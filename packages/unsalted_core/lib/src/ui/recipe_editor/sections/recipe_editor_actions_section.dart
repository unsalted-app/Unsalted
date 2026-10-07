// lib/src/ui/recipe_editor/sections/recipe_editor_actions_section.dart
//
// Bildschirm 3, Abschnitt „Aktionen“ (Teil 1.2): „Einfrieren“
// (snapshotVersion) und „Speichern“ (saveDraft) am unteren Rand.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Aktionsleiste des Editors.
class RecipeEditorActionsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt; `null` = gesperrt.
  const RecipeEditorActionsSection({super.key, required this.onFreeze, required this.onSave});

  /// Friert die Version ein.
  final VoidCallback? onFreeze;

  /// Speichert den Entwurf.
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) => AppBottomActionBar(actions: [
        AppButton.secondary(label: 'Einfrieren', onPressed: onFreeze),
        AppButton.primary(label: 'Speichern', onPressed: onSave),
      ]);
}
