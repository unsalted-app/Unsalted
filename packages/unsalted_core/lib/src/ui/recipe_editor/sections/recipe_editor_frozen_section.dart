// lib/src/ui/recipe_editor/sections/recipe_editor_frozen_section.dart
//
// Bildschirm 3, Abschnitt „eingefroren“ (Teil 1.2): Hinweis „Eingefroren —
// als neuen Entwurf kopieren?“ mit Aktion (createDraftFrom), darunter
// schreibgeschützt Zutaten und Schritte (Kapitel 22).
//
// Seit Teil 1.3 (D16, 28.10.3; Figma Bildschirm 03 „Eingefroren“): der
// Hinweis als `AppNotice` mit „Kopieren“ (Text unverändert), darunter der
// schreibgeschützte Inhalt im Zustandsrahmen (`AppFrame.fixed`) mit der
// Fassungsmarke samt Siegel und dem Zustandswort.
//
// Seit Teil 1.4 (M00a, Figma `42:2010`): zwischen Zutaten und Schritten genau
// eine Haarlinie, ohne Abstand (`AppDivider.flush`).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_version.dart';
import '../../shared/unit_labels.dart';
import '../../versions/version_mark.dart';

/// Schreibgeschützte Ansicht einer eingefrorenen Version.
class RecipeEditorFrozenSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeEditorFrozenSection({super.key, required this.version, required this.onCopy});

  /// Die eingefrorene Version.
  final RecipeVersion version;

  /// Kopiert sie als neuen Entwurf.
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppNotice(
            'Eingefroren — als neuen Entwurf kopieren?',
            action: AppButton.tertiary(label: 'Kopieren', onPressed: onCopy),
          ),
          const AppGap(AppSpace.l),
          AppFrame.fixed(
            mark: VersionMark(version: version, isMaster: false, seal: true),
            caption: 'Eingefroren',
            child: AppStack(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final ingredient in version.ingredients)
                  AppListItem(
                    title: ingredient.displayName,
                    subtitle: formatAmount(ingredient.quantity, ingredient.unitCode),
                  ),
                const AppDivider.flush(),
                for (final step in version.steps) AppListItem(title: step.instruction),
              ],
            ),
          ),
        ],
      );
}
