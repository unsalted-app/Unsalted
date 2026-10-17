// test/components/ds59_navigation_test.dart
//
// DS-59 (Teil 1.3, D10): Hauptnavigation nach der NavigationBar-Karte —
// unter `breakpoint-medium` unten, ab `breakpoint-medium` als seitliche Leiste
// (`size-nav-rail`); Auswahl als Balken `stroke-rule` in `line-strong`, nicht
// als Pille; Systemleisten folgen der Textgröße nicht. Dazu Kopfleiste,
// untere Aktionsleiste, Deklarationstabelle und Codeblock (DS-40b, 43b, 44b,
// 45b).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

AppColorTokens _colors(Variant variant) =>
    variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;

AppPage _page(List<int> selected) => AppPage(
      body: const Center(child: Text('Inhalt')),
      navigation: AppNavigationBar(
        selectedIndex: 1,
        onSelected: selected.add,
        destinations: const [
          AppNavigationDestination(icon: AppIcons.book, label: 'Eins'),
          AppNavigationDestination(icon: AppIcons.restaurant, label: 'Zwei'),
          AppNavigationDestination(icon: AppIcons.settings, label: 'Drei'),
        ],
      ),
    );

void main() {
  testVariants('DS-59: Navigation unten unter 600, links ab 600', (tester, variant) async {
    final selected = <int>[];
    await pumpVariant(tester, variant, _page(selected), wrapInPage: false);
    final c = _colors(variant);
    final bar = find.byType(AppNavigationBar);
    final rect = tester.getRect(bar);
    if (variant.size.width < AppBreakpoints.medium) {
      expect(rect.bottom, variant.size.height, reason: 'unten');
      expect(rect.width, variant.size.width);
      expect(rect.height, greaterThanOrEqualTo(AppSize.navBar));
    } else {
      expect(rect.left, 0, reason: 'links');
      expect(rect.width, AppSize.navRail);
      expect(tester.getTopLeft(find.text('Inhalt')).dx, greaterThan(AppSize.navRail));
    }
    // Auswahl: genau ein Balken in line-strong, Breite size-target, Höhe stroke-rule.
    final bars = tester
        .widgetList<ColoredBox>(find.descendant(of: bar, matching: find.byType(ColoredBox)))
        .where((b) => b.color == c.lineStrong);
    expect(bars, hasLength(1));
    final barBox = find.descendant(of: bar, matching: find.byWidget(bars.single));
    expect(tester.getSize(barBox), const Size(AppSize.target, AppStroke.rule));
    expect(tester.widget<Text>(find.text('Zwei')).style!.color, c.textPrimary);
    expect(tester.widget<Text>(find.text('Eins')).style!.color, c.textSecondary);
    await tester.tap(find.text('Drei'));
    expect(selected, [2]);
    expect(find.byType(NavigationBar), findsNothing, reason: 'eigene Komponente statt Material-Pille');
  });

  testVariants('DS-59: Systemleisten folgen der Textgröße nicht', (tester, variant) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpVariant(
      tester,
      variant,
      AppPage(
        topBar: const AppTopBar(title: 'Titel'),
        body: const Text('Inhalt'),
        navigation: AppNavigationBar(selectedIndex: 0, onSelected: (_) {}, destinations: const [
          AppNavigationDestination(icon: AppIcons.book, label: 'Eins'),
          AppNavigationDestination(icon: AppIcons.settings, label: 'Zwei'),
        ]),
      ),
      wrapInPage: false,
    );
    expect(MediaQuery.textScalerOf(tester.element(find.text('Eins'))).scale(10), 10);
    expect(MediaQuery.textScalerOf(tester.element(find.text('Titel'))).scale(10), 10);
    expect(MediaQuery.textScalerOf(tester.element(find.text('Inhalt'))).scale(10), 20, reason: 'Inhalt wächst');
  });

  testVariants('DS-59: Ziel mit Semantik und Tooltip', (tester, variant) async {
    final handle = tester.ensureSemantics();
    await pumpVariant(tester, variant, _page([]), wrapInPage: false);
    expect(tester.getSemantics(find.ancestor(of: find.text('Zwei'), matching: find.byType(Semantics)).first),
        isSemantics(label: 'Zwei', isButton: true, isSelected: true));
    expect(find.byTooltip('Eins'), findsOneWidget);
    handle.dispose();
  });

  testVariants('DS-40b: Kopfleiste — Suchbereich aus Tokens', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Scaffold(appBar: AppTopBar(title: 'Liste', bottom: AppSearchField(hint: 'Suchen …'))),
      wrapInPage: false,
    );
    expect(AppTopBar.bottomHeight, AppSpacing.s + AppSize.control + AppSpacing.m);
    expect(tester.getSize(find.byType(AppBar)).height, AppSize.topBar + AppTopBar.bottomHeight);
    final field = tester.getRect(find.byType(TextField));
    expect(field.left, AppSpacing.l);
  });

  testVariants('DS-43b: Aktionsleiste mit Haarlinie oben', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      AppBottomActionBar(actions: [AppButton.primary(label: 'Speichern', onPressed: () {})]),
    );
    final c = _colors(variant);
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: find.byType(AppBottomActionBar), matching: find.byType(DecoratedBox)).first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, c.surfacePage);
    expect((decoration.border! as Border).top, BorderSide(color: c.lineHairline, width: AppStroke.hairline));
  });

  testVariants('DS-44b: Deklaration — Tintenlinie, eingerückte und hervorgehobene Zeilen', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const AppKeyValueTable(headers: ['A'], rows: [
        AppTableRow('Haupt', ['12'], strong: true),
        AppTableRow('Unter', ['3'], sub: true),
      ]),
    );
    final c = _colors(variant);
    final table = tester.widget<Table>(find.byType(Table));
    final header = table.children.first.decoration! as BoxDecoration;
    expect((header.border! as Border).bottom, BorderSide(color: c.lineStrong, width: AppStroke.frame));
    final row = table.children[1].decoration! as BoxDecoration;
    expect((row.border! as Border).bottom, BorderSide(color: c.lineHairline, width: AppStroke.hairline));
    expect(tester.widget<Text>(find.text('A')).style!.color, c.textSecondary);
    expect(tester.widget<Text>(find.text('12')).style!.fontWeight, AppTypography.dataStrong.fontWeight);
    expect(tester.widget<Text>(find.text('12')).style!.fontFeatures, AppTypography.data.fontFeatures);
    expect(tester.widget<Text>(find.text('Unter')).style!.color, c.textSecondary);
    expect(
      tester.getTopLeft(find.text('Unter')).dx - tester.getTopLeft(find.text('Haupt')).dx,
      AppSpacing.l,
      reason: 'davon-Zeilen eingerückt',
    );
  });

  testVariants('DS-45b: Codeblock auf surface-sunken im Stil code', (tester, variant) async {
    await pumpVariant(tester, variant, const SizedBox(height: 200, child: AppCodeBlock('{"a": 1}')));
    final c = _colors(variant);
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: find.byType(AppCodeBlock), matching: find.byType(DecoratedBox)).first,
    );
    expect((box.decoration as BoxDecoration).color, c.surfaceSunken);
    expect(tester.widget<SelectableText>(find.byType(SelectableText)).style!.fontFamily,
        AppTypography.code.fontFamily);
  });
}
