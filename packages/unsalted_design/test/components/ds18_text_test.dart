// test/components/ds18_text_test.dart
//
// DS-18 (Teil 1.2): AppText — Rollen und Farbtöne kommen aus dem Theme;
// `body` ohne Ton ist ein schlichter Text ohne eigenen Stil.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-18: Rollen und Töne', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppText('Fließ'),
        AppText.strong('Fett'),
        AppText.title('Titel'),
        AppText.caption('Klein', tone: AppTone.muted),
        AppText('Fehler', tone: AppTone.error),
        AppText('Lang', maxLines: 1),
      ]),
    );
    Text text(String s) => tester.widget<Text>(find.text(s));
    final scheme = variant.theme.colorScheme;
    final textTheme = Theme.of(tester.element(find.text('Fließ'))).textTheme;
    expect(text('Fließ').style, isNull);
    expect(text('Fett').style!.fontWeight, FontWeight.bold);
    expect(text('Titel').style, textTheme.titleMedium);
    expect(text('Klein').style!.fontSize, textTheme.bodySmall!.fontSize);
    expect(text('Klein').style!.color, scheme.onSurfaceVariant);
    expect(text('Fehler').style!.color, scheme.error);
    expect(text('Lang').overflow, TextOverflow.ellipsis);
  });
}
