// lib/src/ui/recipe_detail/version_switcher.dart
//
// Bildschirm 4 (Kapitel 22, Schritt 8.5): Versionsumschalter -- zeigt
// „V{versionIndex}" + optionales label je Version, absteigend sortiert
// (wie von RecipeRepository.watchVersions geliefert). Reine Anzeige/
// Auswahl, keine eigene Datenquelle. Seit Teil 1.2 (C23) aus
// Design-Komponenten (AppChoiceChip).
//
// Seit Teil 1.3 (D13): Fassungsleiste (Figma `Core/Version Switcher`) —
// Fassungsmarken nebeneinander, Abstand `space-s`, unten ausgerichtet; die
// gewählte trägt den Auswahlbalken, jedes Ziel mindestens `size-target`.
// Passt die Leiste nicht in eine Zeile (große Schrift, viele Versionen),
// bricht sie um statt abzuschneiden. Den Master kennt die Leiste nicht (die
// Versionen tragen ihn nicht) — alle Marken zeigen Entwurf oder eingefroren.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe_version.dart';
import '../versions/version_mark.dart';

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
    return Wrap(
      spacing: AppSpacing.s,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final version in versions)
          VersionMark(
            version: version,
            isMaster: false,
            selected: version.id == selectedVersionId,
            onTap: () => onSelected(version.id),
          ),
      ],
    );
  }
}
