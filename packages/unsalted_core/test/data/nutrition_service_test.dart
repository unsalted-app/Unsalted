// test/data/nutrition_service_test.dart
//
// Schritt 6.5: Draft/Snapshot-Fallunterscheidung, IT-02 (historische
// Stabilität), IT-04 (Snapshot-Wahrheit: Zeilen und snapshotJson liefern
// zum Zeitpunkt des Einfrierens dasselbe Ergebnis).
//
// Nutzt DriftRecipeRepository (Schritt 6.3) und DriftFoodRepository
// (Schritt 6.4) zum Aufbau der Testdaten, weil beide bereits eine korrekte,
// getestete Schreibschicht sind -- dieser Test prüft ausschließlich
// DriftNutritionService selbst, nicht erneut die Schreiblogik.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_nutrition_service.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';

void main() {
  late db.CoreDatabase database;
  late DriftRecipeDao recipeDao;
  late DriftFoodDao foodDao;
  late DriftRecipeRepository recipeRepo;
  late DriftFoodRepository foodRepo;
  late DriftNutritionService service;

  setUp(() {
    database = db.CoreDatabase(NativeDatabase.memory());
    recipeDao = DriftRecipeDao(database);
    foodDao = DriftFoodDao(database);
    recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);
    foodRepo = DriftFoodRepository(foodDao);
    service = DriftNutritionService(recipeDao, foodDao);
  });

  tearDown(() async {
    await database.close();
  });

  test('Draft: forVersion berechnet live aus den aktuellen Zeilen', () async {
    final variantId = await foodRepo.createVariant(NewFoodVariant(
      name: 'Mehl',
      brand: null,
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(300)),
    ));

    final recipeId = await recipeRepo.createRecipe(NewRecipe(title: 'Test'));
    final versionId = (await recipeDao.watchVersions(recipeId).first).first.id;

    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.zero,
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: 'i1',
          versionId: versionId,
          position: 1,
          foodVariantId: variantId,
          displayName: 'Mehl',
          quantity: Decimal.fromInt(200),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));

    final result = await service.forVersion(versionId);
    // 200 g bei 300 kcal/100g -> 600 kcal.
    expect(result.total.energyKcal, Decimal.fromInt(600));
    expect(result.rawWeightG, Decimal.fromInt(200));
  });

  test('Snapshot: forVersion liest ausschließlich aus snapshotJson', () async {
    final variantId = await foodRepo.createVariant(NewFoodVariant(
      name: 'Mehl',
      brand: null,
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(300)),
    ));

    final recipeId = await recipeRepo.createRecipe(NewRecipe(title: 'Test'));
    final versionId = (await recipeDao.watchVersions(recipeId).first).first.id;

    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.zero,
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: 'i1',
          versionId: versionId,
          position: 1,
          foodVariantId: variantId,
          displayName: 'Mehl',
          quantity: Decimal.fromInt(200),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));

    await recipeRepo.snapshotVersion(versionId);

    final result = await service.forVersion(versionId);
    expect(result.total.energyKcal, Decimal.fromInt(600));
    expect(result.rawWeightG, Decimal.fromInt(200));
  });

  test(
      'IT-04: Snapshot-Wahrheit -- Zeilen und snapshotJson liefern zum '
      'Zeitpunkt des Einfrierens dasselbe Ergebnis', () async {
    final variantId = await foodRepo.createVariant(NewFoodVariant(
      name: 'Zucker',
      brand: null,
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(400), carbsG: Decimal.fromInt(100)),
    ));

    final recipeId = await recipeRepo.createRecipe(NewRecipe(title: 'Test'));
    final versionId = (await recipeDao.watchVersions(recipeId).first).first.id;

    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.fromInt(10),
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: 'i1',
          versionId: versionId,
          position: 1,
          foodVariantId: variantId,
          displayName: 'Zucker',
          quantity: Decimal.fromInt(150),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));

    // Ergebnis direkt vor dem Einfrieren (Draft-Pfad, aus den Zeilen).
    final beforeFreeze = await service.forVersion(versionId);

    await recipeRepo.snapshotVersion(versionId);

    // Ergebnis direkt nach dem Einfrieren (Snapshot-Pfad, aus snapshotJson).
    final afterFreeze = await service.forVersion(versionId);

    expect(afterFreeze.total.energyKcal, beforeFreeze.total.energyKcal);
    expect(afterFreeze.rawWeightG, beforeFreeze.rawWeightG);
    expect(afterFreeze.finalWeightG, beforeFreeze.finalWeightG);
    expect(afterFreeze.per100g, beforeFreeze.per100g);
  });

  test(
      'IT-02: historische Stabilität -- Snapshot-Nährwerte bleiben nach '
      'Änderung der verknüpften FoodVariant unverändert', () async {
    final variantId = await foodRepo.createVariant(NewFoodVariant(
      name: 'Butter',
      brand: null,
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(700)),
    ));

    final recipeId = await recipeRepo.createRecipe(NewRecipe(title: 'Test'));
    final versionId = (await recipeDao.watchVersions(recipeId).first).first.id;

    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.zero,
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: 'i1',
          versionId: versionId,
          position: 1,
          foodVariantId: variantId,
          displayName: 'Butter',
          quantity: Decimal.fromInt(100),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));

    await recipeRepo.snapshotVersion(versionId);
    final snapshotResult = await service.forVersion(versionId);
    expect(snapshotResult.total.energyKcal, Decimal.fromInt(700));

    // Verknüpftes Lebensmittel nachträglich ändern.
    final variant = (await foodRepo.getById(variantId))!;
    await foodRepo.updateVariant(
      variant.copyWith(nutrients: NutrientSet(energyKcal: Decimal.fromInt(50))),
    );

    // Snapshot bleibt unverändert -- keine Neuberechnung mit dem neuen Wert.
    final afterChange = await service.forVersion(versionId);
    expect(afterChange.total.energyKcal, Decimal.fromInt(700));
  });

  test('preview greift nicht auf die Datenbank zu und berechnet direkt', () {
    final variant = FoodVariant(
      id: 'unsaved',
      name: 'Testzutat',
      source: FoodSource.custom,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(200)),
    );

    final result = service.preview(
      ingredients: [
        IngredientInput(
          displayName: 'Testzutat',
          quantity: Decimal.fromInt(50),
          unitCode: 'g',
          variant: variant,
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.total.energyKcal, Decimal.fromInt(100));
  });
}
