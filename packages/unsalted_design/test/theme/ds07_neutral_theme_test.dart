// test/theme/ds07_neutral_theme_test.dart
//
// DS-07 (Teil 1.2): Solange die Tokens Platzhalter sind, entspricht
// `AppTheme` dem Flutter-Standard `ThemeData()`: jede nicht veraltete
// Farbrolle, die daraus abgeleiteten Flächenfarben und die Typo nach
// `ThemeData.localize` (so wendet `MaterialApp` das Theme an). Nachweis für
// „Umstellung ohne sichtbare Änderung“; wird mit dem Figma-Design ersetzt.
// `ColorScheme.==` ist bewusst nicht verwendet: Die Tokens führen die
// veraltete Rolle `surfaceVariant` nicht (docs/decisions.md, C03).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Alle 46 Rollen des ColorScheme, nach Figma-Namen.
final Map<String, Color Function(ColorScheme)> _roles = {
  'color/primary': (s) => s.primary,
  'color/on-primary': (s) => s.onPrimary,
  'color/primary-container': (s) => s.primaryContainer,
  'color/on-primary-container': (s) => s.onPrimaryContainer,
  'color/primary-fixed': (s) => s.primaryFixed,
  'color/primary-fixed-dim': (s) => s.primaryFixedDim,
  'color/on-primary-fixed': (s) => s.onPrimaryFixed,
  'color/on-primary-fixed-variant': (s) => s.onPrimaryFixedVariant,
  'color/secondary': (s) => s.secondary,
  'color/on-secondary': (s) => s.onSecondary,
  'color/secondary-container': (s) => s.secondaryContainer,
  'color/on-secondary-container': (s) => s.onSecondaryContainer,
  'color/secondary-fixed': (s) => s.secondaryFixed,
  'color/secondary-fixed-dim': (s) => s.secondaryFixedDim,
  'color/on-secondary-fixed': (s) => s.onSecondaryFixed,
  'color/on-secondary-fixed-variant': (s) => s.onSecondaryFixedVariant,
  'color/tertiary': (s) => s.tertiary,
  'color/on-tertiary': (s) => s.onTertiary,
  'color/tertiary-container': (s) => s.tertiaryContainer,
  'color/on-tertiary-container': (s) => s.onTertiaryContainer,
  'color/tertiary-fixed': (s) => s.tertiaryFixed,
  'color/tertiary-fixed-dim': (s) => s.tertiaryFixedDim,
  'color/on-tertiary-fixed': (s) => s.onTertiaryFixed,
  'color/on-tertiary-fixed-variant': (s) => s.onTertiaryFixedVariant,
  'color/error': (s) => s.error,
  'color/on-error': (s) => s.onError,
  'color/error-container': (s) => s.errorContainer,
  'color/on-error-container': (s) => s.onErrorContainer,
  'color/surface': (s) => s.surface,
  'color/surface-bright': (s) => s.surfaceBright,
  'color/surface-container-lowest': (s) => s.surfaceContainerLowest,
  'color/surface-container-low': (s) => s.surfaceContainerLow,
  'color/surface-container': (s) => s.surfaceContainer,
  'color/surface-container-high': (s) => s.surfaceContainerHigh,
  'color/surface-container-highest': (s) => s.surfaceContainerHighest,
  'color/surface-dim': (s) => s.surfaceDim,
  'color/on-surface': (s) => s.onSurface,
  'color/on-surface-variant': (s) => s.onSurfaceVariant,
  'color/outline': (s) => s.outline,
  'color/outline-variant': (s) => s.outlineVariant,
  'color/shadow': (s) => s.shadow,
  'color/scrim': (s) => s.scrim,
  'color/inverse-surface': (s) => s.inverseSurface,
  'color/on-inverse-surface': (s) => s.onInverseSurface,
  'color/inverse-primary': (s) => s.inversePrimary,
  'color/surface-tint': (s) => s.surfaceTint,
};

List<String> _roleDifferences(ColorScheme actual, ColorScheme expected) => [
      for (final MapEntry(key: name, value: role) in _roles.entries)
        if (role(actual) != role(expected)) name,
    ];

List<String> _textDifferences(TextTheme actual, TextTheme expected) {
  final a = actual.toStyleMap();
  final e = expected.toStyleMap();
  return [
    for (final role in e.keys)
      if (a[role]!.fontSize != e[role]!.fontSize ||
          a[role]!.fontWeight != e[role]!.fontWeight ||
          a[role]!.height != e[role]!.height ||
          a[role]!.letterSpacing != e[role]!.letterSpacing ||
          a[role]!.color != e[role]!.color ||
          a[role]!.fontFamily != e[role]!.fontFamily ||
          a[role]!.leadingDistribution != e[role]!.leadingDistribution)
        role,
  ];
}

extension on TextTheme {
  Map<String, TextStyle> toStyleMap() => {
        'displayLarge': displayLarge!,
        'displayMedium': displayMedium!,
        'displaySmall': displaySmall!,
        'headlineLarge': headlineLarge!,
        'headlineMedium': headlineMedium!,
        'headlineSmall': headlineSmall!,
        'titleLarge': titleLarge!,
        'titleMedium': titleMedium!,
        'titleSmall': titleSmall!,
        'labelLarge': labelLarge!,
        'labelMedium': labelMedium!,
        'labelSmall': labelSmall!,
        'bodyLarge': bodyLarge!,
        'bodyMedium': bodyMedium!,
        'bodySmall': bodySmall!,
      };
}

void main() {
  for (final (mode, theme, reference) in [
    ('hell', AppTheme.light(), ThemeData()),
    ('dunkel', AppTheme.dark(), ThemeData(brightness: Brightness.dark)),
  ]) {
    test('DS-07: Farbrollen entsprechen dem Flutter-Standard ($mode)', () {
      expect(_roles, hasLength(46));
      expect(_roleDifferences(theme.colorScheme, reference.colorScheme), isEmpty);
      expect(theme.brightness, reference.brightness);
    });

    test('DS-07: abgeleitete Flächenfarben entsprechen dem Standard ($mode)', () {
      expect(theme.scaffoldBackgroundColor, reference.scaffoldBackgroundColor);
      expect(theme.canvasColor, reference.canvasColor);
      expect(theme.cardColor, reference.cardColor);
      expect(theme.dividerColor, reference.dividerColor);
      expect(theme.hintColor, reference.hintColor);
      expect(theme.disabledColor, reference.disabledColor);
      expect(theme.primaryColor, reference.primaryColor);
    });

    test('DS-07: Typo entspricht dem Standard ($mode)', () {
      final geometry = Typography.englishLike2021;
      final actual = ThemeData.localize(theme, geometry);
      final expected = ThemeData.localize(reference, geometry);
      expect(_textDifferences(actual.textTheme, expected.textTheme), isEmpty);
      expect(_textDifferences(actual.primaryTextTheme, expected.primaryTextTheme), isEmpty);
    });
  }

  test('DS-07: der Vergleich erkennt Abweichungen', () {
    final other = ThemeData(colorSchemeSeed: const Color(0xFF00AA00));
    expect(_roleDifferences(other.colorScheme, ThemeData().colorScheme), isNotEmpty);
    final bigger = ThemeData(textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20)));
    expect(
      _textDifferences(ThemeData.localize(bigger, Typography.englishLike2021).textTheme,
          ThemeData.localize(ThemeData(), Typography.englishLike2021).textTheme),
      ['bodyMedium'],
    );
  });
}
