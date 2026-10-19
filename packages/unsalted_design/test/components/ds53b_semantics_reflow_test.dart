// test/components/ds53b_semantics_reflow_test.dart
//
// DS-53b, DS-59b und DS-32c (Teil 1.3, D13a): Auswahlziele tragen ihre
// Tippaktion auch in der Semantik (Marke als Ziel der Fassungsleiste, Ziel der
// Navigation); ein langer Text bricht in der Marke um statt überzulaufen; der
// Hinweis stellt seine Aktion rechtsbündig unter den Text, sobald dem Text
// daneben weniger als `reflow-label-min` bliebe (28.10.11).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-53b: Marke als Ziel — Tippen über die Semantik', (tester, variant) async {
    final taps = <String>[];
    await pumpVariant(
      tester,
      variant,
      Row(children: [
        AppMark(label: 'V2', state: AppMarkState.fixed, selected: true, onTap: () => taps.add('V2')),
        AppMark(label: 'V1', state: AppMarkState.fixed, onTap: () => taps.add('V1')),
      ]),
    );
    final handle = tester.ensureSemantics();
    expect(tester.getSemantics(find.byType(AppMark).last), isSemantics(label: 'V1', isButton: true, hasTapAction: true));
    tester.semantics.tap(find.semantics.byLabel('V1'));
    await tester.pump();
    expect(taps, ['V1']);
    handle.dispose();
  });

  testVariants('DS-53b: langer Text bricht in der Marke um', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: AppSize.target,
          child: AppMark(label: 'V12 · mit sehr langem Namen', state: AppMarkState.provisional, onTap: _noop),
        ),
      ),
    );
    expect(tester.takeException(), isNull, reason: 'kein Überlauf');
    expect(tester.getSize(find.text('V12 · mit sehr langem Namen')).height,
        greaterThan(AppTypography.labelSmall.fontSize! * AppTypography.labelSmall.height!),
        reason: 'mehrzeilig');
  });

  testVariants('DS-59b: Ziel der Navigation — Tippen über die Semantik', (tester, variant) async {
    final selected = <int>[];
    await pumpVariant(
      tester,
      variant,
      AppPage(
        body: const SizedBox.shrink(),
        navigation: AppNavigationBar(
          selectedIndex: 0,
          onSelected: selected.add,
          destinations: const [
            AppNavigationDestination(icon: AppIcons.book, label: 'Eins'),
            AppNavigationDestination(icon: AppIcons.settings, label: 'Zwei'),
          ],
        ),
      ),
      wrapInPage: false,
    );
    final handle = tester.ensureSemantics();
    tester.semantics.tap(find.semantics.byLabel('Zwei'));
    await tester.pump();
    expect(selected, [1]);
    handle.dispose();
  });

  for (final scale in [1.0, 2.0]) {
    testVariants('DS-32c: Hinweis mit Aktion bei Textgröße ${scale * 100} %', (tester, variant) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpVariant(
        tester,
        variant,
        Align(
          alignment: Alignment.topCenter,
          child: AppNotice('Hinweis mit Aktion.', action: AppButton.tertiary(label: 'Kopieren', onPressed: () {})),
        ),
      );
      expect(tester.takeException(), isNull);
      final text = tester.getRect(find.text('Hinweis mit Aktion.'));
      final action = tester.getRect(find.byType(AppButton));
      final notice = tester.getRect(find.byType(AppNotice));
      // Regel über die gemessene Breite (die Testschrift ist breiter als Atkinson).
      final besideText = notice.width - 2 * AppSpacing.m - AppSize.iconSmall - 2 * AppSpacing.m - action.width;
      final stacked = besideText < AppReflowMetric.labelMin.at(scale);
      expect(action.right, closeTo(notice.right - AppSpacing.m, 1), reason: 'rechtsbündig');
      if (stacked) {
        expect(action.top, greaterThanOrEqualTo(text.bottom), reason: 'Aktion unter dem Text');
      } else {
        expect(action.top, closeTo(text.top, AppSpacing.m), reason: 'nebeneinander');
        expect(action.left, greaterThanOrEqualTo(text.right));
      }
      if (scale == 1 && variant.size.width >= AppBreakpoints.medium) expect(stacked, isFalse);
      if (scale == 2 && variant.size.width < AppBreakpoints.medium) expect(stacked, isTrue);
    });
  }

  testVariants('DS-32c: schmaler Hinweis stellt die Aktion auch bei 100 % unter den Text', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: AppReflow.labelMin + AppSize.target * 2,
          child: AppNotice('Hinweis mit Aktion.', action: AppButton.tertiary(label: 'Kopieren', onPressed: () {})),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(AppButton)).top,
        greaterThanOrEqualTo(tester.getRect(find.text('Hinweis mit Aktion.')).bottom));
  });
}

void _noop() {}
