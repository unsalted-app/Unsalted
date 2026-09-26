import 'package:drift/drift.dart';

import '../../recipe/recipe.dart';
import '../core_database.dart' as db;

/// Drift-generierte Zeilenklasse `db.Recipe` -> Fachmodell `Recipe`
/// (Kapitel 10.3). createdAt/updatedAt/deletedAt/ownerId werden bewusst
/// nicht übernommen — sie sind laut Kapitel 10.2/10.3 kein Teil des
/// Fachmodells.
Recipe recipeFromRow(db.Recipe row) {
  return Recipe(
    id: row.id,
    title: row.title,
    description: row.description,
    masterVersionId: row.masterVersionId,
  );
}

/// Fachmodell -> Companion für INSERT. createdAt/updatedAt kommen von
/// außen (Kapitel 10.10: das Repository setzt sie, nicht das Fachmodell).
/// ownerId ist ebenfalls kein Fachmodellfeld (Kapitel 10.3) und wird
/// separat übergeben (Standard: null, bis Teil 3 assignOwner ruft).
db.RecipesCompanion recipeToInsertCompanion(
  Recipe recipe, {
  required int createdAtMs,
  required int updatedAtMs,
  String? ownerId,
}) {
  return db.RecipesCompanion.insert(
    id: recipe.id,
    createdAt: createdAtMs,
    updatedAt: updatedAtMs,
    title: recipe.title,
    description: Value(recipe.description),
    masterVersionId: Value(recipe.masterVersionId),
    ownerId: Value(ownerId),
  );
}

/// Fachmodell -> Companion für UPDATE (ohne id — die adressiert die
/// aufrufende DAO-Methode separat über WHERE).
db.RecipesCompanion recipeToUpdateCompanion(
  Recipe recipe, {
  required int updatedAtMs,
}) {
  return db.RecipesCompanion(
    updatedAt: Value(updatedAtMs),
    title: Value(recipe.title),
    description: Value(recipe.description),
    masterVersionId: Value(recipe.masterVersionId),
  );
}