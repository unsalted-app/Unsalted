// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_recipe_dao.dart';

// ignore_for_file: type=lint
mixin _$DriftRecipeDaoMixin on DatabaseAccessor<CoreDatabase> {
  $RecipesTable get recipes => attachedDatabase.recipes;
  $RecipeVersionsTable get recipeVersions => attachedDatabase.recipeVersions;
  $RecipeIngredientsTable get recipeIngredients =>
      attachedDatabase.recipeIngredients;
  $RecipeStepsTable get recipeSteps => attachedDatabase.recipeSteps;
  DriftRecipeDaoManager get managers => DriftRecipeDaoManager(this);
}

class DriftRecipeDaoManager {
  final _$DriftRecipeDaoMixin _db;
  DriftRecipeDaoManager(this._db);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db.attachedDatabase, _db.recipes);
  $$RecipeVersionsTableTableManager get recipeVersions =>
      $$RecipeVersionsTableTableManager(
        _db.attachedDatabase,
        _db.recipeVersions,
      );
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(
        _db.attachedDatabase,
        _db.recipeIngredients,
      );
  $$RecipeStepsTableTableManager get recipeSteps =>
      $$RecipeStepsTableTableManager(_db.attachedDatabase, _db.recipeSteps);
}
