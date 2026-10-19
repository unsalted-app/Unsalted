// lib/src/components/feedback/app_empty_state.dart
//
// Komponente (Teil 1.2): leerer Zustand (Kapitel 22: Symbol, ein Satz,
// Primäraktion; Figma `Feedback/Empty State`). Symbol und Aktion sind
// optional, z. B. „Keine Treffer.“ ohne beides.
//
// Seit Teil 1.3 (D09, States-Karte): Mit Aktion ist der leere Zustand eine
// Leerstelle (`AppSlot`: Strichlinie, Punktraster, Symbol `size-icon`, Satz,
// Aktion); ohne Aktion (z. B. „nicht gefunden“) nur Symbol und Satz, ohne
// Rahmen und Punktraster.

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../brand/app_frame.dart';
import '../icons/app_icon.dart';
import '../text/app_text.dart';

/// Leerer Zustand einer Seite.
class AppEmptyState extends StatelessWidget {
  /// Erzeugt den Zustand.
  const AppEmptyState({super.key, required this.message, this.icon, this.action});

  /// Satz, z. B. „Noch keine Einträge.“.
  final String message;

  /// Symbol über dem Satz.
  final IconData? icon;

  /// Hauptaktion, z. B. `AppButton.primary`.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    if (action != null) {
      return Center(
        child: SingleChildScrollView(
          child: AppPadding.all(AppSpace.l, child: AppSlot(icon: icon, message: message, action: action)),
        ),
      );
    }
    return Center(
      child: AppStack(
        gap: AppSpace.s,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) AppIcon(icon!),
          AppText(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
