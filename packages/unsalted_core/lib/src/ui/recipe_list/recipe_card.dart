// lib/src/ui/recipe_list/recipe_card.dart
//
// Fachlicher Baustein (Teil 1.2): ein Rezept in der Liste — Titel und
// optional Beschreibung. Ob Liste oder Karte, entscheidet das Design-System.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe.dart';

/// Eintrag eines Rezepts.
class RecipeCard extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  /// Das Rezept.
  final Recipe recipe;

  /// Öffnet das Rezept.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppListItem(title: recipe.title, subtitle: recipe.description, onTap: onTap);
}
