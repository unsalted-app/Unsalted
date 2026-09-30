// test/ui/recipe_list/recipe_list_screen_test.dart
//
// Schritt 8.2, Bildschirm 1: UI-01 (leerer Zustand), UI-02 (vorhandene
// Rezepte), Titel-Suche, Navigation zum Erstellen-Bildschirm und (Nachtrag
// 8.8a) zum Rezeptdetail.
//
// NativeDatabase.memory() unter testWidgets() braucht WidgetTester.runAsync()
// -- siehe CLAUDE.md Abschnitt 4 und test/ui/foods/food_list_screen_test.dart.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_create_screen.dart';
import 'package:unsalted_core/src/ui/recipe_list/recipe_list_screen.dart';

Future<CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _pumpRecipeList(WidgetTester tester, CoreDatabase database) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: const MaterialApp(home: RecipeListScreen()),
  ));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets('UI-01: leerer Zustand zeigt "Erstes Rezept anlegen"', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await _pumpRecipeList(tester, database);

    expect(find.text('Noch keine Rezepte.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Erstes Rezept anlegen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-02: vorhandene Rezepte werden gelistet', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await tester.runAsync(() async {
      final repo = DriftRecipeRepository(
        DriftRecipeDao(database),
        DriftFoodDao(database),
        database,
      );
      await repo.createRecipe(const NewRecipe(title: 'Pizzateig'));
      await repo.createRecipe(const NewRecipe(title: 'Apfelkuchen'));
    });

    await _pumpRecipeList(tester, database);

    expect(find.text('Pizzateig'), findsOneWidget);
    expect(find.text('Apfelkuchen'), findsOneWidget);
    expect(find.text('Noch keine Rezepte.'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Titel-Suche filtert client-seitig', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await tester.runAsync(() async {
      final repo = DriftRecipeRepository(
        DriftRecipeDao(database),
        DriftFoodDao(database),
        database,
      );
      await repo.createRecipe(const NewRecipe(title: 'Pizzateig'));
      await repo.createRecipe(const NewRecipe(title: 'Apfelkuchen'));
    });

    await _pumpRecipeList(tester, database);
    expect(find.text('Pizzateig'), findsOneWidget);
    expect(find.text('Apfelkuchen'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pizza');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Pizzateig'), findsOneWidget);
    expect(find.text('Apfelkuchen'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('FAB öffnet den Erstellen-Bildschirm', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await _pumpRecipeList(tester, database);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RecipeCreateScreen), findsOneWidget);
    expect(find.text('Rezept erstellen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Tippen auf ein Rezept öffnet das Rezeptdetail (Nachtrag 8.8a)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    final recipeId = await tester.runAsync(() => DriftRecipeRepository(
          DriftRecipeDao(database),
          DriftFoodDao(database),
          database,
        ).createRecipe(const NewRecipe(title: 'Pizzateig')));

    await _pumpRecipeList(tester, database);

    await tester.tap(find.text('Pizzateig'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final detail = tester.widget<RecipeDetailScreen>(find.byType(RecipeDetailScreen));
    expect(detail.recipeId, recipeId);

    await _disposeWidgetTree(tester);
  });
}
