// lib/src/module/unsalted_module.dart
//
// Der Modul-Vertrag selbst (Kapitel 21, Schritt 7.1). Jeder Teil (2-6)
// implementiert diese Klasse genau einmal und registriert die Instanz in
// `apps/unsalted_app/lib/main.dart` (Kapitel 21: "Kein anderer Ort im
// Projekt registriert oder verändert die Modulliste"). `CoreModule`
// (Schritt 7.2) ist die erste, in Teil 1 mitgelieferte Implementierung.

import 'package:go_router/go_router.dart';

import 'extension_types.dart';

/// Vertrag eines Moduls (Kapitel 21). Jeder Teil implementiert ihn genau einmal;
/// registriert wird die Instanz ausschließlich in der App-Hülle über
/// `modulesProvider`.
abstract class UnsaltedModule {
  /// Eindeutige ID des Moduls, z. B. `core`.
  String get id;
  /// Routen des Moduls; die App-Hülle verbindet die Routen aller Module zu
  /// einem Router (Kapitel 21, 28.2.3).
  List<RouteBase> get routes;
  /// Zusätzliche Abschnitte für das Rezeptdetail; über alle Module nach
  /// `order` sortiert angezeigt.
  List<RecipeDetailSection> get recipeDetailSections;
  /// Zusätzliche Aktionen für das Rezeptdetail (AppBar oder Menü); über alle
  /// Module nach `order` sortiert angezeigt.
  List<RecipeAction> get recipeActions;
  /// Zusätzliche Einträge für die Einstellungen; über alle Module nach `order`
  /// sortiert angezeigt.
  List<SettingsEntry> get settingsEntries;
  /// Tabellen des Moduls, die Teil 3 synchronisiert.
  List<SyncTableSpec> get syncTables;
}
