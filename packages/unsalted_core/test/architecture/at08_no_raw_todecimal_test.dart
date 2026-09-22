// test/architecture/at08_no_raw_todecimal_test.dart
//
// AT-08: `toDecimal(` kommt im gesamten Paket nur in
// src/nutrition/decimal_math.dart vor. Jede andere Stelle muss stattdessen
// die Extension `toFixedDecimal()` aus decimal_math.dart benutzen
// (Kapitel 4.3, PROJECT.md Regel 4).

import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-08: toDecimal( nur in decimal_math.dart', () {
    final libDir = findPackageLibDir();
    const allowedFile = 'src/nutrition/decimal_math.dart';

    final toDecimalRegex = RegExp(r'\.toDecimal\(');

    final violations = <String>[];

    for (final file in allDartFiles(libDir)) {
      final rel = relativeToLib(file, libDir);
      if (rel == allowedFile) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final codePart = lines[i].split('//').first;
        if (toDecimalRegex.hasMatch(codePart)) {
          violations.add('$rel:${i + 1} → ${lines[i].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'toDecimal( außerhalb von $allowedFile gefunden:\n${violations.join('\n')}\n'
          'Stattdessen toFixedDecimal() aus decimal_math.dart verwenden.',
    );
  });
}