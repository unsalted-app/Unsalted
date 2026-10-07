// lib/catalog/tokens.dart
//
// Tokens: Farben je Modus, Typo, Abstände, Radien, Höhen.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

Widget _colorTable(AppColorTokens tokens) => AppStack(
      gap: AppSpace.xs,
      children: [
        for (final MapEntry(key: name, value: color) in tokens.byFigmaName.entries)
          AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
            SizedBox.square(dimension: 24, child: ColoredBox(color: color)),
            Expanded(child: Text('$name  #${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}')),
          ]),
      ],
    );

/// Ordner „Tokens“.
final tokensFolder = WidgetbookFolder(name: 'Tokens', children: [
  component('Farbe', [
    useCase('light', (_) => _colorTable(AppColorTokens.light)),
    useCase('dark', (_) => _colorTable(AppColorTokens.dark)),
  ]),
  component('Typografie', [
    useCase('type', (_) => AppStack(gap: AppSpace.s, children: [
          for (final MapEntry(key: name, value: style) in AppTypography.byFigmaName.entries) Text(name, style: style),
        ])),
  ]),
  component('Abstand, Radius, Höhe', [
    useCase('space', (context) => AppStack(gap: AppSpace.s, children: [
          for (final MapEntry(key: name, value: value) in AppSpacing.byFigmaName.entries)
            AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
              SizedBox(width: value * 4, height: 12, child: ColoredBox(color: Theme.of(context).colorScheme.outline)),
              Expanded(child: Text('$name = $value')),
            ]),
        ])),
    useCase('radius', (context) => Wrap(spacing: 12, runSpacing: 12, children: [
          for (final MapEntry(key: name, value: value) in AppRadius.byFigmaName.entries)
            Container(
              width: 96,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(value),
              ),
              child: Text(name.split('/').last),
            ),
        ])),
    useCase('elevation', (_) => Wrap(spacing: 16, runSpacing: 16, children: [
          for (final MapEntry(key: name, value: value) in AppElevation.byFigmaName.entries)
            Material(
              elevation: value,
              borderRadius: BorderRadius.circular(AppRadius.m),
              child: SizedBox(width: 120, height: 64, child: Center(child: Text(name.split('/').last))),
            ),
        ])),
  ]),
]);
