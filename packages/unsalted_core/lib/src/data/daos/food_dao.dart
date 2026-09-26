import 'package:drift/drift.dart';

import '../core_database.dart';
import '../tables/food_variants.dart';

part 'food_dao.g.dart';

@DriftAccessor(tables: [FoodVariants])
class FoodDao extends DatabaseAccessor<CoreDatabase> with _$FoodDaoMixin {
  FoodDao(super.db);

  Stream<List<FoodVariant>> watchActiveVariants() {
    final q = select(foodVariants)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.name),
        (t) => OrderingTerm(expression: t.id),
      ]);
    return q.watch();
  }

  /// Teilstringsuche in name/brand (Kapitel 16.2). Leerer Suchtext liefert
  /// alle aktiven Varianten, weil `LIKE '%%'` jede Zeile trifft.
  Stream<List<FoodVariant>> searchVariants(String searchText) {
    final pattern = '%$searchText%';
    final q = select(foodVariants)
      ..where(
        (t) =>
            t.deletedAt.isNull() &
            (t.name.like(pattern) | t.brand.like(pattern)),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return q.watch();
  }

  Future<FoodVariant?> getVariantById(String id) {
    final q = select(foodVariants)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  Future<FoodVariant?> getVariantByBarcode(String barcode) {
    final q = select(foodVariants)
      ..where((t) => t.barcode.equals(barcode) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  Future<void> insertVariant(FoodVariantsCompanion companion) =>
      into(foodVariants).insert(companion);

  Future<void> updateVariantFields(
    String id,
    FoodVariantsCompanion companion,
  ) =>
      (update(foodVariants)..where((t) => t.id.equals(id))).write(companion);

  Future<void> softDeleteVariant(String id, int deletedAtMs) =>
      (update(foodVariants)..where((t) => t.id.equals(id))).write(
        FoodVariantsCompanion(
          deletedAt: Value(deletedAtMs),
          updatedAt: Value(deletedAtMs),
        ),
      );
}