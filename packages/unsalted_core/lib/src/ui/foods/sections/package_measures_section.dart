// lib/src/ui/foods/sections/package_measures_section.dart
//
// Bildschirm 10, Abschnitt „Maße“ (Teil 1.2): Dichte, Stückgewicht,
// Portionsgröße (Kapitel 22). Ungültige Zahlen sperren das Speichern
// (PackageForm), ohne das Feld zu markieren — wie vor Teil 1.2. Seit Teil 1.3
// (D18b) Zahlenfelder wie die Nährwertfelder (Tastatur mit Komma,
// rechtsbündig, tabellarische Ziffern), seit D18c mit Abstand `space-m`
// zwischen den Feldern (wie D16b).

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
    const numeric = TextInputType.numberWithOptions(decimal: true);
    return AppSection(
      children: [
        AppStack(
          gap: AppSpace.m,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (visible.contains(Measure.density))
              AppTextField(controller: density, label: 'Dichte (g/ml)', keyboardType: numeric),
            if (visible.contains(Measure.gramsPerPiece))
              AppTextField(controller: gramsPerPiece, label: 'Stückgewicht (g)', keyboardType: numeric),
            if (visible.contains(Measure.servingSize))
              AppTextField(controller: servingSize, label: 'Portionsgröße (g)', keyboardType: numeric),
          ],
        ),
      ],
    );
  }
}
