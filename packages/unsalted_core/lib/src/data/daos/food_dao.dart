import '../core_database.dart';

/// Interner Vertrag (Kapitel 16.8). DAO-Methoden liefern ausschließlich
/// Persistenztypen, niemals Fachmodelle.
abstract class FoodDao {
  Stream<List<FoodVariantRow>> watchAll();
  Stream<List<FoodVariantRow>> search(String query);
  Future<FoodVariantRow?> getById(String id);
  Future<FoodVariantRow?> findByBarcode(String barcode);
  Future<void> insertVariant(FoodVariantRow row);
  Future<void> updateVariant(FoodVariantRow row, int nowMs);
  Future<void> softDeleteVariant(String id, int deletedAt);
}