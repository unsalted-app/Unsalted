// lib/src/module/core_module.dart
//
// Erste konkrete UnsaltedModule-Implementierung (Kapitel 21, Schritt 7.2).
// Wird ausschließlich in apps/unsalted_app/lib/main.dart registriert
// (Kapitel 21) -- diese Datei registriert sich nirgends selbst.
//
// ROUTEN (Nachtrag 8.7a, docs/decisions.md): `routes` liefert je Bildschirm
// mit eigener Route aus Kapitel 22 einen GoRoute-Eintrag. Die App-Hülle
// darf wegen AT-09 und der eingefrorenen öffentlichen Tür keine
// Bildschirmklassen direkt importieren -- CoreModule.routes ist der einzige
// legale Weg dorthin. Die Bildschirme selbst navigieren intern weiterhin per
// Navigator.push; die Reihenfolge stellt '/recipes/new' bzw. '/foods/new'
// vor die jeweilige ':id'-Route.
//
// recipeDetailSections/recipeActions/settingsEntries: Kapitel 21 nennt für
// CoreModule ausdrücklich nur id, Routen und syncTables -- diese drei
// Steckplatz-Listen sind Erweiterungspunkte für andere Module (Teil 2-6),
// nicht für Core selbst ("Bildschirm 4 rendert recipeDetailSections ...
// unabhängig davon, ob zur Laufzeit nur CoreModule registriert ist").
// Bleiben deshalb leer.
//
// ownerColumn: Nur `recipes` und `food_variants` besitzen tatsächlich eine
// eigene owner_id-Spalte (Kapitel 11.2, 11.6); recipe_versions,
// recipe_ingredients und recipe_steps haben keine (Kapitel 11.3-11.5).
// Kapitel 21 gibt für ownerColumn nur ein Beispiel ('owner_id'), keine
// Tabelle mit Werten pro Zeile, und die Arbeitskarte prüft dieses Feld
// nicht. Hier einheitlich 'owner_id' verwendet: für die drei Zeilentabellen
// ohne eigene Spalte ist das ein Hinweis für die künftige Sync-Schicht
// (Teil 3), Besitz über die Elternkette (version_id -> recipe_id ->
// recipes.owner_id) aufzulösen, keine Behauptung einer physisch
// vorhandenen Spalte. Endgültige Festlegung ist Sache von Teil 3.

import 'package:go_router/go_router.dart';

import '../ui/foods/food_editor_screen.dart';
import '../ui/foods/food_list_screen.dart';
import '../ui/recipe_detail/recipe_detail_screen.dart';
import '../ui/recipe_editor/recipe_create_screen.dart';
import '../ui/recipe_editor/recipe_editor_screen.dart';
import '../ui/recipe_list/recipe_list_screen.dart';
import '../ui/settings/export_screen.dart';
import '../ui/settings/import_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/versions/version_compare_screen.dart';
import '../ui/versions/version_list_screen.dart';
import 'extension_types.dart';
import 'unsalted_module.dart';

class CoreModule implements UnsaltedModule {
  const CoreModule();

  @override
  String get id => 'core';

  @override
  List<RouteBase> get routes => [
        GoRoute(path: '/', builder: (context, state) => const RecipeListScreen()),
        GoRoute(path: '/recipes/new', builder: (context, state) => const RecipeCreateScreen()),
        GoRoute(
          path: '/recipes/:id',
          builder: (context, state) => RecipeDetailScreen(recipeId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/recipes/:id/versions',
          builder: (context, state) => VersionListScreen(recipeId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/recipes/:id/versions/:vid/edit',
          builder: (context, state) => RecipeEditorScreen(
            recipeId: state.pathParameters['id']!,
            versionId: state.pathParameters['vid']!,
          ),
        ),
        GoRoute(
          path: '/recipes/:id/compare',
          builder: (context, state) => VersionCompareScreen(
            recipeId: state.pathParameters['id']!,
            versionAId: state.uri.queryParameters['a'] ?? '',
            versionBId: state.uri.queryParameters['b'] ?? '',
          ),
        ),
        GoRoute(path: '/foods', builder: (context, state) => const FoodListScreen()),
        GoRoute(path: '/foods/new', builder: (context, state) => const FoodEditorScreen()),
        GoRoute(
          path: '/foods/:id',
          builder: (context, state) => FoodEditorScreen(foodId: state.pathParameters['id']),
        ),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/settings/export', builder: (context, state) => const ExportScreen()),
        GoRoute(path: '/settings/import', builder: (context, state) => const ImportScreen()),
      ];

  @override
  List<RecipeDetailSection> get recipeDetailSections => const [];

  @override
  List<RecipeAction> get recipeActions => const [];

  @override
  List<SettingsEntry> get settingsEntries => const [];

  @override
  List<SyncTableSpec> get syncTables => const [
        SyncTableSpec(
          tableName: 'recipes',
          ownerColumn: 'owner_id',
          immutableAfterCreate: false,
        ),
        SyncTableSpec(
          tableName: 'recipe_versions',
          ownerColumn: 'owner_id',
          immutableAfterCreate: true,
        ),
        SyncTableSpec(
          tableName: 'recipe_ingredients',
          ownerColumn: 'owner_id',
          immutableAfterCreate: true,
        ),
        SyncTableSpec(
          tableName: 'recipe_steps',
          ownerColumn: 'owner_id',
          immutableAfterCreate: true,
        ),
        SyncTableSpec(
          tableName: 'food_variants',
          ownerColumn: 'owner_id',
          immutableAfterCreate: true,
        ),
      ];
}
