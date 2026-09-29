// lib/src/ui/recipe_detail/version_switcher.dart
//
// Bildschirm 4 (Kapitel 22, Schritt 8.5): Versionsumschalter -- zeigt
// „V{versionIndex}" + optionales label je Version, absteigend sortiert
// (wie von RecipeRepository.watchVersions geliefert). Reine Anzeige/
// Auswahl, keine eigene Datenquelle.

import 'package:flutter/material.dart';

import '../../recipe/recipe_version.dart';

class VersionSwitcher extends StatelessWidget {
  final List<RecipeVersion> versions;
  final String? selectedVersionId;
  final ValueChanged<String> onSelected;

  const VersionSwitcher({
    super.key,
    required this.versions,
    required this.selectedVersionId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final version in versions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  version.label == null ? 'V${version.versionIndex}' : 'V${version.versionIndex} · ${version.label}',
                ),
                selected: version.id == selectedVersionId,
                onSelected: (_) => onSelected(version.id),
              ),
            ),
        ],
      ),
    );
  }
}
