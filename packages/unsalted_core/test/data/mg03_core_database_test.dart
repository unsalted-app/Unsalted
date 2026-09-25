// test/data/mg03_core_database_test.dart
//
// MG-03 (Kapitel 23.4): CoreDatabase startet mit übergebenem QueryExecutor.
// Nutzt eine In-Memory-SQLite-Instanz (package:drift/native.dart) — keine
// Datei auf der Festplatte, ausschließlich zum Nachweis, dass CoreDatabase
// mit einem von außen übergebenen Executor lauffähig ist (Kapitel 16.7:
// coreDatabaseProvider bekommt den Executor ebenfalls von außen).

import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/data/core_database.dart';

void main() {
  test('MG-03: CoreDatabase startet mit übergebenem QueryExecutor', () async {
    final db = CoreDatabase(NativeDatabase.memory());

    expect(db.schemaVersion, 1);

    // Einfache Operation, um zu beweisen, dass die Verbindung tatsächlich
    // funktioniert, nicht nur dass der Konstruktor durchläuft.
    final result = await db.customSelect('SELECT 1 AS one').getSingle();
    expect(result.read<int>('one'), 1);

    await db.close();
  });

  test('MG-03b: alle fünf Tabellen sind registriert', () async {
    final db = CoreDatabase(NativeDatabase.memory());

    final tableNames = db.allTables.map((t) => t.actualTableName).toSet();
    expect(
      tableNames,
      equals({
        'recipes',
        'recipe_versions',
        'recipe_ingredients',
        'recipe_steps',
        'food_variants',
      }),
    );

    await db.close();
  });
}