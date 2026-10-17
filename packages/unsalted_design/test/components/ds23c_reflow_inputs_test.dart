// test/components/ds23c_reflow_inputs_test.dart
//
// DS-23c und DS-25c (Teil 1.3, D16): Eingaben bei großer Schrift.
// DS-23c: Das schmale Feld (`AppFieldWidth.narrow`) ist `reflow-field-min`
// breit und wächst mit der Textgröße.
// DS-25c: Eine Auswahl ohne Beschriftung füllt mit `expand` ihre Breite und
// kürzt lange Einträge, statt überzulaufen; ohne `expand` bleibt sie so
// breit wie ihr Inhalt.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

const _items = [AppSelectItem('g', 'Gramm'), AppSelectItem('ms', 'Messerspitze mit langem Namen')];

void main() {
  for (final scale in [1.0, 1.5, 2.0]) {
    testVariants('DS-23c: schmales Feld bei Textgröße ${scale * 100} %', (tester, variant) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpVariant(
        tester,
        variant,
        const Align(alignment: Alignment.topLeft, child: AppTextField(label: 'Min.', width: AppFieldWidth.narrow)),
      );
      expect(tester.getSize(find.byType(AppTextField)).width, AppReflowMetric.fieldMin.at(scale));
    });
  }

  testVariants('DS-25c: Auswahl mit expand füllt die Breite ohne Überlauf', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Row(children: [
        SizedBox(
          width: AppReflow.selectMin,
          child: AppSelect<String>(items: _items, value: 'ms', onChanged: (_) {}, expand: true),
        ),
      ]),
    );
    expect(tester.takeException(), isNull, reason: 'langer Eintrag wird gekürzt');
    expect(tester.getSize(find.byType(DropdownButton<String>)).width, AppReflow.selectMin);
  });

  testVariants('DS-25c: ohne expand so breit wie der Inhalt', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Row(children: [AppSelect<String>(items: const [AppSelectItem('g', 'g')], value: 'g', onChanged: (_) {})]),
    );
    expect(tester.getSize(find.byType(DropdownButton<String>)).width, lessThan(AppReflow.selectMin));
  });
}
