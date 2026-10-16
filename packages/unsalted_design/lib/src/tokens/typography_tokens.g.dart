// lib/src/tokens/typography_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppe `type`: die elf Textstile (ohne Farbe).
// `sans` ist die gebündelte Schrift (AppFonts), `mono` die Systemschrift aus dem
// Stapel der Token-Datei.

import 'package:flutter/painting.dart';

import '../theme/app_fonts.dart';

/// Textstile. Laufweite überall 0, Zeilenhöhen auf dem 4-px-Raster.
abstract final class AppTypography {
  /// `type/display`: 28px / 36px, 700.
  static const display = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 28,
    height: 1.2857142857142858,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// `type/title-page`: 20px / 28px, 700.
  static const titlePage = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// `type/heading`: 18px / 24px, 700.
  static const heading = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 18,
    height: 1.3333333333333333,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// `type/body`: 16px / 24px, 400.
  static const body = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// `type/body-strong`: 16px / 24px, 600.
  static const bodyStrong = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// `type/body-small`: 14px / 20px, 400.
  static const bodySmall = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 14,
    height: 1.4285714285714286,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// `type/label-small`: 13px / 16px, 600.
  static const labelSmall = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 13,
    height: 1.2307692307692308,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// `type/caption`: 13px / 18px, 400.
  static const caption = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 13,
    height: 1.3846153846153846,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// `type/data`: 16px / 24px, 400.
  static const data = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// `type/data-strong`: 16px / 24px, 700.
  static const dataStrong = TextStyle(
    fontFamily: AppFonts.family,
    package: AppFonts.package,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// `type/code`: 13px / 20px, 400.
  static const code = TextStyle(
    fontFamily: 'ui-monospace',
    fontFamilyFallback: ['SF Mono', 'Menlo', 'Consolas', 'monospace'],
    fontSize: 13,
    height: 1.5384615384615385,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// Alle Stile mit ihrem Figma-Namen, in der Reihenfolge der Token-Datei.
  static const byFigmaName = <String, TextStyle>{
    'type/display': display,
    'type/title-page': titlePage,
    'type/heading': heading,
    'type/body': body,
    'type/body-strong': bodyStrong,
    'type/body-small': bodySmall,
    'type/label-small': labelSmall,
    'type/caption': caption,
    'type/data': data,
    'type/data-strong': dataStrong,
    'type/code': code,
  };
}
