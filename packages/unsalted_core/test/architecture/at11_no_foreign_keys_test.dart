// test/architecture/at11_no_foreign_keys_test.dart
//
// AT-11: keine references( in src/data/tables/. Verweise zwischen Tabellen
// sind Text-UUIDs, niemals Drift-Fremdschlüssel (R3, Kapitel 7.1) —
// notwendige Vorbereitung für Sync (Teil 3).

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-11: keine Fremdschlüssel in src/data/tables/', () {
    final libDir = findPackageLibDir();
    final tablesDir = Directory('${libDir.path}/src/data/tables');

    final violations = <String>[];

    for (final file in allDartFiles(tablesDir)) {
      final rel = relativeToLib(file, libDir);
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final codePart = lines[i].split('//').first;
        if (codePart.contains('references(')) {
          violations.add('$rel:${i + 1} → ${lines[i].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Fremdschlüssel gefunden:\n${violations.join('\n')}',
    );
  });
}
