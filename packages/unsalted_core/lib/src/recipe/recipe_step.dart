// lib/src/recipe/recipe_step.dart
//
// Fachmodell für einen Zubereitungsschritt (Kapitel 10.5 der neuen
// Spezifikation). Trägt `id`, aus demselben Grund wie RecipeIngredient
// (Drag-Reorder-Identität, unabhängig von `position`). Siehe
// docs/decisions.md.

const Object _unset = Object();

/// Ein Zubereitungsschritt einer Version (Kapitel 10.5).
class RecipeStep {
  /// Stabile Text-UUID; bleibt über mehrere `saveDraft`-Aufrufe erhalten
  /// (Kapitel 10.7).
  final String id;
  /// ID der Version, zu der der Schritt gehört.
  final String versionId;

  /// 1-basiert, lückenlos innerhalb einer Version (Kapitel 11.5).
  final int position;

  /// Anweisungstext.
  final String instruction;

  /// Optionaler Timer in Sekunden (Kapitel 11.5).
  final int? timerSeconds;

  /// Erzeugt einen Schritt; ohne [timerSeconds] hat er keinen Timer.
  const RecipeStep({
    required this.id,
    required this.versionId,
    required this.position,
    required this.instruction,
    this.timerSeconds,
  });

  /// Kopie mit geänderten Feldern; [timerSeconds] lässt sich ausdrücklich auf
  /// `null` setzen, nicht angegebene Felder bleiben unverändert.
  RecipeStep copyWith({
    String? id,
    String? versionId,
    int? position,
    String? instruction,
    Object? timerSeconds = _unset,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      versionId: versionId ?? this.versionId,
      position: position ?? this.position,
      instruction: instruction ?? this.instruction,
      timerSeconds: identical(timerSeconds, _unset) ? this.timerSeconds : timerSeconds as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeStep &&
        id == other.id &&
        versionId == other.versionId &&
        position == other.position &&
        instruction == other.instruction &&
        timerSeconds == other.timerSeconds;
  }

  @override
  int get hashCode => Object.hash(id, versionId, position, instruction, timerSeconds);

  @override
  String toString() => 'RecipeStep(id: $id, position: $position, instruction: $instruction)';
}