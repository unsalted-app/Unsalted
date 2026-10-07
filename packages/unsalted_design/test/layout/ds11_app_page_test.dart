// test/layout/ds11_app_page_test.dart
//
// DS-11 (Teil 1.2): AppPage baut ein Scaffold mit Kopfleiste, Inhalt,
// Hauptaktion und Fußleiste.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-11: AppPage zeigt alle Bereiche', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      AppPage(
        topBar: AppBar(title: const Text('Kopf')),
        body: const Text('Inhalt'),
        primaryAction: FloatingActionButton(onPressed: () {}, child: const Text('Aktion')),
        bottomBar: const SizedBox(height: 40, child: Text('Fuß')),
      ),
      wrapInPage: false,
    );
    expect(find.byType(Scaffold), findsOneWidget);
    for (final text in ['Kopf', 'Inhalt', 'Aktion', 'Fuß']) {
      expect(find.text(text), findsOneWidget);
    }
  });
}
