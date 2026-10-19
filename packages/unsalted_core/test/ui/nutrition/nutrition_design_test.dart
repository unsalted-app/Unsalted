// test/ui/nutrition/nutrition_design_test.dart
//
// UI-70 und UI-71 (Teil 1.3, D15): Nährwerte nach Figma.
// UI-70: Der Kopf ist eine Kennzahlenleiste (Fertiggewicht, Gesamt,
// kcal/Portion) mit Werten aus dem NutritionFormatter, „*“ für unvollständig,
// „—“ für unbekannt; der Hinweis „Nicht berechenbar …“ ist eine Warnung mit
// unverändertem Text; bei großer Schrift ohne Überlauf.
// UI-71: Die Tabelle ist eine Deklaration („davon“ eingerückt, kcal-Zeile
// hervorgehoben); der Mengenrechner zeigt zwei Zahlenfelder (rechtsbündig,
// Gramm mit Einheit im Feld) mit dem Symbol `swap` dazwischen und stellt bei
// großer Schrift das zweite Feld darunter.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_result.dart';
import 'package:unsalted_core/src/ui/nutrition/amount_calculator.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_header.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_table.dart';
import 'package:unsalted_design/unsalted_design.dart';

Decimal _d(String v) => Decimal.parse(v);

NutritionResult _result({
  Decimal? totalKcal,
  bool perServing = true,
  Set<String> incomplete = const {},
  List<String> notCalculable = const [],
}) {
  final set = NutrientSet(
    energyKcal: _d('350'),
    fatG: _d('10'),
    saturatedFatG: _d('4'),
    carbsG: _d('50'),
    sugarsG: _d('5'),
    fiberG: _d('3'),
    proteinG: _d('8'),
    saltG: _d('1.2'),
  );
  return NutritionResult(
    rawWeightG: _d('1000'),
    finalWeightG: _d('1000'),
    total: NutrientSet(energyKcal: totalKcal),
    per100g: set,
    perServing: perServing ? NutrientSet(energyKcal: _d('875')) : null,
    incomplete: incomplete,
    notCalculable: notCalculable,
    hasAnyNutrition: true,
  );
}

Future<void> _pump(WidgetTester tester, Widget child, {double scale = 1}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light(), home: Scaffold(body: SingleChildScrollView(child: child))),
  );
}

AppValue _valueOf(WidgetTester tester, String label) => tester.widget<AppValue>(find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(MergeSemantics)),
      matching: find.byType(AppValue),
    ));

void main() {
  testWidgets('UI-70: Kopf als Kennzahlenleiste mit Werten aus dem Formatter', (tester) async {
    await _pump(tester, NutritionHeader(result: _result(totalKcal: _d('3500.4'), incomplete: {'energy_kcal'})));
    expect(find.byType(AppFigureRow), findsOneWidget);
    expect(find.text('Fertiggewicht'), findsOneWidget);
    expect(find.text('Gesamt'), findsOneWidget);
    expect(find.text('kcal/Portion'), findsOneWidget);

    final weight = _valueOf(tester, 'Fertiggewicht');
    expect((weight.value, weight.unit, weight.certainty), ('1.000,0', 'g', AppCertainty.known));
    final total = _valueOf(tester, 'Gesamt');
    expect((total.value, total.unit, total.certainty), ('3.500', 'kcal', AppCertainty.incomplete));
    final serving = _valueOf(tester, 'kcal/Portion');
    expect((serving.value, serving.certainty), ('875', AppCertainty.incomplete));
    expect(find.byType(AppNotice), findsNothing);
  });

  testWidgets('UI-70: unbekannt als „—“, ohne Portionen zwei Kennzahlen, Hinweis als Warnung', (tester) async {
    await _pump(tester, NutritionHeader(result: _result(perServing: false, notCalculable: ['Milch', 'Ei'])));
    expect(_valueOf(tester, 'Gesamt').certainty, AppCertainty.unknown);
    expect(find.text('kcal/Portion'), findsNothing);
    expect(tester.widget<AppFigureRow>(find.byType(AppFigureRow)).figures, hasLength(2));
    final notice = tester.widget<AppNotice>(find.byType(AppNotice));
    expect(notice.kind, AppNoticeKind.warning);
    expect(notice.message, 'Nicht berechenbar (fehlende Dichte/Stückgewicht): Milch, Ei');
  });

  testWidgets('UI-70: bei 200 % ohne Überlauf, Kennzahlen untereinander', (tester) async {
    await _pump(tester, NutritionHeader(result: _result(totalKcal: _d('3500'))), scale: 2);
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('Gesamt')).dy, greaterThan(tester.getBottomLeft(find.text('Fertiggewicht')).dy));
  });

  testWidgets('UI-71: Deklaration — „davon“ eingerückt, kcal-Zeile hervorgehoben', (tester) async {
    await _pump(tester, NutritionTable(result: _result(totalKcal: _d('3500'))));
    final rows = {for (final r in tester.widget<AppKeyValueTable>(find.byType(AppKeyValueTable)).rows) r.label: r};
    expect(rows['Kalorien (kcal)']!.strong, isTrue);
    expect(rows['davon gesättigte Fettsäuren (g)']!.sub, isTrue);
    expect(rows['davon Zucker (g)']!.sub, isTrue);
    expect([for (final r in rows.values) if (r.sub) r.label], hasLength(2));
    expect([for (final r in rows.values) if (r.strong) r.label], ['Kalorien (kcal)']);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('UI-71: Mengenrechner bei Textgröße ${scale * 100} %', (tester) async {
      await _pump(tester, AmountCalculator(result: _result(totalKcal: _d('3500'))), scale: scale);
      expect(tester.takeException(), isNull);
      final fields = tester.widgetList<AppTextField>(find.byType(AppTextField)).toList();
      expect([for (final f in fields) f.label], ['Gramm', 'kcal']);
      expect(fields.first.unit, 'g');
      for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.textAlign, TextAlign.end, reason: 'Zahlen rechtsbündig');
      }
      expect(find.byIcon(AppIcons.swap), findsOneWidget);
      final grams = tester.getRect(find.byType(AppTextField).first);
      final kcal = tester.getRect(find.byType(AppTextField).last);
      final swap = tester.getRect(find.byIcon(AppIcons.swap));
      expect(swap.left, greaterThan(grams.right), reason: 'Symbol neben dem ersten Feld');
      if (scale == 1) {
        expect(kcal.top, grams.top, reason: 'nebeneinander');
        expect(kcal.left, greaterThan(swap.right));
      } else {
        expect(kcal.top, greaterThan(grams.bottom), reason: 'zweites Feld darunter');
        expect(kcal.width, greaterThan(grams.width), reason: 'in voller Breite');
      }
    });
  }
}
