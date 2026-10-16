// test/typography/ds49_glyph_coverage_test.dart
//
// DS-49 (Teil 1.3, D02): Texte der Oberfläche verwenden nur Zeichen, die die
// Schrift des Design-Systems enthält. Geprüft werden alle Zeichen außerhalb
// von Kommentaren — wörtlich oder als `\uXXXX` geschrieben — in
// `packages/unsalted_design/lib/` und `packages/unsalted_core/lib/src/ui/`
// gegen die Zeichentabelle aller drei Schnitte. Der Schrift fehlen u. a.
// → ✓ ★ µ (docs/design/system/02-typografie.md); sie erscheinen als Symbol.
//
// Einzige Ausnahme: der Pfeil in den Texten der Änderungsliste
// (`versions/change_descriptions.dart`). Bis D14 wird er noch als Text
// gezeichnet (auf dem Gerät aus der Systemschrift), ab D14 zeichnet
// `AppChangeText` ein Symbol und der Text dient nur noch als Semantik
// (docs/design/plan-1.3.md, d4).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../architecture/support/design_test_utils.dart';
import 'support/cmap.dart';

const _exceptions = {
  'unsalted_core/lib/src/ui/versions/change_descriptions.dart': {0x2192},
};

final _escape = RegExp(r'\\u\{([0-9a-fA-F]+)\}|\\u([0-9a-fA-F]{4})');

/// Zeichen außerhalb von Kommentaren in [source] als (Zeile, Code Point).
List<(int, int)> _codePoints(String source) {
  final lines = stripComments(source).split('\n');
  return [
    for (var i = 0; i < lines.length; i++) ...[
      for (final rune in lines[i].runes)
        if (rune > 0x7E) (i + 1, rune),
      for (final m in _escape.allMatches(lines[i])) (i + 1, int.parse(m.group(1) ?? m.group(2)!, radix: 16)),
    ],
  ];
}

void main() {
  final root = findPackageRoot();
  final packages = root.parent;
  final fonts = Directory('${root.path}/lib/fonts')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.ttf'))
      .toList();

  test('DS-49: drei Schnitte mit derselben Zeichentabelle', () {
    expect(fonts, hasLength(3));
    final tables = [for (final f in fonts) cmapCodePoints(f.readAsBytesSync())];
    expect(tables.first, hasLength(362), reason: 'Atkinson Hyperlegible Next 2.001: 362 Zeichen');
    for (final table in tables.skip(1)) {
      expect(table, tables.first);
    }
    // Fehlende Zeichen laut 02-typografie: Pfeile, Häkchen, Stern, Mikro,
    // schmales geschütztes Leerzeichen. Vorhanden: geschütztes Leerzeichen,
    // Gedankenstriche, deutsche Anführungszeichen, Auslassungspunkte.
    for (final missing in [0x2190, 0x2191, 0x2192, 0x2193, 0x2713, 0x2605, 0x00B5, 0x202F]) {
      expect(tables.first.contains(missing), isFalse, reason: 'U+${missing.toRadixString(16)}');
    }
    for (final present in [0x00A0, 0x2013, 0x2014, 0x201E, 0x201C, 0x2026, 0x00B7, 0x00D7, 0x00E4, 0x00DF]) {
      expect(tables.first.contains(present), isTrue, reason: 'U+${present.toRadixString(16)}');
    }
  });

  test('DS-49: Oberflächentexte nur mit Zeichen der Schrift', () {
    final glyphs = cmapCodePoints(fonts.first.readAsBytesSync());
    final failures = <String>[];
    var checked = 0;
    for (final base in ['unsalted_design/lib', 'unsalted_core/lib/src/ui']) {
      for (final file in dartFilesUnder(Directory('${packages.path}/$base'))) {
        final path = relativePath(file, packages);
        final allowed = _exceptions[path] ?? const <int>{};
        for (final (line, rune) in _codePoints(file.readAsStringSync())) {
          checked++;
          if (!glyphs.contains(rune) && !allowed.contains(rune)) {
            failures.add('$path:$line → U+${rune.toRadixString(16).toUpperCase().padLeft(4, '0')} '
                '„${String.fromCharCode(rune)}“');
          }
        }
      }
    }
    expect(checked, greaterThan(0), reason: 'keine Texte gefunden — Pfade prüfen');
    expect(failures, isEmpty, reason: 'Zeichen ohne Glyphe:\n${failures.join('\n')}');
  });

  test('DS-49: der Detektor erkennt fehlende Zeichen', () {
    final glyphs = cmapCodePoints(fonts.first.readAsBytesSync());
    final found = _codePoints("final a = 'Stern ★'; // Pfeil → im Kommentar\nfinal b = '\\u2713 \\u{00B5}';");
    expect([for (final (line, rune) in found) if (!glyphs.contains(rune)) (line, rune)], [
      (1, 0x2605),
      (2, 0x2713),
      (2, 0x00B5),
    ]);
  });
}
