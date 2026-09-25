import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Speichert `Decimal`-Werte verlustfrei als `TEXT` in SQLite (Kapitel 7.4).
/// Niemals `REAL` — das würde die exakte Dezimaldarstellung zerstören.
///
/// Ein einziger, nicht-nullabler Converter genügt für beide Fälle. Drift
/// wrappt ihn intern automatisch null-sicher, WENN `.map()` **vor**
/// `.nullable()` aufgerufen wird — nicht umgekehrt (offizielles Muster laut
/// drift.simonbinder.eu/type_converters/; die umgekehrte Reihenfolge erzeugt
/// nachweislich kaputten generierten Code, siehe simolus3/drift#515).
///
/// Non-nullable Spalte:
/// ```dart
/// TextColumn get quantity => text().map(const DecimalConverter())();
/// ```
///
/// Nullable Spalte:
/// ```dart
/// TextColumn get finalWeightOverrideG =>
///     text().map(const DecimalConverter()).nullable()();
/// ```
class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}