// test/ui/settings/settings_screen_test.dart
//
// Schritt 8.7, Bildschirm 13: EX-03 (ein SettingsEntry aus einem
// Test-Modul erscheint in den Einstellungen -- bei Schritt 8.5 noch nicht
// testbar, siehe docs/status.md), feste Einträge navigieren zu Export/
// Import.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/module/extension_types.dart';
import 'package:unsalted_core/src/module/unsalted_module.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/settings/export_screen.dart';
import 'package:unsalted_core/src/ui/settings/import_screen.dart';
import 'package:unsalted_core/src/ui/settings/settings_screen.dart';

class _FakeModule implements UnsaltedModule {
  final List<SettingsEntry> entries;
  const _FakeModule({this.entries = const []});

  @override
  String get id => 'fake';
  @override
  List<RouteBase> get routes => const [];
  @override
  List<RecipeDetailSection> get recipeDetailSections => const [];
  @override
  List<RecipeAction> get recipeActions => const [];
  @override
  List<SettingsEntry> get settingsEntries => entries;
  @override
  List<SyncTableSpec> get syncTables => const [];
}

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// Schließt [database] im Teardown, auch wenn der Test vorher scheitert
/// (Teil 1.1d). Nach einem roten Test lässt flutter_test den Widget-Baum stehen,
/// und Drift wartet beim Schließen auf seine Abbestell-Timer in der Fake-Zone,
/// die dann niemand mehr auspumpt -- der Lauf hinge. Deshalb erst den Baum
/// abbauen und auspumpen, dann schließen.
Future<void> _closeDatabase(WidgetTester tester, db.CoreDatabase database) async {
  await _disposeWidgetTree(tester);
  await tester.runAsync(database.close);
}

void main() {
  testWidgets('EX-03: ein SettingsEntry eines Test-Moduls erscheint in den Einstellungen',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    var tapped = false;
    final module = _FakeModule(entries: [
      SettingsEntry(
        id: 'entry1',
        order: 1,
        title: 'Testeintrag',
        subtitle: 'Untertitel',
        onTap: (context) => tapped = true,
      ),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        coreDatabaseProvider.overrideWithValue(database),
        modulesProvider.overrideWithValue([module]),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pump();

    expect(find.text('Testeintrag'), findsOneWidget);
    expect(find.text('Untertitel'), findsOneWidget);

    await tester.tap(find.text('Testeintrag'));
    await tester.pump();
    expect(tapped, isTrue);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Export-Eintrag öffnet ExportScreen', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pump();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.byType(ExportScreen), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('Import-Eintrag öffnet ImportScreen', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pump();

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.byType(ImportScreen), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('ohne registrierte Module bleibt die Seite funktionsfähig (EX-05)', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pump();

    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Über unsalted'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeWidgetTree(tester);
  });
}
