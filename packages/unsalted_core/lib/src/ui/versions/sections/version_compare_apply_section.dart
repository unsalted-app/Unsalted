// lib/src/ui/versions/sections/version_compare_apply_section.dart
//
// Bildschirm 8, Abschnitt „Übernehmen“ (Teil 1.2): Fehler beim Übernehmen
// und „Als neuen Entwurf übernehmen“ (Kapitel 15.5: exakt dieselbe Liste).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Fußzeile des Vergleichs.
class VersionCompareApplySection extends StatelessWidget {
  /// Erzeugt den Abschnitt; [onApply] `null` = gesperrt.
  const VersionCompareApplySection({super.key, required this.error, required this.onApply});

  /// Fehler beim letzten Übernehmen; `null` = keiner.
  final String? error;

  /// Übernimmt die Änderungen.
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (error != null) AppPadding.all(AppSpace.s, child: AppText(error!, tone: AppTone.error)),
          AppBottomActionBar(actions: [AppButton.primary(label: 'Als neuen Entwurf übernehmen', onPressed: onApply)]),
        ],
      );
}
