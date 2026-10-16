// test/tokens/ds05_contrast_test.dart
//
// DS-05 (Teil 1.2, neu gefasst in Teil 1.3 D03): Kontraste der semantischen
// Paare aus docs/design/system/01-farbe.md („Kontraste“) in beiden Modi —
// Text ≥ 4,5 : 1, Konturen und Fokusring ≥ 3 : 1 (WCAG 2.x). Jede Zeile trägt
// zusätzlich den in 01 genannten Wert; weicht die Rechnung ab, stimmen
// Dokument und Tokens nicht mehr überein. Ausdrücklich ausgenommen (in 01
// begründet): Marker auf Papier im hellen Modus (der Marker-Knopf trägt
// deshalb eine Tintenkontur) und das Punktraster (rein dekorativ).

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Kontrastverhältnis nach WCAG 2.1.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

/// (Vordergrund, Hintergrund, Wert hell, Wert dunkel, Mindestwert) aus 01.
const _pairs = [
  ('text-primary', 'surface-page', 16.40, 16.40, 4.5),
  ('text-primary', 'surface-raised', 17.57, 13.43, 4.5),
  ('text-primary', 'surface-sunken', 15.15, 17.76, 4.5),
  ('text-secondary', 'surface-page', 5.72, 6.59, 4.5),
  ('text-secondary', 'surface-raised', 6.13, 5.40, 4.5),
  ('text-secondary', 'surface-sunken', 5.28, 7.14, 4.5),
  ('action-on-primary', 'action-primary', 16.40, 16.40, 4.5),
  ('text-inverse', 'surface-inverse', 16.40, 16.40, 4.5),
  ('action-inverse', 'surface-inverse', 13.81, 16.40, 4.5),
  ('text-on-marker', 'marker', 13.81, 11.53, 4.5),
  ('text-error', 'surface-page', 5.32, 7.77, 4.5),
  ('text-error', 'surface-raised', 5.70, 6.36, 4.5),
  ('text-error', 'surface-sunken', 4.92, 8.41, 4.5),
  ('text-warning', 'surface-page', 4.95, 9.18, 4.5),
  ('text-warning', 'surface-raised', 5.31, 7.52, 4.5),
  ('feedback-on-error-surface', 'feedback-error-surface', 8.47, 12.03, 4.5),
  ('feedback-on-warning-surface', 'feedback-warning-surface', 7.70, 11.49, 4.5),
  ('line-control', 'surface-page', 3.70, 4.44, 3.0),
  ('line-control', 'surface-raised', 3.96, 3.63, 3.0),
  ('line-control', 'surface-sunken', 3.41, 4.81, 3.0),
  ('state-draft', 'surface-page', 3.70, 6.59, 3.0),
  ('state-draft', 'surface-raised', 3.96, 5.40, 3.0),
  ('line-focus', 'surface-page', 16.40, 16.40, 3.0),
  ('line-focus', 'surface-raised', 17.57, 13.43, 3.0),
];

/// Bewusst unter dem Mindestwert (01): (Vordergrund, Hintergrund, hell, dunkel).
const _exempt = [
  ('marker', 'surface-page', 1.19, 11.53),
  ('line-dot', 'surface-page', 1.24, 1.22),
];

void main() {
  for (final (mode, tokens) in [('hell', AppColorTokens.light), ('dunkel', AppColorTokens.dark)]) {
    final byName = tokens.byFigmaName;
    Color c(String role) => byName['color/$role']!;
    final light = mode == 'hell';

    test('DS-05: Kontraste der Paare aus 01-farbe ($mode)', () {
      final failures = <String>[];
      for (final (fg, bg, valueLight, valueDark, minimum) in _pairs) {
        final ratio = contrast(c(fg), c(bg));
        final documented = light ? valueLight : valueDark;
        if (ratio < minimum) failures.add('$fg auf $bg: ${ratio.toStringAsFixed(2)} < $minimum');
        if ((ratio - documented).abs() > 0.01) {
          failures.add('$fg auf $bg: ${ratio.toStringAsFixed(2)} statt $documented laut 01');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('DS-05: dokumentierte Ausnahmen ($mode)', () {
      for (final (fg, bg, valueLight, valueDark) in _exempt) {
        expect(contrast(c(fg), c(bg)), closeTo(light ? valueLight : valueDark, 0.01), reason: '$fg auf $bg');
      }
    });
  }

  test('DS-05: Kontrastformel stimmt', () {
    expect(contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(contrast(const Color(0xFF777777), const Color(0xFF777777)), 1);
  });
}
