// lib/src/layout/responsive.dart
//
// Layout (Teil 1.2): Material-Fenstergrößen aus den Breakpoint-Tokens. Wer
// nach Breite unterscheidet, fragt `AppWindowSize`, nie eine eigene Zahl.

import 'package:flutter/widgets.dart';

import '../tokens/breakpoint_tokens.dart';

/// Fenstergröße nach Material 3.
enum AppWindowSize {
  /// unter `breakpoint/medium` (Handy hochkant).
  compact,

  /// ab `breakpoint/medium`.
  medium,

  /// ab `breakpoint/expanded` (Tablet).
  expanded,

  /// ab `breakpoint/large` (Desktop).
  large;

  /// Größe für die Breite [width].
  static AppWindowSize forWidth(double width) {
    if (width < AppBreakpoints.medium) return compact;
    if (width < AppBreakpoints.expanded) return medium;
    if (width < AppBreakpoints.large) return expanded;
    return large;
  }

  /// Größe des Fensters von [context].
  static AppWindowSize of(BuildContext context) => forWidth(MediaQuery.sizeOf(context).width);

  /// Spalten eines Rasters: 1 kompakt, 2 mittel, sonst 3.
  int get gridColumns => switch (this) {
        compact => 1,
        medium => 2,
        expanded || large => 3,
      };

  /// `true` ab [other].
  bool isAtLeast(AppWindowSize other) => index >= other.index;
}

/// Baut je nach verfügbarer Breite (nicht Fensterbreite) unterschiedlich.
class ResponsiveBuilder extends StatelessWidget {
  /// Erzeugt den Builder.
  const ResponsiveBuilder({super.key, required this.builder});

  /// Erhält die Größe der verfügbaren Breite.
  final Widget Function(BuildContext context, AppWindowSize size) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => builder(context, AppWindowSize.forWidth(constraints.maxWidth)),
      );
}
