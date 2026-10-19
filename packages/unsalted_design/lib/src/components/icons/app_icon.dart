// lib/src/components/icons/app_icon.dart
//
// Komponente (Teil 1.2): Symbol in Token-Größe und Farbton (Figma `Icon`).
// Baut ein `Icon`; Größe `m` ist die Standardgröße der Umgebung.

import 'package:flutter/material.dart';

import '../../tokens/size_tokens.g.dart';

import '../../theme/app_tone.dart';

/// Größe von [AppIcon].
enum AppIconSize {
  /// `size-icon-xs` (16), z. B. in Marken und Tags.
  xs,

  /// `size-icon-small` (20), z. B. in Buttons und Hinweisen.
  s,

  /// `size-icon` (24), Standard.
  m,
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
          AppIconSize.xs => AppSize.iconXs,
          AppIconSize.s => AppSize.iconSmall,
          AppIconSize.m => AppSize.icon,
        },
        color: tone.colorOf(context),
        semanticLabel: semanticLabel,
      );
}
