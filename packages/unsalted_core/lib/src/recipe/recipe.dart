// lib/src/recipe/recipe.dart
//
// Fachmodell für ein Rezept (Kapitel 10.3 der neuen Spezifikation).
// Unveränderlich, keine Drift-Typen, keine JSON-Methoden (das macht der
// Codec in Phase 4). Trägt `id`, weil die Fachlogik es überall braucht.
// KEIN `ownerId` — reines Sync-Feld, wird nur von der Persistenzschicht
// gelesen/geschrieben (`assignOwner`), siehe docs/decisions.md.

const Object _unset = Object();

class Recipe {
  final String id;
  final String title;
  final String? description;

  /// Weicher Verweis auf die vom Nutzer gekürte "Sieger"-Version. Nur
  /// Snapshots dürfen Master werden (Kapitel 12.1).
  final String? masterVersionId;

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    this.masterVersionId,
  });

  Recipe copyWith({
    String? id,
    String? title,
    Object? description = _unset,
    Object? masterVersionId = _unset,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: identical(description, _unset) ? this.description : description as String?,
      masterVersionId:
          identical(masterVersionId, _unset) ? this.masterVersionId : masterVersionId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        masterVersionId == other.masterVersionId;
  }

  @override
  int get hashCode => Object.hash(id, title, description, masterVersionId);

  @override
  String toString() =>
      'Recipe(id: $id, title: $title, masterVersionId: $masterVersionId)';
}