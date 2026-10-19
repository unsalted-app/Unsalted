// lib/src/templates/page_content.dart
//
// Template-Hilfe (Teil 1.3, D11): Rahmen „Inhalt“ der Detail- und
// Formularseiten (Figma `Template/Detail Page`, `Template/Form Page`) — oben
// und unten `space-l`, seitlich der Seitenrand nach Fenstergröße
// (`AppWindowSize.pageMargin`); der Rahmen ist samt Seitenrand höchstens
// `size-content-max` breit und steht mittig (UEBERGABE Punkt 2). Listen stehen
// ohne Seitenrand (Figma `Template/List Page`). Nicht exportiert.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../layout/responsive.dart';
import '../tokens/size_tokens.g.dart';
import '../tokens/spacing_tokens.g.dart';

/// Innenabstand des Rahmens „Inhalt“ bei der verfügbaren Breite [width].
EdgeInsets pageContentPadding(BuildContext context, double width) {
  final margin = AppWindowSize.of(context).pageMargin.value;
  final side = (width - math.min(width, AppSize.contentMax)) / 2 + margin;
  return EdgeInsets.fromLTRB(side, AppSpacing.l, side, AppSpacing.l);
}

/// Baut den Inhalt mit dem Innenabstand des Rahmens „Inhalt“ für die
/// verfügbare Breite.
class PageContent extends StatelessWidget {
  /// Erzeugt den Rahmen.
  const PageContent({super.key, required this.builder});

  /// Erhält den Innenabstand.
  final Widget Function(BuildContext context, EdgeInsets padding) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => builder(context, pageContentPadding(context, constraints.maxWidth)),
      );
}
