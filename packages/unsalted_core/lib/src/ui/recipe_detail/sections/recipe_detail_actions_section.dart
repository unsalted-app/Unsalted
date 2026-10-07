// lib/src/ui/recipe_detail/sections/recipe_detail_actions_section.dart
//
// Bildschirm 4, Abschnitt „Aktionen“ der Kopfleiste (Teil 1.2): die festen
// Core-Aktionen „Versionen“ und „Bearbeiten“ (Nachtrag 8.8a), die
// `recipeActions` aller Module mit `placement = appBar`, dann das Menü mit den
// Modul-Aktionen `placement = menu` und „Rezept löschen“ (Teil 1.1b).
// Aktionen sind bereits nach `order` sortiert. Ob eine Aktion aktiv ist und
// was sie tut, entscheidet der Bildschirm.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../module/extension_types.dart';

/// Aktionen der Kopfleiste des Rezeptdetails.
class RecipeDetailActionsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeDetailActionsSection({
    super.key,
    required this.appBarActions,
    required this.menuActions,
    required this.isEnabled,
    required this.onAction,
    required this.onVersions,
    required this.onEdit,
    required this.onDelete,
  });

  /// Modul-Aktionen für die Kopfleiste.
  final List<RecipeAction> appBarActions;

  /// Modul-Aktionen für das Menü.
  final List<RecipeAction> menuActions;

  /// `true`, wenn die Aktion gerade ausführbar ist.
  final bool Function(RecipeAction action) isEnabled;

  /// Führt eine Modul-Aktion aus.
  final ValueChanged<RecipeAction> onAction;

  /// Öffnet die Versionsliste.
  final VoidCallback onVersions;

  /// Öffnet den Editor der gewählten Version.
  final VoidCallback onEdit;

  /// Löscht das Rezept (mit „Rückgängig“).
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => AppStack(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIconButton(icon: AppIcons.history, tooltip: 'Versionen', onPressed: onVersions),
          AppIconButton(icon: AppIcons.edit, tooltip: 'Bearbeiten', onPressed: onEdit),
          for (final action in appBarActions)
            AppIconButton(
              icon: action.icon,
              tooltip: action.label,
              onPressed: isEnabled(action) ? () => onAction(action) : null,
            ),
          AppOverflowMenu(entries: [
            for (final action in menuActions)
              AppMenuEntry(label: action.label, enabled: isEnabled(action), onSelected: () => onAction(action)),
            AppMenuEntry(label: 'Rezept löschen', onSelected: onDelete),
          ]),
        ],
      );
}
