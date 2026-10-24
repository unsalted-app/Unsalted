// lib/src/components/navigation/app_overflow_menu.dart
//
// Komponente (Teil 1.2): Menü „⋮“ mit Einträgen (Figma
// `Navigation/Overflow Menu`). Baut einen `PopupMenuButton<VoidCallback>`
// (Plan R1); ein gewählter Eintrag ruft seine Aktion auf. Seit Teil 1.3
// (D10): Symbol `more`, Gestalt aus dem Theme (`surface-raised`, Haarlinie).
// Seit Teil 1.4 (B01): additiv [AppOverflowMenu.tooltip] (Figma
// `Feedback/Tooltip`) — Tooltip und Semantik des Menüknopfs; ausgegraute
// Einträge über [AppMenuEntry.enabled] (Figma `Navigation/Menu Item`,
// `state=disabled`).

import 'package:flutter/material.dart';

import '../icons/app_icons.dart';

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
  const AppOverflowMenu({super.key, required this.entries, this.tooltip});

  /// Einträge in Reihenfolge.
  final List<AppMenuEntry> entries;

  /// Tooltip und Semantik des Menüknopfs; `null` = Standardtext der
  /// Plattform („Menü anzeigen“).
  final String? tooltip;

  @override
  Widget build(BuildContext context) => PopupMenuButton<VoidCallback>(
        icon: const Icon(AppIcons.more),
        tooltip: tooltip,
        itemBuilder: (context) => [
          for (final entry in entries)
            PopupMenuItem(value: entry.onSelected, enabled: entry.enabled, child: Text(entry.label)),
        ],
        onSelected: (callback) => callback(),
      );
}
