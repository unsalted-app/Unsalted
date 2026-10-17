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
//
// Seit Teil 1.3 (D14): Zu jedem Text entstehen in derselben Schleife die
// sichtbaren Teile ([ChangePart]: Gegenstand, alt, neu, Zusatz) für die
// Darstellung „alt durchgestrichen → neu markiert“ (Highlight-Karte, Figma
// Bildschirm 08). Die Texte bleiben unverändert und sind die Semantik
// (28.4.5); der Pfeil darin wird nie gezeichnet (DS-49-Ausnahme), in den
// Teilen kommt er nicht vor. [describeChanges] hängt die Teile an die
// gelieferte Liste ([changePartsOf]), damit die Änderungsliste sie ohne neue
// Parameter findet.

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

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

/// Sichtbarer Teil einer Änderung: Gegenstand, alt (durchgestrichen), neu
/// (markiert) und Zusatz; zwischen alt und neu steht der Pfeil als Symbol.
@immutable
class ChangePart {
  /// Erzeugt den Teil.
  const ChangePart({this.subject, this.before, this.after, this.note});

  /// Gegenstand, z. B. „Mehl“.
  final String? subject;

  /// Alter Wert.
  final String? before;

  /// Neuer Wert.
  final String? after;

  /// Zusatz im Klartext.
  final String? note;
}

final _parts = Expando<List<List<ChangePart>>>('Teile der Änderungen');

/// Sichtbare Teile je Text einer Liste aus [describeChanges]; `null`, wenn
/// [texts] nicht von dort stammt.
List<List<ChangePart>>? changePartsOf(List<String> texts) => _parts[texts];

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
  final parts = <List<ChangePart>>[];
  void add(String text, List<ChangePart> visible) {
    texts.add(text);
    parts.add(visible);
  }

  for (final change in changes) {
    switch (change) {
      case SetTitle c:
        add('Titel: ${_quoted(a.recipe.title)} → ${_quoted(c.title)}',
            [ChangePart(subject: 'Titel', before: _quoted(a.recipe.title), after: _quoted(c.title))]);
      case SetNotes c:
        add('Notizen: ${_quoted(a.version.notes)} → ${_quoted(c.notes)}',
            [ChangePart(subject: 'Notizen', before: _quoted(a.version.notes), after: _quoted(c.notes))]);
      case SetBakingLoss c:
        final before = '${formatQuantity(a.version.bakingLossPercent)} %';
        final after = '${formatQuantity(c.percent)} %';
        add('Backverlust: $before → $after', [ChangePart(subject: 'Backverlust', before: before, after: after)]);
      case SetFinalWeightOverride c:
        String grams(Decimal? g) => g == null ? '—' : '${formatQuantity(g)} g';
        add('Fertiggewicht-Override: ${grams(a.version.finalWeightOverrideG)} → ${grams(c.grams)}', [
          ChangePart(subject: 'Fertiggewicht-Override', before: grams(a.version.finalWeightOverrideG), after: grams(c.grams)),
        ]);
      case SetServings c:
        final before = '${a.version.servings ?? '—'}';
        final after = '${c.servings ?? '—'}';
        add('Portionen: $before → $after', [ChangePart(subject: 'Portionen', before: before, after: after)]);

      case SetStep c:
        final old = stepAt(c.position);
        final changed = <String>[
          if (c.instruction != null) _shorten(c.instruction!),
          if (c.timerSeconds != null) 'Timer ${_timer(old?.timerSeconds)} → ${_timer(c.timerSeconds!.value)}',
        ];
        add('Schritt ${c.position} geändert: ${changed.join(' · ')}', [
          if (c.instruction != null)
            ChangePart(
              subject: 'Schritt ${c.position}',
              before: old == null ? null : _shorten(old.instruction),
              after: _shorten(c.instruction!),
            )
          else
            ChangePart(subject: 'Schritt ${c.position}'),
          if (c.timerSeconds != null)
            ChangePart(subject: 'Timer', before: _timer(old?.timerSeconds), after: _timer(c.timerSeconds!.value)),
        ]);
        if (old != null) {
          steps[c.position - 1] = _Step(
            c.instruction ?? old.instruction,
            c.timerSeconds != null ? c.timerSeconds!.value : old.timerSeconds,
          );
        }
      case AddStep c:
        final timer = c.timerSeconds == null ? '' : ' (Timer ${_timer(c.timerSeconds)})';
        add('Schritt ${c.position} hinzugefügt: ${_shorten(c.instruction)}$timer',
            [ChangePart(subject: 'Schritt ${c.position}', after: '${_shorten(c.instruction)}$timer')]);
        steps.insert((c.position - 1).clamp(0, steps.length), _Step(c.instruction, c.timerSeconds));
      case RemoveStep c:
        final old = stepAt(c.position);
        add(
          old == null ? 'Schritt ${c.position} entfernt' : 'Schritt ${c.position} entfernt: ${_shorten(old.instruction)}',
          [
            old == null
                ? ChangePart(subject: 'Schritt ${c.position}', note: 'entfernt')
                : ChangePart(subject: 'Schritt ${c.position}', before: _shorten(old.instruction)),
          ],
        );
        if (old != null) steps.removeAt(c.position - 1);

      case SetIngredientQuantity c:
        final old = ingredientAt(c.position);
        final unit = c.unitCode ?? old?.unit ?? '';
        add(
          old == null
              ? '${nameAt(c.position)}: → ${_amount(c.quantity, unit)}'
              : '${old.name}: ${_amount(old.quantity, old.unit)} → ${_amount(c.quantity, unit)}',
          [
            ChangePart(
              subject: old?.name ?? nameAt(c.position),
              before: old == null ? null : _amount(old.quantity, old.unit),
              after: _amount(c.quantity, unit),
            ),
          ],
        );
        if (old != null) ingredients[c.position - 1] = _Ingredient(old.name, c.quantity, unit);
      case ReplaceIngredient c:
        final old = ingredientAt(c.position);
        final amountChanged = old != null && (old.quantity != c.quantity || old.unit != c.unitCode);
        final amount = amountChanged ? ' (${_amount(old.quantity, old.unit)} → ${_amount(c.quantity, c.unitCode)})' : '';
        final sameName = old != null && old.name == c.displayName;
        add(
          sameName
              ? '${old.name}: anderes Lebensmittel verknüpft$amount'
              : '${nameAt(c.position)} ersetzt durch ${c.displayName}$amount',
          [
            if (sameName)
              ChangePart(subject: old.name, note: 'anderes Lebensmittel verknüpft')
            else
              ChangePart(before: nameAt(c.position), after: c.displayName),
            if (amountChanged) ChangePart(before: _amount(old.quantity, old.unit), after: _amount(c.quantity, c.unitCode)),
          ],
        );
        if (old != null) ingredients[c.position - 1] = _Ingredient(c.displayName, c.quantity, c.unitCode);
      case RemoveIngredient c:
        final old = ingredientAt(c.position);
        add('${nameAt(c.position)} entfernt', [
          ChangePart(
            subject: 'entfernt',
            before: old == null ? nameAt(c.position) : '${old.name} · ${_amount(old.quantity, old.unit)}',
          ),
        ]);
        if (old != null) ingredients.removeAt(c.position - 1);
      case AddIngredient c:
        add('${c.displayName} hinzugefügt (${_amount(c.quantity, c.unitCode)})', [
          ChangePart(subject: 'neu', after: '${c.displayName} · ${_amount(c.quantity, c.unitCode)}'),
        ]);
        ingredients.insert(
          (c.position - 1).clamp(0, ingredients.length),
          _Ingredient(c.displayName, c.quantity, c.unitCode),
        );
      case MoveIngredient c:
        final moved = ingredientAt(c.from);
        add('${nameAt(c.from)} verschoben (Position ${c.from} → ${c.to})', [
          ChangePart(subject: '${nameAt(c.from)} verschoben', before: 'Position ${c.from}', after: 'Position ${c.to}'),
        ]);
        if (moved != null) {
          ingredients.removeAt(c.from - 1);
          ingredients.insert((c.to - 1).clamp(0, ingredients.length), moved);
        }
    }
  }
  _parts[texts] = parts;
  return texts;
}
