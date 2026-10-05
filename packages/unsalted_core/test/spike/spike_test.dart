// test/spike/spike_test.dart
//
// Schritt 9.3, technischer Spike (Kapitel 20.1): Können mehrere
// Drift-Datenbankklassen (eine je Paket) dieselbe Datenbankdatei bzw.
// denselben QueryExecutor nutzen? Ergebnis und Quellen: docs/decisions.md,
// Eintrag „Spike 20.1“.
//
// Paket 1 = die echte, unveränderte CoreDatabase (schemaVersion 1).
// Paket 2 = SpikeDatabase (eigene Tabelle spike_notes, eigene Version).
//
//   A: beide Klassen auf DERSELBEN QueryExecutor-Instanz (NativeDatabase)
//   B: jede Klasse mit EIGENER NativeDatabase auf dieselbe Datei
//   C: eine gemeinsame Klasse mit allen Tabellen (Plan B aus 20.1)
//
// Jede Variante prüft 1 Anlegen, 2 Schema-Version, 3 Lesen/Schreiben,
// 4 Live-Streams, 5 Transaktion, 6 gleichzeitiges Schreiben, 7 Schließen.
// Echte temporäre Datei, keine In-Memory-DB. Tests, die ein
// Nichtfunktionieren belegen, prüfen das dokumentierte Verhalten.

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' show CoreDatabase;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/domain_event_bus.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';

import 'spike_combined_database.dart' as cmb;
import 'spike_database.dart';

const coreTables = {'recipes', 'recipe_versions', 'recipe_ingredients', 'recipe_steps', 'food_variants'};

File tempDbFile() {
  final dir = Directory.systemTemp.createTempSync('unsalted_spike_');
  addTearDown(() => dir.delete(recursive: true));
  return File('${dir.path}/shared.sqlite');
}

T closeLater<T extends GeneratedDatabase>(T db) {
  addTearDown(db.close);
  return db;
}

Future<Set<String>> tablesOf(GeneratedDatabase db) async => (await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
        .get())
    .map((r) => r.read<String>('name'))
    .toSet();

Future<int> userVersion(GeneratedDatabase db) async =>
    (await db.customSelect('PRAGMA user_version').getSingle()).read<int>('user_version');

DriftRecipeRepository repositoryOf(CoreDatabase core) =>
    DriftRecipeRepository(DriftRecipeDao(core), DriftFoodDao(core), core, eventBus: DomainEventBus());

Future<void> insertNote(SpikeDatabase spike, String id) =>
    spike.into(spike.spikeNotes).insert(SpikeNotesCompanion.insert(id: id, body: 'Notiz $id'));

Future<int> noteCount(GeneratedDatabase db) async =>
    (await db.customSelect('SELECT COUNT(*) AS c FROM spike_notes').getSingle()).read<int>('c');

Future<int> recipeCount(GeneratedDatabase db) async =>
    (await db.customSelect('SELECT COUNT(*) AS c FROM recipes WHERE deleted_at IS NULL').getSingle()).read<int>('c');

/// Paket 2 legt seine Tabelle selbst an, wo Drift es nicht tut (A, B).
Future<void> createSpikeTableManually(SpikeDatabase spike) =>
    spike.createMigrator().createTable(spike.spikeNotes);

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  // ===========================================================================
  group('Variante A: eine QueryExecutor-Instanz für beide Klassen', () {
    test('A1/A2: nur die zuerst öffnende Klasse migriert; user_version gehört ihr', () async {
      final file = tempDbFile();
      final executor = NativeDatabase(file);
      final core = closeLater(CoreDatabase(executor));
      final spike = closeLater(SpikeDatabase(executor, version: 2));

      await recipeCount(core); // Core öffnet zuerst
      await spike.customSelect('SELECT 1').get(); // Spike öffnet danach

      expect(await tablesOf(spike), coreTables, reason: 'spike_notes fehlt');
      expect(spike.migrationLog, isEmpty, reason: 'Migration von Paket 2 läuft nie');
      expect(await userVersion(spike), 1, reason: 'Version von Core, nicht 2');
      await expectLater(insertNote(spike, 'n1'), throwsA(isA<SqliteException>()));
    });

    test('A1/A2 (umgekehrte Reihenfolge): öffnet Paket 2 zuerst, fehlen die Core-Tabellen', () async {
      final file = tempDbFile();
      final executor = NativeDatabase(file);
      final core = closeLater(CoreDatabase(executor));
      final spike = closeLater(SpikeDatabase(executor, version: 2));

      await spike.customSelect('SELECT 1').get();
      await core.customSelect('SELECT 1').get();

      expect(spike.migrationLog, ['onCreate']);
      expect(await tablesOf(core), {'spike_notes'});
      expect(await userVersion(core), 2);
      await expectLater(repositoryOf(core).createRecipe(const NewRecipe(title: 'Brot')),
          throwsA(isA<SqliteException>()));
    });

    test('A3/A4/A6: Lesen/Schreiben geht; Streams nur bei geteilter DatabaseConnection', () async {
      final file = tempDbFile();

      // A3/A6 mit roher Executor-Instanz (Variante A wie gefordert).
      final executor = NativeDatabase(file);
      final core = closeLater(CoreDatabase(executor));
      final spike = closeLater(SpikeDatabase(executor));
      await recipeCount(core);
      await createSpikeTableManually(spike);

      await repositoryOf(core).createRecipe(const NewRecipe(title: 'Brot'));
      await insertNote(spike, 'n1');
      expect(await recipeCount(spike), 1, reason: 'Spike liest, was Core schrieb');
      expect(await noteCount(core), 1, reason: 'Core liest, was Spike schrieb');

      // A6: verschränkte Schreibzugriffe beider Klassen werden vom
      // gemeinsamen Executor serialisiert -- kein "database is locked".
      final repo = repositoryOf(core);
      await Future.wait([
        for (var i = 0; i < 20; i++) ...[
          repo.createRecipe(NewRecipe(title: 'R$i')),
          insertNote(spike, 'p$i'),
        ],
      ]);
      expect(await recipeCount(core), 21);
      expect(await noteCount(core), 21);

      // A4 mit roher Executor-Instanz: jede Klasse hat ihren eigenen
      // StreamQueryStore -- Benachrichtigungen der einen erreichen die
      // andere nicht.
      final seen = <int>[];
      final sub = spike.select(spike.spikeNotes).watch().listen((rows) => seen.add(rows.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await core.customStatement("INSERT INTO spike_notes (id, body) VALUES ('c1', 'von Core')");
      core.notifyUpdates({const TableUpdate('spike_notes')});
      await pumpEventQueue();
      expect(seen, [21], reason: 'Stream von Spike bemerkt das Schreiben über Core nicht');
      await insertNote(spike, 'n2');
      await pumpEventQueue();
      expect(seen, [21, 23], reason: 'Kontrolle: eigenes Schreiben wird bemerkt');
    });

    test('A4b: mit geteilter DatabaseConnection werden Streams klassenübergreifend benachrichtigt', () async {
      final file = tempDbFile();
      final connection = DatabaseConnection(NativeDatabase(file));
      final core = closeLater(CoreDatabase(connection));
      final spike = closeLater(SpikeDatabase(connection));
      await recipeCount(core);
      await createSpikeTableManually(spike);

      final seen = <int>[];
      final sub = spike.select(spike.spikeNotes).watch().listen((rows) => seen.add(rows.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await core.customStatement("INSERT INTO spike_notes (id, body) VALUES ('c1', 'von Core')");
      core.notifyUpdates({const TableUpdate('spike_notes')});
      await pumpEventQueue();

      expect(seen, [0, 1]);
    });

    test('A5: Transaktion über beide Klassen ist nicht möglich (Paket 2 blockiert)', () async {
      final file = tempDbFile();
      final executor = NativeDatabase(file);
      final core = closeLater(CoreDatabase(executor));
      final spike = closeLater(SpikeDatabase(executor));
      await recipeCount(core);
      await createSpikeTableManually(spike);

      // Spike erkennt die Transaktion von Core nicht (attachedDatabase
      // verschieden) und wartet auf den Executor, den die Transaktion hält.
      late Future<int> pending;
      await expectLater(
        core.transaction(() async {
          await core.customStatement("INSERT INTO spike_notes (id, body) VALUES ('t-core', 'in Transaktion')");
          pending = insertNote(spike, 't-spike').then((_) => 1);
          await pending.timeout(const Duration(milliseconds: 200));
        }),
        throwsA(isA<TimeoutException>()),
      );
      await pending; // läuft erst nach dem Rollback, außerhalb der Transaktion

      final ids = (await spike.select(spike.spikeNotes).get()).map((n) => n.id).toSet();
      expect(ids, {'t-spike'}, reason: 'Core-Schreiben zurückgerollt, Spike-Schreiben trotzdem da: nicht atomar');
    });

    test('A7: Schließen einer Klasse schließt den Executor für beide', () async {
      final file = tempDbFile();
      final executor = NativeDatabase(file);
      final core = CoreDatabase(executor);
      final spike = closeLater(SpikeDatabase(executor));
      await recipeCount(core);
      await spike.customSelect('SELECT 1').get();

      await core.close();

      await expectLater(spike.customSelect('SELECT 1').get(), throwsA(anything));
    });
  });

  // ===========================================================================
  group('Variante B: eigene NativeDatabase je Klasse auf dieselbe Datei', () {
    test('B1/B2: gleiche Versionsnummer -- Paket 2 migriert nicht, spike_notes fehlt', () async {
      final file = tempDbFile();
      final core = closeLater(CoreDatabase(NativeDatabase(file)));
      await recipeCount(core);
      final spike = closeLater(SpikeDatabase(NativeDatabase(file), version: 1));
      await spike.customSelect('SELECT 1').get();

      expect(spike.migrationLog, isEmpty);
      expect(await tablesOf(spike), coreTables);
      expect(await userVersion(spike), 1);
    });

    test('B2: höhere Version von Paket 2 überschreibt user_version und sperrt danach Core aus', () async {
      final file = tempDbFile();
      final core = closeLater(CoreDatabase(NativeDatabase(file)));
      await recipeCount(core);
      final spike = closeLater(SpikeDatabase(NativeDatabase(file), version: 2));
      await spike.customSelect('SELECT 1').get();

      expect(spike.migrationLog, ['onUpgrade 1→2'], reason: 'Core-Version als eigene Vorgängerversion missverstanden');
      expect(await tablesOf(spike), coreTables, reason: 'onCreate von Paket 2 lief nie');
      expect(await userVersion(spike), 2);

      // Nächster App-Start: Core sieht Version 2, will auf 1 „upgraden“ und
      // scheitert an der Standard-Migrationsstrategie.
      final coreAgain = closeLater(CoreDatabase(NativeDatabase(file)));
      await expectLater(recipeCount(coreAgain), throwsA(isA<Exception>()));
    });

    test('B3/B4/B7: Lesen/Schreiben geht, Streams getrennt, Schließen getrennt', () async {
      final file = tempDbFile();
      final core = closeLater(CoreDatabase(NativeDatabase(file)));
      await recipeCount(core);
      final spike = closeLater(SpikeDatabase(NativeDatabase(file)));
      await createSpikeTableManually(spike);

      // B3: nacheinander geschrieben, über die jeweils andere Verbindung gelesen.
      await repositoryOf(core).createRecipe(const NewRecipe(title: 'Brot'));
      await insertNote(spike, 'n1');
      expect(await recipeCount(spike), 1);
      expect(await noteCount(core), 1);

      // B4: getrennte Verbindungen, getrennte Stream-Stores
      // (drift.simonbinder.eu/isolates: „stream queries won't synchronize
      // between those independent instances“).
      final seen = <int>[];
      final sub = spike.select(spike.spikeNotes).watch().listen((rows) => seen.add(rows.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await core.customStatement("INSERT INTO spike_notes (id, body) VALUES ('c1', 'von Core')");
      core.notifyUpdates({const TableUpdate('spike_notes')});
      await pumpEventQueue();
      expect(seen, [1], reason: 'Spike bemerkt das Schreiben über Core nicht');

      // B7: Core schließen lässt Spike unberührt.
      await core.close();
      expect(await noteCount(spike), 2);
    });

    test('B6: Schreiben neben einer Teil-1-Transaktion scheitert mit „database is locked“', () async {
      final file = tempDbFile();
      final core = closeLater(CoreDatabase(NativeDatabase(file)));
      await recipeCount(core);
      final spike = closeLater(SpikeDatabase(NativeDatabase(file)));
      await createSpikeTableManually(spike);

      // createRecipe schreibt in einer Transaktion mit asynchronen Lücken;
      // die zweite Verbindung trifft auf die offene Sperre. Drift setzt kein
      // busy_timeout (SQLite-Standard 0), daher sofortiger Fehler.
      final repo = repositoryOf(core);
      final spikeErrors = <Object>[];
      await Future.wait([
        for (var i = 0; i < 20; i++) ...[
          repo.createRecipe(NewRecipe(title: 'R$i')),
          insertNote(spike, 'p$i').then<void>((_) {}, onError: (Object e) {
            spikeErrors.add(e);
          }),
        ],
      ]);

      expect(await recipeCount(core), 20, reason: 'Core-Transaktionen laufen durch');
      expect(spikeErrors, isNotEmpty);
      expect(spikeErrors, everyElement(isA<SqliteException>().having((e) => e.extendedResultCode & 0xff, 'Code', 5)));
      expect(await noteCount(spike) + spikeErrors.length, 20, reason: 'jede Notiz geschrieben oder gesperrt');
    });

    test('B5: Transaktion über beide Klassen -- „database is locked“, nicht atomar', () async {
      final file = tempDbFile();
      final core = closeLater(CoreDatabase(NativeDatabase(file)));
      await recipeCount(core);
      final spike = closeLater(SpikeDatabase(NativeDatabase(file)));
      await createSpikeTableManually(spike);

      Object? spikeError;
      await expectLater(
        core.transaction(() async {
          await core.customStatement("INSERT INTO spike_notes (id, body) VALUES ('t-core', 'in Transaktion')");
          try {
            await insertNote(spike, 't-spike');
          } catch (e) {
            spikeError = e;
            rethrow;
          }
        }),
        throwsA(isA<SqliteException>()),
      );

      expect(spikeError, isA<SqliteException>().having((e) => e.extendedResultCode & 0xff, 'Ergebniscode', 5));
      expect('$spikeError', contains('database is locked'));
      expect(await noteCount(spike), 0, reason: 'Transaktion von Core zurückgerollt');
    });
  });

  // ===========================================================================
  group('Variante C: eine gemeinsame Klasse mit allen Tabellen', () {
    test('C1/C2: eine Migration legt alle Tabellen an, eine user_version', () async {
      final file = tempDbFile();
      final combined = closeLater(cmb.SpikeCombinedDatabase(NativeDatabase(file)));

      expect(await tablesOf(combined), {...coreTables, 'spike_notes'});
      expect(combined.migrationLog, ['onCreate']);
      expect(await userVersion(combined), 1);
    });

    test('C3/C4/C5/C6: Lesen/Schreiben, Streams, atomare Transaktion, verschränktes Schreiben', () async {
      final file = tempDbFile();
      final combined = closeLater(cmb.SpikeCombinedDatabase(NativeDatabase(file)));
      Future<void> note(String id) =>
          combined.into(combined.spikeNotes).insert(cmb.SpikeNotesCompanion.insert(id: id, body: 'Notiz $id'));
      Future<void> recipe(String id) => combined.into(combined.recipes).insert(cmb.RecipesCompanion.insert(
            id: id,
            createdAt: 1,
            updatedAt: 1,
            title: 'Rezept $id',
          ));

      final seen = <int>[];
      final sub = combined.select(combined.spikeNotes).watch().listen((rows) => seen.add(rows.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();

      // C3 + C4
      await recipe('r1');
      await note('n1');
      await pumpEventQueue();
      expect(await recipeCount(combined), 1);
      expect(seen, [0, 1]);

      // C5: atomar -- Fehler rollt beide Tabellen zurück, Erfolg schreibt beide.
      await expectLater(
        combined.transaction(() async {
          await recipe('r2');
          await note('n2');
          throw StateError('Abbruch');
        }),
        throwsA(isA<StateError>()),
      );
      expect((await recipeCount(combined), await noteCount(combined)), (1, 1));
      await combined.transaction(() async {
        await recipe('r3');
        await note('n3');
      });
      expect((await recipeCount(combined), await noteCount(combined)), (2, 2));

      // C6
      await Future.wait([
        for (var i = 0; i < 20; i++) ...[recipe('p$i'), note('p$i')],
      ]);
      expect((await recipeCount(combined), await noteCount(combined)), (22, 22));
    });

    test('C mit Teil 1: CoreDatabase auf derselben DatabaseConnection nutzt das gemeinsame Schema', () async {
      final file = tempDbFile();
      final connection = DatabaseConnection(NativeDatabase(file));
      final combined = closeLater(cmb.SpikeCombinedDatabase(connection));
      final core = closeLater(CoreDatabase(connection));
      await combined.customSelect('SELECT 1').get(); // gemeinsame Klasse öffnet und migriert

      // Teil-1-Repository unverändert auf dem gemeinsamen Schema.
      final seen = <int>[];
      final sub = combined.select(combined.recipes).watch().listen((rows) => seen.add(rows.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await repositoryOf(core).createRecipe(const NewRecipe(title: 'Brot'));
      await pumpEventQueue();

      expect(await recipeCount(combined), 1);
      expect(seen, [0, 1], reason: 'geteilte DatabaseConnection teilt den Stream-Store');
      expect(await userVersion(core), 1);
    });

    test('C5b: Teil-1-Repository innerhalb einer Transaktion der gemeinsamen Klasse blockiert (wie A5)',
        () async {
      final file = tempDbFile();
      final connection = DatabaseConnection(NativeDatabase(file));
      final combined = closeLater(cmb.SpikeCombinedDatabase(connection));
      final core = closeLater(CoreDatabase(connection));
      await combined.customSelect('SELECT 1').get();

      late Future<String> pending;
      await expectLater(
        combined.transaction(() async {
          await combined.into(combined.spikeNotes).insert(cmb.SpikeNotesCompanion.insert(id: 't', body: 'x'));
          pending = repositoryOf(core).createRecipe(const NewRecipe(title: 'Brot'));
          await pending.timeout(const Duration(milliseconds: 200));
        }),
        throwsA(isA<TimeoutException>()),
      );
      await pending;

      expect((await recipeCount(combined), await noteCount(combined)), (1, 0),
          reason: 'Notiz zurückgerollt, Rezept danach außerhalb geschrieben: klassenübergreifend nicht atomar');
    });

    test('C7: Schließen der gemeinsamen Verbindung schließt sie für alle Klassen darauf', () async {
      final file = tempDbFile();
      final connection = DatabaseConnection(NativeDatabase(file));
      final combined = cmb.SpikeCombinedDatabase(connection);
      final core = closeLater(CoreDatabase(connection));
      await combined.customSelect('SELECT 1').get();

      await combined.close();

      await expectLater(core.customSelect('SELECT 1').get(), throwsA(anything));
    });
  });
}
