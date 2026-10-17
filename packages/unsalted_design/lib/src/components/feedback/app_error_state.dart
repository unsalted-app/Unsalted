// lib/src/components/feedback/app_error_state.dart
//
// Komponente (Teil 1.2): Fehlerzustand (Kapitel 22: Klartext + „Erneut
// versuchen“; Figma `Feedback/Error State`). Ohne [onRetry] nur der Text.
// Seit Teil 1.3 (D09, States-Karte) mit Symbol `error` in `text-error`.

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_tone.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../buttons/app_button.dart';
import '../icons/app_icon.dart';
import '../icons/app_icons.dart';
import '../text/app_text.dart';

/// Fehlerzustand, mittig.
class AppErrorState extends StatelessWidget {
  /// Erzeugt den Zustand; mit [onRetry] ist [retryLabel] Pflicht.
  const AppErrorState({super.key, required this.message, this.onRetry, this.retryLabel})
      : assert(onRetry == null || retryLabel != null);

  /// Fehlertext im Klartext.
  final String message;

  /// Aktion „Erneut versuchen“.
  final VoidCallback? onRetry;

  /// Beschriftung der Aktion.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) => Center(
        child: AppPadding.all(
          AppSpace.l,
          child: AppStack(
            crossAxisAlignment: CrossAxisAlignment.center,
            gap: AppSpace.s,
            children: [
              const AppIcon(AppIcons.error, tone: AppTone.error),
              AppText(message, textAlign: TextAlign.center),
              if (onRetry != null) AppButton.tertiary(label: retryLabel!, onPressed: onRetry),
            ],
          ),
        ),
      );
}
