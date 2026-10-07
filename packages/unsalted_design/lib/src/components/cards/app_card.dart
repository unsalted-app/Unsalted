// lib/src/components/cards/app_card.dart
//
// Komponente (Teil 1.2): Fläche mit Inhalt, optional antippbar (Figma
// `Card`). Baut eine `Card`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';

/// Karte.
class AppCard extends StatelessWidget {
  /// Erzeugt die Karte.
  const AppCard({super.key, required this.child, this.onTap, this.padding = AppSpace.l});

  /// Inhalt.
  final Widget child;

  /// Aktion beim Antippen; `null` = nicht antippbar.
  final VoidCallback? onTap;

  /// Innenabstand.
  final AppSpace padding;

  @override
  Widget build(BuildContext context) {
    final content = AppPadding.all(padding, child: child);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
