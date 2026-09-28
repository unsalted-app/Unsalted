// lib/src/module/unsalted_module.dart
//
// Der Modul-Vertrag selbst (Kapitel 21, Schritt 7.1). Jeder Teil (2-6)
// implementiert diese Klasse genau einmal und registriert die Instanz in
// `apps/unsalted_app/lib/main.dart` (Kapitel 21: "Kein anderer Ort im
// Projekt registriert oder verändert die Modulliste"). `CoreModule`
// (Schritt 7.2) ist die erste, in Teil 1 mitgelieferte Implementierung.

import 'package:go_router/go_router.dart';

import 'extension_types.dart';

abstract class UnsaltedModule {
  String get id;
  List<RouteBase> get routes;
  List<RecipeDetailSection> get recipeDetailSections;
  List<RecipeAction> get recipeActions;
  List<SettingsEntry> get settingsEntries;
  List<SyncTableSpec> get syncTables;
}
