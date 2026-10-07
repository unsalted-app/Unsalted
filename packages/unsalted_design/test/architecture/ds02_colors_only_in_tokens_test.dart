// test/architecture/ds02_colors_only_in_tokens_test.dart
//
// DS-02 (Teil 1.2): Farbwerte stehen nur in lib/src/tokens/. Überall sonst
// im Design-Paket sind `Colors.*`, `CupertinoColors.*`, `Color(…)` und
// `Color.from…(…)` verboten; Farben kommen aus dem Theme (Detektor wie AT-13
// in unsalted_core).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_utils.dart';

final _colorsRegex = RegExp(r'\b(Cupertino)?Colors\.');
final _colorCtorRegex = RegExp(r'\bColor(\.from\w+)?\(');

/// Zeilen mit festen Farben in [source], als (Zeile, Text).
List<(int, String)> findFixedColors(String source) {
  final lines = stripComments(source).split('\n');
  return [
    for (var i = 0; i < lines.length; i++)
      if (_colorsRegex.hasMatch(lines[i]) || _colorCtorRegex.hasMatch(lines[i])) (i + 1, lines[i].trim()),
  ];
}

void main() {
  test('DS-02: Farbwerte nur in lib/src/tokens/', () {
    final root = findPackageRoot();
    final violations = <String>[];
    for (final file in dartFilesUnder(Directory('${root.path}/lib'))) {
      final path = relativePath(file, root);
      if (path.startsWith('lib/src/tokens/')) continue;
      for (final (line, text) in findFixedColors(file.readAsStringSync())) {
        violations.add('$path:$line → $text');
      }
    }
    expect(violations, isEmpty, reason: 'Feste Farben außerhalb der Tokens:\n${violations.join('\n')}');
  });

  test('DS-02: der Detektor erkennt Verstöße und lässt Theme-Farben zu', () {
    expect(findFixedColors('final c = Colors.red;'), hasLength(1));
    expect(findFixedColors('const c = Color(0xFF00FF00);'), hasLength(1));
    expect(findFixedColors('final c = Color.fromARGB(255, 0, 0, 0);'), hasLength(1));
    expect(findFixedColors('final c = Theme.of(context).colorScheme.primary;'), isEmpty);
    expect(findFixedColors('final ColorScheme s = scheme; // Colors.red'), isEmpty);
  });
}
