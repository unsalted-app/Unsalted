// test/components/ds69_text_field_suffix_test.dart
//
// DS-69 (Teil 1.4 T00b, Figma `Input/Text Field` `showSuffix`): Das Suffix ist
// ein Knopf am Feldende, `size-target` groß und bündig an der Kontur; der Wert
// endet `space-m` davor. Ohne Suffix unverändert.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-69: Suffix am Feldende, Wert endet space-m davor', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      AppTextField(
        label: 'Name',
        initialValue: 'Weizenmehl',
        suffix: AppIconButton(icon: AppIcons.search, tooltip: 'Verknüpfen', onPressed: () {}),
      ),
    );
    final field = tester.getRect(find.byType(InputDecorator));
    final button = tester.getRect(find.byType(AppIconButton));
    final text = tester.getRect(find.byType(EditableText));
    expect(button.size, const Size(AppSize.target, AppSize.target));
    expect(button.right, field.right, reason: 'bündig an der Kontur');
    expect(button.left - text.right, AppSpacing.m, reason: 'Wert endet space-m vor dem Knopf');
  });
}
