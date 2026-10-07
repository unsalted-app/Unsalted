// lib/src/components/surfaces/app_surface.dart
//
// Komponente (Teil 1.2): getönte Fläche mit Innenabstand (Figma
// `Surface/<ton>`), z. B. eine Leiste über dem Inhalt oder ein schlichter
// Hinweiskasten. Die Töne `info`, `warning`, `error` färben auch Text und
// Symbole im Inhalt passend (`on…Container`). Für Hinweise mit Symbol gibt
// es `AppNotice`.

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

  /// Information: `color/secondary-container`, Inhalt `color/on-secondary-container`.
  info,

  /// Warnung: `color/tertiary-container`, Inhalt `color/on-tertiary-container`.
  warning,

  /// Fehler: `color/error-container`, Inhalt `color/on-error-container`.
  error,
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
    final (background, foreground) = switch (tone) {
      AppSurfaceTone.low => (scheme.surfaceContainerLow, null),
      AppSurfaceTone.medium => (scheme.surfaceContainer, null),
      AppSurfaceTone.high => (scheme.surfaceContainerHigh, null),
      AppSurfaceTone.info => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      AppSurfaceTone.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      AppSurfaceTone.error => (scheme.errorContainer, scheme.onErrorContainer),
    };
    Widget content = AppPadding.all(padding, child: child);
    if (foreground != null) {
      content = IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: DefaultTextStyle.merge(style: TextStyle(color: foreground), child: content),
      );
    }
    return ColoredBox(
      color: background,
      child: SizedBox(width: fullWidth ? double.infinity : null, child: content),
    );
  }
}
