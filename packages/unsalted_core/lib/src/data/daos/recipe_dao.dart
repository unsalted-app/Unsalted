import '../core_database.dart';

/// Interner Vertrag innerhalb von unsalted_core (Kapitel 16.8) — keine
/// externe Public API, nicht über die Tür exportiert. Liefert und erwartet
/// ausschließlich Persistenztypen (RecipeRow, RecipeVersionRow, ... sowie
/// die zugehörigen Drift-Companion-Typen), niemals Fachmodelle.
abstract class RecipeDao {
  Stream<List<RecipeRow>> watchRecipes();
  Stream<RecipeRow?> watchRecipe(String recipeId);
  Stream<List<RecipeVersionRow>> watchVersions(String recipeId);

  Future<RecipeRow?> getRecipe(String recipeId);
  Future<RecipeVersionRow?> getVersion(String versionId);
  Future<List<RecipeIngredientRow>> getIngredientsForVersion(
    String versionId,
  );
  Future<List<RecipeStepRow>> getStepsForVersion(String versionId);

  Future<void> insertRecipe(
    RecipesCompanion recipe,
    RecipeVersionsCompanion version,
  );
  Future<void> updateRecipe(
    String recipeId,
    RecipesCompanion changes,
    int updatedAt,
  );
  Future<void> insertVersion(RecipeVersionsCompanion version);
  Future<void> updateVersion(RecipeVersionsCompanion changes);
  Future<void> updateVersionSnapshotState(
    String versionId,
    String state,
    String? snapshotJson,
    int? snapshotFormatVersion,
    int? snapshottedAt,
    int updatedAt,
  );
  Future<void> setMasterVersionId(
    String recipeId,
    String versionId,
    int updatedAt,
  );
  Future<void> softDeleteVersion(
    String versionId,
    int deletedAt,
    int updatedAt,
  );

  /// Setzt das Upsert-/Soft-Delete-Delta aus Kapitel 10.7 um: eine aktive
  /// Zeile mit derselben id wie in [items] wird aktualisiert, eine neue id
  /// eingefügt, eine zuvor aktive Zeile ohne Entsprechung in [items] wird
  /// per deleted_at = [nowMs] weich gelöscht. Reaktiviert niemals eine
  /// bereits gelöschte Zeile.
  Future<void> saveDraftIngredients(
    String versionId,
    List<RecipeIngredientsCompanion> items,
    int nowMs,
  );

  /// Gleiches Delta-Verhalten wie [saveDraftIngredients], für
  /// recipe_steps.
  Future<void> saveDraftSteps(
    String versionId,
    List<RecipeStepsCompanion> items,
    int nowMs,
  );
}