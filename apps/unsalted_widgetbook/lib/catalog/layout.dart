// lib/catalog/layout.dart
//
// Layout: AppStack/AppGap/AppPadding, AppSection, AppGrid, AppPage,
// ResponsiveBuilder.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

Widget _box(String label) => AppSurface(child: Text(label));

/// Ordner „Layout“.
final layoutFolder = WidgetbookFolder(name: 'Layout', children: [
  component('AppStack', [
    useCase('Layout/Stack vertical', (_) => AppStack(gap: AppSpace.m, children: [_box('Eins'), _box('Zwei')])),
    useCase('Layout/Stack horizontal', (_) => AppStack(
          direction: Axis.horizontal,
          gap: AppSpace.s,
          children: [_box('Eins'), const AppGap(AppSpace.xl), _box('Zwei')],
        )),
    useCase('AppPadding', (_) => AppSurface(child: AppPadding.symmetric(horizontal: AppSpace.xl, child: _box('Innen')))),
  ]),
  component('AppSection', [
    useCase('Layout/Section', (_) => AppStack(children: [
          const AppSection(divider: false, title: 'Erster Abschnitt', children: [Text('Inhalt')]),
          const AppSection(title: 'Zweiter Abschnitt', children: [Text('Inhalt')]),
        ])),
  ]),
  component('AppGrid', [
    useCase('Layout/Grid', (_) => AppGrid(itemCount: 7, itemBuilder: (context, i) => _box('Element ${i + 1}'))),
  ]),
  component('ResponsiveBuilder', [
    useCase('breakpoint', (_) => ResponsiveBuilder(
          builder: (context, size) => AppText.title('Fenstergröße: ${size.name}, Rasterspalten: ${size.gridColumns}'),
        )),
  ]),
  component('AppPage', [
    pageUseCase('Layout/Page', (_) => AppPage(
          topBar: const AppTopBar(title: 'Seite'),
          body: const Center(child: Text('Inhalt')),
          primaryAction: const AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: noop),
        )),
  ]),
]);
