// lib/src/components/navigation/app_overflow_menu.dart
//
// Komponente (Teil 1.2): Menü „⋮“ mit Einträgen (Figma
// `Navigation/Overflow Menu`). Baut einen `PopupMenuButton<VoidCallback>`
// (Plan R1); ein gewählter Eintrag ruft seine Aktion auf.

import 'package:flutter/material.dart';

/// Ein Eintrag eines [AppOverflowMenu].
@immutable
class AppMenuEntry {
  /// Erzeugt den Eintrag.
  const AppMenuEntry({required this.label, required this.onSelected, this.enabled = true});

  /// Beschriftung.
  final String label;

  /// Aktion bei Auswahl.
  final VoidCallback onSelected;

  /// `false`: ausgegraut.
  final bool enabled;
}

/// Menü „⋮“.
class AppOverflowMenu extends StatelessWidget {
  /// Erzeugt das Menü.
  const AppOverflowMenu({super.key, required this.entries});

  /// Einträge in Reihenfolge.
  final List<AppMenuEntry> entries;

  @override
  Widget build(BuildContext context) => PopupMenuButton<VoidCallback>(
        itemBuilder: (context) => [
          for (final entry in entries)
            PopupMenuItem(value: entry.onSelected, enabled: entry.enabled, child: Text(entry.label)),
        ],
        onSelected: (callback) => callback(),
      );
}
