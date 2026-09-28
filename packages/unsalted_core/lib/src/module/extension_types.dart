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
  final String recipeId;
  final String versionId;
  final RecipeVersion version;
  final NutritionResult nutrition;
  final WidgetRef ref;

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
  final String id;
  final int order;
  final Widget Function(BuildContext, RecipeContext) build;

  const RecipeDetailSection({
    required this.id,
    required this.order,
    required this.build,
  });
}

/// Platzierung einer [RecipeAction] (Kapitel 21).
enum RecipeActionPlacement { appBar, menu }

/// Eine zusätzliche Aktion auf der Rezeptdetailseite (AppBar oder Menü).
class RecipeAction {
  final String id;
  final int order;
  final String label;
  final IconData icon;
  final RecipeActionPlacement placement;
  final bool Function(RecipeContext)? isEnabled;
  final void Function(BuildContext, RecipeContext) onPressed;

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
  final String id;
  final int order;
  final String title;
  final String? subtitle;
  final void Function(BuildContext) onTap;

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
  final String tableName;
  final String ownerColumn;
  final bool immutableAfterCreate;

  const SyncTableSpec({
    required this.tableName,
    required this.ownerColumn,
    required this.immutableAfterCreate,
  });
}
