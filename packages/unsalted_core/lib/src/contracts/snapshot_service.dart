import '../recipe/recipe_snapshot_v1.dart';

/// Kapitel 16.4. Öffentlicher Vertrag, über die Tür exportiert. Verhalten
/// wie in Kapitel 13.6/13.7 festgelegt. Implementierung folgt in Schritt
/// 6.6 (`DriftSnapshotService`).
abstract class SnapshotService {
  Future<RecipeSnapshotV1> exportVersion(String versionId);
  Future<String> exportVersionAsJsonString(String versionId);
  Future<String> importSnapshot(RecipeSnapshotV1 s);
  Future<String> importJsonString(String json);
}