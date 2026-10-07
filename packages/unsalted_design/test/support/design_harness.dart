// test/support/design_harness.dart
//
// Prüfvarianten der Komponenten-Tests (Teil 1.2): hell/dunkel × Handy/Tablet.
// `testVariants` führt denselben Testkörper in allen vier Varianten aus;
// `pump` setzt Fenstergröße und Theme und legt das Widget in eine Seite.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Fenstergrößen der Varianten (logische Pixel).
const variantSizes = {'Handy': Size(390, 844), 'Tablet': Size(1024, 1366)};

/// Eine Prüfvariante.
typedef Variant = ({String name, ThemeData theme, Size size});

/// Alle vier Varianten.
List<Variant> get variants => [
      for (final MapEntry(key: device, value: size) in variantSizes.entries)
        for (final (mode, theme) in [('hell', AppTheme.light()), ('dunkel', AppTheme.dark())])
          (name: '$mode, $device', theme: theme, size: size),
    ];

/// Setzt Fenstergröße und Theme der [variant] und zeigt [child] auf einer
/// Seite (`Scaffold`), damit Material-Widgets ihren Rahmen finden.
Future<void> pumpVariant(WidgetTester tester, Variant variant, Widget child, {bool wrapInPage = true}) async {
  tester.view.physicalSize = variant.size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: variant.theme,
    home: wrapInPage ? Scaffold(body: child) : child,
  ));
}

/// Führt [body] in allen vier Varianten aus.
void testVariants(String description, Future<void> Function(WidgetTester tester, Variant variant) body) {
  for (final variant in variants) {
    testWidgets('$description (${variant.name})', (tester) => body(tester, variant));
  }
}
