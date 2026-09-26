// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_dao.dart';

// ignore_for_file: type=lint
mixin _$RecipeDaoMixin on DatabaseAccessor<CoreDatabase> {
  $RecipesTable get recipes => attachedDatabase.recipes;
  $RecipeVersionsTable get recipeVersions => attachedDatabase.recipeVersions;
  $RecipeIngredientsTable get recipeIngredients =>
      attachedDatabase.recipeIngredients;
  $RecipeStepsTable get recipeSteps => attachedDatabase.recipeSteps;
  RecipeDaoManager get managers => RecipeDaoManager(this);
}

class RecipeDaoManager {
  final _$RecipeDaoMixin _db;
  RecipeDaoManager(this._db);
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
