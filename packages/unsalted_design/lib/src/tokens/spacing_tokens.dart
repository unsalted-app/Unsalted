// lib/src/tokens/spacing_tokens.dart
//
// Abstands-Tokens (Teil 1.2), Figma-Variablen `space/<stufe>` in logischen
// Pixeln. Die Stufen decken alle Abstände ab, die die Core-Bildschirme heute
// verwenden (4, 8, 12, 16, 32).

/// Abstände.
abstract final class AppSpacing {
  /// `space/xxs`
  static const double xxs = 2;

  /// `space/xs`
  static const double xs = 4;

  /// `space/s`
  static const double s = 8;

  /// `space/m`
  static const double m = 12;

  /// `space/l`
  static const double l = 16;

  /// `space/xl`
  static const double xl = 24;

  /// `space/xxl`
  static const double xxl = 32;

  /// Alle Stufen mit ihrem Figma-Namen.
  static const byFigmaName = {
    'space/xxs': xxs,
    'space/xs': xs,
    'space/s': s,
    'space/m': m,
    'space/l': l,
    'space/xl': xl,
    'space/xxl': xxl,
  };
}
