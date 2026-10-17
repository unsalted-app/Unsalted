// lib/src/components/buttons/app_fab.dart
//
// Komponente (Teil 1.2): Hauptaktion einer Seite (Figma `Button/FAB`), mit
// Ladezustand. Während des Ladens ist sie deaktiviert und zeigt einen kleinen
// Ladekreis in der Vordergrundfarbe des Buttons. Gestalt (Marker-Knopf mit
// Tintenkontur) aus dem Theme (Teil 1.3, D04); Ladekreis `size-icon-small` mit
// Strich `stroke-focus` (D06).

import 'package:flutter/material.dart';

import '../../tokens/size_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';

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
                dimension: AppSize.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: AppStroke.focus,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            : Icon(icon),
      );
}
