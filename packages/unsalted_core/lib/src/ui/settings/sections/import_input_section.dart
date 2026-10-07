// lib/src/ui/settings/sections/import_input_section.dart
//
// Bildschirm 12, Abschnitt „Eingabe“ (Teil 1.2): JSON einfügen. Füllt die
// verfügbare Höhe; der Bildschirm legt es in ein `Expanded`.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Eingabefeld für das JSON.
class ImportInputSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const ImportInputSection({super.key, required this.controller, required this.onChanged});

  /// Eingefügter Text.
  final TextEditingController controller;

  /// Meldet jede Änderung.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) =>
      AppTextField(controller: controller, label: 'JSON einfügen', expands: true, onChanged: onChanged);
}
