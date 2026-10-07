// lib/src/components/chips/app_chip.dart
//
// Komponente (Teil 1.2): Info-Chip, z. B. eine Zeitangabe (Figma
// `Chip/Info`). Baut einen `Chip`.

import 'package:flutter/material.dart';

/// Info-Chip.
class AppChip extends StatelessWidget {
  /// Erzeugt den Chip.
  const AppChip({super.key, required this.label});

  /// Beschriftung.
  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}
