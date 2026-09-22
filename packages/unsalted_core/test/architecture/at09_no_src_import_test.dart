// test/architecture/at09_no_src_import_test.dart
//
// AT-09: unsalted_app und Testdateien außerhalb des jeweiligen Pakets
// importieren nichts aus dessen src/ (R2 — nur die öffentliche Tür ist
// erlaubt). Innerhalb eines Pakets selbst (lib/ und test/ desselben Pakets)
// ist der Zugriff auf das eigene src/ natürlich erlaubt und nötig.
//
// Läuft projektweit (nicht nur innerhalb von unsalted_core), weil genau das
// geprüft werden muss: fremde Pakete dürfen package:unsalted_core/src/...
// nicht importieren.

import 'dart:io';
import 'package:test/test.dart';
import 'support/architecture_test_utils.dart';

void main() {
  test('AT-09: kein Fremdzugriff auf ein fremdes src/', () {
    final root = findProjectRoot();
    final archYaml = findArchitectureYaml();
    final ranks = parseRanks(archYaml.readAsStringSync());

    // package-Name -> Ordnerpfad (packages/<name> oder apps/<name>)
    final packageDirs = <String, String>{};
    for (final base in ['packages', 'apps']) {
      final baseDir = Directory('${root.path}/$base');
      if (!baseDir.existsSync()) continue;
      for (final entry in baseDir.listSync()) {
        if (entry is Directory) {
          final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
          packageDirs[name] = entry.path;
        }
      }
    }

    // src-Import-Muster: package:<name>/src/...
    final srcImportRegex =
        RegExp(r"""import\s+['"]package:([a-zA-Z0-9_]+)/src/[^'"]*['"]""");

    final violations = <String>[];

    for (final file in allProjectDartFiles(root)) {
      // Welchem Paket gehört diese Datei selbst? (falls keinem: z. B. tool/)
      String? owningPackage;
      for (final entry in packageDirs.entries) {
        if (file.path.startsWith('${entry.value}/')) {
          owningPackage = entry.key;
          break;
        }
      }

      for (final entry in importLines(file)) {
        final match = srcImportRegex.firstMatch(entry.value);
        if (match == null) continue;
        final importedPackage = match.group(1)!;

        // Ein Paket darf sein EIGENES src/ importieren.
        if (importedPackage == owningPackage) continue;

        // Nur Verstöße bei tatsächlich bekannten Projektpaketen zählen.
        if (!ranks.containsKey(importedPackage)) continue;

        final relForMessage = file.path.substring(root.path.length + 1);
        violations.add(
          '$relForMessage:${entry.key} importiert package:$importedPackage/src/... '
          '(fremdes Paket${owningPackage != null ? ", Datei gehört zu $owningPackage" : ""})',
        );
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Fremdzugriff auf src/ gefunden:\n${violations.join('\n')}',
    );
  });
}