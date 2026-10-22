// lib/src/tokens/opacity_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppe `opacity`.

/// Deckkraft der Zustandsebenen (0 bis 1; in Figma in Prozent).
///
/// Zustandsebenen statt eigener Farben.
abstract final class AppOpacity {
  /// `opacity/hover`
  static const double hover = 0.06;

  /// `opacity/pressed`
  static const double pressed = 0.12;

  /// `opacity/scrim`
  static const double scrim = 0.48;

  /// `opacity/selection`
  static const double selection = 0.4;

  /// Alle Werte mit ihrem Figma-Namen.
  static const byFigmaName = <String, double>{
    'opacity/hover': hover,
    'opacity/pressed': pressed,
    'opacity/scrim': scrim,
    'opacity/selection': selection,
  };
}
