// test/components/ds20b_surface_tones_test.dart
//
// DS-20b (Teil 1.2, C22): AppSurface mit den Tönen info, warning und error —
// Fläche aus den container-Rollen, Text im Inhalt in der passenden
// on…Container-Rolle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-20b: Hinweistöne färben Fläche und Inhalt', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppSurface(key: Key('info'), tone: AppSurfaceTone.info, child: Text('Info')),
        AppSurface(key: Key('warning'), tone: AppSurfaceTone.warning, child: Text('Warnung')),
        AppSurface(key: Key('error'), tone: AppSurfaceTone.error, child: Text('Fehler')),
        AppSurface(key: Key('plain'), child: Text('Schlicht')),
      ]),
    );
    final scheme = variant.theme.colorScheme;
    Color background(String key) => tester
        .widget<ColoredBox>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(ColoredBox)))
        .color;
    Color? textColor(String text) => DefaultTextStyle.of(tester.element(find.text(text))).style.color;

    expect(background('info'), scheme.secondaryContainer);
    expect(background('warning'), scheme.tertiaryContainer);
    expect(background('error'), scheme.errorContainer);
    expect(textColor('Info'), scheme.onSecondaryContainer);
    expect(textColor('Warnung'), scheme.onTertiaryContainer);
    expect(textColor('Fehler'), scheme.onErrorContainer);
    expect(textColor('Schlicht'), isNot(scheme.onErrorContainer));
    expect(find.byType(Icon), findsNothing, reason: 'ohne Symbol, anders als AppNotice');
  });
}
