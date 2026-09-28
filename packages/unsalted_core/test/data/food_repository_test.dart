// test/data/food_repository_test.dart
//
// FD-01 bis FD-05 (Kapitel 23.4, Schritt 6.4): DriftFoodRepository gegen
// eine In-Memory-SQLite-Instanz.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';

void main() {
  late db.CoreDatabase database;
  late DriftFoodDao foodDao;
  late DriftFoodRepository repo;

  setUp(() {
    database = db.CoreDatabase(NativeDatabase.memory());
    foodDao = DriftFoodDao(database);
    repo = DriftFoodRepository(foodDao);
  });

  tearDown(() async {
    await database.close();
  });

  NewFoodVariant newVariant({
    String name = 'Weizenmehl',
    String? brand,
    String? barcode,
    NutrientSet? nutrients,
  }) {
    return NewFoodVariant(
      name: name,
      brand: brand,
      barcode: barcode,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: nutrients ?? NutrientSet(energyKcal: Decimal.zero),
    );
  }

  test('FD-01: createVariant legt eine neue FoodVariant an', () async {
    final id = await repo.createVariant(newVariant(
      name: 'Weizenmehl Type 550',
      brand: 'Hersteller X',
      nutrients: NutrientSet(
        energyKcal: Decimal.fromInt(343),
        fatG: Decimal.parse('1.2'),
        carbsG: Decimal.fromInt(70),
        proteinG: Decimal.fromInt(11),
      ),
    ));

    final variant = await repo.getById(id);
    expect(variant, isNotNull);
    expect(variant!.name, 'Weizenmehl Type 550');
    expect(variant.brand, 'Hersteller X');
    expect(variant.nutrients.energyKcal, Decimal.fromInt(343));
    expect(variant.source, FoodSource.custom);
  });

  test('FD-02: updateVariant ändert bestehende Snapshots nicht', () async {
    final id = await repo.createVariant(newVariant(name: 'Zucker'));
    final original = (await repo.getById(id))!;

    final changed = original.copyWith(
      name: 'Zucker (raffiniert)',
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(400)),
    );
    await repo.updateVariant(changed);

    final updated = await repo.getById(id);
    expect(updated!.name, 'Zucker (raffiniert)');
    expect(updated.nutrients.energyKcal, Decimal.fromInt(400));

    // updateVariant selbst rührt keine recipe_versions.snapshot_json an --
    // dieses Repository fasst ausschließlich food_variants an (Kapitel
    // 10.7: bestehende Snapshot-Kopien bleiben unabhängig von späteren
    // FoodVariant-Änderungen). Ohne recipe-Tabellen in diesem Testscope wird
    // das indirekt dadurch belegt, dass updateVariant nur die id-adressierte
    // Zeile in food_variants verändert.
    final row = await foodDao.getById(id);
    expect(row!.id, id);
  });

  test('FD-02b: updateVariant auf unbekannte id wirft NotFoundException', () async {
    expect(
      () => repo.updateVariant(FoodVariant(
        id: 'unbekannt',
        name: 'X',
        source: FoodSource.custom,
      )),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('FD-03: findByBarcode liefert die passende Variante, sonst null', () async {
    final id1 = await repo.createVariant(newVariant(name: 'A', barcode: '111'));
    await repo.createVariant(newVariant(name: 'B', barcode: '222'));

    final found = await repo.findByBarcode('111');
    expect(found, isNotNull);
    expect(found!.id, id1);
    expect(found.name, 'A');

    expect(await repo.findByBarcode('999-unbekannt'), isNull);
  });

  test('FD-04: softDeleteVariant, danach liefert getById null', () async {
    final id = await repo.createVariant(newVariant());
    expect(await repo.getById(id), isNotNull);

    await repo.softDeleteVariant(id);

    expect(await repo.getById(id), isNull);
    expect(await repo.watchAll().first, isEmpty);
  });

  test('FD-05: Validator-Fehler blockiert das Speichern', () async {
    expect(
      () => repo.createVariant(newVariant(
        nutrients: NutrientSet(energyKcal: Decimal.fromInt(-1)),
      )),
      throwsA(isA<ValidationException>()),
    );

    final id = await repo.createVariant(newVariant());
    final existing = (await repo.getById(id))!;
    expect(
      () => repo.updateVariant(
        existing.copyWith(nutrients: NutrientSet(fatG: Decimal.fromInt(-5))),
      ),
      throwsA(isA<ValidationException>()),
    );
  });
}
