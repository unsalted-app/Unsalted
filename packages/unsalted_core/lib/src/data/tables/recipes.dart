import 'package:drift/drift.dart';

/// Kapitel 11.2. Standardfelder aus 11.1: id, created_at, updated_at,
/// deleted_at. Kein Auto-Increment, keine Fremdschlüssel — Verweise sind
/// reine Text-UUID-Spalten (Kapitel 11.1).
@TableIndex(name: 'idx_recipes_title', columns: {#title})
@TableIndex(name: 'idx_recipes_owner_id', columns: {#ownerId})
class Recipes extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  /// Weicher Verweis; muss auf eine Version mit state = snapshot zeigen
  /// (fachlich erzwungen im Repository, nicht per Fremdschlüssel — R3).
  TextColumn get masterVersionId => text().nullable()();

  /// null bis Teil 3 assignOwner ruft (Kapitel 10.3, 16.1).
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}