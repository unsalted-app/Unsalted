// test/ui/config/core_ui_options_test.dart
//
// UC-01 bis UC-06 (Teil 1.2, C29): Anzeige-Schalter auf Baustein-Ebene —
// Nährwerttabelle und Verpackungsformular. Ausgeblendet heißt nicht
// gelöscht. Die Bildschirm-Verdrahtung über coreUiOptionsProvider prüft
// core_ui_options_screens_test.dart.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_result.dart';
import 'package:unsalted_core/src/ui/config/core_ui_options.dart';
import 'package:unsalted_core/src/ui/foods/package_form.dart';
import 'package:unsalted_core/src/ui/nutrition/nutrition_table.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_parameters_section.dart';

Decimal d(String v) => Decimal.parse(v);

const _nutrientLabels = [
  'Kalorien (kcal)',
  'Fett (g)',
  'davon gesättigte Fettsäuren (g)',
  'Kohlenhydrate (g)',
  'davon Zucker (g)',
  'Ballaststoffe (g)',
  'Eiweiß (g)',
  'Salz (g)',
];

NutritionResult _result({Set<String> incomplete = const {}}) {
  final set = NutrientSet(
    energyKcal: d('250'),
    fatG: d('10'),
    saturatedFatG: d('4'),
    carbsG: d('30'),
    sugarsG: d('5'),
    fiberG: d('3'),
    proteinG: d('8'),
    saltG: d('1.2'),
  );
  return NutritionResult(
    rawWeightG: d('100'),
    finalWeightG: d('100'),
    total: set,
    per100g: set,
    perServing: null,
    incomplete: incomplete,
    notCalculable: const [],
    hasAnyNutrition: true,
  );
}

final PackageFormValue _initial = (
  name: 'Haferflocken',
  brand: 'Mühle',
  barcode: '4001234567890',
  densityGPerMl: d('0.4'),
  gramsPerPiece: d('50'),
  servingSizeG: d('40'),
  nutrients: NutrientSet(
    energyKcal: d('370'),
    fatG: d('7'),
    saturatedFatG: d('1.3'),
    carbsG: d('59'),
    sugarsG: d('1'),
    fiberG: d('10'),
    proteinG: d('13'),
    saltG: d('0.02'),
  ),
);

Future<GlobalKey<PackageFormState>> _pumpForm(
  WidgetTester tester, {
  PackageFormValue? initial,
  CoreUiOptions options = const CoreUiOptions(),
}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final key = GlobalKey<PackageFormState>();
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: PackageForm(key: key, initial: initial ?? _initial, options: options)),
  ));
  return key;
}

Future<void> _pumpTable(WidgetTester tester, NutritionResult result, CoreUiOptions options) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: NutritionTable(result: result, options: options))));

void main() {
  group('UC-01: Standardwerte = Verhalten vor Teil 1.2', () {
    test('Werte und showsNutrient', () {
      const options = CoreUiOptions();
      expect(options.hiddenNutrients, isEmpty);
      expect(options.showBarcodeField, isTrue);
      expect(options.showAdvancedFields, isTrue);
      for (final key in ['energy_kcal', 'fat_g', 'saturated_fat_g', 'carbs_g', 'sugars_g', 'fiber_g', 'protein_g', 'salt_g']) {
        expect(options.showsNutrient(key), isTrue, reason: key);
      }
      expect(const CoreUiOptions(), const CoreUiOptions(hiddenNutrients: <String>{}));
      expect(const CoreUiOptions(hiddenNutrients: {'fiber_g'}), isNot(const CoreUiOptions()));
    });

    testWidgets('Tabelle und Formular zeigen alles', (tester) async {
      await _pumpTable(tester, _result(), const CoreUiOptions());
      for (final label in _nutrientLabels) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      await _pumpForm(tester);
      for (final label in [
        'Name', 'Marke', 'Barcode', 'Dichte (g/ml)', 'Stückgewicht (g)', 'Portionsgröße (g)', //
        ..._nutrientLabels, 'oder: Natrium (mg)',
      ]) {
        expect(find.widgetWithText(AppTextField, label), findsOneWidget, reason: label);
      }
    });

    testWidgets('Parameter des Editors vollständig', (tester) async {
      final controllers = List.generate(4, (_) => TextEditingController());
      addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RecipeEditorParametersSection(
            servings: controllers[0],
            bakingLoss: controllers[1],
            finalWeight: controllers[2],
            notes: controllers[3],
            onChanged: () {},
          ),
        ),
      ));
      for (final label in ['Portionen', 'Backverlust (%)', 'Fertiggewicht-Override (g)', 'Notizen']) {
        expect(find.widgetWithText(AppTextField, label), findsOneWidget, reason: label);
      }
    });
  });

  testWidgets('UC-02: ausgeblendeter Nährwert fehlt in Tabelle und Fußnoten', (tester) async {
    await _pumpTable(
      tester,
      _result(incomplete: {'fiber_g', 'sugars_g'}),
      const CoreUiOptions(hiddenNutrients: {'fiber_g'}),
    );
    expect(find.text('Ballaststoffe (g)'), findsNothing);
    expect(find.textContaining('Ballaststoffe (g): unvollständig'), findsNothing);
    expect(find.textContaining('davon Zucker (g): unvollständig'), findsOneWidget);
    for (final label in _nutrientLabels.where((l) => l != 'Ballaststoffe (g)')) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await _pumpTable(tester, _result(incomplete: {'fiber_g'}), const CoreUiOptions(hiddenNutrients: {'fiber_g'}));
    expect(find.textContaining('unvollständig'), findsNothing, reason: 'keine Fußnote nur für Ausgeblendetes');
  });

  testWidgets('UC-03: kcal lässt sich nicht ausblenden, unbekannte Schlüssel wirken nicht', (tester) async {
    const options = CoreUiOptions(hiddenNutrients: {'energy_kcal', 'unbekannt'});
    expect(options.showsNutrient('energy_kcal'), isTrue);
    await _pumpTable(tester, _result(), options);
    for (final label in _nutrientLabels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await _pumpForm(tester, options: options);
    expect(find.widgetWithText(AppTextField, 'Kalorien (kcal)'), findsOneWidget);
  });

  testWidgets('UC-04: Barcode ausgeblendet, Wert bleibt erhalten', (tester) async {
    final key = await _pumpForm(tester, options: const CoreUiOptions(showBarcodeField: false));
    expect(find.widgetWithText(AppTextField, 'Barcode'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Marke'), findsOneWidget);
    expect(key.currentState!.value!.barcode, '4001234567890');
  });

  testWidgets('UC-05: erweiterte Felder ausgeblendet, Werte bleiben erhalten', (tester) async {
    final key = await _pumpForm(tester, options: const CoreUiOptions(showAdvancedFields: false));
    for (final label in ['Dichte (g/ml)', 'Stückgewicht (g)', 'Portionsgröße (g)', 'oder: Natrium (mg)']) {
      expect(find.widgetWithText(AppTextField, label), findsNothing, reason: label);
    }
    expect(find.widgetWithText(AppTextField, 'Salz (g)'), findsOneWidget);
    final value = key.currentState!.value!;
    expect(value.densityGPerMl, d('0.4'));
    expect(value.gramsPerPiece, d('50'));
    expect(value.servingSizeG, d('40'));

    final controllers = List.generate(4, (_) => TextEditingController(text: '10'));
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RecipeEditorParametersSection(
          servings: controllers[0],
          bakingLoss: controllers[1],
          finalWeight: controllers[2],
          notes: controllers[3],
          onChanged: () {},
          showAdvanced: false,
        ),
      ),
    ));
    expect(find.widgetWithText(AppTextField, 'Backverlust (%)'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Fertiggewicht-Override (g)'), findsNothing);
    expect(find.widgetWithText(AppTextField, 'Portionen'), findsOneWidget);
    expect(controllers[1].text, '10');
  });

  group('UC-06: ausgeblendeter Nährwert im Formular', () {
    testWidgets('Wert bleibt erhalten, Salz aus blendet auch Natrium aus', (tester) async {
      final key = await _pumpForm(tester, options: const CoreUiOptions(hiddenNutrients: {'fiber_g', 'salt_g'}));
      expect(find.widgetWithText(AppTextField, 'Ballaststoffe (g)'), findsNothing);
      expect(find.widgetWithText(AppTextField, 'Salz (g)'), findsNothing);
      expect(find.widgetWithText(AppTextField, 'oder: Natrium (mg)'), findsNothing);
      final nutrients = key.currentState!.value!.nutrients;
      expect(nutrients.fiberG, d('10'));
      expect(nutrients.saltG, d('0.02'));
    });

    testWidgets('Warnungen zu ausgeblendeten Feldern entfallen, andere bleiben', (tester) async {
      final initial = (
        name: 'Test',
        brand: null,
        barcode: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        // Zucker > Kohlenhydrate (Warnung ohne Ballaststoffe) und
        // Fett + KH + Eiweiß + Ballaststoffe > 100 g (Warnung mit Ballaststoffen).
        nutrients: NutrientSet(fatG: d('40'), carbsG: d('30'), sugarsG: d('35'), proteinG: d('20'), fiberG: d('20')),
      );
      await _pumpForm(tester, initial: initial);
      expect(find.byKey(const Key('package_form_warning')), findsNWidgets(2));

      await _pumpForm(tester, initial: initial, options: const CoreUiOptions(hiddenNutrients: {'fiber_g'}));
      expect(find.byKey(const Key('package_form_warning')), findsOneWidget);
      expect(find.text('Zucker ist größer als der Gesamtkohlenhydratgehalt.'), findsOneWidget);
    });

    testWidgets('negativer Wert in einem ausgeblendeten Feld blendet es ein und blockiert', (tester) async {
      final initial = (
        name: 'Test',
        brand: null,
        barcode: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: NutrientSet(fiberG: d('-1')),
      );
      final key = await _pumpForm(tester, initial: initial, options: const CoreUiOptions(hiddenNutrients: {'fiber_g'}));
      expect(find.widgetWithText(AppTextField, 'Ballaststoffe (g)'), findsOneWidget);
      expect(find.byKey(const Key('package_form_error')), findsOneWidget);
      expect(key.currentState!.value, isNull);
    });
  });
}
