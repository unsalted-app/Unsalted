// test/architecture/at04_contracts_are_pure_test.dart
//
// AT-04: src/contracts/ importiert kein drift, kein flutter/material.
// Verträge (Kapitel 12) sind reine abstrakte Schnittstellen — jede Kenntnis
// von Drift oder Flutter würde die Implementierungsfreiheit späterer
// Repository-Implementierungen einschränken.

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-04: src/contracts/ kennt weder Drift noch Flutter', () {
    final libDir = findPackageLibDir();
    final contractsDir = Directory('${libDir.path}/src/contracts');

    final forbiddenPackages = {'drift', 'flutter'};

    final violations = <String>[];

    for (final file in allDartFiles(contractsDir)) {
      final rel = relativeToLib(file, libDir);
      for (final entry in importLines(file)) {
        final pkgMatch = importPackageRegex.firstMatch(entry.value);
        if (pkgMatch != null && forbiddenPackages.contains(pkgMatch.group(1))) {
          violations.add('$rel:${entry.key} importiert package:${pkgMatch.group(1)}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'src/contracts/ ist nicht rein:\n${violations.join('\n')}',
    );
  });
}
