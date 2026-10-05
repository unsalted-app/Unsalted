/// Kapitel 16.5. Auslösung: jede Repository-/Service-Methode, die laut
/// Kapitel 16.1/16.2 ein Event trägt, löst nach erfolgreichem
/// Transaktions-Commit genau eines aus — nie vor dem Commit, nie bei
/// Rollback. Persistenz: Events werden in Teil 1 nicht gespeichert,
/// ausschließlich In-Memory-Broadcast für die Laufzeit des App-Prozesses
/// (`DomainEventBus`, Schritt 6.2).
sealed class DomainEvent {
  /// Eindeutige ID des Events.
  final String id;
  /// Zeitpunkt der Auslösung (UTC).
  final DateTime at;

  const DomainEvent({required this.id, required this.at});
}

/// Ein Rezept wurde angelegt: `createRecipe` oder ein Import (Kapitel 13.6,
/// 16.1).
class RecipeCreated extends DomainEvent {
  /// ID des neuen Rezepts.
  final String recipeId;
  /// ID seiner ersten Version.
  final String versionId;

  /// Erzeugt das Event; die Repositories lösen es nach dem Commit aus.
  const RecipeCreated({
    required super.id,
    required super.at,
    required this.recipeId,
    required this.versionId,
  });
}

/// Ein Rezept oder eine seiner Versionen wurde geändert (Kapitel 16.1):
/// `updateRecipe`, `saveDraft`, `createDraftFrom`, `applyChangesAsNewDraft`,
/// `setMasterVersion`, `deleteVersion`.
class RecipeUpdated extends DomainEvent {
  /// ID des geänderten Rezepts.
  final String recipeId;
  /// Gesetzt bei `saveDraft` (der gespeicherte Draft) und bei
  /// `createDraftFrom`/`applyChangesAsNewDraft` (die neue Version); bei
  /// `updateRecipe`, `setMasterVersion` und `deleteVersion` `null`.
  final String? versionId;

  /// Erzeugt das Event; die Repositories lösen es nach dem Commit aus.
  const RecipeUpdated({
    required super.id,
    required super.at,
    required this.recipeId,
    this.versionId,
  });
}

/// Eine Version wurde eingefroren (`snapshotVersion`, Kapitel 12.3).
class VersionSnapshotted extends DomainEvent {
  /// ID des Rezepts.
  final String recipeId;
  /// ID der eingefrorenen Version.
  final String versionId;

  /// Erzeugt das Event; die Repositories lösen es nach dem Commit aus.
  const VersionSnapshotted({
    required super.id,
    required super.at,
    required this.recipeId,
    required this.versionId,
  });
}

/// Ein Rezept wurde samt seiner Versionen weich gelöscht (`softDeleteRecipe`,
/// Kapitel 12.5).
class RecipeDeleted extends DomainEvent {
  /// ID des gelöschten Rezepts.
  final String recipeId;

  /// Erzeugt das Event; die Repositories lösen es nach dem Commit aus.
  const RecipeDeleted({
    required super.id,
    required super.at,
    required this.recipeId,
  });
}

/// Art der Änderung eines Lebensmittels in [FoodChanged]: `created`
/// (`createVariant`), `updated` (`updateVariant`), `deleted`
/// (`softDeleteVariant`) (Kapitel 16.2).
enum FoodChangeKind {
  /// Lebensmittel angelegt (`createVariant`).
  created,
  /// Lebensmittel geändert (`updateVariant`).
  updated,
  /// Lebensmittel weich gelöscht (`softDeleteVariant`).
  deleted
}

/// Ein Lebensmittel wurde angelegt, geändert oder weich gelöscht
/// (Kapitel 16.2).
class FoodChanged extends DomainEvent {
  /// ID des betroffenen Lebensmittels.
  final String variantId;
  /// Art der Änderung.
  final FoodChangeKind kind;

  /// Erzeugt das Event; die Repositories lösen es nach dem Commit aus.
  const FoodChanged({
    required super.id,
    required super.at,
    required this.variantId,
    required this.kind,
  });
}