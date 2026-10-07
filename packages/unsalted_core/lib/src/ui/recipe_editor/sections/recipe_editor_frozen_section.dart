// lib/src/ui/recipe_editor/sections/recipe_editor_frozen_section.dart
//
// Bildschirm 3, Abschnitt „eingefroren“ (Teil 1.2): Hinweis „Eingefroren —
// als neuen Entwurf kopieren?“ mit Aktion (createDraftFrom), darunter
// schreibgeschützt Zutaten und Schritte (Kapitel 22).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_version.dart';
import '../../shared/unit_labels.dart';

/// Schreibgeschützte Ansicht einer eingefrorenen Version.
class RecipeEditorFrozenSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeEditorFrozenSection({super.key, required this.version, required this.onCopy});

  /// Die eingefrorene Version.
  final RecipeVersion version;

  /// Kopiert sie als neuen Entwurf.
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurface(
            tone: AppSurfaceTone.info,
            child: Row(
              children: [
                const Expanded(child: AppText('Eingefroren — als neuen Entwurf kopieren?')),
                AppButton.tertiary(label: 'Kopieren', onPressed: onCopy),
              ],
            ),
          ),
          const AppGap(AppSpace.l),
          for (final ingredient in version.ingredients)
            AppListItem(title: ingredient.displayName, subtitle: formatAmount(ingredient.quantity, ingredient.unitCode)),
          const AppDivider(),
          for (final step in version.steps) AppListItem(title: step.instruction),
        ],
      );
}
