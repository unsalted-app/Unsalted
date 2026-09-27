import 'package:drift/drift.dart';

import '../core_database.dart';
import '../tables/recipes.dart';
import '../tables/recipe_versions.dart';
import '../tables/recipe_ingredients.dart';
import '../tables/recipe_steps.dart';
import 'recipe_dao.dart';

part 'drift_recipe_dao.g.dart';

/// Implementierung von [RecipeDao]. Eröffnet keine eigene Transaction
/// Boundary (Kapitel 16.0.7) — jede Methode geht davon aus, dass sie
/// innerhalb der vom Repository (Schritt 6.3) bereits geöffneten
/// Transaktion läuft, wo eine Transaktion laut Kapitel 16.1 vorgeschrieben
/// ist.
@DriftAccessor(
  tables: [Recipes, RecipeVersions, RecipeIngredients, RecipeSteps],
)
class DriftRecipeDao extends DatabaseAccessor<CoreDatabase>
    with _$DriftRecipeDaoMixin
    implements RecipeDao {
  DriftRecipeDao(super.db);

  // ---------------------------------------------------------------------
  // recipes
  // ---------------------------------------------------------------------

  @override
  Stream<List<RecipeRow>> watchRecipes() {
    final q = select(recipes)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.title),
        (t) => OrderingTerm(expression: t.id),
      ]);
    return q.watch();
  }

  @override
  Stream<RecipeRow?> watchRecipe(String recipeId) {
    final q = select(recipes)
      ..where((t) => t.id.equals(recipeId) & t.deletedAt.isNull());
    return q.watchSingleOrNull();
  }

  @override
  Future<RecipeRow?> getRecipe(String recipeId) {
    final q = select(recipes)
      ..where((t) => t.id.equals(recipeId) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  @override
  Future<void> insertRecipe(
    RecipesCompanion recipe,
    RecipeVersionsCompanion version,
  ) async {
    await into(recipes).insert(recipe);
    await into(recipeVersions).insert(version);
  }

  @override
  Future<void> updateRecipe(
    String recipeId,
    RecipesCompanion changes,
    int updatedAt,
  ) {
    final withTimestamp = changes.copyWith(updatedAt: Value(updatedAt));
    return (update(
      recipes,
    )..where((t) => t.id.equals(recipeId))).write(withTimestamp);
  }

  // ---------------------------------------------------------------------
  // recipe_versions
  // ---------------------------------------------------------------------

  @override
  Stream<List<RecipeVersionRow>> watchVersions(String recipeId) {
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

  @override
  Future<RecipeVersionRow?> getVersion(String versionId) {
    final q = select(recipeVersions)
      ..where((t) => t.id.equals(versionId) & t.deletedAt.isNull());
    return q.getSingleOrNull();
  }

  @override
  Future<void> insertVersion(RecipeVersionsCompanion version) =>
      into(recipeVersions).insert(version);

  /// Adressiert die zu aktualisierende Zeile über `changes.id` — der
  /// Aufrufer (Repository) muss `id` im Companion setzen. Diese
  /// Entscheidung ist nicht wörtlich in Kapitel 16.8 spezifiziert (die
  /// Signatur trägt keinen separaten id-Parameter, anders als
  /// `updateRecipe`); sie ist die einzige Lesart, die ohne zusätzlichen
  /// Parameter konsistent funktioniert.
  @override
  Future<void> updateVersion(RecipeVersionsCompanion changes) {
    final id = changes.id.value;
    return (update(
      recipeVersions,
    )..where((t) => t.id.equals(id))).write(changes);
  }

  @override
  Future<void> updateVersionSnapshotState(
    String versionId,
    String state,
    String? snapshotJson,
    int? snapshotFormatVersion,
    int? snapshottedAt,
    int updatedAt,
  ) {
    return (update(recipeVersions)..where((t) => t.id.equals(versionId)))
        .write(
      RecipeVersionsCompanion(
        state: Value(state),
        snapshotJson: Value(snapshotJson),
        snapshotFormatVersion: Value(snapshotFormatVersion),
        snapshottedAt: Value(snapshottedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  @override
  Future<void> setMasterVersionId(
    String recipeId,
    String versionId,
    int updatedAt,
  ) {
    return (update(recipes)..where((t) => t.id.equals(recipeId))).write(
      RecipesCompanion(
        masterVersionId: Value(versionId),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  @override
  Future<void> softDeleteVersion(
    String versionId,
    int deletedAt,
    int updatedAt,
  ) {
    return (update(recipeVersions)..where((t) => t.id.equals(versionId)))
        .write(
      RecipeVersionsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // recipe_ingredients / recipe_steps
  // ---------------------------------------------------------------------

  @override
  Future<List<RecipeIngredientRow>> getIngredientsForVersion(
    String versionId,
  ) {
    final q = select(recipeIngredients)
      ..where((t) => t.versionId.equals(versionId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.position)]);
    return q.get();
  }

  @override
  Future<List<RecipeStepRow>> getStepsForVersion(String versionId) {
    final q = select(recipeSteps)
      ..where((t) => t.versionId.equals(versionId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.position)]);
    return q.get();
  }

  /// Upsert-/Soft-Delete-Delta (Kapitel 10.7): aktive Zeile mit gleicher id
  /// -> Update; id nicht unter den bisherigen aktiven Zeilen -> Insert;
  /// bisher aktive Zeile ohne Entsprechung in [items] -> deleted_at =
  /// [nowMs]. Ein [items]-Eintrag, dessen id zu einer bereits weich
  /// gelöschten Zeile gehört, wird nicht reaktiviert: das Update trifft
  /// wegen des deleted_at IS NULL-Filters keine Zeile, der anschließende
  /// Versuch, sie stattdessen einzufügen, scheitert an der doppelt
  /// vergebenen id (Primärschlüssel-Konflikt) — die ungültige Eingabe wird
  /// so auf Datenbankebene abgewiesen, statt sie stillschweigend zu
  /// akzeptieren.
  @override
  Future<void> saveDraftIngredients(
    String versionId,
    List<RecipeIngredientsCompanion> items,
    int nowMs,
  ) async {
    final activeIds = await (select(
      recipeIngredients,
    )..where((t) => t.versionId.equals(versionId) & t.deletedAt.isNull()))
        .map((row) => row.id)
        .get();
    final activeIdSet = activeIds.toSet();

    final incomingIds = items.map((c) => c.id.value).toSet();
    final toSoftDelete = activeIdSet.difference(incomingIds).toList();

    await batch((b) {
      if (toSoftDelete.isNotEmpty) {
        b.update(
          recipeIngredients,
          RecipeIngredientsCompanion(
            deletedAt: Value(nowMs),
            updatedAt: Value(nowMs),
          ),
          where: (t) => t.id.isIn(toSoftDelete),
        );
      }
      for (final item in items) {
        final id = item.id.value;
        if (activeIdSet.contains(id)) {
          b.update(recipeIngredients, item, where: (t) => t.id.equals(id));
        } else {
          b.insert(recipeIngredients, item);
        }
      }
    });
  }

  /// Gleiches Muster wie [saveDraftIngredients], für recipe_steps.
  @override
  Future<void> saveDraftSteps(
    String versionId,
    List<RecipeStepsCompanion> items,
    int nowMs,
  ) async {
    final activeIds = await (select(
      recipeSteps,
    )..where((t) => t.versionId.equals(versionId) & t.deletedAt.isNull()))
        .map((row) => row.id)
        .get();
    final activeIdSet = activeIds.toSet();

    final incomingIds = items.map((c) => c.id.value).toSet();
    final toSoftDelete = activeIdSet.difference(incomingIds).toList();

    await batch((b) {
      if (toSoftDelete.isNotEmpty) {
        b.update(
          recipeSteps,
          RecipeStepsCompanion(
            deletedAt: Value(nowMs),
            updatedAt: Value(nowMs),
          ),
          where: (t) => t.id.isIn(toSoftDelete),
        );
      }
      for (final item in items) {
        final id = item.id.value;
        if (activeIdSet.contains(id)) {
          b.update(recipeSteps, item, where: (t) => t.id.equals(id));
        } else {
          b.insert(recipeSteps, item);
        }
      }
    });
  }
}