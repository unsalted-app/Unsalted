// test/ui/foods/food_editor_screen_test.dart
//
// Schritt 8.1, Bildschirm 10: Erstellen, Bearbeiten, Speichern über
// FoodRepository. NativeDatabase.memory() braucht WidgetTester.runAsync()
// (siehe food_list_screen_test.dart).

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart';
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/foods/food_editor_screen.dart';

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

void main() {
  testWidgets('Erstellen: FAB ist erst nach gültigem Namen aktiv, createVariant wird aufgerufen',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));
    final dao = DriftFoodDao(database);

    await _pumpEditor(tester, database);

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull, reason: 'ohne Namen nicht speicherbar');

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Neues Produkt');
    await tester.pump();

    final fabAfter = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fabAfter.onPressed, isNotNull);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);

    final variants = await tester.runAsync(() => dao.watchAll().first);
    expect(variants!.map((v) => v.name), contains('Neues Produkt'));

    await _disposeWidgetTree(tester);
  });

  testWidgets('Bearbeiten: lädt bestehende Variante vor und ruft updateVariant auf',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

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

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zucker (raffiniert)');
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);

    final repo = DriftFoodRepository(DriftFoodDao(database));
    final updated = await tester.runAsync(() => repo.getById(id!));
    expect(updated!.name, 'Zucker (raffiniert)');

    await _disposeWidgetTree(tester);
  });

  testWidgets('Formularfehler blockiert die Speichern-Aktion (FAB deaktiviert)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await _pumpEditor(tester, database);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Testprodukt');
    await tester.enterText(find.widgetWithText(TextField, 'Fett (g)'), '-1');
    await tester.pump();

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull);

    await _disposeWidgetTree(tester);
  });
}
