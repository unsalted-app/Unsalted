// test/ui/recipe_editor/editor_design_test.dart
//
// UI-72 bis UI-74 und UI-76 (Teil 1.3, D16): Editor, Verpackungsformular und
// Leerstellen nach Figma.
// UI-72: Die Zutatenzeile ist zweizeilig (oben Name, darunter eingerückt
// Menge in `reflow-value-column`, Einheit, Notiz), bei großer Schrift ohne
// Überlauf untereinander; eine nicht verknüpfte Zutat ist gestrichelt
// unterstrichen, eine verknüpfte nicht.
// UI-73: Warnung und Fehler im Verpackungsformular sind Hinweise mit Symbol
// (Keys unverändert); die Nährwertfelder stehen ab 600 Breite zweispaltig.
// UI-74: Schrittzeile mit Nummer (`size-index-column`, `data-strong`) und dem
// Timer-Feld unter der Anweisung; die Schritte im Rezeptdetail mit Nummer und
// Timer als Tag mit Symbol; die eingefrorene Ansicht im Zustandsrahmen mit
// Fassungsmarke samt Siegel.
// UI-76: „Keine Treffer.“ ohne Leerstelle (kein Punktraster), „Noch keine
// Rezepte.“ mit Leerstelle und Aktion.
// UI-77 (D16b): Abstand `space-m` zwischen den Feldern des Abschnitts
// „Parameter“.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';
import 'package:unsalted_core/src/recipe/recipe_version.dart';
import 'package:unsalted_core/src/ui/foods/package_form.dart';
import 'package:unsalted_core/src/ui/recipe_detail/sections/recipe_detail_steps_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/ingredient_row.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_frozen_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_parameters_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_steps_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/step_row.dart';
import 'package:unsalted_core/src/ui/recipe_list/sections/recipe_list_empty_section.dart';
import 'package:unsalted_core/src/ui/versions/version_mark.dart';
import 'package:unsalted_design/unsalted_design.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double scale = 1,
  bool scrolls = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: scrolls ? SingleChildScrollView(child: child) : child),
    ),
  ));
}

IngredientRow _row({bool linked = false}) => IngredientRow(
      data: IngredientRowData(
        id: 'i1',
        variant: linked ? const FoodVariant(id: 'v1', name: 'Mehl', source: FoodSource.custom) : null,
        displayName: 'Mehl',
        quantity: Decimal.fromInt(500),
        unitCode: 'g',
      ),
      onChanged: (_) {},
      onRemove: () {},
    );

Rect _field(WidgetTester tester, String label) => tester.getRect(find.widgetWithText(AppTextField, label));

RecipeVersion _frozenVersion() => RecipeVersion(
      id: 'v3',
      recipeId: 'r',
      versionIndex: 3,
      state: VersionState.snapshot,
      bakingLossPercent: Decimal.zero,
      snapshottedAt: DateTime(2026, 10, 1),
      ingredients: [
        RecipeIngredient(
          id: 'i',
          versionId: 'v3',
          position: 1,
          displayName: 'Mehl',
          quantity: Decimal.fromInt(500),
          unitCode: 'g',
        ),
      ],
      steps: const [RecipeStep(id: 's', versionId: 'v3', position: 1, instruction: 'Kneten')],
    );

void main() {
  testWidgets('UI-72: Zutatenzeile zweizeilig, Menge in reflow-value-column', (tester) async {
    await _pump(tester, _row());
    final name = _field(tester, 'Name');
    final amount = _field(tester, 'Menge');
    final note = _field(tester, 'Notiz');
    expect(amount.top, greaterThan(name.bottom), reason: 'Menge in der zweiten Zeile');
    expect(amount.width, AppReflow.valueColumn);
    expect(note.top, amount.top, reason: 'Einheit und Notiz in derselben Zeile');
    expect(tester.getRect(find.byType(AppSelect<String>)).left, greaterThan(amount.right));
    expect(amount.left, greaterThan(tester.getRect(find.byIcon(AppIcons.dragHandle)).left), reason: 'eingerückt');
    expect(find.byTooltip('Zutat entfernen'), findsOneWidget);
  });

  testWidgets('UI-72: bei 200 % ohne Überlauf untereinander', (tester) async {
    await _pump(tester, _row(), scale: 2);
    expect(tester.takeException(), isNull);
    final amount = _field(tester, 'Menge');
    final note = _field(tester, 'Notiz');
    expect(amount.width, AppReflowMetric.valueColumn.at(2));
    expect(tester.getRect(find.byType(AppSelect<String>)).top, greaterThanOrEqualTo(amount.bottom));
    expect(note.top, greaterThan(tester.getRect(find.byType(AppSelect<String>)).bottom));
  });

  testWidgets('UI-72: nicht verknüpft gestrichelt unterstrichen, verknüpft nicht', (tester) async {
    await _pump(tester, _row());
    expect(find.ancestor(of: find.widgetWithText(AppTextField, 'Name'), matching: find.byType(AppDashedUnderline)),
        findsOneWidget);
    await _pump(tester, _row(linked: true));
    expect(find.byType(AppDashedUnderline), findsNothing);
  });

  testWidgets('UI-73: Warnung und Fehler als Hinweise mit Symbol, Keys unverändert', (tester) async {
    await _pump(tester, const PackageForm(), size: const Size(800, 3000), scrolls: false);
    await tester.enterText(find.widgetWithText(AppTextField, 'Fett (g)'), '5');
    await tester.enterText(find.widgetWithText(AppTextField, 'davon gesättigte Fettsäuren (g)'), '10');
    await tester.pump();
    final warning = tester.widget<AppNotice>(find.byKey(const Key('package_form_warning')));
    expect(warning.kind, AppNoticeKind.warning);
    await tester.enterText(find.widgetWithText(AppTextField, 'Fett (g)'), '-1');
    await tester.pump();
    final error = tester.widget<AppNotice>(find.byKey(const Key('package_form_error')));
    expect(error.kind, AppNoticeKind.error);
  });

  for (final width in [390.0, 800.0]) {
    testWidgets('UI-73: Nährwertfelder bei Breite $width', (tester) async {
      await _pump(tester, const PackageForm(), size: Size(width, 3000), scrolls: false);
      final kcal = _field(tester, 'Kalorien (kcal)');
      final fat = _field(tester, 'Fett (g)');
      if (width >= AppBreakpoints.medium) {
        expect(fat.top, kcal.top, reason: 'zweispaltig');
        expect(fat.left, greaterThan(kcal.right));
      } else {
        expect(fat.top, greaterThan(kcal.bottom), reason: 'einspaltig');
      }
    });
  }

  testWidgets('UI-74: Schrittzeile mit Nummer, Timer unter der Anweisung', (tester) async {
    await _pump(
      tester,
      RecipeEditorStepsSection(
        steps: const [
          StepRowData(id: 'a', instruction: 'Kneten'),
          StepRowData(id: 'b', instruction: 'Ruhen', timerSeconds: 600, loadedTimerSeconds: 600),
        ],
        onReorder: (_, _) {},
        onInstructionChanged: (_, _) {},
        onTimerChanged: (_, _) {},
        onRemoved: (_) {},
        onAdd: () {},
      ),
    );
    expect([for (final row in tester.widgetList<StepRow>(find.byType(StepRow))) row.number], [1, 2]);
    final number = tester.widget<Text>(find.text('2'));
    expect(number.style!.fontWeight, AppTypography.dataStrong.fontWeight);
    final instruction = tester.getRect(find.widgetWithText(AppTextField, 'Anweisung').last);
    final timer = tester.getRect(find.widgetWithText(AppTextField, 'Timer (Min.)').last);
    expect(timer.top, greaterThan(instruction.bottom), reason: 'Timer unter der Anweisung');
    expect(timer.width, AppReflow.fieldMin);
    expect(tester.getRect(find.text('2')).right, lessThanOrEqualTo(instruction.left));
  });

  testWidgets('UI-74: schmales Timer-Feld wächst bei 200 %', (tester) async {
    await _pump(
      tester,
      StepRow(data: const StepRowData(id: 'a', instruction: 'Kneten'), number: 1, onInstructionChanged: (_) {},
          onTimerChanged: (_) {}, onRemove: () {}),
      scale: 2,
    );
    expect(tester.takeException(), isNull);
    final timer = tester.getRect(find.widgetWithText(AppTextField, 'Timer (Min.)'));
    final instruction = tester.getRect(find.widgetWithText(AppTextField, 'Anweisung'));
    expect(timer.width, greaterThan(AppReflow.fieldMin));
    expect(timer.width, lessThanOrEqualTo(instruction.width), reason: 'nie breiter als die Spalte');
  });

  testWidgets('UI-74: Schritte im Rezeptdetail mit Nummer und Timer-Tag', (tester) async {
    await _pump(
      tester,
      const RecipeDetailStepsSection(steps: [
        RecipeStep(id: 'a', versionId: 'v', position: 1, instruction: 'Kneten'),
        RecipeStep(id: 'b', versionId: 'v', position: 2, instruction: 'Ruhen', timerSeconds: 600),
      ]),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    final tag = tester.widget<AppChip>(find.byType(AppChip));
    expect((tag.label, tag.icon), ('10:00', AppIcons.timer));
    expect(tester.getRect(find.byType(AppChip)).top, greaterThan(tester.getRect(find.text('Ruhen')).bottom));
    expect(find.byType(AppListItem), findsNothing);
  });

  testWidgets('UI-74: eingefrorene Ansicht im Zustandsrahmen mit Siegel', (tester) async {
    var copies = 0;
    await _pump(tester, RecipeEditorFrozenSection(version: _frozenVersion(), onCopy: () => copies++));
    expect(find.text('Eingefroren — als neuen Entwurf kopieren?'), findsOneWidget);
    expect(find.descendant(of: find.byType(AppNotice), matching: find.widgetWithText(AppButton, 'Kopieren')),
        findsOneWidget);
    final mark = tester.widget<VersionMark>(find.byType(VersionMark));
    expect(mark.seal, isTrue);
    expect(tester.widget<AppMark>(find.byType(AppMark)).state, AppMarkState.fixed);
    expect(find.ancestor(of: find.text('Kneten'), matching: find.byType(AppFrame)), findsOneWidget);
    await tester.tap(find.text('Kopieren'));
    expect(copies, 1);
  });

  testWidgets('UI-76: „Keine Treffer.“ ohne Leerstelle, leere Liste mit Leerstelle', (tester) async {
    await _pump(tester, SizedBox(height: 600, child: RecipeListEmptySection(hasRecipes: true, onCreate: () {})));
    expect(find.text('Keine Treffer.'), findsOneWidget);
    expect(find.byType(AppSlot), findsNothing, reason: 'kein Punktraster');
    expect(find.byType(AppButton), findsNothing);

    await _pump(tester, SizedBox(height: 600, child: RecipeListEmptySection(hasRecipes: false, onCreate: () {})));
    expect(find.byType(AppSlot), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Erstes Rezept anlegen'), findsOneWidget);
  });

  for (final showAdvanced in [true, false]) {
    testWidgets('UI-77: Abstand zwischen den Parameter-Feldern (showAdvanced: $showAdvanced)', (tester) async {
      await _pump(
        tester,
        RecipeEditorParametersSection(
          servings: TextEditingController(),
          bakingLoss: TextEditingController(),
          finalWeight: TextEditingController(),
          notes: TextEditingController(),
          onChanged: () {},
          showAdvanced: showAdvanced,
        ),
      );
      final fields = [for (final e in find.byType(AppTextField).evaluate()) tester.getRect(find.byWidget(e.widget))];
      expect(fields, hasLength(showAdvanced ? 4 : 2));
      for (var i = 1; i < fields.length; i++) {
        expect(fields[i].top - fields[i - 1].bottom, AppSpacing.m);
      }
    });
  }
}
