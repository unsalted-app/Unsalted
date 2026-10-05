// lib/src/module/extension_types.dart
//
// Steckplatztypen des Modulsystems (Kapitel 21, Schritt 7.1). Wörtlich nach
// dem Contract in Kapitel 21 — keine zusätzlichen Felder oder Methoden.
//
// `lib/src/module/` darf Flutter importieren (ausdrückliche Ausnahme,
// Arbeitskarte Schritt 7.1, §9): die Rezeptseite (Bildschirm 4, Kapitel 22)
// rendert diese Typen direkt als Widgets. Drift bleibt hier verboten wie
// überall außerhalb von `lib/src/data/` (AT-05).

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nutrition/nutrition_result.dart';
import '../recipe/recipe_version.dart';

/// Kontext, den ein Modul beim Rendern einer Rezeptseiten-Erweiterung
/// erhält (Kapitel 21). `ref` erlaubt Zugriff auf alle Provider aus
/// Kapitel 16.7.
class RecipeContext {
  /// ID des angezeigten Rezepts.
  final String recipeId;
  /// ID der angezeigten Version.
  final String versionId;
  /// Die angezeigte Version samt Zutaten und Schritten.
  final RecipeVersion version;
  /// Nährwerte der angezeigten Version, wie sie die Nährwerttabelle zeigt
  /// (`NutritionService.forVersion`).
  final NutritionResult nutrition;
  /// Zugriff auf die Provider aus Kapitel 16.7.
  final WidgetRef ref;

  /// Erzeugt den Kontext; die Rezeptseite baut ihn je angezeigter Version.
  const RecipeContext({
    required this.recipeId,
    required this.versionId,
    required this.version,
    required this.nutrition,
    required this.ref,
  });
}

/// Ein zusätzlicher Abschnitt auf der Rezeptdetailseite (Bildschirm 4).
/// `order` ist die Sortierung über Module hinweg, aufsteigend.
class RecipeDetailSection {
  /// Eindeutige ID des Abschnitts.
  final String id;
  /// Sortierschlüssel über alle Module hinweg, aufsteigend (Kapitel 21).
  final int order;
  /// Baut das Widget des Abschnitts für den gegebenen [RecipeContext].
  final Widget Function(BuildContext, RecipeContext) build;

  /// Erzeugt den Abschnitt.
  const RecipeDetailSection({
    required this.id,
    required this.order,
    required this.build,
  });
}

/// Platzierung einer [RecipeAction] (Kapitel 21).
enum RecipeActionPlacement {
  /// Als Symbol in der AppBar der Rezeptseite.
  appBar,
  /// Als Eintrag im Menü der Rezeptseite.
  menu
}

/// Eine zusätzliche Aktion auf der Rezeptdetailseite (AppBar oder Menü).
class RecipeAction {
  /// Eindeutige ID der Aktion.
  final String id;
  /// Sortierschlüssel über alle Module hinweg, aufsteigend (Kapitel 21).
  final int order;
  /// Beschriftung; in der AppBar als Tooltip, im Menü als Eintrag.
  final String label;
  /// Symbol der Aktion in der AppBar.
  final IconData icon;
  /// Ort der Aktion: AppBar oder Menü.
  final RecipeActionPlacement placement;
  /// Optional: `false` deaktiviert die Aktion für den gegebenen Kontext;
  /// ohne Funktion ist sie immer aktiv.
  final bool Function(RecipeContext)? isEnabled;
  /// Wird beim Antippen mit dem aktuellen Kontext aufgerufen.
  final void Function(BuildContext, RecipeContext) onPressed;

  /// Erzeugt die Aktion.
  const RecipeAction({
    required this.id,
    required this.order,
    required this.label,
    required this.icon,
    required this.placement,
    this.isEnabled,
    required this.onPressed,
  });
}

/// Ein zusätzlicher Eintrag auf der Einstellungsseite (Bildschirm 13).
class SettingsEntry {
  /// Eindeutige ID des Eintrags.
  final String id;
  /// Sortierschlüssel über alle Module hinweg, aufsteigend (Kapitel 21).
  final int order;
  /// Titel des Eintrags.
  final String title;
  /// Optionale zweite Zeile.
  final String? subtitle;
  /// Wird beim Antippen aufgerufen.
  final void Function(BuildContext) onTap;

  /// Erzeugt den Eintrag.
  const SettingsEntry({
    required this.id,
    required this.order,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

/// Beschreibt eine synchronisierbare Tabelle für Teil 3 (Kapitel 21).
/// `immutableAfterCreate = true` für Zeilen, deren zugehörige Version
/// `state = snapshot` ist.
class SyncTableSpec {
  /// Name der Datenbanktabelle, z. B. `recipes`.
  final String tableName;
  /// Spalte, über die der Besitz bestimmt wird, z. B. `owner_id`
  /// (Kapitel 28.2.3).
  final String ownerColumn;
  /// `true`, wenn Zeilen nach dem Anlegen unveränderlich sind (Zeilen einer
  /// eingefrorenen Version).
  final bool immutableAfterCreate;

  /// Erzeugt die Beschreibung.
  const SyncTableSpec({
    required this.tableName,
    required this.ownerColumn,
    required this.immutableAfterCreate,
  });
}
