// lib/src/ui/nutrition/nutrition_header.dart
//
// Bildschirm 5 (Kapitel 22, Schritt 8.4): Kopf der Nährwertanzeige --
// Fertiggewicht, Gesamt-kcal, kcal/Portion (nur wenn servings gesetzt war,
// erkennbar an result.perServing != null), Hinweisblock für nicht
// berechenbare Zutaten. Reine Anzeige; keine eigene Berechnung.
// NutritionFormatter ist die einzige Rundungsstelle. Seit Teil 1.2 (C22) aus
// Design-Komponenten.
//
// Seit Teil 1.3 (D15, NutritionHeader im Vorschlag, Figma `Core/Nutrition
// Header`): Kennzahlenleiste (`AppFigureRow`) mit Fertiggewicht, Gesamt und
// kcal/Portion, Werte als `AppValue.strong` (Zahl aus NutritionFormatter,
// Einheit zurückgenommen, „*“ für unvollständig, „—“ für unbekannt); der
// Hinweis „Nicht berechenbar …“ als `AppNotice` (Warnung). Texte unverändert.

import 'package:decimal/decimal.dart';
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
    AppValue kcal(Decimal? value) => AppValue.strong(
          value: NutritionFormatter.formatKcal(value),
          unit: 'kcal',
          certainty: value == null
              ? AppCertainty.unknown
              : (incompleteEnergy ? AppCertainty.incomplete : AppCertainty.known),
        );

    return AppStack(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFigureRow(figures: [
          AppFigure(
            label: 'Fertiggewicht',
            value: AppValue.strong(value: NutritionFormatter.formatGrams(result.finalWeightG), unit: 'g'),
          ),
          AppFigure(label: 'Gesamt', value: kcal(result.total.energyKcal)),
          if (result.perServing != null) AppFigure(label: 'kcal/Portion', value: kcal(result.perServing!.energyKcal)),
        ]),
        if (result.notCalculable.isNotEmpty)
          AppPadding.only(
            top: AppSpace.m,
            child: AppNotice(
              'Nicht berechenbar (fehlende Dichte/Stückgewicht): ${result.notCalculable.join(", ")}',
              kind: AppNoticeKind.warning,
            ),
          ),
      ],
    );
  }
}
