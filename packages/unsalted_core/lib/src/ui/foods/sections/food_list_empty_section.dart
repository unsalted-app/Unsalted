// lib/src/ui/foods/sections/food_list_empty_section.dart
//
// Bildschirm 9, Abschnitt „leer“ (Teil 1.2): kein Lebensmittel gefunden, mit
// Aktion „Eigenes Produkt anlegen“ (Kapitel 22).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Leerer Zustand der Lebensmittel-Liste.
class FoodListEmptySection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const FoodListEmptySection({super.key, required this.onCreate});

  /// Legt ein neues Lebensmittel an.
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => AppEmptyState(
        icon: AppIcons.emptyPlate,
        message: 'Keine Lebensmittel gefunden.',
        action: AppButton.primary(label: 'Eigenes Produkt anlegen', onPressed: onCreate),
      );
}
