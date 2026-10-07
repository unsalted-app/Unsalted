// lib/src/ui/versions/snapshot_column.dart
//
// Fachlicher Baustein (Teil 1.2, aus version_compare_screen.dart
// herausgelöst): eine Seite des Versionsvergleichs — Kennung, Titel, Zutaten
// und Schritte des Snapshots.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe_snapshot_v1.dart';
import '../shared/unit_labels.dart';

/// Inhalt eines Snapshots in einer Vergleichsspalte.
class SnapshotColumn extends StatelessWidget {
  /// Erzeugt die Spalte.
  const SnapshotColumn({super.key, required this.title, required this.snapshot});

  /// Kennung der Spalte, z. B. „A“.
  final String title;

  /// Der Snapshot.
  final RecipeSnapshotV1 snapshot;

  @override
  Widget build(BuildContext context) => AppPadding.all(
        AppSpace.s,
        child: AppStack(
          children: [
            AppText.title(title),
            AppText.strong(snapshot.recipe.title),
            const AppGap(AppSpace.s),
            for (final ingredient in snapshot.ingredients)
              AppText('${ingredient.name}: ${formatAmount(ingredient.quantity, ingredient.unit)}'),
            const AppGap(AppSpace.s),
            for (final step in snapshot.steps) AppText('${step.position}. ${step.instruction}'),
          ],
        ),
      );
}
