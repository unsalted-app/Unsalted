// lib/src/tokens/radius_tokens.dart
//
// Eckenradius-Tokens (Teil 1.2), Figma-Variablen `radius/<stufe>` in
// logischen Pixeln; Stufen nach der Material-3-Formskala.

/// Eckenradien.
abstract final class AppRadius {
  /// `radius/none`
  static const double none = 0;

  /// `radius/xs`
  static const double xs = 4;

  /// `radius/s`
  static const double s = 8;

  /// `radius/m`
  static const double m = 12;

  /// `radius/l`
  static const double l = 16;

  /// `radius/xl`
  static const double xl = 28;

  /// `radius/full` — voll gerundet (Pille, Kreis).
  static const double full = 9999;

  /// Alle Stufen mit ihrem Figma-Namen.
  static const byFigmaName = {
    'radius/none': none,
    'radius/xs': xs,
    'radius/s': s,
    'radius/m': m,
    'radius/l': l,
    'radius/xl': xl,
    'radius/full': full,
  };
}
