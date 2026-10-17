// test/components/ds38_overlays_test.dart
//
// DS-38 und DS-39 (Teil 1.2): Meldungen über AppMessenger und die Dialoge.
// DS-38b (Teil 1.3, D09b): Restzeitlinie der Meldung mit Aktion.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

/// Lässt eine Meldung erscheinen. Nicht `pumpAndSettle`: Die Restzeitlinie
/// läuft, bis die Meldung schließt (D09b).
Future<void> _appear(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Restzeitlinie der sichtbaren Meldung.
Finder get _line => find.descendant(of: find.byType(SnackBar), matching: find.byType(FractionallySizedBox));

void main() {
  testVariants('DS-38: Meldung mit Aktion schließt nach der Frist von selbst', (tester, variant) async {
    var undos = 0;
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    AppMessenger.of(page).showWithAction(
      message: 'Gelöscht',
      actionLabel: 'Rückgängig',
      onAction: () => undos++,
      duration: const Duration(seconds: 5),
    );
    await _appear(tester);
    expect(find.text('Gelöscht'), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
    expect(undos, 1);
    await tester.pumpAndSettle();

    AppMessenger.of(page).showWithAction(
      message: 'Wieder',
      actionLabel: 'Rückgängig',
      onAction: () {},
      duration: const Duration(seconds: 5),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Wieder'), findsNothing);
  });

  testVariants('DS-38: Griff schließt nur offene Meldungen; neue ersetzt sichtbare', (tester, variant) async {
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    final messenger = AppMessenger.of(page);
    final first = messenger.showWithAction(
        message: 'Eins', actionLabel: 'Rückgängig', onAction: () {}, duration: const Duration(seconds: 5));
    await _appear(tester);
    messenger.showWithAction(
        message: 'Zwei', actionLabel: 'Rückgängig', onAction: () {}, duration: const Duration(seconds: 5));
    await _appear(tester);
    expect(find.text('Eins'), findsNothing);
    expect(find.text('Zwei'), findsOneWidget);
    first.close();
    await _appear(tester);
    expect(find.text('Zwei'), findsOneWidget, reason: 'close() auf eine geschlossene Meldung wirkt nicht');

    showAppMessage(page, 'Hinweis');
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Hinweis'), findsOneWidget);
  });

  testVariants('DS-38b: Restzeitlinie läuft ab dem Erscheinen in der Frist ab', (tester, variant) async {
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    AppMessenger.of(page).showWithAction(
        message: 'Gelöscht', actionLabel: 'Rückgängig', onAction: () {}, duration: const Duration(seconds: 4));
    await _appear(tester);
    final c = variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
    final snackbar = tester.getRect(find.descendant(of: find.byType(SnackBar), matching: find.byType(Material)).first);
    expect(snackbar.width, lessThanOrEqualTo(AppSize.dialog));
    expect(tester.getRect(_line).bottom, closeTo(snackbar.bottom, 1), reason: 'am unteren Rand');
    expect(tester.getRect(_line).left, closeTo(snackbar.left, 1));
    expect(tester.getSize(_line).height, AppStroke.rule);
    final box = tester.widget<ColoredBox>(find.descendant(of: _line, matching: find.byType(ColoredBox)));
    expect(box.color, c.actionInverse);
    expect(tester.widget<FractionallySizedBox>(_line).widthFactor, closeTo(1, 0.15), reason: 'eben erschienen');
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<FractionallySizedBox>(_line).widthFactor, closeTo(0.5, 0.15), reason: 'halbe Frist');
    expect(tester.getRect(find.text('Gelöscht')).left - snackbar.left, AppSpacing.l);
    expect(tester.getSize(find.byType(SnackBarAction)).height, greaterThanOrEqualTo(AppSize.target));
    expect(tester.widget<Text>(find.text('Rückgängig')).style, isNull, reason: 'Stil aus dem Thema');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Gelöscht'), findsNothing, reason: 'Frist und Ablauf unverändert');
  });

  testVariants('DS-38b: bei „Bewegung reduzieren“ steht die Linie still', (tester, variant) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    AppMessenger.of(page).showWithAction(
        message: 'Gelöscht', actionLabel: 'Rückgängig', onAction: () {}, duration: const Duration(seconds: 5));
    await _appear(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<FractionallySizedBox>(_line).widthFactor, 1);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Gelöscht'), findsNothing, reason: 'die Frist läuft trotzdem');
  });

  for (final scale in [1.0, 2.0]) {
    testVariants('DS-38b: Aktion bei Textgröße ${scale * 100} % neben oder unter dem Text', (tester, variant) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      late BuildContext page;
      await pumpVariant(tester, variant, Builder(builder: (context) {
        page = context;
        return const SizedBox.shrink();
      }));
      AppMessenger.of(page).showWithAction(
          message: '„Eintrag 3“ gelöscht', actionLabel: 'Rückgängig', onAction: () {}, duration: const Duration(seconds: 5));
      await _appear(tester);
      expect(tester.takeException(), isNull);
      final text = tester.getRect(find.text('„Eintrag 3“ gelöscht'));
      final action = tester.getRect(find.byType(SnackBarAction));
      final snackbar = tester.getRect(find.descendant(of: find.byType(SnackBar), matching: find.byType(Material)).first);
      // Regel: Bliebe dem Text neben der Aktion weniger als reflow-label-min,
      // steht die Aktion darunter. (Die Testschrift ist breiter als Atkinson,
      // deshalb hier über die Regel statt fest je Textgröße.)
      final besideText = snackbar.width - AppSpacing.l - AppSpacing.xs - AppSpacing.m - action.width;
      final stacked = besideText < AppReflowMetric.labelMin.at(scale);
      if (scale == 2 && variant.size.width < AppBreakpoints.medium) expect(stacked, isTrue);
      if (stacked) {
        expect(action.top, greaterThanOrEqualTo(text.bottom), reason: 'Aktion unter dem Text (28.10.11)');
        expect(action.right, closeTo(snackbar.right - AppSpacing.xs, 1), reason: 'rechtsbündig');
      } else {
        expect(action.left, greaterThan(text.right), reason: 'nebeneinander');
        expect(action.center.dy, closeTo(text.center.dy, 1));
      }
    });
  }

  testVariants('DS-38b: kurze Aktion steht neben dem Text', (tester, variant) async {
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    AppMessenger.of(page)
        .showWithAction(message: 'Weg', actionLabel: 'Ja', onAction: () {}, duration: const Duration(seconds: 5));
    await _appear(tester);
    final text = tester.getRect(find.text('Weg'));
    final action = tester.getRect(find.byType(SnackBarAction));
    expect(action.left, greaterThan(text.right));
    expect(action.center.dy, closeTo(text.center.dy, 1));
  });

  testVariants('DS-39: Rückfrage liefert true nur bei Bestätigung', (tester, variant) async {
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    Future<bool> ask() => showAppConfirmDialog(page,
        title: 'Verwerfen?', message: 'Nicht gespeichert.', confirmLabel: 'Verwerfen', cancelLabel: 'Abbrechen');

    var answer = ask();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Verwerfen'));
    await tester.pumpAndSettle();
    expect(await answer, isTrue);

    answer = ask();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Abbrechen'));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);

    answer = ask();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(await answer, isFalse, reason: 'Schließen ohne Wahl = nein');
  });

  testVariants('DS-39: Auswahl, leere Auswahl, freier Dialog', (tester, variant) async {
    late BuildContext page;
    await pumpVariant(tester, variant, Builder(builder: (context) {
      page = context;
      return const SizedBox.shrink();
    }));
    final choice = showAppChoiceDialog<int>(page,
        title: 'Welche?', options: const [AppSelectItem(1, 'V1'), AppSelectItem(2, 'V2')], emptyMessage: 'Keine.');
    await tester.pumpAndSettle();
    await tester.tap(find.text('V2'));
    await tester.pumpAndSettle();
    expect(await choice, 2);

    final empty = showAppChoiceDialog<int>(page, title: 'Welche?', options: const [], emptyMessage: 'Keine.');
    await tester.pumpAndSettle();
    expect(find.text('Keine.'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(await empty, isNull);

    final free = showAppDialog<String>(
      page,
      (context) => AppDialog(
        title: 'Frei',
        fixedContentSize: true,
        content: const Text('Inhalt'),
        actions: [AppButton.tertiary(label: 'OK', onPressed: () => Navigator.of(context).pop('ok'))],
      ),
    );
    await tester.pumpAndSettle();
    final box = tester.getSize(find.ancestor(of: find.text('Inhalt'), matching: find.byType(SizedBox)).first);
    expect(box.height, AppSize.dialog);
    expect(box.width, lessThanOrEqualTo(AppSize.dialog), reason: 'auf dem Handy begrenzt der Dialog die Breite');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await free, 'ok');
  });

  testVariants('DS-39b: Rückfrage mit primärem Verb (Teil 1.3)', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Builder(builder: (context) {
        return AppButton.secondary(
          label: 'Öffnen',
          onPressed: () => showAppConfirmDialog(context,
              title: 'Verwerfen?', message: 'Text', confirmLabel: 'Verwerfen', cancelLabel: 'Abbrechen'),
        );
      }),
    );
    await tester.tap(find.text('Öffnen'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Verwerfen'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Abbrechen'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
  });
}
