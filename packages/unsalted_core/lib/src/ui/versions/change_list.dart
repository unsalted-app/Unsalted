// lib/src/ui/versions/change_list.dart
//
// Fachlicher Baustein (Teil 1.2, aus version_compare_screen.dart
// herausgelöst): die Änderungsliste, gruppiert nach Kategorie in der
// Reihenfolge, in der RecipeDiff.between sie liefert (Kapitel 15.4:
// Parameter, Schritte, Zutaten). Die Texte kommen aus change_descriptions.dart.
//
// Seit Teil 1.3 (D14, ChangeList im Vorschlag, Figma Bildschirm 08): je
// Kategorie ein Abschnitt mit 3-px-Linie und Überschrift, je Änderung
// `AppChangeText` aus den sichtbaren Teilen (alt durchgestrichen, Pfeil als
// Symbol, neu markiert; hinzugefügt nur Marker, entfernt nur Strich). Die
// Semantik jeder Änderung ist ihr bisheriger Text (28.4.5). Fehlen die Teile
// (Texte nicht aus `describeChanges`), steht der Text unverändert da.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe_change.dart';
import 'change_descriptions.dart';

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
    final parts = changePartsOf(descriptions);
    final groups = <(_ChangeCategory, List<Widget>)>[];
    for (var i = 0; i < changes.length; i++) {
      final category = _categoryOf(changes[i]);
      if (groups.isEmpty || groups.last.$1 != category) groups.add((category, []));
      groups.last.$2.add(AppPadding.symmetric(
        vertical: AppSpace.xs,
        child: _ChangeLine(text: descriptions[i], parts: parts?[i]),
      ));
    }
    return AppItemList(children: [
      for (final (category, lines) in groups)
        AppPadding.symmetric(
          horizontal: AppSpace.l,
          child: AppSection(title: _categoryLabel(category), children: lines),
        ),
    ]);
  }
}

/// Eine Änderung: sichtbar in Teilen, vorgelesen als ihr Text.
class _ChangeLine extends StatelessWidget {
  const _ChangeLine({required this.text, required this.parts});

  final String text;
  final List<ChangePart>? parts;

  @override
  Widget build(BuildContext context) {
    final visible = parts;
    if (visible == null) return AppText(text);
    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final part in visible)
              AppChangeText(
                semanticLabel: text,
                subject: part.subject,
                before: part.before,
                after: part.after,
                note: part.note,
              ),
          ],
        ),
      ),
    );
  }
}
