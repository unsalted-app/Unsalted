// test/components/ds70_mark_frame_notice_test.dart
//
// DS-70 bis DS-72 (Teil 1.4 M00b, Figma `Mark` `114:68`/`107:48`, `Frame`
// `135:55`/`135:47`, `Feedback/Notice` Instanz `42:2034`): gemessen wird das,
// was man sieht.
// DS-70: Der gezeichnete Kasten der Marke ist mindestens `size-mark` hoch, der
// Inhalt darin senkrecht mittig, waagrecht `space-s` + `stroke-frame` (die
// Kontur zählt zum Innenabstand); das Siegel steht mittig zum Text (auch bei
// großer Schrift); die belegte Höhe ist die des Kastens (wie vorher). Als Ziel
// der Fassungsleiste wird der Kasten nicht gestreckt.
// DS-71: Im Rahmen stehen Marke und Zustandswort senkrecht mittig; der
// Innenabstand ist `space-m`/`space-l` + `stroke-frame` (beide Zustände).
// DS-72: Neben dem Text steht die Beschriftung der Hinweis-Aktion auf Höhe der
// ersten Textzeile; das Tippziel bleibt mindestens `size-target` und ragt
// höchstens in den Innenabstand. Ohne Aktion bleibt der Hinweis unverändert.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

/// Gezeichneter Kasten unter [finder]: Strichlinie oder Kontur.
Finder _box(Finder finder) => find
    .descendant(
      of: finder,
      matching: find.byWidgetPredicate(
        (w) =>
            (w is CustomPaint && w.painter.runtimeType.toString() == 'DashedPainter') ||
            (w is DecoratedBox && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).border != null),
      ),
    )
    .first;

void _scaleText(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  for (final scale in [1.0, 2.0]) {
    testVariants('DS-70: Kasten der Marke mindestens size-mark, Inhalt mittig (${scale * 100} %)', (tester, variant) async {
      _scaleText(tester, scale);
      await pumpVariant(
        tester,
        variant,
        const Align(
          alignment: Alignment.topLeft,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppMark(key: Key('p'), label: 'V3', state: AppMarkState.provisional),
            AppMark(key: Key('f'), label: 'V2', state: AppMarkState.fixed, seal: true),
            AppMark(key: Key('h'), label: 'V1', state: AppMarkState.highlighted),
          ]),
        ),
      );
      for (final (key, label) in [('p', 'V3'), ('f', 'V2'), ('h', 'V1')]) {
        final mark = find.byKey(Key(key));
        final box = tester.getRect(_box(mark));
        final text = tester.getRect(find.text(label));
        expect(box.height, math.max(AppSize.mark, text.height), reason: '$label: der Kasten selbst');
        expect(tester.getSize(mark).height, box.height, reason: '$label: belegte Höhe = Kasten');
        expect(text.center.dy, closeTo(box.center.dy, 0.01), reason: '$label: Inhalt senkrecht mittig');
        final seal = find.descendant(of: mark, matching: find.byIcon(AppIcons.lock));
        if (key == 'f') {
          expect(tester.getRect(seal).center.dy, closeTo(text.center.dy, 0.01), reason: 'Siegel mittig zum Text');
        }
        final first = key == 'f' ? tester.getRect(seal) : text;
        expect(first.left - box.left, AppSpacing.s + AppStroke.frame, reason: '$label: links space-s + stroke-frame');
        expect(box.right - text.right, AppSpacing.s + AppStroke.frame, reason: '$label: rechts space-s + stroke-frame');
      }
      expect(tester.takeException(), isNull);
    });
  }

  testVariants('DS-70: Marke als Ziel — Kasten size-mark, nicht gestreckt, mittig im Ziel', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Align(
        alignment: Alignment.topLeft,
        child: AppMark(key: const Key('t'), label: 'V1', state: AppMarkState.fixed, onTap: () {}),
      ),
    );
    final target = tester.getRect(find.byKey(const Key('t')));
    final box = tester.getRect(_box(find.byKey(const Key('t'))));
    expect(box.height, AppSize.mark);
    expect(box.width, lessThan(AppSize.target), reason: 'kurze Marke nicht auf die Zielbreite gestreckt');
    expect(box.center.dx, closeTo(target.center.dx, 0.01));
  });

  testVariants('DS-71: Rahmen — Kopfzeile mittig, Innenabstand mit Kontur', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 320,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AppFrame.fixed(
              key: Key('f'),
              mark: AppMark(label: 'V3', state: AppMarkState.fixed, seal: true),
              caption: 'Eingefroren',
              child: SizedBox(key: Key('fc'), height: 40),
            ),
            AppFrame.provisional(key: Key('p'), child: SizedBox(key: Key('pc'), height: 40)),
          ]),
        ),
      ),
    );
    final mark = tester.getRect(_box(find.byType(AppMark)));
    final caption = tester.getRect(find.text('Eingefroren'));
    expect(mark.height, AppSize.mark);
    expect(caption.center.dy, closeTo(mark.center.dy, 0.01), reason: 'Zustandswort mittig zur Marke');

    const inset = (AppSpacing.m + AppStroke.frame, AppSpacing.l + AppStroke.frame);
    for (final (frameKey, childKey) in [('f', 'fc'), ('p', 'pc')]) {
      final frame = tester.getRect(find.byKey(Key(frameKey)));
      final child = tester.getRect(find.byKey(Key(childKey)));
      expect(child.left - frame.left, inset.$2, reason: '$frameKey: links space-l + stroke-frame');
      expect(frame.right - child.right, inset.$2, reason: '$frameKey: rechts');
      expect(frame.bottom - child.bottom, inset.$1, reason: '$frameKey: unten space-m + stroke-frame');
    }
    final fixed = tester.getRect(find.byKey(const Key('f')));
    expect(mark.top - fixed.top, inset.$1, reason: 'oben space-m + stroke-frame (Kopfzeile)');
    expect(tester.getRect(find.byKey(const Key('fc'))).top - mark.bottom, AppSpacing.s);
    final provisional = tester.getRect(find.byKey(const Key('p')));
    expect(tester.getRect(find.byKey(const Key('pc'))).top - provisional.top, inset.$1, reason: 'oben ohne Kopfzeile');
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('DS-72: Beschriftung der Hinweis-Aktion auf Höhe der ersten Zeile (${scale * 100} %)', (tester) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      _scaleText(tester, scale);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: AppNotice('Hinweis mit Aktion.', action: AppButton.tertiary(label: 'Kopieren', onPressed: () {})),
          ),
        ),
      ));
      final notice = tester.getRect(find.byType(AppNotice));
      final text = tester.getRect(find.text('Hinweis mit Aktion.'));
      final label = tester.getRect(find.text('Kopieren'));
      final target = tester.getRect(find.byType(TextButton));
      expect(target.left, greaterThan(text.right), reason: 'nebeneinander');
      expect(text.top - notice.top, AppSpacing.m, reason: 'Text wie bisher space-m unter der Kante');
      expect(label.top, text.top, reason: 'Beschriftung auf Höhe der ersten Zeile');
      expect(label.height, text.height, reason: 'eine Zeile wie die erste Textzeile');
      expect(target.height, greaterThanOrEqualTo(AppSize.target));
      expect(target.top, greaterThanOrEqualTo(notice.top), reason: 'Tippziel ragt höchstens in den Innenabstand');
      expect(tester.takeException(), isNull);
    });
  }

  testVariants('DS-72: Hinweis ohne Aktion unverändert', (tester, variant) async {
    await pumpVariant(tester, variant, const Align(alignment: Alignment.topCenter, child: AppNotice('Nur ein Hinweis.')));
    final notice = tester.getRect(find.byType(AppNotice));
    expect(tester.getRect(find.text('Nur ein Hinweis.')).top - notice.top, AppSpacing.m);
    expect(tester.getRect(find.byIcon(AppIcons.info)).top - notice.top, AppSpacing.m + AppSpacing.xxs);
  });
}
