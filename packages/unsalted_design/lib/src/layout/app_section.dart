// lib/src/layout/app_section.dart
//
// Layout (Teil 1.2): Abschnitt einer Seite (Figma `Layout/Section`). Seit
// Teil 1.3 (D06) nach der Section-Karte: `space-xxl` davor, Abschnittslinie
// (`stroke-rule` in `line-strong`), `space-m`, Überschrift in `heading`
// (rechts optional Metadaten in `caption`/`text-secondary`), `space-s`,
// darunter die Kinder in voller Breite. Ohne Trennlinie (erster Abschnitt)
// entfallen Abstand und Linie.

import 'package:flutter/widgets.dart';

import '../components/surfaces/app_divider.dart';
import '../components/text/app_text.dart';
import '../theme/app_tone.dart';
import '../tokens/spacing_tokens.g.dart';
import 'app_stack.dart';

/// Abschnitt mit Linie, Überschrift und Inhalt.
class AppSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const AppSection({super.key, this.title, this.meta, this.divider = true, required this.children});

  /// Überschrift; `null` = keine.
  final String? title;

  /// Metadaten rechts neben der Überschrift; `null` = keine.
  final String? meta;

  /// `true`: Abstand `space-xxl` und Abschnittslinie davor.
  final bool divider;

  /// Inhalt.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (divider) ...[const AppGap(AppSpace.xxl), const AppDivider.rule(), const AppGap(AppSpace.m)],
          if (title != null) ...[
            AppStack(
              direction: Axis.horizontal,
              gap: AppSpace.m,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: AppText.heading(title!)),
                if (meta != null) AppText.caption(meta!, tone: AppTone.muted),
              ],
            ),
            const AppGap(AppSpace.s),
          ],
          ...children,
        ],
      );
}
