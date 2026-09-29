// test/ui/recipe_editor/recipe_editor_screen_test.dart
//
// Schritt 8.3, Bildschirm 3: UI-03 (Editor speichert und zeigt Live-
// Nährwerte), UI-04 (Editor verweigert Bearbeiten einer Snapshot-Version).

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _settle(WidgetTester tester, {int millis = 100}) async {
  await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: millis)));
  await tester.pump();
  await tester.pump();
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

Future<void> _pumpEditor(
  WidgetTester tester,
  db.CoreDatabase database, {
  required String recipeId,
  required String versionId,
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: MaterialApp(
      home: RecipeEditorScreen(recipeId: recipeId, versionId: versionId),
    ),
  ));
  await _settle(tester);
}

void main() {
  testWidgets(
      'UI-03: Editor zeigt Live-Nährwerte und speichert über saveDraft',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);
    final foodRepo = DriftFoodRepository(foodDao);

    final variantId = await tester.runAsync(() => foodRepo.createVariant(NewFoodVariant(
          name: 'Mehl',
          brand: null,
          barcode: null,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: null,
          gramsPerPiece: null,
          servingSizeG: null,
          nutrients: NutrientSet(energyKcal: Decimal.fromInt(300)),
        )));

    final recipeId = await tester.runAsync(() => recipeRepo.createRecipe(
          const NewRecipe(title: 'Testrezept'),
        ));
    final versionId = await tester.runAsync(
      () async => (await recipeDao.watchVersions(recipeId!).first).first.id,
    );

    await tester.runAsync(() => recipeRepo.saveDraft(RecipeVersionDraft(
          id: versionId!,
          recipeId: recipeId!,
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
        )));

    await _pumpEditor(tester, database, recipeId: recipeId!, versionId: versionId!);

    // 200 g bei 300 kcal/100g -> 600 kcal in der Live-Vorschau.
    expect(find.textContaining('600'), findsOneWidget);

    // Menge ändern -> Vorschau aktualisiert sich sofort (rein lokale
    // Berechnung über NutritionService.preview, kein DB-Zugriff).
    await tester.enterText(find.widgetWithText(TextField, 'Menge'), '100');
    await tester.pump();
    expect(find.textContaining('300'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Speichern'));
    await _settle(tester);

    final saved = await tester.runAsync(() => recipeDao.getIngredientsForVersion(versionId));
    expect(saved!.single.quantity, Decimal.fromInt(100));

    await _disposeWidgetTree(tester);
  });

  testWidgets('Zutat hinzufügen und entfernen aktualisiert die Liste', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final recipeId = await tester.runAsync(() => recipeRepo.createRecipe(
          const NewRecipe(title: 'Leer'),
        ));
    final versionId = await tester.runAsync(
      () async => (await recipeDao.watchVersions(recipeId!).first).first.id,
    );

    await _pumpEditor(tester, database, recipeId: recipeId!, versionId: versionId!);

    expect(find.widgetWithText(TextField, 'Name'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Zutat hinzufügen'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Name'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets(
      'UI-04: Editor ist bei state = snapshot schreibgeschützt und bietet '
      'createDraftFrom an', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final recipeId = await tester.runAsync(() => recipeRepo.createRecipe(
          const NewRecipe(title: 'Eingefroren'),
        ));
    final versionId = await tester.runAsync(
      () async => (await recipeDao.watchVersions(recipeId!).first).first.id,
    );
    await tester.runAsync(() => recipeRepo.saveDraft(RecipeVersionDraft(
          id: versionId!,
          recipeId: recipeId!,
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
              displayName: 'Salz',
              quantity: Decimal.fromInt(5),
              unitCode: 'g',
            ),
          ],
          steps: const [],
        )));
    await tester.runAsync(() => recipeRepo.snapshotVersion(versionId!));

    await _pumpEditor(tester, database, recipeId: recipeId!, versionId: versionId!);

    expect(find.text('Eingefroren — als neuen Entwurf kopieren?'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Name'), findsNothing);
    expect(find.text('Salz'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Speichern'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Kopieren'));
    await _settle(tester, millis: 150);
    await tester.pumpAndSettle();

    final versions = await tester.runAsync(() => recipeDao.watchVersions(recipeId).first);
    expect(versions!, hasLength(2));
    expect(versions.any((v) => v.state == 'draft'), isTrue);

    await _disposeWidgetTree(tester);
  });
}
