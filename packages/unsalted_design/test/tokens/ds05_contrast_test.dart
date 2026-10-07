// test/tokens/ds05_contrast_test.dart
//
// DS-05 (Teil 1.2): Text auf Fläche erreicht in beiden Modi mindestens 4,5:1
// (WCAG 2.1 AA, normale Schrift). Ansatz aus `test/theme/contrast_test.dart`
// auf `design/1.1`, hier gegen die Tokens statt gegen App-Farben.

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

/// Text-auf-Fläche-Paare (Text, Fläche) mit Figma-Namen.
Map<String, (Color, Color)> textPairs(AppColorTokens t) => {
      'on-primary / primary': (t.onPrimary, t.primary),
      'on-primary-container / primary-container': (t.onPrimaryContainer, t.primaryContainer),
      'on-secondary / secondary': (t.onSecondary, t.secondary),
      'on-secondary-container / secondary-container': (t.onSecondaryContainer, t.secondaryContainer),
      'on-tertiary / tertiary': (t.onTertiary, t.tertiary),
      'on-tertiary-container / tertiary-container': (t.onTertiaryContainer, t.tertiaryContainer),
      'on-error / error': (t.onError, t.error),
      'on-error-container / error-container': (t.onErrorContainer, t.errorContainer),
      'on-primary-fixed / primary-fixed': (t.onPrimaryFixed, t.primaryFixed),
      'on-secondary-fixed / secondary-fixed': (t.onSecondaryFixed, t.secondaryFixed),
      'on-tertiary-fixed / tertiary-fixed': (t.onTertiaryFixed, t.tertiaryFixed),
      'on-inverse-surface / inverse-surface': (t.onInverseSurface, t.inverseSurface),
      'inverse-primary / inverse-surface': (t.inversePrimary, t.inverseSurface),
      for (final (name, surface) in [
        ('surface', t.surface),
        ('surface-dim', t.surfaceDim),
        ('surface-bright', t.surfaceBright),
        ('surface-container-lowest', t.surfaceContainerLowest),
        ('surface-container-low', t.surfaceContainerLow),
        ('surface-container', t.surfaceContainer),
        ('surface-container-high', t.surfaceContainerHigh),
        ('surface-container-highest', t.surfaceContainerHighest),
      ]) ...{
        'on-surface / $name': (t.onSurface, surface),
        'on-surface-variant / $name': (t.onSurfaceVariant, surface),
        'primary / $name': (t.primary, surface),
        'error / $name': (t.error, surface),
      },
    };

void main() {
  for (final (mode, tokens) in [('hell', AppColorTokens.light), ('dunkel', AppColorTokens.dark)]) {
    test('DS-05: Kontrast ≥ 4,5:1 ($mode)', () {
      final failures = <String>[
        for (final MapEntry(key: name, value: (text, surface)) in textPairs(tokens).entries)
          if (contrast(text, surface) < 4.5) '$name: ${contrast(text, surface).toStringAsFixed(2)}:1',
      ];
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }

  test('DS-05: Kontrastformel stimmt', () {
    expect(contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(contrast(const Color(0xFF777777), const Color(0xFF777777)), 1);
  });
}
