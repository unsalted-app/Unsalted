// test/localization_test.dart
//
// APP-03 (Teil 1.3, D17b, F2): Die Systemtexte der Bedienelemente sind
// deutsch — Sprache der App `de`, `MaterialLocalizations` liefern „Zurück“
// und die deutschen Bedienhilfe-Aktionen beim Umsortieren.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_app/main.dart';
import 'package:unsalted_core/unsalted_core.dart';
import 'support/db_teardown.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }
}

void main() {
  testWidgets('APP-03: Systemtexte deutsch', (tester) async {
    final database = (await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory())))!;
    addTearDown(() => closeTestDatabase(tester, database));
    final modules = <UnsaltedModule>[CoreModule()];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        coreDatabaseProvider.overrideWithValue(database),
        modulesProvider.overrideWithValue(modules),
      ],
      child: UnsaltedApp(modules: modules),
    ));
    await _settle(tester);

    final context = tester.element(find.text('Noch keine Rezepte.'));
    expect(Localizations.localeOf(context), const Locale('de'));
    final texts = MaterialLocalizations.of(context);
    expect(texts.backButtonTooltip, 'Zurück');
    final widgets = WidgetsLocalizations.of(context);
    expect(widgets.reorderItemUp, 'Nach oben verschieben');
    expect(widgets.reorderItemDown, 'Nach unten verschieben');
    expect(texts.licensesPageTitle, 'Lizenzen');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
