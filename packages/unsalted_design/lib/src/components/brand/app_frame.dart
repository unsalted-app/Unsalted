// lib/src/components/brand/app_frame.dart
//
// Markenelement (Teil 1.3, D07): Zustandsrahmen und Leerstelle (Figma
// `Frame` · `state=provisional/fixed`, `Slot`; Frame-Karte). Der Rahmen fasst
// einen Arbeitsstand ein — gestrichelt in `state-draft`, solange er
// vorläufig ist, durchgezogen in `state-frozen`, sobald er fest ist;
// `stroke-frame`, `radius-s`, Innenabstand `space-m`/`space-l`, Abstand
// `space-s`; Kopfzeile mit Marke und Zustandswort (`label-small`,
// `text-secondary`). Die Leerstelle ist sein leerer Zwilling: gestrichelt, mit
// Punktraster, Symbol, einem Satz und einer Aktion. Dazu die gestrichelte
// Unterstreichung für noch nicht verknüpfte Einträge. Strichlinien gibt es
// nur hier und in der vorläufigen Marke.
// Seit Teil 1.4 (M00b, Figma `Frame` `135:55`, fest `135:47`): Marke und
// Zustandswort stehen senkrecht mittig zueinander; der Innenabstand ist
// `space-m`/`space-l` + `stroke-frame` — die Kontur zählt zum Innenabstand
// wie in Figma (beide Zustände).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';
import 'dashed_painter.dart';
import 'dot_pattern.dart';

/// Zustandsrahmen.
class AppFrame extends StatelessWidget {
  /// Vorläufiger Stand: Strichlinie.
  const AppFrame.provisional({super.key, this.mark, this.caption, required this.child}) : fixed = false;

  /// Fester Stand: durchgezogene Tintenlinie.
  const AppFrame.fixed({super.key, this.mark, this.caption, required this.child}) : fixed = true;

  /// `true`: fester Stand.
  final bool fixed;

  /// Marke in der Kopfzeile, in der Regel eine `AppMark`.
  final Widget? mark;

  /// Zustand als Wort in der Kopfzeile.
  final String? caption;

  /// Inhalt.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.m + AppStroke.frame,
        horizontal: AppSpacing.l + AppStroke.frame,
      ),
      child: AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        gap: AppSpace.s,
        children: [
          if (mark != null || caption != null)
            AppStack(
              direction: Axis.horizontal,
              gap: AppSpace.s,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ?mark,
                if (caption != null)
                  Flexible(child: Text(caption!, style: AppTypography.labelSmall.copyWith(color: c.textSecondary))),
              ],
            ),
          child,
        ],
      ),
    );
    if (fixed) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.s),
          border: Border.all(color: c.stateFrozen, width: AppStroke.frame),
        ),
        child: content,
      );
    }
    return CustomPaint(
      painter: DashedPainter.border(color: c.stateDraft, width: AppStroke.frame, radius: AppRadius.s),
      child: content,
    );
  }
}

/// Leerstelle: gestrichelte Fläche mit Punktraster, Symbol, Satz und Aktion.
class AppSlot extends StatelessWidget {
  /// Erzeugt die Leerstelle.
  const AppSlot({super.key, this.icon, required this.message, this.action, this.pattern = true});

  /// Symbol, in der Regel aus `AppIcons`.
  final IconData? icon;

  /// Ein Satz.
  final String message;

  /// Eine Aktion, in der Regel ein `AppButton`.
  final Widget? action;

  /// `false`: ohne Punktraster (z. B. „keine Treffer“ — die Liste ist nicht
  /// leer, nur gefiltert).
  final bool pattern;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: CustomPaint(
        painter: pattern ? DotPatternPainter(color: c.lineDot) : null,
        foregroundPainter: DashedPainter.border(color: c.stateDraft, width: AppStroke.frame, radius: AppRadius.s),
        child: AppPadding.symmetric(
          vertical: AppSpace.xl,
          horizontal: AppSpace.l,
          child: AppStack(
            crossAxisAlignment: CrossAxisAlignment.center,
            gap: AppSpace.s,
            children: [
              if (icon != null) Icon(icon, size: AppSize.icon, color: c.textSecondary),
              Text(message, textAlign: TextAlign.center, style: AppTypography.body.copyWith(color: c.textPrimary)),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}

/// Gestrichelte Unterstreichung: Eintrag ist noch nicht verknüpft. Seit
/// Teil 1.4 (B01, Figma-Hinweis 2) `space-xxs` unter dem Inhalt, nicht im
/// Layout — auf der Feldkante wäre sie hell unsichtbar (`state-draft` =
/// `line-control`).
class AppDashedUnderline extends StatelessWidget {
  /// Unterstreicht [child] gestrichelt in `state-draft`.
  const AppDashedUnderline({super.key, required this.child});

  /// Unterstrichener Inhalt.
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
        foregroundPainter: DashedPainter.underline(
          color: AppColors.of(context).stateDraft,
          width: AppStroke.frame,
          offset: AppSpacing.xxs,
        ),
        child: child,
      );
}
