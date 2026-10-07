// lib/src/tokens/typography_tokens.dart
//
// Typo-Tokens (Teil 1.2). Figma-Textstile `type/<rolle>`; Werte sind die
// Material-3-Typskala aus `Typography.englishLike2021` (Flutter 3.47.5):
// Größe, Schnitt, Zeilenhöhe, Laufweite. Keine Farbe und keine Schriftfamilie
// (Systemschrift) — beides kommt aus dem Theme.

import 'package:flutter/material.dart';

/// Typo-Tokens: die 15 Material-3-Rollen.
abstract final class AppTypography {
  /// `type/display-large`
  static const displayLarge = TextStyle(fontSize: 57, fontWeight: FontWeight.w400, height: 1.12, letterSpacing: -0.25);

  /// `type/display-medium`
  static const displayMedium = TextStyle(fontSize: 45, fontWeight: FontWeight.w400, height: 1.16, letterSpacing: 0);

  /// `type/display-small`
  static const displaySmall = TextStyle(fontSize: 36, fontWeight: FontWeight.w400, height: 1.22, letterSpacing: 0);

  /// `type/headline-large`
  static const headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w400, height: 1.25, letterSpacing: 0);

  /// `type/headline-medium`
  static const headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w400, height: 1.29, letterSpacing: 0);

  /// `type/headline-small`
  static const headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0);

  /// `type/title-large`
  static const titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w400, height: 1.27, letterSpacing: 0);

  /// `type/title-medium`
  static const titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.50, letterSpacing: 0.15);

  /// `type/title-small`
  static const titleSmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1);

  /// `type/label-large`
  static const labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1);

  /// `type/label-medium`
  static const labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5);

  /// `type/label-small`
  static const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5);

  /// `type/body-large`
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.50, letterSpacing: 0.5);

  /// `type/body-medium`
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.25);

  /// `type/body-small`
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4);

  /// Alle Rollen als `TextTheme`.
  static const textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );

  /// Alle Rollen mit ihrem Figma-Namen.
  static const byFigmaName = {
    'type/display-large': displayLarge,
    'type/display-medium': displayMedium,
    'type/display-small': displaySmall,
    'type/headline-large': headlineLarge,
    'type/headline-medium': headlineMedium,
    'type/headline-small': headlineSmall,
    'type/title-large': titleLarge,
    'type/title-medium': titleMedium,
    'type/title-small': titleSmall,
    'type/label-large': labelLarge,
    'type/label-medium': labelMedium,
    'type/label-small': labelSmall,
    'type/body-large': bodyLarge,
    'type/body-medium': bodyMedium,
    'type/body-small': bodySmall,
  };
}
