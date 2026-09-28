import '../food/food_variant.dart';
import 'input_models.dart';

/// Kapitel 16.2. Öffentlicher Vertrag, über die Tür exportiert. Ab Abnahme
/// von Schritt 6.1 eingefroren (Kapitel 25.1) — Implementierung folgt in
/// Schritt 6.4 (`DriftFoodRepository`).
abstract class FoodRepository {
  /// Aktive Varianten, sortiert nach `name`, bei Gleichstand nach `id`.
  Stream<List<FoodVariant>> watchAll();

  /// Teilstringsuche in `name`/`brand`. Leerer Query liefert alle aktiven
  /// Varianten.
  Stream<List<FoodVariant>> search(String query);

  /// `null` bei gelöscht/unbekannt.
  Future<FoodVariant?> getById(String id);

  /// `null`, wenn kein Treffer.
  Future<FoodVariant?> findByBarcode(String code);

  /// Wirft `ValidationException` (Validator-Fehler, Kapitel 8.6).
  Future<String> createVariant(NewFoodVariant variant);

  /// Ändert nie vorhandene `snapshotJson`-Kopien in bestehenden Snapshots
  /// (Kapitel 10.7). Wirft `NotFoundException`, `ValidationException`.
  Future<void> updateVariant(FoodVariant variant);

  /// Kapitel 10.7.
  Future<void> softDeleteVariant(String id);
}