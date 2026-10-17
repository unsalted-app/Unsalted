// test/ui/versions/change_list_test.dart
//
// UI-69 (Teil 1.3, D14): Die Änderungsliste zeigt jede Änderung in Teilen —
// alt durchgestrichen, Pfeil als Symbol, neu markiert; hinzugefügt nur
// Marker, entfernt nur Strich —, gruppiert in Abschnitten mit 3-px-Linie.
// Vorgelesen wird jede Änderung als ihr bisheriger Text (28.4.5); kein
// sichtbarer Text enthält den Pfeil. Texte ohne Teile stehen unverändert da.
// UI-75 (Teil 1.3, D14, Entscheidung 3 zu Etappe 2): Würde eine Spalte des
// Versionsvergleichs schmaler als `reflow-label-min`, steht A über B.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';
import 'package:unsalted_core/src/ui/versions/change_descriptions.dart';
import 'package:unsalted_core/src/ui/versions/change_list.dart';
import 'package:unsalted_core/src/ui/versions/sections/version_compare_columns_section.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'change_descriptions_test.dart' show d, ing, snapshot;

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child)));
}

void main() {
  final a = snapshot(servings: 8, ingredients: [ing(1, 'Mehl', '100', 'g'), ing(2, 'Zucker', '5', 'g')]);
  final changes = <RecipeChange>[
    const SetServings(servings: 10),
    SetIngredientQuantity(position: 1, quantity: d('200')),
    const RemoveIngredient(position: 2),
    AddIngredient(position: 2, displayName: 'Salz', quantity: d('5'), unitCode: 'g'),
  ];

  testWidgets('UI-69: Änderungen in Teilen, vorgelesen als bisheriger Text', (tester) async {
    final texts = describeChanges(a, changes);
    await _pump(tester, ChangeList(changes: changes, descriptions: texts));

    for (final text in texts) {
      expect(find.bySemanticsLabel(text), findsOneWidget, reason: text);
    }
    expect(find.byType(AppChangeText), findsNWidgets(4));
    expect(find.byIcon(AppIcons.arrow), findsNWidgets(2), reason: 'Pfeil nur bei alt → neu');
    expect(find.textContaining('→'), findsNothing, reason: 'der Pfeil wird nie als Zeichen gezeichnet');

    // alt durchgestrichen, neu markiert
    expect(tester.widget<Text>(find.text('100 g')).style!.decoration, TextDecoration.lineThrough);
    expect(find.ancestor(of: find.text('200 g'), matching: find.byType(AppHighlight)), findsOneWidget);
    // hinzugefügt nur Marker, entfernt nur Strich
    expect(find.ancestor(of: find.text('Salz · 5 g'), matching: find.byType(AppHighlight)), findsOneWidget);
    expect(tester.widget<Text>(find.text('Zucker · 5 g')).style!.decoration, TextDecoration.lineThrough);
    // Abschnitte mit Überschrift und Linie
    expect(find.widgetWithText(AppSection, 'Parameter'), findsOneWidget);
    expect(find.widgetWithText(AppSection, 'Zutaten'), findsOneWidget);
  });

  testWidgets('UI-69: Texte ohne Teile stehen unverändert da', (tester) async {
    await _pump(tester, ChangeList(changes: changes, descriptions: [...describeChanges(a, changes)]));
    expect(find.byType(AppChangeText), findsNothing);
    expect(find.text('Mehl: 100 g → 200 g'), findsOneWidget);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('UI-75: Versionsvergleich bei Textgröße ${scale * 100} %', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final b = snapshot(title: 'Brot mit Weizenmehl', servings: 10, ingredients: [ing(1, 'Weizenmehl', '200', 'g')]);
      await _pump(tester, SingleChildScrollView(child: VersionCompareColumnsSection(a: a, b: b)));
      expect(tester.takeException(), isNull);
      final columnA = tester.getRect(find.text('A'));
      final columnB = tester.getRect(find.text('B'));
      final stacked = 390 / 2 < AppReflowMetric.labelMin.at(scale);
      if (stacked) {
        expect(columnB.top, greaterThan(columnA.bottom), reason: 'A über B');
        expect(columnB.left, columnA.left);
      } else {
        expect(columnB.top, columnA.top, reason: 'nebeneinander');
        expect(columnB.left, greaterThan(390 / 2));
      }
      if (scale == 2) expect(stacked, isTrue);
    });
  }
}
