// test/architecture/at01_no_upper_imports_test.dart
//
// AT-01: unsalted_core importiert kein Paket mit höherem Rang (R1 in PROJECT.md,
// architecture.yaml). Da unsalted_core Rang 1 hat (der niedrigste), bedeutet das
// praktisch: kein Import irgendeines anderen Projektpakets.

import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-01: unsalted_core importiert kein ranghöheres/-gleiches Paket', () {
    final archYaml = findArchitectureYaml();
    final ranks = parseRanks(archYaml.readAsStringSync());
    final libDir = findPackageLibDir();

    const ownPackage = 'unsalted_core';
    final ownRank = ranks[ownPackage];
    expect(ownRank, isNotNull,
        reason: 'unsalted_core fehlt in architecture.yaml');

    final violations = <String>[];

    for (final file in allDartFiles(libDir)) {
      final rel = relativeToLib(file, libDir);
      for (final entry in importLines(file)) {
        final match = importPackageRegex.firstMatch(entry.value);
        if (match == null) continue;
        final importedPackage = match.group(1)!;
        if (importedPackage == ownPackage) continue;
        final importedRank = ranks[importedPackage];
        if (importedRank != null && importedRank >= ownRank!) {
          violations.add(
            '$rel:${entry.key} importiert "$importedPackage" (Rang $importedRank) '
            '— unsalted_core hat Rang $ownRank',
          );
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Rangverstöße gefunden:\n${violations.join('\n')}',
    );
  });
}