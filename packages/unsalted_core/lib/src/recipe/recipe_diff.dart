import 'recipe_change.dart';
import 'recipe_ingredient.dart';
import 'recipe_snapshot_v1.dart';
import 'snapshot_row_match.dart';

/// Vergleicht zwei Snapshots und liefert die `RecipeChange`-Liste, die `a`
/// in `b` überführt (Kapitel 15). Reine Funktion: keine Datenbank, kein
/// Flutter, kein veränderlicher Zustand.
///
/// [targetRows] sind die Zutatenzeilen der Zielversion `b` (über
/// `RecipeRepository.getVersion`). Nur damit tragen erzeugte
/// `AddIngredient`/`ReplaceIngredient` die `foodVariantId` von `b`; ohne
/// sie bleibt sie `null`, weil das Snapshot-Format keine Variant-ID führt
/// (Fehlerbehebung 9.1a, F3). Wer die Liste anwenden will, muss sie
/// übergeben.
///
/// Bekannte, bewusste Einschränkung: Eine reine Änderung von
/// `RecipeSnapshotIngredient.note` wird nicht erkannt, weil es dafür keinen
/// passenden `RecipeChange`-Typ gibt (`ReplaceIngredient` trägt kein
/// `note`-Feld, Kapitel 14.1).
class RecipeDiff {
  const RecipeDiff._();

  /// Liefert die Änderungen von [a] nach [b] in der festen Reihenfolge aus
  /// Kapitel 15.4. Für eine Liste, die angewendet werden soll, ist [targetRows]
  /// Pflicht (Kapitel 28.3.2).
  static List<RecipeChange> between(
    RecipeSnapshotV1 a,
    RecipeSnapshotV1 b, {
    List<RecipeIngredient>? targetRows,
  }) {
    final changes = <RecipeChange>[];

    // 1. positionsunabhängige Parameter, feste Reihenfolge (Kapitel 15.4.1)
    if (a.recipe.title != b.recipe.title) {
      changes.add(SetTitle(title: b.recipe.title));
    }
    if (a.version.notes != b.version.notes) {
      changes.add(SetNotes(notes: b.version.notes));
    }
    if (a.version.bakingLossPercent != b.version.bakingLossPercent) {
      changes.add(SetBakingLoss(percent: b.version.bakingLossPercent));
    }
    if (a.version.finalWeightOverrideG != b.version.finalWeightOverrideG) {
      changes.add(
        SetFinalWeightOverride(grams: b.version.finalWeightOverrideG),
      );
    }
    if (a.version.servings != b.version.servings) {
      changes.add(SetServings(servings: b.version.servings));
    }

    // 2. + 3. Schritte
    changes.addAll(_diffSteps(a.steps, b.steps));

    // 4. - 7. Zutaten
    changes.addAll(_diffIngredients(a.ingredients, b.ingredients, targetRows ?? const []));

    return changes;
  }

  // -----------------------------------------------------------------
  // Schritte
  // -----------------------------------------------------------------

  static List<RecipeChange> _diffSteps(
    List<RecipeSnapshotStep> a,
    List<RecipeSnapshotStep> b,
  ) {
    final changes = <RecipeChange>[];
    final common = a.length < b.length ? a.length : b.length;

    for (var i = 0; i < common; i++) {
      final sa = a[i];
      final sb = b[i];
      final instructionChanged = sa.instruction != sb.instruction;
      final timerChanged = sa.timerSeconds != sb.timerSeconds;
      if (instructionChanged || timerChanged) {
        changes.add(
          SetStep(
            position: sb.position,
            instruction: instructionChanged ? sb.instruction : null,
            timerSeconds:
                timerChanged ? OptionalValue<int?>(sb.timerSeconds) : null,
          ),
        );
      }
    }

    if (a.length > b.length) {
      // RemoveStep in absteigender Position (Kapitel 15.4.3)
      for (var i = a.length; i > common; i--) {
        changes.add(RemoveStep(position: a[i - 1].position));
      }
    } else if (b.length > a.length) {
      // AddStep in aufsteigender Position (Kapitel 15.4.3)
      for (var i = common; i < b.length; i++) {
        final sb = b[i];
        changes.add(
          AddStep(
            position: sb.position,
            instruction: sb.instruction,
            timerSeconds: sb.timerSeconds,
          ),
        );
      }
    }

    return changes;
  }

  // -----------------------------------------------------------------
  // Zutaten
  // -----------------------------------------------------------------

  static String _normalizedName(RecipeSnapshotIngredient i) => i.name.trim().toLowerCase();

  static bool _hasBarcode(RecipeSnapshotIngredient i) => i.barcode != null && i.barcode!.isNotEmpty;

  /// Kapitel 15.1/15.2: zweistufig, jeweils greedy in Positionsreihenfolge
  /// -- erst gleicher (nicht leerer) Barcode, danach normalisierter Name.
  /// Liefert b-Position → zugeordnete a-Zutat.
  static Map<int, RecipeSnapshotIngredient> _match(
    List<RecipeSnapshotIngredient> a,
    List<RecipeSnapshotIngredient> b,
  ) {
    final matchedBToA = <int, RecipeSnapshotIngredient>{};
    final usedA = <int>{};

    void pass(bool Function(RecipeSnapshotIngredient x, RecipeSnapshotIngredient y) sameIngredient) {
      for (final bIng in b) {
        if (matchedBToA.containsKey(bIng.position)) continue;
        for (final aIng in a) {
          if (usedA.contains(aIng.position) || !sameIngredient(aIng, bIng)) continue;
          matchedBToA[bIng.position] = aIng;
          usedA.add(aIng.position);
          break;
        }
      }
    }

    pass((x, y) => _hasBarcode(x) && _hasBarcode(y) && x.barcode == y.barcode);
    pass((x, y) => _normalizedName(x) == _normalizedName(y));
    return matchedBToA;
  }

  /// Kapitel 15.3: Name, Marke oder verknüpfte Variante unterscheiden sich.
  /// Die Variante steht nicht im Format; verglichen werden ihre
  /// eingebetteten Daten (F5), Zahlen als Decimal-Wert (600 == 600.0).
  static bool _needsReplace(RecipeSnapshotIngredient x, RecipeSnapshotIngredient y) =>
      x.name != y.name ||
      x.brand != y.brand ||
      x.barcode != y.barcode ||
      x.per100g != y.per100g ||
      x.densityGPerMl != y.densityGPerMl ||
      x.gramsPerPiece != y.gramsPerPiece;

  static List<RecipeChange> _diffIngredients(
    List<RecipeSnapshotIngredient> unsortedA,
    List<RecipeSnapshotIngredient> unsortedB,
    List<RecipeIngredient> targetRows,
  ) {
    int byPosition(RecipeSnapshotIngredient x, RecipeSnapshotIngredient y) => x.position.compareTo(y.position);
    final a = [...unsortedA]..sort(byPosition);
    final b = [...unsortedB]..sort(byPosition);

    final matchedBToA = _match(a, b);
    final changes = <RecipeChange>[];

    // 4. Inhaltliche Änderungen zugeordneter Paare an ihrer a-Position
    // (Kapitel 15.4.4); verschieben weder Positionen noch Längen.
    for (final bIng in b) {
      final aIng = matchedBToA[bIng.position];
      if (aIng == null) continue;
      if (_needsReplace(aIng, bIng)) {
        changes.add(ReplaceIngredient(
          position: aIng.position,
          displayName: bIng.name,
          foodVariantId: linkedVariantIdFor(bIng, targetRows),
          quantity: bIng.quantity,
          unitCode: bIng.unit,
        ));
      } else if (aIng.quantity != bIng.quantity || aIng.unit != bIng.unit) {
        changes.add(SetIngredientQuantity(
          position: aIng.position,
          quantity: bIng.quantity,
          unitCode: aIng.unit != bIng.unit ? bIng.unit : null,
        ));
      }
    }

    // 5. RemoveIngredient, absteigende a-Position (Kapitel 15.4.5).
    final bPositionOfA = {for (final entry in matchedBToA.entries) entry.value.position: entry.key};
    final unmatchedA = a.where((ing) => !bPositionOfA.containsKey(ing.position)).toList().reversed;
    for (final ing in unmatchedA) {
      changes.add(RemoveIngredient(position: ing.position));
    }

    // 6. AddIngredient, aufsteigende b-Position (Kapitel 15.4.6).
    final unmatchedB = b.where((ing) => !matchedBToA.containsKey(ing.position)).toList();
    for (final ing in unmatchedB) {
      changes.add(AddIngredient(
        position: ing.position,
        displayName: ing.name,
        foodVariantId: linkedVariantIdFor(ing, targetRows),
        quantity: ing.quantity,
        unitCode: ing.unit,
        note: ing.note,
      ));
    }

    // 7. MoveIngredient zuletzt (Kapitel 15.4.7, DF-13): berechnet auf der
    // virtuellen Liste nach allen Remove/Add. Jedes Element wird mit seiner
    // Ziel-(b-)Position markiert; zugeordnete stehen noch in a-Reihenfolge,
    // hinzugefügte bereits an ihrer b-Position.
    final virtual = [for (final aIng in a) ?bPositionOfA[aIng.position]];
    for (final ing in unmatchedB) {
      virtual.insert(ing.position - 1, ing.position);
    }
    changes.addAll(_computeMoves(virtual, [for (final bIng in b) bIng.position]));

    return changes;
  }

  /// Minimale Folge von `MoveIngredient`, die [current] in [target]
  /// überführt. `from`/`to` beziehen sich -- wie in Kapitel 14.4 gefordert
  /// -- jeweils auf den Zustand unmittelbar vor dieser einzelnen Änderung
  /// (Selection-Algorithmus, ausgehend von Position 1).
  static List<RecipeChange> _computeMoves(List<int> current, List<int> target) {
    final changes = <RecipeChange>[];
    for (var i = 0; i < target.length; i++) {
      if (current[i] == target[i]) continue;
      final fromIdx = current.indexOf(target[i], i);
      changes.add(MoveIngredient(from: fromIdx + 1, to: i + 1));
      current.insert(i, current.removeAt(fromIdx));
    }
    return changes;
  }
}
