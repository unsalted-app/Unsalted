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
    expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Timer'), findsOneWidget);
    expect(tester.getSize(find.widgetWithText(TextFormField, 'Timer')).width, 120);
    expect(find.text('Ungültige Zahl'), findsOneWidget);
    final helper = tester.widget<Text>(find.text('Hinweis'));
    expect(helper.style?.color, variant.theme.colorScheme.error);
    expect(tester.widget<TextField>(find.widgetWithText(TextField, 'Aus')).enabled, isFalse);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Brot');
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
    expect(find.widgetWithText(DropdownButtonFormField<int>, 'Version'), findsOneWidget);
    await tester.tap(find.text('g'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ml').last);
    await tester.pumpAndSettle();
    expect(picked, ['ml']);
    expect(tester.widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>)).last.onChanged, isNull);
  });
}
