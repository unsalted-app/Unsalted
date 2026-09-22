// test/architecture/at03_recipe_is_pure_test.dart
//
// AT-03: dito wie AT-02, aber für src/recipe/ und src/food/ (reine Fachmodelle,
// Kapitel 3 und 4, keine Datenbank- oder UI-Abhängigkeit).

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-03: src/recipe/ und src/food/ sind reines Dart', () {
    final libDir = findPackageLibDir();
    final dirs = [
      Directory('${libDir.path}/src/recipe'),
      Directory('${libDir.path}/src/food'),
    ];

    final forbiddenPackages = {'flutter', 'drift', 'sqlite3', 'sqlite'};
    final forbiddenDartLibs = {'io'};

    final violations = <String>[];

    for (final dir in dirs) {
      for (final file in allDartFiles(dir)) {
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
    }

    expect(
      violations,
      isEmpty,
      reason: 'src/recipe/ oder src/food/ ist nicht rein:\n${violations.join('\n')}',
    );
  });
}
