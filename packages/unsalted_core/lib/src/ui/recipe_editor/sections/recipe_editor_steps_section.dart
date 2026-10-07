// lib/src/ui/recipe_editor/sections/recipe_editor_steps_section.dart
//
// Bildschirm 3, Abschnitt „Schritte“ (Teil 1.2): umsortierbare
// Schrittzeilen mit Timer (28.4.2) und „Schritt hinzufügen“. Jede Zeile trägt
// ihre stabile ID als Key (Kapitel 10.7).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../step_row.dart';

/// Schritte im Entwurf.
class RecipeEditorStepsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeEditorStepsSection({
    super.key,
    required this.steps,
    required this.onReorder,
    required this.onInstructionChanged,
    required this.onTimerChanged,
    required this.onRemoved,
    required this.onAdd,
  });

  /// Schritte in Reihenfolge.
  final List<StepRowData> steps;

  /// Verschiebt einen Schritt (Zielindex nach dem Entfernen).
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Meldet eine geänderte Anweisung (ID, Text).
  final void Function(String id, String instruction) onInstructionChanged;

  /// Meldet eine Eingabe im Timer-Feld (ID, Text).
  final void Function(String id, String input) onTimerChanged;

  /// Entfernt den Schritt mit dieser ID.
  final ValueChanged<String> onRemoved;

  /// Fügt einen leeren Schritt an.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => AppSection(
        title: 'Schritte',
        children: [
          AppReorderableList(
            onReorder: onReorder,
            children: [
              for (final step in steps)
                StepRow(
                  key: ValueKey(step.id),
                  data: step,
                  onInstructionChanged: (value) => onInstructionChanged(step.id, value),
                  onTimerChanged: (value) => onTimerChanged(step.id, value),
                  onRemove: () => onRemoved(step.id),
                ),
            ],
          ),
          AppButton.tertiary(label: 'Schritt hinzufügen', icon: AppIcons.add, onPressed: onAdd),
        ],
      );
}
