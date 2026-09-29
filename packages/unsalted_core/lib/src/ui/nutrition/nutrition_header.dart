// lib/src/ui/nutrition/nutrition_header.dart
//
// Bildschirm 5 (Kapitel 22, Schritt 8.4): Kopf der Nährwertanzeige --
// Fertiggewicht, Gesamt-kcal, kcal/Portion (nur wenn servings gesetzt war,
// erkennbar an result.perServing != null), Hinweisblock für nicht
// berechenbare Zutaten. Reine Anzeige; keine eigene Berechnung.
// NutritionFormatter ist die einzige Rundungsstelle.

import 'package:flutter/material.dart';

import '../../nutrition/nutrition_formatter.dart';
import '../../nutrition/nutrition_result.dart';

class NutritionHeader extends StatelessWidget {
  final NutritionResult result;

  const NutritionHeader({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final incompleteEnergy = result.incomplete.contains('energy_kcal');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fertiggewicht: ${NutritionFormatter.formatGrams(result.finalWeightG)} g'),
        Text(
          'Gesamt: ${NutritionFormatter.formatKcal(result.total.energyKcal, isIncomplete: incompleteEnergy)} kcal',
        ),
        if (result.perServing != null)
          Text(
            'kcal/Portion: '
            '${NutritionFormatter.formatKcal(result.perServing!.energyKcal, isIncomplete: incompleteEnergy)} kcal',
          ),
        if (result.notCalculable.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              child: Text(
                'Nicht berechenbar (fehlende Dichte/Stückgewicht): '
                '${result.notCalculable.join(", ")}',
              ),
            ),
          ),
      ],
    );
  }
}
