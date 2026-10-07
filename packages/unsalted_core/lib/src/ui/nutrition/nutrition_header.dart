// lib/src/ui/nutrition/nutrition_header.dart
//
// Bildschirm 5 (Kapitel 22, Schritt 8.4): Kopf der Nährwertanzeige --
// Fertiggewicht, Gesamt-kcal, kcal/Portion (nur wenn servings gesetzt war,
// erkennbar an result.perServing != null), Hinweisblock für nicht
// berechenbare Zutaten. Reine Anzeige; keine eigene Berechnung.
// NutritionFormatter ist die einzige Rundungsstelle. Seit Teil 1.2 (C22) aus
// Design-Komponenten.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../nutrition/nutrition_formatter.dart';
import '../../nutrition/nutrition_result.dart';

class NutritionHeader extends StatelessWidget {
  final NutritionResult result;

  const NutritionHeader({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final incompleteEnergy = result.incomplete.contains('energy_kcal');

    return AppStack(
      children: [
        AppText('Fertiggewicht: ${NutritionFormatter.formatGrams(result.finalWeightG)} g'),
        AppText(
          'Gesamt: ${NutritionFormatter.formatKcal(result.total.energyKcal, isIncomplete: incompleteEnergy)} kcal',
        ),
        if (result.perServing != null)
          AppText(
            'kcal/Portion: '
            '${NutritionFormatter.formatKcal(result.perServing!.energyKcal, isIncomplete: incompleteEnergy)} kcal',
          ),
        if (result.notCalculable.isNotEmpty)
          AppPadding.only(
            top: AppSpace.s,
            child: AppSurface(
              tone: AppSurfaceTone.warning,
              padding: AppSpace.s,
              child: AppText(
                'Nicht berechenbar (fehlende Dichte/Stückgewicht): '
                '${result.notCalculable.join(", ")}',
              ),
            ),
          ),
      ],
    );
  }
}
