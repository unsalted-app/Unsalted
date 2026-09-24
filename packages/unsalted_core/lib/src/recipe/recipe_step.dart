// lib/src/recipe/recipe_step.dart
//
// Fachmodell für einen Zubereitungsschritt (Kapitel 10.5 der neuen
// Spezifikation). Trägt `id`, aus demselben Grund wie RecipeIngredient
// (Drag-Reorder-Identität, unabhängig von `position`). Siehe
// docs/decisions.md.

const Object _unset = Object();

class RecipeStep {
  final String id;
  final String versionId;

  /// 1-basiert, lückenlos innerhalb einer Version (Kapitel 11.5).
  final int position;

  final String instruction;

  /// Optionaler Timer in Sekunden (Kapitel 11.5).
  final int? timerSeconds;

  const RecipeStep({
    required this.id,
    required this.versionId,
    required this.position,
    required this.instruction,
    this.timerSeconds,
  });

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