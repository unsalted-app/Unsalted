// lib/src/ui/versions/sections/version_compare_columns_section.dart
//
// Bildschirm 8, Abschnitt „Spalten“ (Teil 1.2): Version A und B
// nebeneinander. Seit Teil 1.3 (D14, Entscheidung 3 zu Etappe 2): Würde eine
// Spalte schmaler als `reflow-label-min` (große Schrift), steht A über B,
// getrennt durch eine Linie — sonst trennte Flutter lange Wörter.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../recipe/recipe_snapshot_v1.dart';
import '../snapshot_column.dart';

/// Zwei Vergleichsspalten.
class VersionCompareColumnsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const VersionCompareColumnsSection({super.key, required this.a, required this.b});

  /// Version A (Basis).
  final RecipeSnapshotV1 a;

  /// Version B (Ziel).
  final RecipeSnapshotV1 b;

  @override
  Widget build(BuildContext context) {
    final labelMin = AppReflowMetric.labelMin.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth / 2 < labelMin) {
        return AppStack(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SnapshotColumn(title: 'A', snapshot: a),
            const AppDivider.flush(),
            SnapshotColumn(title: 'B', snapshot: b),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SnapshotColumn(title: 'A', snapshot: a)),
          const AppDivider.vertical(),
          Expanded(child: SnapshotColumn(title: 'B', snapshot: b)),
        ],
      );
    });
  }
}
