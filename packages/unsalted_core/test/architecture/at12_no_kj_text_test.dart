// test/architecture/at12_no_kj_text_test.dart
//
// AT-12 (neu, Kapitel 5.2 der Spezifikation v2): Kein Vorkommen der
// Zeichenfolge "kJ" (Groß-/Kleinschreibung exakt) in lib/ oder test/.
// R7: Energie ist ausschließlich energy_kcal.

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-12: kein "kJ" in lib/ oder test/', () {
    final libDir = findPackageLibDir();
    final packageDir = libDir.parent;
    final testDir = Directory('${packageDir.path}/test');

    final violations = <String>[];

    void scan(Directory dir, String label, {bool skipArchitectureFolder = false}) {
      for (final file in allDartFiles(dir)) {
        if (skipArchitectureFolder && file.path.contains('${Platform.pathSeparator}architecture${Platform.pathSeparator}')) {
          // Prüfwerkzeuge, die nach "kJ" suchen, müssen den String selbst
          // enthalten (Testname, Kommentare, Suchmuster) -- das ist kein
          // Verstoß gegen R7, sondern die Testinfrastruktur selbst.
          continue;
        }
        final rel = file.path.substring(packageDir.path.length + 1);
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('kJ')) {
            violations.add('$rel:${i + 1} → ${lines[i].trim()}');
          }
        }
      }
    }

    scan(libDir, 'lib');
    if (testDir.existsSync()) scan(testDir, 'test', skipArchitectureFolder: true);

    expect(
      violations,
      isEmpty,
      reason: '"kJ" gefunden (R7 verletzt):\n${violations.join('\n')}',
    );
  });
}