// test/architecture/at02_nutrition_is_pure_test.dart
//
// AT-02: Keine Datei in src/nutrition/ importiert flutter, drift, sqlite oder
// dart:io. Der Rechenkern muss reines Dart bleiben (Kapitel 13, Checkliste
// Phase 2).

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-02: src/nutrition/ ist reines Dart', () {
    final libDir = findPackageLibDir();
    final nutritionDir = Directory('${libDir.path}/src/nutrition');

    final forbiddenPackages = {'flutter', 'drift', 'sqlite3', 'sqlite'};
    final forbiddenDartLibs = {'io'};

    final violations = <String>[];

    for (final file in allDartFiles(nutritionDir)) {
      final rel = relativeToLib(file, libDir);
      for (final entry in importLines(file)) {
        final pkgMatch = importPackageRegex.firstMatch(entry.value);
        if (pkgMatch != null && forbiddenPackages.contains(pkgMatch.group(1))) {
          violations.add('$rel:${entry.key} importiert package:${pkgMatch.group(1)}');
        }
        final dartMatch = importDartRegex.firstMatch(entry.value);
        if (dartMatch != null && forbiddenDartLibs.contains(dartMatch.group(1))) {
          violations.add('$rel:${entry.key} importiert dart:${dartMatch.group(1)}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'src/nutrition/ ist nicht rein:\n${violations.join('\n')}',
    );
  });
}
