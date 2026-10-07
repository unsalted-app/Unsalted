// lib/src/components/lists/app_reorderable_list.dart
//
// Komponente (Teil 1.2): eingebettete Liste, deren Einträge sich per
// Ziehgriff umsortieren lassen (Figma `List/Reorderable`). Scrollt nicht
// selbst; jedes Kind braucht einen eindeutigen Key. Baut ein
// `ReorderableListView` (Plan R1).

import 'package:flutter/material.dart';

/// Umsortierbare, eingebettete Liste.
class AppReorderableList extends StatelessWidget {
  /// Erzeugt die Liste.
  const AppReorderableList({super.key, required this.onReorder, required this.children});

  /// Meldet eine Verschiebung von `oldIndex` nach `newIndex` (Zielposition
  /// nach dem Entfernen, wie `onReorderItem`).
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Einträge, je mit eindeutigem Key.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorderItem: onReorder,
        children: children,
      );
}
