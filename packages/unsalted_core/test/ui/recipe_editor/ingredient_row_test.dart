// test/ui/recipe_editor/ingredient_row_test.dart
//
// Schritt 8.3: IngredientRow -- Name/Menge/Einheit/Notiz-Änderungen, sowie
// die Lebensmittel-Verknüpfung über FoodRepository.search ("Autocomplete",
// Bildschirm 3). Fehlerbehebung 9.1b: foodVariantId wird mitgeführt.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/recipe_editor/ingredient_row.dart';

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory()));
  return database!;
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
  testWidgets('Namensänderung löst eine zuvor verknüpfte Variante', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    IngredientRowData? latest;
    final initialVariant = FoodVariant(id: 'v1', name: 'Mehl', source: FoodSource.custom);

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Scaffold(
          body: IngredientRow(
            data: IngredientRowData(
              id: 'i1',
              variant: initialVariant,
              displayName: 'Mehl',
              quantity: Decimal.fromInt(100),
              unitCode: 'g',
            ),
            onChanged: (data) => latest = data,
            onRemove: () {},
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Anderer Name');
    await tester.pump();

    expect(latest, isNotNull);
    expect(latest!.displayName, 'Anderer Name');
    expect(latest!.variant, isNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Verknüpfen-Dialog sucht über FoodRepository.search und übernimmt die Auswahl',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    final foodRepo = DriftFoodRepository(DriftFoodDao(database));
    await tester.runAsync(() => foodRepo.createVariant(NewFoodVariant(
          name: 'Zucker',
          brand: null,
          barcode: null,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: null,
          gramsPerPiece: null,
          servingSizeG: null,
          nutrients: NutrientSet(energyKcal: Decimal.fromInt(400)),
        )));

    IngredientRowData? latest;

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Scaffold(
          body: IngredientRow(
            data: IngredientRowData(
              id: 'i1',
              displayName: '',
              quantity: Decimal.zero,
              unitCode: 'g',
            ),
            onChanged: (data) => latest = data,
            onRemove: () {},
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();

    expect(find.text('Zucker'), findsOneWidget);
    await tester.tap(find.text('Zucker'));
    await tester.pump();

    expect(latest, isNotNull);
    expect(latest!.displayName, 'Zucker');
    expect(latest!.variant?.name, 'Zucker');

    await _disposeWidgetTree(tester);
  });

  test('IngredientRowData: Verknüpfung ändert sich nur über variant (9.1b)', () {
    final mehl = FoodVariant(id: 'v-mehl', name: 'Mehl', source: FoodSource.custom);
    expect(
      IngredientRowData(id: 'i1', variant: mehl, displayName: 'Mehl', quantity: Decimal.one, unitCode: 'g')
          .foodVariantId,
      'v-mehl',
      reason: 'ohne foodVariantId gilt die ID von variant',
    );

    final deleted = IngredientRowData(
      id: 'i2',
      foodVariantId: 'v-geloescht',
      displayName: 'Butter',
      quantity: Decimal.one,
      unitCode: 'g',
    );
    expect(deleted.hasUnresolvedVariant, isTrue);

    final edited = deleted.copyWith(quantity: Decimal.ten, unitCode: 'kg', note: () => 'kalt');
    expect(edited.foodVariantId, 'v-geloescht');
    expect(edited.hasUnresolvedVariant, isTrue);

    final relinked = edited.copyWith(variant: () => mehl);
    expect((relinked.foodVariantId, relinked.hasUnresolvedVariant), ('v-mehl', false));

    final unlinked = edited.copyWith(variant: () => null, displayName: 'Pflanzenfett');
    expect((unlinked.foodVariantId, unlinked.hasUnresolvedVariant), (null, false));
  });
}
