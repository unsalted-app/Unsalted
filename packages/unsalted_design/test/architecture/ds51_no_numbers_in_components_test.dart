// test/architecture/ds51_no_numbers_in_components_test.dart
//
// DS-51 (Teil 1.3, D03): Komponenten, Layout, Templates und Theme nennen
// keine Zahlen für Maße, Abstände, Radien, Schrift oder Dauern — Werte kommen
// nur aus den generierten Tokens (docs/design/plan-1.3.md, Leitplanke „Werte
// nur aus der Token-Datei“). Erlaubt bleibt 0. Gesucht wird nach Zahlen in
// `EdgeInsets…(…)`, `Radius.circular(…)`, `Size(…)`, `Offset(…)`,
// `Duration(…)` und nach benannten Maß-Parametern (`width:`, `height:`,
// `fontSize:`, `elevation:` …).
//
// Die Übergangsliste (D03–D11, wie AT-13/14 in Teil 1.2, C13) ist seit D12
// mit ihrer Ausnahmeprüfung entfernt (wie C27c): Die Regel gilt ohne
// Ausnahme.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_utils.dart';

const _scanned = ['src/components', 'src/layout', 'src/templates', 'src/theme'];

final _number = r'-?\d+(?:\.\d+)?';
final _rules = <RegExp>[
  RegExp(r'\bEdgeInsets(?:Directional)?\.\w+\([^;]*?(?<![\w.])(?!0(?:\.0)?\b)\d'),
  RegExp(r'\b(?:Border)?Radius\.(?:circular|elliptical)\(\s*(?!0(?:\.0)?\b)\d'),
  RegExp(r'\b(?:Size|Offset)\([^)]*?(?<![\w.])(?!0(?:\.0)?\b)\d'),
  RegExp(r'\bSize\.(?:square|fromHeight|fromWidth|fromRadius)\(\s*(?!0(?:\.0)?\b)\d'),
  RegExp(r'\bDuration\(\s*(?:milliseconds|seconds|microseconds|minutes)\s*:\s*(?!0\b)\d'),
  RegExp(
    r'\b(?:width|height|thickness|indent|endIndent|elevation|strokeWidth|size|iconSize|minWidth|minHeight|'
    r'maxWidth|maxHeight|blurRadius|spreadRadius|spacing|runSpacing|fontSize|letterSpacing|dimension|'
    r'toolbarHeight|itemExtent|gap)\s*:\s*(?!0(?:\.0)?\b)'
    '$_number',
  ),
  // Maße mit zwei und mehr Stellen (Zählwerte wie `maxLines: 2` oder Spalten
  // sind einstellig) und Bruchzahlen (Anteile, Deckkraft) überall sonst.
  RegExp(r'(?<![\w.#])\d{2,}(?:\.\d+)?\b'),
  RegExp(r'(?<![\w.#])0\.(?!0\b)\d+\b'),
  RegExp(r'\bFlexColumnWidth\(\s*\d'),
];

/// Zeilen in [source] (ohne Kommentare) mit einer Zahl für ein Maß.
List<(int, String)> findNumbers(String source) {
  final lines = stripComments(source).split('\n');
  return [
    for (var i = 0; i < lines.length; i++)
      if (_rules.any((r) => r.hasMatch(lines[i]))) (i + 1, lines[i].trim()),
  ];
}

void main() {
  final root = findPackageRoot();
  final lib = Directory('${root.path}/lib');
  final files = [
    for (final dir in _scanned)
      if (Directory('${lib.path}/$dir').existsSync()) ...dartFilesUnder(Directory('${lib.path}/$dir')),
  ];

  test('DS-51: keine Zahlen für Maße in Komponenten, Layout, Templates, Theme', () {
    final violations = <String>[];
    for (final file in files) {
      final path = relativePath(file, lib);
      for (final (line, text) in findNumbers(file.readAsStringSync())) {
        violations.add('$path:$line → $text');
      }
    }
    expect(violations, isEmpty, reason: 'Zahlen statt Tokens:\n${violations.join('\n')}');
  });

  test('DS-51: der Detektor erkennt Zahlen', () {
    const bad = [
      'padding: EdgeInsets.all(8),',
      'padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSpacing.s),',
      'borderRadius: BorderRadius.circular(12),',
      'child: SizedBox(width: 120, child: x),',
      'const SizedBox(height: 48)',
      'style: TextStyle(fontSize: 14),',
      'elevation: 2,',
      'thickness: 1,',
      'offset: Offset(0, 4),',
      'size: Size(400, 400),',
      'duration: Duration(milliseconds: 300),',
      'letterSpacing: -0.5,',
      'static const double bottomHeight = 56;',
      'AppIconSize.l => 48,',
      'bar(0.55, 18),',
      'lowerBound: 0.45',
      '0: const FlexColumnWidth(2),',
    ];
    const good = [
      'padding: EdgeInsets.all(AppSpacing.l),',
      'padding: EdgeInsets.zero,',
      'borderRadius: BorderRadius.circular(AppRadius.s),',
      'child: SizedBox(width: AppSize.dialog, child: x),',
      'elevation: 0,',
      'offset: Offset(0, 0),',
      'minimumSize: Size(0, AppSize.control),',
      'maxLines: 2,',
      'flex: 2,',
      'final columns = width >= AppBreakpoints.large ? 3 : 1;',
      'duration: AppMotion.short,',
      '// padding: EdgeInsets.all(8)',
      'medium => 2,',
      'final color = Color(0xFF141925);',
      'value: 0.0,',
    ];
    for (final line in bad) {
      expect(findNumbers(line), hasLength(1), reason: line);
    }
    for (final line in good) {
      expect(findNumbers(line), isEmpty, reason: line);
    }
  });
}
