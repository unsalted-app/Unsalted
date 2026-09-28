// lib/src/module/core_module.dart
//
// Erste konkrete UnsaltedModule-Implementierung (Kapitel 21, Schritt 7.2).
// Wird ausschließlich in apps/unsalted_app/lib/main.dart registriert
// (Kapitel 21) -- diese Datei registriert sich nirgends selbst.
//
// ROUTEN: Kapitel 21 nennt "seine eigenen Routen" als Teil von CoreModule,
// aber die zugehörigen Bildschirme (Kapitel 22, Bildschirm 1-13) sind erst
// Phase 8. Da Schritt 7.2 laut Arbeitskarte ausdrücklich keine Provider-
// oder main.dart-Verdrahtung vornimmt und die TESTS-Zeile der Arbeitskarte
// nur id, Tabellenliste und immutableAfterCreate verlangt (nicht routes),
// liefert `routes` hier bewusst eine leere Liste. Phase 8 ergänzt die
// echten GoRoute-Einträge, sobald die Bildschirm-Widgets existieren.
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

import 'extension_types.dart';
import 'unsalted_module.dart';

class CoreModule implements UnsaltedModule {
  const CoreModule();

  @override
  String get id => 'core';

  @override
  List<RouteBase> get routes => const [];

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
