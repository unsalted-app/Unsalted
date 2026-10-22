// lib/src/ui/recipe_detail/sections/recipe_detail_steps_section.dart
//
// Bildschirm 4, Abschnitt „Schritte“ (Teil 1.2): Anweisung je Schritt, bei
// gesetztem timerSeconds ein Timer-Chip (nur Anzeige, keine Timer-Engine).
// Seit Teil 1.3 (D16, Figma `Core/Step Row`): je Schritt die Nummer in
// `size-index-column` (`data-strong`), daneben die Anweisung und darunter der
// Timer als Tag mit Symbol `timer`; Haarlinie unter jedem Schritt.
// Seit Teil 1.4 (B05, F1): der Text ist markierbar und kopierbar
// (`AppSelectableArea`, Figma `Input/Text Selection`).

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
          AppSelectableArea(
            child: AppStack(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, step) in steps.indexed) ...[
                  AppPadding.symmetric(
                    vertical: AppSpace.s,
                    child: AppStack(
                      direction: Axis.horizontal,
                      gap: AppSpace.s,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(width: AppSize.indexColumn, child: AppText.dataStrong('${index + 1}')),
                        Expanded(
                          child: AppStack(
                            gap: AppSpace.s,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(step.instruction),
                              if (step.timerSeconds != null)
                                AppChip(label: _formatTimer(step.timerSeconds!), icon: AppIcons.timer),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppDivider.flush(),
                ],
              ],
            ),
          ),
        ],
      );
}
