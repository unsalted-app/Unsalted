// lib/src/components/feedback/app_notice.dart
//
// Komponente (Teil 1.2): Hinweiszeile, immer mit Symbol (Figma
// `Feedback/Notice`). Fehler in den error-Rollen, Warnungen in den
// tertiary-Rollen, Infos in den secondary-Rollen — alle Paare erfüllen AA
// (DS-05). Übernommen aus `ui/shared/notice.dart` auf `design/1.1`. Seit
// Teil 1.3 (D09, Notice-Karte): Fehler und Warnung auf den
// feedback-Flächen, Info und Erfolg neutral auf `surface-sunken` mit Symbol in
// `text-secondary`; `radius-s`, Innenabstand und Abstand `space-m`, Symbol
// `size-icon-small` um `space-xxs` abgesenkt, Text `body`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../icons/app_icons.dart';

/// Art eines Hinweises.
enum AppNoticeKind {
  /// Fehler.
  error,

  /// Warnung.
  warning,

  /// Information.
  info,

  /// Erfolg (wie Information, Symbol `check`; Teil 1.3).
  success,
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
    final c = AppColors.of(context);
    final (background, foreground, iconColor, icon) = switch (kind) {
      AppNoticeKind.error => (c.feedbackErrorSurface, c.feedbackOnErrorSurface, c.feedbackOnErrorSurface, AppIcons.error),
      AppNoticeKind.warning =>
        (c.feedbackWarningSurface, c.feedbackOnWarningSurface, c.feedbackOnWarningSurface, AppIcons.warning),
      AppNoticeKind.info => (c.surfaceSunken, c.textPrimary, c.textSecondary, AppIcons.info),
      AppNoticeKind.success => (c.surfaceSunken, c.textPrimary, c.textSecondary, AppIcons.check),
    };
    return Semantics(
      container: true,
      liveRegion: kind == AppNoticeKind.error,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.s)),
        child: AppPadding.all(
          AppSpace.m,
          child: AppStack(
            direction: Axis.horizontal,
            gap: AppSpace.m,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Um `space-xxs` abgesenkt, damit das Symbol mit der ersten Zeile fluchtet.
              AppPadding.only(
                top: AppSpace.xxs,
                child: Icon(icon, color: iconColor, size: AppSize.iconSmall),
              ),
              Expanded(child: Text(message, style: AppTypography.body.copyWith(color: foreground))),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}
