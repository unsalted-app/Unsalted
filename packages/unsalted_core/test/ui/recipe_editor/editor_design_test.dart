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
// UI-78 (D16c): Die Nährwertfelder des Verpackungsformulars sind Zahlenfelder
// (Tastatur mit Komma, rechtsbündig, tabellarische Ziffern).
// UI-79 (D18b): Abstand `space-m` zwischen Titel und Beschreibung
// (Bildschirm 2).
// UI-80 (D18b): Maßfelder des Verpackungsformulars und Editor-Parameter sind
// Zahlenfelder; Portionen ohne Komma, die übrigen mit Komma.
// UI-81 (D18c): Abstand `space-m` zwischen den Maßfeldern des
// Verpackungsformulars.
// UI-82 (D18d): Abstand `space-m` auch zwischen Name, Marke und Barcode
// (Kennung), zwischen den Auswahlfeldern des Exports und zwischen Anweisung
// und Timer der Schrittzeile.
// UI-84 (Teil 1.4 B01, Figma N1): Zutatenzeile mit Zeilenmenü „⋮“ (Tooltip
// „Aktionen für Zutat“: „Nach oben“, „Nach unten“, „Entfernen“, erste bzw.
// letzte Zeile ausgegraut; dieselben `onReorder`-Werte wie das Ziehen),
// Beschriftung „Einheit“, `space-m` zwischen den Zeilen, Haarlinie unten,
// schreibgeschützt ohne Menü.
// UI-85 (Teil 1.4 B01, Figma N1): Schrittzeile wie die Zutatenzeile — Griff,
// Nummer und Menü unten bündig mit der Anweisung, Timer eingerückt darunter,
// Menü mit Tooltip „Aktionen für Schritt“, Haarlinie unten.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/recipe/recipe.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';
import 'package:unsalted_core/src/recipe/recipe_version.dart';
import 'package:unsalted_core/src/ui/foods/package_form.dart';
import 'package:unsalted_core/src/ui/foods/sections/package_identity_section.dart';
import 'package:unsalted_core/src/ui/foods/sections/package_measures_section.dart';
import 'package:unsalted_core/src/ui/recipe_detail/sections/recipe_detail_steps_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/ingredient_row.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_create_fields_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_frozen_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_parameters_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_ingredients_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_steps_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/step_row.dart';
import 'package:unsalted_core/src/ui/recipe_list/sections/recipe_list_empty_section.dart';
import 'package:unsalted_core/src/ui/settings/sections/export_selection_section.dart';
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

TextField _input(WidgetTester tester, String label) => tester.widget<TextField>(
      find.descendant(of: find.widgetWithText(AppTextField, label), matching: find.byType(TextField)),
    );

/// Zahlenfeld nach D16c: Tastatur [keyboard], rechtsbündig, tabellarische
/// Ziffern.
void _expectNumeric(WidgetTester tester, String label, TextInputType keyboard) {
  final field = _input(tester, label);
  expect(field.keyboardType, keyboard, reason: label);
  expect(field.textAlign, TextAlign.end, reason: label);
  expect(field.style!.fontFeatures, AppTypography.data.fontFeatures, reason: label);
}

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
    expect(find.byTooltip('Aktionen für Zutat'), findsOneWidget);
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

  testWidgets('UI-78: Nährwertfelder als Zahlenfelder', (tester) async {
    await _pump(tester, const PackageForm(), size: const Size(800, 3000), scrolls: false);
    const labels = [
      'Kalorien (kcal)',
      'Fett (g)',
      'davon gesättigte Fettsäuren (g)',
      'Kohlenhydrate (g)',
      'davon Zucker (g)',
      'Ballaststoffe (g)',
      'Eiweiß (g)',
      'Salz (g)',
    ];
    for (final label in labels) {
      final field = tester.widget<TextField>(
        find.descendant(of: find.widgetWithText(AppTextField, label), matching: find.byType(TextField)),
      );
      expect(field.keyboardType, const TextInputType.numberWithOptions(decimal: true), reason: label);
      expect(field.textAlign, TextAlign.end, reason: label);
      expect(field.style!.fontFeatures, AppTypography.data.fontFeatures, reason: label);
    }
    await tester.enterText(find.widgetWithText(AppTextField, 'Fett (g)'), '2,5');
    expect(find.text('2,5'), findsOneWidget, reason: 'Komma bleibt erhalten');
  });

  testWidgets('UI-79: Abstand zwischen Titel und Beschreibung', (tester) async {
    await _pump(
      tester,
      RecipeCreateFieldsSection(
        titleController: TextEditingController(),
        descriptionController: TextEditingController(),
        titleError: null,
      ),
    );
    expect(_field(tester, 'Beschreibung').top - _field(tester, 'Titel').bottom, AppSpacing.m);
  });

  testWidgets('UI-80: Maßfelder als Zahlenfelder mit Komma', (tester) async {
    await _pump(
      tester,
      PackageMeasuresSection(
        density: TextEditingController(),
        gramsPerPiece: TextEditingController(),
        servingSize: TextEditingController(),
      ),
    );
    const decimal = TextInputType.numberWithOptions(decimal: true);
    for (final label in ['Dichte (g/ml)', 'Stückgewicht (g)', 'Portionsgröße (g)']) {
      _expectNumeric(tester, label, decimal);
    }
    await tester.enterText(find.widgetWithText(AppTextField, 'Dichte (g/ml)'), '1,03');
    expect(find.text('1,03'), findsOneWidget, reason: 'Komma bleibt erhalten');
  });

  testWidgets('UI-80: Editor-Parameter als Zahlenfelder, Portionen ohne Komma', (tester) async {
    await _pump(
      tester,
      RecipeEditorParametersSection(
        servings: TextEditingController(),
        bakingLoss: TextEditingController(),
        finalWeight: TextEditingController(),
        notes: TextEditingController(),
        onChanged: () {},
        showAdvanced: true,
      ),
    );
    _expectNumeric(tester, 'Portionen', TextInputType.number);
    expect(_input(tester, 'Portionen').keyboardType.decimal, isNot(isTrue), reason: 'Portionen ohne Komma');
    const decimal = TextInputType.numberWithOptions(decimal: true);
    _expectNumeric(tester, 'Backverlust (%)', decimal);
    _expectNumeric(tester, 'Fertiggewicht-Override (g)', decimal);
    final notes = _input(tester, 'Notizen');
    expect(notes.keyboardType.index, isNot(TextInputType.number.index), reason: 'Notizen bleiben Text');
    expect(notes.textAlign, TextAlign.start, reason: 'Notizen bleiben Text');
  });

  for (final visible in [
    {Measure.density, Measure.gramsPerPiece, Measure.servingSize},
    {Measure.density, Measure.servingSize},
  ]) {
    testWidgets('UI-81: Abstand zwischen den Maßfeldern (${visible.length} Felder)', (tester) async {
      await _pump(
        tester,
        PackageMeasuresSection(
          density: TextEditingController(),
          gramsPerPiece: TextEditingController(),
          servingSize: TextEditingController(),
          visible: visible,
        ),
      );
      final fields = [for (final e in find.byType(AppTextField).evaluate()) tester.getRect(find.byWidget(e.widget))];
      expect(fields, hasLength(visible.length));
      for (var i = 1; i < fields.length; i++) {
        expect(fields[i].top - fields[i - 1].bottom, AppSpacing.m);
      }
    });
  }

  for (final showBarcode in [true, false]) {
    testWidgets('UI-82: Abstand zwischen Name, Marke und Barcode (showBarcode: $showBarcode)', (tester) async {
      await _pump(
        tester,
        PackageIdentitySection(
          name: TextEditingController(),
          brand: TextEditingController(),
          barcode: TextEditingController(),
          showBarcode: showBarcode,
        ),
      );
      final fields = [for (final e in find.byType(AppTextField).evaluate()) tester.getRect(find.byWidget(e.widget))];
      expect(fields, hasLength(showBarcode ? 3 : 2));
      for (var i = 1; i < fields.length; i++) {
        expect(fields[i].top - fields[i - 1].bottom, AppSpacing.m);
      }
    });
  }

  testWidgets('UI-82: Abstand zwischen den Auswahlfeldern des Exports', (tester) async {
    await _pump(
      tester,
      ExportSelectionSection(
        recipes: Stream.value(const [Recipe(id: 'r', title: 'Pizzateig')]),
        versions: Stream.value([_frozenVersion()]),
        selectedRecipeId: 'r',
        selectedVersionId: 'v3',
        onRecipeSelected: (_) {},
        onVersionSelected: (_) {},
      ),
    );
    await tester.pump();
    final selects = [
      for (final e in find.byType(AppSelect<String>).evaluate()) tester.getRect(find.byWidget(e.widget)),
    ];
    expect(selects, hasLength(2), reason: 'Rezept und Version');
    expect(selects[1].top - selects[0].bottom, AppSpacing.m);
  });

  testWidgets('UI-82: Abstand zwischen Anweisung und Timer', (tester) async {
    await _pump(
      tester,
      StepRow(data: const StepRowData(id: 'a', instruction: 'Kneten'), number: 1, onInstructionChanged: (_) {},
          onTimerChanged: (_) {}, onRemove: () {}),
    );
    expect(_field(tester, 'Timer (Min.)').top - _field(tester, 'Anweisung').bottom, AppSpacing.m);
  });

  Future<List<PopupMenuItem<VoidCallback>>> openMenu(WidgetTester tester, Finder button) async {
    await tester.tap(button);
    await tester.pumpAndSettle();
    return tester.widgetList<PopupMenuItem<VoidCallback>>(find.byType(PopupMenuItem<VoidCallback>)).toList();
  }

  Future<void> choose(WidgetTester tester, String entry) async {
    await tester.tap(find.text(entry));
    await tester.pumpAndSettle();
  }

  String entryLabel(PopupMenuItem<VoidCallback> item) => (item.child! as Text).data!;

  testWidgets('UI-84: Zeilenmenü der Zutatenzeile, Einheit beschriftet, Abstände nach Figma', (tester) async {
    final moves = <(int, int)>[];
    final removed = <String>[];
    IngredientRowData data(String id, String name) =>
        IngredientRowData(id: id, displayName: name, quantity: Decimal.fromInt(100), unitCode: 'g');
    await _pump(
      tester,
      RecipeEditorIngredientsSection(
        rows: [data('a', 'Mehl'), data('b', 'Wasser')],
        onReorder: (from, to) => moves.add((from, to)),
        onRowChanged: (_) {},
        onRowRemoved: removed.add,
        onAdd: () {},
      ),
      size: const Size(390, 1200),
    );
    final menus = find.byTooltip('Aktionen für Zutat');
    expect(menus, findsNWidgets(2));
    expect(find.byIcon(AppIcons.deleteOutline), findsNothing, reason: 'kein Papierkorb mehr');

    var items = await openMenu(tester, menus.first);
    expect([for (final item in items) entryLabel(item)], ['Nach oben', 'Nach unten', 'Entfernen']);
    expect([for (final item in items) item.enabled], [false, true, true], reason: 'erste Zeile: Nach oben ausgegraut');
    await choose(tester, 'Nach unten');
    expect(moves, [(0, 1)], reason: 'wie Ziehen um eine Stelle');

    items = await openMenu(tester, menus.last);
    expect([for (final item in items) item.enabled], [true, false, true], reason: 'letzte Zeile: Nach unten ausgegraut');
    await choose(tester, 'Nach oben');
    expect(moves, [(0, 1), (1, 0)]);
    await openMenu(tester, menus.last);
    await choose(tester, 'Entfernen');
    expect(removed, ['b']);

    expect(find.widgetWithText(AppSelect<String>, 'Einheit'), findsNWidgets(2), reason: 'Beschriftung „Einheit“');
    final name = tester.getRect(find.widgetWithText(AppTextField, 'Name').first);
    final amount = tester.getRect(find.widgetWithText(AppTextField, 'Menge').first);
    expect(amount.top - name.bottom, AppSpacing.m, reason: 'Zeile 1 zu Zeile 2');
    final menu = tester.getRect(menus.first);
    expect(menu.bottom, name.bottom, reason: 'Menü unten bündig mit dem Feld');
    expect(find.descendant(of: find.byType(IngredientRow).first, matching: find.byType(AppDivider)), findsOneWidget,
        reason: 'Haarlinie unten');
  });

  testWidgets('UI-84: schreibgeschützte Zutatenzeile ohne Menü', (tester) async {
    await _pump(
      tester,
      IngredientRow(
        data: IngredientRowData(id: 'a', displayName: 'Mehl', quantity: Decimal.fromInt(100), unitCode: 'g'),
        onChanged: (_) {},
        onRemove: () {},
        readOnly: true,
      ),
    );
    expect(find.byType(AppOverflowMenu), findsNothing);
  });

  testWidgets('UI-85: Schrittzeile mit Zeilenmenü, Griff, Nummer und Menü unten bündig', (tester) async {
    final moves = <(int, int)>[];
    final removed = <String>[];
    await _pump(
      tester,
      RecipeEditorStepsSection(
        steps: const [StepRowData(id: 'a', instruction: 'Kneten'), StepRowData(id: 'b', instruction: 'Ruhen')],
        onReorder: (from, to) => moves.add((from, to)),
        onInstructionChanged: (_, _) {},
        onTimerChanged: (_, _) {},
        onRemoved: removed.add,
        onAdd: () {},
      ),
      size: const Size(390, 1200),
    );
    final menus = find.byTooltip('Aktionen für Schritt');
    expect(menus, findsNWidgets(2));
    expect(find.byIcon(AppIcons.deleteOutline), findsNothing);

    var items = await openMenu(tester, menus.first);
    expect([for (final item in items) item.enabled], [false, true, true]);
    await choose(tester, 'Nach unten');
    items = await openMenu(tester, menus.last);
    expect([for (final item in items) item.enabled], [true, false, true]);
    await choose(tester, 'Entfernen');
    expect(moves, [(0, 1)]);
    expect(removed, ['b']);

    final row = find.byType(StepRow).first;
    final instruction = tester.getRect(find.widgetWithText(AppTextField, 'Anweisung').first);
    final timer = tester.getRect(find.widgetWithText(AppTextField, 'Timer (Min.)').first);
    final handle = tester.getRect(find.descendant(of: row, matching: find.byIcon(AppIcons.dragHandle)));
    final number = tester.getRect(find.descendant(of: row, matching: find.text('1')));
    expect(tester.getRect(menus.first).bottom, instruction.bottom, reason: 'Menü unten bündig');
    expect(handle.bottom, instruction.bottom - AppSpacing.m, reason: 'Griff space-m über der Feldkante');
    expect(number.bottom, closeTo(instruction.bottom - AppSpacing.m, 0.01), reason: 'Nummer space-m über der Feldkante');
    expect(timer.left, instruction.left, reason: 'Timer eingerückt unter der Anweisung');
    expect(timer.top - instruction.bottom, AppSpacing.m);
    expect(find.descendant(of: row, matching: find.byType(AppDivider)), findsOneWidget, reason: 'Haarlinie unten');
  });
}
