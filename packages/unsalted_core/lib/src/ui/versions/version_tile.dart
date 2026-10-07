// lib/src/ui/versions/version_tile.dart
//
// Fachlicher Baustein (Teil 1.2): eine Version im Verlauf — „V{index}“ mit
// optionalem Label, Entwurf/Eingefroren, Zeitpunkt des Einfrierens, Stern
// für die Master-Version und die Aktionen (Kapitel 22, Bildschirm 7; 28.4.4).

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe_version.dart';

/// Eintrag einer Version.
class VersionTile extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const VersionTile({
    super.key,
    required this.version,
    required this.isMaster,
    required this.onMarkMaster,
    required this.onCopy,
    required this.onCompare,
    required this.onDelete,
  });

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  /// Die Version.
  final RecipeVersion version;

  /// `true`: Master-Version des Rezepts.
  final bool isMaster;

  /// Markiert die Version als Master (nur eingefroren, noch nicht Master).
  final VoidCallback onMarkMaster;

  /// Kopiert die Version als neuen Entwurf.
  final VoidCallback onCopy;

  /// Vergleicht die Version (nur eingefroren).
  final VoidCallback onCompare;

  /// Löscht die Version.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isSnapshot = version.state == VersionState.snapshot;
    return AppListItem(
      leading: isMaster ? const AppIcon(AppIcons.star, tone: AppTone.primary, semanticLabel: 'Master') : null,
      title: version.label == null ? 'V${version.versionIndex}' : 'V${version.versionIndex} · ${version.label}',
      subtitle: [
        isSnapshot ? 'Eingefroren' : 'Entwurf',
        if (version.snapshottedAt != null) _dateFormat.format(version.snapshottedAt!),
      ].join(' · '),
      trailing: AppStack(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isSnapshot && !isMaster)
            AppIconButton(icon: AppIcons.starOutline, tooltip: 'Als Master markieren', onPressed: onMarkMaster),
          AppIconButton(icon: AppIcons.copy, tooltip: 'Kopie als Entwurf', onPressed: onCopy),
          AppIconButton(icon: AppIcons.compare, tooltip: 'Vergleichen', onPressed: isSnapshot ? onCompare : null),
          AppIconButton(icon: AppIcons.deleteOutline, tooltip: 'Löschen', onPressed: onDelete),
        ],
      ),
    );
  }
}
