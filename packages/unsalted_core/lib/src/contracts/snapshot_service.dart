import '../recipe/recipe_snapshot_v1.dart';

/// Kapitel 16.4. Öffentlicher Vertrag, über die Tür exportiert. Verhalten
/// wie in Kapitel 13.6/13.7 festgelegt. Implementierung folgt in Schritt
/// 6.6 (`DriftSnapshotService`).
abstract class SnapshotService {
  /// Liefert den gespeicherten Snapshot einer eingefrorenen Version unverändert
  /// (Kapitel 13.7). Wirft `NotFoundException` bei unbekannter Version und
  /// `IllegalStateException` bei einem Draft.
  Future<RecipeSnapshotV1> exportVersion(String versionId);
  /// Liefert den gespeicherten JSON-String einer eingefrorenen Version
  /// unverändert (Kapitel 13.7); Fehler wie [exportVersion].
  Future<String> exportVersionAsJsonString(String versionId);
  /// Legt aus [s] ein neues Rezept mit einer eingefrorenen Version an und gibt
  /// die neue Rezept-ID zurück (Kapitel 13.6). Gespeichert wird die kanonische
  /// Kodierung.
  Future<String> importSnapshot(RecipeSnapshotV1 s);
  /// Prüft einen Snapshot-JSON-String (Kapitel 13.5), legt daraus ein neues
  /// Rezept an und gibt die neue Rezept-ID zurück (Kapitel 13.6). Der
  /// Originaltext wird unverändert gespeichert. Wirft `ImportFormatException`
  /// oder `ImportVersionException`, bevor etwas geschrieben wird.
  Future<String> importJsonString(String json);
}