// lib/src/ui/recipe_list/sections/recipe_list_search_section.dart
//
// Bildschirm 1, Abschnitt „Suche“ (Teil 1.2): Suche über den Titel.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Suchfeld der Rezeptliste.
class RecipeListSearchSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeListSearchSection({super.key, required this.controller, required this.onChanged});

  /// Text der Suche.
  final TextEditingController controller;

  /// Meldet jede Änderung der Suche.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) =>
      AppSearchField(hint: 'Suchen …', controller: controller, onChanged: onChanged);
}
