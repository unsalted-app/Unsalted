// lib/src/components/navigation/app_top_bar.dart
//
// Komponente (Teil 1.2): Kopfleiste einer Seite mit Titel, Aktionen und
// optionalem unterem Bereich, z. B. einem Suchfeld (Figma
// `Navigation/Top Bar`). Baut eine `AppBar` (Plan R1).
//
// Seit Teil 1.3 (D10, TopBar-Karte): Gestalt aus dem Theme (Papier, Titel
// links in `title-page`, Haarlinie statt Schatten, Höhe `size-top-bar`); der
// Suchbereich hat oben `space-s`, seitlich `space-l`, unten `space-m`. Als
// Systemleiste folgt sie der Textgröße nicht.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';

/// Kopfleiste.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Erzeugt die Kopfleiste.
  const AppTopBar({super.key, required this.title, this.actions = const [], this.bottom});

  /// Höhe des unteren Bereichs: `space-s` + Feld (`size-control`) + `space-m`.
  static const double bottomHeight = AppSpacing.s + AppSize.control + AppSpacing.m;

  /// Titel.
  final String title;

  /// Aktionen rechts, z. B. `AppIconButton` und `AppOverflowMenu`.
  final List<Widget> actions;

  /// Unterer Bereich, z. B. `AppSearchField`.
  final Widget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(AppSize.topBar + (bottom == null ? 0 : bottomHeight));

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
        child: AppBar(
          title: Text(title),
          actions: actions,
          bottom: bottom == null
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(bottomHeight),
                  child: AppPadding.only(
                    top: AppSpace.s,
                    left: AppSpace.l,
                    right: AppSpace.l,
                    bottom: AppSpace.m,
                    child: bottom!,
                  ),
                ),
        ),
      );
}
