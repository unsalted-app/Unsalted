// lib/src/layout/app_stack.dart
//
// Layout (Teil 1.2): Abstände nur als Token-Stufe. `AppGap` ist ein einzelner
// Abstand, `AppStack` reiht Kinder mit gleichem Abstand, `AppPadding` setzt
// Innenabstand. Ersetzt `SizedBox`/`EdgeInsets` mit Zahlen in Bildschirmen.

import 'package:flutter/widgets.dart';

import '../tokens/spacing_tokens.dart';

/// Ein Abstand der Stufe [space], waagrecht und senkrecht gleich groß.
class AppGap extends StatelessWidget {
  /// Erzeugt den Abstand.
  const AppGap(this.space, {super.key});

  /// Stufe des Abstands.
  final AppSpace space;

  @override
  Widget build(BuildContext context) => SizedBox(width: space.value, height: space.value);
}

/// Kinder untereinander (oder nebeneinander) mit Abstand [gap].
class AppStack extends StatelessWidget {
  /// Erzeugt die Anordnung.
  const AppStack({
    super.key,
    required this.children,
    this.gap,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  /// Inhalt.
  final List<Widget> children;

  /// Abstand zwischen zwei Kindern; `null` = kein Abstand.
  final AppSpace? gap;

  /// Senkrecht (Standard) oder waagrecht.
  final Axis direction;

  /// Ausrichtung quer zur Richtung.
  final CrossAxisAlignment crossAxisAlignment;

  /// Platzbedarf in Richtung.
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0 && gap != null) AppGap(gap!),
        children[i],
      ],
    ];
    return Flex(
      direction: direction,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spaced,
    );
  }
}

/// Innenabstand in Token-Stufen.
class AppPadding extends StatelessWidget {
  /// Ringsum gleich.
  const AppPadding.all(AppSpace space, {super.key, required this.child})
      : left = space,
        top = space,
        right = space,
        bottom = space;

  /// Waagrecht und senkrecht getrennt.
  const AppPadding.symmetric({super.key, AppSpace? horizontal, AppSpace? vertical, required this.child})
      : left = horizontal,
        right = horizontal,
        top = vertical,
        bottom = vertical;

  /// Je Seite einzeln.
  const AppPadding.only({super.key, this.left, this.top, this.right, this.bottom, required this.child});

  /// Abstand links; `null` = 0.
  final AppSpace? left;

  /// Abstand oben; `null` = 0.
  final AppSpace? top;

  /// Abstand rechts; `null` = 0.
  final AppSpace? right;

  /// Abstand unten; `null` = 0.
  final AppSpace? bottom;

  /// Inhalt.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(left?.value ?? 0, top?.value ?? 0, right?.value ?? 0, bottom?.value ?? 0),
        child: child,
      );
}
