// lib/src/components/data/app_code_block.dart
//
// Komponente (Teil 1.2): langer, auswählbarer Text, z. B. ein Datenexport
// (Figma `Data/Code Block`). Scrollt selbst.

import 'package:flutter/material.dart';

/// Auswählbarer Langtext.
class AppCodeBlock extends StatelessWidget {
  /// Erzeugt den Block.
  const AppCodeBlock(this.text, {super.key});

  /// Inhalt.
  final String text;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(child: SelectableText(text));
}
