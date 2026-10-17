// test/components/ds23_inputs_test.dart
//
// DS-23 bis DS-25 (Teil 1.2): AppTextField, AppSearchField und AppSelect
// bauen die bisherigen Material-Felder und melden Eingaben.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-23: AppTextField mit Controller, Startwert, Fehler und Hilfe', (tester, variant) async {
    final controller = TextEditingController(text: 'a');
    addTearDown(controller.dispose);
    final changes = <String>[];
    await pumpVariant(
      tester,
      variant,
      ListView(children: [
        AppTextField(controller: controller, label: 'Name', onChanged: changes.add),
        const Row(children: [
          AppTextField(initialValue: '5', label: 'Timer', width: AppFieldWidth.narrow, keyboardType: TextInputType.number),
        ]),
        const AppTextField(label: 'Menge', error: 'Ungültige Zahl'),
        const AppTextField(label: 'Notiz', helper: 'Hinweis', helperTone: AppTone.error),
        const AppTextField(label: 'Aus', enabled: false),
        const AppTextField(label: 'Mehr', maxLines: 3),
      ]),
    );
    expect(find.descendant(of: find.widgetWithText(AppTextField, 'Name'), matching: find.byType(TextField)), findsOneWidget);
    expect(find.descendant(of: find.widgetWithText(AppTextField, 'Timer'), matching: find.byType(TextFormField)), findsOneWidget);
    expect(tester.getSize(find.descendant(of: find.widgetWithText(AppTextField, 'Timer'), matching: find.byType(TextFormField))).width, 120);
    expect(find.text('Ungültige Zahl'), findsOneWidget);
    final helper = tester.widget<Text>(find.text('Hinweis'));
    expect(helper.style?.color, variant.theme.colorScheme.error);
    expect(tester.widget<TextField>(find.descendant(of: find.widgetWithText(AppTextField, 'Aus'), matching: find.byType(TextField))).enabled, isFalse);
    await tester.enterText(find.descendant(of: find.widgetWithText(AppTextField, 'Name'), matching: find.byType(TextField)), 'Brot');
    expect(changes, ['Brot']);
    expect(controller.text, 'Brot');
  });

  testVariants('DS-23: AppTextField füllend mit Rahmen', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [Expanded(child: AppTextField(label: 'Text', expands: true))]),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.expands, isTrue);
    expect(field.maxLines, isNull);
    expect(field.decoration!.border, isA<OutlineInputBorder>());
  });

  testVariants('DS-24: AppSearchField', (tester, variant) async {
    final queries = <String>[];
    await pumpVariant(tester, variant, AppSearchField(hint: 'Suchen …', onChanged: queries.add));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(AppIcons.search), findsOneWidget);
    expect(find.text('Suchen …'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Pi');
    expect(queries, ['Pi']);
  });

  testVariants('DS-25: AppSelect ohne und mit Label', (tester, variant) async {
    final picked = <String>[];
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        AppSelect<String>(
          items: const [AppSelectItem('g', 'g'), AppSelectItem('ml', 'ml')],
          value: 'g',
          onChanged: picked.add,
        ),
        AppSelect<int>(
          label: 'Version',
          items: const [AppSelectItem(1, 'V1'), AppSelectItem(2, 'V2')],
          value: null,
          onChanged: (_) {},
        ),
        AppSelect<String>(items: const [AppSelectItem('x', 'x')], value: 'x', onChanged: null),
      ]),
    );
    expect(find.byType(DropdownButton<String>), findsNWidgets(2));
    expect(find.descendant(of: find.widgetWithText(AppSelect<int>, 'Version'), matching: find.byType(DropdownButtonFormField<int>)), findsOneWidget);
    await tester.tap(find.text('g'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ml').last);
    await tester.pumpAndSettle();
    expect(picked, ['ml']);
    expect(tester.widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>)).last.onChanged, isNull);
  });

  testVariants('DS-23b: Beschriftung über dem Feld, Zahl mit Einheit, Fehler mit Symbol (Teil 1.3)', (tester, variant) async {
    final handle = tester.ensureSemantics();
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppTextField(label: 'Menge', initialValue: '12,5', unit: 'g', keyboardType: TextInputType.number),
        AppTextField(label: 'Titel', error: 'Pflichtfeld'),
      ]),
    );
    final c = variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
    final label = tester.widget<Text>(find.text('Menge')).style!;
    expect(label.fontSize, AppTypography.labelSmall.fontSize);
    expect(label.color, c.textSecondary);
    final field = find.descendant(of: find.widgetWithText(AppTextField, 'Menge'), matching: find.byType(TextField));
    expect(tester.getTopLeft(find.text('Menge')).dy, lessThan(tester.getTopLeft(field).dy), reason: 'Beschriftung über dem Feld');
    expect(find.descendant(of: field, matching: find.text('Menge')), findsNothing, reason: 'nicht schwebend im Feld');
    final input = tester.widget<TextField>(field);
    expect(input.textAlign, TextAlign.end);
    expect(input.style!.fontFeatures, AppTypography.data.fontFeatures);
    expect(input.decoration!.suffixText, 'g');
    expect(input.decoration!.suffixStyle!.color, c.textSecondary);
    // Beschriftung und Wert gehören zum Textfeld.
    expect(tester.getSemantics(field), isSemantics(isTextField: true, value: '12,5'));
    expect(tester.getSemantics(field).getSemanticsData().label, startsWith('Menge'));
    expect(find.byIcon(AppIcons.error), findsOneWidget);
    expect(tester.widget<Text>(find.text('Pflichtfeld')).style!.color, c.textError);
    handle.dispose();
  });

  testVariants('DS-25b: AppSelect mit Beschriftung über dem Feld und chevron (Teil 1.3)', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      AppSelect<int>(label: 'Wahl', items: const [AppSelectItem(1, 'Eins')], value: 1, onChanged: (_) {}),
    );
    final dropdown = find.byType(DropdownButtonFormField<int>);
    expect(tester.getTopLeft(find.text('Wahl')).dy, lessThan(tester.getTopLeft(dropdown).dy));
    expect(find.descendant(of: dropdown, matching: find.byIcon(AppIcons.chevron)), findsOneWidget);
  });
}
