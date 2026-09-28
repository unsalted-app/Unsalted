/// Öffentliche Tür von `unsalted_core` (Kapitel 18.1, Schritt 7.4).
///
/// Exportiert ausschließlich Verträge (`contracts/`), Fachmodelle
/// (`recipe/`, `food/`), die Nährwert-Typen `NutritionResult`/
/// `NutrientSet`/`UnitCatalog`/`NutritionFormatter`, `RecipeChange`/
/// `RecipeDiff`/`RecipeSnapshotV1`, Fehlerklassen, die Modultypen
/// (`module/`), `CoreModule`, die Provider (`providers/`) und
/// `CoreDatabase`. Niemals Tabellenklassen, DAOs, Mapper oder Widgets aus
/// `ui/` — insbesondere bleiben `RecipeDao`/`FoodDao` und die daraus
/// gebauten `recipeDaoProvider`/`foodDaoProvider` unexportiert (Kapitel
/// 16.8: "DAO-Contracts sind ... keine externe Public API"), obwohl
/// Kapitel 16.7 sie im selben Codeblock zeigt; siehe docs/decisions.md.
///
/// Ab Abnahme dieses Schritts eingefroren (Kapitel 25.1) — Erweiterungen
/// sind eine eigene, bewusste spätere Entscheidung, kein Nachtrag hier.
library;

// ---------------------------------------------------------------------
// Verträge (contracts/)
// ---------------------------------------------------------------------
export 'src/contracts/core_exceptions.dart';
export 'src/contracts/domain_events.dart';
export 'src/contracts/food_repository.dart';
export 'src/contracts/input_models.dart';
export 'src/contracts/nutrition_service.dart';
export 'src/contracts/recipe_repository.dart';
export 'src/contracts/snapshot_service.dart';

// ---------------------------------------------------------------------
// Fachmodelle (recipe/, food/)
// ---------------------------------------------------------------------
export 'src/food/food_variant.dart';
export 'src/recipe/recipe.dart';
export 'src/recipe/recipe_change.dart';
export 'src/recipe/recipe_diff.dart';
export 'src/recipe/recipe_ingredient.dart';
export 'src/recipe/recipe_snapshot_v1.dart' show RecipeSnapshotV1;
export 'src/recipe/recipe_step.dart';
export 'src/recipe/recipe_version.dart';

// ---------------------------------------------------------------------
// Nährwert-Typen — laut Kapitel 17 "die einzigen Typen, mit denen UI und
// spätere Teile über Nährwerte kommunizieren"
// ---------------------------------------------------------------------
export 'src/nutrition/nutrient_set.dart';
export 'src/nutrition/nutrition_formatter.dart';
export 'src/nutrition/nutrition_result.dart';
export 'src/nutrition/unit_catalog.dart' show UnitCatalog;

// ---------------------------------------------------------------------
// Modulsystem (module/)
// ---------------------------------------------------------------------
export 'src/module/core_module.dart';
export 'src/module/extension_types.dart';
export 'src/module/unsalted_module.dart';

// ---------------------------------------------------------------------
// Provider (providers/) — ohne recipeDaoProvider/foodDaoProvider, siehe
// Datei-Dokumentation oben.
// ---------------------------------------------------------------------
export 'src/providers/core_providers.dart' show coreDatabaseProvider, domainEventsProvider, foodRepositoryProvider, modulesProvider, nutritionServiceProvider, recipeRepositoryProvider, snapshotServiceProvider;

// ---------------------------------------------------------------------
// Datenbank-Handle (Kapitel 18.1: explizit als Ausnahme genannt)
// ---------------------------------------------------------------------
export 'src/data/core_database.dart' show CoreDatabase;
