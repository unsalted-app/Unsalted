// test/theme_test.dart
//
// APP-02 (Teil 1.2, C26): Die App nutzt die Themes aus unsalted_design —
// hell und dunkel — und folgt der Systemeinstellung (Antwort F4); die
// Hauptnavigation ist die AppNavigationBar mit drei Zielen.

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
  for (final brightness in Brightness.values) {
    testWidgets('APP-02: Theme aus unsalted_design folgt dem System (${brightness.name})', (tester) async {
      final database = (await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory())))!;
      addTearDown(() => tester.runAsync(database.close));
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final modules = <UnsaltedModule>[CoreModule()];
      await tester.pumpWidget(ProviderScope(
        overrides: [
          coreDatabaseProvider.overrideWithValue(database),
          modulesProvider.overrideWithValue(modules),
        ],
        child: UnsaltedApp(modules: modules),
      ));
      await _settle(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme!.colorScheme.primary, AppTheme.light().colorScheme.primary);
      expect(app.darkTheme!.colorScheme.primary, AppTheme.dark().colorScheme.primary);
      expect(app.themeMode, ThemeMode.system);

      final theme = Theme.of(tester.element(find.text('Noch keine Rezepte.')));
      expect(theme.brightness, brightness);
      final expected = brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
      expect(theme.colorScheme.surface, expected.surface);

      expect(find.byType(AppNavigationBar), findsOneWidget);
      for (final label in ['Rezepte', 'Lebensmittel', 'Einstellungen']) {
        expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    });
  }
}
