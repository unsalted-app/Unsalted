// lib/src/tokens/stroke_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppe `stroke`.

/// Linienstärken und Strichmuster.
///
/// Linie trägt Bedeutung: gestrichelt = vorläufig, durchgezogen = fest.
abstract final class AppStroke {
  /// `stroke/hairline`
  static const double hairline = 1;

  /// `stroke/frame`
  static const double frame = 1.5;

  /// `stroke/focus`
  static const double focus = 2;

  /// `stroke/rule`
  static const double rule = 3;

  /// `stroke/dash`
  static const double dash = 4;

  /// `stroke/gap`
  static const double gap = 3;

  /// Alle Werte mit ihrem Figma-Namen.
  static const byFigmaName = <String, double>{
    'stroke/hairline': hairline,
    'stroke/frame': frame,
    'stroke/focus': focus,
    'stroke/rule': rule,
    'stroke/dash': dash,
    'stroke/gap': gap,
  };
}
