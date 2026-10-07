// lib/src/components/surfaces/app_surface.dart
//
// Komponente (Teil 1.2): getönte Fläche mit Innenabstand (Figma
// `Surface/<ton>`), z. B. eine Leiste über dem Inhalt. Für Hinweise mit
// Symbol gibt es `AppNotice`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';

/// Ton einer [AppSurface].
enum AppSurfaceTone {
  /// `color/surface-container-low`
  low,

  /// `color/surface-container`
  medium,

  /// `color/surface-container-high`
  high,
}

/// Getönte Fläche.
class AppSurface extends StatelessWidget {
  /// Erzeugt die Fläche.
  const AppSurface({
    super.key,
    required this.child,
    this.tone = AppSurfaceTone.medium,
    this.padding = AppSpace.m,
    this.fullWidth = false,
  });

  /// Inhalt.
  final Widget child;

  /// Ton.
  final AppSurfaceTone tone;

  /// Innenabstand.
  final AppSpace padding;

  /// `true`: so breit wie möglich.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: switch (tone) {
        AppSurfaceTone.low => scheme.surfaceContainerLow,
        AppSurfaceTone.medium => scheme.surfaceContainer,
        AppSurfaceTone.high => scheme.surfaceContainerHigh,
      },
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: AppPadding.all(padding, child: child),
      ),
    );
  }
}
