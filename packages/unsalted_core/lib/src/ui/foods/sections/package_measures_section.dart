// lib/src/ui/foods/sections/package_measures_section.dart
//
// Bildschirm 10, Abschnitt „Maße“ (Teil 1.2): Dichte, Stückgewicht,
// Portionsgröße (Kapitel 22). Ungültige Zahlen sperren das Speichern
// (PackageForm), ohne das Feld zu markieren — wie vor Teil 1.2.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Ein Feld des Maße-Abschnitts.
enum Measure {
  /// Dichte (g/ml).
  density,

  /// Stückgewicht (g).
  gramsPerPiece,

  /// Portionsgröße (g).
  servingSize,
}

/// Dichte, Stückgewicht und Portionsgröße.
class PackageMeasuresSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const PackageMeasuresSection({
    super.key,
    required this.density,
    required this.gramsPerPiece,
    required this.servingSize,
    this.visible = const {Measure.density, Measure.gramsPerPiece, Measure.servingSize},
  });

  /// Dichte (g/ml).
  final TextEditingController density;

  /// Stückgewicht (g).
  final TextEditingController gramsPerPiece;

  /// Portionsgröße (g).
  final TextEditingController servingSize;

  /// Angezeigte Felder (C29: erweiterte Felder ausblendbar); leer = Abschnitt
  /// entfällt.
  final Set<Measure> visible;

  @override
  Widget build(BuildContext context) {
    if (visible.isEmpty) return const SizedBox.shrink();
    return AppSection(
      children: [
        if (visible.contains(Measure.density)) AppTextField(controller: density, label: 'Dichte (g/ml)'),
        if (visible.contains(Measure.gramsPerPiece)) AppTextField(controller: gramsPerPiece, label: 'Stückgewicht (g)'),
        if (visible.contains(Measure.servingSize)) AppTextField(controller: servingSize, label: 'Portionsgröße (g)'),
      ],
    );
  }
}
