// lib/src/layout/app_section.dart
//
// Layout (Teil 1.2): Abschnitt einer Seite — optional Trennlinie und fette
// Überschrift, darunter die Kinder in voller Breite (Figma `Layout/Section`).

import 'package:flutter/widgets.dart';

import '../components/surfaces/app_divider.dart';
import '../components/text/app_text.dart';
import '../tokens/spacing_tokens.dart';
import 'app_stack.dart';

/// Abschnitt.
class AppSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const AppSection({super.key, this.title, this.divider = true, required this.children});

  /// Überschrift; `null` = keine.
  final String? title;

  /// `true`: Trennlinie davor (Gesamthöhe `space/xxl`).
  final bool divider;

  /// Inhalt.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (divider) const AppDivider(space: AppSpace.xxl),
          if (title != null) AppText.strong(title!),
          ...children,
        ],
      );
}
