// test/theme/ds04b_reflow_test.dart
//
// DS-04b (Teil 1.3, D12): Maße, die mit der Textgröße wachsen
// (`AppReflowMetric`) — Werte nur aus dem Generat, zwischen 100 und 200 %
// linear, darüber der Wert bei 200 %, darunter der bei 100 % (F5); Linien
// und Abstände je nach Anordnung.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

void main() {
  test('DS-04b: ein Eintrag je reflow-Token, Werte aus dem Generat', () {
    expect([for (final m in AppReflowMetric.values) m.figmaName], AppReflow.byFigmaName.keys);
    expect(AppReflow.byFigmaNameAt200.keys, AppReflow.byFigmaName.keys);
    expect(AppReflowMetric.valueColumn.at100, AppReflow.valueColumn);
    expect(AppReflowMetric.valueColumn.at200, AppReflow.byFigmaNameAt200['reflow/value-column']);
  });

  test('DS-04b: zwischen 100 und 200 % linear, außerhalb begrenzt', () {
    for (final m in AppReflowMetric.values) {
      expect(m.at(1), m.at100, reason: m.name);
      expect(m.at(2), m.at200, reason: m.name);
      expect(m.at(1.5), (m.at100 + m.at200) / 2, reason: m.name);
      expect(m.at(3), m.at200, reason: '${m.name}: über 200 % der Wert bei 200 %');
      expect(m.at(0.85), m.at100, reason: '${m.name}: unter 100 % der Wert bei 100 %');
    }
  });

  testWidgets('DS-04b: Wert für die Textgröße des Kontexts', (tester) async {
    final seen = <double, double>{};
    for (final scale in [1.0, 1.5, 2.0, 2.5]) {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Builder(builder: (context) {
          seen[scale] = AppReflowMetric.valueColumn.of(context);
          return const SizedBox.shrink();
        }),
      ));
    }
    final at100 = AppReflowMetric.valueColumn.at100;
    final at200 = AppReflowMetric.valueColumn.at200;
    expect(seen, {1.0: at100, 1.5: (at100 + at200) / 2, 2.0: at200, 2.5: at200});
  });

  test('DS-04b: Linien und Abstände nach Anordnung', () {
    expect(AppReflowMetric.ruleInline.arranged(stacked: false), AppReflow.ruleInline);
    expect(AppReflowMetric.ruleInline.arranged(stacked: true), AppReflow.byFigmaNameAt200['reflow/rule-inline']);
    expect(AppReflowMetric.ruleStacked.arranged(stacked: true), AppReflow.byFigmaNameAt200['reflow/rule-stacked']);
    expect(AppReflowMetric.insetInline.arranged(stacked: false), AppReflow.insetInline);
  });
}
