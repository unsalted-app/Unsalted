// test/ui/recipe_detail/recipe_detail_screen_test.dart
//
// Schritt 8.5, Bildschirm 4: EX-01 (RecipeDetailSection erscheint),
// EX-02 (RecipeAction erscheint in der AppBar), EX-04 (order-Reihenfolge
// über mehrere Module hinweg), EX-05 (Seite funktioniert ohne registrierte
// Module). EX-03 (SettingsEntry) ist erst mit dem Einstellungen-Bildschirm
// (Schritt 8.7) testbar, siehe docs/status.md. Nachtrag 8.8a: feste
// Core-Aktionen "Versionen" und "Bearbeiten" in der AppBar. UI-28
// (Fehlerbehebung 9.2a, Befund 4): Mengenrechner unter der Nährwerttabelle.
// UI-33/UI-34 (Teil 1.1a): kein Flackern beim Versionswechsel, späte
// Antworten älterer Wechsel werden verworfen. Dafür hält
// _GatedNutritionService `forVersion` je Version zurück, bis der Test sie
// freigibt -- so ist der Zwischenzustand deterministisch prüfbar.
// UI-40 (Teil 1.1b): „Rezept löschen“ im AppBar-Menü kehrt zur Rezeptliste
// zurück und zeigt dort die SnackBar mit „Rückgängig“. UI-45/UI-46
// (Teil 1.1c): Ladebalken erst nach 300 ms, bei schnellem Laden nie.

import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/contracts/nutrition_service.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_nutrition_service.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/module/extension_types.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_result.dart';
import 'package:unsalted_core/src/module/unsalted_module.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';
import 'package:unsalted_core/src/ui/nutrition/amount_calculator.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_table.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_detail/version_switcher.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/recipe_list/recipe_list_screen.dart';
import 'package:unsalted_core/src/ui/shared/undoable_deletion.dart';
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

/// Echter NutritionService, der `forVersion` für einzeln angehaltene
/// Versionen erst nach Freigabe ausführt (Teil 1.1a).
class _GatedNutritionService implements NutritionService {
  final NutritionService inner;
  final _gates = <String, Completer<void>>{};

  _GatedNutritionService(this.inner);

  /// Hält den nächsten `forVersion`-Aufruf für [versionId] an, bis der
  /// zurückgegebene Completer abgeschlossen wird.
  Completer<void> hold(String versionId) => _gates[versionId] = Completer<void>();

  @override
  Future<NutritionResult> forVersion(String versionId) async {
    final gate = _gates.remove(versionId);
    if (gate != null) await gate.future;
    return inner.forVersion(versionId);
  }

  @override
  NutritionResult preview({
    required List<IngredientInput> ingredients,
    required Decimal bakingLossPercent,
    Decimal? finalWeightOverrideG,
    int? servings,
  }) =>
      inner.preview(
        ingredients: ingredients,
        bakingLossPercent: bakingLossPercent,
        finalWeightOverrideG: finalWeightOverrideG,
        servings: servings,
      );
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
  NutritionService? nutritionService,
}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      coreDatabaseProvider.overrideWithValue(database),
      modulesProvider.overrideWithValue(modules),
      if (nutritionService != null) nutritionServiceProvider.overrideWithValue(nutritionService),
    ],
    child: MaterialApp(home: RecipeDetailScreen(recipeId: recipeId)),
  ));
  await _settle(tester);
}

/// Legt per createDraftFrom([fromVersionId]) eine neue Version an und
/// speichert sie mit genau einer Zutat [ingredientName].
Future<String> _addVersion(
  WidgetTester tester,
  db.CoreDatabase database,
  String recipeId,
  String fromVersionId, {
  required int versionIndex,
  required String ingredientName,
}) async {
  final recipeRepo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
  return tester.runAsync(() async {
    final versionId = await recipeRepo.createDraftFrom(fromVersionId);
    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: fromVersionId,
      versionIndex: versionIndex,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.zero,
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: 'i$versionIndex',
          versionId: versionId,
          position: 1,
          displayName: ingredientName,
          quantity: Decimal.fromInt(50),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));
    return versionId;
  }).then((value) => value!);
}

/// Beschriftung des gewählten Chips in der Versionsleiste.
String _selectedVersionLabel(WidgetTester tester) {
  final chip = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).singleWhere((c) => c.selected);
  return (chip.label as Text).data!;
}

/// Tippt den Chip [label] der Versionsleiste an und lässt dessen
/// Auswahl-Animation auslaufen -- `_settle` pumpt ohne Zeitvorschub, sonst
/// verfehlt ein direkt folgender Tap den halb animierten Chip.
Future<void> _tapVersion(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(ChoiceChip, label));
  await _settle(tester);
  await tester.pump(const Duration(milliseconds: 500));
}

_GatedNutritionService _gatedNutrition(db.CoreDatabase database) =>
    _GatedNutritionService(DriftNutritionService(DriftRecipeDao(database), DriftFoodDao(database)));

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

  testWidgets('UI-33: beim Versionswechsel bleiben Titel, Aktionen und Versionsleiste stehen (Teil 1.1a)',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

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
    final v2 = await _addVersion(tester, database, recipeId, v1, versionIndex: 2, ingredientName: 'Zucker V2');
    final nutrition = _gatedNutrition(database);

    // Allererstes Laden: nur hier der zentrierte Ladekreis (Kapitel 22).
    final firstLoad = nutrition.hold(v2);
    await _pumpDetail(tester, database, recipeId, nutritionService: nutrition);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    firstLoad.complete();
    await _settle(tester);
    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Wechsel auf V1, dessen Nährwerte noch nicht geliefert sind.
    final switchLoad = nutrition.hold(v1);
    await _tapVersion(tester, 'V1');

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Testrezept'), findsOneWidget);
    expect(find.byTooltip('Versionen'), findsOneWidget);
    expect(find.byTooltip('Bearbeiten'), findsOneWidget);
    expect(find.byType(VersionSwitcher), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Alter Inhalt bleibt stehen, die Leiste markiert schon die neue Wahl.
    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.text('Mehl V1'), findsNothing);
    expect(_selectedVersionLabel(tester), 'V1');

    switchLoad.complete();
    await _settle(tester);

    expect(find.text('Mehl V1'), findsOneWidget);
    expect(find.text('Zucker V2'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(Scaffold), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-34: schneller Wechsel V1 → V3 → V2 endet auf V2, späte V3-Antwort wird verworfen',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

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
    final v2 = await _addVersion(tester, database, recipeId, v1, versionIndex: 2, ingredientName: 'Zucker V2');
    await _addVersion(tester, database, recipeId, v2, versionIndex: 3, ingredientName: 'Butter V3');
    final nutrition = _gatedNutrition(database);

    await _pumpDetail(tester, database, recipeId, nutritionService: nutrition);
    await _tapVersion(tester, 'V1');
    expect(find.text('Mehl V1'), findsOneWidget);

    // V3 antwortet erst, nachdem V2 schon gewählt und geladen ist.
    final v3 = tester.widget<VersionSwitcher>(find.byType(VersionSwitcher)).versions
        .singleWhere((v) => v.versionIndex == 3)
        .id;
    final lateV3 = nutrition.hold(v3);
    await _tapVersion(tester, 'V3');
    // V3 ist gewählt und lädt noch; der Inhalt von V1 bleibt stehen.
    expect(_selectedVersionLabel(tester), 'V3');
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Mehl V1'), findsOneWidget);

    await _tapVersion(tester, 'V2');
    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    lateV3.complete();
    await _settle(tester);

    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.text('Butter V3'), findsNothing);
    expect(find.text('Mehl V1'), findsNothing);
    expect(_selectedVersionLabel(tester), 'V2');
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-40: „Rezept löschen“ im Detail kehrt zur Liste zurück, SnackBar dort, nach 5 s gelöscht',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));
    final (recipeId, v1) = await _seedDraftRecipe(tester, database, title: 'Pizzateig');
    final v2 = await _addVersion(tester, database, recipeId, v1, versionIndex: 2, ingredientName: 'Hefe');
    await _seedDraftRecipe(tester, database, title: 'Apfelkuchen');

    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: RecipeListScreen()),
    ));
    await _settle(tester);

    await tester.tap(find.text('Pizzateig'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await _settle(tester);
    expect(find.byType(RecipeDetailScreen), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rezept löschen'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailScreen), findsNothing);
    expect(find.byType(RecipeListScreen), findsOneWidget);
    expect(find.text('Pizzateig'), findsNothing);
    expect(find.text('Apfelkuchen'), findsOneWidget);
    expect(find.text('„Pizzateig“ gelöscht'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Rückgängig'), findsOneWidget);

    final repo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
    expect(await tester.runAsync(() => repo.getVersion(v2)), isNotNull);

    await tester.pump(undoableDeletionDelay);
    await _settle(tester);
    expect(await tester.runAsync(() => repo.watchRecipe(recipeId).first), isNull);
    expect(await tester.runAsync(() => repo.getVersion(v1)), isNull);
    expect(await tester.runAsync(() => repo.getVersion(v2)), isNull);
    // runAsync liefert auch bei einer Ausnahme null -- die darf es nicht geben.
    expect(tester.takeException(), isNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-45: schneller Versionswechsel zeigt keinen Ladebalken (Teil 1.1c)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));
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
    await _addVersion(tester, database, recipeId, v1, versionIndex: 2, ingredientName: 'Zucker V2');
    await _pumpDetail(tester, database, recipeId);
    expect(find.text('Zucker V2'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'V1'));
    await tester.pump();
    // Der Wechsel läuft schon, der Ladebalken bleibt verborgen.
    expect(_selectedVersionLabel(tester), 'V1');
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await _settle(tester);
    expect(find.text('Mehl V1'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    // Die Verzögerung endet mit der Antwort -- auch danach kein Strich.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-46: Ladebalken erst nach 300 ms; ein weiterer Wechsel lässt ihn stehen (Teil 1.1c)',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));
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
    final v2 = await _addVersion(tester, database, recipeId, v1, versionIndex: 2, ingredientName: 'Zucker V2');
    await _addVersion(tester, database, recipeId, v2, versionIndex: 3, ingredientName: 'Butter V3');
    final nutrition = _gatedNutrition(database);
    await _pumpDetail(tester, database, recipeId, nutritionService: nutrition);
    expect(find.text('Butter V3'), findsOneWidget);

    // V1 lädt langsam: erst nach 300 ms erscheint der Strich.
    final slowV1 = nutrition.hold(v1);
    await tester.tap(find.widgetWithText(ChoiceChip, 'V1'));
    await _settle(tester);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Butter V3'), findsOneWidget);

    // Wechsel auf V2, während noch geladen wird: der Strich bleibt sofort stehen.
    final slowV2 = nutrition.hold(v2);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.widgetWithText(ChoiceChip, 'V2'));
    await tester.pump();
    expect(_selectedVersionLabel(tester), 'V2');
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    slowV2.complete();
    await _settle(tester);
    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    // Die späte V1-Antwort ändert nichts mehr.
    slowV1.complete();
    await _settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Zucker V2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await _disposeWidgetTree(tester);
  });
}
