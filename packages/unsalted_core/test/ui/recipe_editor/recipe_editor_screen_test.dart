// test/ui/recipe_editor/recipe_editor_screen_test.dart
//
// Schritt 8.3, Bildschirm 3: UI-03 (Editor speichert und zeigt Live-
// Nährwerte), UI-04 (Editor verweigert Bearbeiten einer Snapshot-Version).
// UI-11 bis UI-15 (Fehlerbehebung 9.1b, Erweiterung von 23.6): die
// Lebensmittel-Verknüpfung einer Zeile ändert sich nur durch Auswahl oder
// Namensänderung, auch wenn das Lebensmittel weich gelöscht ist.
// UI-16 bis UI-21 (Fehlerbehebung 9.2a, Befund 1): Schritt-Timer eingeben.

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
import 'package:unsalted_core/src/recipe/recipe_step.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/ingredient_row.dart';
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

/// Schließt [database] im Teardown, auch wenn der Test vorher scheitert
/// (Teil 1.1d). Nach einem roten Test lässt flutter_test den Widget-Baum stehen,
/// und Drift wartet beim Schließen auf seine Abbestell-Timer in der Fake-Zone,
/// die dann niemand mehr auspumpt -- der Lauf hinge. Deshalb erst den Baum
/// abbauen und auspumpen, dann schließen.
Future<void> _closeDatabase(WidgetTester tester, db.CoreDatabase database) async {
  await _disposeWidgetTree(tester);
  await tester.runAsync(database.close);
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
    addTearDown(() => _closeDatabase(tester, database));

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
    addTearDown(() => _closeDatabase(tester, database));

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
    addTearDown(() => _closeDatabase(tester, database));

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

  // -------------------------------------------------------------------------
  // 9.1b: "Mehl" ist mit einem aktiven Lebensmittel verknüpft, "Butter" mit
  // einem danach weich gelöschten. "Margarine" steht zur Auswahl bereit.
  // -------------------------------------------------------------------------
  Future<({String recipeId, String versionId, String mehl, String butter, String margarine})> seedDeletedLink(
    WidgetTester tester,
    db.CoreDatabase database,
  ) async {
    final recipeDao = DriftRecipeDao(database);
    final foodDao = DriftFoodDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, foodDao, database);
    final foodRepo = DriftFoodRepository(foodDao);

    Future<String> variant(String name, int kcal) => foodRepo.createVariant(NewFoodVariant(
          name: name,
          brand: null,
          barcode: null,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: null,
          gramsPerPiece: null,
          servingSizeG: null,
          nutrients: NutrientSet(energyKcal: Decimal.fromInt(kcal)),
        ));

    return (await tester.runAsync(() async {
      final mehl = await variant('Mehl', 343);
      final butter = await variant('Butter', 741);
      final margarine = await variant('Margarine', 720);
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Mürbeteig'));
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
        ingredients: [
          RecipeIngredient(id: 'i1', versionId: versionId, position: 1, foodVariantId: mehl,
              displayName: 'Mehl', quantity: Decimal.fromInt(200), unitCode: 'g'),
          RecipeIngredient(id: 'i2', versionId: versionId, position: 2, foodVariantId: butter,
              displayName: 'Butter', quantity: Decimal.fromInt(50), unitCode: 'g'),
        ],
        steps: const [],
      ));
      await foodRepo.softDeleteVariant(butter);
      return (recipeId: recipeId, versionId: versionId, mehl: mehl, butter: butter, margarine: margarine);
    }))!;
  }

  Future<Map<String, RecipeIngredient>> saveAndReadRows(WidgetTester tester, db.CoreDatabase database, String versionId) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Speichern'));
    await _settle(tester);
    final rows = await tester.runAsync(() => DriftRecipeDao(database).getIngredientsForVersion(versionId));
    return {
      for (final r in rows!)
        r.id: RecipeIngredient(
          id: r.id,
          versionId: r.versionId,
          position: r.position,
          foodVariantId: r.foodVariantId,
          displayName: r.displayName,
          quantity: r.quantity,
          unitCode: r.unitCode,
          note: r.note,
        ),
    };
  }

  testWidgets('UI-11: Speichern nach Änderung an einer anderen Zeile behält die Verknüpfung zum gelöschten Lebensmittel',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final seed = await seedDeletedLink(tester, database);

    await _pumpEditor(tester, database, recipeId: seed.recipeId, versionId: seed.versionId);
    await tester.enterText(find.widgetWithText(TextField, 'Menge').first, '250');
    await tester.pump();
    final rows = await saveAndReadRows(tester, database, seed.versionId);

    expect(rows['i1']!.quantity, Decimal.fromInt(250));
    expect(rows['i1']!.foodVariantId, seed.mehl);
    expect(rows['i2']!.foodVariantId, seed.butter);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-12: Menge, Einheit, Notiz und Position derselben Zeile ändern die Verknüpfung nicht',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final seed = await seedDeletedLink(tester, database);

    await _pumpEditor(tester, database, recipeId: seed.recipeId, versionId: seed.versionId);
    await tester.enterText(find.widgetWithText(TextField, 'Menge').at(1), '60');
    await tester.enterText(find.widgetWithText(TextField, 'Notiz').at(1), 'kalt');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('kg').last);
    await tester.pumpAndSettle();

    // "Butter" per Long-Press-Drag an Position 1 ziehen.
    final from = tester.getCenter(find.byIcon(Icons.drag_handle).at(1));
    final to = tester.getCenter(find.byIcon(Icons.drag_handle).first);
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(seconds: 1));
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(Offset.lerp(from, to - const Offset(0, 30), i / 10)!);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Butter').evaluate().isNotEmpty, isTrue);
    expect(tester.getCenter(find.widgetWithText(TextField, 'Butter')).dy,
        lessThan(tester.getCenter(find.widgetWithText(TextField, 'Mehl')).dy),
        reason: 'Drag hat die Reihenfolge nicht geändert');

    final butter = (await saveAndReadRows(tester, database, seed.versionId))['i2']!;

    expect(butter.position, 1);
    expect(butter.quantity, Decimal.fromInt(60));
    expect(butter.unitCode, 'kg');
    expect(butter.note, 'kalt');
    expect(butter.foodVariantId, seed.butter);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-13: Namensänderung löst die Verknüpfung weiterhin', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final seed = await seedDeletedLink(tester, database);

    await _pumpEditor(tester, database, recipeId: seed.recipeId, versionId: seed.versionId);
    await tester.enterText(find.widgetWithText(TextField, 'Name').at(1), 'Pflanzenfett');
    await tester.pump();
    final butter = (await saveAndReadRows(tester, database, seed.versionId))['i2']!;

    expect(butter.displayName, 'Pflanzenfett');
    expect(butter.foodVariantId, isNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-14: Auswahl eines anderen Lebensmittels ersetzt die Verknüpfung', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final seed = await seedDeletedLink(tester, database);

    await _pumpEditor(tester, database, recipeId: seed.recipeId, versionId: seed.versionId);
    await tester.tap(find.byIcon(Icons.search).at(1));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.tap(find.text('Margarine'));
    await tester.pump();
    final butter = (await saveAndReadRows(tester, database, seed.versionId))['i2']!;

    expect(butter.displayName, 'Margarine');
    expect(butter.foodVariantId, seed.margarine);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-15: Hinweis bei gelöschtem Lebensmittel; Vorschau rechnet die Zeile wie unverknüpft',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final seed = await seedDeletedLink(tester, database);

    await _pumpEditor(tester, database, recipeId: seed.recipeId, versionId: seed.versionId);

    expect(find.text(deletedVariantHint), findsOneWidget);
    expect(deletedVariantHint, 'Verknüpftes Lebensmittel wurde gelöscht – bitte neu auswählen.');
    // Nur Mehl rechnet: 200 g × 343 kcal/100 g = 686 kcal.
    expect(find.textContaining('686'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _disposeWidgetTree(tester);
  });

  // -------------------------------------------------------------------------
  // 9.2a, Befund 1: Schritt 1 ohne Timer, Schritt 2 mit 600 s, Schritt 3 mit
  // importierten 90 s (keine ganzen Minuten).
  // -------------------------------------------------------------------------
  Future<(String, String)> seedTimerRecipe(WidgetTester tester, db.CoreDatabase database) async {
    final recipeDao = DriftRecipeDao(database);
    final recipeRepo = DriftRecipeRepository(recipeDao, DriftFoodDao(database), database);
    return (await tester.runAsync(() async {
      final recipeId = await recipeRepo.createRecipe(const NewRecipe(title: 'Brot'));
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
        ingredients: [
          RecipeIngredient(id: 'i1', versionId: versionId, position: 1, displayName: 'Mehl',
              quantity: Decimal.fromInt(500), unitCode: 'g'),
        ],
        steps: [
          RecipeStep(id: 's1', versionId: versionId, position: 1, instruction: 'Kneten'),
          RecipeStep(id: 's2', versionId: versionId, position: 2, instruction: 'Gehen lassen', timerSeconds: 600),
          RecipeStep(id: 's3', versionId: versionId, position: 3, instruction: 'Ruhen', timerSeconds: 90),
        ],
      ));
      return (recipeId, versionId);
    }))!;
  }

  Finder timerField(int index) => find.widgetWithText(TextFormField, 'Timer (Min.)').at(index);

  String timerText(WidgetTester tester, int index) =>
      tester.widget<EditableText>(find.descendant(of: timerField(index), matching: find.byType(EditableText))).controller.text;

  Future<List<int?>> saveAndReadTimers(WidgetTester tester, db.CoreDatabase database, String versionId) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Speichern'));
    await _settle(tester);
    final steps = await tester.runAsync(() => DriftRecipeDao(database).getStepsForVersion(versionId));
    return [for (final s in steps!..sort((a, b) => a.position.compareTo(b.position))) s.timerSeconds];
  }

  testWidgets('UI-16: Timer setzen speichert Minuten × 60', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (recipeId, versionId) = await seedTimerRecipe(tester, database);

    await _pumpEditor(tester, database, recipeId: recipeId, versionId: versionId);
    expect(timerText(tester, 0), '');
    await tester.enterText(timerField(0), '8');
    await tester.pump();

    expect(await saveAndReadTimers(tester, database, versionId), [480, 600, 90]);
    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-17: Timer ändern überschreibt den geladenen Wert', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (recipeId, versionId) = await seedTimerRecipe(tester, database);

    await _pumpEditor(tester, database, recipeId: recipeId, versionId: versionId);
    expect(timerText(tester, 1), '10');
    await tester.enterText(timerField(1), '5');
    await tester.pump();

    expect(await saveAndReadTimers(tester, database, versionId), [null, 300, 90]);
    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-18: Timer leeren entfernt ihn', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (recipeId, versionId) = await seedTimerRecipe(tester, database);

    await _pumpEditor(tester, database, recipeId: recipeId, versionId: versionId);
    await tester.enterText(timerField(1), '');
    await tester.pump();

    expect(await saveAndReadTimers(tester, database, versionId), [null, null, 90]);
    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-19: ungültiger Timer markiert das Feld und blockiert Speichern', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (recipeId, versionId) = await seedTimerRecipe(tester, database);

    await _pumpEditor(tester, database, recipeId: recipeId, versionId: versionId);
    for (final invalid in ['0', '-3', 'abc', '2.5']) {
      await tester.enterText(timerField(0), invalid);
      await tester.pump();
      expect(find.text('Ganze Minuten > 0'), findsOneWidget, reason: invalid);
      expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Speichern')).onPressed, isNull,
          reason: invalid);
    }

    await tester.enterText(timerField(0), '3');
    await tester.pump();
    expect(find.text('Ganze Minuten > 0'), findsNothing);
    expect(await saveAndReadTimers(tester, database, versionId), [180, 600, 90]);
    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-20: unangefasster Sekundenwert bleibt sekundengenau erhalten', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (recipeId, versionId) = await seedTimerRecipe(tester, database);

    await _pumpEditor(tester, database, recipeId: recipeId, versionId: versionId);
    expect(timerText(tester, 2), '1:30');
    await tester.enterText(find.widgetWithText(TextFormField, 'Anweisung').at(2), 'Ruhen lassen');
    await tester.pump();
    expect(await saveAndReadTimers(tester, database, versionId), [null, 600, 90]);

    // Steht nach einer Bearbeitung wieder der Ausgangstext im Feld, gilt der
    // geladene Wert.
    await tester.enterText(timerField(2), '1:3');
    await tester.pump();
    await tester.enterText(timerField(2), '1:30');
    await tester.pump();
    expect(await saveAndReadTimers(tester, database, versionId), [null, 600, 90]);
    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-21: gesetzter Timer erscheint als Chip im Rezeptdetail', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final (recipeId, versionId) = await seedTimerRecipe(tester, database);

    await _pumpEditor(tester, database, recipeId: recipeId, versionId: versionId);
    await tester.enterText(timerField(0), '8');
    await tester.pump();
    await saveAndReadTimers(tester, database, versionId);

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(home: RecipeDetailScreen(recipeId: recipeId)),
    ));
    for (var i = 0; i < 4; i++) {
      await _settle(tester, millis: 150);
    }

    expect(find.widgetWithText(Chip, '8:00'), findsOneWidget);
    expect(find.widgetWithText(Chip, '10:00'), findsOneWidget);
    expect(find.widgetWithText(Chip, '1:30'), findsOneWidget);
    await _disposeWidgetTree(tester);
  });
}
