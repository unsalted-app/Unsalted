// test/components/ds32_feedback_test.dart
//
// DS-32 bis DS-37 (Teil 1.2): AppNotice, AppEmptyState, AppErrorState,
// AppLoading, AppProgressBar und AppSkeleton.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-32: AppNotice je Art mit Symbol, Farben aus dem Theme', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        const AppNotice('Fehler', key: Key('e'), kind: AppNoticeKind.error),
        const AppNotice('Warnung', key: Key('w'), kind: AppNoticeKind.warning),
        AppNotice('Info', action: AppButton.tertiary(label: 'Kopieren', onPressed: () {})),
      ]),
    );
    final scheme = variant.theme.colorScheme;
    Color background(String key) => (tester
            .widget<DecoratedBox>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(DecoratedBox)).first)
            .decoration as BoxDecoration)
        .color!;
    expect(background('e'), scheme.errorContainer);
    expect(background('w'), scheme.tertiaryContainer);
    expect(find.byIcon(AppIcons.error), findsOneWidget);
    expect(find.byIcon(AppIcons.warning), findsOneWidget);
    expect(find.byIcon(AppIcons.info), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Kopieren'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('w')), matching: find.text('Warnung')), findsOneWidget);
  });

  testVariants('DS-33: AppEmptyState mit und ohne Symbol und Aktion', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        Expanded(
          child: AppEmptyState(
            icon: AppIcons.book,
            message: 'Noch nichts da.',
            action: AppButton.primary(label: 'Anlegen', onPressed: () => taps++),
          ),
        ),
        const Expanded(child: AppEmptyState(message: 'Keine Treffer.')),
      ]),
    );
    expect(find.byIcon(AppIcons.book), findsOneWidget);
    expect(tester.getSize(find.byIcon(AppIcons.book)), const Size(48, 48));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Anlegen'));
    expect(taps, 1);
    expect(find.text('Keine Treffer.'), findsOneWidget);
  });

  testVariants('DS-34: AppErrorState mit und ohne „Erneut versuchen“', (tester, variant) async {
    var retries = 0;
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        Expanded(child: AppErrorState(message: 'Kaputt', retryLabel: 'Erneut versuchen', onRetry: () => retries++)),
        const Expanded(child: AppErrorState(message: 'Nur Text')),
      ]),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Erneut versuchen'));
    expect(retries, 1);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testVariants('DS-35/36: AppLoading und AppProgressBar', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [AppProgressBar(), Expanded(child: AppLoading())]),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testVariants('DS-37: AppSkeleton pulsiert, bei „Bewegung reduzieren“ nicht', (tester, variant) async {
    await pumpVariant(tester, variant, const SingleChildScrollView(child: AppSkeleton(semanticLabel: 'Wird geladen', count: 3)));
    expect(find.bySemanticsLabel('Wird geladen'), findsOneWidget);
    final pulse = find.descendant(of: find.byType(AppSkeleton), matching: find.byType(FadeTransition));
    final first = tester.widget<FadeTransition>(pulse).opacity.value;
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.widget<FadeTransition>(pulse).opacity.value, isNot(first));

    await tester.pumpWidget(MaterialApp(
      theme: variant.theme,
      home: const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(body: AppSkeleton(semanticLabel: 'Wird geladen', count: 1)),
      ),
    ));
    expect(tester.widget<FadeTransition>(pulse).opacity.value, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
