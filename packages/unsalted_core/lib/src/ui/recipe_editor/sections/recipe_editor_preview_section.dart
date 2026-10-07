// lib/src/ui/recipe_editor/sections/recipe_editor_preview_section.dart
//
// Bildschirm 3, Abschnitt „Vorschau“ (Teil 1.2): Gesamt-kcal live über
// NutritionService.preview, als Leiste über dem Formular. Gerundet wird nur
// im NutritionFormatter.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../nutrition/nutrition_formatter.dart';
import '../../../nutrition/nutrition_result.dart';

/// Live-Vorschau der Gesamt-kcal.
class RecipeEditorPreviewSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeEditorPreviewSection({super.key, required this.preview});

  /// Vorschau aus den aktuellen Eingaben.
  final NutritionResult preview;

  @override
  Widget build(BuildContext context) => AppSurface(
        tone: AppSurfaceTone.high,
        fullWidth: true,
        child: AppText(
          'Gesamt: ${NutritionFormatter.formatKcal(preview.total.energyKcal, isIncomplete: preview.incomplete.contains('energy_kcal'))}',
        ),
      );
}
