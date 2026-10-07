// test/components/ds19_surfaces_test.dart
//
// DS-19 bis DS-22 (Teil 1.2): AppCard, AppSurface, AppDivider und AppSection.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-19: AppCard antippbar', (tester, variant) async {
    var taps = 0;
    await pumpVariant(tester, variant, AppCard(onTap: () => taps++, child: const Text('Karte')));
    expect(find.byType(Card), findsOneWidget);
    await tester.tap(find.text('Karte'));
    expect(taps, 1);
  });

  testVariants('DS-20: AppSurface Ton und volle Breite', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppSurface(key: Key('voll'), tone: AppSurfaceTone.high, fullWidth: true, child: Text('A')),
        Align(alignment: Alignment.centerLeft, child: AppSurface(key: Key('eng'), child: Text('B'))),
      ]),
    );
    final box = tester.widget<ColoredBox>(find.descendant(of: find.byKey(const Key('voll')), matching: find.byType(ColoredBox)));
    expect(box.color, variant.theme.colorScheme.surfaceContainerHigh);
    expect(tester.getSize(find.byKey(const Key('voll'))).width, variant.size.width);
    expect(tester.getSize(find.byKey(const Key('eng'))).width, lessThan(variant.size.width));
  });

  testVariants('DS-21: AppDivider Höhen', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppDivider(key: Key('std')),
        AppDivider(key: Key('xxl'), space: AppSpace.xxl),
        AppDivider.flush(key: Key('flush')),
        SizedBox(height: 40, child: AppDivider.vertical(key: Key('v'))),
      ]),
    );
    expect(tester.getSize(find.byKey(const Key('std'))).height, 16);
    expect(tester.getSize(find.byKey(const Key('xxl'))).height, AppSpacing.xxl);
    expect(tester.getSize(find.byKey(const Key('flush'))).height, 1);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });

  testVariants('DS-22: AppSection mit Trennlinie und Überschrift', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      ListView(children: const [
        AppSection(title: 'Teil', children: [Text('Inhalt')]),
        AppSection(divider: false, children: [Text('Ohne')]),
      ]),
    );
    expect(find.byType(Divider), findsOneWidget);
    expect(tester.widget<Text>(find.text('Teil')).style!.fontWeight, FontWeight.bold);
    expect(tester.getTopLeft(find.text('Teil')).dy, greaterThan(tester.getTopLeft(find.byType(Divider)).dy));
    expect(find.text('Ohne'), findsOneWidget);
  });
}
