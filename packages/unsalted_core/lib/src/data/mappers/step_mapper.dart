import 'package:drift/drift.dart';

import '../../recipe/recipe_step.dart';
import '../core_database.dart' as db;

/// Drift-generierte Zeile `db.RecipeStep` -> Fachmodell `RecipeStep`
/// (Kapitel 10.5). createdAt/updatedAt/deletedAt werden bewusst nicht
/// übernommen.
RecipeStep recipeStepFromRow(db.RecipeStep row) {
  return RecipeStep(
    id: row.id,
    versionId: row.versionId,
    position: row.position,
    instruction: row.instruction,
    timerSeconds: row.timerSeconds,
  );
}

/// Fachmodell -> Companion für INSERT. Gleiches Muster wie bei
/// recipe_ingredients: saveDraft/createDraftFrom ersetzen den kompletten
/// Zeilenbestand einer Draft-Version (Kapitel 10.7).
db.RecipeStepsCompanion recipeStepToInsertCompanion(
  RecipeStep step, {
  required int createdAtMs,
  required int updatedAtMs,
}) {
  return db.RecipeStepsCompanion.insert(
    id: step.id,
    createdAt: createdAtMs,
    updatedAt: updatedAtMs,
    versionId: step.versionId,
    position: step.position,
    instruction: step.instruction,
    timerSeconds: Value(step.timerSeconds),
  );
}