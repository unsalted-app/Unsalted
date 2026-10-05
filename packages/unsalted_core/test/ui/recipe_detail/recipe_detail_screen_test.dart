// test/ui/recipe_detail/recipe_detail_screen_test.dart
//
// Schritt 8.5, Bildschirm 4: EX-01 (RecipeDetailSection erscheint),
// EX-02 (RecipeAction erscheint in der AppBar), EX-04 (order-Reihenfolge
// über mehrere Module hinweg), EX-05 (Seite funktioniert ohne registrierte
// Module). EX-03 (SettingsEntry) ist erst mit dem Einstellungen-Bildschirm
// (Schritt 8.7) testbar, siehe docs/status.md. Nachtrag 8.8a: feste
// Core-Aktionen "Versionen" und "Bearbeiten" in der AppBar. UI-28
// (Fehlerbehebung 9.2a, Befund 4): Mengenrechner unter der Nährwerttabelle.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/module/extension_types.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/module/unsalted_module.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';
import 'package:unsalted_core/src/ui/nutrition/amount_calculator.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_table.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/versions/version_list_screen.dart';

class _FakeModule implements UnsaltedModule {
  final List<RecipeDetailSection> sections;
  final List<RecipeAction> actions;

  const _FakeModule({this.sections = const [], this.actions = const []});

  @override
  String get id => 'fake';
  @override
  List<RouteBase> get routes => const [];
  @override
  List<RecipeDetailSection> get recipeDetailSections => sections;
  @override
  List<RecipeAction> get recipeActions => actions;
  @override
  List<SettingsEntry> get settingsEntries => const [];
  @override
  List<SyncTableSpec> get syncTables => const [];
}

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _settle(WidgetTester tester, {int millis = 150}) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: millis)));
    await tester.pump();
  }
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

Future<(String recipeId, String versionId)> _seedDraftRecipe(
  WidgetTester tester,
  db.CoreDatabase database, {
  String title = 'Testrezept',
  List<RecipeIngredient> Function(String versionId)? ingredients,
  List<RecipeStep> Function(String versionId)? steps,
}) async {
  final recipeDao = DriftRecipeDao(database);
  final foodDao = DriftFoodDao(database);
  final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

  return tester.runAsync(() async {
    final recipeId = await recipeRepo.createRecipe(NewRecipe(title: title));
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
      ingredients: ingredients?.call(versionId) ?? const [],
      steps: steps?.call(versionId) ?? const [],
    ));
    return (recipeId, versionId);
  }).then((value) => value!);
}

Future<void> _pumpDetail(
  WidgetTester tester,
  db.CoreDatabase database,
  String recipeId, {
  List<UnsaltedModule> modules = const [],
}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      coreDatabaseProvider.overrideWithValue(database),
      modulesProvider.overrideWithValue(modules),
    ],
    child: MaterialApp(home: RecipeDetailScreen(recipeId: recipeId)),
  ));
  await _settle(tester);
}

void main() {
  testWidgets('EX-05: Seite funktioniert ohne registrierte Module', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, versionId) = await _seedDraftRecipe(
      tester,
      database,
      ingredients: (vid) => [
        RecipeIngredient(
          id: 'i1',
          versionId: vid,
          position: 1,
          displayName: 'Mehl',
          quantity: Decimal.fromInt(200),
          unitCode: 'g',
        ),
      ],
    );
    expect(versionId, isNotEmpty);

    await _pumpDetail(tester, database, recipeId);

    expect(find.text('Testrezept'), findsOneWidget);
    expect(find.text('Mehl'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('EX-01: eine RecipeDetailSection eines Test-Moduls erscheint auf der Seite',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, _) = await _seedDraftRecipe(tester, database);

    final module = _FakeModule(sections: [
      RecipeDetailSection(
        id: 'sec1',
        order: 1,
        build: (context, ctx) => const Text('Zusatzabschnitt vom Testmodul'),
      ),
    ]);

    await _pumpDetail(tester, database, recipeId, modules: [module]);

    expect(find.text('Zusatzabschnitt vom Testmodul'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('EX-02: eine RecipeAction eines Test-Moduls erscheint in der AppBar',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, _) = await _seedDraftRecipe(tester, database);

    var pressed = false;
    final module = _FakeModule(actions: [
      RecipeAction(
        id: 'act1',
        order: 1,
        label: 'Testaktion',
        icon: const IconData(0xe000),
        placement: RecipeActionPlacement.appBar,
        onPressed: (context, ctx) => pressed = true,
      ),
    ]);

    await _pumpDetail(tester, database, recipeId, modules: [module]);

    final button = find.widgetWithIcon(IconButton, const IconData(0xe000));
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pump();
    expect(pressed, isTrue);

    await _disposeWidgetTree(tester);
  });

  testWidgets('EX-04: order bestimmt die Reihenfolge über mehrere Module hinweg',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, _) = await _seedDraftRecipe(tester, database);

    final moduleA = _FakeModule(sections: [
      RecipeDetailSection(id: 'a', order: 2, build: (c, ctx) => const Text('Abschnitt B (order 2)')),
    ]);
    final moduleB = _FakeModule(sections: [
      RecipeDetailSection(id: 'b', order: 1, build: (c, ctx) => const Text('Abschnitt A (order 1)')),
    ]);

    // Module absichtlich in "falscher" Registrierungsreihenfolge, damit nur
    // `order` (nicht die Modul-/Registrierungsreihenfolge) die Anzeige
    // bestimmt.
    await _pumpDetail(tester, database, recipeId, modules: [moduleA, moduleB]);

    final posA = tester.getTopLeft(find.text('Abschnitt A (order 1)')).dy;
    final posB = tester.getTopLeft(find.text('Abschnitt B (order 2)')).dy;
    expect(posA, lessThan(posB));

    await _disposeWidgetTree(tester);
  });

  testWidgets('Versionsumschalter wechselt die angezeigte Version', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final (recipeId, v1) = await _seedDraftRecipe(
      tester,
      database,
      ingredients: (vid) => [
        RecipeIngredient(
          id: 'i1',
          versionId: vid,
          position: 1,
          displayName: 'Mehl V1',
          quantity: Decimal.fromInt(100),
          unitCode: 'g',
        ),
      ],
    );
    final v2 = await tester.runAsync(() => recipeRepo.createDraftFrom(v1));
    await tester.runAsync(() => recipeRepo.saveDraft(RecipeVersionDraft(
          id: v2!,
          recipeId: recipeId,
          parentVersionId: v1,
          versionIndex: 2,
          label: null,
          servings: null,
          bakingLossPercent: Decimal.zero,
          finalWeightOverrideG: null,
          notes: null,
          ingredients: [
            RecipeIngredient(
              id: 'i2',
              versionId: v2,
              position: 1,
              displayName: 'Zucker V2',
              quantity: Decimal.fromInt(50),
              unitCode: 'g',
            ),
          ],
          steps: const [],
        )));

    await _pumpDetail(tester, database, recipeId);

    // Standardauswahl: höchster versionIndex (V2, kein Master gesetzt).
    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.text('Mehl V1'), findsNothing);

    await tester.tap(find.text('V1'));
    await _settle(tester);

    expect(find.text('Mehl V1'), findsOneWidget);
    expect(find.text('Zucker V2'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Timer-Chip zeigt nur den gespeicherten timerSeconds-Wert', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, _) = await _seedDraftRecipe(
      tester,
      database,
      steps: (vid) => [
        RecipeStep(id: 's1', versionId: vid, position: 1, instruction: 'Kneten', timerSeconds: 600),
        RecipeStep(id: 's2', versionId: vid, position: 2, instruction: 'Ruhen lassen'),
      ],
    );

    await _pumpDetail(tester, database, recipeId);

    expect(find.text('Kneten'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Ruhen lassen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Aktion "Versionen" öffnet die Versionsliste (Nachtrag 8.8a)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, _) = await _seedDraftRecipe(tester, database);
    await _pumpDetail(tester, database, recipeId);

    await tester.tap(find.byTooltip('Versionen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await _settle(tester);

    final list = tester.widget<VersionListScreen>(find.byType(VersionListScreen));
    expect(list.recipeId, recipeId);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Aktion "Bearbeiten" öffnet den Editor der gewählten Version (Nachtrag 8.8a)',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeRepo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
    final (recipeId, v1) = await _seedDraftRecipe(tester, database);
    await tester.runAsync(() => recipeRepo.createDraftFrom(v1));

    await _pumpDetail(tester, database, recipeId);
    // Standardauswahl ist V2 -- bewusst auf V1 wechseln, damit geprüft wird,
    // dass die gewählte (nicht irgendeine) Version geöffnet wird.
    await tester.tap(find.text('V1'));
    await _settle(tester);

    await tester.tap(find.byTooltip('Bearbeiten'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await _settle(tester);

    final editor = tester.widget<RecipeEditorScreen>(find.byType(RecipeEditorScreen));
    expect(editor.recipeId, recipeId);
    expect(editor.versionId, v1);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-28: Mengenrechner unter der Tabelle, Gramm ↔ kcal gekoppelt, auch für Snapshots',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final mehl = await tester.runAsync(() => DriftFoodRepository(DriftFoodDao(database)).createVariant(NewFoodVariant(
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
    // 200 g Mehl bei 300 kcal/100 g: 600 kcal auf 200 g.
    final (recipeId, versionId) = await _seedDraftRecipe(
      tester,
      database,
      ingredients: (vid) => [
        RecipeIngredient(id: 'i1', versionId: vid, position: 1, foodVariantId: mehl,
            displayName: 'Mehl', quantity: Decimal.fromInt(200), unitCode: 'g'),
      ],
    );

    Future<void> expectCoupled() async {
      expect(find.byType(AmountCalculator), findsOneWidget);
      expect(tester.getTopLeft(find.byType(AmountCalculator)).dy,
          greaterThan(tester.getTopLeft(find.byType(NutritionTable)).dy));

      final grams = find.widgetWithText(TextField, 'Gramm');
      final kcal = find.widgetWithText(TextField, 'kcal');
      await tester.enterText(grams, '100');
      await tester.pump();
      expect(tester.widget<TextField>(kcal).controller!.text, '300');
      await tester.enterText(kcal, '150');
      await tester.pump();
      expect(tester.widget<TextField>(grams).controller!.text, '50');
    }

    await _pumpDetail(tester, database, recipeId);
    await expectCoupled();
    await _disposeWidgetTree(tester);

    final recipeRepo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
    await tester.runAsync(() => recipeRepo.snapshotVersion(versionId));
    await _pumpDetail(tester, database, recipeId);
    await expectCoupled();
    await _disposeWidgetTree(tester);
  });
}
