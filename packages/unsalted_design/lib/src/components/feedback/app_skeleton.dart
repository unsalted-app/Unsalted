// lib/src/components/feedback/app_skeleton.dart
//
// Komponente (Teil 1.2): Platzhalter beim Laden, ruhig pulsierend; bei
// „Bewegung reduzieren“ ohne Animation (Figma `Feedback/Skeleton`).
// Übernommen aus `ui/shared/skeleton.dart` auf `design/1.1`. Vorerst ohne
// Verwendung: Kapitel 22 verlangt den Ladekreis (Antwort F3). Seit Teil 1.3
// (D09) aus Tokens: Zeilen wie Listeneinträge (Haarlinie), Balken in
// `surface-sunken`, Puls `duration-long` bis `opacity-scrim`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_reflow.dart';
import '../../tokens/motion_tokens.g.dart';
import '../../tokens/opacity_tokens.g.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

/// [count] Platzhalterblöcke.
class AppSkeleton extends StatefulWidget {
  /// Erzeugt das Skelett.
  const AppSkeleton({super.key, required this.semanticLabel, this.count = 6});

  /// Text für Screenreader, z. B. „Wird geladen“.
  final String semanticLabel;

  /// Anzahl der Blöcke.
  final int count;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: AppMotion.long, lowerBound: AppOpacity.scrim);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotion(context)) {
      _pulse
        ..stop()
        ..value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget bar(double height, {double? width}) => SizedBox(
          height: height,
          width: width,
          child: DecoratedBox(
            decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.xs)),
          ),
        );
    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _pulse,
          child: AppStack(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < widget.count; i++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
                  ),
                  child: AppPadding.symmetric(
                    vertical: AppSpace.m,
                    horizontal: AppSpace.l,
                    child: AppStack(gap: AppSpace.s, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      bar(AppTypography.bodyStrong.fontSize!, width: AppSize.dialog),
                      bar(AppTypography.bodySmall.fontSize!, width: AppReflowMetric.labelMin.of(context)),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
