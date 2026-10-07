// lib/src/components/buttons/app_fab.dart
//
// Komponente (Teil 1.2): Hauptaktion einer Seite (Figma `Button/FAB`), mit
// Ladezustand. Während des Ladens ist sie deaktiviert und zeigt einen kleinen
// Ladekreis in der Vordergrundfarbe des Buttons.

import 'package:flutter/material.dart';

/// Hauptaktion einer Seite.
class AppFab extends StatelessWidget {
  /// Erzeugt die Hauptaktion.
  const AppFab({super.key, required this.icon, required this.tooltip, required this.onPressed, this.loading = false});

  /// Symbol, in der Regel aus `AppIcons`.
  final IconData icon;

  /// Tooltip und Screenreader-Text.
  final String tooltip;

  /// Aktion; `null` = deaktiviert.
  final VoidCallback? onPressed;

  /// `true`: Ladekreis statt Symbol, deaktiviert.
  final bool loading;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        tooltip: tooltip,
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            : Icon(icon),
      );
}
