// lib/src/components/lists/app_list_item.dart
//
// Komponente (Teil 1.2): Listeneintrag mit Titel, Untertitel, Elementen
// vorn und hinten (Figma `List/Item`). Baut ein `ListTile` (Plan R1).
//
// Seit Teil 1.3 (D08, ListItem-Karte): ohne Karte, Haarlinie unten
// (`stroke-hairline` in `line-hairline`); [AppListItem.selected] zeigt einen
// Auswahlbalken `stroke-rule` in `line-strong` links (Liste und Detail
// nebeneinander, Teil 1.4). Höhe und Innenabstand aus dem Theme (D04).

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../tokens/stroke_tokens.g.dart';

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
    this.selected = false,
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

  /// `true`: gewählt (Auswahlbalken links).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.lineHairline, width: AppStroke.hairline),
          left: selected ? BorderSide(color: c.lineStrong, width: AppStroke.rule) : BorderSide.none,
        ),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        dense: dense ? true : null,
        selected: selected,
      ),
    );
  }
}
