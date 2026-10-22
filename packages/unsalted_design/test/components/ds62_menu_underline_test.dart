// test/components/ds62_menu_underline_test.dart
//
// DS-62 (Teil 1.4 B01): `AppOverflowMenu.tooltip` ist Tooltip und Semantik des
// Menüknopfs (ohne: Standardtext der Plattform); ausgegraute Einträge stehen
// im Menü, lösen aber nichts aus (Figma `Navigation/Menu Item`,
// `state=disabled`).
// DS-64 (Teil 1.4 B01, Figma-Hinweis 2): `AppDashedUnderline` zeichnet die
// Linie `space-xxs` unter dem Inhalt und ändert das Layout nicht.
// DS-65 (Teil 1.4 B01): `AppSelect` mit Beschriftung und `expand` füllt eine
// schmale Breite ohne Überlauf (lange Einträge gekürzt).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-62: AppOverflowMenu mit Tooltip und ausgegrautem Eintrag', (tester, variant) async {
    final calls = <String>[];
    await pumpVariant(
      tester,
      variant,
      Align(
        alignment: Alignment.topRight,
        child: AppOverflowMenu(tooltip: 'Aktionen für Zutat', entries: [
          AppMenuEntry(label: 'Nach oben', enabled: false, onSelected: () => calls.add('oben')),
          AppMenuEntry(label: 'Entfernen', onSelected: () => calls.add('entfernen')),
        ]),
      ),
    );
    expect(find.byTooltip('Aktionen für Zutat'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    final data = tester.getSemantics(find.byTooltip('Aktionen für Zutat')).getSemanticsData();
    expect(data.tooltip, 'Aktionen für Zutat', reason: 'Semantik des Menüknopfs');
    semantics.dispose();

    await tester.tap(find.byTooltip('Aktionen für Zutat'));
    await tester.pumpAndSettle();
    final up = tester.widget<PopupMenuItem<VoidCallback>>(
      find.ancestor(of: find.text('Nach oben'), matching: find.byType(PopupMenuItem<VoidCallback>)),
    );
    expect(up.enabled, isFalse, reason: 'ausgegraut');
    await tester.tap(find.text('Nach oben'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
    await tester.tap(find.text('Entfernen'));
    await tester.pumpAndSettle();
    expect(calls, ['entfernen']);
  });

  testVariants('DS-62: AppOverflowMenu ohne Tooltip mit dem Standardtext', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topRight,
        child: AppOverflowMenu(entries: [AppMenuEntry(label: 'Eins', onSelected: _noop)]),
      ),
    );
    final context = tester.element(find.byType(AppOverflowMenu));
    expect(find.byTooltip(MaterialLocalizations.of(context).showMenuTooltip), findsOneWidget);
  });

  testVariants('DS-64: AppDashedUnderline space-xxs unter dem Inhalt, Layout unverändert', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(
        alignment: Alignment.topLeft,
        child: AppDashedUnderline(child: SizedBox(width: 120, height: AppSize.control)),
      ),
    );
    expect(tester.getSize(find.byType(AppDashedUnderline)), const Size(120, AppSize.control));
    final paint = find.descendant(of: find.byType(AppDashedUnderline), matching: find.byType(CustomPaint)).first;
    final tops = <double>[];
    expect(
      tester.renderObject(paint),
      paints
        ..everything((Symbol method, List<dynamic> arguments) {
          if (method == #drawPath) tops.add((arguments[0] as Path).getBounds().center.dy);
          return true;
        }),
    );
    expect(tops, isNotEmpty);
    for (final y in tops) {
      expect(y, AppSize.control + AppSpacing.xxs + AppStroke.frame / 2, reason: 'Linie space-xxs unter dem Feld');
    }
  });

  testVariants('DS-65: AppSelect mit Beschriftung und expand füllt die Breite', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: AppReflow.selectMin,
          child: AppSelect<String>(
            label: 'Einheit',
            expand: true,
            value: 'el',
            onChanged: (_) {},
            items: const [AppSelectItem('g', 'g'), AppSelectItem('el', 'Esslöffel'), AppSelectItem('tl', 'Teelöffel')],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull, reason: 'kein Überlauf');
    expect(tester.getSize(find.byType(AppSelect<String>)).width, AppReflow.selectMin);
  });
}

void _noop() {}
