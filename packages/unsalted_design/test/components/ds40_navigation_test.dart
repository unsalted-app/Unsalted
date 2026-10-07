// test/components/ds40_navigation_test.dart
//
// DS-40 bis DS-45 (Teil 1.2): AppTopBar, AppOverflowMenu, AppNavigationBar,
// AppBottomActionBar, AppKeyValueTable und AppCodeBlock.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-40: AppTopBar mit Aktionen und Suchbereich', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      AppPage(
        topBar: AppTopBar(
          title: 'Liste',
          actions: [AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: () {})],
          bottom: const AppSearchField(hint: 'Suchen …'),
        ),
        body: const SizedBox.shrink(),
      ),
      wrapInPage: false,
    );
    expect(find.widgetWithText(AppBar, 'Liste'), findsOneWidget);
    expect(find.byTooltip('Verlauf'), findsOneWidget);
    expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight + AppTopBar.bottomHeight);
    expect(find.descendant(of: find.byType(AppBar), matching: find.byType(TextField)), findsOneWidget);
  });

  testVariants('DS-41: AppOverflowMenu ruft die gewählte Aktion auf', (tester, variant) async {
    final calls = <String>[];
    await pumpVariant(
      tester,
      variant,
      Align(
        alignment: Alignment.topRight,
        child: AppOverflowMenu(entries: [
          AppMenuEntry(label: 'Eins', onSelected: () => calls.add('eins')),
          AppMenuEntry(label: 'Aus', enabled: false, onSelected: () => calls.add('aus')),
        ]),
      ),
    );
    expect(find.byType(PopupMenuButton<VoidCallback>), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aus'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
    await tester.tap(find.text('Eins'));
    await tester.pumpAndSettle();
    expect(calls, ['eins']);
  });

  testVariants('DS-42: AppNavigationBar', (tester, variant) async {
    final selected = <int>[];
    await pumpVariant(
      tester,
      variant,
      AppPage(
        body: const SizedBox.shrink(),
        bottomBar: AppNavigationBar(
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
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Zwei'));
    expect(selected, [1]);
  });

  testVariants('DS-43: AppBottomActionBar mit einer und zwei Aktionen', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        const Spacer(),
        AppBottomActionBar(actions: [AppButton.primary(label: 'Allein', onPressed: () {})]),
        AppBottomActionBar(actions: [
          AppButton.secondary(label: 'Links', onPressed: () {}),
          AppButton.primary(label: 'Rechts', onPressed: () {}),
        ]),
      ]),
    );
    final alone = tester.getSize(find.widgetWithText(ElevatedButton, 'Allein')).width;
    final left = tester.getSize(find.widgetWithText(OutlinedButton, 'Links')).width;
    final right = tester.getSize(find.widgetWithText(ElevatedButton, 'Rechts')).width;
    expect(left, right);
    expect(left, (variant.size.width - 3 * AppSpacing.l) / 2);
    expect(alone, lessThan(left), reason: 'eine Aktion steht in ihrer eigenen Breite');
  });

  testVariants('DS-44: AppKeyValueTable', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const AppKeyValueTable(
        headers: ['pro 100', 'pro Teil'],
        rows: [
          AppTableRow('Erste', ['1', '2']),
          AppTableRow('Zweite', ['3', '4']),
        ],
      ),
    );
    expect(find.byType(Table), findsOneWidget);
    expect(tester.widget<Text>(find.text('pro 100')).style!.fontWeight, FontWeight.bold);
    for (final text in ['Erste', 'Zweite', '1', '2', '3', '4', 'pro Teil']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.getSize(find.text('Erste')).width, lessThan(variant.size.width / 2));
    expect(tester.getTopLeft(find.text('1')).dx, closeTo(variant.size.width / 2 + AppSpacing.xs, 1));
  });

  testVariants('DS-45: AppCodeBlock auswählbar und scrollend', (tester, variant) async {
    await pumpVariant(tester, variant, AppCodeBlock('{"a": 1}\n' * 200));
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
