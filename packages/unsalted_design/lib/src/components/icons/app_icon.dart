// lib/src/components/icons/app_icon.dart
//
// Komponente (Teil 1.2): Symbol in Token-Größe und Farbton (Figma `Icon`).
// Baut ein `Icon`; Größe `m` ist die Standardgröße der Umgebung.

import 'package:flutter/material.dart';

import '../../theme/app_tone.dart';

/// Größe von [AppIcon].
enum AppIconSize {
  /// Standardgröße der Umgebung (24).
  m,

  /// groß, z. B. im leeren Zustand (48).
  l,
}

/// Ein Symbol.
class AppIcon extends StatelessWidget {
  /// Erzeugt das Symbol [icon], in der Regel aus `AppIcons`.
  const AppIcon(this.icon, {super.key, this.size = AppIconSize.m, this.tone = AppTone.normal, this.semanticLabel});

  /// Symbol.
  final IconData icon;

  /// Größe.
  final AppIconSize size;

  /// Farbton.
  final AppTone tone;

  /// Text für Screenreader; `null` = dekorativ.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Icon(
        icon,
        size: switch (size) {
          AppIconSize.m => null,
          AppIconSize.l => 48,
        },
        color: tone.colorOf(context),
        semanticLabel: semanticLabel,
      );
}
