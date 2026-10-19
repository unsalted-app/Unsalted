// lib/src/theme/app_theme.dart
//
// Theme (Teil 1.2, seit Teil 1.3 D03 aus der Figma-Übergabe): `ThemeData`
// ausschließlich aus den generierten Tokens. Material-Widgets lesen die 46
// Rollen des `ColorScheme` und die 15 Rollen des `TextTheme`; beide werden
// hier nach den Tabellen „Abbildung auf Material 3“
// (docs/design/system/01-farbe.md) und „Zuordnung zu Material 3“
// (02-typografie.md) auf die 28 Farbrollen und elf Textstile abgebildet —
// so zeigt kein Widget unbemerkt Platzhalter-Lila. DS-07 prüft die Zuordnung.
// Seit D04 dazu die Komponenten-Themes aus `component_themes.dart` (DS-52);
// Dichte und Tippziele fest, damit Maße auf allen Plattformen den Tokens
// entsprechen.

import 'package:flutter/material.dart';

import '../tokens/color_tokens.g.dart';
import '../tokens/typography_tokens.g.dart';
import 'app_fonts.dart';
import 'component_themes.dart';

/// Die Themes der App.
abstract final class AppTheme {
  /// Helles Theme (Figma-Modus `light`).
  static ThemeData light() => _build(AppColorTokens.light);

  /// Dunkles Theme (Figma-Modus `dark`).
  static ThemeData dark() => _build(AppColorTokens.dark);

  static ThemeData _build(AppColorTokens c) {
    final themes = AppComponentThemes(c);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeOf(c),
      textTheme: textTheme,
      fontFamily: AppFonts.qualifiedFamily,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      elevatedButtonTheme: themes.elevatedButton,
      outlinedButtonTheme: themes.outlinedButton,
      textButtonTheme: themes.textButton,
      iconButtonTheme: themes.iconButton,
      floatingActionButtonTheme: themes.fab,
      inputDecorationTheme: themes.input,
      chipTheme: themes.chip,
      listTileTheme: themes.listTile,
      dividerTheme: themes.divider,
      dividerColor: c.lineHairline,
      snackBarTheme: themes.snackBar,
      dialogTheme: themes.dialog,
      popupMenuTheme: themes.popupMenu,
      cardTheme: themes.card,
      progressIndicatorTheme: themes.progress,
      appBarTheme: themes.appBar,
      navigationBarTheme: themes.navigationBar,
      tooltipTheme: themes.tooltip,
    );
  }

  /// Material-Farbrollen nach 01-farbe, „Abbildung auf Material 3“.
  static ColorScheme colorSchemeOf(AppColorTokens c) {
    final dark = c.brightness == Brightness.dark;
    return ColorScheme(
      brightness: c.brightness,
      primary: c.actionPrimary,
      onPrimary: c.actionOnPrimary,
      primaryContainer: c.marker,
      onPrimaryContainer: c.textOnMarker,
      primaryFixed: c.marker,
      primaryFixedDim: c.marker,
      onPrimaryFixed: c.textOnMarker,
      onPrimaryFixedVariant: c.textOnMarker,
      secondary: c.textSecondary,
      onSecondary: c.textInverse,
      secondaryContainer: dark ? c.surfaceRaised : c.surfaceSunken,
      onSecondaryContainer: c.textPrimary,
      secondaryFixed: AppColorPrimitives.neutral100,
      secondaryFixedDim: AppColorPrimitives.neutral150,
      onSecondaryFixed: AppColorPrimitives.neutral900,
      onSecondaryFixedVariant: AppColorPrimitives.neutral600,
      tertiary: c.textWarning,
      onTertiary: dark ? AppColorPrimitives.neutral900 : c.textInverse,
      tertiaryContainer: c.feedbackWarningSurface,
      onTertiaryContainer: c.feedbackOnWarningSurface,
      tertiaryFixed: AppColorPrimitives.orange100,
      tertiaryFixedDim: AppColorPrimitives.orange300,
      onTertiaryFixed: AppColorPrimitives.orange800,
      onTertiaryFixedVariant: AppColorPrimitives.orange700,
      error: c.textError,
      onError: dark ? AppColorPrimitives.neutral900 : c.textInverse,
      errorContainer: c.feedbackErrorSurface,
      onErrorContainer: c.feedbackOnErrorSurface,
      surface: c.surfacePage,
      surfaceBright: dark ? c.surfaceRaised : AppColorPrimitives.neutral0,
      surfaceDim: c.surfaceSunken,
      surfaceContainerLowest: dark ? c.surfaceSunken : c.surfaceRaised,
      surfaceContainerLow: c.surfaceRaised,
      surfaceContainer: c.surfaceRaised,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: dark ? c.surfaceRaised : c.surfaceSunken,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.lineControl,
      outlineVariant: c.lineHairline,
      shadow: c.scrim,
      scrim: c.scrim,
      inverseSurface: c.surfaceInverse,
      onInverseSurface: c.textInverse,
      inversePrimary: c.actionInverse,
      surfaceTint: c.surfacePage,
    );
  }

  /// Material-Textrollen nach 02-typografie, „Zuordnung zu Material 3“.
  static const textTheme = TextTheme(
    displayLarge: AppTypography.display,
    displayMedium: AppTypography.display,
    displaySmall: AppTypography.display,
    headlineLarge: AppTypography.display,
    headlineMedium: AppTypography.titlePage,
    headlineSmall: AppTypography.titlePage,
    titleLarge: AppTypography.titlePage,
    titleMedium: AppTypography.bodyStrong,
    titleSmall: AppTypography.bodyStrong,
    labelLarge: AppTypography.bodyStrong,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body,
    bodySmall: AppTypography.caption,
    labelMedium: AppTypography.labelSmall,
    labelSmall: AppTypography.labelSmall,
  );
}
