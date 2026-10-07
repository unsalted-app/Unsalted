// lib/src/ui/recipe_editor/sections/recipe_editor_ingredients_section.dart
//
// Bildschirm 3, Abschnitt „Zutaten“ (Teil 1.2): umsortierbare
// Zutatenzeilen (Drag-Reorder ändert die Position) und „Zutat hinzufügen“.
// Jede Zeile trägt ihre stabile ID als Key (Kapitel 10.7).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../ingredient_row.dart';

/// Zutaten im Entwurf.
class RecipeEditorIngredientsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeEditorIngredientsSection({
    super.key,
    required this.rows,
    required this.onReorder,
    required this.onRowChanged,
    required this.onRowRemoved,
    required this.onAdd,
  });

  /// Zeilen in Reihenfolge.
  final List<IngredientRowData> rows;

  /// Verschiebt eine Zeile (Zielindex nach dem Entfernen).
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Meldet eine geänderte Zeile.
  final ValueChanged<IngredientRowData> onRowChanged;

  /// Entfernt die Zeile mit dieser ID.
  final ValueChanged<String> onRowRemoved;

  /// Fügt eine leere Zeile an.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => AppSection(
        title: 'Zutaten',
        children: [
          AppReorderableList(
            onReorder: onReorder,
            children: [
              for (final row in rows)
                IngredientRow(
                  key: ValueKey(row.id),
                  data: row,
                  onChanged: onRowChanged,
                  onRemove: () => onRowRemoved(row.id),
                ),
            ],
          ),
          AppButton.tertiary(label: 'Zutat hinzufügen', icon: AppIcons.add, onPressed: onAdd),
        ],
      );
}
