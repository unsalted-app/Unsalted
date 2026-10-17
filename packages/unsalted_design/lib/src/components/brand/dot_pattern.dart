// lib/src/components/brand/dot_pattern.dart
//
// Punktraster (Teil 1.3, D07): „hier ist noch Platz“ — nur auf leeren
// Flächen (Leerstelle), nie hinter Inhalt (Markenelemente, Frame-Karte).
// Punkte `size-dot` in `line-dot`, Abstand `space-xl`, der erste Punkt
// `space-l` von der Kante (wie `Punktraster.svg` im Figma-Startpaket).
// Rein dekorativ, ohne Semantik. Nicht exportiert.

import 'package:flutter/widgets.dart';

import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';

/// Malt das Punktraster über die ganze Fläche.
class DotPatternPainter extends CustomPainter {
  /// Punktraster in [color].
  const DotPatternPainter({required this.color});

  /// Farbe der Punkte (`line-dot`).
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const radius = AppSize.dot / 2;
    for (var y = AppSpacing.l; y < size.height; y += AppSpacing.xl) {
      for (var x = AppSpacing.l; x < size.width; x += AppSpacing.xl) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotPatternPainter old) => old.color != color;
}
