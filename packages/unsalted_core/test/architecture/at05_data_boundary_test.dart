// test/architecture/at05_data_boundary_test.dart
//
// AT-05 (neu, Kapitel 5.2 der Spezifikation v2): Kein Import von
// package:drift/drift.dart oder eines Drift-generierten Symbols außerhalb
// von lib/src/data/. Umfasst ui/, nutrition/, recipe/, food/, contracts/,
// module/, providers/ — also strenggenommen jede Datei unter lib/src/
// außer denen in lib/src/data/ selbst.
//
// GEÄNDERT ggü. der ersten Fassung dieses Tests (die nur src/ui/ prüfte):
// die neue Spezifikation weitet die Prüfung ausdrücklich auf alle
// Ordner außer data/ aus (siehe docs/decisions.md).

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-05: kein Drift-Import außerhalb von src/data/', () {
    final libDir = findPackageLibDir();
    final srcDir = Directory('${libDir.path}/src');

    final violations = <String>[];

    for (final file in allDartFiles(srcDir)) {
      final rel = relativeToLib(file, libDir);

      // Alles unter src/data/ ist ausgenommen -- dort ist Drift der Sinn
      // der Sache (Tabellen, DAOs, CoreDatabase, Mapper).
      if (rel.startsWith('src/data/')) continue;

      for (final entry in importLines(file)) {
        final line = entry.value;

        final pkgMatch = importPackageRegex.firstMatch(line);
        if (pkgMatch != null && pkgMatch.group(1) == 'drift') {
          violations.add('$rel:${entry.key} importiert package:drift → ${line.trim()}');
        }

        // Relative Importe wie '../data/tables/recipes.dart' oder
        // '../data/core_database.dart' aus einer Nicht-data/-Datei heraus.
        if (RegExp(r'''['"](\.\./)*data/''').hasMatch(line)) {
          violations.add('$rel:${entry.key} importiert direkt aus data/ → ${line.trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Datengrenze verletzt (AT-05):\n${violations.join('\n')}',
    );
  });
}