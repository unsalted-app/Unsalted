// test/components/ds68_list_item_reflow_test.dart
//
// DS-68 (Teil 1.4 T00a, Figma `List/Item` „Umbruch bei großer Schrift“,
// Hinweis 4): Passt neben dem Element hinten das Element vorn samt breitestem
// Wort von Titel oder Untertitel nicht mehr, steht das Element hinten
// rechtsbündig unter dem Text (über die volle Breite, `space-m` darunter) —
// Wörter werden nicht getrennt. Sonst nebeneinander, senkrecht mittig.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

const _actions = Key('aktionen');

Widget _item() => AppListItem(
      leading: const AppIcon(AppIcons.book),
      title: 'Entwurf',
      subtitle: '28.09.2026',
      trailing: AppStack(key: _actions, direction: Axis.horizontal, children: [
        for (final icon in [AppIcons.starOutline, AppIcons.copy, AppIcons.compare, AppIcons.deleteOutline])
          AppIconButton(icon: icon, tooltip: 'Aktion', onPressed: () {}),
      ]),
    );

Future<void> _pump(WidgetTester tester, Size size, double scale) async {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await pumpVariant(tester, (name: 'hell', theme: AppTheme.light(), size: size), Align(alignment: Alignment.topCenter, child: _item()));
}

void main() {
  testWidgets('DS-68: Handy bei 200 % — Aktionen unter dem Text', (tester) async {
    await _pump(tester, const Size(390, 844), 2);
    expect(tester.takeException(), isNull, reason: 'kein Überlauf');
    final item = tester.getRect(find.byType(AppListItem));
    final actions = tester.getRect(find.byKey(_actions));
    final subtitle = tester.getRect(find.text('28.09.2026'));
    final title = tester.getRect(find.text('Entwurf'));
    expect(actions.top, greaterThanOrEqualTo(subtitle.bottom), reason: 'unter Titel und Untertitel');
    expect(actions.right, item.right - AppSpacing.l, reason: 'rechtsbündig');
    expect(item.bottom - actions.bottom, closeTo(AppSpacing.m, 1), reason: 'space-m darunter');
    final style = DefaultTextStyle.of(tester.element(find.text('Entwurf'))).style;
    expect(title.height, lessThanOrEqualTo(style.fontSize! * (style.height ?? 1.5) * 2 + 1), reason: 'eine Zeile');
  });

  testWidgets('DS-68: Tablet bei 100 % — Aktionen daneben, mittig', (tester) async {
    await _pump(tester, const Size(1024, 1366), 1);
    final item = tester.getRect(find.byType(AppListItem));
    final actions = tester.getRect(find.byKey(_actions));
    final title = tester.getRect(find.text('Entwurf'));
    expect(actions.left, greaterThan(title.right), reason: 'daneben');
    expect(actions.right, item.right - AppSpacing.l);
    expect(actions.center.dy, closeTo(item.center.dy, 1), reason: 'senkrecht mittig');
  });
}
