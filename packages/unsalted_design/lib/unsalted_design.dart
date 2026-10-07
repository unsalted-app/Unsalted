/// Öffentliche Tür des Design-Systems von unsalted (Teil 1.2).
///
/// Enthält ausschließlich Aussehen: Tokens, Theme, Layout, Komponenten und
/// Templates. Keine Fachbegriffe, keine Abhängigkeit außer Flutter
/// (`architecture.yaml`, Rang 0). Jeder Export nennt seine Symbole mit
/// `show`; die Liste prüft DS-03 gegen `test/architecture/public_api_golden.txt`.
library;

// Tokens
export 'src/tokens/breakpoint_tokens.dart' show AppBreakpoints;
export 'src/tokens/color_tokens.dart' show AppColorTokens;
export 'src/tokens/elevation_tokens.dart' show AppElevation;
export 'src/tokens/motion_tokens.dart' show AppMotion;
export 'src/tokens/radius_tokens.dart' show AppRadius;
export 'src/tokens/spacing_tokens.dart' show AppSpacing;
export 'src/tokens/typography_tokens.dart' show AppTypography;

// Theme
export 'src/theme/app_theme.dart' show AppTheme;
