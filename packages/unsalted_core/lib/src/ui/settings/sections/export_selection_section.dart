// lib/src/ui/settings/sections/export_selection_section.dart
//
// Bildschirm 11, Abschnitt „Auswahl“ (Teil 1.2): Rezept und eingefrorene
// Version. Nur Versionen mit state = snapshot sind wählbar (Kapitel 13.7).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe.dart';
import '../../../recipe/recipe_version.dart';

/// Auswahl von Rezept und Version für den Export.
class ExportSelectionSection extends StatelessWidget {
  /// Erzeugt den Abschnitt; ohne gewähltes Rezept ist [versions] `null`.
  const ExportSelectionSection({
    super.key,
    required this.recipes,
    required this.versions,
    required this.selectedRecipeId,
    required this.selectedVersionId,
    required this.onRecipeSelected,
    required this.onVersionSelected,
  });

  /// Alle Rezepte.
  final Stream<List<Recipe>> recipes;

  /// Versionen des gewählten Rezepts.
  final Stream<List<RecipeVersion>>? versions;

  /// Gewähltes Rezept.
  final String? selectedRecipeId;

  /// Gewählte Version.
  final String? selectedVersionId;

  /// Meldet die Wahl eines Rezepts.
  final ValueChanged<String> onRecipeSelected;

  /// Meldet die Wahl einer Version.
  final ValueChanged<String> onVersionSelected;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<List<Recipe>>(
            stream: recipes,
            builder: (context, snapshot) => AppSelect<String>(
              label: 'Rezept',
              value: selectedRecipeId,
              items: [
                for (final recipe in snapshot.data ?? const <Recipe>[]) AppSelectItem(recipe.id, recipe.title),
              ],
              onChanged: onRecipeSelected,
            ),
          ),
          const AppGap(AppSpace.s),
          if (versions != null)
            StreamBuilder<List<RecipeVersion>>(
              stream: versions,
              builder: (context, snapshot) {
                final snapshots = (snapshot.data ?? const <RecipeVersion>[])
                    .where((v) => v.state == VersionState.snapshot)
                    .toList();
                if (snapshots.isEmpty) return const AppText('Keine eingefrorene Version vorhanden.');
                return AppSelect<String>(
                  label: 'Version',
                  value: selectedVersionId,
                  items: [for (final version in snapshots) AppSelectItem(version.id, 'V${version.versionIndex}')],
                  onChanged: onVersionSelected,
                );
              },
            ),
        ],
      );
}
