// lib/src/ui/versions/change_descriptions.dart
//
// Fehlerbehebung 9.2a, Befund 2: verständliche Texte für die
// Änderungsliste des Versionsvergleichs (Bildschirm 8). Reine Anzeige --
// keine Diff-Logik, die Änderungsliste selbst bleibt unverändert und wird
// so übernommen, wie RecipeDiff.between sie liefert (Kapitel 8.6/15.5).
//
// Positionen einer Änderung beziehen sich auf die Liste unmittelbar vor
// dieser Änderung (Kapitel 14.4), nicht auf Version A. Deshalb wird die
// Liste hier für die Anzeige der Reihe nach auf eine Namensliste aus A
// angewendet; ein Nachschlagen in A wäre nach Remove/Add/Move falsch.
// Zahlen erscheinen ungerundet, mit Dezimalkomma (formatQuantity, Teil 1.2
// C30).

import 'package:decimal/decimal.dart';

import '../../nutrition/unit_catalog.dart';
import '../../recipe/recipe_change.dart';
import '../../recipe/recipe_snapshot_v1.dart';
import '../shared/unit_labels.dart';

class _Ingredient {
  _Ingredient(this.name, this.quantity, this.unit);
  final String name;
  final Decimal quantity;
  final String unit;
}

class _Step {
  _Step(this.instruction, this.timerSeconds);
  final String instruction;
  final int? timerSeconds;
}

const _symbolUnits = {'g', 'kg', 'ml', 'l'};

String _unitLabel(String code) {
  if (_symbolUnits.contains(code)) return code;
  try {
    return UnitCatalog.byCode(code).name;
  } on ArgumentError {
    return code;
  }
}

String _amount(Decimal quantity, String unit) => '${formatQuantity(quantity)} ${_unitLabel(unit)}';

String _timer(int? seconds) {
  if (seconds == null) return 'kein Timer';
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// Kürzt am letzten Wortende vor [max] Zeichen.
String _shorten(String text, [int max = 40]) {
  final trimmed = text.trim();
  if (trimmed.length <= max) return trimmed;
  final cut = trimmed.substring(0, max);
  final lastSpace = cut.lastIndexOf(' ');
  return '${(lastSpace > 0 ? cut.substring(0, lastSpace) : cut).trimRight()}…';
}

String _quoted(String? text) => text == null || text.trim().isEmpty ? '—' : '„${_shorten(text)}“';

/// Ein Text je Änderung, in derselben Reihenfolge wie [changes].
List<String> describeChanges(RecipeSnapshotV1 a, List<RecipeChange> changes) {
  final ingredients = [
    for (final i in [...a.ingredients]..sort((x, y) => x.position.compareTo(y.position)))
      _Ingredient(i.name, i.quantity, i.unit),
  ];
  final steps = [
    for (final s in [...a.steps]..sort((x, y) => x.position.compareTo(y.position)))
      _Step(s.instruction, s.timerSeconds),
  ];

  _Ingredient? ingredientAt(int position) =>
      position >= 1 && position <= ingredients.length ? ingredients[position - 1] : null;
  _Step? stepAt(int position) => position >= 1 && position <= steps.length ? steps[position - 1] : null;
  String nameAt(int position) => ingredientAt(position)?.name ?? 'Zutat an Position $position';

  final texts = <String>[];
  for (final change in changes) {
    switch (change) {
      case SetTitle c:
        texts.add('Titel: ${_quoted(a.recipe.title)} → ${_quoted(c.title)}');
      case SetNotes c:
        texts.add('Notizen: ${_quoted(a.version.notes)} → ${_quoted(c.notes)}');
      case SetBakingLoss c:
        texts.add('Backverlust: ${formatQuantity(a.version.bakingLossPercent)} % → ${formatQuantity(c.percent)} %');
      case SetFinalWeightOverride c:
        String grams(Decimal? g) => g == null ? '—' : '${formatQuantity(g)} g';
        texts.add('Fertiggewicht-Override: ${grams(a.version.finalWeightOverrideG)} → ${grams(c.grams)}');
      case SetServings c:
        texts.add('Portionen: ${a.version.servings ?? '—'} → ${c.servings ?? '—'}');

      case SetStep c:
        final old = stepAt(c.position);
        final parts = <String>[
          if (c.instruction != null) _shorten(c.instruction!),
          if (c.timerSeconds != null) 'Timer ${_timer(old?.timerSeconds)} → ${_timer(c.timerSeconds!.value)}',
        ];
        texts.add('Schritt ${c.position} geändert: ${parts.join(' · ')}');
        if (old != null) {
          steps[c.position - 1] = _Step(
            c.instruction ?? old.instruction,
            c.timerSeconds != null ? c.timerSeconds!.value : old.timerSeconds,
          );
        }
      case AddStep c:
        final timer = c.timerSeconds == null ? '' : ' (Timer ${_timer(c.timerSeconds)})';
        texts.add('Schritt ${c.position} hinzugefügt: ${_shorten(c.instruction)}$timer');
        steps.insert((c.position - 1).clamp(0, steps.length), _Step(c.instruction, c.timerSeconds));
      case RemoveStep c:
        final old = stepAt(c.position);
        texts.add(old == null ? 'Schritt ${c.position} entfernt' : 'Schritt ${c.position} entfernt: ${_shorten(old.instruction)}');
        if (old != null) steps.removeAt(c.position - 1);

      case SetIngredientQuantity c:
        final old = ingredientAt(c.position);
        final unit = c.unitCode ?? old?.unit ?? '';
        texts.add(old == null
            ? '${nameAt(c.position)}: → ${_amount(c.quantity, unit)}'
            : '${old.name}: ${_amount(old.quantity, old.unit)} → ${_amount(c.quantity, unit)}');
        if (old != null) ingredients[c.position - 1] = _Ingredient(old.name, c.quantity, unit);
      case ReplaceIngredient c:
        final old = ingredientAt(c.position);
        final amountChanged = old != null && (old.quantity != c.quantity || old.unit != c.unitCode);
        final amount = amountChanged ? ' (${_amount(old.quantity, old.unit)} → ${_amount(c.quantity, c.unitCode)})' : '';
        texts.add(old != null && old.name == c.displayName
            ? '${old.name}: anderes Lebensmittel verknüpft$amount'
            : '${nameAt(c.position)} ersetzt durch ${c.displayName}$amount');
        if (old != null) ingredients[c.position - 1] = _Ingredient(c.displayName, c.quantity, c.unitCode);
      case RemoveIngredient c:
        texts.add('${nameAt(c.position)} entfernt');
        if (ingredientAt(c.position) != null) ingredients.removeAt(c.position - 1);
      case AddIngredient c:
        texts.add('${c.displayName} hinzugefügt (${_amount(c.quantity, c.unitCode)})');
        ingredients.insert(
          (c.position - 1).clamp(0, ingredients.length),
          _Ingredient(c.displayName, c.quantity, c.unitCode),
        );
      case MoveIngredient c:
        final moved = ingredientAt(c.from);
        texts.add('${nameAt(c.from)} verschoben (Position ${c.from} → ${c.to})');
        if (moved != null) {
          ingredients.removeAt(c.from - 1);
          ingredients.insert((c.to - 1).clamp(0, ingredients.length), moved);
        }
    }
  }
  return texts;
}
