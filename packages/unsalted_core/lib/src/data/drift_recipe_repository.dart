// lib/src/data/drift_recipe_repository.dart
//
// Implementierung von RecipeRepository (Kapitel 16.1, Schritt 6.3).
//
// TRANSAKTIONSGRENZE (Kapitel 16.0.7): Das Repository besitzt die
// Transaction Boundary, nicht die DAOs. RecipeDao/FoodDao (Kapitel 16.8)
// exponieren dafür keine Transaktions-API — deshalb bekommt dieses
// Repository zusätzlich zu den beiden DAOs die CoreDatabase direkt injiziert
// und öffnet Transaktionen selbst über `_db.transaction(...)`. Das ist kein
// `coreDatabaseProvider`-Import (das bleibt verboten, Riverpod ist in
// Schritt 6.3 nicht Thema) — nur der Datenbanktyp selbst wird gebraucht, um
// Kapitel 16.0.7 technisch einzulösen.
//
// NÄHRWERT-BERECHNUNG IN snapshotVersion (Kapitel 12.3, Schritt 3+4): Die
// Dateivertragstabelle (Kapitel 18.1) listet `nutrition/*` unter "darf nicht
// importieren" für diese Datei. Das steht im Widerspruch zu Kapitel 12.3,
// das für snapshotVersion ausdrücklich `NutritionEngine.calculate(...)`
// vorschreibt — und Kapitel 12 ist laut der Arbeitskarte für Schritt 6.3
// selbst als verbindlicher Contract genannt. Es gibt keine andere erlaubte
// Datei in diesem Schritt, die diese Berechnung stattdessen übernehmen
// könnte (der Dateiscope erlaubt nur das Anlegen dieser einen Datei). Kein
// Architekturtest (AT-02, AT-05) verbietet diesen Import tatsächlich; AT-02
// prüft nur, dass nutrition/ selbst nichts Unerlaubtes importiert, AT-05
// nur, dass Nicht-data/-Dateien kein Drift importieren. Entscheidung: dem
// konkreteren, für diesen Schritt ausdrücklich verbindlichen Kapitel 12.3
// folgen. Siehe docs/decisions.md (Eintrag zu Schritt 6.3).
//
// FOOD-VARIANTEN-AUFLÖSUNG: Für snapshotVersion müssen die Nährwerte der
// verknüpften FoodVariant zum Zeitpunkt des Einfrierens kopiert werden
// (Kapitel 12.3 Punkt 4, Kapitel 13.1 `per100g`). RecipeDao kennt keine
// FoodVariants — deshalb zusätzlich FoodDao injiziert (Kapitel 18.1 erlaubt
// `daos/*`, nicht nur RecipeDao).

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../contracts/core_exceptions.dart';
import '../contracts/domain_events.dart';
import '../contracts/input_models.dart';
import '../contracts/recipe_repository.dart';
import '../food/food_variant.dart';
import '../nutrition/decimal_math.dart';
import '../nutrition/nutrition_engine.dart' as engine;
import '../nutrition/unit_catalog.dart';
import '../recipe/recipe.dart';
import '../recipe/recipe_change.dart';
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
import 'mappers/version_mapper.dart';

class DriftRecipeRepository implements RecipeRepository {
  DriftRecipeRepository(
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
  // Lesende Methoden
  // ---------------------------------------------------------------------

  @override
  Stream<List<Recipe>> watchRecipes() {
    return _recipeDao.watchRecipes().map((rows) => rows.map(recipeFromRow).toList());
  }

  @override
  Stream<Recipe?> watchRecipe(String id) {
    return _recipeDao.watchRecipe(id).map((row) => row == null ? null : recipeFromRow(row));
  }

  @override
  Stream<List<RecipeVersion>> watchVersions(String recipeId) {
    return _recipeDao
        .watchVersions(recipeId)
        .map((rows) => rows.map((row) => recipeVersionFromRow(row)).toList());
  }

  @override
  Future<RecipeVersion?> getVersion(String versionId) async {
    final row = await _recipeDao.getVersion(versionId);
    if (row == null) return null;

    final ingredientRows = await _recipeDao.getIngredientsForVersion(versionId);
    final stepRows = await _recipeDao.getStepsForVersion(versionId);

    return recipeVersionFromRow(
      row,
      ingredients: ingredientRows.map(recipeIngredientFromRow).toList(),
      steps: stepRows.map(recipeStepFromRow).toList(),
    );
  }

  // ---------------------------------------------------------------------
  // createRecipe / updateRecipe
  // ---------------------------------------------------------------------

  @override
  Future<String> createRecipe(NewRecipe recipe) async {
    if (recipe.title.isEmpty || recipe.title.length > 200) {
      throw const ValidationException('title muss 1–200 Zeichen lang sein');
    }

    final recipeId = _newId();
    final versionId = _newId();
    final now = _now();

    final recipeCompanion = recipeToInsertCompanion(
      Recipe(id: recipeId, title: recipe.title, description: recipe.description),
      createdAtMs: now,
      updatedAtMs: now,
    );
    final versionCompanion = recipeVersionToInsertCompanion(
      RecipeVersion(
        id: versionId,
        recipeId: recipeId,
        parentVersionId: null,
        versionIndex: 1,
        label: null,
        state: VersionState.draft,
        servings: null,
        bakingLossPercent: Decimal.zero,
        finalWeightOverrideG: null,
        notes: null,
      ),
      createdAtMs: now,
      updatedAtMs: now,
    );

    await _transaction(() => _recipeDao.insertRecipe(recipeCompanion, versionCompanion));

    _eventBus.add(RecipeCreated(
      id: _newId(),
      at: DateTime.now().toUtc(),
      recipeId: recipeId,
      versionId: versionId,
    ));

    return recipeId;
  }

  @override
  Future<void> updateRecipe(String id, UpdateRecipeCommand command) async {
    final current = await _recipeDao.getRecipe(id);
    if (current == null) {
      throw NotFoundException('Rezept "$id" nicht gefunden.');
    }

    final now = _now();
    final changes = db.RecipesCompanion(
      title: command.title != null ? Value(command.title!) : const Value.absent(),
      description: command.description != null
          ? Value(command.description!.value)
          : const Value.absent(),
    );

    await _transaction(() => _recipeDao.updateRecipe(id, changes, now));

    _eventBus.add(RecipeUpdated(id: _newId(), at: DateTime.now().toUtc(), recipeId: id));
  }

  // ---------------------------------------------------------------------
  // saveDraft
  // ---------------------------------------------------------------------

  @override
  Future<void> saveDraft(RecipeVersionDraft draft) async {
    final row = await _recipeDao.getVersion(draft.id);
    if (row == null) {
      throw NotFoundException('Version "${draft.id}" nicht gefunden.');
    }
    if (row.state != VersionState.snapshot.code && row.state != VersionState.draft.code) {
      throw IllegalStateException('Unbekannter Versionsstatus "${row.state}".');
    }
    if (row.state == VersionState.snapshot.code) {
      throw SnapshotImmutableException(
        'Version "${draft.id}" ist eingefroren und kann nicht verändert werden.',
      );
    }

    _validateDraftValues(draft);

    final now = _now();

    final existingIngredients = await _recipeDao.getIngredientsForVersion(draft.id);
    final existingIngredientsById = {for (final r in existingIngredients) r.id: r};
    final ingredientCompanions = draft.ingredients.map((ingredient) {
      final existing = existingIngredientsById[ingredient.id];
      return recipeIngredientToInsertCompanion(
        ingredient,
        createdAtMs: existing?.createdAt ?? now,
        updatedAtMs: now,
      );
    }).toList();

    final existingSteps = await _recipeDao.getStepsForVersion(draft.id);
    final existingStepsById = {for (final r in existingSteps) r.id: r};
    final stepCompanions = draft.steps.map((step) {
      final existing = existingStepsById[step.id];
      return recipeStepToInsertCompanion(
        step,
        createdAtMs: existing?.createdAt ?? now,
        updatedAtMs: now,
      );
    }).toList();

    final versionCompanion = recipeVersionToUpdateCompanion(
      RecipeVersion(
        id: draft.id,
        recipeId: draft.recipeId,
        parentVersionId: draft.parentVersionId,
        versionIndex: draft.versionIndex,
        label: draft.label,
        state: VersionState.draft,
        servings: draft.servings,
        bakingLossPercent: draft.bakingLossPercent,
        finalWeightOverrideG: draft.finalWeightOverrideG,
        notes: draft.notes,
      ),
      updatedAtMs: now,
    ).copyWith(id: Value(draft.id));

    await _transaction(() async {
      await _recipeDao.saveDraftIngredients(draft.id, ingredientCompanions, now);
      await _recipeDao.saveDraftSteps(draft.id, stepCompanions, now);
      await _recipeDao.updateVersion(versionCompanion);
    });

    _eventBus.add(RecipeUpdated(
      id: _newId(),
      at: DateTime.now().toUtc(),
      recipeId: draft.recipeId,
      versionId: draft.id,
    ));
  }

  void _validateDraftValues(RecipeVersionDraft draft) {
    for (final ingredient in draft.ingredients) {
      if (ingredient.quantity < Decimal.zero) {
        throw ValidationException(
          'quantity muss >= 0 sein (Zutat "${ingredient.displayName}")',
        );
      }
      try {
        UnitCatalog.byCode(ingredient.unitCode);
      } on ArgumentError {
        throw ValidationException('unitCode "${ingredient.unitCode}" ist unbekannt');
      }
    }
    if (draft.bakingLossPercent < Decimal.zero || draft.bakingLossPercent > Decimal.fromInt(100)) {
      throw const ValidationException('bakingLossPercent muss zwischen 0 und 100 liegen');
    }
    if (draft.finalWeightOverrideG != null && draft.finalWeightOverrideG! <= Decimal.zero) {
      throw const ValidationException('finalWeightOverrideG muss > 0 sein oder null');
    }
    if (draft.servings != null && draft.servings! < 1) {
      throw const ValidationException('servings muss >= 1 sein oder null');
    }
  }

  // ---------------------------------------------------------------------
  // snapshotVersion (Kapitel 12.3)
  // ---------------------------------------------------------------------

  @override
  Future<void> snapshotVersion(String versionId) async {
    final versionRow = await _recipeDao.getVersion(versionId);
    if (versionRow == null) {
      throw NotFoundException('Version "$versionId" nicht gefunden.');
    }
    if (versionRow.state != VersionState.draft.code) {
      throw IllegalStateException('Version "$versionId" ist kein Draft.');
    }

    final recipeRow = await _recipeDao.getRecipe(versionRow.recipeId);
    if (recipeRow == null) {
      throw NotFoundException('Rezept "${versionRow.recipeId}" nicht gefunden.');
    }

    final ingredientRows = await _recipeDao.getIngredientsForVersion(versionId);
    if (ingredientRows.isEmpty) {
      throw const ValidationException(
        'Eine Version ohne Zutaten kann nicht eingefroren werden.',
      );
    }
    final stepRows = await _recipeDao.getStepsForVersion(versionId);

    final variants = await _resolveVariants(ingredientRows);

    final engineIngredients = ingredientRows.map((row) {
      final variant = row.foodVariantId == null ? null : variants[row.foodVariantId];
      return engine.IngredientInput(
        displayName: row.displayName,
        quantity: row.quantity,
        unitCode: row.unitCode,
        per100g: variant?.nutrients,
        densityGPerMl: variant?.densityGPerMl,
        gramsPerPiece: variant?.gramsPerPiece,
      );
    }).toList();

    final result = engine.NutritionEngine.calculate(
      ingredients: engineIngredients,
      bakingLossPercent: versionRow.bakingLossPercent,
      finalWeightOverrideG: versionRow.finalWeightOverrideG,
      servings: versionRow.servings,
    );

    final snapshotIngredients = ingredientRows.map((row) {
      final variant = row.foodVariantId == null ? null : variants[row.foodVariantId];
      final grams = UnitCatalog.toGrams(
        row.quantity,
        row.unitCode,
        densityGPerMl: variant?.densityGPerMl,
        gramsPerPiece: variant?.gramsPerPiece,
      );
      return RecipeSnapshotIngredient(
        position: row.position,
        name: row.displayName,
        brand: variant?.brand,
        barcode: variant?.barcode,
        quantity: row.quantity,
        unit: row.unitCode,
        grams: grams?.toFixedDecimal(),
        note: row.note,
        densityGPerMl: variant?.densityGPerMl,
        gramsPerPiece: variant?.gramsPerPiece,
        per100g: variant?.nutrients,
      );
    }).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    final snapshotSteps = stepRows
        .map((row) => RecipeSnapshotStep(
              position: row.position,
              instruction: row.instruction,
              timerSeconds: row.timerSeconds,
            ))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    final now = _now();
    final snapshottedAt = DateTime.now().toUtc();

    final snapshot = RecipeSnapshotV1(
      recipe: RecipeSnapshotRecipe(
        id: recipeRow.id,
        title: recipeRow.title,
        description: recipeRow.description,
      ),
      version: RecipeSnapshotVersion(
        id: versionRow.id,
        parentVersionId: versionRow.parentVersionId,
        versionIndex: versionRow.versionIndex,
        label: versionRow.label,
        servings: versionRow.servings,
        bakingLossPercent: versionRow.bakingLossPercent,
        finalWeightOverrideG: versionRow.finalWeightOverrideG,
        notes: versionRow.notes,
        createdAt: DateTime.fromMillisecondsSinceEpoch(versionRow.createdAt, isUtc: true),
        snapshottedAt: snapshottedAt,
      ),
      ingredients: snapshotIngredients,
      steps: snapshotSteps,
      nutrition: RecipeSnapshotNutrition(
        rawWeightG: result.rawWeightG,
        finalWeightG: result.finalWeightG,
        total: result.total,
        per100g: result.per100g,
        incomplete: result.incomplete.toList(),
        notCalculable: result.notCalculable,
      ),
    );

    final jsonString = jsonEncode(SnapshotCodec.encode(snapshot));

    await _transaction(() => _recipeDao.updateVersionSnapshotState(
          versionId,
          VersionState.snapshot.code,
          jsonString,
          kSnapshotFormatVersion,
          snapshottedAt.millisecondsSinceEpoch,
          now,
        ));

    _eventBus.add(VersionSnapshotted(
      id: _newId(),
      at: DateTime.now().toUtc(),
      recipeId: versionRow.recipeId,
      versionId: versionId,
    ));
  }

  Future<Map<String, FoodVariant>> _resolveVariants(
    List<db.RecipeIngredientRow> ingredientRows,
  ) async {
    final ids = {
      for (final row in ingredientRows)
        if (row.foodVariantId != null) row.foodVariantId!,
    };
    final result = <String, FoodVariant>{};
    for (final id in ids) {
      final row = await _foodDao.getById(id);
      if (row != null) result[id] = foodVariantFromRow(row);
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // createDraftFrom / applyChangesAsNewDraft (Kapitel 12.4, 14.4)
  //
  // Beide teilen sich _prepareDraftFrom: dieser private Helfer öffnet keine
  // eigene Transaktion und löst kein Event aus, damit applyChangesAsNewDraft
  // (das intern konzeptionell auf createDraftFrom aufbaut, Kapitel 14.4
  // Punkt 1) nicht zwei Transaktionen/zwei Events erzeugt, wo Kapitel 14.4
  // Punkt 5+6 ausdrücklich nur eine Transaktion und ein Event verlangt.
  // ---------------------------------------------------------------------

  @override
  Future<String> createDraftFrom(String versionId) async {
    final seed = await _prepareDraftFrom(versionId);
    final now = _now();

    await _transaction(() async {
      await _recipeDao.insertVersion(recipeVersionToInsertCompanion(
        RecipeVersion(
          id: seed.newVersionId,
          recipeId: seed.recipeId,
          parentVersionId: versionId,
          versionIndex: seed.versionIndex,
          label: seed.label,
          state: VersionState.draft,
          servings: seed.servings,
          bakingLossPercent: seed.bakingLossPercent,
          finalWeightOverrideG: seed.finalWeightOverrideG,
          notes: seed.notes,
        ),
        createdAtMs: now,
        updatedAtMs: now,
      ));
      await _recipeDao.saveDraftIngredients(
        seed.newVersionId,
        seed.ingredients
            .map((i) => recipeIngredientToInsertCompanion(i, createdAtMs: now, updatedAtMs: now))
            .toList(),
        now,
      );
      await _recipeDao.saveDraftSteps(
        seed.newVersionId,
        seed.steps
            .map((s) => recipeStepToInsertCompanion(s, createdAtMs: now, updatedAtMs: now))
            .toList(),
        now,
      );
    });

    _eventBus.add(RecipeUpdated(
      id: _newId(),
      at: DateTime.now().toUtc(),
      recipeId: seed.recipeId,
      versionId: seed.newVersionId,
    ));

    return seed.newVersionId;
  }

  @override
  Future<String> applyChangesAsNewDraft(
    String baseVersionId,
    List<RecipeChange> changes,
  ) async {
    final seed = await _prepareDraftFrom(baseVersionId);

    var ingredients = List<RecipeIngredient>.of(seed.ingredients);
    var steps = List<RecipeStep>.of(seed.steps);
    var bakingLossPercent = seed.bakingLossPercent;
    var finalWeightOverrideG = seed.finalWeightOverrideG;
    var servings = seed.servings;
    var notes = seed.notes;
    String? newTitle;

    for (final change in changes) {
      change.validate();

      switch (change) {
        case AddIngredient c:
          _requireInsertPosition(c.position, ingredients.length, 'position');
          ingredients = List.of(ingredients)
            ..insert(
              c.position - 1,
              RecipeIngredient(
                id: _newId(),
                versionId: seed.newVersionId,
                position: c.position,
                foodVariantId: c.foodVariantId,
                displayName: c.displayName,
                quantity: c.quantity,
                unitCode: c.unitCode,
                note: c.note,
              ),
            );
          ingredients = _renumber(ingredients, (i, p) => i.copyWith(position: p));

        case RemoveIngredient c:
          _requireExistingPosition(c.position, ingredients.length, 'position');
          ingredients = List.of(ingredients)..removeAt(c.position - 1);
          ingredients = _renumber(ingredients, (i, p) => i.copyWith(position: p));

        case SetIngredientQuantity c:
          _requireExistingPosition(c.position, ingredients.length, 'position');
          final existing = ingredients[c.position - 1];
          ingredients = List.of(ingredients)
            ..[c.position - 1] = existing.copyWith(
              quantity: c.quantity,
              unitCode: c.unitCode ?? existing.unitCode,
            );

        case ReplaceIngredient c:
          _requireExistingPosition(c.position, ingredients.length, 'position');
          final existing = ingredients[c.position - 1];
          ingredients = List.of(ingredients)
            ..[c.position - 1] = RecipeIngredient(
              id: existing.id,
              versionId: existing.versionId,
              position: c.position,
              foodVariantId: c.foodVariantId,
              displayName: c.displayName,
              quantity: c.quantity,
              unitCode: c.unitCode,
              note: null,
            );

        case MoveIngredient c:
          _requireExistingPosition(c.from, ingredients.length, 'from');
          _requireExistingPosition(c.to, ingredients.length, 'to');
          final mutable = List<RecipeIngredient>.of(ingredients);
          final item = mutable.removeAt(c.from - 1);
          mutable.insert(c.to - 1, item);
          ingredients = _renumber(mutable, (i, p) => i.copyWith(position: p));

        case AddStep c:
          _requireInsertPosition(c.position, steps.length, 'position');
          steps = List.of(steps)
            ..insert(
              c.position - 1,
              RecipeStep(
                id: _newId(),
                versionId: seed.newVersionId,
                position: c.position,
                instruction: c.instruction,
                timerSeconds: c.timerSeconds,
              ),
            );
          steps = _renumber(steps, (s, p) => s.copyWith(position: p));

        case RemoveStep c:
          _requireExistingPosition(c.position, steps.length, 'position');
          steps = List.of(steps)..removeAt(c.position - 1);
          steps = _renumber(steps, (s, p) => s.copyWith(position: p));

        case SetStep c:
          _requireExistingPosition(c.position, steps.length, 'position');
          final existing = steps[c.position - 1];
          final newTimerSeconds =
              c.timerSeconds != null ? c.timerSeconds!.value : existing.timerSeconds;
          steps = List.of(steps)
            ..[c.position - 1] = existing.copyWith(
              instruction: c.instruction ?? existing.instruction,
              timerSeconds: newTimerSeconds,
            );

        case SetBakingLoss c:
          bakingLossPercent = c.percent;

        case SetFinalWeightOverride c:
          finalWeightOverrideG = c.grams;

        case SetServings c:
          servings = c.servings;

        case SetTitle c:
          newTitle = c.title;

        case SetNotes c:
          notes = c.notes;
      }
    }

    ingredients = _renumber(ingredients, (i, p) => i.copyWith(position: p));
    steps = _renumber(steps, (s, p) => s.copyWith(position: p));

    final now = _now();

    await _transaction(() async {
      await _recipeDao.insertVersion(recipeVersionToInsertCompanion(
        RecipeVersion(
          id: seed.newVersionId,
          recipeId: seed.recipeId,
          parentVersionId: baseVersionId,
          versionIndex: seed.versionIndex,
          label: seed.label,
          state: VersionState.draft,
          servings: servings,
          bakingLossPercent: bakingLossPercent,
          finalWeightOverrideG: finalWeightOverrideG,
          notes: notes,
        ),
        createdAtMs: now,
        updatedAtMs: now,
      ));
      await _recipeDao.saveDraftIngredients(
        seed.newVersionId,
        ingredients
            .map((i) => recipeIngredientToInsertCompanion(i, createdAtMs: now, updatedAtMs: now))
            .toList(),
        now,
      );
      await _recipeDao.saveDraftSteps(
        seed.newVersionId,
        steps
            .map((s) => recipeStepToInsertCompanion(s, createdAtMs: now, updatedAtMs: now))
            .toList(),
        now,
      );
      if (newTitle != null) {
        await _recipeDao.updateRecipe(
          seed.recipeId,
          db.RecipesCompanion(title: Value(newTitle)),
          now,
        );
      }
    });

    _eventBus.add(RecipeUpdated(
      id: _newId(),
      at: DateTime.now().toUtc(),
      recipeId: seed.recipeId,
      versionId: seed.newVersionId,
    ));

    return seed.newVersionId;
  }

  List<T> _renumber<T>(List<T> items, T Function(T item, int position) withPosition) {
    return [for (var i = 0; i < items.length; i++) withPosition(items[i], i + 1)];
  }

  void _requireExistingPosition(int position, int length, String field) {
    if (position < 1 || position > length) {
      throw ValidationException('$field verweist auf keine vorhandene Zeile: $position');
    }
  }

  void _requireInsertPosition(int position, int length, String field) {
    if (position < 1 || position > length + 1) {
      throw ValidationException('$field liegt außerhalb des gültigen Bereichs: $position');
    }
  }

  Future<_DraftSeed> _prepareDraftFrom(String sourceVersionId) async {
    final sourceRow = await _recipeDao.getVersion(sourceVersionId);
    if (sourceRow == null) {
      throw NotFoundException('Version "$sourceVersionId" nicht gefunden.');
    }
    final recipeRow = await _recipeDao.getRecipe(sourceRow.recipeId);
    if (recipeRow == null) {
      throw NotFoundException('Rezept "${sourceRow.recipeId}" nicht gefunden.');
    }

    final activeVersions = await _recipeDao.watchVersions(sourceRow.recipeId).first;
    final maxIndex = activeVersions.fold<int>(
      0,
      (max, v) => v.versionIndex > max ? v.versionIndex : max,
    );
    final newVersionId = _newId();

    List<RecipeIngredient> ingredients;
    List<RecipeStep> steps;

    if (sourceRow.state == VersionState.snapshot.code) {
      // Kapitel 12.4 Punkt 3: aus snapshotJson lesen, nicht aus den Zeilen.
      // Das Snapshot-Format (Kapitel 13.1/13.2) trägt keine food_variant_id
      // — eine Zutat aus einem Snapshot wird daher ohne Varianten-Verweis
      // kopiert (self-contained: die Nährwerte stehen bereits als per100g
      // im Snapshot, ein Re-Linking ist für 12.4 nicht spezifiziert, anders
      // als beim Import, Kapitel 13.6 Punkt 5).
      final decoded = SnapshotCodec.decode(
        jsonDecode(sourceRow.snapshotJson!) as Map<String, dynamic>,
      );
      ingredients = decoded.ingredients
          .map((si) => RecipeIngredient(
                id: _newId(),
                versionId: newVersionId,
                position: si.position,
                foodVariantId: null,
                displayName: si.name,
                quantity: si.quantity,
                unitCode: si.unit,
                note: si.note,
              ))
          .toList();
      steps = decoded.steps
          .map((ss) => RecipeStep(
                id: _newId(),
                versionId: newVersionId,
                position: ss.position,
                instruction: ss.instruction,
                timerSeconds: ss.timerSeconds,
              ))
          .toList();
    } else {
      final ingredientRows = await _recipeDao.getIngredientsForVersion(sourceVersionId);
      final stepRows = await _recipeDao.getStepsForVersion(sourceVersionId);
      ingredients = ingredientRows
          .map((row) => RecipeIngredient(
                id: _newId(),
                versionId: newVersionId,
                position: row.position,
                foodVariantId: row.foodVariantId,
                displayName: row.displayName,
                quantity: row.quantity,
                unitCode: row.unitCode,
                note: row.note,
              ))
          .toList();
      steps = stepRows
          .map((row) => RecipeStep(
                id: _newId(),
                versionId: newVersionId,
                position: row.position,
                instruction: row.instruction,
                timerSeconds: row.timerSeconds,
              ))
          .toList();
    }

    return _DraftSeed(
      newVersionId: newVersionId,
      recipeId: sourceRow.recipeId,
      versionIndex: maxIndex + 1,
      label: sourceRow.label,
      servings: sourceRow.servings,
      bakingLossPercent: sourceRow.bakingLossPercent,
      finalWeightOverrideG: sourceRow.finalWeightOverrideG,
      notes: sourceRow.notes,
      ingredients: ingredients,
      steps: steps,
    );
  }

  // ---------------------------------------------------------------------
  // setMasterVersion / deleteVersion / softDeleteRecipe (Kapitel 12.5)
  // ---------------------------------------------------------------------

  @override
  Future<void> setMasterVersion(String recipeId, String versionId) async {
    final row = await _recipeDao.getVersion(versionId);
    if (row == null || row.recipeId != recipeId) {
      throw const IllegalStateException(
        'Version gehört nicht zu diesem Rezept oder existiert nicht.',
      );
    }
    if (row.state != VersionState.snapshot.code) {
      throw const IllegalStateException('Nur eingefrorene Versionen können Master werden.');
    }

    final now = _now();
    await _transaction(() => _recipeDao.setMasterVersionId(recipeId, versionId, now));

    _eventBus.add(RecipeUpdated(id: _newId(), at: DateTime.now().toUtc(), recipeId: recipeId));
  }

  @override
  Future<void> deleteVersion(String versionId) async {
    final row = await _recipeDao.getVersion(versionId);
    if (row == null) {
      throw NotFoundException('Version "$versionId" nicht gefunden.');
    }

    final recipeRow = await _recipeDao.getRecipe(row.recipeId);
    if (recipeRow != null && recipeRow.masterVersionId == versionId) {
      throw const IllegalStateException('Die Master-Version kann nicht gelöscht werden.');
    }

    final activeVersions = await _recipeDao.watchVersions(row.recipeId).first;
    if (activeVersions.length <= 1) {
      throw const IllegalStateException(
        'Die letzte verbleibende Version eines Rezepts kann nicht gelöscht werden.',
      );
    }

    final now = _now();
    await _transaction(() => _recipeDao.softDeleteVersion(versionId, now, now));

    _eventBus.add(RecipeUpdated(id: _newId(), at: DateTime.now().toUtc(), recipeId: row.recipeId));
  }

  @override
  Future<void> softDeleteRecipe(String recipeId) async {
    final now = _now();

    await _transaction(() async {
      final activeVersions = await _recipeDao.watchVersions(recipeId).first;
      await _recipeDao.updateRecipe(recipeId, db.RecipesCompanion(deletedAt: Value(now)), now);
      for (final version in activeVersions) {
        await _recipeDao.softDeleteVersion(version.id, now, now);
      }
    });

    _eventBus.add(RecipeDeleted(id: _newId(), at: DateTime.now().toUtc(), recipeId: recipeId));
  }

  // ---------------------------------------------------------------------
  // assignOwner (Kapitel 16.1, letzter Absatz — Teil 1 schreibt, Teil 3 ruft)
  // ---------------------------------------------------------------------

  @override
  Future<void> assignOwner(String ownerId) async {
    final now = _now();

    await _transaction(() async {
      final recipes = await _recipeDao.watchRecipes().first;
      for (final recipe in recipes) {
        if (recipe.ownerId == null) {
          await _recipeDao.updateRecipe(
            recipe.id,
            db.RecipesCompanion(ownerId: Value(ownerId)),
            now,
          );
        }
      }

      final variants = await _foodDao.watchAll().first;
      for (final variant in variants) {
        if (variant.ownerId == null) {
          await _foodDao.updateVariant(variant.copyWith(ownerId: Value(ownerId)), now);
        }
      }
    });
  }
}

class _DraftSeed {
  _DraftSeed({
    required this.newVersionId,
    required this.recipeId,
    required this.versionIndex,
    required this.label,
    required this.servings,
    required this.bakingLossPercent,
    required this.finalWeightOverrideG,
    required this.notes,
    required this.ingredients,
    required this.steps,
  });

  final String newVersionId;
  final String recipeId;
  final int versionIndex;
  final String? label;
  final int? servings;
  final Decimal bakingLossPercent;
  final Decimal? finalWeightOverrideG;
  final String? notes;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
}
