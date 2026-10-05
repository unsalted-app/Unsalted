// test/spike/spike_combined_database.dart
//
// Schritt 9.3, Variante C (Plan B aus Kapitel 20.1): eine gemeinsame Klasse,
// die die Tabellen von Teil 1 und die des späteren Pakets auflistet. Nur
// Testcode.

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:unsalted_core/src/data/converters/decimal_converter.dart';
import 'package:unsalted_core/src/data/tables/food_variants.dart';
import 'package:unsalted_core/src/data/tables/recipe_ingredients.dart';
import 'package:unsalted_core/src/data/tables/recipe_steps.dart';
import 'package:unsalted_core/src/data/tables/recipe_versions.dart';
import 'package:unsalted_core/src/data/tables/recipes.dart';

import 'spike_tables.dart';

part 'spike_combined_database.g.dart';

@DriftDatabase(tables: [Recipes, RecipeVersions, RecipeIngredients, RecipeSteps, FoodVariants, SpikeNotes])
class SpikeCombinedDatabase extends _$SpikeCombinedDatabase {
  SpikeCombinedDatabase(super.executor);

  final List<String> migrationLog = [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          migrationLog.add('onCreate');
          await m.createAll();
        },
      );
}
