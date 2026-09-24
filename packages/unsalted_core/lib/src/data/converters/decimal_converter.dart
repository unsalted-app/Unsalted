import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Speichert `Decimal`-Werte verlustfrei als `TEXT` in SQLite (Kapitel 7.4).
/// Niemals `REAL` — das würde die exakte Dezimaldarstellung zerstören.
///
/// Verwendung in einer Tabelle:
/// ```dart
/// TextColumn get quantity => text().map(const DecimalConverter())();
/// ```
class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}

/// Variante für nullable `Decimal?`-Spalten (z. B. `final_weight_override_g`,
/// `density_g_per_ml`). Drift verlangt für nullable Spalten einen eigenen
/// `TypeConverter`, der `null` durchreicht, statt `NullAwareTypeConverter`
/// stillschweigend zu erwarten.
///
/// Verwendung:
/// ```dart
/// TextColumn get finalWeightOverrideG =>
///     text().nullable().map(const NullableDecimalConverter())();
/// ```
class NullableDecimalConverter extends TypeConverter<Decimal?, String?> {
  const NullableDecimalConverter();

  @override
  Decimal? fromSql(String? fromDb) =>
      fromDb == null ? null : Decimal.parse(fromDb);

  @override
  String? toSql(Decimal? value) => value?.toString();
}