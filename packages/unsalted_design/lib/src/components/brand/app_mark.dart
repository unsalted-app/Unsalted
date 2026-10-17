// lib/src/components/brand/app_mark.dart
//
// Markenelement (Teil 1.3, D07): Zustandsmarke (Figma `Mark`,
// `state=provisional/fixed/highlighted`, Mark-Karte). Gestrichelt heißt
// vorläufig, Tintenkontur fest, Markerfläche hervorgehoben; Höhe mindestens
// `size-mark`, Innenabstand `space-s`, `label-small` mit tabellarischen
// Ziffern, `radius-xs`, Linie `stroke-frame`; optional das Siegel `lock`.
// Der Aufrufer liefert Text und Screenreader-Text (der Zustand gehört in die
// Semantik, nie nur in Farbe oder Linie). Mit [AppMark.onTap] ist die Marke
// ein Auswahlziel (mindestens `size-target`); gewählt zeigt ein Balken
// `stroke-rule` in `line-strong` unter der Marke die Auswahl — nie die Füllung.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';
import '../icons/app_icons.dart';
import 'dashed_painter.dart';

/// Zustand einer [AppMark].
enum AppMarkState {
  /// vorläufig: Strichlinie in `state-draft`.
  provisional,

  /// fest: Tintenkontur in `state-frozen`.
  fixed,

  /// hervorgehoben: Markerfläche `state-master`.
  highlighted,
}

/// Zustandsmarke.
class AppMark extends StatelessWidget {
  /// Erzeugt die Marke.
  const AppMark({
    super.key,
    required this.label,
    required this.state,
    this.seal = false,
    this.semanticLabel,
    this.selected = false,
    this.onTap,
  });

  /// Sichtbarer Text, z. B. eine Kennung.
  final String label;

  /// Zustand.
  final AppMarkState state;

  /// `true`: Siegel (`lock`) vor dem Text.
  final bool seal;

  /// Screenreader-Text mit Zustand; `null` = [label].
  final String? semanticLabel;

  /// `true`: als gewählt markiert (nur mit [onTap]).
  final bool selected;

  /// Aktion beim Antippen; `null` = keine Schaltfläche.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final (Color foreground, Color? fill, Color line) = switch (state) {
      AppMarkState.provisional => (c.textSecondary, null, c.stateDraft),
      AppMarkState.fixed => (c.textPrimary, null, c.stateFrozen),
      AppMarkState.highlighted => (c.textOnMarker, c.stateMaster, c.textOnMarker),
    };
    final content = AppPadding.symmetric(
      horizontal: AppSpace.s,
      child: AppStack(
        direction: Axis.horizontal,
        gap: AppSpace.xs,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (seal) Icon(AppIcons.lock, size: AppSize.iconXs, color: foreground),
          Text(label, style: AppTypography.labelSmall.copyWith(color: foreground)),
        ],
      ),
    );
    final radius = BorderRadius.circular(AppRadius.xs);
    final Widget box = state == AppMarkState.provisional
        ? CustomPaint(
            painter: DashedPainter.border(color: line, width: AppStroke.frame, radius: AppRadius.xs),
            child: content,
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(color: line, width: AppStroke.frame),
            ),
            child: content,
          );
    final mark = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.mark),
      child: Center(widthFactor: 1, heightFactor: 1, child: box),
    );

    final semantics = semanticLabel ?? label;
    if (onTap == null) {
      return Semantics(label: semantics, child: ExcludeSemantics(child: mark));
    }
    return Semantics(
      label: semantics,
      button: true,
      selected: selected,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          // Figma `Core/Version Switcher`: Ziel mindestens `size-target`,
          // oben `space-xs`, Abstand `space-xs`, darunter der Balken in voller
          // Breite des Ziels.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: AppSize.target, minHeight: AppSize.target),
            child: IntrinsicWidth(
              child: AppPadding.only(
                top: AppSpace.xs,
                child: AppStack(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  gap: AppSpace.xs,
                  children: [
                    mark,
                    SizedBox(height: AppStroke.rule, child: selected ? ColoredBox(color: c.lineStrong) : null),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
