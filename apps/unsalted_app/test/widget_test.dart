// test/widget_test.dart
//
// Schritt 8.8: App-Start mit In-Memory-Datenbank. Die Rezeptliste erscheint,
// die Navigation zu /foods und /settings funktioniert.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_app/main.dart';
import 'package:unsalted_core/unsalted_core.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }
}

void main() {
  testWidgets('App startet mit der Rezeptliste und navigiert zu /foods und /settings',
      (tester) async {
    final database = (await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory())))!;
    addTearDown(() => tester.runAsync(database.close));

    final modules = <UnsaltedModule>[CoreModule()];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        coreDatabaseProvider.overrideWithValue(database),
        modulesProvider.overrideWithValue(modules),
      ],
      child: UnsaltedApp(modules: modules),
    ));
    await _settle(tester);

    expect(find.text('Noch keine Rezepte.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.restaurant));
    await _settle(tester);
    expect(find.text('Noch keine Rezepte.'), findsNothing);
    expect(find.text('Eigenes Produkt anlegen'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await _settle(tester);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Über unsalted'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu_book));
    await _settle(tester);
    expect(find.text('Noch keine Rezepte.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
