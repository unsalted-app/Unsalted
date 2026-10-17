// lib/src/theme/app_colors.dart
//
// Farbrollen im Kontext (Teil 1.3, D06): Komponenten brauchen Rollen, die das
// Material-`ColorScheme` nicht kennt (`line-strong`, `marker`, `state-draft`,
// `line-dot` …). Sie lesen sie hier passend zur Helligkeit des Themes —
// ohne ThemeExtension, damit es auch unter einem `MaterialApp` ohne
// Design-Theme gilt (Core-Tests: hell). Nicht über die Tür exportiert.

import 'package:flutter/material.dart';

import '../tokens/color_tokens.g.dart';

/// Farbrollen des Modus im [BuildContext].
abstract final class AppColors {
  /// Rollen für die Helligkeit des Themes an [context].
  static AppColorTokens of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
}
