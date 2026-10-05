// test/spike/spike_database.dart
//
// Schritt 9.3, technischer Spike (Kapitel 20.1). Nur Testcode.
//
// SpikeDatabase steht für die Datenbankklasse eines späteren Pakets
// (Teil 3): eigene Tabelle, eigene Schema-Version, eigene Migrationen. Das
// Protokoll [migrationLog] zeigt, ob und welche Migration lief.

import 'package:drift/drift.dart';

import 'spike_tables.dart';

export 'spike_tables.dart';

part 'spike_database.g.dart';

@DriftDatabase(tables: [SpikeNotes])
class SpikeDatabase extends _$SpikeDatabase {
  SpikeDatabase(super.executor, {this.version = 1});

  final int version;
  final List<String> migrationLog = [];

  @override
  int get schemaVersion => version;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          migrationLog.add('onCreate');
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          migrationLog.add('onUpgrade $from→$to');
        },
      );
}
