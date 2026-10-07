// lib/src/components/feedback/app_skeleton.dart
//
// Komponente (Teil 1.2): Platzhalter beim Laden, ruhig pulsierend; bei
// „Bewegung reduzieren“ ohne Animation (Figma `Feedback/Skeleton`).
// Übernommen aus `ui/shared/skeleton.dart` auf `design/1.1`. Vorerst ohne
// Verwendung: Kapitel 22 verlangt den Ladekreis (Antwort F3).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/motion_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/spacing_tokens.dart';

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
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900), lowerBound: 0.45);

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
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
          widthFactor: widthFactor,
          alignment: Alignment.centerLeft,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        );
    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _pulse,
          child: AppStack(
            gap: AppSpace.m,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < widget.count; i++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: AppPadding.all(
                    AppSpace.l,
                    child: AppStack(gap: AppSpace.s, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      bar(0.55, 18),
                      bar(0.85, 14),
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
