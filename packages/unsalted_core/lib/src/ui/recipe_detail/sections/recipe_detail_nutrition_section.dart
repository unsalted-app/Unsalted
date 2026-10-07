// lib/src/ui/recipe_detail/sections/recipe_detail_nutrition_section.dart
//
// Bildschirm 4, Abschnitt „Nährwerte“ (Teil 1.2): Kopf und Tabelle
// (Bildschirm 5), darunter der Mengenrechner (Bildschirm 6) mit demselben
// NutritionResult (Fehlerbehebung 9.2a). Der Rechner ist je Version neu
// (Key = Versions-ID), damit seine Eingaben nicht in eine andere Version
// übernommen werden.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../nutrition/nutrition_result.dart';
import '../../config/core_ui_options.dart';
import '../../nutrition/amount_calculator.dart';
import '../../nutrition/nutrition_header.dart';
import '../../nutrition/nutrition_table.dart';

/// Nährwerte der gewählten Version.
class RecipeDetailNutritionSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeDetailNutritionSection({
    super.key,
    required this.versionId,
    required this.nutrition,
    this.options = const CoreUiOptions(),
  });

  /// ID der angezeigten Version.
  final String versionId;

  /// Nährwerte der Version.
  final NutritionResult nutrition;

  /// Anzeige-Schalter (C29).
  final CoreUiOptions options;

  @override
  Widget build(BuildContext context) => AppStack(
        gap: AppSpace.s,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NutritionHeader(result: nutrition),
          NutritionTable(result: nutrition, options: options),
          AmountCalculator(key: ValueKey(versionId), result: nutrition),
        ],
      );
}
