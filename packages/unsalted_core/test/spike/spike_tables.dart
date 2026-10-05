// test/spike/spike_tables.dart
//
// Schritt 9.3: Tabelle des simulierten späteren Pakets. Eigene Datei, damit
// SpikeDatabase und SpikeCombinedDatabase sie in getrennten Bibliotheken
// aufnehmen können -- zwei @DriftDatabase-Klassen mit derselben Tabelle in
// EINER Bibliothek erzeugen doppelte Klassen im selben part.

import 'package:drift/drift.dart';

class SpikeNotes extends Table {
  TextColumn get id => text()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {id};
}
