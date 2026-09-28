// test/module/core_module_test.dart
//
// Schritt 7.2: prüft id, Tabellenliste und immutableAfterCreate (Kapitel 21,
// Arbeitskarte §10).

import 'package:test/test.dart';

import 'package:unsalted_core/src/module/core_module.dart';

void main() {
  test('CoreModule.id ist "core"', () {
    expect(const CoreModule().id, 'core');
  });

  test('CoreModule.syncTables enthält genau die fünf Teil-1-Tabellen', () {
    final tables = const CoreModule().syncTables.map((t) => t.tableName).toList();
    expect(tables, [
      'recipes',
      'recipe_versions',
      'recipe_ingredients',
      'recipe_steps',
      'food_variants',
    ]);
  });

  test(
      'immutableAfterCreate ist bei recipes false, bei den vier '
      'zutatenbezogenen Tabellen true', () {
    final byTable = {
      for (final t in const CoreModule().syncTables) t.tableName: t.immutableAfterCreate,
    };

    expect(byTable['recipes'], isFalse);
    expect(byTable['recipe_versions'], isTrue);
    expect(byTable['recipe_ingredients'], isTrue);
    expect(byTable['recipe_steps'], isTrue);
    expect(byTable['food_variants'], isTrue);
  });

  test('CoreModule liefert für Phase 1 leere Routen- und Steckplatzlisten', () {
    const module = CoreModule();
    expect(module.routes, isEmpty);
    expect(module.recipeDetailSections, isEmpty);
    expect(module.recipeActions, isEmpty);
    expect(module.settingsEntries, isEmpty);
  });
}
