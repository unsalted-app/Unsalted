// lib/src/ui/recipe_detail/sections/recipe_detail_ingredients_section.dart
//
// Bildschirm 4, Abschnitt „Zutaten“ (Teil 1.2): Name, Menge, Einheit und
// optional Notiz je Zutat.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_ingredient.dart';

/// Zutaten der gewählten Version.
class RecipeDetailIngredientsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeDetailIngredientsSection({super.key, required this.ingredients});

  /// Zutaten in Reihenfolge.
  final List<RecipeIngredient> ingredients;

  @override
  Widget build(BuildContext context) => AppSection(
        title: 'Zutaten',
        children: [
          for (final ingredient in ingredients)
            AppListItem(
              title: ingredient.displayName,
              subtitle: '${ingredient.quantity} ${ingredient.unitCode}'
                  '${ingredient.note == null ? '' : ' · ${ingredient.note}'}',
            ),
        ],
      );
}
