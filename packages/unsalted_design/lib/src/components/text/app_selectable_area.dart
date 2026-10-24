// lib/src/components/text/app_selectable_area.dart
//
// Komponente (Teil 1.4, B05): Bereich mit markierbarem und kopierbarem Text
// (Figma `Input/Text Selection`, Muster „Textauswahl“). Baut eine
// `SelectionArea`; Markierung, Griffe und Cursor kommen aus dem Theme
// (`selection` × `opacity-selection`, `selection-handle`), das Kontextmenü
// von der Plattform.

import 'package:flutter/material.dart';

/// Markierbarer Text in [child].
class AppSelectableArea extends StatelessWidget {
  /// Macht den Text in [child] markierbar und kopierbar.
  const AppSelectableArea({super.key, required this.child});

  /// Inhalt mit markierbarem Text.
  final Widget child;

  @override
  Widget build(BuildContext context) => SelectionArea(child: child);
}
