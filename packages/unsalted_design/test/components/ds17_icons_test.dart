// test/components/ds17_icons_test.dart
//
// DS-17 (Teil 1.2): AppIcon setzt Größe und Farbton; AppIcons führt jedes
// Symbol unter einem Figma-Namen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  test('DS-17: Figma-Namen der Symbole', () {
    expect(AppIcons.byFigmaName.keys.every((k) => RegExp(r'^Icon/[a-z]+(-[a-z]+)*$').hasMatch(k)), isTrue);
    expect(AppIcons.byFigmaName.values.toSet(), hasLength(AppIcons.byFigmaName.length));
  });

  testVariants('DS-17: AppIcon Größe, Ton und Screenreader-Text', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Row(children: [
        AppIcon(AppIcons.info, key: Key('m')),
        AppIcon(AppIcons.star, key: Key('l'), size: AppIconSize.l, tone: AppTone.primary, semanticLabel: 'Markiert'),
      ]),
    );
    expect(tester.getSize(find.byKey(const Key('m'))), const Size(24, 24));
    expect(tester.getSize(find.byKey(const Key('l'))), const Size(48, 48));
    final star = tester.widget<Icon>(find.byIcon(AppIcons.star));
    expect(star.color, variant.theme.colorScheme.primary);
    expect(find.bySemanticsLabel('Markiert'), findsOneWidget);
  });
}
