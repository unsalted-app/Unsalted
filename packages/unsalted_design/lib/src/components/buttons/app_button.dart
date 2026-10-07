// lib/src/components/buttons/app_button.dart
//
// Komponente (Teil 1.2): Schaltfläche mit Beschriftung und optionalem Symbol.
// Figma `Button/Primary`, `Button/Secondary`, `Button/Tertiary`. Baut vorerst
// genau die bisherigen Material-Widgets (`ElevatedButton`, `OutlinedButton`,
// `TextButton`, Plan R1).

import 'package:flutter/material.dart';

/// Gewicht einer [AppButton].
enum AppButtonVariant {
  /// Hauptaktion eines Bereichs.
  primary,

  /// Nebenaktion.
  secondary,

  /// zurückhaltende Aktion, z. B. in Dialogen und Hinweisen.
  tertiary,
}

/// Schaltfläche.
class AppButton extends StatelessWidget {
  /// Hauptaktion.
  const AppButton.primary({super.key, required this.label, required this.onPressed, this.icon})
      : variant = AppButtonVariant.primary;

  /// Nebenaktion.
  const AppButton.secondary({super.key, required this.label, required this.onPressed, this.icon})
      : variant = AppButtonVariant.secondary;

  /// zurückhaltende Aktion.
  const AppButton.tertiary({super.key, required this.label, required this.onPressed, this.icon})
      : variant = AppButtonVariant.tertiary;

  /// Beschriftung.
  final String label;

  /// Aktion; `null` = deaktiviert.
  final VoidCallback? onPressed;

  /// Optionales Symbol vor der Beschriftung.
  final IconData? icon;

  /// Gewicht.
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    final iconWidget = icon == null ? null : Icon(icon);
    return switch (variant) {
      AppButtonVariant.primary => iconWidget == null
          ? ElevatedButton(onPressed: onPressed, child: text)
          : ElevatedButton.icon(onPressed: onPressed, icon: iconWidget, label: text),
      AppButtonVariant.secondary => iconWidget == null
          ? OutlinedButton(onPressed: onPressed, child: text)
          : OutlinedButton.icon(onPressed: onPressed, icon: iconWidget, label: text),
      AppButtonVariant.tertiary => iconWidget == null
          ? TextButton(onPressed: onPressed, child: text)
          : TextButton.icon(onPressed: onPressed, icon: iconWidget, label: text),
    };
  }
}
