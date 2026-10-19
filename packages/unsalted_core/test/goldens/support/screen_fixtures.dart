// test/goldens/support/screen_fixtures.dart
//
// Feste Beispieldaten für GL-02 (Teil 1.3, D01): drei Lebensmittel, ein
// Rezept mit drei Fassungen (V1 und V2 eingefroren, V2 Master, V3 Entwurf)
// und ein zweites Rezept für die Liste. Milch, Ei und Salz sind absichtlich
// nicht verknüpft (Hinweis „nicht berechenbar“, später die gestrichelte
// Unterstreichung). Keiner der fünf Bildschirme zeigt Zeitpunkte oder IDs,
// die Bilder sind deshalb unabhängig vom Lauf.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';

/// IDs der angelegten Daten.
typedef GoldenFixture = ({String recipeId, String v1, String v2, String v3, String flourId});

Decimal _d(String value) => Decimal.parse(value);

/// Öffnet eine leere In-Memory-Datenbank.
Future<db.CoreDatabase> openGoldenDatabase(WidgetTester tester) async =>
    (await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory())))!;

/// Baut den Widget-Baum ab und schließt [database] (Muster aus Teil 1.1d).
Future<void> closeGoldenDatabase(WidgetTester tester, db.CoreDatabase database) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
  await tester.runAsync(database.close);
}

/// Lässt Streams und Futures der Bildschirme ankommen.
Future<void> settleScreen(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump();
  }
}

NewFoodVariant _food(String name, String? brand, NutrientSet nutrients) => NewFoodVariant(
      name: name,
      brand: brand,
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: nutrients,
    );

/// Legt die Beispieldaten an.
Future<GoldenFixture> seedGoldenFixture(WidgetTester tester, db.CoreDatabase database) async {
  final recipeDao = DriftRecipeDao(database);
  final foodDao = DriftFoodDao(database);
  final recipes = DriftRecipeRepository(recipeDao, foodDao, database);
  final foods = DriftFoodRepository(foodDao);

  return (await tester.runAsync(() async {
    final flourId = await foods.createVariant(_food(
      'Weizenmehl Type 550',
      'Mühle Nord',
      NutrientSet(
        energyKcal: _d('343'),
        fatG: _d('1.0'),
        saturatedFatG: _d('0.2'),
        carbsG: _d('70.9'),
        sugarsG: _d('0.7'),
        fiberG: _d('4.0'),
        proteinG: _d('10.0'),
        saltG: _d('0.01'),
      ),
    ));
    final butterId = await foods.createVariant(_food(
      'Butter',
      null,
      NutrientSet(
        energyKcal: _d('741'),
        fatG: _d('82.0'),
        saturatedFatG: _d('55.0'),
        carbsG: _d('0.6'),
        sugarsG: _d('0.6'),
        proteinG: _d('0.7'),
        saltG: _d('0.03'),
      ),
    ));
    final sugarId = await foods.createVariant(_food(
      'Zucker',
      null,
      NutrientSet(energyKcal: _d('400'), carbsG: _d('100'), sugarsG: _d('100')),
    ));

    final recipeId = await recipes.createRecipe(
      const NewRecipe(title: 'Hefezopf klassisch', description: 'Süßer Zopf für das Wochenende.'),
    );
    final v1 = (await recipeDao.watchVersions(recipeId).first).first.id;
    await recipes.saveDraft(RecipeVersionDraft(
      id: v1,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: 8,
      bakingLossPercent: _d('10'),
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
            id: 'gl-i1', versionId: v1, position: 1, foodVariantId: flourId,
            displayName: 'Weizenmehl Type 550', quantity: _d('500'), unitCode: 'g'),
        RecipeIngredient(
            id: 'gl-i2', versionId: v1, position: 2,
            displayName: 'Milch', quantity: _d('250'), unitCode: 'ml', note: 'lauwarm'),
        RecipeIngredient(
            id: 'gl-i3', versionId: v1, position: 3, foodVariantId: butterId,
            displayName: 'Butter', quantity: _d('80'), unitCode: 'g'),
        RecipeIngredient(
            id: 'gl-i4', versionId: v1, position: 4, foodVariantId: sugarId,
            displayName: 'Zucker', quantity: _d('60'), unitCode: 'g'),
        RecipeIngredient(
            id: 'gl-i5', versionId: v1, position: 5,
            displayName: 'Ei', quantity: _d('1'), unitCode: 'piece'),
      ],
      steps: [
        RecipeStep(id: 'gl-s1', versionId: v1, position: 1,
            instruction: 'Milch erwärmen und die Butter darin schmelzen.', timerSeconds: 300),
        RecipeStep(id: 'gl-s2', versionId: v1, position: 2,
            instruction: 'Alle Zutaten 10 Minuten kneten, dann abgedeckt ruhen lassen.', timerSeconds: 600),
        RecipeStep(id: 'gl-s3', versionId: v1, position: 3,
            instruction: 'Zu einem Zopf flechten und backen.', timerSeconds: 2100),
      ],
    ));
    await recipes.snapshotVersion(v1);

    // V2: mehr Mehl und Butter, Salz neu, 10 statt 8 Portionen.
    final v2 = await recipes.createDraftFrom(v1);
    final copied = (await recipes.getVersion(v2))!;
    final rows = [
      for (final row in copied.ingredients)
        switch (row.displayName) {
          'Weizenmehl Type 550' => row.copyWith(quantity: _d('550')),
          'Butter' => row.copyWith(quantity: _d('100')),
          _ => row,
        },
    ];
    await recipes.saveDraft(RecipeVersionDraft(
      id: v2,
      recipeId: recipeId,
      parentVersionId: v1,
      versionIndex: 2,
      label: 'mit Vorteig',
      servings: 10,
      bakingLossPercent: _d('10'),
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        ...rows,
        RecipeIngredient(
            id: 'gl-i6', versionId: v2, position: rows.length + 1,
            displayName: 'Salz', quantity: _d('5'), unitCode: 'g'),
      ],
      steps: copied.steps,
    ));
    await recipes.snapshotVersion(v2);
    await recipes.setMasterVersion(recipeId, v2);

    // V3: Entwurf aus V2, unverändert.
    final v3 = await recipes.createDraftFrom(v2);

    final otherId = await recipes.createRecipe(const NewRecipe(title: 'Roggenbrot'));
    final otherVersion = (await recipeDao.watchVersions(otherId).first).first.id;
    await recipes.saveDraft(RecipeVersionDraft(
      id: otherVersion,
      recipeId: otherId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.zero,
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
            id: 'gl-r1', versionId: otherVersion, position: 1,
            displayName: 'Roggenmehl', quantity: _d('400'), unitCode: 'g'),
      ],
      steps: const [],
    ));

    return (recipeId: recipeId, v1: v1, v2: v2, v3: v3, flourId: flourId);
  }))!;
}
