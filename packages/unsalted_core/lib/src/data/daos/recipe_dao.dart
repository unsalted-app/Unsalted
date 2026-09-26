import 'package:drift/drift.dart';

import '../core_database.dart';
import '../tables/recipes.dart';
import '../tables/recipe_versions.dart';
import '../tables/recipe_ingredients.dart';
import '../tables/recipe_steps.dart';

part 'recipe_dao.g.dart';

/// Liefert ausschließlich Drift-Zeilentypen (Recipe, RecipeVersion,
/// RecipeIngredient, RecipeStep — die von Drift generierten Klassen,
/// nicht die Fachmodelle aus lib/src/recipe/). Kapitel 18.1: "DAOs liefern
/// ausschließlich Drift-Zeilentypen (keine Fachmodelle)".
///
/// Jede lesende Methode filtert implizit deleted_at IS NULL (Kapitel 10.7,
/// letzter Punkt) — außer den beiden reinen recipe_ingredients/
/// recipe_steps-Methoden, weil diese Tabellen laut Kapitel 10.7 in Teil 1
/// keinen eigenen deleted_at-Schreibpfad haben und ausschließlich über die
/// (bereits gefilterte) version_id erreicht werden.
@DriftAccessor(
  tables: [Recipes, RecipeVersions, RecipeIngredients, RecipeSteps],
)
class RecipeDao extends DatabaseAccessor<CoreDatabase>
    with _$RecipeDaoMixin {
  RecipeDao(super.db);

  // ---------------------------------------------------------------------
  // recipes
  // ---------------------------------------------------------------------

  Stream<List<Recipe>> watchActiveRecipes() {
    final q = select(recipes)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.title),
        (t) => OrderingTerm(expression: t.id),
      ]);
    return q.watch();
  }

  Stream<Recipe?> watchRecipeById(String id) {
    final q = select(recipes)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.watchSingleOrNull();
  }

  Future<Recipe?> getRecipeById(String id) {
    final q = select(recipes)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  Future<void> insertRecipe(RecipesCompanion companion) =>
      into(recipes).insert(companion);

  Future<void> updateRecipeFields(String id, RecipesCompanion companion) =>
      (update(recipes)..where((t) => t.id.equals(id))).write(companion);

  Future<void> softDeleteRecipe(String id, int deletedAtMs) =>
      (update(recipes)..where((t) => t.id.equals(id))).write(
        RecipesCompanion(
          deletedAt: Value(deletedAtMs),
          updatedAt: Value(deletedAtMs),
        ),
      );

  // ---------------------------------------------------------------------
  // recipe_versions
  // ---------------------------------------------------------------------

  Stream<List<RecipeVersion>> watchVersionsForRecipe(String recipeId) {
    final q = select(recipeVersions)
      ..where((t) => t.recipeId.equals(recipeId) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(
              expression: t.versionIndex,
              mode: OrderingMode.desc,
            ),
      ]);
    return q.watch();
  }

  Future<RecipeVersion?> getVersionById(String id) {
    final q = select(recipeVersions)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  /// Höchster bisheriger version_index des Rezepts + 1 (Kapitel 10.4/12.4).
  /// Berücksichtigt auch gelöschte Versionen, damit ein einmal vergebener
  /// Index nie erneut auftaucht.
  Future<int> nextVersionIndex(String recipeId) async {
    final maxExpr = recipeVersions.versionIndex.max();
    final q = selectOnly(recipeVersions)
      ..addColumns([maxExpr])
      ..where(recipeVersions.recipeId.equals(recipeId));
    final row = await q.getSingleOrNull();
    final currentMax = row?.read(maxExpr);
    return (currentMax ?? 0) + 1;
  }

  Future<void> insertVersion(RecipeVersionsCompanion companion) =>
      into(recipeVersions).insert(companion);

  Future<void> updateVersionFields(
    String id,
    RecipeVersionsCompanion companion,
  ) =>
      (update(recipeVersions)..where((t) => t.id.equals(id))).write(
        companion,
      );

  Future<void> softDeleteVersion(String id, int deletedAtMs) =>
      (update(recipeVersions)..where((t) => t.id.equals(id))).write(
        RecipeVersionsCompanion(
          deletedAt: Value(deletedAtMs),
          updatedAt: Value(deletedAtMs),
        ),
      );

  /// Kaskadierendes Löschen aller aktiven Versionen eines Rezepts
  /// (Kapitel 12.5, softDeleteRecipe).
  Future<void> softDeleteAllVersionsForRecipe(
    String recipeId,
    int deletedAtMs,
  ) =>
      (update(recipeVersions)
            ..where(
              (t) => t.recipeId.equals(recipeId) & t.deletedAt.isNull(),
            ))
          .write(
        RecipeVersionsCompanion(
          deletedAt: Value(deletedAtMs),
          updatedAt: Value(deletedAtMs),
        ),
      );

  // ---------------------------------------------------------------------
  // recipe_ingredients
  // ---------------------------------------------------------------------

  Future<List<RecipeIngredient>> getIngredientsForVersion(String versionId) {
    final q = select(recipeIngredients)
      ..where((t) => t.versionId.equals(versionId))
      ..orderBy([(t) => OrderingTerm(expression: t.position)]);
    return q.get();
  }

  /// Hart-Löschen, kein Soft Delete (Kapitel 10.7: recipe_ingredients hat
  /// in Teil 1 keinen eigenen deleted_at-Schreibpfad). Wird von saveDraft
  /// (Schritt 6.3) innerhalb einer Transaktion vor insertIngredients
  /// aufgerufen, um den Zeilenbestand vollständig zu ersetzen.
  Future<void> deleteIngredientsForVersion(String versionId) =>
      (delete(
        recipeIngredients,
      )..where((t) => t.versionId.equals(versionId))).go();

  Future<void> insertIngredients(List<RecipeIngredientsCompanion> rows) =>
      batch((b) => b.insertAll(recipeIngredients, rows));

  // ---------------------------------------------------------------------
  // recipe_steps
  // ---------------------------------------------------------------------

  Future<List<RecipeStep>> getStepsForVersion(String versionId) {
    final q = select(recipeSteps)
      ..where((t) => t.versionId.equals(versionId))
      ..orderBy([(t) => OrderingTerm(expression: t.position)]);
    return q.get();
  }

  Future<void> deleteStepsForVersion(String versionId) =>
      (delete(recipeSteps)..where((t) => t.versionId.equals(versionId))).go();

  Future<void> insertSteps(List<RecipeStepsCompanion> rows) =>
      batch((b) => b.insertAll(recipeSteps, rows));
}