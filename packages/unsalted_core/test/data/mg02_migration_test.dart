import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/data/core_database.dart';

import 'generated/schema.dart';

/// MG-02 (Kapitel 23.4): Migrationstest v1 -> v1 (Leerlauf).
///
/// Teil 1 kennt aktuell nur schemaVersion 1, es gibt also noch keine echte
/// Migration zu testen. Dieser Test prüft stattdessen das, was an dieser
/// Stelle zählt: dass die tatsächliche Tabellenstruktur, die aus dem
/// aktuellen CoreDatabase-Quellcode erzeugt wird, exakt der eingefrorenen
/// v1-Momentaufnahme (drift_schemas/drift_schema_v1.json, über
/// GeneratedHelper/schema_v1.dart) entspricht. Weicht der Quellcode später
/// unbemerkt vom eingefrorenen Schema ab, schlägt dieser Test fehl.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    // GeneratedHelper() wurde von drift_dev erzeugt (Schritt 5.4,
    // test/data/generated/schema.dart). Der Verifier ist eine API aus
    // drift_dev (Kapitel 23.4).
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('MG-02: CoreDatabase entspricht dem eingefrorenen Schema v1',
      () async {
    // Leere Tabellen exakt in der Struktur von Schema-Version 1.
    final connection = await verifier.startAt(1);
    final db = CoreDatabase(connection);
    addTearDown(db.close);

    // "Migration" nach Version 1 ist ein Leerlauf (aktuelle Version = 1),
    // validiert aber trotzdem die reale Struktur gegen die eingefrorene.
    await verifier.migrateAndValidate(db, 1);
  });
}