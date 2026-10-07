// lib/src/components/lists/app_list_item.dart
//
// Komponente (Teil 1.2): Listeneintrag mit Titel, Untertitel, Elementen
// vorn und hinten (Figma `List/Item`). Baut ein `ListTile` (Plan R1).

import 'package:flutter/material.dart';

/// Listeneintrag.
class AppListItem extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const AppListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  /// Titel.
  final String title;

  /// Untertitel; `null` = keiner.
  final String? subtitle;

  /// Element vorn, z. B. `AppIcon`.
  final Widget? leading;

  /// Element hinten, z. B. `AppChip` oder Symbol-Schaltflächen.
  final Widget? trailing;

  /// Aktion beim Antippen.
  final VoidCallback? onTap;

  /// `true`: kompakte Höhe.
  final bool dense;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        dense: dense ? true : null,
      );
}
