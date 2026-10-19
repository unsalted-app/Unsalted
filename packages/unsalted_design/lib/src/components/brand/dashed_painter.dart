// lib/src/components/brand/dashed_painter.dart
//
// Strichlinie (Teil 1.3, D07): „gestrichelt heißt immer noch offen“
// (docs/design/system/README.md). Flutter zeichnet gestrichelte Linien nicht
// selbst; dieser Painter legt das Muster `stroke-dash`/`stroke-gap` entlang
// einer abgerundeten Kontur oder einer Unterstreichung. Kein Zusatzpaket —
// das Design-Paket hängt nur von Flutter ab (Frame-Karte). Nicht exportiert.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../tokens/stroke_tokens.g.dart';

/// Gestrichelte Kontur eines abgerundeten Rechtecks oder gestrichelte Linie
/// am unteren Rand.
class DashedPainter extends CustomPainter {
  /// Kontur mit Eckenradius [radius].
  const DashedPainter.border({required this.color, required this.width, required this.radius}) : underline = false;

  /// Linie am unteren Rand.
  const DashedPainter.underline({required this.color, required this.width})
      : radius = 0,
        underline = true;

  /// Farbe der Striche.
  final Color color;

  /// Strichstärke.
  final double width;

  /// Eckenradius der Kontur.
  final double radius;

  /// `true`: nur eine Linie am unteren Rand.
  final bool underline;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    final half = width / 2;
    final path = underline
        ? (Path()
          ..moveTo(0, size.height - half)
          ..lineTo(size.width, size.height - half))
        : (Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(half, half, size.width - width, size.height - width),
            Radius.circular(radius),
          )));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + AppStroke.dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + AppStroke.gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedPainter old) =>
      old.color != color || old.width != width || old.radius != radius || old.underline != underline;
}
