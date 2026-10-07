// lib/src/ui/foods/sections/package_measures_section.dart
//
// Bildschirm 10, Abschnitt „Maße“ (Teil 1.2): Dichte, Stückgewicht,
// Portionsgröße (Kapitel 22). Ungültige Zahlen sperren das Speichern
// (PackageForm), ohne das Feld zu markieren — wie vor Teil 1.2.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Dichte, Stückgewicht und Portionsgröße.
class PackageMeasuresSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const PackageMeasuresSection({
    super.key,
    required this.density,
    required this.gramsPerPiece,
    required this.servingSize,
  });

  /// Dichte (g/ml).
  final TextEditingController density;

  /// Stückgewicht (g).
  final TextEditingController gramsPerPiece;

  /// Portionsgröße (g).
  final TextEditingController servingSize;

  @override
  Widget build(BuildContext context) => AppSection(
        children: [
          AppTextField(controller: density, label: 'Dichte (g/ml)'),
          AppTextField(controller: gramsPerPiece, label: 'Stückgewicht (g)'),
          AppTextField(controller: servingSize, label: 'Portionsgröße (g)'),
        ],
      );
}
