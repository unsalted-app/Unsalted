// test/layout/ds10_app_stack_test.dart
//
// DS-10 (Teil 1.2): AppGap, AppStack und AppPadding setzen Abstände nur aus
// Token-Stufen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  test('DS-10: AppSpace trägt die Werte der Abstands-Tokens', () {
    expect(AppSpace.values.map((s) => s.value), AppSpacing.byFigmaName.values);
  });

  testVariants('DS-10: AppStack setzt den Abstand nur zwischen die Kinder', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topLeft,
        child: AppStack(gap: AppSpace.l, children: [
          SizedBox(key: Key('a'), width: 10, height: 10),
          SizedBox(key: Key('b'), width: 10, height: 10),
        ]),
      ),
    );
    expect(tester.getTopLeft(find.byKey(const Key('b'))).dy - tester.getBottomLeft(find.byKey(const Key('a'))).dy,
        AppSpacing.l);
    expect(tester.getSize(find.byType(AppStack)).height, 10 + AppSpacing.l + 10);
  });

  testVariants('DS-10: waagrechter AppStack und AppGap', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topLeft,
        child: AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
          SizedBox(key: Key('a'), width: 10, height: 10),
          SizedBox(key: Key('b'), width: 10, height: 10),
        ]),
      ),
    );
    expect(tester.getTopLeft(find.byKey(const Key('b'))).dx, 10 + AppSpacing.s);
    expect(tester.getSize(find.byType(AppGap)), const Size(AppSpacing.s, AppSpacing.s));
  });

  testVariants('DS-10: AppPadding je Seite', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topLeft,
        child: AppPadding.only(
          left: AppSpace.l,
          top: AppSpace.m,
          right: AppSpace.l,
          bottom: AppSpace.xs,
          child: SizedBox(key: Key('c'), width: 10, height: 10),
        ),
      ),
    );
    expect(tester.getTopLeft(find.byKey(const Key('c'))), const Offset(AppSpacing.l, AppSpacing.m));
    expect(tester.getSize(find.byType(AppPadding)), const Size(10 + 2 * AppSpacing.l, 10 + AppSpacing.m + AppSpacing.xs));
  });
}
