// lib/catalog/brand.dart
//
// Markenelemente (Teil 1.3, D07): Zustandsmarke, Zustandsrahmen, Leerstelle,
// Marker, Änderung, Messwert.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „brand“.
final brandFolder = WidgetbookFolder(name: 'brand', children: [
  component('AppMark', [
    useCase('Mark · state', (_) => const Wrap(spacing: AppSpacing.s, runSpacing: AppSpacing.s, children: [
          AppMark(label: 'V3', state: AppMarkState.provisional),
          AppMark(label: 'V2', state: AppMarkState.fixed, seal: true),
          AppMark(label: 'V1 · Basis', state: AppMarkState.highlighted),
        ])),
    useCase('Auswahlziel', (_) => const AppStack(direction: Axis.horizontal, children: [
          AppMark(label: 'V3', state: AppMarkState.provisional, onTap: noop),
          AppMark(label: 'V2', state: AppMarkState.fixed, selected: true, onTap: noop),
          AppMark(label: 'V1', state: AppMarkState.highlighted, onTap: noop),
        ])),
  ]),
  component('AppFrame', [
    useCase('Frame · state', (_) => const AppStack(gap: AppSpace.m, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppFrame.provisional(
            mark: AppMark(label: 'V4', state: AppMarkState.provisional),
            caption: 'Entwurf · offen',
            child: Text('Inhalt des Arbeitsstands'),
          ),
          AppFrame.fixed(
            mark: AppMark(label: 'V3', state: AppMarkState.fixed, seal: true),
            caption: 'fest seit 09.10.2026',
            child: Text('Inhalt des festen Stands'),
          ),
        ])),
  ]),
  component('AppSlot', [
    useCase('Slot', (_) => const AppSlot(
          icon: AppIcons.photo,
          message: 'Noch kein Bild.',
          action: AppButton.secondary(label: 'Bild hinzufügen', onPressed: noop),
        )),
    useCase('ohne Punktraster', (_) => const AppSlot(message: 'Keine Treffer.', pattern: false)),
  ]),
  component('AppDashedUnderline', [
    useCase('nicht verknüpft', (_) => const AppDashedUnderline(child: Text('Eintrag ohne Verknüpfung'))),
  ]),
  component('AppHighlight', [
    useCase('Highlight', (_) => const AppHighlight('390 g')),
  ]),
  component('AppChangeText', [
    useCase('Change', (_) => const AppStack(gap: AppSpace.s, children: [
          AppChangeText(semanticLabel: 'Eins: 500 g → 550 g', subject: 'Eins:', before: '500 g', after: '550 g'),
          AppChangeText(semanticLabel: 'Zwei hinzugefügt (5 g)', subject: 'Zwei', after: '5 g'),
          AppChangeText(semanticLabel: 'Drei entfernt', subject: 'Drei', before: '20 g'),
          AppChangeText(semanticLabel: 'Vier: anders verknüpft', subject: 'Vier:', note: 'anders verknüpft'),
        ])),
  ]),
  component('AppValue', [
    useCase('Value · certainty', (_) => const AppStack(gap: AppSpace.s, children: [
          AppValue(value: '1,80', unit: 'g'),
          AppValue(value: '0', unit: 'g', certainty: AppCertainty.unknown),
          AppValue.strong(value: '343', unit: 'g', certainty: AppCertainty.incomplete),
          AppValue.display(value: '3.500', unit: 'x'),
        ])),
  ]),
]);
