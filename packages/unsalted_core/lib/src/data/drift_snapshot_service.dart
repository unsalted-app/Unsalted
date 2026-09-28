// lib/src/data/drift_snapshot_service.dart
//
// Implementierung von SnapshotService (Kapitel 16.4, Schritt 6.6):
// Export/Import nach Kapitel 13.
//
// TRANSAKTIONSGRENZE: wie bei DriftRecipeRepository (Kapitel 16.0.7) hält
// dieser Service die CoreDatabase direkt, weil RecipeDao/FoodDao keine
// Transaktions-API exponieren (Kapitel 16.8).
//
// ROW STATT COMPANION FÜR FoodDao.insertVariant: dieselbe bekannte Lücke
// wie in drift_food_repository.dart (CLAUDE.md Abschnitt 3) — der
// Dateiscope von Schritt 6.6 erlaubt kein Ändern von Mappern, deshalb baut
// `_toFoodRow` die Zeile direkt, statt `food_mapper.dart` anzufassen.
//
// VOLLE INSERT-COMPANION FÜR EINE DIREKT ALS SNAPSHOT ANGELEGTE VERSION:
// `version_mapper.dart` bietet nur `recipeVersionToInsertCompanion` (setzt
// nie Snapshot-Felder, für neue Drafts) und `recipeVersionToSnapshotCompanion`
// (setzt nur die vier Snapshot-Felder, für ein UPDATE einer bestehenden
// Zeile). Für den Import (Kapitel 13.6 Punkt 3: die neue Version wird
// DIREKT mit state = snapshot angelegt, kein Draft) braucht es eine einzige
// Companion mit beidem zugleich — dafür gibt es keine passende Mapper-
// Funktion. Aus demselben Scope-Grund wie oben wird die Companion hier
// direkt gebaut, statt `version_mapper.dart` zu ändern.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../contracts/core_exceptions.dart';
import '../contracts/domain_events.dart';
import '../contracts/snapshot_service.dart';
import '../food/food_variant.dart';
import '../nutrition/nutrient_set.dart';
import '../nutrition/unit_catalog.dart';
import '../recipe/recipe.dart';
import '../recipe/recipe_ingredient.dart';
import '../recipe/recipe_snapshot_v1.dart';
import '../recipe/recipe_step.dart';
import '../recipe/recipe_version.dart';
import '../recipe/snapshot_codec.dart';
import 'core_database.dart' as db;
import 'daos/food_dao.dart';
import 'daos/recipe_dao.dart';
import 'domain_event_bus.dart';
import 'mappers/food_mapper.dart';
import 'mappers/ingredient_mapper.dart';
import 'mappers/recipe_mapper.dart';
import 'mappers/step_mapper.dart';

class DriftSnapshotService implements SnapshotService {
  DriftSnapshotService(
    this._recipeDao,
    this._foodDao,
    this._db, {
    DomainEventBus? eventBus,
  }) : _eventBus = eventBus ?? DomainEventBus.instance;

  final RecipeDao _recipeDao;
  final FoodDao _foodDao;
  final db.CoreDatabase _db;
  final DomainEventBus _eventBus;

  static const Uuid _uuid = Uuid();
  String _newId() => _uuid.v4();
  int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;
  Future<T> _transaction<T>(Future<T> Function() action) => _db.transaction(action);

  // ---------------------------------------------------------------------
  // Export (Kapitel 13.7)
  // ---------------------------------------------------------------------

  @override
  Future<RecipeSnapshotV1> exportVersion(String versionId) async {
    final jsonString = await exportVersionAsJsonString(versionId);
    return SnapshotCodec.decode(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<String> exportVersionAsJsonString(String versionId) async {
    final row = await _recipeDao.getVersion(versionId);
    if (row == null) {
      throw NotFoundException('Version "$versionId" nicht gefunden.');
    }
    if (row.state != VersionState.snapshot.code) {
      throw const IllegalStateException('Nur eingefrorene Versionen können exportiert werden.');
    }
    // Original-String unverändert, nicht neu berechnet (Kapitel 13.7).
    return row.snapshotJson!;
  }

  // ---------------------------------------------------------------------
  // Import (Kapitel 13.5, 13.5.1, 13.6)
  // ---------------------------------------------------------------------

  @override
  Future<String> importSnapshot(RecipeSnapshotV1 s) async {
    // Kein Original-String vorhanden -- deterministisch neu kodiert
    // (Kapitel 13.4). Anders als bei importJsonString bleiben hier keine
    // unbekannten Felder erhalten, weil s bereits ein typisierter Wert ist.
    final jsonString = jsonEncode(SnapshotCodec.encode(s));
    return _import(s, jsonString);
  }

  @override
  Future<String> importJsonString(String json) async {
    final map = jsonDecode(json) as Map<String, dynamic>;
    // Strukturelle Format-/Versionsprüfung (Kapitel 13.5); wirft
    // ImportFormatException/ImportVersionException. Unbekannte Felder
    // werden für die typisierte Dekodierung ignoriert (Kapitel 13.5 letzter
    // Punkt), bleiben aber im Original-String [json] erhalten, der
    // unverändert als snapshot_json gespeichert wird (Kapitel 13.6 Punkt 3,
    // GD-12).
    final decoded = SnapshotCodec.decode(map);
    return _import(decoded, json);
  }

  Future<String> _import(RecipeSnapshotV1 s, String storedJsonString) async {
    _validateSemantics(s);

    final recipeId = _newId();
    final versionId = _newId();
    final now = _now();

    final recipeCompanion = recipeToInsertCompanion(
      Recipe(id: recipeId, title: s.recipe.title, description: s.recipe.description),
      createdAtMs: now,
      updatedAtMs: now,
    );

    // Direkt als Snapshot angelegt, kein Draft (Kapitel 13.6 Punkt 3).
    final versionCompanion = db.RecipeVersionsCompanion.insert(
      id: versionId,
      createdAt: now,
      updatedAt: now,
      recipeId: recipeId,
      parentVersionId: Value(s.version.id),
      versionIndex: 1,
      label: Value(s.version.label),
      state: VersionState.snapshot.code,
      servings: Value(s.version.servings),
      bakingLossPercent: Value(s.version.bakingLossPercent),
      finalWeightOverrideG: Value(s.version.finalWeightOverrideG),
      notes: Value(s.version.notes),
      snapshotJson: Value(storedJsonString),
      snapshotFormatVersion: Value(kSnapshotFormatVersion),
      snapshottedAt: Value(now),
    );

    await _transaction(() async {
      await _recipeDao.insertRecipe(recipeCompanion, versionCompanion);

      final knownVariants = await _loadAllVariants();
      final ingredientCompanions = <db.RecipeIngredientsCompanion>[];
      for (final ingredient in s.ingredients) {
        String? variantId;
        if (ingredient.per100g != null) {
          variantId = await _resolveOrCreateVariant(ingredient, knownVariants, now);
        }
        ingredientCompanions.add(recipeIngredientToInsertCompanion(
          RecipeIngredient(
            id: _newId(),
            versionId: versionId,
            position: ingredient.position,
            foodVariantId: variantId,
            displayName: ingredient.name,
            quantity: ingredient.quantity,
            unitCode: ingredient.unit,
            note: ingredient.note,
          ),
          createdAtMs: now,
          updatedAtMs: now,
        ));
      }
      await _recipeDao.saveDraftIngredients(versionId, ingredientCompanions, now);

      final stepCompanions = s.steps
          .map((step) => recipeStepToInsertCompanion(
                RecipeStep(
                  id: _newId(),
                  versionId: versionId,
                  position: step.position,
                  instruction: step.instruction,
                  timerSeconds: step.timerSeconds,
                ),
                createdAtMs: now,
                updatedAtMs: now,
              ))
          .toList();
      await _recipeDao.saveDraftSteps(versionId, stepCompanions, now);
    });

    _eventBus.add(RecipeCreated(
      id: _newId(),
      at: DateTime.now().toUtc(),
      recipeId: recipeId,
      versionId: versionId,
    ));

    return recipeId;
  }

  // ---------------------------------------------------------------------
  // Semantische Validierung (Kapitel 13.5.1)
  // ---------------------------------------------------------------------

  void _validateSemantics(RecipeSnapshotV1 s) {
    for (final ingredient in s.ingredients) {
      if (ingredient.quantity < Decimal.zero) {
        throw ImportFormatException(
          'quantity muss >= 0 sein (Position ${ingredient.position}).',
        );
      }
      try {
        UnitCatalog.byCode(ingredient.unit);
      } on ArgumentError {
        throw ImportFormatException(
          'unit "${ingredient.unit}" ist unbekannt (Position ${ingredient.position}).',
        );
      }
    }

    if (s.version.bakingLossPercent < Decimal.zero ||
        s.version.bakingLossPercent > Decimal.fromInt(100)) {
      throw const ImportFormatException('baking_loss_percent muss zwischen 0 und 100 liegen.');
    }
    if (s.version.finalWeightOverrideG != null && s.version.finalWeightOverrideG! <= Decimal.zero) {
      throw const ImportFormatException('final_weight_override_g muss > 0 sein oder null.');
    }
    if (s.version.servings != null && s.version.servings! < 1) {
      throw const ImportFormatException('servings muss >= 1 sein oder null.');
    }

    _requireGaplessPositions(s.ingredients.map((i) => i.position).toList(), 'ingredients');
    _requireGaplessPositions(s.steps.map((step) => step.position).toList(), 'steps');
  }

  void _requireGaplessPositions(List<int> positions, String label) {
    final sorted = List<int>.of(positions)..sort();
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i] != i + 1) {
        throw ImportFormatException(
          '$label-Positionen sind nicht positiv und lückenlos 1..n: $sorted',
        );
      }
    }
  }

  // ---------------------------------------------------------------------
  // FoodVariant-Duplikaterkennung (Kapitel 13.6 Punkt 5)
  // ---------------------------------------------------------------------

  Future<List<FoodVariant>> _loadAllVariants() async {
    final rows = await _foodDao.watchAll().first;
    return rows.map(foodVariantFromRow).toList();
  }

  /// a. Barcode-Treffer -> verknüpfen. b. sonst Name+Brand (normalisiert)
  /// und alle acht Nährwertfelder identisch -> verknüpfen. c. sonst neue
  /// FoodVariant mit source = import anlegen. [knownVariants] wird um neu
  /// angelegte Varianten ergänzt, damit mehrere Zutaten mit identischem
  /// Namen/Nährwerten innerhalb desselben Imports dieselbe neue Variante
  /// treffen, statt Duplikate zu erzeugen (Kapitel 13.6 nennt diesen Fall
  /// nicht explizit, aber IT-05 verlangt "nur ein Satz Varianten" bei
  /// Übereinstimmung).
  Future<String> _resolveOrCreateVariant(
    RecipeSnapshotIngredient ingredient,
    List<FoodVariant> knownVariants,
    int nowMs,
  ) async {
    final barcode = ingredient.barcode;
    if (barcode != null && barcode.isNotEmpty) {
      for (final variant in knownVariants) {
        if (variant.barcode == barcode) return variant.id;
      }
    }

    final normalizedName = ingredient.name.trim().toLowerCase();
    final normalizedBrand = (ingredient.brand ?? '').trim().toLowerCase();
    for (final variant in knownVariants) {
      final variantName = variant.name.trim().toLowerCase();
      final variantBrand = (variant.brand ?? '').trim().toLowerCase();
      if (variantName == normalizedName &&
          variantBrand == normalizedBrand &&
          _sameEightFields(variant.nutrients, ingredient.per100g!)) {
        return variant.id;
      }
    }

    final newVariant = FoodVariant(
      id: _newId(),
      name: ingredient.name,
      brand: ingredient.brand,
      barcode: barcode,
      source: FoodSource.imported,
      densityGPerMl: ingredient.densityGPerMl,
      gramsPerPiece: ingredient.gramsPerPiece,
      nutrients: ingredient.per100g!,
    );
    await _foodDao.insertVariant(_toFoodRow(newVariant, nowMs));
    knownVariants.add(newVariant);
    return newVariant.id;
  }

  bool _sameEightFields(NutrientSet a, NutrientSet b) {
    return a.energyKcal == b.energyKcal &&
        a.fatG == b.fatG &&
        a.saturatedFatG == b.saturatedFatG &&
        a.carbsG == b.carbsG &&
        a.sugarsG == b.sugarsG &&
        a.fiberG == b.fiberG &&
        a.proteinG == b.proteinG &&
        a.saltG == b.saltG;
  }

  db.FoodVariant _toFoodRow(FoodVariant variant, int nowMs) {
    final n = variant.nutrients;
    return db.FoodVariant(
      id: variant.id,
      createdAt: nowMs,
      updatedAt: nowMs,
      name: variant.name,
      brand: variant.brand,
      barcode: variant.barcode,
      source: variant.source.code,
      sourceRef: variant.sourceRef,
      densityGPerMl: variant.densityGPerMl,
      gramsPerPiece: variant.gramsPerPiece,
      servingSizeG: variant.servingSizeG,
      energyKcal: n.energyKcal,
      fatG: n.fatG,
      saturatedFatG: n.saturatedFatG,
      carbsG: n.carbsG,
      sugarsG: n.sugarsG,
      fiberG: n.fiberG,
      proteinG: n.proteinG,
      saltG: n.saltG,
      extraJson: jsonEncode({
        for (final entry in n.extra.entries) entry.key: entry.value.toString(),
      }),
    );
  }
}
