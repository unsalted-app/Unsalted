// test/ui/foods/food_list_screen_test.dart
//
// Schritt 8.1, Bildschirm 9: Suche, leerer Zustand, Liste, Navigation.
// UI-41, UI-42, UI-44 (Teil 1.1b): Löschen per Wischen mit 5 s „Rückgängig“;
// ein gelöschtes Lebensmittel lässt Snapshots unverändert und zeigt im
// Entwurf den Hinweis aus 9.1b.
//
// NativeDatabase.memory() macht echte, nicht gefakte Async-Arbeit (FFI/
// Isolate-Kommunikation). Unter testWidgets() läuft Code standardmäßig in
// einer FakeAsync-Zone (für Timer-Steuerung) -- echte Async-Arbeit muss
// deshalb über WidgetTester.runAsync() laufen, sonst hängt der Test.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_nutrition_service.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart' as model;
import 'package:unsalted_core/src/ui/foods/food_editor_screen.dart';
import 'package:unsalted_core/src/ui/foods/food_list_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/ingredient_row.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/shared/undoable_deletion.dart';

Future<CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _pumpFoodList(WidgetTester tester, CoreDatabase database) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: const MaterialApp(home: FoodListScreen()),
  ));
  // Erste Stream-Emission der (echten, nicht gefakten) DB-Abfrage abwarten.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
}

/// Drifts QueryStream plant beim Abbestellen (StreamBuilder.dispose) einen
/// echten Zero-Duration-Timer zum Schließen. Baut die Testfläche ab, WÄHREND
/// noch aktiv gepumpt werden kann, und pumpt diesen Timer danach einmal aus
/// -- sonst meldet flutter_test am Testende "Timer is still pending even
/// after the widget tree was disposed", weil dieser Timer sonst erst nach
/// dem eigenen Invarianten-Check der Fake-Async-Zone feuert.
Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// Schließt [database] im Teardown, auch wenn der Test vorher scheitert
/// (Teil 1.1d). Nach einem roten Test lässt flutter_test den Widget-Baum stehen,
/// und Drift wartet beim Schließen auf seine Abbestell-Timer in der Fake-Zone,
/// die dann niemand mehr auspumpt -- der Lauf hinge. Deshalb erst den Baum
/// abbauen und auspumpen, dann schließen.
Future<void> _closeDatabase(WidgetTester tester, CoreDatabase database) async {
  await _disposeWidgetTree(tester);
  await tester.runAsync(database.close);
}

Future<String> _createFood(WidgetTester tester, CoreDatabase database, String name, int kcal) async {
  return (await tester.runAsync(() => DriftFoodRepository(DriftFoodDao(database)).createVariant(NewFoodVariant(
        name: name,
        brand: null,
        barcode: null,
        source: FoodSource.custom,
        sourceRef: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: NutrientSet(energyKcal: Decimal.fromInt(kcal)),
      ))))!;
}

/// `true`, solange das Lebensmittel nicht gelöscht ist.
Future<bool> _foodAlive(WidgetTester tester, CoreDatabase database, String id) async {
  final variant = await tester.runAsync(() => DriftFoodRepository(DriftFoodDao(database)).getById(id));
  // runAsync liefert auch bei einer Ausnahme null -- die darf es nicht geben.
  expect(tester.takeException(), isNull);
  return variant != null;
}

/// Lässt echte Datenbankarbeit (z. B. das Löschen nach Ablauf) durchlaufen.
Future<void> _settleDb(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}

Future<void> _swipeAway(WidgetTester tester, String name) async {
  await tester.drag(find.text(name), const Offset(-600, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('leerer Zustand zeigt "Eigenes Produkt anlegen"', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpFoodList(tester, database);

    expect(find.text('Keine Lebensmittel gefunden.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Eigenes Produkt anlegen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('vorhandene Lebensmittel werden gelistet', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.runAsync(() async {
      final repo = DriftFoodRepository(DriftFoodDao(database));
      await repo.createVariant(NewFoodVariant(
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
    });

    await _pumpFoodList(tester, database);

    expect(find.text('Mehl'), findsOneWidget);
    expect(find.text('Keine Lebensmittel gefunden.'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Suche filtert die Liste', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.runAsync(() async {
      final repo = DriftFoodRepository(DriftFoodDao(database));
      for (final name in ['Mehl', 'Zucker']) {
        await repo.createVariant(NewFoodVariant(
          name: name,
          brand: null,
          barcode: null,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: null,
          gramsPerPiece: null,
          servingSizeG: null,
          nutrients: const NutrientSet(),
        ));
      }
    });

    await _pumpFoodList(tester, database);
    expect(find.text('Mehl'), findsOneWidget);
    expect(find.text('Zucker'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Meh');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();

    expect(find.text('Mehl'), findsOneWidget);
    expect(find.text('Zucker'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('FAB öffnet den Editor im Erstellen-Modus', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpFoodList(tester, database);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FoodEditorScreen), findsOneWidget);
    expect(find.text('Lebensmittel anlegen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-41: Wischen blendet ein Lebensmittel sofort aus; erst nach 5 s ist es gelöscht', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final apfel = await _createFood(tester, database, 'Apfel', 52);
    await _createFood(tester, database, 'Birne', 57);
    await _pumpFoodList(tester, database);

    await _swipeAway(tester, 'Apfel');

    expect(find.text('Apfel'), findsNothing);
    expect(find.text('Birne'), findsOneWidget);
    expect(find.text('„Apfel“ gelöscht. Eingefrorene Versionen behalten ihre Nährwerte.'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Rückgängig'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await _settleDb(tester);
    expect(await _foodAlive(tester, database, apfel), isTrue);

    await tester.pump(const Duration(seconds: 2));
    await _settleDb(tester);
    expect(await _foodAlive(tester, database, apfel), isFalse);

    await tester.pumpAndSettle();
    expect(find.text('Apfel'), findsNothing);
    expect(find.text('Birne'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-42: „Rückgängig“ innerhalb von 5 s löscht kein Lebensmittel', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final apfel = await _createFood(tester, database, 'Apfel', 52);
    await _pumpFoodList(tester, database);

    await _swipeAway(tester, 'Apfel');
    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();
    expect(find.text('Apfel'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await _settleDb(tester);
    expect(await _foodAlive(tester, database, apfel), isTrue);
    expect(find.text('Apfel'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-44: gelöschtes Lebensmittel -- Entwurf zeigt den Hinweis aus 9.1b, Snapshot behält Nährwerte',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final mehl = await _createFood(tester, database, 'Mehl', 300);

    // V1 (200 g Mehl, verknüpft) eingefroren, V2 als Entwurf daraus.
    final recipeDao = DriftRecipeDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, DriftFoodDao(database), database);
    final nutrition = DriftNutritionService(recipeDao, DriftFoodDao(database));
    final (recipeId, v1, v2) = (await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Brot'));
      final v1 = (await recipeDao.watchVersions(recipeId).first).single.id;
      await recipeRepo.saveDraft(RecipeVersionDraft(
        id: v1,
        recipeId: recipeId,
        parentVersionId: null,
        versionIndex: 1,
        label: null,
        servings: null,
        bakingLossPercent: Decimal.zero,
        finalWeightOverrideG: null,
        notes: null,
        ingredients: [
          model.RecipeIngredient(id: 'i1', versionId: v1, position: 1, foodVariantId: mehl,
              displayName: 'Mehl', quantity: Decimal.fromInt(200), unitCode: 'g'),
        ],
        steps: const [],
      ));
      await recipeRepo.snapshotVersion(v1);
      final v2 = await recipeRepo.createDraftFrom(v1);
      return (recipeId, v1, v2);
    }))!;
    final before = (await tester.runAsync(() => nutrition.forVersion(v1)))!;
    expect(before.total.energyKcal, Decimal.fromInt(600));

    await _pumpFoodList(tester, database);
    await _swipeAway(tester, 'Mehl');
    await tester.pump(undoableDeletionDelay);
    await _settleDb(tester);
    expect(await _foodAlive(tester, database, mehl), isFalse);
    await _disposeWidgetTree(tester);

    // Der Snapshot rechnet unverändert mit seinen eingebetteten Werten.
    final after = (await tester.runAsync(() => nutrition.forVersion(v1)))!;
    expect(after.total.energyKcal, before.total.energyKcal);

    // Der Entwurf behält die Verknüpfung und zeigt den Hinweis (9.1b).
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(home: RecipeEditorScreen(recipeId: recipeId, versionId: v2)),
    ));
    await _settleDb(tester);
    expect(find.text(deletedVariantHint), findsOneWidget);

    await _disposeWidgetTree(tester);
  });
}
