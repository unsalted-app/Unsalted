// lib/src/tokens/shadow_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppe `shadow`: Überlagerung und Fokusring je
// Modus.

import 'package:flutter/widgets.dart';

/// Schatten. Flach: Ebenen trennen sich durch Linien. Schatten nur für Überlagerungen.
abstract final class AppShadow {
  /// `shadow/overlay`, Modus `light`.
  static const overlayLight = <BoxShadow>[
    BoxShadow(offset: Offset(0, 1), blurRadius: 3, spreadRadius: 0, color: Color(0x1F0C1019)),
    BoxShadow(offset: Offset(0, 4), blurRadius: 16, spreadRadius: 0, color: Color(0x290C1019)),
  ];

  /// `shadow/overlay`, Modus `dark`.
  static const overlayDark = <BoxShadow>[
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, spreadRadius: 0, color: Color(0xB3000000)),
  ];

  /// `shadow/overlay` für [brightness].
  static List<BoxShadow> overlay(Brightness brightness) =>
      brightness == Brightness.dark ? overlayDark : overlayLight;

  /// `shadow/focus`, Modus `light`.
  static const focusLight = <BoxShadow>[
    BoxShadow(offset: Offset(0, 0), blurRadius: 0, spreadRadius: 4, color: Color(0xFF141925)),
    BoxShadow(offset: Offset(0, 0), blurRadius: 0, spreadRadius: 2, color: Color(0xFFF9F7F1)),
  ];

  /// `shadow/focus`, Modus `dark`.
  static const focusDark = <BoxShadow>[
    BoxShadow(offset: Offset(0, 0), blurRadius: 0, spreadRadius: 4, color: Color(0xFFF9F7F1)),
    BoxShadow(offset: Offset(0, 0), blurRadius: 0, spreadRadius: 2, color: Color(0xFF141925)),
  ];

  /// `shadow/focus` für [brightness].
  static List<BoxShadow> focus(Brightness brightness) =>
      brightness == Brightness.dark ? focusDark : focusLight;

  /// Alle Schatten mit ihrem Figma-Namen, je Modus.
  static const byFigmaName = <String, ({List<BoxShadow> light, List<BoxShadow> dark})>{
    'shadow/overlay': (light: overlayLight, dark: overlayDark),
    'shadow/focus': (light: focusLight, dark: focusDark),
  };
}
