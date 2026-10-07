// test/architecture/at15_design_only_in_ui_test.dart
//
// AT-15 (Teil 1.2, Kapitel 28.9): `package:unsalted_design/` wird in
// unsalted_core nur unter `lib/src/ui/` importiert; Rechenkern, Fachmodelle,
// Verträge, Daten, Module und Provider bleiben designfrei. Ergänzt
// `forbidden_in_core` in architecture.yaml (tool/check_architecture.dart).

import 'package:test/test.dart';

import 'support/architecture_test_utils.dart';

void main() {
  test('AT-15: unsalted_design nur in lib/src/ui/', () {
    final libDir = findPackageLibDir();
    final violations = <String>[];
    for (final file in allDartFiles(libDir)) {
      final rel = relativeToLib(file, libDir);
      if (rel.startsWith('src/ui/')) continue;
      for (final entry in importLines(file)) {
        if (entry.value.contains('package:unsalted_design/')) violations.add('$rel:${entry.key}');
      }
    }
    expect(violations, isEmpty, reason: 'Design-Import außerhalb von lib/src/ui/:\n${violations.join('\n')}');
  });
}
