import 'dart:io';

import 'package:test/test.dart';

import '../architecture/support/architecture_test_utils.dart';

/// MG-05 (Kapitel 23.4): keine Spalte in lib/src/data/tables/ ist vom Typ
/// REAL. Alle fachlichen Zahlen sind Decimal, gespeichert als TEXT über
/// DecimalConverter (Kapitel 7.4) — niemals als real()/double.
void main() {
  test('MG-05: keine Spalte ist REAL', () {
    final libDir = findPackageLibDir();
    final tablesDir = Directory('${libDir.path}/src/data/tables');

    final violations = <String>[];
    for (final file in allDartFiles(tablesDir)) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('real()')) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'REAL-Spalte gefunden (verboten, Kapitel 7.4):\n'
          '${violations.join('\n')}',
    );
  });
}