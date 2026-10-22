// test/ui/recipe_list/recipe_list_screen_test.dart
//
// Schritt 8.2, Bildschirm 1: UI-01 (leerer Zustand), UI-02 (vorhandene
// Rezepte), Titel-Suche, Navigation zum Erstellen-Bildschirm und (Nachtrag
// 8.8a) zum Rezeptdetail. UI-35 bis UI-39 (Teil 1.1b): Löschen per Wischen
// mit 5 s „Rückgängig“, mehrere Löschungen nacheinander, App-Ende vor Ablauf.
//
// NativeDatabase.memory() unter testWidgets() braucht WidgetTester.runAsync()
// -- siehe CLAUDE.md Abschnitt 4 und test/ui/foods/food_list_screen_test.dart.
// UI-89 (Teil 1.4, B04): Der Suchtreffer im Titel ist markiert (erster Treffer,
// ohne Groß-/Kleinschreibung); Klartext und Semantik bleiben der ganze Titel.
// UI-91 (Teil 1.4, T02): Liste und Detail ab 840 — Tippen wählt aus
// (Auswahlbalken, Detail rechts, keine neue Seite), Wechsel, „Rezept löschen“
// im Detailbereich und Wischen heben die Auswahl auf; die Auswahl übersteht
// das Verkleinern (F6); unter 840 wie bisher eine eigene Seite.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_design/unsalted_design.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_create_screen.dart';
import 'package:unsalted_core/src/ui/recipe_list/recipe_card.dart';
import 'package:unsalted_core/src/ui/recipe_list/recipe_list_screen.dart';
import 'package:unsalted_core/src/ui/shared/undoable_deletion.dart';
import '../support/db_widget_harness.dart';

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

/// Schließt [database] im Teardown, auch wenn der Test vorher scheitert
/// (Teil 1.1d). Nach einem roten Test lässt flutter_test den Widget-Baum stehen,
/// und Drift wartet beim Schließen auf seine Abbestell-Timer in der Fake-Zone,
/// die dann niemand mehr auspumpt -- der Lauf hinge. Deshalb erst den Baum
/// abbauen und auspumpen, dann schließen.
Future<void> _closeDatabase(WidgetTester tester, CoreDatabase database) async {
  await closeTestDatabase(tester, database);
}

DriftRecipeRepository _repo(CoreDatabase database) =>
    DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);

/// Legt ein Rezept mit [versions] Versionen an; liefert Rezept- und
/// Versions-IDs.
Future<(String, List<String>)> _seedRecipe(
  WidgetTester tester,
  CoreDatabase database,
  String title, {
  int versions = 1,
}) async {
  return (await tester.runAsync(() async {
    final repo = _repo(database);
    final recipeId = await repo.createRecipe(NewRecipe(title: title));
    final versionIds = [(await DriftRecipeDao(database).watchVersions(recipeId).first).single.id];
    while (versionIds.length < versions) {
      versionIds.add(await repo.createDraftFrom(versionIds.last));
    }
    return (recipeId, versionIds);
  }))!;
}

/// `true`, solange das Rezept und alle [versionIds] noch nicht gelöscht sind;
/// `false`, wenn Rezept und alle Versionen gelöscht sind; sonst Testfehler.
Future<bool> _recipeAlive(
  WidgetTester tester,
  CoreDatabase database,
  String recipeId,
  List<String> versionIds,
) async {
  final (recipe, versions) = (await tester.runAsync(() async {
    final repo = _repo(database);
    return (
      await repo.watchRecipe(recipeId).first,
      [for (final id in versionIds) await repo.getVersion(id)],
    );
  }))!;
  if (recipe != null && versions.every((v) => v != null)) return true;
  expect(recipe, isNull, reason: 'Versionen gelöscht, Rezept aber nicht');
  expect(versions, everyElement(isNull), reason: 'Rezept gelöscht, aber nicht alle Versionen');
  return false;
}

/// Lässt echte Datenbankarbeit (z. B. das Löschen nach Ablauf) durchlaufen.
Future<void> _settleDb(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}

Future<void> _swipeAway(WidgetTester tester, String title) async {
  await tester.drag(find.text(title), const Offset(-600, 0));
  // Feste Pumps statt pumpAndSettle: Die Restzeitlinie der Meldung läuft bis zum Ablauf (Teil 1.3, D09b).
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('UI-01: leerer Zustand zeigt "Erstes Rezept anlegen"', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpRecipeList(tester, database);

    expect(find.text('Noch keine Rezepte.'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Erstes Rezept anlegen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-02: vorhandene Rezepte werden gelistet', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

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
    addTearDown(() => _closeDatabase(tester, database));

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

    await tester.enterText(find.byType(AppSearchField), 'Pizza');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Pizzateig'), findsOneWidget);
    expect(find.text('Apfelkuchen'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('FAB öffnet den Erstellen-Bildschirm', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpRecipeList(tester, database);

    await tester.tap(find.byType(AppFab));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RecipeCreateScreen), findsOneWidget);
    expect(find.text('Rezept erstellen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Tippen auf ein Rezept öffnet das Rezeptdetail (Nachtrag 8.8a)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

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

  testWidgets('UI-35: Wischen blendet sofort aus; erst nach 5 s ist das Rezept samt aller Versionen gelöscht',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (pizzaId, pizzaVersions) = await _seedRecipe(tester, database, 'Pizzateig', versions: 2);
    await _seedRecipe(tester, database, 'Apfelkuchen');
    await _pumpRecipeList(tester, database);

    await _swipeAway(tester, 'Pizzateig');

    expect(find.text('Pizzateig'), findsNothing);
    expect(find.text('Apfelkuchen'), findsOneWidget);
    expect(find.text('„Pizzateig“ gelöscht'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Rückgängig'), findsOneWidget);

    // Vor Ablauf ist nichts gelöscht.
    await tester.pump(const Duration(seconds: 3));
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, pizzaId, pizzaVersions), isTrue);

    await tester.pump(const Duration(seconds: 2));
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, pizzaId, pizzaVersions), isFalse);

    await tester.pumpAndSettle();
    expect(find.text('Pizzateig'), findsNothing);
    expect(find.text('„Pizzateig“ gelöscht'), findsNothing);
    expect(find.text('Apfelkuchen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-36: „Rückgängig“ innerhalb von 5 s löscht nichts, der Eintrag ist wieder da', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (pizzaId, pizzaVersions) = await _seedRecipe(tester, database, 'Pizzateig', versions: 2);
    await _pumpRecipeList(tester, database);

    await _swipeAway(tester, 'Pizzateig');
    expect(find.text('Pizzateig'), findsNothing);

    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();
    expect(find.text('Pizzateig'), findsOneWidget);
    expect(find.text('„Pizzateig“ gelöscht'), findsNothing);

    await tester.pump(const Duration(seconds: 10));
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, pizzaId, pizzaVersions), isTrue);
    expect(find.text('Pizzateig'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-37: zwei Löschungen kurz nacheinander -- je eigene SnackBar und eigener Ablauf',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (pizzaId, pizzaVersions) = await _seedRecipe(tester, database, 'Pizzateig');
    final (apfelId, apfelVersions) = await _seedRecipe(tester, database, 'Apfelkuchen');
    await _pumpRecipeList(tester, database);

    await _swipeAway(tester, 'Pizzateig');
    await tester.pump(const Duration(seconds: 2));
    await _swipeAway(tester, 'Apfelkuchen');

    // Die neue SnackBar ersetzt die alte.
    expect(find.text('„Apfelkuchen“ gelöscht'), findsOneWidget);
    expect(find.text('„Pizzateig“ gelöscht'), findsNothing);

    // Pizzateig ist nach seinem eigenen Ablauf gelöscht, Apfelkuchen noch nicht.
    await tester.pump(const Duration(seconds: 3));
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, pizzaId, pizzaVersions), isFalse);
    expect(await _recipeAlive(tester, database, apfelId, apfelVersions), isTrue);

    await tester.pump(const Duration(seconds: 2));
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, apfelId, apfelVersions), isFalse);

    await tester.pumpAndSettle();
    expect(find.text('Noch keine Rezepte.'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-38: „Rückgängig“ der zweiten Löschung lässt die erste weiterlaufen', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (pizzaId, pizzaVersions) = await _seedRecipe(tester, database, 'Pizzateig');
    final (apfelId, apfelVersions) = await _seedRecipe(tester, database, 'Apfelkuchen');
    await _pumpRecipeList(tester, database);

    await _swipeAway(tester, 'Pizzateig');
    await _swipeAway(tester, 'Apfelkuchen');
    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();

    expect(find.text('Apfelkuchen'), findsOneWidget);
    expect(find.text('Pizzateig'), findsNothing);

    await tester.pump(const Duration(seconds: 10));
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, pizzaId, pizzaVersions), isFalse);
    expect(await _recipeAlive(tester, database, apfelId, apfelVersions), isTrue);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-39: App-Ende innerhalb der 5 s löscht nichts', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (pizzaId, pizzaVersions) = await _seedRecipe(tester, database, 'Pizzateig', versions: 2);
    await _pumpRecipeList(tester, database);

    await _swipeAway(tester, 'Pizzateig');
    // ProviderScope samt Timern verschwindet, wie beim Beenden der App.
    await _disposeWidgetTree(tester);

    await tester.pump(undoableDeletionDelay * 2);
    await _settleDb(tester);
    expect(await _recipeAlive(tester, database, pizzaId, pizzaVersions), isTrue);
  });

  testWidgets('UI-89: Suchtreffer im Titel markiert, Klartext unverändert', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    await tester.runAsync(() async {
      final repo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
      await repo.createRecipe(const NewRecipe(title: 'Hefeteig für Zopf'));
      await repo.createRecipe(const NewRecipe(title: 'Mürbeteig'));
      await repo.createRecipe(const NewRecipe(title: 'Apfelkuchen'));
    });
    expect(tester.takeException(), isNull);

    await _pumpRecipeList(tester, database);
    TextRange? matchOf(String title) =>
        tester.widget<AppListItem>(find.ancestor(of: find.text(title), matching: find.byType(AppListItem))).match;
    expect(matchOf('Hefeteig für Zopf'), isNull, reason: 'ohne Suche keine Markierung');

    await tester.enterText(find.byType(AppSearchField), 'TEIG');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(matchOf('Hefeteig für Zopf'), const TextRange(start: 4, end: 8));
    expect(matchOf('Mürbeteig'), const TextRange(start: 5, end: 9));
    expect(find.text('Apfelkuchen'), findsNothing);
    final semantics = tester.ensureSemantics();
    expect(tester.getSemantics(find.ancestor(of: find.text('Mürbeteig'), matching: find.byType(ListTile))).label,
        contains('Mürbeteig'));
    semantics.dispose();

    await _disposeWidgetTree(tester);
  });

  test('UI-89: Treffer ohne Groß-/Kleinschreibung, sonst keiner', () {
    expect(RecipeCard.matchOf('Pizzateig', 'pizza'), const TextRange(start: 0, end: 5));
    expect(RecipeCard.matchOf('Pizzateig', '  teig '), const TextRange(start: 5, end: 9));
    expect(RecipeCard.matchOf('Pizzateig', ''), isNull);
    expect(RecipeCard.matchOf('Pizzateig', 'Brot'), isNull);
  });

  group('UI-91: Liste und Detail', () {
    void setView(WidgetTester tester, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Finder card(String title) => find.widgetWithText(RecipeCard, title);
    String detailId(WidgetTester tester) => tester.widget<RecipeDetailScreen>(find.byType(RecipeDetailScreen)).recipeId;
    List<String> selected(WidgetTester tester) => [
          for (final item in tester.widgetList<AppListItem>(
            find.descendant(of: find.byType(RecipeCard), matching: find.byType(AppListItem)),
          ))
            if (item.selected) item.title,
        ];

    for (final size in const [Size(1024, 1366), Size(844, 390)]) {
      final label = '${size.width.toInt()} × ${size.height.toInt()}';
      testWidgets('UI-91: $label — Tippen wählt, Wechsel, „Rezept löschen“ hebt die Auswahl auf', (tester) async {
        final database = await _openDatabase(tester);
        addTearDown(() => _closeDatabase(tester, database));
        final (pizzaId, _) = await _seedRecipe(tester, database, 'Pizzateig');
        final (apfelId, apfelVersions) = await _seedRecipe(tester, database, 'Apfelkuchen');
        setView(tester, size);
        await _pumpRecipeList(tester, database);

        expect(find.byType(RecipeDetailScreen), findsNothing);
        expect(tester.widget<ListDetailTemplate>(find.byType(ListDetailTemplate)).detail, isNull,
            reason: 'ohne Auswahl leerer Detailbereich');

        await tester.tap(card('Pizzateig'));
        await _settleDb(tester);
        expect(detailId(tester), pizzaId);
        expect(tester.getTopLeft(find.byType(RecipeDetailScreen)).dx, greaterThanOrEqualTo(AppSize.listPane),
            reason: 'Detail rechts neben der Liste');
        expect(selected(tester), ['Pizzateig']);
        expect(Navigator.of(tester.element(find.byType(RecipeListScreen))).canPop(), isFalse,
            reason: 'keine neue Seite');
        expect(find.byType(BackButton), findsNothing, reason: 'kein „Zurück“ im Detailbereich');

        await tester.tap(card('Apfelkuchen'));
        await _settleDb(tester);
        expect(detailId(tester), apfelId);
        expect(selected(tester), ['Apfelkuchen']);

        await tester.tap(find.descendant(of: find.byType(RecipeDetailScreen), matching: find.byType(AppOverflowMenu)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Rezept löschen'));
        // Feste Pumps statt pumpAndSettle: Die Restzeitlinie der Meldung läuft bis zum Ablauf (Teil 1.3, D09b).
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.byType(RecipeDetailScreen), findsNothing, reason: 'Auswahl aufgehoben');
        expect(find.byType(RecipeListScreen), findsOneWidget, reason: 'Liste bleibt');
        expect(card('Apfelkuchen'), findsNothing);
        expect(find.text('„Apfelkuchen“ gelöscht'), findsOneWidget, reason: 'eine Meldung');
        expect(selected(tester), isEmpty);

        await tester.pump(undoableDeletionDelay);
        await _settleDb(tester);
        expect(await _recipeAlive(tester, database, apfelId, apfelVersions), isFalse);

        await _disposeWidgetTree(tester);
      });
    }

    testWidgets('UI-91: Wischen hebt die Auswahl auf', (tester) async {
      final database = await _openDatabase(tester);
      addTearDown(() => _closeDatabase(tester, database));
      await _seedRecipe(tester, database, 'Pizzateig');
      await _seedRecipe(tester, database, 'Apfelkuchen');
      setView(tester, const Size(1024, 1366));
      await _pumpRecipeList(tester, database);

      await tester.tap(card('Pizzateig'));
      await _settleDb(tester);
      expect(find.byType(RecipeDetailScreen), findsOneWidget);

      await tester.drag(card('Pizzateig'), const Offset(-600, 0));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(RecipeDetailScreen), findsNothing);
      expect(card('Pizzateig'), findsNothing);
      expect(find.text('„Pizzateig“ gelöscht'), findsOneWidget);

      await _disposeWidgetTree(tester);
    });

    testWidgets('UI-91: Auswahl übersteht das Verkleinern; unter 840 eigene Seite', (tester) async {
      final database = await _openDatabase(tester);
      addTearDown(() => _closeDatabase(tester, database));
      final (pizzaId, _) = await _seedRecipe(tester, database, 'Pizzateig');
      await _seedRecipe(tester, database, 'Apfelkuchen');
      setView(tester, const Size(1024, 1366));
      await _pumpRecipeList(tester, database);
      await tester.tap(card('Pizzateig'));
      await _settleDb(tester);

      setView(tester, const Size(390, 844));
      await _settleDb(tester);
      expect(find.byType(RecipeDetailScreen), findsNothing, reason: 'unter 840 nur die Liste');
      expect(selected(tester), isEmpty, reason: 'ohne Detail kein Auswahlbalken');

      setView(tester, const Size(1024, 1366));
      await _settleDb(tester);
      expect(detailId(tester), pizzaId, reason: 'Auswahl erhalten (F6)');
      expect(selected(tester), ['Pizzateig']);

      setView(tester, const Size(390, 844));
      await _settleDb(tester);
      await tester.tap(card('Apfelkuchen'));
      await tester.pump();
      await _settleDb(tester);
      await tester.pump(const Duration(seconds: 1));
      final page = find.byType(RecipeDetailScreen);
      expect(tester.widget<RecipeDetailScreen>(page).onClose, isNull, reason: 'eigene Seite');
      expect(tester.getRect(page), const Rect.fromLTWH(0, 0, 390, 844));
      expect(Navigator.of(tester.element(page)).canPop(), isTrue);

      await _disposeWidgetTree(tester);
    });
  });
}
