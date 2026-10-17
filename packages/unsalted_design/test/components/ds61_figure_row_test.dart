// test/components/ds61_figure_row_test.dart
//
// DS-61 (Teil 1.3, D15a): Kennzahlenleiste nach Figma `Core/Nutrition
// Header`/`Core/Nutrition Field` — Haarlinie oben und unten, Felder teilen
// die Breite, ab dem zweiten Feld links Haarlinie und `reflow-inset-inline`
// Einzug, Beschriftung `caption` in `text-secondary`; bei großer Schrift
// (Feld schmaler als `reflow-stat-min`) untereinander, getrennt durch eine
// Haarlinie, ohne Einzug; Beschriftung und Wert werden zusammen vorgelesen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

const _row = AppFigureRow(figures: [
  AppFigure(label: 'Erste', value: AppValue.strong(value: '1.250', unit: 'g')),
  AppFigure(label: 'Zweite', value: AppValue.strong(value: '3.500', unit: 'E')),
  AppFigure(label: 'Dritte', value: AppValue.strong(value: '875', unit: 'E', certainty: AppCertainty.incomplete)),
]);

AppColorTokens _colors(Variant variant) =>
    variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;

Border _borderOf(WidgetTester tester, Finder of) => (tester
        .widgetList<DecoratedBox>(find.ancestor(of: of, matching: find.byType(DecoratedBox)))
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.border != null)
        .border! as Border);

void main() {
  for (final scale in [1.0, 2.0]) {
    testVariants('DS-61: Kennzahlenleiste bei Textgröße ${scale * 100} %', (tester, variant) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpVariant(tester, variant, const Align(alignment: Alignment.topCenter, child: _row));
      expect(tester.takeException(), isNull);
      final c = _colors(variant);
      final hairline = BorderSide(color: c.lineHairline, width: AppStroke.hairline);

      final outer = tester.widget<DecoratedBox>(
          find.descendant(of: find.byType(AppFigureRow), matching: find.byType(DecoratedBox)).first);
      final border = (outer.decoration as BoxDecoration).border! as Border;
      expect(border.top, hairline);
      expect(border.bottom, hairline);
      expect(tester.widget<Text>(find.text('Erste')).style!.color, c.textSecondary);
      expect(tester.widget<Text>(find.text('Erste')).style!.fontSize, AppTypography.caption.fontSize);

      final width = tester.getSize(find.byType(AppFigureRow)).width;
      final stacked = width / 3 < AppReflowMetric.statMin.at(scale);
      final first = tester.getRect(find.text('Erste'));
      final second = tester.getRect(find.text('Zweite'));
      if (stacked) {
        expect(second.top, greaterThan(first.bottom), reason: 'untereinander');
        expect(second.left, first.left, reason: 'ohne Einzug');
        expect(_borderOf(tester, find.text('Zweite')).top, hairline);
      } else {
        expect(second.top, first.top, reason: 'nebeneinander');
        expect(second.left, closeTo(width / 3 + AppReflow.insetInline, 1), reason: 'Einzug nach der Linie');
        expect(_borderOf(tester, find.text('Zweite')).left, hairline);
      }
      if (scale == 1) expect(stacked, isFalse);
      if (scale == 2 && variant.size.width < AppBreakpoints.medium) expect(stacked, isTrue);
    });
  }

  testVariants('DS-61: Beschriftung und Wert werden zusammen vorgelesen', (tester, variant) async {
    final handle = tester.ensureSemantics();
    await pumpVariant(tester, variant, const Align(alignment: Alignment.topCenter, child: _row));
    expect(find.bySemanticsLabel(RegExp('^Zweite\n3\\.500\u00A0E\$')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Dritte\n875\u00A0E\\*\$')), findsOneWidget);
    handle.dispose();
  });
}
