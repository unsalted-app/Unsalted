// lib/src/tokens/radius_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppe `radius`.

/// Eckenradien.
///
/// Kanten statt Kapseln: kleine Radien, keine Pillen außer Schalter und Avatare.
abstract final class AppRadius {
  /// `radius/none`
  static const double none = 0;

  /// `radius/xs`
  static const double xs = 2;

  /// `radius/s`
  static const double s = 4;

  /// `radius/m`
  static const double m = 8;

  /// `radius/full`
  static const double full = 9999;

  /// Alle Werte mit ihrem Figma-Namen.
  static const byFigmaName = <String, double>{
    'radius/none': none,
    'radius/xs': xs,
    'radius/s': s,
    'radius/m': m,
    'radius/full': full,
  };
}
