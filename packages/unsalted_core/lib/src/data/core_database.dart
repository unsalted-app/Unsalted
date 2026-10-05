// lib/src/data/core_database.dart
//
// Die Drift-Datenbankklasse (Schritt 5.3). Bekommt den QueryExecutor von
// außen (Kapitel 16.7, coreDatabaseProvider) — kennt selbst keine konkrete
// Speicherimplementierung (Datei vs. In-Memory), das ist Sache der
// App-Hülle bzw. der Tests.
//
// schemaVersion = 1 ist ab Schritt 5.4 eingefroren (Kapitel 25.1).

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
/// Drift-Datenbank von Teil 1 mit den fünf Tabellen aus Kapitel 11;
/// Schema-Version `1`, eingefroren (Kapitel 25.1). Den `QueryExecutor` gibt die
/// App-Hülle vor (Kapitel 16.7); mehrere Datenbankklassen auf einer Datei
/// regelt Kapitel 28.6.
class CoreDatabase extends _$CoreDatabase {
    /// Erzeugt die Datenbank auf dem übergebenen Executor. Gelesen und geschrieben
    /// wird über die Repositories und Services, nicht direkt.
    CoreDatabase(super.executor);


  @override
  int get schemaVersion => 1;
}

// Kapitel 16.8: generische Namen für die Drift-generierten Zeilentypen, um
// Namenskollisionen mit den gleichnamigen Fachmodellen (Recipe,
// RecipeVersion, RecipeIngredient, RecipeStep, FoodVariant aus
// lib/src/recipe/ bzw. lib/src/food/) zu vermeiden. DAO-Contracts (Kapitel
// 16.8) und deren Implementierungen referenzieren ausschließlich diese
// Namen, nie die rohen Drift-Klassennamen direkt.
typedef RecipeRow = Recipe;
typedef RecipeVersionRow = RecipeVersion;
typedef RecipeIngredientRow = RecipeIngredient;
typedef RecipeStepRow = RecipeStep;
typedef FoodVariantRow = FoodVariant;