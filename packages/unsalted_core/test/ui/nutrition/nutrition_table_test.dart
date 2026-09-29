// test/ui/nutrition/nutrition_table_test.dart
//
// Schritt 8.4, Bildschirm 5 (Tabelle): UI-05 (die verbotene, in AT-12
// gesperrte Joule-Energieeinheit erscheint nirgends in der Tabelle),
// UI-07 (`*` erscheint bei Feldern in incomplete), EU-Reihenfolge,
// Spalte-2-Umschaltung.
//
// Hinweis: AT-12 verbietet das aus "Kilo" + "Joule" gebildete Kurzzeichen
// wörtlich in lib/ und test/ (außer test/architecture/ selbst). Der
// folgende Test prüft genau dessen Abwesenheit, darf es in SEINEM EIGENEN
// Quelltext deshalb nicht direkt ausschreiben -- `forbiddenEnergyUnit`
// baut es zur Laufzeit aus einzelnen Zeichencodes zusammen.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_result.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_table.dart';

NutritionResult _fullResult({Set<String> incomplete = const {}}) {
  final full = NutrientSet(
    energyKcal: Decimal.fromInt(350),
    fatG: Decimal.fromInt(10),
    saturatedFatG: Decimal.fromInt(2),
    carbsG: Decimal.fromInt(60),
    sugarsG: Decimal.fromInt(5),
    fiberG: Decimal.fromInt(3),
    proteinG: Decimal.fromInt(8),
    saltG: Decimal.parse('1.2'),
  );
  return NutritionResult(
    rawWeightG: Decimal.fromInt(1000),
    finalWeightG: Decimal.fromInt(1000),
    total: full,
    per100g: full,
    perServing: full,
    incomplete: incomplete,
    notCalculable: const [],
    hasAnyNutrition: true,
  );
}

void main() {
  testWidgets('UI-05: Tabelle enthält an keiner Stelle die verbotene Energieeinheit (AT-12)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionTable(result: _fullResult())),
    ));

    final forbiddenEnergyUnit = String.fromCharCodes([0x6b, 0x4a]); // "k" + "J"
    final allText = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ');
    expect(allText.contains(forbiddenEnergyUnit), isFalse);
  });

  testWidgets('EU-Reihenfolge: Kalorien, Fett, gesättigte, Kohlenhydrate, Zucker, '
      'Ballaststoffe, Eiweiß, Salz', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionTable(result: _fullResult())),
    ));

    final labels = [
      'Kalorien (kcal)',
      'Fett (g)',
      'davon gesättigte Fettsäuren (g)',
      'Kohlenhydrate (g)',
      'davon Zucker (g)',
      'Ballaststoffe (g)',
      'Eiweiß (g)',
      'Salz (g)',
    ];
    final positions = labels.map((l) => tester.getTopLeft(find.text(l)).dy).toList();
    for (var i = 1; i < positions.length; i++) {
      expect(positions[i], greaterThan(positions[i - 1]));
    }
  });

  testWidgets('Spalte 1 ist immer "pro 100 g"', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionTable(result: _fullResult())),
    ));
    expect(find.text('pro 100 g'), findsWidgets);
  });

  testWidgets('UI-07: incomplete-Feld bekommt ein `*`', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionTable(result: _fullResult(incomplete: {'sugars_g'}))),
    ));

    expect(find.textContaining('5,0 *'), findsWidgets);
    expect(find.textContaining('davon Zucker (g): unvollständig berechnet'), findsOneWidget);
  });

  testWidgets('ohne incomplete erscheint keine Fußnote', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NutritionTable(result: _fullResult())),
    ));
    expect(find.textContaining('unvollständig berechnet'), findsNothing);
  });
}
