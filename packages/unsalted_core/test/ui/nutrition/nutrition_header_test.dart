// test/ui/nutrition/nutrition_header_test.dart
//
// Schritt 8.4, Bildschirm 5 (Kopf): Fertiggewicht, Gesamt-kcal,
// kcal/Portion (nur wenn servings gesetzt), Hinweis bei notCalculable.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_result.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_header.dart';

NutritionResult _result({
  Decimal? perServingKcal,
  List<String> notCalculable = const [],
  Set<String> incomplete = const {},
}) {
  return NutritionResult(
    rawWeightG: Decimal.fromInt(1000),
    finalWeightG: Decimal.fromInt(1000),
    total: NutrientSet(energyKcal: Decimal.fromInt(3500)),
    per100g: NutrientSet(energyKcal: Decimal.fromInt(350)),
    perServing: perServingKcal == null ? null : NutrientSet(energyKcal: perServingKcal),
    incomplete: incomplete,
    notCalculable: notCalculable,
    hasAnyNutrition: true,
  );
}

void main() {
  testWidgets('zeigt Fertiggewicht und Gesamt-kcal', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionHeader(result: _result())),
    ));

    expect(find.textContaining('Fertiggewicht'), findsOneWidget);
    expect(find.textContaining('1.000'), findsOneWidget); // Gramm-Formatierung
    expect(find.textContaining('3.500'), findsOneWidget); // kcal-Formatierung
  });

  testWidgets('kcal/Portion nur sichtbar, wenn servings gesetzt war (perServing != null)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionHeader(result: _result())),
    ));
    expect(find.textContaining('kcal/Portion'), findsNothing);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionHeader(result: _result(perServingKcal: Decimal.fromInt(350)))),
    ));
    expect(find.textContaining('kcal/Portion'), findsOneWidget);
  });

  testWidgets('Hinweisblock erscheint nur, wenn notCalculable nicht leer ist', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionHeader(result: _result())),
    ));
    expect(find.textContaining('Nicht berechenbar'), findsNothing);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionHeader(result: _result(notCalculable: const ['Öl']))),
    ));
    expect(find.textContaining('Nicht berechenbar'), findsOneWidget);
    expect(find.textContaining('Öl'), findsOneWidget);
  });
}
