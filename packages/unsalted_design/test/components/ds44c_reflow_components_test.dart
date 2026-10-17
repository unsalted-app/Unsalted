// test/components/ds44c_reflow_components_test.dart
//
// DS-43c und DS-44c (Teil 1.3, D12): große Schrift — Nebeneinander wird
// untereinander. Die Aktionsleiste stellt ihre Aktionen untereinander, sobald
// eine schmaler als `reflow-field-min` würde; die Deklarationstabelle bricht
// jede Zeile um (Bezeichnung oben, Werte darunter rechtsbündig), sobald der
// Bezeichnung weniger als `reflow-label-min` bliebe. Die Wertspalte ist
// `reflow-value-column` breit (Innenabstand in der Zelle).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

/// Zeigt [child] in [variant] bei Textgröße [scale].
Future<void> _pumpScaled(WidgetTester tester, Variant variant, double scale, Widget child) async {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await pumpVariant(tester, variant, child);
}

const _table = AppKeyValueTable(
  headers: ['pro 100', 'pro Teil'],
  rows: [
    AppTableRow('Erste', ['1', '2']),
    AppTableRow('davon', ['3', '4'], sub: true),
  ],
);

void main() {
  for (final scale in [1.0, 2.0]) {
    testVariants('DS-43c: Aktionsleiste bei Textgröße ${scale * 100} %', (tester, variant) async {
      await _pumpScaled(
        tester,
        variant,
        scale,
        Column(children: [
          const Spacer(),
          AppBottomActionBar(actions: [AppButton.primary(label: 'Allein', onPressed: () {})]),
          AppBottomActionBar(actions: [
            AppButton.secondary(label: 'Links', onPressed: () {}),
            AppButton.primary(label: 'Rechts', onPressed: () {}),
          ]),
        ]),
      );
      final full = variant.size.width - 2 * AppSpacing.l;
      expect(tester.getSize(find.widgetWithText(ElevatedButton, 'Allein')).width, full);
      final left = tester.getRect(find.widgetWithText(OutlinedButton, 'Links'));
      final right = tester.getRect(find.widgetWithText(ElevatedButton, 'Rechts'));
      final share = (full - AppSpacing.m) / 2;
      if (share < AppReflowMetric.fieldMin.at(scale)) {
        expect(left.width, full, reason: 'untereinander, jede in voller Breite');
        expect(right.width, full);
        expect(right.top - left.bottom, AppSpacing.m, reason: 'Reihenfolge bleibt, Abstand space-m');
      } else {
        expect(left.top, right.top, reason: 'nebeneinander');
        expect(left.width, share);
      }
    });

    testVariants('DS-44c: Deklaration bei Textgröße ${scale * 100} %', (tester, variant) async {
      await _pumpScaled(tester, variant, scale, _table);
      final width = variant.size.width;
      final column = AppReflowMetric.valueColumn.at(scale);
      final stacked = width - 2 * column < AppReflowMetric.labelMin.at(scale);
      expect(tester.getTopRight(find.text('2')).dx, closeTo(width, 1));
      expect(tester.getTopRight(find.text('1')).dx, closeTo(width - column, 1), reason: 'Wertspalte reflow-value-column');
      expect(tester.getTopRight(find.text('pro Teil')).dx, closeTo(width, 1));
      expect(tester.getTopLeft(find.text('davon')).dx, AppSpacing.l, reason: 'davon-Zeilen eingerückt');
      if (stacked) {
        expect(find.byType(Table), findsNothing);
        expect(tester.getTopLeft(find.text('Erste')).dx, 0);
        expect(tester.getTopLeft(find.text('1')).dy, greaterThanOrEqualTo(tester.getBottomLeft(find.text('Erste')).dy),
            reason: 'Werte unter der Bezeichnung');
        expect(tester.getTopLeft(find.text('Erste')).dy, greaterThanOrEqualTo(tester.getBottomLeft(find.text('pro Teil')).dy));
      } else {
        expect(find.byType(Table), findsOneWidget);
        expect(tester.getTopLeft(find.text('1')).dy, tester.getTopLeft(find.text('Erste')).dy, reason: 'eine Zeile');
      }
    });
  }

  testVariants('DS-44c: bei 200 % am Handy untereinander, auf dem Tablet nebeneinander', (tester, variant) async {
    await _pumpScaled(tester, variant, 2, _table);
    final handy = variant.size.width < AppBreakpoints.medium;
    expect(find.byType(Table), handy ? findsNothing : findsOneWidget);
  });
}
