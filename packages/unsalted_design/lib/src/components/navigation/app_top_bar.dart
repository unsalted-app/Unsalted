// lib/src/components/navigation/app_top_bar.dart
//
// Komponente (Teil 1.2): Kopfleiste einer Seite mit Titel, Aktionen und
// optionalem unterem Bereich, z. B. einem Suchfeld (Figma
// `Navigation/Top Bar`). Baut eine `AppBar` (Plan R1).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';

/// Kopfleiste.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Erzeugt die Kopfleiste.
  const AppTopBar({super.key, required this.title, this.actions = const [], this.bottom});

  /// Höhe des unteren Bereichs.
  static const double bottomHeight = 56;

  /// Titel.
  final String title;

  /// Aktionen rechts, z. B. `AppIconButton` und `AppOverflowMenu`.
  final List<Widget> actions;

  /// Unterer Bereich, z. B. `AppSearchField`.
  final Widget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom == null ? 0 : bottomHeight));

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(title),
        actions: actions,
        bottom: bottom == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(bottomHeight),
                child: AppPadding.symmetric(horizontal: AppSpace.l, vertical: AppSpace.s, child: bottom!),
              ),
      );
}
