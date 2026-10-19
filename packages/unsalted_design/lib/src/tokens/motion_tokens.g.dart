// lib/src/tokens/motion_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppen `duration` und `easing`; dazu die feste
// Vorlage für „Bewegung reduzieren“ (`durationOf`).

import 'package:flutter/widgets.dart';

/// Dauern und Kurven für Animationen. Unverändert aus `AppMotion`. Bei „Bewegung reduzieren“ immer 0.
abstract final class AppMotion {
  /// `motion/duration/short`
  static const short = Duration(milliseconds: 150);

  /// `motion/duration/medium`
  static const medium = Duration(milliseconds: 250);

  /// `motion/duration/long`
  static const long = Duration(milliseconds: 400);

  /// `motion/easing/standard`
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// `motion/easing/emphasized` — laut Token-Datei (Hinweis zu `easing`)
  /// nur im Code und bis zur ersten Verwendung behalten.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// `true`, wenn das System „Bewegung reduzieren“ verlangt.
  static bool reduceMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  /// [duration] oder 0, wenn das System „Bewegung reduzieren“ verlangt.
  static Duration durationOf(BuildContext context, [Duration duration = medium]) =>
      reduceMotion(context) ? Duration.zero : duration;

  /// Alle Dauern mit ihrem Figma-Namen.
  static const byFigmaName = <String, Duration>{
    'motion/duration/short': short,
    'motion/duration/medium': medium,
    'motion/duration/long': long,
  };
}
