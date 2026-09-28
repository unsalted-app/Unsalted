// test/module/unsalted_module_test.dart
//
// Schritt 7.1: Compile-Test der Modultypen (Kapitel 21). Prüft, dass alle
// Typen mit exakt den vorgesehenen Feldern/Signaturen kompilieren und ein
// UnsaltedModule vollständig implementierbar ist. Kein Widget-Rendering
// nötig -- die Funktionswerte (`build`, `onPressed`, `onTap`, `isEnabled`)
// werden nur zugewiesen, nicht aufgerufen, weil dafür ein echter
// BuildContext/WidgetRef nötig wäre (Sache der UI, Phase 8).

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/module/extension_types.dart';
import 'package:unsalted_core/src/module/unsalted_module.dart';

Widget _buildSection(BuildContext context, RecipeContext ctx) => const Placeholder();
bool _isEnabled(RecipeContext ctx) => true;
void _onPressed(BuildContext context, RecipeContext ctx) {}
void _onTap(BuildContext context) {}

class _FakeModule implements UnsaltedModule {
  @override
  String get id => 'fake';

  @override
  List<RouteBase> get routes => const [];

  @override
  List<RecipeDetailSection> get recipeDetailSections => const [
        RecipeDetailSection(id: 'sec1', order: 1, build: _buildSection),
      ];

  @override
  List<RecipeAction> get recipeActions => [
        RecipeAction(
          id: 'act1',
          order: 1,
          label: 'Test-Aktion',
          icon: const IconData(0xe000),
          placement: RecipeActionPlacement.appBar,
          isEnabled: _isEnabled,
          onPressed: _onPressed,
        ),
        const RecipeAction(
          id: 'act2',
          order: 2,
          label: 'Menü-Aktion',
          icon: IconData(0xe001),
          placement: RecipeActionPlacement.menu,
          onPressed: _onPressed,
        ),
      ];

  @override
  List<SettingsEntry> get settingsEntries => const [
        SettingsEntry(id: 'set1', order: 1, title: 'Einstellung', onTap: _onTap),
      ];

  @override
  List<SyncTableSpec> get syncTables => const [
        SyncTableSpec(tableName: 'recipes', ownerColumn: 'owner_id', immutableAfterCreate: false),
      ];
}

void main() {
  test('UnsaltedModule ist vollständig implementierbar mit den Kapitel-21-Typen', () {
    final UnsaltedModule module = _FakeModule();

    expect(module.id, 'fake');
    expect(module.routes, isEmpty);
    expect(module.recipeDetailSections, hasLength(1));
    expect(module.recipeActions, hasLength(2));
    expect(module.settingsEntries, hasLength(1));
    expect(module.syncTables, hasLength(1));
  });

  test('order-Felder sind int (Kapitel 21)', () {
    final module = _FakeModule();
    expect(module.recipeDetailSections.first.order, isA<int>());
    expect(module.recipeActions.first.order, isA<int>());
    expect(module.settingsEntries.first.order, isA<int>());
  });

  test('RecipeActionPlacement kennt genau appBar und menu', () {
    expect(RecipeActionPlacement.values, [RecipeActionPlacement.appBar, RecipeActionPlacement.menu]);
  });

  test('RecipeAction.isEnabled ist optional', () {
    const withoutIsEnabled = RecipeAction(
      id: 'a',
      order: 1,
      label: 'X',
      icon: IconData(0xe002),
      placement: RecipeActionPlacement.menu,
      onPressed: _onPressed,
    );
    expect(withoutIsEnabled.isEnabled, isNull);
  });

  test('SyncTableSpec trägt tableName, ownerColumn, immutableAfterCreate', () {
    const spec = SyncTableSpec(
      tableName: 'recipe_ingredients',
      ownerColumn: 'owner_id',
      immutableAfterCreate: true,
    );
    expect(spec.tableName, 'recipe_ingredients');
    expect(spec.ownerColumn, 'owner_id');
    expect(spec.immutableAfterCreate, isTrue);
  });
}
