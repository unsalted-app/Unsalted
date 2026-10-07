// lib/src/ui/recipe_detail/sections/recipe_detail_extensions_section.dart
//
// Bildschirm 4, Abschnitt „Erweiterungen“ (Teil 1.2): die bereits gebauten
// `recipeDetailSections` aller Module in `order`-Reihenfolge (Kapitel 21),
// abgesetzt durch eine Trennlinie. Gebaut werden sie im Bildschirm mit dessen
// Kontext und dem RecipeContext — wie vor Teil 1.2.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Abschnitte der Module; leer = nichts.
class RecipeDetailExtensionsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeDetailExtensionsSection({super.key, required this.children});

  /// Gebaute Modul-Abschnitte in Anzeigereihenfolge.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return AppSection(children: children);
  }
}
