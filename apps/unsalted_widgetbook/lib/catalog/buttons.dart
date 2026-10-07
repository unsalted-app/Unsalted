// lib/catalog/buttons.dart
//
// Komponenten: Schaltflächen.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „buttons“.
final buttonsFolder = WidgetbookFolder(name: 'buttons', children: [
  component('AppButton', [
    useCase('Button/Primary', (_) => const AppButton.primary(label: 'Speichern', onPressed: noop)),
    useCase('Button/Secondary', (_) => const AppButton.secondary(label: 'Einfrieren', onPressed: noop)),
    useCase('Button/Tertiary', (_) => const AppButton.tertiary(label: 'Abbrechen', onPressed: noop)),
    useCase('mit Symbol', (_) => const AppStack(gap: AppSpace.s, children: [
          AppButton.primary(label: 'Hinzufügen', icon: AppIcons.add, onPressed: noop),
          AppButton.secondary(label: 'Hinzufügen', icon: AppIcons.add, onPressed: noop),
          AppButton.tertiary(label: 'Hinzufügen', icon: AppIcons.add, onPressed: noop),
        ])),
    useCase('deaktiviert', (_) => const AppStack(gap: AppSpace.s, children: [
          AppButton.primary(label: 'Speichern', onPressed: null),
          AppButton.secondary(label: 'Einfrieren', onPressed: null),
          AppButton.tertiary(label: 'Abbrechen', onPressed: null),
        ])),
  ]),
  component('AppIconButton', [
    useCase('Button/Icon', (_) => const AppStack(direction: Axis.horizontal, children: [
          AppIconButton(icon: AppIcons.edit, tooltip: 'Bearbeiten', onPressed: noop),
          AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: noop),
          AppIconButton(icon: AppIcons.deleteOutline, tooltip: 'Entfernen', onPressed: null),
        ])),
  ]),
  component('AppFab', [
    useCase('Button/FAB', (_) => const AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: noop)),
    useCase('lädt', (_) => const AppFab(icon: AppIcons.check, tooltip: 'Speichern', loading: true, onPressed: noop)),
  ]),
]);
