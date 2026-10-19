// test/goldens/gl02_screens_golden_test.dart
//
// GL-02 (Teil 1.3, D01): fünf Musterbildschirme im Inhaltszustand, je acht
// Varianten (support/golden_harness.dart) — Rezeptliste (1), Rezept-Editor
// (3), Rezeptdetail (4), Versionsvergleich (8), Lebensmittel bearbeiten (10).
// Daten aus support/screen_fixtures.dart. Nur unter Linux
// (docs/design/plan-1.3.md, d4).
@TestOn('linux')
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/foods/food_editor_screen.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/recipe_list/recipe_list_screen.dart';
import 'package:unsalted_core/src/ui/versions/version_compare_screen.dart';

import 'support/golden_harness.dart';
import 'support/screen_fixtures.dart';

void _screenGolden(String motif, Widget Function(GoldenFixture fixture) screen) {
  for (final variant in goldenVariants) {
    testWidgets('GL-02: $motif (${variant.name})', (tester) async {
      applyGoldenView(tester, variant);
      final database = await openGoldenDatabase(tester);
      addTearDown(() => closeGoldenDatabase(tester, database));
      final fixture = await seedGoldenFixture(tester, database);

      await tolerateOverflow(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            coreDatabaseProvider.overrideWithValue(database),
            modulesProvider.overrideWithValue(const []),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: goldenTheme(variant),
            home: screen(fixture),
          ),
        ));
        await settleScreen(tester);
        await tester.pump(const Duration(seconds: 1));
        await expectGolden(motif, variant);
      });
      // Drift plant beim Abbestellen einen Timer; er muss noch im Test
      // auslaufen (CLAUDE.md, Abschnitt 4).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    }, tags: ['golden']);
  }
}

void main() {
  setUpAll(loadGoldenFonts);

  _screenGolden('01_rezeptliste', (_) => const RecipeListScreen());
  _screenGolden('03_rezept_bearbeiten', (f) => RecipeEditorScreen(recipeId: f.recipeId, versionId: f.v3));
  _screenGolden('04_rezeptdetail', (f) => RecipeDetailScreen(recipeId: f.recipeId));
  _screenGolden(
    '08_versionsvergleich',
    (f) => VersionCompareScreen(recipeId: f.recipeId, versionAId: f.v1, versionBId: f.v2),
  );
  _screenGolden('10_lebensmittel_bearbeiten', (f) => FoodEditorScreen(foodId: f.flourId));
}
