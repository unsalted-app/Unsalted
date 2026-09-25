import 'package:drift/drift.dart';

import '../converters/decimal_converter.dart';

/// Kapitel 11.6. Es gibt bewusst keine eigenen Tabellen für
/// Lebensmittel-Konzepte oder -Quellen (Kapitel 11.6, letzter Absatz) —
/// `source`/`source_ref` sind Spalten dieser Tabelle. Die acht
/// Nährwertfelder liegen direkt an der Variante, alle einzeln nullable
/// (Kapitel 8.1): `null` = unbekannt, ungleich `0` = bekanntermaßen null.
@TableIndex(name: 'idx_food_variants_name', columns: {#name})
@TableIndex(name: 'idx_food_variants_barcode', columns: {#barcode})
class FoodVariants extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();

  /// Grundlage der Duplikaterkennung beim Import (Kapitel 13.6).
  TextColumn get barcode => text().nullable()();

  /// 'custom' | 'import' | 'usda' (Kapitel 10.6).
  TextColumn get source => text()();

  TextColumn get sourceRef => text().nullable()();

  /// wie recipes.owner_id (Kapitel 10.3).
  TextColumn get ownerId => text().nullable()();

  TextColumn get densityGPerMl =>
      text().map(const DecimalConverter()).nullable()();
  TextColumn get gramsPerPiece =>
      text().map(const DecimalConverter()).nullable()();
  TextColumn get servingSizeG =>
      text().map(const DecimalConverter()).nullable()();

  // Acht feste Nährwertfelder pro 100 g, jedes einzeln nullable
  // (Kapitel 8.1). Keine Kilojoule (R7).
  TextColumn get energyKcal =>
      text().map(const DecimalConverter()).nullable()();
  TextColumn get fatG => text().map(const DecimalConverter()).nullable()();
  TextColumn get saturatedFatG =>
      text().map(const DecimalConverter()).nullable()();
  TextColumn get carbsG => text().map(const DecimalConverter()).nullable()();
  TextColumn get sugarsG => text().map(const DecimalConverter()).nullable()();
  TextColumn get fiberG => text().map(const DecimalConverter()).nullable()();
  TextColumn get proteinG =>
      text().map(const DecimalConverter()).nullable()();
  TextColumn get saltG => text().map(const DecimalConverter()).nullable()();

  /// Standard '{}'. Zusätzliche Nährwerte, Decimal-Werte als Strings
  /// (Kapitel 8.1).
  TextColumn get extraJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}