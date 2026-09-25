import 'package:drift/drift.dart';

/// Kapitel 11.5. Gleiche deleted_at-Begründung wie recipe_ingredients
/// (Kapitel 10.7): kein eigener Schreibpfad in Teil 1.
@TableIndex(name: 'idx_recipe_steps_version_id', columns: {#versionId})
@TableIndex(
  name: 'idx_recipe_steps_version_id_position',
  columns: {#versionId, #position},
)
class RecipeSteps extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  TextColumn get versionId => text()();

  /// 1-basiert, lückenlos innerhalb einer Version.
  IntColumn get position => integer()();

  TextColumn get instruction => text()();

  IntColumn get timerSeconds => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}