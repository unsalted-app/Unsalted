// lib/src/components/feedback/app_notice.dart
//
// Komponente (Teil 1.2): Hinweiszeile, immer mit Symbol (Figma
// `Feedback/Notice`). Fehler in den error-Rollen, Warnungen in den
// tertiary-Rollen, Infos in den secondary-Rollen — alle Paare erfüllen AA
// (DS-05). Übernommen aus `ui/shared/notice.dart` auf `design/1.1`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../icons/app_icons.dart';

/// Art eines Hinweises.
enum AppNoticeKind {
  /// Fehler.
  error,

  /// Warnung.
  warning,

  /// Information.
  info,
}

/// Hinweiszeile mit Symbol, Text und optionaler Aktion.
class AppNotice extends StatelessWidget {
  /// Erzeugt den Hinweis.
  const AppNotice(this.message, {super.key, this.kind = AppNoticeKind.info, this.action});

  /// Text.
  final String message;

  /// Art; bestimmt Farbe und Symbol.
  final AppNoticeKind kind;

  /// Optionale Aktion rechts, z. B. `AppButton.tertiary`.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (kind) {
      AppNoticeKind.error => (scheme.errorContainer, scheme.onErrorContainer, AppIcons.error),
      AppNoticeKind.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer, AppIcons.warning),
      AppNoticeKind.info => (scheme.secondaryContainer, scheme.onSecondaryContainer, AppIcons.info),
    };
    return Semantics(
      container: true,
      liveRegion: kind == AppNoticeKind.error,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.m)),
        child: AppPadding.all(
          AppSpace.m,
          child: AppStack(
            direction: Axis.horizontal,
            gap: AppSpace.m,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, color: foreground, size: 20),
              Expanded(
                child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: foreground)),
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}
