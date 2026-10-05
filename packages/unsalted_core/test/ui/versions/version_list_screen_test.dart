// test/ui/versions/version_list_screen_test.dart
//
// Schritt 8.6, Bildschirm 7: Liste absteigend, Badge Entwurf/Eingefroren,
// Master-Stern, Kopie-als-Entwurf-Aktion, Löschen mit Rückfrage.
// UI-26/UI-27 (Fehlerbehebung 9.2a, Befund 3): Master markieren.

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
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/versions/version_list_screen.dart';

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

Future<void> _pumpList(WidgetTester tester, db.CoreDatabase database, String recipeId) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: MaterialApp(home: VersionListScreen(recipeId: recipeId)),
  ));
  await _settle(tester);
}

void main() {
  testWidgets('zeigt Entwurf- und Eingefroren-Badges sowie den Master-Stern', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final recipeId = await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Test'));
      final v1 = (await recipeDao.watchVersions(recipeId).first).first.id;
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
          RecipeIngredient(id: 'i1', versionId: v1, position: 1, displayName: 'Salz', quantity: Decimal.one, unitCode: 'g'),
        ],
        steps: const [],
      ));
      await recipeRepo.snapshotVersion(v1);
      await recipeRepo.setMasterVersion(recipeId, v1);
      await recipeRepo.createDraftFrom(v1);
      return recipeId;
    }).then((v) => v!);

    await _pumpList(tester, database, recipeId);

    expect(find.textContaining('Eingefroren'), findsOneWidget);
    expect(find.textContaining('Entwurf'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Kopie als Entwurf öffnet den Editor für die neue Version', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final recipeId = await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Test'));
      final v1 = (await recipeDao.watchVersions(recipeId).first).first.id;
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
          RecipeIngredient(id: 'i1', versionId: v1, position: 1, displayName: 'Salz', quantity: Decimal.one, unitCode: 'g'),
        ],
        steps: const [],
      ));
      await recipeRepo.snapshotVersion(v1);
      return recipeId;
    }).then((v) => v!);

    await _pumpList(tester, database, recipeId);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.copy));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.byType(RecipeEditorScreen), findsOneWidget);

    final versions = await tester.runAsync(() => recipeDao.watchVersions(recipeId).first);
    expect(versions, hasLength(2));

    await _disposeWidgetTree(tester);
  });

  testWidgets('Löschen fragt nach und ruft erst nach Bestätigung deleteVersion auf',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final recipeId = await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Test'));
      final v1 = (await recipeDao.watchVersions(recipeId).first).first.id;
      await recipeRepo.createDraftFrom(v1);
      return recipeId;
    }).then((v) => v!);

    await _pumpList(tester, database, recipeId);

    var versions = await tester.runAsync(() => recipeDao.watchVersions(recipeId).first);
    expect(versions, hasLength(2));

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline).first);
    await tester.pump();
    expect(find.text('Version löschen?'), findsOneWidget);

    // Noch nicht gelöscht, solange der Dialog nicht bestätigt wurde.
    versions = await tester.runAsync(() => recipeDao.watchVersions(recipeId).first);
    expect(versions, hasLength(2));

    await tester.tap(find.widgetWithText(TextButton, 'Löschen'));
    await _settle(tester);

    versions = await tester.runAsync(() => recipeDao.watchVersions(recipeId).first);
    expect(versions, hasLength(1));

    await _disposeWidgetTree(tester);
  });

  testWidgets('Vergleichen ist nur für eingefrorene Versionen aktiv', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    final recipeId = await tester.runAsync(
      () => recipeRepo.createRecipe(const NewRecipe(title: 'Test')),
    );

    await _pumpList(tester, database, recipeId!);

    final compareButton =
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.compare_arrows));
    expect(compareButton.onPressed, isNull, reason: 'Draft ist nicht vergleichbar (Kapitel 13.7)');

    await _disposeWidgetTree(tester);
  });

  /// V1 eingefroren, V2 eingefroren, V3 Entwurf (watchVersions: V3, V2, V1).
  Future<(String, String, String, String)> seedThreeVersions(WidgetTester tester, db.CoreDatabase database) async {
    final recipeDao = DriftRecipeDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, DriftFoodDao(database), database);
    return (await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Test'));
      final v1 = (await recipeDao.watchVersions(recipeId).first).first.id;
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
          RecipeIngredient(id: 'i1', versionId: v1, position: 1, displayName: 'Salz', quantity: Decimal.one, unitCode: 'g'),
        ],
        steps: const [],
      ));
      await recipeRepo.snapshotVersion(v1);
      final v2 = await recipeRepo.createDraftFrom(v1);
      await recipeRepo.snapshotVersion(v2);
      final v3 = await recipeRepo.createDraftFrom(v2);
      return (recipeId, v1, v2, v3);
    }))!;
  }

  Finder tileOf(String label) => find.ancestor(of: find.text(label), matching: find.byType(ListTile));
  Finder markAction(String label) =>
      find.descendant(of: tileOf(label), matching: find.byTooltip('Als Master markieren'));

  testWidgets('UI-26: „Als Master markieren“ nur bei eingefrorenen Versionen; Stern erscheint sofort',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));
    final (recipeId, v1, _, _) = await seedThreeVersions(tester, database);

    await _pumpList(tester, database, recipeId);

    expect(markAction('V1'), findsOneWidget);
    expect(markAction('V2'), findsOneWidget);
    expect(markAction('V3'), findsNothing, reason: 'Entwurf');
    expect(find.byIcon(Icons.star), findsNothing);

    await tester.tap(markAction('V1'));
    await _settle(tester);

    expect(find.descendant(of: tileOf('V1'), matching: find.byIcon(Icons.star)), findsOneWidget);
    expect(markAction('V1'), findsNothing, reason: 'schon Master');
    expect(markAction('V2'), findsOneWidget);
    final recipe = await tester.runAsync(() => DriftRecipeDao(database).getRecipe(recipeId));
    expect(recipe!.masterVersionId, v1);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-27: Löschen der Master-Version wird mit der Meldung des Repositorys abgelehnt',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));
    final (recipeId, _, _, _) = await seedThreeVersions(tester, database);

    await _pumpList(tester, database, recipeId);
    await tester.tap(markAction('V2'));
    await _settle(tester);

    await tester.tap(find.descendant(of: tileOf('V2'), matching: find.byTooltip('Löschen')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Löschen'));
    await _settle(tester);
    await tester.pump();

    expect(find.text('Die Master-Version kann nicht gelöscht werden.'), findsOneWidget);
    expect(tileOf('V2'), findsOneWidget);
    expect(find.descendant(of: tileOf('V2'), matching: find.byIcon(Icons.star)), findsOneWidget);

    await _disposeWidgetTree(tester);
  });
}
