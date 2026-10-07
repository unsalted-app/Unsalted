// lib/src/theme/app_theme.dart
//
// Theme (Teil 1.2): `ThemeData` ausschließlich aus Tokens — Farben aus
// `AppColorTokens`, Typo aus `AppTypography`. Solange die Tokens den
// Flutter-Standard tragen, sieht die App aus wie mit `ThemeData()` (DS-07).
// Komponenten-Themes kommen erst hinzu, wenn das Figma-Design sie festlegt.

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Die Themes der App.
abstract final class AppTheme {
  /// Helles Theme (Figma-Modus `light`).
  static ThemeData light() => _build(AppColorTokens.light);

  /// Dunkles Theme (Figma-Modus `dark`).
  static ThemeData dark() => _build(AppColorTokens.dark);

  static ThemeData _build(AppColorTokens colors) => ThemeData(
        useMaterial3: true,
        colorScheme: colors.toColorScheme(),
        textTheme: AppTypography.textTheme,
      );
}
