// lib/src/recipe/recipe_version.dart
//
// Fachmodell für eine Rezeptversion (Kapitel 10.4, 12.1 der neuen
// Spezifikation). Trägt `id`, aber KEIN `createdAt` — kein UI-Bildschirm
// zeigt es, keine Sortierung braucht es (`versionIndex` reicht als
// Ordnungsfeld). `RecipeSnapshotV1.version.created_at` (Kapitel 13, Schritt
// 4.1) ist eine eigenständige Datenklasse und unabhängig davon vorhanden;
// die Data-Schicht liest den Wert beim Einfrieren direkt aus der DB-Zeile,
// nicht aus diesem Fachmodell. `snapshottedAt` bleibt die einzige bewusste
// Ausnahme (Kapitel 10.4: "ausdrücklich fachlich relevant", UI zeigt
// "eingefroren am …"). Siehe docs/decisions.md.
//
// DESIGN-ENTSCHEIDUNG (unverändert): `ingredients` und `steps` sind Teil
// dieser Klasse, weil RecipeRepository.getVersion() laut Kapitel 16.1
// "inklusive Zutaten und Schritte" liefert.

import 'package:decimal/decimal.dart';

import 'recipe_ingredient.dart';
import 'recipe_step.dart';

const Object _unset = Object();

enum VersionState {
  draft,
  snapshot;

  static VersionState fromCode(String code) => VersionState.values.byName(code);

  String get code => name;
}

class RecipeVersion {
  final String id;
  final String recipeId;

  /// Herkunft; darf lokal unbekannt sein (Fork, Kapitel 12.1).
  final String? parentVersionId;

  /// Fortlaufend pro Rezept ab 1, vom Repository vergeben (Kapitel 12.1).
  /// Alleinige Sortier- und Anzeigegrundlage ("V3" = versionIndex 3).
  final int versionIndex;

  /// Freier Zusatztext, rein informativ, keine Ordnungsfunktion.
  final String? label;

  final VersionState state;

  /// null oder >= 1, niemals 0 (Kapitel 11.3).
  final int? servings;

  /// 0 … 100, Standard 0 (Kapitel 11.3).
  final Decimal bakingLossPercent;

  /// > 0, hat Vorrang vor Backverlust (Kapitel 11.3).
  final Decimal? finalWeightOverrideG;

  final String? notes;

  /// Zeitpunkt des Einfrierens. Ausdrücklich fachlich relevant (UI zeigt
  /// "eingefroren am …", Bildschirm 7) — deshalb als einziger Zeitstempel
  /// im Fachmodell enthalten (Kapitel 10.4, Ausnahme).
  final DateTime? snapshottedAt;

  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  const RecipeVersion({
    required this.id,
    required this.recipeId,
    this.parentVersionId,
    required this.versionIndex,
    this.label,
    required this.state,
    this.servings,
    required this.bakingLossPercent,
    this.finalWeightOverrideG,
    this.notes,
    this.snapshottedAt,
    this.ingredients = const [],
    this.steps = const [],
  });

  RecipeVersion copyWith({
    String? id,
    String? recipeId,
    Object? parentVersionId = _unset,
    int? versionIndex,
    Object? label = _unset,
    VersionState? state,
    Object? servings = _unset,
    Decimal? bakingLossPercent,
    Object? finalWeightOverrideG = _unset,
    Object? notes = _unset,
    Object? snapshottedAt = _unset,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
  }) {
    return RecipeVersion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      parentVersionId:
          identical(parentVersionId, _unset) ? this.parentVersionId : parentVersionId as String?,
      versionIndex: versionIndex ?? this.versionIndex,
      label: identical(label, _unset) ? this.label : label as String?,
      state: state ?? this.state,
      servings: identical(servings, _unset) ? this.servings : servings as int?,
      bakingLossPercent: bakingLossPercent ?? this.bakingLossPercent,
      finalWeightOverrideG: identical(finalWeightOverrideG, _unset)
          ? this.finalWeightOverrideG
          : finalWeightOverrideG as Decimal?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      snapshottedAt:
          identical(snapshottedAt, _unset) ? this.snapshottedAt : snapshottedAt as DateTime?,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeVersion &&
        id == other.id &&
        recipeId == other.recipeId &&
        parentVersionId == other.parentVersionId &&
        versionIndex == other.versionIndex &&
        label == other.label &&
        state == other.state &&
        servings == other.servings &&
        bakingLossPercent == other.bakingLossPercent &&
        finalWeightOverrideG == other.finalWeightOverrideG &&
        notes == other.notes &&
        snapshottedAt == other.snapshottedAt &&
        _listEquals(ingredients, other.ingredients) &&
        _listEquals(steps, other.steps);
  }

  @override
  int get hashCode => Object.hash(
        id,
        recipeId,
        parentVersionId,
        versionIndex,
        label,
        state,
        servings,
        bakingLossPercent,
        finalWeightOverrideG,
        notes,
        snapshottedAt,
        Object.hashAll(ingredients),
        Object.hashAll(steps),
      );

  @override
  String toString() =>
      'RecipeVersion(id: $id, versionIndex: $versionIndex, state: ${state.code})';
}