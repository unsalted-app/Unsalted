import 'package:drift/drift.dart';

import '../../recipe/recipe_ingredient.dart';
import '../../recipe/recipe_step.dart';
import '../../recipe/recipe_version.dart';
import '../core_database.dart' as db;

/// Drift-generierte Zeile `db.RecipeVersion` -> Fachmodell `RecipeVersion`
/// (Kapitel 10.4). `snapshotJson`/`snapshotFormatVersion` werden bewusst
/// nicht übernommen (Kapitel 10.4: Zugriff ausschließlich über
/// SnapshotService, nie als Rohstring im Fachmodell). `snapshottedAt` ist
/// die einzige Zeitstempel-Ausnahme und wird übernommen.
///
/// `ingredients`/`steps` müssen separat abgefragt werden (eigene Tabellen)
/// und werden hier als Parameter übergeben — dieser Mapper kennt keine
/// Joins, das ist Aufgabe des aufrufenden Repositorys (Schritt 6.3).
RecipeVersion recipeVersionFromRow(
  db.RecipeVersion row, {
  List<RecipeIngredient> ingredients = const [],
  List<RecipeStep> steps = const [],
}) {
  return RecipeVersion(
    id: row.id,
    recipeId: row.recipeId,
    parentVersionId: row.parentVersionId,
    versionIndex: row.versionIndex,
    label: row.label,
    state: VersionState.fromCode(row.state),
    servings: row.servings,
    bakingLossPercent: row.bakingLossPercent,
    finalWeightOverrideG: row.finalWeightOverrideG,
    notes: row.notes,
    snapshottedAt: row.snapshottedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            row.snapshottedAt!,
            isUtc: true,
          ),
    ingredients: ingredients,
    steps: steps,
  );
}

/// Fachmodell -> Companion für INSERT einer neuen Draft-Version
/// (createRecipe, createDraftFrom — Kapitel 12.2). Snapshot-Felder bleiben
/// unbesetzt (Value.absent, DB-seitig null), weil eine neu erzeugte
/// Version laut Kapitel 10.8 stets mit state = draft beginnt — außer beim
/// Import (Kapitel 13.6), der direkt state = snapshot anlegt; dafür ist
/// [recipeVersionToSnapshotCompanion] unten zuständig, nicht diese Funktion.
db.RecipeVersionsCompanion recipeVersionToInsertCompanion(
  RecipeVersion version, {
  required int createdAtMs,
  required int updatedAtMs,
}) {
  return db.RecipeVersionsCompanion.insert(
    id: version.id,
    createdAt: createdAtMs,
    updatedAt: updatedAtMs,
    recipeId: version.recipeId,
    parentVersionId: Value(version.parentVersionId),
    versionIndex: version.versionIndex,
    label: Value(version.label),
    state: version.state.code,
    servings: Value(version.servings),
    bakingLossPercent: Value(version.bakingLossPercent),
    finalWeightOverrideG: Value(version.finalWeightOverrideG),
    notes: Value(version.notes),
  );
}

/// Fachmodell -> Companion für UPDATE einer Draft-Version (saveDraft,
/// Kapitel 16.1). Ändert niemals state, snapshot_json oder
/// snapshot_format_version — dafür sind snapshotVersion bzw. der
/// Snapshot-Sperre-Mechanismus zuständig (Kapitel 12.2/12.3), nicht diese
/// Funktion.
db.RecipeVersionsCompanion recipeVersionToUpdateCompanion(
  RecipeVersion version, {
  required int updatedAtMs,
}) {
  return db.RecipeVersionsCompanion(
    updatedAt: Value(updatedAtMs),
    label: Value(version.label),
    servings: Value(version.servings),
    bakingLossPercent: Value(version.bakingLossPercent),
    finalWeightOverrideG: Value(version.finalWeightOverrideG),
    notes: Value(version.notes),
  );
}

/// Companion für den Übergang Draft -> Snapshot (snapshotVersion, Kapitel
/// 12.3) bzw. den direkten Import als Snapshot (Kapitel 13.6, Schritt 3).
/// `snapshotJson` wird hier als fertig kodierter String übergeben — die
/// Kodierung selbst übernimmt SnapshotCodec (Schritt 4.2), nicht dieser
/// Mapper.
db.RecipeVersionsCompanion recipeVersionToSnapshotCompanion({
  required int updatedAtMs,
  required String snapshotJson,
  required int snapshotFormatVersion,
  required int snapshottedAtMs,
}) {
  return db.RecipeVersionsCompanion(
    updatedAt: Value(updatedAtMs),
    state: const Value('snapshot'),
    snapshotJson: Value(snapshotJson),
    snapshotFormatVersion: Value(snapshotFormatVersion),
    snapshottedAt: Value(snapshottedAtMs),
  );
}