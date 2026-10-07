// lib/src/tokens/color_tokens.dart
//
// Farb-Tokens (Teil 1.2). Figma-Sammlung `color` mit den Modi `light` und
// `dark`; Dart-Name = Figma-Pfad ohne Gruppe in camelCase. Platzhalterwerte
// sind die Material-3-Standardfarben, die `ThemeData()` in Flutter 3.47.5
// erzeugt (`_colorSchemeLightM3`/`_colorSchemeDarkM3` in
// `material/theme_data.dart`), ohne die veralteten Rollen `background`,
// `onBackground` und `surfaceVariant`. Einzige Stelle mit Farbwerten (DS-02).

import 'package:flutter/material.dart';

/// Farb-Tokens eines Modus.
@immutable
class AppColorTokens {
  /// Erzeugt einen vollständigen Satz Farb-Tokens.
  const AppColorTokens({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceDim,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.surfaceTint,
  });

  /// Hell oder dunkel.
  final Brightness brightness;

  /// `color/primary`
  final Color primary;

  /// `color/on-primary`
  final Color onPrimary;

  /// `color/primary-container`
  final Color primaryContainer;

  /// `color/on-primary-container`
  final Color onPrimaryContainer;

  /// `color/primary-fixed`
  final Color primaryFixed;

  /// `color/primary-fixed-dim`
  final Color primaryFixedDim;

  /// `color/on-primary-fixed`
  final Color onPrimaryFixed;

  /// `color/on-primary-fixed-variant`
  final Color onPrimaryFixedVariant;

  /// `color/secondary`
  final Color secondary;

  /// `color/on-secondary`
  final Color onSecondary;

  /// `color/secondary-container`
  final Color secondaryContainer;

  /// `color/on-secondary-container`
  final Color onSecondaryContainer;

  /// `color/secondary-fixed`
  final Color secondaryFixed;

  /// `color/secondary-fixed-dim`
  final Color secondaryFixedDim;

  /// `color/on-secondary-fixed`
  final Color onSecondaryFixed;

  /// `color/on-secondary-fixed-variant`
  final Color onSecondaryFixedVariant;

  /// `color/tertiary`
  final Color tertiary;

  /// `color/on-tertiary`
  final Color onTertiary;

  /// `color/tertiary-container`
  final Color tertiaryContainer;

  /// `color/on-tertiary-container`
  final Color onTertiaryContainer;

  /// `color/tertiary-fixed`
  final Color tertiaryFixed;

  /// `color/tertiary-fixed-dim`
  final Color tertiaryFixedDim;

  /// `color/on-tertiary-fixed`
  final Color onTertiaryFixed;

  /// `color/on-tertiary-fixed-variant`
  final Color onTertiaryFixedVariant;

  /// `color/error`
  final Color error;

  /// `color/on-error`
  final Color onError;

  /// `color/error-container`
  final Color errorContainer;

  /// `color/on-error-container`
  final Color onErrorContainer;

  /// `color/surface`
  final Color surface;

  /// `color/surface-bright`
  final Color surfaceBright;

  /// `color/surface-container-lowest`
  final Color surfaceContainerLowest;

  /// `color/surface-container-low`
  final Color surfaceContainerLow;

  /// `color/surface-container`
  final Color surfaceContainer;

  /// `color/surface-container-high`
  final Color surfaceContainerHigh;

  /// `color/surface-container-highest`
  final Color surfaceContainerHighest;

  /// `color/surface-dim`
  final Color surfaceDim;

  /// `color/on-surface`
  final Color onSurface;

  /// `color/on-surface-variant`
  final Color onSurfaceVariant;

  /// `color/outline`
  final Color outline;

  /// `color/outline-variant`
  final Color outlineVariant;

  /// `color/shadow`
  final Color shadow;

  /// `color/scrim`
  final Color scrim;

  /// `color/inverse-surface`
  final Color inverseSurface;

  /// `color/on-inverse-surface`
  final Color onInverseSurface;

  /// `color/inverse-primary`
  final Color inversePrimary;

  /// `color/surface-tint`
  final Color surfaceTint;

  /// Modus `light`.
  static const light = AppColorTokens(
    brightness: Brightness.light,
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF4F378B),
    primaryFixed: Color(0xFFEADDFF),
    primaryFixedDim: Color(0xFFD0BCFF),
    onPrimaryFixed: Color(0xFF21005D),
    onPrimaryFixedVariant: Color(0xFF4F378B),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF4A4458),
    secondaryFixed: Color(0xFFE8DEF8),
    secondaryFixedDim: Color(0xFFCCC2DC),
    onSecondaryFixed: Color(0xFF1D192B),
    onSecondaryFixedVariant: Color(0xFF4A4458),
    tertiary: Color(0xFF7D5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF633B48),
    tertiaryFixed: Color(0xFFFFD8E4),
    tertiaryFixedDim: Color(0xFFEFB8C8),
    onTertiaryFixed: Color(0xFF31111D),
    onTertiaryFixedVariant: Color(0xFF633B48),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF8C1D18),
    surface: Color(0xFFFEF7FF),
    surfaceBright: Color(0xFFFEF7FF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F2FA),
    surfaceContainer: Color(0xFFF3EDF7),
    surfaceContainerHigh: Color(0xFFECE6F0),
    surfaceContainerHighest: Color(0xFFE6E0E9),
    surfaceDim: Color(0xFFDED8E1),
    onSurface: Color(0xFF1D1B20),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF322F35),
    onInverseSurface: Color(0xFFF5EFF7),
    inversePrimary: Color(0xFFD0BCFF),
    surfaceTint: Color(0xFF6750A4),
  );

  /// Modus `dark`.
  static const dark = AppColorTokens(
    brightness: Brightness.dark,
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),
    primaryFixed: Color(0xFFEADDFF),
    primaryFixedDim: Color(0xFFD0BCFF),
    onPrimaryFixed: Color(0xFF21005D),
    onPrimaryFixedVariant: Color(0xFF4F378B),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),
    secondaryFixed: Color(0xFFE8DEF8),
    secondaryFixedDim: Color(0xFFCCC2DC),
    onSecondaryFixed: Color(0xFF1D192B),
    onSecondaryFixedVariant: Color(0xFF4A4458),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),
    tertiaryFixed: Color(0xFFFFD8E4),
    tertiaryFixedDim: Color(0xFFEFB8C8),
    onTertiaryFixed: Color(0xFF31111D),
    onTertiaryFixedVariant: Color(0xFF633B48),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF141218),
    surfaceBright: Color(0xFF3B383E),
    surfaceContainerLowest: Color(0xFF0F0D13),
    surfaceContainerLow: Color(0xFF1D1B20),
    surfaceContainer: Color(0xFF211F26),
    surfaceContainerHigh: Color(0xFF2B2930),
    surfaceContainerHighest: Color(0xFF36343B),
    surfaceDim: Color(0xFF141218),
    onSurface: Color(0xFFE6E0E9),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E0E9),
    onInverseSurface: Color(0xFF322F35),
    inversePrimary: Color(0xFF6750A4),
    surfaceTint: Color(0xFFD0BCFF),
  );

  /// Alle Rollen mit ihrem Figma-Namen, in fester Reihenfolge.
  Map<String, Color> get byFigmaName => {
        'color/primary': primary,
        'color/on-primary': onPrimary,
        'color/primary-container': primaryContainer,
        'color/on-primary-container': onPrimaryContainer,
        'color/primary-fixed': primaryFixed,
        'color/primary-fixed-dim': primaryFixedDim,
        'color/on-primary-fixed': onPrimaryFixed,
        'color/on-primary-fixed-variant': onPrimaryFixedVariant,
        'color/secondary': secondary,
        'color/on-secondary': onSecondary,
        'color/secondary-container': secondaryContainer,
        'color/on-secondary-container': onSecondaryContainer,
        'color/secondary-fixed': secondaryFixed,
        'color/secondary-fixed-dim': secondaryFixedDim,
        'color/on-secondary-fixed': onSecondaryFixed,
        'color/on-secondary-fixed-variant': onSecondaryFixedVariant,
        'color/tertiary': tertiary,
        'color/on-tertiary': onTertiary,
        'color/tertiary-container': tertiaryContainer,
        'color/on-tertiary-container': onTertiaryContainer,
        'color/tertiary-fixed': tertiaryFixed,
        'color/tertiary-fixed-dim': tertiaryFixedDim,
        'color/on-tertiary-fixed': onTertiaryFixed,
        'color/on-tertiary-fixed-variant': onTertiaryFixedVariant,
        'color/error': error,
        'color/on-error': onError,
        'color/error-container': errorContainer,
        'color/on-error-container': onErrorContainer,
        'color/surface': surface,
        'color/surface-bright': surfaceBright,
        'color/surface-container-lowest': surfaceContainerLowest,
        'color/surface-container-low': surfaceContainerLow,
        'color/surface-container': surfaceContainer,
        'color/surface-container-high': surfaceContainerHigh,
        'color/surface-container-highest': surfaceContainerHighest,
        'color/surface-dim': surfaceDim,
        'color/on-surface': onSurface,
        'color/on-surface-variant': onSurfaceVariant,
        'color/outline': outline,
        'color/outline-variant': outlineVariant,
        'color/shadow': shadow,
        'color/scrim': scrim,
        'color/inverse-surface': inverseSurface,
        'color/on-inverse-surface': onInverseSurface,
        'color/inverse-primary': inversePrimary,
        'color/surface-tint': surfaceTint,
      };

  /// Das `ColorScheme` aus diesen Tokens.
  ColorScheme toColorScheme() => ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        primaryFixed: primaryFixed,
        primaryFixedDim: primaryFixedDim,
        onPrimaryFixed: onPrimaryFixed,
        onPrimaryFixedVariant: onPrimaryFixedVariant,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        secondaryFixed: secondaryFixed,
        secondaryFixedDim: secondaryFixedDim,
        onSecondaryFixed: onSecondaryFixed,
        onSecondaryFixedVariant: onSecondaryFixedVariant,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        tertiaryFixed: tertiaryFixed,
        tertiaryFixedDim: tertiaryFixedDim,
        onTertiaryFixed: onTertiaryFixed,
        onTertiaryFixedVariant: onTertiaryFixedVariant,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        surfaceBright: surfaceBright,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceDim: surfaceDim,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: shadow,
        scrim: scrim,
        inverseSurface: inverseSurface,
        onInverseSurface: onInverseSurface,
        inversePrimary: inversePrimary,
        surfaceTint: surfaceTint,
      );
}
