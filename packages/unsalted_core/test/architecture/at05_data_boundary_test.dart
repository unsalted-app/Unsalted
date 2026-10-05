// test/architecture/at05_data_boundary_test.dart
//
// AT-05 (neu, Kapitel 5.2 der Spezifikation v2): Kein Import von
// package:drift/drift.dart oder eines Drift-generierten Symbols außerhalb
// von lib/src/data/. Umfasst ui/, nutrition/, recipe/, food/, contracts/,
// module/ — also strenggenommen jede Datei unter lib/src/ außer denen in
// lib/src/data/ und lib/src/providers/.
//
// GEÄNDERT ggü. der ersten Fassung dieses Tests (die nur src/ui/ prüfte):
// die neue Spezifikation weitet die Prüfung ausdrücklich auf alle
// Ordner außer data/ aus (siehe docs/decisions.md).
//
// AUSNAHME src/providers/ (Schritt 7.3): eine Riverpod-Verdrahtungsdatei
// muss zwangsläufig aus data/ importieren (CoreDatabase, DriftRecipeDao,
// DriftRecipeRepository, ...) — das ist ihr ganzer Zweck (Kapitel 16.7).
// Die Ausnahme ist bewusst eng: nur src/providers/ selbst, nicht die
// Implementierungen dahinter, und nur für Importe aus data/. package:drift
// bleibt auch dort verboten (Kapitel 28.1.3, Nachtrag 10.2a).

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
      // der Sache (Tabellen, DAOs, CoreDatabase, Mapper). src/providers/
      // darf aus data/ importieren (Schritt 7.3, Kapitel 16.7), aber nicht
      // package:drift (Kapitel 28.1.3).
      if (rel.startsWith('src/data/')) continue;
      final isProviders = rel.startsWith('src/providers/');

      for (final entry in importLines(file)) {
        final line = entry.value;

        final pkgMatch = importPackageRegex.firstMatch(line);
        if (pkgMatch != null && pkgMatch.group(1) == 'drift') {
          violations.add('$rel:${entry.key} importiert package:drift → ${line.trim()}');
        }

        // Relative Importe wie '../data/tables/recipes.dart' oder
        // '../data/core_database.dart' aus einer Nicht-data/-Datei heraus.
        if (!isProviders && RegExp(r'''['"](\.\./)*data/''').hasMatch(line)) {
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