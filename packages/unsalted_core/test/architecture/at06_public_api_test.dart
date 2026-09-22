// test/architecture/at06_public_api_test.dart
//
// AT-06: unsalted_core.dart (die öffentliche Tür) exportiert exakt die Liste
// aus der Golden-Datei public_api_golden.txt. Diese Golden-Datei startet leer
// (Schritt 1.2) und wächst mit jedem Schritt, der etwas Neues exportiert.
// Erst ab Schritt 8.4 ("öffentliche Tür schließen") ist sie final.

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-06: öffentliche Tür entspricht der Golden-Liste', () {
    final libDir = findPackageLibDir();
    final doorFile = File('${libDir.path}/unsalted_core.dart');
    final goldenFile = File('${Directory.current.path}/test/architecture/public_api_golden.txt');

    expect(doorFile.existsSync(), isTrue,
        reason: 'Türdatei lib/unsalted_core.dart fehlt.');
    expect(goldenFile.existsSync(), isTrue,
        reason:
            'test/architecture/public_api_golden.txt fehlt. Leere Datei anlegen, '
            'sie wächst mit jedem Schritt.');

    final exportRegex = RegExp(
      r'''export\s+['"]([^'"]+)['"]\s*(show\s+[^;]+)?;''',
    );

    final actualExports = exportRegex
        .allMatches(doorFile.readAsStringSync())
        .map((m) {
          final target = m.group(1)!;
          final show = m.group(2)?.trim();
          return show == null ? target : '$target $show';
        })
        .toList()
      ..sort();

    final goldenLines = goldenFile
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList()
      ..sort();

    expect(
      actualExports,
      equals(goldenLines),
      reason:
          'Öffentliche Exporte weichen von public_api_golden.txt ab.\n'
          'Ist:   $actualExports\n'
          'Soll:  $goldenLines\n'
          'Wenn die Änderung beabsichtigt ist: golden-Datei bewusst aktualisieren.',
    );
  });
}
