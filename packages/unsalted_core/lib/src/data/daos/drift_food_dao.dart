import 'package:drift/drift.dart';

import '../core_database.dart';
import '../tables/food_variants.dart';
import 'food_dao.dart';

part 'drift_food_dao.g.dart';

/// Implementierung von [FoodDao]. Anders als [DriftRecipeDao] arbeiten
/// insert/update hier direkt mit dem vollen [FoodVariantRow] statt einem
/// Companion — das entspricht wörtlich der Signatur aus Kapitel 16.8.
/// Drifts generierte Zeilenklassen implementieren `Insertable<T>` selbst,
/// `into(table).insert(row)` funktioniert daher direkt mit [FoodVariantRow].
@DriftAccessor(tables: [FoodVariants])
class DriftFoodDao extends DatabaseAccessor<CoreDatabase>
    with _$DriftFoodDaoMixin
    implements FoodDao {
  DriftFoodDao(super.db);

  @override
  Stream<List<FoodVariantRow>> watchAll() {
    final q = select(foodVariants)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.name),
        (t) => OrderingTerm(expression: t.id),
      ]);
    return q.watch();
  }

  @override
  Stream<List<FoodVariantRow>> search(String query) {
    final pattern = '%$query%';
    final q = select(foodVariants)
      ..where(
        (t) =>
            t.deletedAt.isNull() &
            (t.name.like(pattern) | t.brand.like(pattern)),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return q.watch();
  }

  @override
  Future<FoodVariantRow?> getById(String id) {
    final q = select(foodVariants)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  @override
  Future<FoodVariantRow?> findByBarcode(String barcode) {
    final q = select(foodVariants)
      ..where((t) => t.barcode.equals(barcode) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  @override
  Future<void> insertVariant(FoodVariantRow row) =>
      into(foodVariants).insert(row);

  @override
  Future<void> updateVariant(FoodVariantRow row, int nowMs) {
    final updated = row.copyWith(updatedAt: nowMs);
    return update(foodVariants).replace(updated);
  }

  @override
  Future<void> softDeleteVariant(String id, int deletedAt) {
    return (update(foodVariants)..where((t) => t.id.equals(id))).write(
      FoodVariantsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }
}