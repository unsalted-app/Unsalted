// lib/src/ui/recipe_list/sections/recipe_list_results_section.dart
//
// Bildschirm 1, Abschnitt „Treffer“ (Teil 1.2): Rezepte als Liste; nach links
// wischen löscht (mit „Rückgängig“, Teil 1.1b).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe.dart';
import '../recipe_card.dart';

/// Trefferliste der Rezepte.
class RecipeListResultsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeListResultsSection({super.key, required this.recipes, required this.onOpen, required this.onDelete});

  /// Anzuzeigende Rezepte.
  final List<Recipe> recipes;

  /// Öffnet ein Rezept.
  final ValueChanged<Recipe> onOpen;

  /// Löscht ein weggewischtes Rezept.
  final ValueChanged<Recipe> onDelete;

  @override
  Widget build(BuildContext context) => AppItemList.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return AppSwipeToDelete(
            key: ValueKey('recipe-${recipe.id}'),
            onDelete: () => onDelete(recipe),
            child: RecipeCard(recipe: recipe, onTap: () => onOpen(recipe)),
          );
        },
      );
}
