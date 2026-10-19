// lib/src/ui/foods/sections/package_nutrients_section.dart
//
// Bildschirm 10, Abschnitt „Nährwerte“ (Teil 1.2): Felder pro 100 g in der
// Reihenfolge von Bildschirm 5 (EU-Reihenfolge, nur energy_kcal) und das
// Natrium-Feld (Kapitel 8.2). Welche Felder es gibt, mit welchem Fehler- oder
// Hilfetext und ob gesperrt, entscheidet PackageForm. Seit Teil 1.3 (D16) im
// Raster (`AppGrid`): ab `breakpoint-medium` der verfügbaren Breite
// zweispaltig, mit Abstand `space-m`; Reihenfolge zeilenweise unverändert.
// Seit D16c Zahlenfelder (Tastatur mit Komma; `AppTextField` zeigt sie
// rechtsbündig in `data` mit tabellarischen Ziffern).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Ein Zahlenfeld des Nährwert-Abschnitts.
@immutable
class PackageNumberField {
  /// Erzeugt die Beschreibung des Felds.
  const PackageNumberField({
    required this.controller,
    required this.label,
    this.error,
    this.helper,
    this.enabled = true,
  });

  /// Text des Felds.
  final TextEditingController controller;

  /// Bezeichnung.
  final String label;

  /// Fehlertext; `null` = keiner.
  final String? error;

  /// Hilfetext; `null` = keiner.
  final String? helper;

  /// `false`: gesperrt.
  final bool enabled;
}

/// Nährwerte pro 100 g.
class PackageNutrientsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const PackageNutrientsSection({super.key, required this.fields});

  /// Felder in Anzeigereihenfolge.
  final List<PackageNumberField> fields;

  @override
  Widget build(BuildContext context) => AppSection(
        title: 'Nährwerte pro 100 g',
        children: [
          AppGrid(
            itemCount: fields.length,
            itemBuilder: (context, index) => AppTextField(
              controller: fields[index].controller,
              label: fields[index].label,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              error: fields[index].error,
              helper: fields[index].helper,
              enabled: fields[index].enabled,
            ),
          ),
        ],
      );
}
