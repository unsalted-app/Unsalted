import 'package:drift/drift.dart';

import '../../recipe/recipe_ingredient.dart';
import '../core_database.dart' as db;

/// Drift-generierte Zeile `db.RecipeIngredient` -> Fachmodell
/// `RecipeIngredient` (Kapitel 10.5). createdAt/updatedAt/deletedAt werden
/// bewusst nicht übernommen.
RecipeIngredient recipeIngredientFromRow(db.RecipeIngredient row) {
  return RecipeIngredient(
    id: row.id,
    versionId: row.versionId,
    position: row.position,
    foodVariantId: row.foodVariantId,
    displayName: row.displayName,
    quantity: row.quantity,
    unitCode: row.unitCode,
    note: row.note,
  );
}

/// Fachmodell -> Companion für INSERT. Wird von saveDraft/createDraftFrom
/// (Schritt 6.3) je Zutat aufgerufen, nachdem der bisherige Zeilenbestand
/// der Version hart gelöscht wurde (Kapitel 10.7).
db.RecipeIngredientsCompanion recipeIngredientToInsertCompanion(
  RecipeIngredient ingredient, {
  required int createdAtMs,
  required int updatedAtMs,
}) {
  return db.RecipeIngredientsCompanion.insert(
    id: ingredient.id,
    createdAt: createdAtMs,
    updatedAt: updatedAtMs,
    versionId: ingredient.versionId,
    position: ingredient.position,
    foodVariantId: Value(ingredient.foodVariantId),
    displayName: ingredient.displayName,
    quantity: ingredient.quantity,
    unitCode: ingredient.unitCode,
    note: Value(ingredient.note),
  );
}