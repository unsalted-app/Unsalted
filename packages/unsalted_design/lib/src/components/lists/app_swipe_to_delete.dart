// lib/src/components/lists/app_swipe_to_delete.dart
//
// Komponente (Teil 1.2): Eintrag, der sich nach links wegwischen lässt
// (Figma `List/Swipe to Delete`). Hintergrund mit Löschsymbol in den
// error-container-Rollen, übernommen aus `DeleteSwipeBackground`
// (unsalted_core, Teil 1.1b). Baut ein `Dismissible`; [key] muss den Eintrag
// eindeutig kennzeichnen.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';
import '../icons/app_icons.dart';

/// Wegwischbarer Eintrag.
class AppSwipeToDelete extends StatelessWidget {
  /// Erzeugt den Eintrag; [key] kennzeichnet ihn eindeutig.
  const AppSwipeToDelete({required Key super.key, required this.onDelete, required this.child});

  /// Aktion nach dem Wegwischen.
  final VoidCallback onDelete;

  /// Inhalt.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: colors.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: AppPadding.symmetric(
            horizontal: AppSpace.xl,
            child: Icon(AppIcons.delete, color: colors.onErrorContainer),
          ),
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: child,
    );
  }
}
