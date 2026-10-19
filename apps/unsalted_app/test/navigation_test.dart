// test/navigation_test.dart
//
// APP-04 (Teil 1.3, D17, F4): Die Hauptnavigation steht unter
// `breakpoint-medium` unten, ab `breakpoint-medium` als seitliche Leiste
// links (`size-nav-rail`), mit denselben drei Zielen; Tippen wechselt in
// beiden Formen das Ziel.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_app/main.dart';
import 'package:unsalted_core/unsalted_core.dart';
import 'package:unsalted_design/unsalted_design.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }
}

void main() {
  for (final size in const [Size(390, 844), Size(1024, 1366), Size(844, 390)]) {
    testWidgets('APP-04: Navigation bei ${size.width.toInt()} × ${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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

      final bar = tester.widget<AppNavigationBar>(find.byType(AppNavigationBar));
      final rect = tester.getRect(find.byType(AppNavigationBar));
      if (size.width < AppBreakpoints.medium) {
        expect(bar.rail, isFalse);
        expect(rect.bottom, size.height, reason: 'unten');
        expect(rect.width, size.width);
      } else {
        expect(bar.rail, isTrue);
        expect((rect.left, rect.width), (0, AppSize.navRail), reason: 'links, size-nav-rail');
        expect(tester.getTopLeft(find.text('Noch keine Rezepte.')).dx, greaterThan(AppSize.navRail));
      }
      for (final label in ['Rezepte', 'Lebensmittel', 'Einstellungen']) {
        expect(find.descendant(of: find.byType(AppNavigationBar), matching: find.text(label)), findsOneWidget);
      }

      await tester.tap(find.byIcon(AppIcons.settings));
      await _settle(tester);
      expect(find.text('Über unsalted'), findsOneWidget);
      expect(tester.widget<AppNavigationBar>(find.byType(AppNavigationBar)).selectedIndex, 2);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    });
  }
}
