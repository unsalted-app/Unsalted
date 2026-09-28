// test/data/snapshot_service_test.dart
//
// Schritt 6.6: IT-01, IT-03, IT-05 (Kapitel 23.5), GD-11, GD-12 (Kapitel
// 23.2/13.5.1/13.6). Nutzt DriftRecipeRepository/DriftFoodRepository
// (bereits getestete Schreibschicht) zum Aufbau des "eigenen" Rezepts und
// hand-gebaute JSON-Strings (Format nach Kapitel 13.1) für die reinen
// Import-Tests (GD-11/GD-12/IT-03/IT-05), wo die genauen Rohdaten wichtig
// sind.
//
// Die eingebetteten `nutrition`-Blöcke der hand-gebauten JSON-Strings sind
// bewusst immer "unbekannt" (alle Felder null) -- DriftSnapshotService
// prüft laut Kapitel 13.5/13.5.1 nicht, ob dieser Block zur Zutatenliste
// passt, und DriftNutritionService.forVersion berechnet die tatsächlichen
// Nährwerte ohnehin aus den Zutaten neu (Kapitel 17, Schritt 6.5), nicht
// aus diesem Block.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_nutrition_service.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/data/drift_snapshot_service.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';

Map<String, dynamic> _emptyNutrients() => {
      'energy_kcal': null,
      'fat_g': null,
      'saturated_fat_g': null,
      'carbs_g': null,
      'sugars_g': null,
      'fiber_g': null,
      'protein_g': null,
      'salt_g': null,
      'extra': <String, dynamic>{},
    };

Map<String, dynamic> _per100gMap(String? energyKcal) => {
      'energy_kcal': energyKcal,
      'fat_g': null,
      'saturated_fat_g': null,
      'carbs_g': null,
      'sugars_g': null,
      'fiber_g': null,
      'protein_g': null,
      'salt_g': null,
      'extra': <String, dynamic>{},
    };

/// Baut einen strukturell gültigen Snapshot-JSON-String (Kapitel 13.1) mit
/// einer einzigen Zutat. Der `nutrition`-Block ist immer "unbekannt" --
/// siehe Datei-Kommentar oben.
String buildSnapshotJson({
  String recipeId = 'ext-r1',
  String recipeTitle = 'Externes Rezept',
  String versionId = 'ext-v1',
  String ingredientName = 'Mehl',
  String? ingredientBrand,
  String? ingredientBarcode,
  String quantity = '200',
  String unit = 'g',
  String? per100gEnergyKcal,
  bool withVariant = true,
  String bakingLossPercent = '0',
  Map<String, dynamic>? extraTopLevelField,
}) {
  final map = <String, dynamic>{
    'format': 'unsalted_recipe_snapshot',
    'format_version': 1,
    'recipe': {'id': recipeId, 'title': recipeTitle, 'description': null},
    'version': {
      'id': versionId,
      'parent_version_id': null,
      'version_index': 1,
      'label': null,
      'servings': null,
      'baking_loss_percent': bakingLossPercent,
      'final_weight_override_g': null,
      'notes': null,
      'created_at': '2026-01-01T00:00:00.000Z',
      'snapshotted_at': '2026-01-01T00:00:00.000Z',
    },
    'ingredients': [
      {
        'position': 1,
        'name': ingredientName,
        'brand': ingredientBrand,
        'barcode': ingredientBarcode,
        'quantity': quantity,
        'unit': unit,
        'grams': quantity,
        'note': null,
        'density_g_per_ml': null,
        'grams_per_piece': null,
        'per100g': withVariant ? _per100gMap(per100gEnergyKcal) : null,
      }
    ],
    'steps': <Map<String, dynamic>>[],
    'nutrition': {
      'raw_weight_g': quantity,
      'final_weight_g': quantity,
      'total': _emptyNutrients(),
      'per100g': _emptyNutrients(),
      'incomplete': <String>[],
      'not_calculable': <String>[],
    },
  };
  if (extraTopLevelField != null) map.addAll(extraTopLevelField);
  return jsonEncode(map);
}

void main() {
  // IT-03 öffnet absichtlich zwei CoreDatabase-Instanzen gleichzeitig, um
  // zwei getrennte Geräte zu simulieren -- keine echte Race Condition, da
  // jede ihren eigenen In-Memory-QueryExecutor hat.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late db.CoreDatabase database;
  late DriftRecipeDao recipeDao;
  late DriftFoodDao foodDao;
  late DriftRecipeRepository recipeRepo;
  late DriftFoodRepository foodRepo;
  late DriftNutritionService nutritionService;
  late DriftSnapshotService snapshotService;

  setUp(() {
    database = db.CoreDatabase(NativeDatabase.memory());
    recipeDao = DriftRecipeDao(database);
    foodDao = DriftFoodDao(database);
    recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);
    foodRepo = DriftFoodRepository(foodDao);
    nutritionService = DriftNutritionService(recipeDao, foodDao);
    snapshotService = DriftSnapshotService(recipeDao, foodDao, database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
      'IT-01: anlegen -> Zutaten -> einfrieren -> exportieren -> importieren '
      '-> Nährwerte identisch', () async {
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

    final recipeId = await recipeRepo.createRecipe(NewRecipe(title: 'Original'));
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

    final originalNutrition = await nutritionService.forVersion(versionId);

    final jsonString = await snapshotService.exportVersionAsJsonString(versionId);
    final importedRecipeId = await snapshotService.importJsonString(jsonString);

    expect(importedRecipeId, isNot(recipeId));
    final importedVersionId = (await recipeDao.watchVersions(importedRecipeId).first).first.id;
    final importedNutrition = await nutritionService.forVersion(importedVersionId);

    expect(importedNutrition.total.energyKcal, originalNutrition.total.energyKcal);
    expect(importedNutrition.rawWeightG, originalNutrition.rawWeightG);
  });

  test(
      'IT-03: Fork-Simulation -- Import ohne die zugehörigen Varianten legt '
      'sie mit source = import neu an, Nährwerte stimmen überein', () async {
    // "Gerät A": eigene, gefüllte Datenbank.
    final dbA = db.CoreDatabase(NativeDatabase.memory());
    final recipeDaoA = DriftRecipeDao(dbA);
    final foodDaoA = DriftFoodDao(dbA);
    final recipeRepoA = DriftRecipeRepository(recipeDaoA, foodDaoA, dbA);
    final foodRepoA = DriftFoodRepository(foodDaoA);
    final nutritionServiceA = DriftNutritionService(recipeDaoA, foodDaoA);
    final snapshotServiceA = DriftSnapshotService(recipeDaoA, foodDaoA, dbA);

    final variantIdA = await foodRepoA.createVariant(NewFoodVariant(
      name: 'Zucker',
      brand: 'Marke A',
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(400)),
    ));
    final recipeIdA = await recipeRepoA.createRecipe(NewRecipe(title: 'Kuchen'));
    final versionIdA = (await recipeDaoA.watchVersions(recipeIdA).first).first.id;
    await recipeRepoA.saveDraft(RecipeVersionDraft(
      id: versionIdA,
      recipeId: recipeIdA,
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
          versionId: versionIdA,
          position: 1,
          foodVariantId: variantIdA,
          displayName: 'Zucker',
          quantity: Decimal.fromInt(100),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));
    await recipeRepoA.snapshotVersion(versionIdA);
    final originalNutrition = await nutritionServiceA.forVersion(versionIdA);
    final exported = await snapshotServiceA.exportVersionAsJsonString(versionIdA);
    await dbA.close();

    // "Gerät B": frische, leere Datenbank -- kennt die Variante nicht.
    expect(await foodDao.watchAll().first, isEmpty);
    final importedRecipeId = await snapshotService.importJsonString(exported);

    final variantsB = await foodDao.watchAll().first;
    expect(variantsB, hasLength(1));
    expect(variantsB.first.source, 'import');
    expect(variantsB.first.name, 'Zucker');

    final importedVersionId = (await recipeDao.watchVersions(importedRecipeId).first).first.id;
    final importedNutrition = await nutritionService.forVersion(importedVersionId);
    expect(importedNutrition.total.energyKcal, originalNutrition.total.energyKcal);
  });

  test(
      'IT-05: Import desselben JSON zweimal -> zwei unabhängige Rezepte, '
      'aber nur ein Satz Lebensmittel-Varianten', () async {
    final json = buildSnapshotJson(
      ingredientName: 'Salz',
      ingredientBarcode: '4000000000000',
      per100gEnergyKcal: '0',
    );

    final firstRecipeId = await snapshotService.importJsonString(json);
    expect(await foodDao.watchAll().first, hasLength(1));

    final secondRecipeId = await snapshotService.importJsonString(json);
    expect(await foodDao.watchAll().first, hasLength(1)); // kein Duplikat

    expect(secondRecipeId, isNot(firstRecipeId));
    final recipes = await recipeDao.watchRecipes().first;
    expect(recipes.map((r) => r.id).toSet(), {firstRecipeId, secondRecipeId});
  });

  test('GD-11: semantisch ungültige Snapshot-Daten werden vor dem Schreiben abgelehnt',
      () async {
    final invalidJson = buildSnapshotJson(bakingLossPercent: '150');

    final recipesBefore = await recipeDao.watchRecipes().first;

    await expectLater(
      snapshotService.importJsonString(invalidJson),
      throwsA(isA<ImportFormatException>()),
    );

    final recipesAfter = await recipeDao.watchRecipes().first;
    expect(recipesAfter.length, recipesBefore.length);
  });

  test(
      'GD-12: unbekannte Felder bleiben im gespeicherten Original-JSON für '
      'den String-Export erhalten', () async {
    final json = buildSnapshotJson(
      extraTopLevelField: {'unknown_future_field': 'bitte erhalten'},
    );

    final recipeId = await snapshotService.importJsonString(json);
    final versionId = (await recipeDao.watchVersions(recipeId).first).first.id;

    final exported = await snapshotService.exportVersionAsJsonString(versionId);
    final decoded = jsonDecode(exported) as Map<String, dynamic>;

    expect(decoded['unknown_future_field'], 'bitte erhalten');
  });
}
