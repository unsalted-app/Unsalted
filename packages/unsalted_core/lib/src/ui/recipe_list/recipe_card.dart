// lib/src/ui/recipe_list/recipe_card.dart
//
// Fachlicher Baustein (Teil 1.2): ein Rezept in der Liste — Titel und
// optional Beschreibung. Ob Liste oder Karte, entscheidet das Design-System.
// Seit Teil 1.4 (B04, Figma `List/Item` `showMatch`): mit [RecipeCard.query]
// ist der erste Treffer im Titel markiert (ohne Groß-/Kleinschreibung, wie die
// Suche in Bildschirm 1).
// Seit Teil 1.4 (T02): [RecipeCard.selected] zeigt den Auswahlbalken (Liste
// und Detail nebeneinander).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe.dart';

/// Eintrag eines Rezepts.
class RecipeCard extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const RecipeCard({super.key, required this.recipe, required this.onTap, this.query = '', this.selected = false});

  /// Das Rezept.
  final Recipe recipe;

  /// Öffnet das Rezept.
  final VoidCallback onTap;

  /// Suchbegriff; leer = kein Treffer markiert.
  final String query;

  /// `true`: im Detailbereich geöffnet (Auswahlbalken).
  final bool selected;

  /// Erster Treffer von [query] in [title] (ohne Groß-/Kleinschreibung);
  /// `null` = keiner.
  static TextRange? matchOf(String title, String query) {
    final needle = query.trim().toLowerCase();
    final haystack = title.toLowerCase();
    // Nur wenn die Kleinschreibung die Länge erhält, passen die Positionen.
    if (needle.isEmpty || haystack.length != title.length) return null;
    final start = haystack.indexOf(needle);
    return start < 0 ? null : TextRange(start: start, end: start + needle.length);
  }

  @override
  Widget build(BuildContext context) => AppListItem(
        title: recipe.title,
        subtitle: recipe.description,
        onTap: onTap,
        match: matchOf(recipe.title, query),
        selected: selected,
      );
}
