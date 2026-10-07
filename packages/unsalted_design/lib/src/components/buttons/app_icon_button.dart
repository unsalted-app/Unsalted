// lib/src/components/buttons/app_icon_button.dart
//
// Komponente (Teil 1.2): Schaltfläche nur mit Symbol (Figma `Button/Icon`).
// Der Tooltip ist Pflicht — er ist zugleich der Text für Screenreader.

import 'package:flutter/material.dart';

/// Symbol-Schaltfläche.
class AppIconButton extends StatelessWidget {
  /// Erzeugt die Schaltfläche.
  const AppIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed});

  /// Symbol, in der Regel aus `AppIcons`.
  final IconData icon;

  /// Tooltip und Screenreader-Text.
  final String tooltip;

  /// Aktion; `null` = deaktiviert.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
}
