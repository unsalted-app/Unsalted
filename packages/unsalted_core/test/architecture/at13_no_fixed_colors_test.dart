// test/architecture/at13_no_fixed_colors_test.dart
//
// AT-13 (Teil 1.2, Kapitel 28.9): keine festen Farben in der Oberfläche. In
// `lib/src/ui/` jedes Pakets unter `packages/` sind `Colors.*`,
// `CupertinoColors.*`, `Color(…)`/`Color.from…(…)` und ein `TextStyle(…)` mit
// eigenem `color`, `backgroundColor` oder `decorationColor` verboten. Farben
// kommen aus dem Design-System (`unsalted_design`). Übernommen aus
// `design/1.1`; ausgenommen sind bis C27 die Dateien der Übergangsliste.

import 'dart:io';

import 'package:test/test.dart';

import 'support/architecture_test_utils.dart';
import 'support/design_transition.dart';
import 'support/ui_rules.dart';

void main() {
  test('AT-13: keine festen Farben in packages/*/lib/src/ui/', () {
    final root = findProjectRoot();
    final uiFiles = allProjectDartFiles(root).where((f) {
      final path = f.path.replaceAll(Platform.pathSeparator, '/');
      return path.contains('/packages/') && path.contains('/lib/src/ui/');
    }).toList();
    expect(uiFiles, isNotEmpty, reason: 'keine UI-Dateien gefunden -- Pfadsuche prüfen');

    final violations = <String>[];
    for (final file in uiFiles) {
      final path = file.path.substring(root.path.length + 1).replaceAll(Platform.pathSeparator, '/');
      if (designTransitionList.contains(path)) continue;
      for (final (line, text) in findFixedColors(file.readAsStringSync())) {
        violations.add('$path:$line → $text');
      }
    }
    expect(violations, isEmpty, reason: 'Feste Farben gefunden:\n${violations.join('\n')}');
  });

  test('AT-13: der Detektor erkennt Verstöße und lässt Theme-Farben zu', () {
    expect(findFixedColors('final c = Colors.red;'), hasLength(1));
    expect(findFixedColors('final c = CupertinoColors.white;'), hasLength(1));
    expect(findFixedColors('const c = Color(0xFF00FF00);'), hasLength(1));
    expect(findFixedColors('final c = Color.fromARGB(255, 0, 0, 0);'), hasLength(1));
    expect(findFixedColors('const s = TextStyle(\n  fontSize: 12,\n  color: x,\n);'), hasLength(1));
    expect(findFixedColors('const s = TextStyle(backgroundColor: x);'), hasLength(1));

    expect(findFixedColors('const s = TextStyle(fontWeight: FontWeight.bold);'), isEmpty);
    expect(findFixedColors('final s = theme.textTheme.bodyMedium?.copyWith(color: scheme.error);'), isEmpty);
    expect(findFixedColors('final ColorScheme s = Theme.of(context).colorScheme;'), isEmpty);
    expect(findFixedColors('// Colors.red nur im Kommentar'), isEmpty);
    expect(findFixedColors('const s = TextStyle(shadows: [Shadow(color: c)]);'), isEmpty);
  });
}
