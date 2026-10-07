// lib/src/tokens/elevation_tokens.dart
//
// Höhen-Tokens (Teil 1.2), Figma-Variablen `elevation/level0` … `level5`
// nach Material 3 (dp). Schatten und Tönung leitet Flutter aus Höhe und
// `shadow`/`surfaceTint` der Farb-Tokens ab.

/// Höhenstufen.
abstract final class AppElevation {
  /// `elevation/level0`
  static const double level0 = 0;

  /// `elevation/level1`
  static const double level1 = 1;

  /// `elevation/level2`
  static const double level2 = 3;

  /// `elevation/level3`
  static const double level3 = 6;

  /// `elevation/level4`
  static const double level4 = 8;

  /// `elevation/level5`
  static const double level5 = 12;

  /// Alle Stufen mit ihrem Figma-Namen.
  static const byFigmaName = {
    'elevation/level0': level0,
    'elevation/level1': level1,
    'elevation/level2': level2,
    'elevation/level3': level3,
    'elevation/level4': level4,
    'elevation/level5': level5,
  };
}
