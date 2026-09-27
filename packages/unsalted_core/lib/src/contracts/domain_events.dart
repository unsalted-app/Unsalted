/// Kapitel 16.5. Auslösung: jede Repository-/Service-Methode, die laut
/// Kapitel 16.1/16.2 ein Event trägt, löst nach erfolgreichem
/// Transaktions-Commit genau eines aus — nie vor dem Commit, nie bei
/// Rollback. Persistenz: Events werden in Teil 1 nicht gespeichert,
/// ausschließlich In-Memory-Broadcast für die Laufzeit des App-Prozesses
/// (`DomainEventBus`, Schritt 6.2).
sealed class DomainEvent {
  final String id;
  final DateTime at;

  const DomainEvent({required this.id, required this.at});
}

class RecipeCreated extends DomainEvent {
  final String recipeId;
  final String versionId;

  const RecipeCreated({
    required super.id,
    required super.at,
    required this.recipeId,
    required this.versionId,
  });
}

class RecipeUpdated extends DomainEvent {
  final String recipeId;
  final String? versionId;

  const RecipeUpdated({
    required super.id,
    required super.at,
    required this.recipeId,
    this.versionId,
  });
}

class VersionSnapshotted extends DomainEvent {
  final String recipeId;
  final String versionId;

  const VersionSnapshotted({
    required super.id,
    required super.at,
    required this.recipeId,
    required this.versionId,
  });
}

class RecipeDeleted extends DomainEvent {
  final String recipeId;

  const RecipeDeleted({
    required super.id,
    required super.at,
    required this.recipeId,
  });
}

enum FoodChangeKind { created, updated, deleted }

class FoodChanged extends DomainEvent {
  final String variantId;
  final FoodChangeKind kind;

  const FoodChanged({
    required super.id,
    required super.at,
    required this.variantId,
    required this.kind,
  });
}