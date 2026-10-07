// lib/src/components/feedback/app_loading.dart
//
// Komponente (Teil 1.2): Ladezustand (Kapitel 22: zentrierter Ladekreis;
// Figma `Feedback/Loading`) und Ladebalken (Figma `Feedback/Progress Bar`).

import 'package:flutter/material.dart';

/// Zentrierter Ladekreis.
class AppLoading extends StatelessWidget {
  /// Erzeugt den Ladezustand.
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

/// Ladebalken über die volle Breite.
class AppProgressBar extends StatelessWidget {
  /// Erzeugt den Balken.
  const AppProgressBar({super.key});

  @override
  Widget build(BuildContext context) => const LinearProgressIndicator();
}
