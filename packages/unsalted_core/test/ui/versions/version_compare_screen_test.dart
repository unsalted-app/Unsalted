// test/ui/versions/version_compare_screen_test.dart
//
// Schritt 8.6, Bildschirm 8: UI-08 (Vergleichsbildschirm zeigt die
// gruppierte Änderungsliste), Übernehmen ruft applyChangesAsNewDraft mit
// derselben Liste auf.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/data/drift_snapshot_service.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/versions/version_compare_screen.dart';

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _settle(WidgetTester tester, {int millis = 150, int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: millis)));
    await tester.pump();
  }
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// Baut zwei Snapshot-Versionen desselben Rezepts: A mit 100 g Mehl, B mit
/// 200 g Mehl UND einer zusätzlichen Zutat "Salz" -- erzeugt sowohl eine
/// SetIngredientQuantity- als auch eine AddIngredient-Änderung.
Future<(String recipeId, String versionAId, String versionBId)> _seedTwoSnapshots(
  WidgetTester tester,
  db.CoreDatabase database,
) async {
  final recipeDao = DriftRecipeDao(database);
  final foodDao = DriftFoodDao(database);
  final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

  return tester.runAsync(() async {
    final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Brot'));
    final versionAId = (await recipeDao.watchVersions(recipeId).first).first.id;
    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionAId,
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
          versionId: versionAId,
          position: 1,
          displayName: 'Mehl',
          quantity: Decimal.fromInt(100),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));
    await recipeRepo.snapshotVersion(versionAId);

    final versionBId = await recipeRepo.createDraftFrom(versionAId);
    // createDraftFrom hat "Mehl" bereits mit einer NEUEN, automatisch
    // erzeugten id kopiert (Kapitel 10.9) -- diese id muss für das Update
    // wiederverwendet werden, ids sind global eindeutig über die ganze
    // Tabelle, nicht nur pro Version.
    final copiedMehlId = (await recipeDao.getIngredientsForVersion(versionBId)).single.id;
    await recipeRepo.saveDraft(RecipeVersionDraft(
      id: versionBId,
      recipeId: recipeId,
      parentVersionId: versionAId,
      versionIndex: 2,
      label: null,
      servings: null,
      bakingLossPercent: Decimal.zero,
      finalWeightOverrideG: null,
      notes: null,
      ingredients: [
        RecipeIngredient(
          id: copiedMehlId,
          versionId: versionBId,
          position: 1,
          displayName: 'Mehl',
          quantity: Decimal.fromInt(200),
          unitCode: 'g',
        ),
        RecipeIngredient(
          id: 'i2-salz',
          versionId: versionBId,
          position: 2,
          displayName: 'Salz',
          quantity: Decimal.fromInt(5),
          unitCode: 'g',
        ),
      ],
      steps: const [],
    ));
    await recipeRepo.snapshotVersion(versionBId);

    return (recipeId, versionAId, versionBId);
  }).then((v) => v!);
}

void main() {
  testWidgets('UI-08: zeigt die gruppierte Änderungsliste (Zutaten-Kategorie)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final (recipeId, versionAId, versionBId) = await _seedTwoSnapshots(tester, database);

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: VersionCompareScreen(recipeId: recipeId, versionAId: versionAId, versionBId: versionBId),
      ),
    ));
    await _settle(tester);

    expect(find.text('Zutaten'), findsOneWidget);
    expect(find.textContaining('Menge an Position 1 geändert'), findsOneWidget);
    expect(find.textContaining('Zutat "Salz" hinzugefügt'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Übernehmen ruft applyChangesAsNewDraft auf und öffnet den neuen Draft',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final (recipeId, versionAId, versionBId) = await _seedTwoSnapshots(tester, database);

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: VersionCompareScreen(recipeId: recipeId, versionAId: versionAId, versionBId: versionBId),
      ),
    ));
    await _settle(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Als neuen Entwurf übernehmen'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.byType(RecipeEditorScreen), findsOneWidget);

    final versions = await tester.runAsync(() => recipeDao.watchVersions(recipeId).first);
    expect(versions!, hasLength(3));
    final newDraft = versions.firstWhere((v) => v.id != versionAId && v.id != versionBId);
    expect(newDraft.state, 'draft');

    final ingredients = await tester.runAsync(() => recipeDao.getIngredientsForVersion(newDraft.id));
    expect(ingredients!.map((i) => i.displayName), containsAll(['Mehl', 'Salz']));
    expect(ingredients.firstWhere((i) => i.displayName == 'Mehl').quantity, Decimal.fromInt(200));

    await _disposeWidgetTree(tester);
  });

  testWidgets('ohne Unterschiede bleibt die Änderungsliste leer und Übernehmen ist deaktiviert',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final (recipeId, versionAId) = await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Identisch'));
      final versionAId = (await recipeDao.watchVersions(recipeId).first).first.id;
      await recipeRepo.saveDraft(RecipeVersionDraft(
        id: versionAId,
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
            versionId: versionAId,
            position: 1,
            displayName: 'Wasser',
            quantity: Decimal.fromInt(300),
            unitCode: 'g',
          ),
        ],
        steps: const [],
      ));
      await recipeRepo.snapshotVersion(versionAId);
      final versionBId = await recipeRepo.createDraftFrom(versionAId);
      await recipeRepo.snapshotVersion(versionBId);
      return (recipeId, versionAId, versionBId);
    }).then((v) => (v!.$1, v.$2));

    final snapshotService = DriftSnapshotService(recipeDao, foodDao, database);
    final versionBId = await tester.runAsync(() async {
      final versions = await recipeDao.watchVersions(recipeId).first;
      return versions.firstWhere((v) => v.id != versionAId).id;
    });
    // Nur zur Absicherung, dass beide tatsächlich exportierbar sind.
    await tester.runAsync(() => snapshotService.exportVersion(versionAId));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: VersionCompareScreen(recipeId: recipeId, versionAId: versionAId, versionBId: versionBId!),
      ),
    ));
    await _settle(tester);

    expect(find.text('Keine Unterschiede.'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Als neuen Entwurf übernehmen'));
    expect(button.onPressed, isNull);

    await _disposeWidgetTree(tester);
  });
}
