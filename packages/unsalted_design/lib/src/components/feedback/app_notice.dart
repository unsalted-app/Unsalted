// lib/src/components/feedback/app_notice.dart
//
// Komponente (Teil 1.2): Hinweiszeile, immer mit Symbol (Figma
// `Feedback/Notice`). Fehler in den error-Rollen, Warnungen in den
// tertiary-Rollen, Infos in den secondary-Rollen — alle Paare erfüllen AA
// (DS-05). Übernommen aus `ui/shared/notice.dart` auf `design/1.1`. Seit
// Teil 1.3 (D09, Notice-Karte): Fehler und Warnung auf den
// feedback-Flächen, Info und Erfolg neutral auf `surface-sunken` mit Symbol in
// `text-secondary`; `radius-s`, Innenabstand und Abstand `space-m`, Symbol
// `size-icon-small` um `space-xxs` abgesenkt, Text `body`. Seit D13a steht
// eine Aktion rechtsbündig unter dem Text, sobald dem Text daneben weniger
// als `reflow-label-min` bliebe (große Schrift, 28.10.11).
// Seit Teil 1.4 (M00b, Figma `Feedback/Notice`, Instanz `42:2034`): Steht die
// Aktion neben dem Text, fluchtet ihre Beschriftung mit der ersten Textzeile
// (wie das Symbol). Dafür sitzt der obere Innenabstand im Text statt um die
// ganze Zeile; das Tippziel der Aktion (mindestens `size-target`) darf so in
// den Innenabstand ragen. Die Beschriftung der Aktion verteilt den
// Zeilenabstand wie der Text gleichmäßig (wie Figma; Material-Knöpfe sonst
// proportional), sonst lägen die Zeilen trotz gleicher Grundlinie versetzt.
// Untereinander (große Schrift) und ohne Aktion unverändert.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../layout/reflow_row.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_reflow.dart';
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
    final text = Text(message, style: AppTypography.body.copyWith(color: foreground));
    final symbol = Icon(icon, color: iconColor, size: AppSize.iconSmall);
    return Semantics(
      container: true,
      liveRegion: kind == AppNoticeKind.error,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.s)),
        child: action == null
            ? AppPadding.all(
                AppSpace.m,
                child: AppStack(
                  direction: Axis.horizontal,
                  gap: AppSpace.m,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Um `space-xxs` abgesenkt, damit das Symbol mit der ersten Zeile fluchtet.
                    AppPadding.only(top: AppSpace.xxs, child: symbol),
                    Expanded(child: text),
                  ],
                ),
              )
            : Padding(
                // Oben kein Innenabstand: Er sitzt im Text, damit das Tippziel der
                // Aktion hineinragen darf.
                padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
                child: AppStack(
                  direction: Axis.horizontal,
                  gap: AppSpace.m,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: AppSpacing.m + AppSpacing.xxs), child: symbol),
                    Expanded(
                      child: ReflowRow(
                        main: AppPadding.only(top: AppSpace.m, child: text),
                        trailing: DefaultTextHeightBehavior(
                          textHeightBehavior: const TextHeightBehavior(
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                          child: action!,
                        ),
                        gap: AppSpacing.m,
                        mainMin: AppReflowMetric.labelMin.of(context),
                        baseline: true,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
