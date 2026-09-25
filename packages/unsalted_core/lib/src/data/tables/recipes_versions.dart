import 'package:drift/drift.dart';

import '../converters/decimal_converter.dart';

/// Kapitel 11.3. `state` ist als TEXT gespeichert ('draft' | 'snapshot'),
/// nicht als Drift-Enum — Fachmodell-seitig wird daraus VersionState
/// (Kapitel 10.4), das ist Aufgabe des Mappers (Schritt 5.5), nicht der
/// Tabelle selbst.
@TableIndex(name: 'idx_recipe_versions_recipe_id', columns: {#recipeId})
@TableIndex(
  name: 'idx_recipe_versions_recipe_id_version_index',
  columns: {#recipeId, #versionIndex},
)
@TableIndex(name: 'idx_recipe_versions_state', columns: {#state})
class RecipeVersions extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  TextColumn get recipeId => text()();

  /// Darf auf eine lokal unbekannte Version zeigen (Import/Fork, Kapitel 12.1).
  TextColumn get parentVersionId => text().nullable()();

  /// Fortlaufend pro Rezept ab 1, vom Repository vergeben (Kapitel 10.4).
  IntColumn get versionIndex => integer()();

  TextColumn get label => text().nullable()();

  /// 'draft' | 'snapshot' (Kapitel 10.8).
  TextColumn get state => text()();

  /// null oder >= 1 (Kapitel 8.5, 10.4).
  IntColumn get servings => integer().nullable()();

  /// 0..100, Standard 0.
  TextColumn get bakingLossPercent =>
      text().map(const DecimalConverter()).withDefault(const Constant('0'))();

  /// > 0 oder null; hat Vorrang vor bakingLossPercent (Kapitel 8.5).
  TextColumn get finalWeightOverrideG =>
      text().map(const DecimalConverter()).nullable()();

  TextColumn get notes => text().nullable()();

  /// Nur bei state = snapshot gesetzt (Kapitel 10.8). Enthält das
  /// vollständige Snapshot-JSON unverändert (Kapitel 13.6/13.7) — Zugriff
  /// ausschließlich über SnapshotService/SnapshotCodec, niemals als
  /// Rohstring im Fachmodell (Kapitel 10.4).
  TextColumn get snapshotJson => text().nullable()();

  /// Nur bei state = snapshot gesetzt, aktuell 1.
  IntColumn get snapshotFormatVersion => integer().nullable()();

  /// Nur bei state = snapshot gesetzt.
  IntColumn get snapshottedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}