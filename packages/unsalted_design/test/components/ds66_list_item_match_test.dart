// test/components/ds66_list_item_match_test.dart
//
// DS-66 (Teil 1.4 B04, Figma `List/Item` `showMatch`): `AppListItem.match`
// markiert den Treffer im Titel — Markerfläche dahinter, Text darin in
// `text-on-marker`; der Titel bleibt ein Text mit unverändertem Klartext
// (Semantik, `find.text`). Ohne oder mit ungültigem Bereich keine Markierung.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

AppColorTokens _colors(Variant variant) =>
    variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;

Finder _painterOf(Finder item) => find.descendant(
      of: item,
      matching: find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == '_MatchPainter'),
    );

void main() {
  testVariants('DS-66: Treffer im Titel markiert, Klartext und Semantik unverändert', (tester, variant) async {
    const title = 'Hefeteig für Zopf';
    await pumpVariant(
      tester,
      variant,
      const AppListItem(title: title, match: TextRange(start: 4, end: 8)),
    );
    final c = _colors(variant);
    expect(find.text(title), findsOneWidget, reason: 'Klartext unverändert');
    final text = tester.widget<Text>(find.text(title));
    final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect([for (final span in spans) span.text], ['Hefe', 'teig', ' für Zopf']);
    expect(spans[1].style!.color, c.textOnMarker);

    final painter = _painterOf(find.byType(AppListItem));
    expect(painter, findsOneWidget);
    expect(tester.renderObject(painter), paints..rrect(color: c.marker));

    final semantics = tester.ensureSemantics();
    expect(tester.getSemantics(find.byType(ListTile)).label, contains(title));
    semantics.dispose();
  });

  testVariants('DS-66: ohne oder mit ungültigem Treffer keine Markierung', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppListItem(key: Key('ohne'), title: 'Mürbeteig'),
        AppListItem(key: Key('ungültig'), title: 'Rührteig', match: TextRange(start: 3, end: 40)),
      ]),
    );
    expect(_painterOf(find.byKey(const Key('ohne'))), findsNothing);
    expect(_painterOf(find.byKey(const Key('ungültig'))), findsNothing);
    expect(find.text('Mürbeteig'), findsOneWidget);
    expect(find.text('Rührteig'), findsOneWidget);
  });
}
