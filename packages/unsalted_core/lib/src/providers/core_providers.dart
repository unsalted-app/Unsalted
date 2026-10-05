// lib/src/providers/core_providers.dart
//
// Riverpod-Verdrahtung der Core-Komponenten (Kapitel 16.7, Schritt 7.3).
// Reine Verdrahtung, keine Geschäftslogik: jeder Provider konstruiert genau
// eine Implementierung und reicht Abhängigkeiten über `ref.watch(...)`
// weiter. Die Implementierungen selbst kennen Riverpod nicht (keine
// Riverpod-Referenz in Repository-/Service-Konstruktoren).
//
// ABWEICHUNG VON DER BEISPIEL-SIGNATUR IN KAPITEL 16.7: Das dortige
// Codebeispiel zeigt `DriftRecipeRepository(ref.watch(recipeDaoProvider))`
// (ein Argument) bzw. `DriftFoodRepository`/`DriftNutritionService`/
// `DriftSnapshotService(ref.watch(coreDatabaseProvider))`. Die tatsächlichen,
// bereits eingefrorenen Konstruktoren aus Schritt 6.3-6.6 verlangen mehr:
// `DriftRecipeRepository`/`DriftSnapshotService` brauchen zusätzlich
// `FoodDao` und `CoreDatabase` (Transaktionsgrenze, Kapitel 16.0.7),
// `DriftFoodRepository` braucht `FoodDao` statt `CoreDatabase`,
// `DriftNutritionService` braucht `RecipeDao` und `FoodDao` statt
// `CoreDatabase`. Kapitel 16.7 selbst ist laut Arbeitskarte 7.3 §4
// "sowie die konkreten Konstruktoren der Implementierungen" verbindlich —
// bei einem Widerspruch zählen die tatsächlichen, bereits getesteten
// Konstruktoren. Ein `foodDaoProvider` (in Kapitel 16.7 nicht erwähnt) wird
// dafür ergänzt, analog zu `recipeDaoProvider`.
//
// ABWEICHUNG BEI AT-05: `providers/` importiert zwangsläufig aus `data/`
// (u. a. `CoreDatabase`, `DriftRecipeDao`) -- das ist der ganze Zweck einer
// Verdrahtungsdatei. AT-05 wurde deshalb um eine Ausnahme für
// `src/providers/` erweitert, siehe docs/decisions.md.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/domain_events.dart';
import '../contracts/food_repository.dart';
import '../contracts/nutrition_service.dart';
import '../contracts/recipe_repository.dart';
import '../contracts/snapshot_service.dart';
import '../data/core_database.dart';
import '../data/daos/drift_food_dao.dart';
import '../data/daos/drift_recipe_dao.dart';
import '../data/daos/food_dao.dart';
import '../data/daos/recipe_dao.dart';
import '../data/domain_event_bus.dart';
import '../data/drift_food_repository.dart';
import '../data/drift_nutrition_service.dart';
import '../data/drift_recipe_repository.dart';
import '../data/drift_snapshot_service.dart';
import '../module/unsalted_module.dart';

/// Wirft absichtlich ohne Override (Kapitel 16.7): ein Start ohne
/// übergebenen `QueryExecutor` ist ein Programmierfehler, kein stiller
/// Fallback. Override ausschließlich in `apps/unsalted_app/lib/main.dart`.
final coreDatabaseProvider = Provider<CoreDatabase>((ref) {
  throw UnimplementedError(
    'coreDatabaseProvider wurde nicht überschrieben. Override in '
    'apps/unsalted_app/lib/main.dart via ProviderScope(overrides: [...]).',
  );
});

/// Standard leer, solange kein Teil (2-6) registriert wurde (Kapitel 16.7,
/// Kapitel 21).
final modulesProvider = Provider<List<UnsaltedModule>>((ref) => const []);

final recipeDaoProvider = Provider<RecipeDao>(
  (ref) => DriftRecipeDao(ref.watch(coreDatabaseProvider)),
);

final foodDaoProvider = Provider<FoodDao>(
  (ref) => DriftFoodDao(ref.watch(coreDatabaseProvider)),
);

/// Liefert das `RecipeRepository` auf der Datenbank aus [coreDatabaseProvider]
/// (Kapitel 16.7).
final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => DriftRecipeRepository(
    ref.watch(recipeDaoProvider),
    ref.watch(foodDaoProvider),
    ref.watch(coreDatabaseProvider),
  ),
);

/// Liefert das `FoodRepository` auf der Datenbank aus [coreDatabaseProvider]
/// (Kapitel 16.7).
final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => DriftFoodRepository(ref.watch(foodDaoProvider)),
);

/// Liefert den `NutritionService` auf der Datenbank aus [coreDatabaseProvider]
/// (Kapitel 16.7).
final nutritionServiceProvider = Provider<NutritionService>(
  (ref) => DriftNutritionService(
    ref.watch(recipeDaoProvider),
    ref.watch(foodDaoProvider),
  ),
);

/// Liefert den `SnapshotService` auf der Datenbank aus [coreDatabaseProvider]
/// (Kapitel 16.7).
final snapshotServiceProvider = Provider<SnapshotService>(
  (ref) => DriftSnapshotService(
    ref.watch(recipeDaoProvider),
    ref.watch(foodDaoProvider),
    ref.watch(coreDatabaseProvider),
  ),
);

/// Stream aller `DomainEvent`s des laufenden App-Prozesses (Kapitel 16.5);
/// frühere Events werden nicht nachgeliefert.
final domainEventsProvider = StreamProvider<DomainEvent>(
  (ref) => DomainEventBus.instance.events,
);
