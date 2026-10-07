// lib/src/ui/settings/sections/import_preview_section.dart
//
// Bildschirm 12, Abschnitt „Vorschau“ (Teil 1.2): Titel, Zutatenzahl und
// Gesamt-kcal vor dem Schreiben (Kapitel 22). Gerundet wird nur im
// NutritionFormatter.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../nutrition/nutrition_formatter.dart';
import '../../../recipe/recipe_snapshot_v1.dart';

/// Vorschau des einzulesenden Rezepts.
class ImportPreviewSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const ImportPreviewSection({super.key, required this.preview});

  /// Gelesener Snapshot.
  final RecipeSnapshotV1 preview;

  @override
  Widget build(BuildContext context) => AppStack(
        children: [
          AppText.strong('Vorschau: ${preview.recipe.title}'),
          AppText('${preview.ingredients.length} Zutaten'),
          AppText('Gesamt: ${NutritionFormatter.formatKcal(preview.nutrition.total.energyKcal)} kcal'),
        ],
      );
}
