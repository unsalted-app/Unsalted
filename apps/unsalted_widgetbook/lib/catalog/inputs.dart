// lib/catalog/inputs.dart
//
// Komponenten: Eingaben.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „inputs“.
final inputsFolder = WidgetbookFolder(name: 'inputs', children: [
  component('AppTextField', [
    useCase('Input/Text Field', (_) => const AppStack(gap: AppSpace.s, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppTextField(label: 'Titel'),
          AppTextField(label: 'Mit Startwert', initialValue: 'Brot'),
          AppTextField(label: 'Beschreibung', maxLines: 4),
          AppTextField(label: 'Menge', error: 'Ungültige Zahl'),
          AppTextField(label: 'Name', helper: 'Verknüpfung fehlt – bitte neu auswählen.', helperTone: AppTone.error),
          AppTextField(label: 'Gesperrt', initialValue: 'fest', enabled: false),
          AppTextField(label: 'Mit Aktion', suffix: AppIconButton(icon: AppIcons.search, tooltip: 'Suchen', onPressed: noop)),
          Row(children: [AppTextField(label: 'Schmal', width: AppFieldWidth.narrow, keyboardType: TextInputType.number)]),
        ])),
    pageUseCase('füllend (expands)', (_) => const Scaffold(
          body: FormSections.fixed(children: [Expanded(child: AppTextField(label: 'Text einfügen', expands: true))]),
        )),
  ]),
  component('AppSearchField', [
    useCase('Input/Search', (_) => const AppSearchField(hint: 'Suchen …')),
  ]),
  component('AppSelect', [
    useCase('Input/Select ohne Label', (_) => AppSelect<String>(
          items: const [AppSelectItem('g', 'g'), AppSelectItem('ml', 'ml'), AppSelectItem('Stück', 'Stück')],
          value: 'g',
          onChanged: (_) {},
        )),
    useCase('Input/Select mit Label', (_) => AppSelect<int>(
          label: 'Version',
          items: const [AppSelectItem(1, 'V1'), AppSelectItem(2, 'V2')],
          value: 1,
          onChanged: (_) {},
        )),
  ]),
]);
