// lib/src/components/chips/app_choice_chip.dart
//
// Komponente (Teil 1.2): Auswahl-Chip (Figma `Chip/Choice`). Baut einen
// `ChoiceChip`.

import 'package:flutter/material.dart';

/// Auswahl-Chip.
class AppChoiceChip extends StatelessWidget {
  /// Erzeugt den Chip.
  const AppChoiceChip({super.key, required this.label, required this.selected, required this.onSelected});

  /// Beschriftung.
  final String label;

  /// `true`: gewählt.
  final bool selected;

  /// Aktion beim Antippen; `null` = gesperrt.
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected == null ? null : (_) => onSelected!(),
      );
}
