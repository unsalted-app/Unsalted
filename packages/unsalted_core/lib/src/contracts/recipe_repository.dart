import '../recipe/recipe.dart';
import '../recipe/recipe_change.dart';
import '../recipe/recipe_version.dart';
import 'input_models.dart';

/// Kapitel 16.1. Öffentlicher Vertrag, über die Tür exportiert. Ab Abnahme
/// von Schritt 6.1 eingefroren (Kapitel 25.1) — Implementierung folgt in
/// Schritt 6.3 (`DriftRecipeRepository`).
abstract class RecipeRepository {
  /// Aktive Rezepte, sortiert nach `title`, bei Gleichstand nach `id`.
  Stream<List<Recipe>> watchRecipes();

  /// `null`, wenn gelöscht oder unbekannt.
  Stream<Recipe?> watchRecipe(String id);

  /// Aktive Versionen, sortiert absteigend nach `versionIndex`.
  Stream<List<RecipeVersion>> watchVersions(String recipeId);

  /// Inklusive Zutaten und Schritte.
  Future<RecipeVersion?> getVersion(String versionId);

  /// Legt Rezept + ersten Draft (`versionIndex = 1`) an. Wirft
  /// `ValidationException` bei leerem/zu langem Titel.
  Future<String> createRecipe(NewRecipe recipe);

  /// Ändert nur die in [command] angegebenen Felder (Kapitel 16.0.2).
  /// Wirft `NotFoundException`.
  Future<void> updateRecipe(String id, UpdateRecipeCommand command);

  /// Ersetzt den Zeilenbestand per Upsert-/Soft-Delete-Delta (Kapitel
  /// 10.7). Wirft `SnapshotImmutableException` auf einer Snapshot-Version,
  /// `ValidationException` bei ungültigen Werten.
  Future<void> saveDraft(RecipeVersionDraft draft);

  /// Kapitel 12.3. Wirft `IllegalStateException` (nicht `state = draft`),
  /// `ValidationException` (keine Zutaten).
  Future<void> snapshotVersion(String versionId);

  /// Kapitel 12.4. Wirft `NotFoundException`.
  Future<String> createDraftFrom(String versionId);

  /// Kapitel 14.4. Wirft `ValidationException`, `UnknownChangeException`,
  /// `NotFoundException`.
  Future<String> applyChangesAsNewDraft(
    String baseVersionId,
    List<RecipeChange> changes,
  );

  /// Nur Versionen mit `state = snapshot` zulässig. Wirft
  /// `IllegalStateException`.
  Future<void> setMasterVersion(String recipeId, String versionId);

  /// Kapitel 12.5. Wirft `IllegalStateException` (letzte verbleibende
  /// Version oder Master-Version).
  Future<void> deleteVersion(String versionId);

  /// Kapitel 12.5.
  Future<void> softDeleteRecipe(String recipeId);

  /// Setzt `owner_id` auf allen Zeilen, bei denen er `null` ist. Liegt in
  /// Teil 1, obwohl er erst von Teil 3 aufgerufen wird (Kapitel 16.1,
  /// letzter Absatz).
  Future<void> assignOwner(String ownerId);
}