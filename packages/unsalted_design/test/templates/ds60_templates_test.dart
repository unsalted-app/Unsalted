// test/templates/ds60_templates_test.dart
//
// DS-60 (Teil 1.3, D11): Templates nach Figma `Template/*` und den
// Tablet-Seiten — Seitenrand `space-l` bzw. ab `breakpoint-medium` `space-xl`,
// Inhalt samt Seitenrand höchstens `size-content-max` breit und mittig, Listen
// ohne Seitenrand, Detailseiten zweispaltig ab `breakpoint-large`; der obere
// Bereich von `DetailSplit` scrollt (Versionsvergleich am Handy lief über).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Zeigt [page] in einem Fenster der Breite [width].
Future<void> _pump(WidgetTester tester, double width, Widget page) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: page));
}

double _margin(double width) => width < AppBreakpoints.medium ? AppSpacing.l : AppSpacing.xl;

/// Linke Kante des Inhalts im Rahmen „Inhalt“.
double _left(double width) => (width - (width < AppSize.contentMax ? width : AppSize.contentMax)) / 2 + _margin(width);

void main() {
  test('DS-60: Seitenrand je Fenstergröße', () {
    expect(AppWindowSize.compact.pageMargin, AppSpace.l);
    for (final size in [AppWindowSize.medium, AppWindowSize.expanded, AppWindowSize.large]) {
      expect(size.pageMargin, AppSpace.xl);
    }
  });

  for (final width in [390.0, 600.0, 1024.0, 1600.0]) {
    testWidgets('DS-60: Formular im Rahmen „Inhalt“ (Breite $width)', (tester) async {
      await _pump(tester, width, const FormPageTemplate(title: 'Formular', body: FormSections(children: [AppTextField(label: 'Titel')])));
      final field = tester.getRect(find.byType(TextField));
      expect(field.left, _left(width));
      expect(field.right, width - _left(width), reason: 'mittig');
      expect(field.width, lessThanOrEqualTo(AppSize.contentMax - 2 * _margin(width)));
      expect(tester.getTopLeft(find.text('Titel')).dy, greaterThanOrEqualTo(AppSize.topBar + AppSpacing.l));
    });

    testWidgets('DS-60: Detailseite einspaltig im Rahmen „Inhalt“ (Breite $width)', (tester) async {
      await _pump(
        tester,
        width,
        const DetailPageTemplate(title: 'Detail', body: DetailSections(sections: [SizedBox(height: 40, child: Placeholder())])),
      );
      final box = tester.getRect(find.byType(Placeholder));
      expect(box.left, _left(width));
      expect(box.right, width - _left(width));
    });

    testWidgets('DS-60: Liste ohne Seitenrand (Breite $width)', (tester) async {
      await _pump(
        tester,
        width,
        const ListPageTemplate(title: 'Liste', body: AppItemList(children: [AppListItem(title: 'Eintrag')])),
      );
      final item = tester.getRect(find.byType(AppListItem));
      expect(item.left, 0);
      expect(item.width, width);
    });
  }

  testWidgets('DS-60: Detailseite zweispaltig ab breakpoint-large', (tester) async {
    Future<(Offset, Offset)> pump(double width) async {
      await _pump(
        tester,
        width,
        const DetailPageTemplate(
          title: 'Detail',
          body: DetailSections(sections: [Text('Haupt')], secondary: [Text('Neben')]),
        ),
      );
      return (tester.getTopLeft(find.text('Haupt')), tester.getTopLeft(find.text('Neben')));
    }

    var (main, side) = await pump(AppBreakpoints.large - 1);
    expect(side.dy, greaterThan(main.dy), reason: 'unter breakpoint-large eine Spalte');

    (main, side) = await pump(AppBreakpoints.large);
    expect(side.dy, main.dy);
    expect(main.dx, AppSpacing.xl);
    expect(side.dx, AppBreakpoints.large / 2 + AppSpacing.xl);

    const wide = 1600.0;
    (main, side) = await pump(wide);
    const start = (wide - 2 * AppSize.contentMax) / 2;
    expect(main.dx, start + AppSpacing.xl, reason: 'je Spalte höchstens size-content-max, beide mittig');
    expect(side.dx, start + AppSize.contentMax + AppSpacing.xl);
    expect(find.byType(ListView), findsNWidgets(2));
  });

  for (final width in [390.0, 1024.0]) {
    testWidgets('DS-60: DetailSplit – hoher oberer Bereich scrollt (Breite $width)', (tester) async {
      await _pump(
        tester,
        width,
        DetailPageTemplate(
          title: 'Vergleich',
          body: DetailSplit(
            primary: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(children: [for (var i = 0; i < 60; i++) Text('A $i')])),
              const AppDivider.vertical(),
              Expanded(child: Column(children: [for (var i = 0; i < 80; i++) Text('B $i')])),
            ]),
            secondary: const AppItemList(children: [AppListItem(title: 'Änderung')]),
            footer: [AppBottomActionBar(actions: [AppButton.primary(label: 'Übernehmen', onPressed: () {})])],
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'kein Überlauf');
      expect(find.text('B 79', skipOffstage: false), findsOneWidget);
      final upper = find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Scrollable));
      await tester.scrollUntilVisible(find.text('B 79'), 200, scrollable: upper);
      expect(tester.takeException(), isNull);
      final columnA = find.ancestor(of: find.text('A 0', skipOffstage: false), matching: find.byType(Column)).first;
      expect(tester.getRect(columnA).left, _left(width));
      final list = tester.getRect(find.byType(AppListItem));
      expect(list.width, width < AppSize.contentMax ? width : AppSize.contentMax);
      expect(list.center.dx, width / 2, reason: 'unterer Bereich mittig');
      expect(tester.getRect(find.byType(AppBottomActionBar)).width, width, reason: 'Fußzeile in voller Breite');
    });
  }
}
