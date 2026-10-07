// lib/src/ui/versions/sections/version_compare_changes_section.dart
//
// Bildschirm 8, Abschnitt „Änderungen“ (Teil 1.2): gruppierte
// Änderungsliste oder „Keine Unterschiede.“. Die Texte entstehen nur für die
// Anzeige (Fehlerbehebung 9.2a); die Liste selbst bleibt unverändert.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_change.dart';
import '../../../recipe/recipe_snapshot_v1.dart';
import '../change_descriptions.dart';
import '../change_list.dart';

/// Änderungen von A nach B.
class VersionCompareChangesSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const VersionCompareChangesSection({super.key, required this.a, required this.changes});

  /// Version A, Ausgangspunkt der Texte.
  final RecipeSnapshotV1 a;

  /// Änderungen in Diff-Reihenfolge.
  final List<RecipeChange> changes;

  @override
  Widget build(BuildContext context) => changes.isEmpty
      ? const AppEmptyState(message: 'Keine Unterschiede.')
      : ChangeList(changes: changes, descriptions: describeChanges(a, changes));
}
