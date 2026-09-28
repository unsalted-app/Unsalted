// test/providers/core_providers_test.dart
//
// Schritt 7.3: Provider-Auflösung und Standardzustände von
// coreDatabaseProvider/modulesProvider (Arbeitskarte §10).

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/food_repository.dart';
import 'package:unsalted_core/src/contracts/nutrition_service.dart';
import 'package:unsalted_core/src/contracts/recipe_repository.dart';
import 'package:unsalted_core/src/contracts/snapshot_service.dart';
import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/daos/food_dao.dart';
import 'package:unsalted_core/src/data/daos/recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_nutrition_service.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/data/drift_snapshot_service.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';

void main() {
  test('coreDatabaseProvider wirft ohne Override (Kapitel 16.7)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Riverpod verpackt den Fehler des Provider-Erzeugers in eine
    // (nicht öffentlich exportierte) ProviderException -- deshalb wird hier
    // nur auf die durchgereichte Klartextnachricht geprüft, nicht auf den
    // konkreten Exception-Typ.
    expect(
      () => container.read(coreDatabaseProvider),
      throwsA(predicate<Object>(
        (e) => e.toString().contains('coreDatabaseProvider wurde nicht überschrieben'),
      )),
    );
  });

  test('modulesProvider ist ohne Override eine leere Liste (Kapitel 16.7)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(modulesProvider), isEmpty);
  });

  group('Provider-Auflösung mit überschriebenem coreDatabaseProvider', () {
    late CoreDatabase database;
    late ProviderContainer container;

    setUp(() {
      database = CoreDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [coreDatabaseProvider.overrideWithValue(database)],
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('recipeDaoProvider liefert eine DriftRecipeDao über RecipeDao', () {
      final dao = container.read(recipeDaoProvider);
      expect(dao, isA<RecipeDao>());
      expect(dao, isA<DriftRecipeDao>());
    });

    test('foodDaoProvider liefert eine DriftFoodDao über FoodDao', () {
      final dao = container.read(foodDaoProvider);
      expect(dao, isA<FoodDao>());
      expect(dao, isA<DriftFoodDao>());
    });

    test('recipeRepositoryProvider liefert DriftRecipeRepository über RecipeRepository', () {
      final repo = container.read(recipeRepositoryProvider);
      expect(repo, isA<RecipeRepository>());
      expect(repo, isA<DriftRecipeRepository>());
    });

    test('foodRepositoryProvider liefert DriftFoodRepository über FoodRepository', () {
      final repo = container.read(foodRepositoryProvider);
      expect(repo, isA<FoodRepository>());
      expect(repo, isA<DriftFoodRepository>());
    });

    test('nutritionServiceProvider liefert DriftNutritionService über NutritionService', () {
      final service = container.read(nutritionServiceProvider);
      expect(service, isA<NutritionService>());
      expect(service, isA<DriftNutritionService>());
    });

    test('snapshotServiceProvider liefert DriftSnapshotService über SnapshotService', () {
      final service = container.read(snapshotServiceProvider);
      expect(service, isA<SnapshotService>());
      expect(service, isA<DriftSnapshotService>());
    });

    test('domainEventsProvider liefert einen Stream<DomainEvent>', () {
      final asyncValue = container.read(domainEventsProvider);
      expect(asyncValue, isA<AsyncValue<Object?>>());
    });

    test('dieselbe ProviderContainer liefert für denselben Provider dieselbe Instanz', () {
      final first = container.read(recipeRepositoryProvider);
      final second = container.read(recipeRepositoryProvider);
      expect(identical(first, second), isTrue);
    });
  });
}
