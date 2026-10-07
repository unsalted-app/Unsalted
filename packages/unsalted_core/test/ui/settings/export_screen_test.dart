// test/ui/settings/export_screen_test.dart
//
// Schritt 8.7, Bildschirm 11: Auswahl beschränkt auf Snapshot-Versionen,
// Export liefert den gespeicherten JSON-String, Kopieren in die
// Zwischenablage.

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
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/ui/settings/export_screen.dart';

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

/// Schließt [database] im Teardown, auch wenn der Test vorher scheitert
/// (Teil 1.1d). Nach einem roten Test lässt flutter_test den Widget-Baum stehen,
/// und Drift wartet beim Schließen auf seine Abbestell-Timer in der Fake-Zone,
/// die dann niemand mehr auspumpt -- der Lauf hinge. Deshalb erst den Baum
/// abbauen und auspumpen, dann schließen.
Future<void> _closeDatabase(WidgetTester tester, db.CoreDatabase database) async {
  await _disposeWidgetTree(tester);
  await tester.runAsync(database.close);
}

void main() {
  testWidgets(
      'Versionsauswahl zeigt nur eingefrorene Versionen, Export liefert das '
      'gespeicherte JSON', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Brot'));
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
          RecipeIngredient(id: 'i1', versionId: v1, position: 1, displayName: 'Mehl', quantity: Decimal.fromInt(500), unitCode: 'g'),
        ],
        steps: const [],
      ));
      await recipeRepo.snapshotVersion(v1);
      // Zweite, noch nicht eingefrorene Version -- darf nicht in der
      // Versionsauswahl erscheinen.
      await recipeRepo.createDraftFrom(v1);
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: ExportScreen()),
    ));
    await _settle(tester);

    await tester.tap(find.widgetWithText(AppSelect<String>, 'Rezept'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brot').last);
    await tester.pumpAndSettle();
    await _settle(tester);

    // Dropdown-Einträge existieren erst im Baum, während das Menü offen
    // ist (Overlay) -- deshalb erst öffnen, dann auf V1/V2 prüfen.
    await tester.tap(find.widgetWithText(AppSelect<String>, 'Version'));
    await tester.pumpAndSettle();

    expect(find.text('V1'), findsOneWidget);
    expect(find.text('V2'), findsNothing);

    await tester.tap(find.text('V1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppButton, 'Exportieren'));
    await _settle(tester);

    expect(find.textContaining('unsalted_recipe_snapshot'), findsOneWidget);
    expect(find.textContaining('"title":"Brot"'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('ohne eingefrorene Version erscheint ein Hinweis statt einer Auswahl',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);

    await tester.runAsync(() => recipeRepo.createRecipe(const NewRecipe(title: 'Nur Entwurf')));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: ExportScreen()),
    ));
    await _settle(tester);

    await tester.tap(find.widgetWithText(AppSelect<String>, 'Rezept'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nur Entwurf').last);
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(find.text('Keine eingefrorene Version vorhanden.'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });
}
