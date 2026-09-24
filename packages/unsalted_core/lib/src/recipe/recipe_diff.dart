import 'recipe_change.dart';
import 'recipe_snapshot_v1.dart';

/// Vergleicht zwei Snapshots und liefert die `RecipeChange`-Liste, die `a`
/// in `b` überführt (Kapitel 15). Reine Funktion: keine Datenbank, kein
/// Flutter, kein veränderlicher Zustand.
///
/// Bekannte, bewusste Einschränkungen (siehe Chat-Erklärung):
/// - `foodVariantId` wird bei erzeugten `AddIngredient`/`ReplaceIngredient`
///   immer `null` gesetzt, weil `RecipeSnapshotIngredient` keine
///   `foodVariantId` führt (Kapitel 13.1) — nur eine eingebettete
///   Nährwert-Kopie (`per100g`).
/// - Eine reine Änderung von `RecipeSnapshotIngredient.note` wird nicht
///   erkannt, weil es dafür keinen passenden `RecipeChange`-Typ gibt
///   (`ReplaceIngredient` trägt kein `note`-Feld).
class RecipeDiff {
  const RecipeDiff._();

  static List<RecipeChange> between(RecipeSnapshotV1 a, RecipeSnapshotV1 b) {
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
    changes.addAll(_diffIngredients(a.ingredients, b.ingredients));

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

  static String _identityKey(RecipeSnapshotIngredient i) {
    final barcode = i.barcode;
    if (barcode != null && barcode.isNotEmpty) return 'barcode:$barcode';
    return 'name:${i.name.trim().toLowerCase()}';
  }

  static List<RecipeChange> _diffIngredients(
    List<RecipeSnapshotIngredient> a,
    List<RecipeSnapshotIngredient> b,
  ) {
    // Greedy positionsweise Zuordnung nach Identitätsschlüssel
    // (Kapitel 15.1 / 15.2): je Schlüssel wird das i-te Vorkommen in `a`
    // dem i-ten Vorkommen in `b` zugeordnet.
    final candidatesByKey = <String, List<RecipeSnapshotIngredient>>{};
    for (final ing in a) {
      candidatesByKey.putIfAbsent(_identityKey(ing), () => []).add(ing);
    }
    final consumedCount = <String, int>{};

    final matchedAPositionToB = <int, RecipeSnapshotIngredient>{};
    final matchedBPositionToA = <int, RecipeSnapshotIngredient>{};

    for (final bIng in b) {
      final key = _identityKey(bIng);
      final candidates = candidatesByKey[key];
      final idx = consumedCount[key] ?? 0;
      if (candidates != null && idx < candidates.length) {
        final aIng = candidates[idx];
        consumedCount[key] = idx + 1;
        matchedAPositionToB[aIng.position] = bIng;
        matchedBPositionToA[bIng.position] = aIng;
      }
    }

    final changes = <RecipeChange>[];

    // 4. Inhaltliche Änderungen an zugeordneten Paaren, aufsteigende
    // b-Position (Kapitel 15.4.4).
    final matchedBPositions = matchedBPositionToA.keys.toList()..sort();
    for (final bPos in matchedBPositions) {
      final aIng = matchedBPositionToA[bPos]!;
      final bIng = b.firstWhere((e) => e.position == bPos);

      // Name oder Marke unterscheiden sich zusätzlich zur reinen Menge
      // -> ReplaceIngredient (Kapitel 15.3).
      final identityChangedBeyondQuantity =
          aIng.name != bIng.name || aIng.brand != bIng.brand;

      if (identityChangedBeyondQuantity) {
        changes.add(
          ReplaceIngredient(
            position: aIng.position,
            displayName: bIng.name,
            foodVariantId: null,
            quantity: bIng.quantity,
            unitCode: bIng.unit,
          ),
        );
      } else if (aIng.quantity != bIng.quantity || aIng.unit != bIng.unit) {
        changes.add(
          SetIngredientQuantity(
            position: aIng.position,
            quantity: bIng.quantity,
            unitCode: aIng.unit != bIng.unit ? bIng.unit : null,
          ),
        );
      }
    }

    // 5. RemoveIngredient, absteigende a-Position (Kapitel 15.4.5).
    final unmatchedA = a
        .where((ing) => !matchedAPositionToB.containsKey(ing.position))
        .toList()
      ..sort((x, y) => y.position.compareTo(x.position));
    for (final ing in unmatchedA) {
      changes.add(RemoveIngredient(position: ing.position));
    }

    // 6. AddIngredient, aufsteigende b-Position (Kapitel 15.4.6).
    final unmatchedB = b
        .where((ing) => !matchedBPositionToA.containsKey(ing.position))
        .toList()
      ..sort((x, y) => x.position.compareTo(y.position));
    for (final ing in unmatchedB) {
      changes.add(
        AddIngredient(
          position: ing.position,
          displayName: ing.name,
          foodVariantId: null,
          quantity: ing.quantity,
          unitCode: ing.unit,
          note: ing.note,
        ),
      );
    }

    // 7. MoveIngredient zuletzt, für verbleibende reine Verschiebungen
    // (Kapitel 15.4.7). Nur berechenbar, wenn kein Add/Remove nötig war —
    // dann ist a -> b eine reine Permutation derselben Zutaten.
    if (unmatchedA.isEmpty && unmatchedB.isEmpty) {
      changes.addAll(_computeMoves(a, b, matchedAPositionToB));
    }

    return changes;
  }

  /// Minimale Folge von `MoveIngredient`, um die Reihenfolge von `a` in die
  /// von `b` zu überführen. `from`/`to` beziehen sich — wie in Kapitel 14.4
  /// gefordert — jeweils auf den Zustand unmittelbar vor dieser einzelnen
  /// Änderung (Selection-Algorithmus, ausgehend von Position 1).
  static List<RecipeChange> _computeMoves(
    List<RecipeSnapshotIngredient> a,
    List<RecipeSnapshotIngredient> b,
    Map<int, RecipeSnapshotIngredient> matchedAPositionToB,
  ) {
    final n = a.length;
    if (n == 0) return const [];

    // current[k] = ursprüngliche a-Position des Elements, das gedanklich
    // gerade am (0-basierten) Index k steht.
    final current = a.map((e) => e.position).toList();

    // target[k] = ursprüngliche a-Position des Elements, das am Ende an
    // (0-basiertem) Index k stehen soll.
    final bPositionToAPosition = <int, int>{
      for (final entry in matchedAPositionToB.entries)
        entry.value.position: entry.key,
    };
    final target = List<int>.generate(
      n,
      (k) => bPositionToAPosition[b[k].position]!,
    );

    final changes = <RecipeChange>[];
    for (var i = 0; i < n; i++) {
      if (current[i] == target[i]) continue;
      final fromIdx = current.indexOf(target[i], i);
      if (fromIdx == i) continue;
      changes.add(MoveIngredient(from: fromIdx + 1, to: i + 1));
      final tag = current.removeAt(fromIdx);
      current.insert(i, tag);
    }
    return changes;
  }
}