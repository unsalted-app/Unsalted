// lib/src/data/core_database.dart
//
// Die Drift-Datenbankklasse (Schritt 5.3). Bekommt den QueryExecutor von
// außen (Kapitel 16.7, coreDatabaseProvider) — kennt selbst keine konkrete
// Speicherimplementierung (Datei vs. In-Memory), das ist Sache der
// App-Hülle bzw. der Tests.
//
// schemaVersion = 1 ist die erste, noch nicht eingefrorene Fassung. Ab
// Schritt 5.4 (Schema-Dump) gilt dieses Schema als eingefroren (Kapitel 25.1).

import 'package:drift/drift.dart';

import 'tables/food_variants.dart';
import 'tables/recipe_ingredients.dart';
import 'tables/recipe_steps.dart';
import 'tables/recipe_versions.dart';
import 'tables/recipes.dart';
import 'package:decimal/decimal.dart';
import 'converters/decimal_converter.dart';
part 'core_database.g.dart';


@DriftDatabase(
  tables: [
    Recipes,
    RecipeVersions,
    RecipeIngredients,
    RecipeSteps,
    FoodVariants,
  ],
)
class CoreDatabase extends _$CoreDatabase {
  CoreDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}