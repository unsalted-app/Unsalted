// lib/src/ui/recipe_editor/sections/recipe_editor_parameters_section.dart
//
// Bildschirm 3, Abschnitt „Parameter“ (Teil 1.2): Portionen, Backverlust,
// Fertiggewicht-Override, Notizen.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Parameter der Version.
class RecipeEditorParametersSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeEditorParametersSection({
    super.key,
    required this.servings,
    required this.bakingLoss,
    required this.finalWeight,
    required this.notes,
    required this.onChanged,
    this.showAdvanced = true,
  });

  /// Portionen.
  final TextEditingController servings;

  /// Backverlust (%).
  final TextEditingController bakingLoss;

  /// Fertiggewicht-Override (g).
  final TextEditingController finalWeight;

  /// Notizen.
  final TextEditingController notes;

  /// Meldet Änderungen, die die Vorschau beeinflussen.
  final VoidCallback onChanged;

  /// `false`: Backverlust und Fertiggewicht-Override ausgeblendet (C29); ihre
  /// Werte bleiben erhalten und werden mitgespeichert.
  final bool showAdvanced;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(controller: servings, label: 'Portionen', onChanged: (_) => onChanged()),
          if (showAdvanced) ...[
            AppTextField(controller: bakingLoss, label: 'Backverlust (%)', onChanged: (_) => onChanged()),
            AppTextField(controller: finalWeight, label: 'Fertiggewicht-Override (g)', onChanged: (_) => onChanged()),
          ],
          AppTextField(controller: notes, label: 'Notizen', maxLines: 3),
        ],
      );
}
