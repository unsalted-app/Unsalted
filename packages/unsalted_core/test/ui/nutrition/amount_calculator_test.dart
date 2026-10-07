// test/ui/nutrition/amount_calculator_test.dart
//
// Schritt 8.4, Bildschirm 6: UI-06 (Mengenrechner rechnet in beide
// Richtungen), ungültige Eingabe färbt nur das Feld statt eine Exception
// zu werfen.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_design/unsalted_design.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_result.dart';
import 'package:unsalted_core/src/ui/nutrition/amount_calculator.dart';

NutritionResult _result() {
  return NutritionResult(
    rawWeightG: Decimal.fromInt(1000),
    finalWeightG: Decimal.fromInt(1000),
    total: NutrientSet(energyKcal: Decimal.fromInt(3500)),
    per100g: NutrientSet(energyKcal: Decimal.fromInt(350)),
    perServing: null,
    incomplete: const {},
    notCalculable: const [],
    hasAnyNutrition: true,
  );
}

void main() {
  testWidgets('UI-06: Gramm -> kcal', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AmountCalculator(result: _result())),
    ));

    await tester.enterText(find.widgetWithText(AppTextField, 'Gramm'), '200');
    await tester.pump();

    final kcalField = tester.widget<TextField>(find.widgetWithText(TextField, 'kcal'));
    expect(kcalField.controller!.text, '700');
  });

  testWidgets('UI-06: kcal -> Gramm', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AmountCalculator(result: _result())),
    ));

    await tester.enterText(find.widgetWithText(AppTextField, 'kcal'), '700');
    await tester.pump();

    final gramsField = tester.widget<TextField>(find.widgetWithText(TextField, 'Gramm'));
    expect(gramsField.controller!.text, '200');
  });

  testWidgets('ungültige Eingabe färbt nur das Feld, wirft keine Exception', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AmountCalculator(result: _result())),
    ));

    await tester.enterText(find.widgetWithText(AppTextField, 'Gramm'), 'abc');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Ungültige Zahl'), findsOneWidget);
  });

  testWidgets('Leeren eines Felds leert auch das gekoppelte Feld', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AmountCalculator(result: _result())),
    ));

    await tester.enterText(find.widgetWithText(AppTextField, 'Gramm'), '200');
    await tester.pump();
    await tester.enterText(find.widgetWithText(AppTextField, 'Gramm'), '');
    await tester.pump();

    final kcalField = tester.widget<TextField>(find.widgetWithText(TextField, 'kcal'));
    expect(kcalField.controller!.text, '');
  });
}
