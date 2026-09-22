// test/architecture/at07_no_double_test.dart
//
// AT-07: kein `double`, `.toDouble()`, `num` in lib/ außer in src/ui/
// (dort nur für reine Layout-Werte wie Padding/Größen erlaubt, Kapitel 4.1).
// Dieser Test kann nicht zwischen "Layout-double" und "fachlichem double"
// unterscheiden — er verbietet daher double/num komplett außerhalb von
// src/ui/ und lässt es innerhalb von src/ui/ zu. Die fachliche Korrektheit
// innerhalb von src/ui/ bleibt Aufgabe des Code-Reviews.

import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-07: kein double/num außerhalb von src/ui/', () {
    final libDir = findPackageLibDir();

    // Wortgrenzen, damit z. B. "num" nicht in "Enumeration" anschlägt.
    final doubleRegex = RegExp(r'\bdouble\b');
    final toDoubleRegex = RegExp(r'\.toDouble\(\)');
    final numRegex = RegExp(r'\bnum\b');

    final violations = <String>[];

    for (final file in allDartFiles(libDir)) {
      final rel = relativeToLib(file, libDir);
      if (rel.startsWith('ui/') || rel.startsWith('src/ui/')) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Kommentarzeilen nicht werten (z. B. dieser Kommentar hier).
        final codePart = line.split('//').first;
        if (doubleRegex.hasMatch(codePart) ||
            toDoubleRegex.hasMatch(codePart) ||
            numRegex.hasMatch(codePart)) {
          violations.add('$rel:${i + 1} → ${line.trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'double/num außerhalb von src/ui/ gefunden:\n${violations.join('\n')}',
    );
  });
}