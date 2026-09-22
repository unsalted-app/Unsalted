// test/architecture/at10_tables_have_standard_columns_test.dart
//
// AT-10: jede Drift-Tabelle in src/data/tables/ hat die vier Standardspalten
// (id, created_at, updated_at, deleted_at als camelCase-Getter id, createdAt,
// updatedAt, deletedAt) und benutzt kein autoIncrement() (Kapitel 7.1).
//
// Läuft pro Datei in src/data/tables/ — jede Datei wird als eine Tabelle
// behandelt (Datei-für-Datei-Plan, Kapitel 14).

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-10: Standardspalten in allen Drift-Tabellen', () {
    final libDir = findPackageLibDir();
    final tablesDir = Directory('${libDir.path}/src/data/tables');

    final requiredGetters = ['id', 'createdAt', 'updatedAt', 'deletedAt'];
    final violations = <String>[];

    for (final file in allDartFiles(tablesDir)) {
      final rel = relativeToLib(file, libDir);
      final content = file.readAsStringSync();

      for (final getterName in requiredGetters) {
        final getterRegex = RegExp('get\\s+$getterName\\b');
        if (!getterRegex.hasMatch(content)) {
          violations.add('$rel: Spalte/Getter "$getterName" fehlt');
        }
      }

      if (content.contains('autoIncrement(')) {
        violations.add('$rel: autoIncrement() verwendet — verboten (kein Auto-Increment)');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Standardspalten-Verstöße:\n${violations.join('\n')}',
    );
  });
}
