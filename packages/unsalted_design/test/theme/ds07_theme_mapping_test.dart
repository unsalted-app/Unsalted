// test/theme/ds07_theme_mapping_test.dart
//
// DS-07 (Teil 1.2 „neutral“, neu gefasst in Teil 1.3 D03): Das Theme folgt
// den Zuordnungstabellen der Übergabe — jede der 46 Material-Farbrollen trägt
// die Rolle bzw. das Primitiv aus docs/design/system/01-farbe.md („Abbildung
// auf Material 3“), jede der 15 Material-Textrollen den Stil aus
// 02-typografie.md („Zuordnung zu Material 3“). Ersetzt den Vergleich mit
// `ThemeData()` aus Teil 1.2, der laut design_system.md bis zum
// Figma-Design befristet war.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Material-Rolle → (Quelle hell, Quelle dunkel); Quelle ist eine Rolle
/// `color/…` oder ein Primitiv `primitives/…` (01-farbe).
const _colorTable = <String, (String, String)>{
  'primary': ('color/action-primary', 'color/action-primary'),
  'onPrimary': ('color/action-on-primary', 'color/action-on-primary'),
  'primaryContainer': ('color/marker', 'color/marker'),
  'onPrimaryContainer': ('color/text-on-marker', 'color/text-on-marker'),
  'primaryFixed': ('color/marker', 'color/marker'),
  'primaryFixedDim': ('color/marker', 'color/marker'),
  'onPrimaryFixed': ('color/text-on-marker', 'color/text-on-marker'),
  'onPrimaryFixedVariant': ('color/text-on-marker', 'color/text-on-marker'),
  'secondary': ('color/text-secondary', 'color/text-secondary'),
  'onSecondary': ('color/text-inverse', 'color/text-inverse'),
  'secondaryContainer': ('color/surface-sunken', 'color/surface-raised'),
  'onSecondaryContainer': ('color/text-primary', 'color/text-primary'),
  'secondaryFixed': ('primitives/neutral/100', 'primitives/neutral/100'),
  'secondaryFixedDim': ('primitives/neutral/150', 'primitives/neutral/150'),
  'onSecondaryFixed': ('primitives/neutral/900', 'primitives/neutral/900'),
  'onSecondaryFixedVariant': ('primitives/neutral/600', 'primitives/neutral/600'),
  'tertiary': ('color/text-warning', 'color/text-warning'),
  'onTertiary': ('color/text-inverse', 'primitives/neutral/900'),
  'tertiaryContainer': ('color/feedback-warning-surface', 'color/feedback-warning-surface'),
  'onTertiaryContainer': ('color/feedback-on-warning-surface', 'color/feedback-on-warning-surface'),
  'tertiaryFixed': ('primitives/orange/100', 'primitives/orange/100'),
  'tertiaryFixedDim': ('primitives/orange/300', 'primitives/orange/300'),
  'onTertiaryFixed': ('primitives/orange/800', 'primitives/orange/800'),
  'onTertiaryFixedVariant': ('primitives/orange/700', 'primitives/orange/700'),
  'error': ('color/text-error', 'color/text-error'),
  'onError': ('color/text-inverse', 'primitives/neutral/900'),
  'errorContainer': ('color/feedback-error-surface', 'color/feedback-error-surface'),
  'onErrorContainer': ('color/feedback-on-error-surface', 'color/feedback-on-error-surface'),
  'surface': ('color/surface-page', 'color/surface-page'),
  'surfaceBright': ('primitives/neutral/0', 'color/surface-raised'),
  'surfaceDim': ('color/surface-sunken', 'color/surface-sunken'),
  'surfaceContainerLowest': ('color/surface-raised', 'color/surface-sunken'),
  'surfaceContainerLow': ('color/surface-raised', 'color/surface-raised'),
  'surfaceContainer': ('color/surface-raised', 'color/surface-raised'),
  'surfaceContainerHigh': ('color/surface-raised', 'color/surface-raised'),
  'surfaceContainerHighest': ('color/surface-sunken', 'color/surface-raised'),
  'onSurface': ('color/text-primary', 'color/text-primary'),
  'onSurfaceVariant': ('color/text-secondary', 'color/text-secondary'),
  'outline': ('color/line-control', 'color/line-control'),
  'outlineVariant': ('color/line-hairline', 'color/line-hairline'),
  'shadow': ('color/scrim', 'color/scrim'),
  'scrim': ('color/scrim', 'color/scrim'),
  'inverseSurface': ('color/surface-inverse', 'color/surface-inverse'),
  'onInverseSurface': ('color/text-inverse', 'color/text-inverse'),
  'inversePrimary': ('color/action-inverse', 'color/action-inverse'),
  'surfaceTint': ('color/surface-page', 'color/surface-page'),
};

Map<String, Color> _roles(ColorScheme s) => {
      'primary': s.primary,
      'onPrimary': s.onPrimary,
      'primaryContainer': s.primaryContainer,
      'onPrimaryContainer': s.onPrimaryContainer,
      'primaryFixed': s.primaryFixed,
      'primaryFixedDim': s.primaryFixedDim,
      'onPrimaryFixed': s.onPrimaryFixed,
      'onPrimaryFixedVariant': s.onPrimaryFixedVariant,
      'secondary': s.secondary,
      'onSecondary': s.onSecondary,
      'secondaryContainer': s.secondaryContainer,
      'onSecondaryContainer': s.onSecondaryContainer,
      'secondaryFixed': s.secondaryFixed,
      'secondaryFixedDim': s.secondaryFixedDim,
      'onSecondaryFixed': s.onSecondaryFixed,
      'onSecondaryFixedVariant': s.onSecondaryFixedVariant,
      'tertiary': s.tertiary,
      'onTertiary': s.onTertiary,
      'tertiaryContainer': s.tertiaryContainer,
      'onTertiaryContainer': s.onTertiaryContainer,
      'tertiaryFixed': s.tertiaryFixed,
      'tertiaryFixedDim': s.tertiaryFixedDim,
      'onTertiaryFixed': s.onTertiaryFixed,
      'onTertiaryFixedVariant': s.onTertiaryFixedVariant,
      'error': s.error,
      'onError': s.onError,
      'errorContainer': s.errorContainer,
      'onErrorContainer': s.onErrorContainer,
      'surface': s.surface,
      'surfaceBright': s.surfaceBright,
      'surfaceDim': s.surfaceDim,
      'surfaceContainerLowest': s.surfaceContainerLowest,
      'surfaceContainerLow': s.surfaceContainerLow,
      'surfaceContainer': s.surfaceContainer,
      'surfaceContainerHigh': s.surfaceContainerHigh,
      'surfaceContainerHighest': s.surfaceContainerHighest,
      'onSurface': s.onSurface,
      'onSurfaceVariant': s.onSurfaceVariant,
      'outline': s.outline,
      'outlineVariant': s.outlineVariant,
      'shadow': s.shadow,
      'scrim': s.scrim,
      'inverseSurface': s.inverseSurface,
      'onInverseSurface': s.onInverseSurface,
      'inversePrimary': s.inversePrimary,
      'surfaceTint': s.surfaceTint,
    };

/// Material-Textrolle → Stil (02-typografie).
const _textTable = <String, String>{
  'displayLarge': 'type/display',
  'displayMedium': 'type/display',
  'displaySmall': 'type/display',
  'headlineLarge': 'type/display',
  'headlineMedium': 'type/title-page',
  'headlineSmall': 'type/title-page',
  'titleLarge': 'type/title-page',
  'titleMedium': 'type/body-strong',
  'titleSmall': 'type/body-strong',
  'labelLarge': 'type/body-strong',
  'bodyLarge': 'type/body',
  'bodyMedium': 'type/body',
  'bodySmall': 'type/caption',
  'labelMedium': 'type/label-small',
  'labelSmall': 'type/label-small',
};

Map<String, TextStyle?> _text(TextTheme t) => {
      'displayLarge': t.displayLarge,
      'displayMedium': t.displayMedium,
      'displaySmall': t.displaySmall,
      'headlineLarge': t.headlineLarge,
      'headlineMedium': t.headlineMedium,
      'headlineSmall': t.headlineSmall,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'titleSmall': t.titleSmall,
      'labelLarge': t.labelLarge,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelMedium': t.labelMedium,
      'labelSmall': t.labelSmall,
    };

/// Primitive, die 01 direkt nennt, über die Rollen, die laut Token-Datei auf
/// sie verweisen (Primitive sind nicht über die Tür erreichbar).
final _primitives = <String, Color>{
  'primitives/neutral/0': AppColorTokens.light.surfaceRaised,
  'primitives/neutral/100': AppColorTokens.light.surfaceSunken,
  'primitives/neutral/150': AppColorTokens.light.lineHairline,
  'primitives/neutral/600': AppColorTokens.light.textSecondary,
  'primitives/neutral/900': AppColorTokens.light.textPrimary,
  'primitives/orange/100': AppColorTokens.light.feedbackWarningSurface,
  'primitives/orange/300': AppColorTokens.dark.textWarning,
  'primitives/orange/700': AppColorTokens.light.textWarning,
  'primitives/orange/800': AppColorTokens.light.feedbackOnWarningSurface,
};

Color _source(String name, AppColorTokens tokens) =>
    name.startsWith('color/') ? tokens.byFigmaName[name]! : _primitives[name]!;

/// Rollen von [scheme], die von der Tabelle für [tokens] abweichen.
List<String> _colorDifferences(ColorScheme scheme, AppColorTokens tokens) {
  final light = tokens.brightness == Brightness.light;
  final actual = _roles(scheme);
  return [
    for (final MapEntry(key: role, value: (sourceLight, sourceDark)) in _colorTable.entries)
      if (actual[role] != _source(light ? sourceLight : sourceDark, tokens)) role,
  ];
}

void main() {
  for (final (mode, theme, tokens) in [
    ('hell', AppTheme.light(), AppColorTokens.light),
    ('dunkel', AppTheme.dark(), AppColorTokens.dark),
  ]) {
    test('DS-07: 46 Farbrollen nach 01-farbe ($mode)', () {
      expect(_colorTable, hasLength(46));
      expect(_roles(theme.colorScheme), hasLength(46));
      expect(theme.brightness, tokens.brightness);
      expect(_colorDifferences(theme.colorScheme, tokens), isEmpty);
    });

    test('DS-07: abgeleitete Flächen ($mode)', () {
      expect(theme.scaffoldBackgroundColor, tokens.surfacePage);
      expect(theme.canvasColor, tokens.surfacePage);
      // Trennerfarbe (line-hairline) setzen die Komponenten-Themes (D04, DS-52).
    });

    test('DS-07: 15 Textrollen nach 02-typografie ($mode)', () {
      final actual = _text(theme.textTheme);
      expect(actual, hasLength(15));
      for (final MapEntry(key: role, value: figma) in _textTable.entries) {
        final expected = AppTypography.byFigmaName[figma]!;
        final style = actual[role]!;
        expect(style.fontSize, expected.fontSize, reason: role);
        expect(style.height, expected.height, reason: role);
        expect(style.fontWeight, expected.fontWeight, reason: role);
        expect(style.letterSpacing, expected.letterSpacing, reason: role);
        expect(style.fontFamily, AppFonts.qualifiedFamily, reason: role);
        expect(style.fontFeatures, expected.fontFeatures, reason: role);
      }
    });
  }

  test('DS-07: der Vergleich erkennt Abweichungen', () {
    expect(_colorDifferences(ThemeData().colorScheme, AppColorTokens.light), isNotEmpty);
    expect(_colorDifferences(AppTheme.dark().colorScheme, AppColorTokens.light), isNotEmpty);
  });
}
