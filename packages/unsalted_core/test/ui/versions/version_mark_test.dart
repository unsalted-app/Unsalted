// test/ui/versions/version_mark_test.dart
//
// UI-67 und UI-68 (Teil 1.3, D13): Fassungsmarke, Fassungsleiste und Master.
// UI-87 (Teil 1.4, B02): Mit `masterVersionId` trägt die Master-Marke in der
// Fassungsleiste die Markerfläche und „Master“ in der Semantik; die Auswahl
// bleibt davon unabhängig.
// UI-67: Die Fassungsleiste zeigt je Version eine Marke (Entwurf gestrichelt,
// eingefroren mit Kontur), die gewählte mit Auswahlbalken; Semantik nennt
// Nummer, Bezeichnung und Zustand; Tippen meldet die Version; bei großer
// Schrift bricht die Leiste um statt abzuschneiden. UI-68: Im Verlauf trägt
// jeder Eintrag genau eine Marke „V{n}“, der Zustand steht als Wort, die
// Master-Version trägt die Markerfläche und das Wort „Master“ statt des
// Sterns.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/recipe/recipe_version.dart';
import 'package:unsalted_core/src/ui/recipe_detail/version_switcher.dart';
import 'package:unsalted_core/src/ui/versions/version_mark.dart';
import 'package:unsalted_core/src/ui/versions/version_tile.dart';
import 'package:unsalted_design/unsalted_design.dart';

RecipeVersion _version(int index, {VersionState state = VersionState.snapshot, String? label}) => RecipeVersion(
      id: 'v$index',
      recipeId: 'r',
      versionIndex: index,
      label: label,
      state: state,
      bakingLossPercent: Decimal.zero,
      snapshottedAt: state == VersionState.snapshot ? DateTime(2026, 10, index) : null,
    );

final _versions = [
  _version(3, state: VersionState.draft),
  _version(2, label: 'mit Vorteig'),
  _version(1),
];

Future<void> _pump(WidgetTester tester, Widget child, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child)));
}

AppMark _markOf(WidgetTester tester, String text) =>
    tester.widget<AppMark>(find.ancestor(of: find.text(text), matching: find.byType(AppMark)));

void main() {
  testWidgets('UI-67: Fassungsleiste — Marken, Auswahl, Semantik, Tippen', (tester) async {
    final selected = <String>[];
    await _pump(tester, VersionSwitcher(versions: _versions, selectedVersionId: 'v2', onSelected: selected.add));

    expect(find.byType(VersionMark), findsNWidgets(3));
    expect(find.byType(ChoiceChip), findsNothing, reason: 'keine Auswahl-Chips mehr');
    expect(_markOf(tester, 'V3').state, AppMarkState.provisional);
    expect(_markOf(tester, 'V2 · mit Vorteig').state, AppMarkState.fixed);
    expect(_markOf(tester, 'V1').state, AppMarkState.fixed);
    expect([for (final m in tester.widgetList<AppMark>(find.byType(AppMark))) if (m.selected) m.label], ['V2 · mit Vorteig']);

    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(VersionMark).at(1)),
      isSemantics(label: 'Version 2 · mit Vorteig, eingefroren', isButton: true, isSelected: true, hasTapAction: true),
    );
    expect(tester.getSemantics(find.byType(VersionMark).first).label, 'Version 3, Entwurf');
    semantics.dispose();

    for (final mark in tester.widgetList<VersionMark>(find.byType(VersionMark))) {
      final size = tester.getSize(find.byWidget(mark));
      expect(size.width, greaterThanOrEqualTo(AppSize.target), reason: 'Tippziel');
      expect(size.height, greaterThanOrEqualTo(AppSize.target), reason: 'Tippziel');
    }
    await tester.tap(find.text('V1'));
    expect(selected, ['v1']);
  });

  testWidgets('UI-67: Fassungsleiste bricht bei 200 % um statt abzuschneiden', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final many = [for (var i = 6; i >= 1; i--) _version(i, label: i.isEven ? 'mit Vorteig' : null)];
    await _pump(tester, VersionSwitcher(versions: many, selectedVersionId: 'v6', onSelected: (_) {}));
    expect(tester.takeException(), isNull, reason: 'kein Überlauf');
    final first = tester.getRect(find.text('V6 · mit Vorteig'));
    final last = tester.getRect(find.text('V1'));
    expect(last.top, greaterThan(first.top), reason: 'zweite Zeile');
    for (final mark in tester.widgetList<VersionMark>(find.byType(VersionMark))) {
      expect(tester.getRect(find.byWidget(mark)).right, lessThanOrEqualTo(390));
    }
  });

  testWidgets('UI-68: Verlauf — eine Marke je Eintrag, Zustand als Wort, Master mit Wort', (tester) async {
    Widget tile(RecipeVersion version, {bool isMaster = false}) => VersionTile(
          version: version,
          isMaster: isMaster,
          onMarkMaster: () {},
          onCopy: () {},
          onCompare: () {},
          onDelete: () {},
        );
    await _pump(
      tester,
      AppItemList(children: [tile(_versions[0]), tile(_versions[1], isMaster: true), tile(_versions[2])]),
    );

    for (final text in ['V3', 'V2 · mit Vorteig', 'V1']) {
      expect(find.text(text), findsOneWidget, reason: 'genau ein „V{n}“ je Eintrag');
    }
    expect(find.text('Entwurf'), findsOneWidget);
    expect(find.text('Eingefroren'), findsNWidgets(2));
    expect(find.byIcon(AppIcons.star), findsNothing, reason: 'kein Stern mehr');
    expect(find.text('Master'), findsOneWidget);

    Finder tileOf(String text) => find.ancestor(of: find.text(text), matching: find.byType(AppListItem));
    expect(find.descendant(of: tileOf('V2 · mit Vorteig'), matching: find.text('Master')), findsOneWidget);
    expect(_markOf(tester, 'V2 · mit Vorteig').state, AppMarkState.highlighted);
    expect(_markOf(tester, 'V1').state, AppMarkState.fixed);
    expect(_markOf(tester, 'V3').state, AppMarkState.provisional);
    expect(find.descendant(of: tileOf('V2 · mit Vorteig'), matching: find.byTooltip('Als Master markieren')), findsNothing);
    expect(find.descendant(of: tileOf('V1'), matching: find.byTooltip('Als Master markieren')), findsOneWidget);

    // Der Listeneintrag fasst seine Semantik zusammen; die Marke steht vorn.
    final semantics = tester.ensureSemantics();
    expect(tester.getSemantics(find.byType(VersionMark).at(1)).label,
        startsWith('Version 2 · mit Vorteig, eingefroren, Master'));
    semantics.dispose();
  });

  testWidgets('UI-87: Fassungsleiste markiert den Master', (tester) async {
    await _pump(
      tester,
      VersionSwitcher(versions: _versions, selectedVersionId: 'v2', masterVersionId: 'v1', onSelected: (_) {}),
    );
    expect(_markOf(tester, 'V1').state, AppMarkState.highlighted, reason: 'Master mit Markerfläche');
    expect(_markOf(tester, 'V2 · mit Vorteig').state, AppMarkState.fixed);
    expect(_markOf(tester, 'V3').state, AppMarkState.provisional);
    expect(_markOf(tester, 'V1').selected, isFalse, reason: 'Auswahl unabhängig vom Master');
    expect(_markOf(tester, 'V2 · mit Vorteig').selected, isTrue);
    final semantics = tester.ensureSemantics();
    expect(tester.getSemantics(find.byType(VersionMark).last).label, 'Version 1, eingefroren, Master');
    semantics.dispose();
  });
}
