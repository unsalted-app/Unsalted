// test/ui/recipe_detail/recipe_detail_menu_context_test.dart
//
// UI-58 (Teil 1.2, C23): Eine RecipeAction mit placement = menu erhält beim
// Antippen einen gültigen Kontext unter RecipeDetailScreen und den
// RecipeContext des Rezepts (Kapitel 21: onPressed(BuildContext,
// RecipeContext)). Eine Aktion mit isEnabled = false ist gesperrt und wird
// nicht ausgeführt. Bis Teil 1.2 gab es für Menü-Aktionen keinen Test.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:unsalted_design/unsalted_design.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/module/extension_types.dart';
import 'package:unsalted_core/src/module/unsalted_module.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';

class _MenuModule implements UnsaltedModule {
  const _MenuModule(this.actions);

  final List<RecipeAction> actions;

  @override
  String get id => 'menu-test';
  @override
  List<RouteBase> get routes => const [];
  @override
  List<RecipeDetailSection> get recipeDetailSections => const [];
  @override
  List<RecipeAction> get recipeActions => actions;
  @override
  List<SettingsEntry> get settingsEntries => const [];
  @override
  List<SyncTableSpec> get syncTables => const [];
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump();
  }
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets('UI-58: Menü-Aktion eines Moduls erhält einen gültigen Kontext des Rezeptdetails', (tester) async {
    final database = (await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory())))!;
    addTearDown(() async {
      await _disposeWidgetTree(tester);
      await tester.runAsync(database.close);
    });
    final recipeId = (await tester.runAsync(() async {
      final repo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
      return repo.createRecipe(const NewRecipe(title: 'Testrezept'));
    }))!;

    BuildContext? received;
    RecipeContext? receivedRecipe;
    var mountedAfterMenu = false;
    var disabledCalls = 0;
    final module = _MenuModule([
      RecipeAction(
        id: 'menu-ok',
        order: 1,
        label: 'Menüaktion',
        icon: Icons.info,
        placement: RecipeActionPlacement.menu,
        onPressed: (context, recipeContext) {
          received = context;
          receivedRecipe = recipeContext;
          mountedAfterMenu = context.mounted;
        },
      ),
      RecipeAction(
        id: 'menu-off',
        order: 2,
        label: 'Gesperrt',
        icon: Icons.info,
        placement: RecipeActionPlacement.menu,
        isEnabled: (_) => false,
        onPressed: (_, _) => disabledCalls++,
      ),
    ]);

    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        coreDatabaseProvider.overrideWithValue(database),
        modulesProvider.overrideWithValue([module]),
      ],
      child: MaterialApp(home: RecipeDetailScreen(recipeId: recipeId)),
    ));
    await _settle(tester);

    await tester.tap(find.byType(AppOverflowMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gesperrt'));
    await tester.pumpAndSettle();
    expect(disabledCalls, 0);
    expect(find.text('Menüaktion'), findsOneWidget, reason: 'ein gesperrter Eintrag schließt das Menü nicht');

    await tester.tap(find.text('Menüaktion'));
    await tester.pumpAndSettle();

    expect(received, isNotNull);
    expect(mountedAfterMenu, isTrue, reason: 'Kontext bleibt nach dem Schließen des Menüs gültig');
    expect(received!.findAncestorWidgetOfExactType<RecipeDetailScreen>(), isNotNull);
    expect(receivedRecipe!.recipeId, recipeId);

    await _disposeWidgetTree(tester);
  });
}
