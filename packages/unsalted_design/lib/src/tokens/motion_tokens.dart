// lib/src/tokens/motion_tokens.dart
//
// Bewegungs-Tokens (Teil 1.2), Figma-Variablen `motion/duration/<stufe>` und
// `motion/easing/<kurve>`. Verlangt das System „Bewegung reduzieren“
// (`MediaQuery.disableAnimations`), liefert `durationOf` 0 — übernommen aus
// `ui/shared/motion.dart` auf `design/1.1`.

import 'package:flutter/material.dart';

/// Dauern und Kurven für Animationen.
abstract final class AppMotion {
  /// `motion/duration/short`
  static const short = Duration(milliseconds: 150);

  /// `motion/duration/medium`
  static const medium = Duration(milliseconds: 250);

  /// `motion/duration/long`
  static const long = Duration(milliseconds: 400);

  /// `motion/easing/standard`
  static const Curve standard = Easing.standard;

  /// `motion/easing/emphasized`
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// `true`, wenn das System „Bewegung reduzieren“ verlangt.
  static bool reduceMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  /// [duration] oder 0, wenn das System „Bewegung reduzieren“ verlangt.
  static Duration durationOf(BuildContext context, [Duration duration = medium]) =>
      reduceMotion(context) ? Duration.zero : duration;
}
