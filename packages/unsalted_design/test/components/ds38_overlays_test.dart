// test/components/ds38_overlays_test.dart
//
// DS-38 und DS-39 (Teil 1.2): Meldungen über AppMessenger und die Dialoge.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

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
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    messenger.showWithAction(
        message: 'Zwei', actionLabel: 'Rückgängig', onAction: () {}, duration: const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Eins'), findsNothing);
    expect(find.text('Zwei'), findsOneWidget);
    first.close();
    await tester.pumpAndSettle();
    expect(find.text('Zwei'), findsOneWidget, reason: 'close() auf eine geschlossene Meldung wirkt nicht');

    showAppMessage(page, 'Hinweis');
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Hinweis'), findsOneWidget);
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
    await tester.tap(find.widgetWithText(TextButton, 'Verwerfen'));
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
    expect(box.height, 400);
    expect(box.width, lessThanOrEqualTo(400), reason: 'auf dem Handy begrenzt der Dialog die Breite');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await free, 'ok');
  });
}
