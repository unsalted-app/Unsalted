// test/templates/ds63_list_detail_template_test.dart
//
// DS-63 (Teil 1.4 T01, Figma Tablet „01+04“/„09+10“, Nachtrag N3):
// `ListDetailTemplate` — unter `breakpoint-expanded` nur die Liste; ab
// `breakpoint-expanded` die Liste in `size-list-pane`, rechts davon das Detail
// über den Rest, mit Haarlinie links (`line-hairline`) auf `surface-page`;
// ohne Detail nur das Punktraster (`line-dot`), ohne Text. Eine Meldung aus
// Liste oder Detail erscheint einmal (gemeinsame Seite). Bei 200 % Schrift
// kein Überlauf.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

AppColorTokens _colors(Variant variant) =>
    variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;

const _list = ListPageTemplate(title: 'Liste', body: AppItemList(children: [AppListItem(title: 'Eintrag')]));

const _detail = DetailPageTemplate(title: 'Detail', body: DetailSections(sections: [Text('Inhalt')]));

final _dots = find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == 'DotPatternPainter');

/// Fläche des Detailbereichs: `surface-page` mit Haarlinie links.
Finder _pane(AppColorTokens c) => find.byWidgetPredicate((w) {
      if (w is! DecoratedBox) return false;
      final decoration = w.decoration;
      return decoration is BoxDecoration &&
          decoration.color == c.surfacePage &&
          decoration.border is Border &&
          (decoration.border! as Border).left.color == c.lineHairline;
    });

/// Zeigt [page] in einem Fenster der Breite [width], optional mit
/// Schriftgröße [scale].
Future<void> _pump(WidgetTester tester, double width, Widget page, {double scale = 1}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    builder: (context, child) =>
        MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
    home: page,
  ));
}

void main() {
  testVariants('DS-63: ohne Auswahl Liste und Punktraster ohne Text', (tester, variant) async {
    await pumpVariant(tester, variant, const ListDetailTemplate(list: _list), wrapInPage: false);
    final c = _colors(variant);
    final width = variant.size.width;
    final split = width >= AppBreakpoints.expanded;
    final item = tester.getRect(find.byType(AppListItem));
    expect(item.left, 0);
    expect(item.width, split ? AppSize.listPane : width, reason: 'Liste in size-list-pane bzw. voller Breite');
    if (!split) {
      expect(_pane(c), findsNothing, reason: 'unter breakpoint-expanded nur die Liste');
      expect(_dots, findsNothing);
      return;
    }

    final pane = tester.getRect(_pane(c));
    expect(pane, Rect.fromLTRB(AppSize.listPane, 0, width, variant.size.height), reason: 'Detail füllt den Rest');
    final decoration = tester.widget<DecoratedBox>(_pane(c)).decoration as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.left, BorderSide(color: c.lineHairline, width: AppStroke.hairline));
    expect([border.top, border.right, border.bottom], everyElement(BorderSide.none));

    expect(tester.getRect(_dots), Rect.fromLTRB(AppSize.listPane + AppStroke.hairline, 0, width, variant.size.height),
        reason: 'Punktraster über die ganze Fläche, neben der Haarlinie');
    expect(
      tester.renderObject(_dots),
      paints..circle(x: AppSpacing.l, y: AppSpacing.l, radius: AppSize.dot / 2, color: c.lineDot),
    );
    expect(find.descendant(of: _pane(c), matching: find.byType(Text)), findsNothing, reason: 'Leerstelle ohne Text (N3)');
  });

  testVariants('DS-63: mit Auswahl Detail rechts neben der Liste', (tester, variant) async {
    await pumpVariant(tester, variant, const ListDetailTemplate(list: _list, detail: _detail), wrapInPage: false);
    final c = _colors(variant);
    final width = variant.size.width;
    if (width < AppBreakpoints.expanded) {
      expect(find.text('Detail'), findsNothing, reason: 'unter breakpoint-expanded nur die Liste');
      expect(tester.getRect(find.byType(AppListItem)).width, width);
      return;
    }
    expect(_dots, findsNothing);
    final topBars = find.byType(AppTopBar);
    expect(topBars, findsNWidgets(2), reason: 'Liste und Detail mit eigener Kopfleiste');
    expect(tester.getRect(topBars.first).width, AppSize.listPane);
    final detailBar = tester.getRect(find.ancestor(of: find.text('Detail'), matching: topBars));
    expect(detailBar.left, AppSize.listPane + AppStroke.hairline);
    expect(detailBar.right, width);
    expect(find.descendant(of: _pane(c), matching: find.text('Inhalt')), findsOneWidget);
  });

  for (final (width, split) in [(AppBreakpoints.expanded - 1, false), (AppBreakpoints.expanded, true)]) {
    testWidgets('DS-63: nebeneinander ab breakpoint-expanded (Breite $width)', (tester) async {
      bool? isSplit;
      await _pump(tester, width, ListDetailTemplate(list: Builder(builder: (context) {
        isSplit = ListDetailTemplate.isSplit(context);
        return _list;
      })));
      expect(isSplit, split);
      expect(tester.getRect(find.byType(AppListItem)).width, split ? AppSize.listPane : width);
      expect(_dots, split ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('DS-63: Meldung aus dem Detail erscheint einmal', (tester) async {
    await _pump(
      tester,
      1024,
      ListDetailTemplate(
        list: _list,
        detail: Builder(
          builder: (context) => DetailPageTemplate(
            title: 'Detail',
            body: AppButton.primary(
              label: 'Melden',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gelöscht'))),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Melden'));
    await tester.pumpAndSettle();
    expect(find.text('Gelöscht'), findsOneWidget, reason: 'nicht je Seite eine Meldung');
  });

  for (final detail in [null, _detail]) {
    testWidgets('DS-63: 200 % Schrift ohne Überlauf (${detail == null ? 'ohne' : 'mit'} Auswahl)', (tester) async {
      await _pump(
        tester,
        1024,
        ListDetailTemplate(
          list: const ListPageTemplate(
            title: 'Liste mit langem Titel',
            body: AppItemList(children: [AppListItem(title: 'Eintrag mit langem Titel', subtitle: 'Untertitel')]),
          ),
          detail: detail,
        ),
        scale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
