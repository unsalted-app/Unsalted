// lib/src/components/feedback/app_empty_state.dart
//
// Komponente (Teil 1.2): leerer Zustand (Kapitel 22: Symbol, ein Satz,
// Primäraktion; Figma `Feedback/Empty State`). Symbol und Aktion sind
// optional, z. B. „Keine Treffer.“ ohne beides.

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';
import '../icons/app_icon.dart';
import '../text/app_text.dart';

/// Leerer Zustand, mittig.
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
  Widget build(BuildContext context) => Center(
        child: AppStack(
          gap: AppSpace.s,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) AppIcon(icon!, size: AppIconSize.l),
            AppText(message, textAlign: TextAlign.center),
            ?action,
          ],
        ),
      );
}
