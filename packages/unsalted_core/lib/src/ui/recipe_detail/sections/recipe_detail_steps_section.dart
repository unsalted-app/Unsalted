// lib/src/ui/recipe_detail/sections/recipe_detail_steps_section.dart
//
// Bildschirm 4, Abschnitt „Schritte“ (Teil 1.2): Anweisung je Schritt, bei
// gesetztem timerSeconds ein Timer-Chip (nur Anzeige, keine Timer-Engine).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_step.dart';

/// Schritte der gewählten Version.
class RecipeDetailStepsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeDetailStepsSection({super.key, required this.steps});

  /// Schritte in Reihenfolge.
  final List<RecipeStep> steps;

  static String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => AppSection(
        title: 'Schritte',
        children: [
          for (final step in steps)
            AppListItem(
              title: step.instruction,
              trailing: step.timerSeconds == null ? null : AppChip(label: _formatTimer(step.timerSeconds!)),
            ),
        ],
      );
}
