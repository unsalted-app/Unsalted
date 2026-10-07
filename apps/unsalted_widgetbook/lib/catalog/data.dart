// lib/catalog/data.dart
//
// Komponenten: Daten.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „data“.
final dataFolder = WidgetbookFolder(name: 'data', children: [
  component('AppKeyValueTable', [
    useCase('Data/Key Value Table', (_) => const AppKeyValueTable(
          headers: ['Spalte A', 'Spalte B'],
          rows: [
            AppTableRow('Erste Zeile', ['12', '3,4']),
            AppTableRow('davon Teil', ['5', '0,6']),
            AppTableRow('Letzte Zeile mit langer Bezeichnung', ['1,2', '0,1']),
          ],
        )),
  ]),
  component('AppCodeBlock', [
    pageUseCase('Data/Code Block', (_) => Scaffold(
          body: FormSections.fixed(children: [
            Expanded(child: AppCodeBlock('{\n  "format": 1,\n  "items": [\n${'    {"a": 1},\n' * 40}  ]\n}')),
          ]),
        )),
  ]),
]);
