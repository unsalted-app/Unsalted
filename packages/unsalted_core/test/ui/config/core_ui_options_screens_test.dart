// test/ui/config/core_ui_options_screens_test.dart
//
// UC-02, UC-04, UC-05 auf Bildschirm-Ebene (Teil 1.2, C29): Die Bildschirme
// lesen coreUiOptionsProvider; ausgeblendete Felder behalten beim Speichern
// ihren Wert.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/ui/config/core_ui_options.dart';
import 'package:unsalted_core/src/ui/foods/food_editor_screen.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';

Decimal d(String v) => Decimal.parse(v);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump();
  }
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = (await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory())))!;
  addTearDown(() async {
    await _disposeWidgetTree(tester);
    await tester.runAsync(database.close);
  });
  return database;
}

DriftRecipeRepository _recipes(db.CoreDatabase database) =>
    DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);

Future<(String, String)> _seedDraft(WidgetTester tester, db.CoreDatabase database) async {
  return (await tester.runAsync(() async {
    final repo = _recipes(database);
    final recipeId = await repo.createRecipe(const NewRecipe(title: 'Brot'));
    final versionId = (await DriftRecipeDao(database).watchVersions(recipeId).first).first.id;
    await repo.saveDraft(RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: 1,
      label: null,
      servings: null,
      bakingLossPercent: d('10'),
      finalWeightOverrideG: d('900'),
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: 'i1',
          versionId: versionId,
          position: 1,
          displayName: 'Mehl',
          quantity: d('500'),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));
    return (recipeId, versionId);
  }))!;
}

Future<void> _pump(WidgetTester tester, db.CoreDatabase database, CoreUiOptions options, Widget home) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      coreDatabaseProvider.overrideWithValue(database),
      coreUiOptionsProvider.overrideWithValue(options),
    ],
    child: MaterialApp(home: home),
  ));
  await _settle(tester);
}

void main() {
  testWidgets('UC-02: Rezeptdetail blendet Nährwerte über den Provider aus', (tester) async {
    final database = await _openDatabase(tester);
    final (recipeId, _) = await _seedDraft(tester, database);
    await _pump(tester, database, const CoreUiOptions(hiddenNutrients: {'fiber_g', 'energy_kcal'}),
        RecipeDetailScreen(recipeId: recipeId));
    expect(find.text('Ballaststoffe (g)'), findsNothing);
    expect(find.text('Kalorien (kcal)'), findsOneWidget);
    expect(find.text('Fett (g)'), findsOneWidget);
    await _disposeWidgetTree(tester);
  });

  testWidgets('UC-04: Lebensmittel-Editor ohne Barcode-Feld, Barcode bleibt beim Speichern', (tester) async {
    final database = await _openDatabase(tester);
    final foods = DriftFoodRepository(DriftFoodDao(database));
    final id = (await tester.runAsync(() => foods.createVariant(NewFoodVariant(
          name: 'Haferflocken',
          brand: null,
          barcode: '4001234567890',
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: d('0.4'),
          gramsPerPiece: null,
          servingSizeG: d('40'),
          nutrients: NutrientSet(energyKcal: d('370'), fiberG: d('10')),
        ))))!;
    await _pump(
      tester,
      database,
      const CoreUiOptions(showBarcodeField: false, showAdvancedFields: false, hiddenNutrients: {'fiber_g'}),
      FoodEditorScreen(foodId: id),
    );
    expect(find.widgetWithText(AppTextField, 'Barcode'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Dichte (g/ml)'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Ballaststoffe (g)'), findsNothing);

    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Haferflocken zart');
    await tester.pump();
    await tester.tap(find.byType(AppFab));
    await _settle(tester);

    final saved = (await tester.runAsync(() => foods.getById(id)))!;
    expect(saved.name, 'Haferflocken zart');
    expect(saved.barcode, '4001234567890');
    expect(saved.densityGPerMl, d('0.4'));
    expect(saved.servingSizeG, d('40'));
    expect(saved.nutrients.fiberG, d('10'));
    await _disposeWidgetTree(tester);
  });

  testWidgets('UC-05: Rezept-Editor ohne erweiterte Felder, Werte bleiben beim Speichern', (tester) async {
    final database = await _openDatabase(tester);
    final (recipeId, versionId) = await _seedDraft(tester, database);
    await _pump(tester, database, const CoreUiOptions(showAdvancedFields: false),
        RecipeEditorScreen(recipeId: recipeId, versionId: versionId));
    expect(find.widgetWithText(AppTextField, 'Backverlust (%)'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Fertiggewicht-Override (g)'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Portionen'), findsOneWidget);

    await tester.enterText(find.widgetWithText(AppTextField, 'Portionen'), '4');
    await tester.pump();
    await tester.tap(find.widgetWithText(AppButton, 'Speichern'));
    await _settle(tester);

    final saved = (await tester.runAsync(() => _recipes(database).getVersion(versionId)))!;
    expect(saved.servings, 4);
    expect(saved.bakingLossPercent, d('10'));
    expect(saved.finalWeightOverrideG, d('900'));
    await _disposeWidgetTree(tester);
  });
}
