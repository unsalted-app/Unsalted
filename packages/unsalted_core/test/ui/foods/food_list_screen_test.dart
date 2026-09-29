// test/ui/foods/food_list_screen_test.dart
//
// Schritt 8.1, Bildschirm 9: Suche, leerer Zustand, Liste, Navigation.
//
// NativeDatabase.memory() macht echte, nicht gefakte Async-Arbeit (FFI/
// Isolate-Kommunikation). Unter testWidgets() läuft Code standardmäßig in
// einer FakeAsync-Zone (für Timer-Steuerung) -- echte Async-Arbeit muss
// deshalb über WidgetTester.runAsync() laufen, sonst hängt der Test.

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
import 'package:unsalted_core/src/ui/foods/food_list_screen.dart';

Future<CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _pumpFoodList(WidgetTester tester, CoreDatabase database) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: const MaterialApp(home: FoodListScreen()),
  ));
  // Erste Stream-Emission der (echten, nicht gefakten) DB-Abfrage abwarten.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
}

/// Drifts QueryStream plant beim Abbestellen (StreamBuilder.dispose) einen
/// echten Zero-Duration-Timer zum Schließen. Baut die Testfläche ab, WÄHREND
/// noch aktiv gepumpt werden kann, und pumpt diesen Timer danach einmal aus
/// -- sonst meldet flutter_test am Testende "Timer is still pending even
/// after the widget tree was disposed", weil dieser Timer sonst erst nach
/// dem eigenen Invarianten-Check der Fake-Async-Zone feuert.
Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets('leerer Zustand zeigt "Eigenes Produkt anlegen"', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await _pumpFoodList(tester, database);

    expect(find.text('Keine Lebensmittel gefunden.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Eigenes Produkt anlegen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('vorhandene Lebensmittel werden gelistet', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await tester.runAsync(() async {
      final repo = DriftFoodRepository(DriftFoodDao(database));
      await repo.createVariant(NewFoodVariant(
        name: 'Mehl',
        brand: null,
        barcode: null,
        source: FoodSource.custom,
        sourceRef: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: NutrientSet(energyKcal: Decimal.fromInt(300)),
      ));
    });

    await _pumpFoodList(tester, database);

    expect(find.text('Mehl'), findsOneWidget);
    expect(find.text('Keine Lebensmittel gefunden.'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Suche filtert die Liste', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await tester.runAsync(() async {
      final repo = DriftFoodRepository(DriftFoodDao(database));
      for (final name in ['Mehl', 'Zucker']) {
        await repo.createVariant(NewFoodVariant(
          name: name,
          brand: null,
          barcode: null,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: null,
          gramsPerPiece: null,
          servingSizeG: null,
          nutrients: const NutrientSet(),
        ));
      }
    });

    await _pumpFoodList(tester, database);
    expect(find.text('Mehl'), findsOneWidget);
    expect(find.text('Zucker'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Meh');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();

    expect(find.text('Mehl'), findsOneWidget);
    expect(find.text('Zucker'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('FAB öffnet den Editor im Erstellen-Modus', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => tester.runAsync(database.close));

    await _pumpFoodList(tester, database);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FoodEditorScreen), findsOneWidget);
    expect(find.text('Lebensmittel anlegen'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });
}
