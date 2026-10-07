// lib/src/ui/versions/change_list.dart
//
// Fachlicher Baustein (Teil 1.2, aus version_compare_screen.dart
// herausgelöst): die Änderungsliste, gruppiert nach Kategorie in der
// Reihenfolge, in der RecipeDiff.between sie liefert (Kapitel 15.4:
// Parameter, Schritte, Zutaten). Die Texte kommen aus change_descriptions.dart.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe_change.dart';

enum _ChangeCategory { parameter, steps, ingredients }

_ChangeCategory _categoryOf(RecipeChange change) {
  return switch (change) {
    SetTitle() || SetNotes() || SetBakingLoss() || SetFinalWeightOverride() || SetServings() =>
      _ChangeCategory.parameter,
    SetStep() || AddStep() || RemoveStep() => _ChangeCategory.steps,
    SetIngredientQuantity() ||
    ReplaceIngredient() ||
    RemoveIngredient() ||
    AddIngredient() ||
    MoveIngredient() =>
      _ChangeCategory.ingredients,
  };
}

String _categoryLabel(_ChangeCategory category) => switch (category) {
      _ChangeCategory.parameter => 'Parameter',
      _ChangeCategory.steps => 'Schritte',
      _ChangeCategory.ingredients => 'Zutaten',
    };

/// Änderungsliste mit Kategorie-Überschriften.
class ChangeList extends StatelessWidget {
  /// Erzeugt die Liste; [descriptions] hat je Änderung einen Text.
  const ChangeList({super.key, required this.changes, required this.descriptions});

  /// Änderungen in Diff-Reihenfolge.
  final List<RecipeChange> changes;

  /// Anzeigetexte, gleiche Reihenfolge wie [changes].
  final List<String> descriptions;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    _ChangeCategory? currentCategory;
    for (var i = 0; i < changes.length; i++) {
      final category = _categoryOf(changes[i]);
      if (category != currentCategory) {
        currentCategory = category;
        items.add(AppPadding.only(
          left: AppSpace.l,
          top: AppSpace.m,
          right: AppSpace.l,
          bottom: AppSpace.xs,
          child: AppText.strong(_categoryLabel(category)),
        ));
      }
      items.add(AppListItem(dense: true, title: descriptions[i]));
    }
    return AppItemList(children: items);
  }
}
