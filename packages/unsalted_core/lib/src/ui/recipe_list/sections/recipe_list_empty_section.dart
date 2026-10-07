// lib/src/ui/recipe_list/sections/recipe_list_empty_section.dart
//
// Bildschirm 1, Abschnitt „leer“ (Teil 1.2): noch keine Rezepte (mit Aktion
// „Erstes Rezept anlegen“, Kapitel 22) oder keine Treffer der Suche.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Leerer Zustand der Rezeptliste.
class RecipeListEmptySection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeListEmptySection({super.key, required this.hasRecipes, required this.onCreate});

  /// `true`: Es gibt Rezepte, nur die Suche trifft keins.
  final bool hasRecipes;

  /// Legt das erste Rezept an.
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => AppEmptyState(
        icon: AppIcons.book,
        message: hasRecipes ? 'Keine Treffer.' : 'Noch keine Rezepte.',
        // Ohne Aktion hält ein leerer Platzhalter den Abstand unter dem Satz
        // wie vor Teil 1.2.
        action: hasRecipes
            ? const SizedBox.shrink()
            : AppButton.primary(label: 'Erstes Rezept anlegen', onPressed: onCreate),
      );
}
