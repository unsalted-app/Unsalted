// lib/src/theme/app_tone.dart
//
// Theme (Teil 1.2): Farbton für Text und Symbole als Rolle statt als Farbe.
// Die Farbe kommt aus dem ColorScheme des Themes.

import 'package:flutter/material.dart';

/// Farbton von Text oder Symbol.
enum AppTone {
  /// Standardfarbe der Umgebung.
  normal,

  /// zurückgenommen (`color/on-surface-variant`).
  muted,

  /// Akzent (`color/primary`).
  primary,

  /// Fehler (`color/error`).
  error;

  /// Farbe im Theme von [context]; `null` für [normal].
  Color? colorOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      normal => null,
      muted => scheme.onSurfaceVariant,
      primary => scheme.primary,
      error => scheme.error,
    };
  }
}
