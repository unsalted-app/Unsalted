// test/ui/foods/food_editor_screen_test.dart
//
// Schritt 8.1, Bildschirm 10: Erstellen, Bearbeiten, Speichern über
// FoodRepository. NativeDatabase.memory() braucht WidgetTester.runAsync()
// (siehe food_list_screen_test.dart). UI-29 bis UI-32 (Nachtrag 10.0,
// Erweiterung von 23.6): Zurück mit ungespeicherten Änderungen fragt nach.
// UI-43 (Teil 1.1b): „Löschen“ im AppBar-Menü kehrt ohne Verwerfen-Dialog
// zur Liste zurück und löscht dort nach 5 s „Rückgängig“.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_design/unsalted_design.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/foods/food_editor_screen.dart';
import 'package:unsalted_core/src/ui/foods/food_list_screen.dart';
import 'package:unsalted_core/src/ui/shared/undoable_deletion.dart';

Future<CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
}

Future<void> _pumpEditor(WidgetTester tester, CoreDatabase database, {String? foodId}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: MaterialApp(home: FoodEditorScreen(foodId: foodId)),
  ));
  await _settle(tester);
}

/// Siehe food_list_screen_test.dart: baut die Testfläche ab, während noch
/// aktiv gepumpt werden kann, um Drifts Zero-Duration-Cleanup-Timer vor
/// Testende auszupumpen.
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
  testWidgets('Erstellen: FAB ist erst nach gültigem Namen aktiv, createVariant wird aufgerufen',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final dao = DriftFoodDao(database);

    await _pumpEditor(tester, database);

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull, reason: 'ohne Namen nicht speicherbar');

    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Neues Produkt');
    await tester.pump();

    final fabAfter = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fabAfter.onPressed, isNotNull);

    await tester.tap(find.byType(AppFab));
    await _settle(tester);

    final variants = await tester.runAsync(() => dao.watchAll().first);
    expect(variants!.map((v) => v.name), contains('Neues Produkt'));

    await _disposeWidgetTree(tester);
  });

  testWidgets('Bearbeiten: lädt bestehende Variante vor und ruft updateVariant auf',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    final id = await tester.runAsync(() async {
      final repo = DriftFoodRepository(DriftFoodDao(database));
      return repo.createVariant(NewFoodVariant(
        name: 'Zucker',
        brand: null,
        barcode: null,
        source: FoodSource.custom,
        sourceRef: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: NutrientSet(energyKcal: Decimal.fromInt(400)),
      ));
    });

    await _pumpEditor(tester, database, foodId: id);

    expect(find.text('Zucker'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);

    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Zucker (raffiniert)');
    await tester.pump();
    await tester.tap(find.byType(AppFab));
    await _settle(tester);

    final repo = DriftFoodRepository(DriftFoodDao(database));
    final updated = await tester.runAsync(() => repo.getById(id!));
    expect(updated!.name, 'Zucker (raffiniert)');

    await _disposeWidgetTree(tester);
  });

  testWidgets('Formularfehler blockiert die Speichern-Aktion (FAB deaktiviert)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpEditor(tester, database);

    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Testprodukt');
    await tester.enterText(find.widgetWithText(AppTextField, 'Fett (g)'), '-1');
    await tester.pump();

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull);

    await _disposeWidgetTree(tester);
  });

  /// Öffnet den Editor über einen Startbildschirm, damit "Zurück" eine Route
  /// schließen kann.
  Future<void> openEditorFromLauncher(WidgetTester tester, CoreDatabase database, {String? foodId}) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => FoodEditorScreen(foodId: foodId),
              )),
              child: const Text('Öffnen'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Öffnen'));
    await tester.pumpAndSettle();
    await _settle(tester);
  }

  Future<String> createZucker(WidgetTester tester, CoreDatabase database) async =>
      (await tester.runAsync(() => DriftFoodRepository(DriftFoodDao(database)).createVariant(NewFoodVariant(
            name: 'Zucker',
            brand: null,
            barcode: null,
            source: FoodSource.custom,
            sourceRef: null,
            densityGPerMl: null,
            gramsPerPiece: null,
            servingSizeG: null,
            nutrients: NutrientSet(energyKcal: Decimal.fromInt(400)),
          ))))!;

  testWidgets('UI-29: ohne Änderung (nur Feld angetippt) schließt Zurück ohne Nachfrage', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await openEditorFromLauncher(tester, database);
    await tester.tap(find.widgetWithText(AppTextField, 'Marke'));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Änderungen verwerfen?'), findsNothing);
    expect(find.byType(FoodEditorScreen), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-30: Eingabe ohne Namen fragt nach; Abbrechen bleibt, Verwerfen schließt ohne Speichern',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await openEditorFromLauncher(tester, database);
    await tester.enterText(find.widgetWithText(AppTextField, 'Marke'), 'Alpenhof');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Änderungen verwerfen?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Abbrechen'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEditorScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Verwerfen'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEditorScreen), findsNothing);

    final variants = await tester.runAsync(() => DriftFoodDao(database).watchAll().first);
    expect(variants, isEmpty);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-31: Speichern nach Änderung schließt ohne Nachfrage', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final id = await createZucker(tester, database);

    await openEditorFromLauncher(tester, database, foodId: id);
    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Rohrzucker');
    await tester.pump();
    await tester.tap(find.byType(AppFab));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.text('Änderungen verwerfen?'), findsNothing);
    expect(find.byType(FoodEditorScreen), findsNothing);
    final updated = await tester.runAsync(() => DriftFoodRepository(DriftFoodDao(database)).getById(id));
    expect(updated!.name, 'Rohrzucker');

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-32: auf den Ausgangswert zurückgesetzter Text gilt nicht als Änderung', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final id = await createZucker(tester, database);

    await openEditorFromLauncher(tester, database, foodId: id);
    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Zuckerl');
    await tester.pump();
    await tester.enterText(find.widgetWithText(AppTextField, 'Name'), 'Zucker');
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Änderungen verwerfen?'), findsNothing);
    expect(find.byType(FoodEditorScreen), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('UI-43: „Löschen“ im Editor kehrt ohne Verwerfen-Dialog zur Liste zurück, nach 5 s gelöscht',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));
    final repo = DriftFoodRepository(DriftFoodDao(database));
    final apfel = (await tester.runAsync(() => repo.createVariant(NewFoodVariant(
          name: 'Apfel',
          brand: null,
          barcode: null,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: null,
          gramsPerPiece: null,
          servingSizeG: null,
          nutrients: NutrientSet(energyKcal: Decimal.fromInt(52)),
        ))))!;

    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: FoodListScreen()),
    ));
    await _settle(tester);

    await tester.tap(find.text('Apfel'));
    await tester.pumpAndSettle();
    await _settle(tester);
    expect(find.byType(FoodEditorScreen), findsOneWidget);

    // Ungespeicherte Änderung: Löschen fragt trotzdem nicht nach.
    await tester.enterText(find.widgetWithText(AppTextField, 'Marke'), 'Alpenhof');
    await tester.pump();

    await tester.tap(find.byType(AppOverflowMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(find.text('Änderungen verwerfen?'), findsNothing);
    expect(find.byType(FoodEditorScreen), findsNothing);
    expect(find.byType(FoodListScreen), findsOneWidget);
    expect(find.text('Apfel'), findsNothing);
    expect(find.text('„Apfel“ gelöscht. Eingefrorene Versionen behalten ihre Nährwerte.'), findsOneWidget);
    await _settle(tester);
    expect(await tester.runAsync(() => repo.getById(apfel)), isNotNull);

    await tester.pump(undoableDeletionDelay);
    await _settle(tester);
    await _settle(tester);
    expect(await tester.runAsync(() => repo.getById(apfel)), isNull);
    // runAsync liefert auch bei einer Ausnahme null -- die darf es nicht geben.
    expect(tester.takeException(), isNull);

    // Beim Anlegen gibt es nichts zu löschen, also kein Menü.
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppFab));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEditorScreen), findsOneWidget);
    expect(find.byType(AppOverflowMenu), findsNothing);

    await _disposeWidgetTree(tester);
  });
}
