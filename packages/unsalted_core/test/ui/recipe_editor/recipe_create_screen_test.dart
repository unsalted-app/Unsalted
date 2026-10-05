// test/ui/recipe_editor/recipe_create_screen_test.dart
//
// Schritt 8.2, Bildschirm 2: Titel-Validierung (1-200 Zeichen), Speichern
// ruft createRecipe auf, Weiterleitungs-Callback, Verwerfen-Bestätigung.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_create_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';

Future<CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
}

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

void main() {
  testWidgets('FAB ist ohne Titel deaktiviert, mit gültigem Titel aktiv', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: RecipeCreateScreen()),
    ));
    await tester.pump();

    var fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Titel'), 'Pizzateig');
    await tester.pump();

    fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNotNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('zu langer Titel (> 200 Zeichen) deaktiviert das Speichern', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: RecipeCreateScreen()),
    ));
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, 'Titel'), 'x' * 201);
    await tester.pump();

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull);
    expect(find.text('Titel muss 1–200 Zeichen lang sein'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Speichern ruft createRecipe auf und ruft onCreated mit recipeId/versionId auf',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final recipeDao = DriftRecipeDao(database);

    String? createdRecipeId;
    String? createdVersionId;

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: RecipeCreateScreen(
          onCreated: (context, recipeId, versionId) {
            createdRecipeId = recipeId;
            createdVersionId = versionId;
          },
        ),
      ),
    ));
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, 'Titel'), 'Pizzateig');
    await tester.enterText(find.widgetWithText(TextField, 'Beschreibung'), 'Knusprig dünn');
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);

    expect(createdRecipeId, isNotNull);
    expect(createdVersionId, isNotNull);

    final recipeRow = await tester.runAsync(() => recipeDao.getRecipe(createdRecipeId!));
    expect(recipeRow!.title, 'Pizzateig');
    expect(recipeRow.description, 'Knusprig dünn');

    final versionRow = await tester.runAsync(() => recipeDao.getVersion(createdVersionId!));
    expect(versionRow!.versionIndex, 1);
    expect(versionRow.state, 'draft');

    await _disposeWidgetTree(tester);
  });

  testWidgets(
      'ohne onCreated-Callback wird nach dem Speichern zum Draft-Editor '
      'weitergeleitet (Arbeitskarte 8.2 §13, eingelöst in Schritt 8.3)',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const RecipeCreateScreen(),
                )),
                child: const Text('Öffnen'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Öffnen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.widgetWithText(TextField, 'Titel'), 'Pizzateig');
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    await tester.pumpAndSettle();
    // RecipeEditorScreen lädt die neue Version asynchron nach (echte
    // DB-Arbeit) -- zusätzliche Wartezeit, damit der Ladezustand durch ist.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeCreateScreen), findsNothing);
    expect(find.byType(RecipeEditorScreen), findsOneWidget);
    expect(find.text('Rezept bearbeiten'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Zurück mit ungespeicherten Eingaben fragt vor dem Verwerfen nach', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const RecipeCreateScreen(),
                )),
                child: const Text('Öffnen'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Öffnen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.widgetWithText(TextField, 'Titel'), 'Unfertiges Rezept');
    await tester.pump();

    // Simuliert den AppBar-Zurück-Button (Systemzurück), den PopScope
    // abfängt, solange ungespeicherte Eingaben vorhanden sind.
    await tester.pageBack();
    await tester.pump();

    expect(find.text('Änderungen verwerfen?'), findsOneWidget);
    expect(find.byType(RecipeCreateScreen), findsOneWidget, reason: 'noch nicht verworfen');

    await _disposeWidgetTree(tester);
  });
}
