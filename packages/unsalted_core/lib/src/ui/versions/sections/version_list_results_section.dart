// lib/src/ui/versions/sections/version_list_results_section.dart
//
// Bildschirm 7, Abschnitt „Versionen“ (Teil 1.2): alle Versionen absteigend
// nach versionIndex (so geliefert von watchVersions).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_version.dart';
import '../version_tile.dart';

/// Liste der Versionen.
class VersionListResultsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const VersionListResultsSection({
    super.key,
    required this.versions,
    required this.masterVersionId,
    required this.onMarkMaster,
    required this.onCopy,
    required this.onCompare,
    required this.onDelete,
  });

  /// Versionen in Anzeigereihenfolge.
  final List<RecipeVersion> versions;

  /// ID der Master-Version; `null` = keine.
  final String? masterVersionId;

  /// Markiert eine Version als Master.
  final ValueChanged<RecipeVersion> onMarkMaster;

  /// Kopiert eine Version als Entwurf.
  final ValueChanged<RecipeVersion> onCopy;

  /// Vergleicht eine Version.
  final ValueChanged<RecipeVersion> onCompare;

  /// Löscht eine Version.
  final ValueChanged<RecipeVersion> onDelete;

  @override
  Widget build(BuildContext context) => AppItemList.builder(
        itemCount: versions.length,
        itemBuilder: (context, index) {
          final version = versions[index];
          return VersionTile(
            version: version,
            isMaster: version.id == masterVersionId,
            onMarkMaster: () => onMarkMaster(version),
            onCopy: () => onCopy(version),
            onCompare: () => onCompare(version),
            onDelete: () => onDelete(version),
          );
        },
      );
}
