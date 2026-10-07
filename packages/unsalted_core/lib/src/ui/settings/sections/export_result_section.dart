// lib/src/ui/settings/sections/export_result_section.dart
//
// Bildschirm 11, Abschnitt „Ergebnis“ (Teil 1.2): das exportierte JSON und
// „In Zwischenablage kopieren“. Füllt die verfügbare Höhe; der Bildschirm
// legt es in ein `Expanded`.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Ergebnis des Exports.
class ExportResultSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const ExportResultSection({super.key, required this.json, required this.onCopy});

  /// Exportiertes JSON.
  final String json;

  /// Kopiert das JSON in die Zwischenablage.
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          const AppGap(AppSpace.l),
          Expanded(child: AppCodeBlock(json)),
          const AppGap(AppSpace.s),
          AppButton.secondary(label: 'In Zwischenablage kopieren', onPressed: onCopy),
        ],
      );
}
