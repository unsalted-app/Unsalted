// test/architecture/ds03_public_api_test.dart
//
// DS-03 (Teil 1.2): lib/unsalted_design.dart exportiert genau die Zeilen aus
// public_api_golden.txt, und jeder Export nennt seine Symbole mit `show`. So
// fällt jede neue, umbenannte oder entfernte Komponente auf (Figma-Namen,
// Plan R10). Format wie AT-06 in unsalted_core.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_utils.dart';

void main() {
  test('DS-03: öffentliche Tür entspricht der Golden-Liste', () {
    final root = findPackageRoot();
    final door = File('${root.path}/lib/unsalted_design.dart').readAsStringSync();
    final golden = File('${root.path}/test/architecture/public_api_golden.txt');

    final exportRegex = RegExp(r'''export\s+['"]([^'"]+)['"]\s*(show\s+[^;]+)?;''');
    final exports = exportRegex.allMatches(stripComments(door)).toList();
    final withoutShow = [for (final m in exports) if (m.group(2) == null) m.group(1)!];
    expect(withoutShow, isEmpty, reason: 'Export ohne show: $withoutShow');

    final actual = [
      for (final m in exports) '${m.group(1)} ${m.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim()}',
    ]..sort();
    final expected = golden
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList()
      ..sort();
    expect(actual, expected,
        reason: 'Exporte weichen von public_api_golden.txt ab. Wenn beabsichtigt: '
            'Golden-Datei bewusst aktualisieren und CHANGELOG.md ergänzen.');
  });
}
