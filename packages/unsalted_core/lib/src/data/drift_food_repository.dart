// lib/src/data/drift_food_repository.dart
//
// Implementierung von FoodRepository (Kapitel 16.2, Schritt 6.4).
//
// ROW STATT COMPANION FÜR insert/update: `FoodDao.insertVariant`/
// `updateVariant` erwarten laut Kapitel 16.8 einen vollen `FoodVariantRow`,
// keinen Companion (anders als bei RecipeDao). `food_mapper.dart` liefert
// bisher nur `foodVariantToInsertCompanion`/`foodVariantToUpdateCompanion`
// (Companions) — siehe CLAUDE.md Abschnitt 3, bekannte Lücke. Der
// Dateiscope von Schritt 6.4 erlaubt ausdrücklich nur das Lesen, nicht das
// Ändern von Mappern ("Lesen, aber nicht ändern: Food-Contracts, Mapper und
// Tabellen"). Deshalb baut dieses Repository die Zeile für insert/update
// direkt selbst (`_toRow`), analog zur bestehenden Companion-Logik in
// `food_mapper.dart`, statt die Mapper-Datei zu ändern. Für die Leserichtung
// wird weiterhin `foodVariantFromRow` aus `food_mapper.dart` verwendet, die
// bereits korrekt ist.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import '../contracts/core_exceptions.dart';
import '../contracts/domain_events.dart';
import '../contracts/food_repository.dart';
import '../contracts/input_models.dart';
import '../food/food_variant.dart';
import '../nutrition/nutrient_set.dart';
import '../nutrition/nutrient_validator.dart';
import 'core_database.dart' as db;
import 'daos/food_dao.dart';
import 'domain_event_bus.dart';
import 'mappers/food_mapper.dart';

class DriftFoodRepository implements FoodRepository {
  DriftFoodRepository(this._foodDao, {DomainEventBus? eventBus})
      : _eventBus = eventBus ?? DomainEventBus.instance;

  final FoodDao _foodDao;
  final DomainEventBus _eventBus;

  static const Uuid _uuid = Uuid();

  String _newId() => _uuid.v4();
  int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  @override
  Stream<List<FoodVariant>> watchAll() {
    return _foodDao.watchAll().map((rows) => rows.map(foodVariantFromRow).toList());
  }

  @override
  Stream<List<FoodVariant>> search(String query) {
    return _foodDao.search(query).map((rows) => rows.map(foodVariantFromRow).toList());
  }

  @override
  Future<FoodVariant?> getById(String id) async {
    final row = await _foodDao.getById(id);
    return row == null ? null : foodVariantFromRow(row);
  }

  @override
  Future<FoodVariant?> findByBarcode(String code) async {
    final row = await _foodDao.findByBarcode(code);
    return row == null ? null : foodVariantFromRow(row);
  }

  @override
  Future<String> createVariant(NewFoodVariant variant) async {
    // Wirft ValidationException bei negativen Nährwerten (Kapitel 8.6);
    // Warnungen (z. B. "alle Felder leer") blockieren das Speichern nicht
    // und werden hier bewusst verworfen — FoodRepository.createVariant hat
    // laut Kapitel 16.2 keinen Rückgabeweg für Warnungen, das ist Sache der
    // UI (Bildschirm 10, Phase 8).
    NutrientValidator.check(variant.nutrients);

    final id = _newId();
    final now = _now();

    await _foodDao.insertVariant(_toRow(
      id: id,
      createdAtMs: now,
      updatedAtMs: now,
      ownerId: null,
      name: variant.name,
      brand: variant.brand,
      barcode: variant.barcode,
      source: variant.source,
      sourceRef: variant.sourceRef,
      densityGPerMl: variant.densityGPerMl,
      gramsPerPiece: variant.gramsPerPiece,
      servingSizeG: variant.servingSizeG,
      nutrients: variant.nutrients,
    ));

    _eventBus.add(FoodChanged(
      id: _newId(),
      at: DateTime.now().toUtc(),
      variantId: id,
      kind: FoodChangeKind.created,
    ));

    return id;
  }

  @override
  Future<void> updateVariant(FoodVariant variant) async {
    final existing = await _foodDao.getById(variant.id);
    if (existing == null) {
      throw NotFoundException('FoodVariant "${variant.id}" nicht gefunden.');
    }
    NutrientValidator.check(variant.nutrients);

    final now = _now();

    await _foodDao.updateVariant(
      _toRow(
        id: variant.id,
        createdAtMs: existing.createdAt,
        updatedAtMs: now,
        ownerId: existing.ownerId,
        name: variant.name,
        brand: variant.brand,
        barcode: variant.barcode,
        source: variant.source,
        sourceRef: variant.sourceRef,
        densityGPerMl: variant.densityGPerMl,
        gramsPerPiece: variant.gramsPerPiece,
        servingSizeG: variant.servingSizeG,
        nutrients: variant.nutrients,
      ),
      now,
    );

    _eventBus.add(FoodChanged(
      id: _newId(),
      at: DateTime.now().toUtc(),
      variantId: variant.id,
      kind: FoodChangeKind.updated,
    ));
  }

  @override
  Future<void> softDeleteVariant(String id) async {
    final now = _now();
    await _foodDao.softDeleteVariant(id, now);

    _eventBus.add(FoodChanged(
      id: _newId(),
      at: DateTime.now().toUtc(),
      variantId: id,
      kind: FoodChangeKind.deleted,
    ));
  }

  db.FoodVariant _toRow({
    required String id,
    required int createdAtMs,
    required int updatedAtMs,
    required String? ownerId,
    required String name,
    required String? brand,
    required String? barcode,
    required FoodSource source,
    required String? sourceRef,
    required Decimal? densityGPerMl,
    required Decimal? gramsPerPiece,
    required Decimal? servingSizeG,
    required NutrientSet nutrients,
  }) {
    return db.FoodVariant(
      id: id,
      createdAt: createdAtMs,
      updatedAt: updatedAtMs,
      name: name,
      brand: brand,
      barcode: barcode,
      source: source.code,
      sourceRef: sourceRef,
      ownerId: ownerId,
      densityGPerMl: densityGPerMl,
      gramsPerPiece: gramsPerPiece,
      servingSizeG: servingSizeG,
      energyKcal: nutrients.energyKcal,
      fatG: nutrients.fatG,
      saturatedFatG: nutrients.saturatedFatG,
      carbsG: nutrients.carbsG,
      sugarsG: nutrients.sugarsG,
      fiberG: nutrients.fiberG,
      proteinG: nutrients.proteinG,
      saltG: nutrients.saltG,
      extraJson: jsonEncode({
        for (final entry in nutrients.extra.entries) entry.key: entry.value.toString(),
      }),
    );
  }
}
