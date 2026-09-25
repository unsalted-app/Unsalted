import 'package:drift/drift.dart';

import '../converters/decimal_converter.dart';

/// Kapitel 11.4. `deleted_at` hat hier in Teil 1 keinen eigenen
/// Schreibpfad — saveDraft ersetzt den Zeilenbestand einer Draft-Version
/// transaktional per Hart-Löschen + Neu-Einfügen (Kapitel 10.7). Die
/// Spalte existiert trotzdem, weil Kapitel 11.1 sie für jede Tabelle
/// vorschreibt (AT-10-Einheitlichkeit).
@TableIndex(
  name: 'idx_recipe_ingredients_version_id',
  columns: {#versionId},
)
@TableIndex(
  name: 'idx_recipe_ingredients_version_id_position',
  columns: {#versionId, #position},
)
class RecipeIngredients extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  TextColumn get versionId => text()();

  /// 1-basiert, lückenlos innerhalb einer Version (Kapitel 10.10).
  IntColumn get position => integer()();

  /// null = freie Zutat ohne Nährwerte (Kapitel 8.5).
  TextColumn get foodVariantId => text().nullable()();

  TextColumn get displayName => text()();

  /// >= 0 (Kapitel 11.4). Negative Werte werden bereits vor der Persistenz
  /// durch RecipeChange.validate() bzw. die UI-Formularvalidierung
  /// abgelehnt (Kapitel 8.5).
  TextColumn get quantity => text().map(const DecimalConverter())();

  /// Code aus UnitCatalog (Kapitel 9).
  TextColumn get unitCode => text()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}