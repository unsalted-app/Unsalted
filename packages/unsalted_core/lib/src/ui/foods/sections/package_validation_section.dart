// lib/src/ui/foods/sections/package_validation_section.dart
//
// Bildschirm 10, Abschnitt „Prüfung“ (Teil 1.2): Warnungen des
// NutrientValidator (Speichern trotzdem möglich) und ein blockierender Fehler
// (Kapitel 22). Die Keys `package_form_warning`/`package_form_error` bleiben
// für Tests erhalten.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Warnungen und Fehler des Formulars.
class PackageValidationSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const PackageValidationSection({super.key, required this.warnings, required this.error});

  /// Texte der Warnungen.
  final List<String> warnings;

  /// Blockierender Fehler; `null` = keiner.
  final String? error;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppGap(AppSpace.l),
          for (final warning in warnings)
            AppPadding.symmetric(
              vertical: AppSpace.xs,
              child: AppSurface(
                key: const Key('package_form_warning'),
                tone: AppSurfaceTone.warning,
                padding: AppSpace.s,
                child: AppText(warning),
              ),
            ),
          if (error != null)
            AppPadding.symmetric(
              vertical: AppSpace.xs,
              child: AppSurface(
                key: const Key('package_form_error'),
                tone: AppSurfaceTone.error,
                padding: AppSpace.s,
                child: AppText(error!),
              ),
            ),
        ],
      );
}
