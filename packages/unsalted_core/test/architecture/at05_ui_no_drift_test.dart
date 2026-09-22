// test/architecture/at05_ui_no_drift_test.dart
//
// AT-05: Keine Datei in src/ui/ importiert drift oder src/data/tables direkt.
// Die UI darf nur über die Verträge (contracts/) auf Daten zugreifen, nie
// direkt auf Drift-Tabellen (R5 in PROJECT.md).

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-05: src/ui/ importiert kein Drift und keine Tabellen direkt', () {
    final libDir = findPackageLibDir();
    final uiDir = Directory('${libDir.path}/src/ui');

    final violations = <String>[];

    for (final file in allDartFiles(uiDir)) {
      final rel = relativeToLib(file, libDir);
      for (final entry in importLines(file)) {
        final line = entry.value;

        final pkgMatch = importPackageRegex.firstMatch(line);
        if (pkgMatch != null && pkgMatch.group(1) == 'drift') {
          violations.add('$rel:${entry.key} importiert package:drift');
        }

        // Relative Importe wie '../data/tables/recipes.dart'
        if (line.contains('src/data/tables') ||
            RegExp(r'''['"](\.\./)*data/tables/''').hasMatch(line)) {
          violations.add('$rel:${entry.key} importiert direkt aus data/tables');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'src/ui/ verletzt R5:\n${violations.join('\n')}',
    );
  });
}
