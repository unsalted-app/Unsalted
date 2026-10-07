// lib/src/tokens/breakpoint_tokens.dart
//
// Breakpoint-Tokens (Teil 1.2), Figma-Variablen `breakpoint/<stufe>`: untere
// Grenzen der Material-Fenstergrößen in logischen Pixeln. Unter `medium` ist
// das Fenster kompakt (Handy).

/// Fensterbreiten-Grenzen.
abstract final class AppBreakpoints {
  /// `breakpoint/medium` — ab hier mittel (kleines Tablet, Handy quer).
  static const double medium = 600;

  /// `breakpoint/expanded` — ab hier erweitert (Tablet).
  static const double expanded = 840;

  /// `breakpoint/large` — ab hier groß (Desktop).
  static const double large = 1200;

  /// Alle Grenzen mit ihrem Figma-Namen.
  static const byFigmaName = {
    'breakpoint/medium': medium,
    'breakpoint/expanded': expanded,
    'breakpoint/large': large,
  };
}
