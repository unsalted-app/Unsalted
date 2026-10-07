// lib/src/layout/app_page.dart
//
// Layout (Teil 1.2): Seitenrahmen jeder Seite — Kopfleiste, Inhalt,
// Hauptaktion, Fußleiste. Baut vorerst genau ein `Scaffold` (Plan R1).

import 'package:flutter/material.dart';

/// Seitenrahmen.
class AppPage extends StatelessWidget {
  /// Erzeugt den Rahmen.
  const AppPage({super.key, this.topBar, required this.body, this.primaryAction, this.bottomBar});

  /// Kopfleiste, in der Regel `AppTopBar`.
  final PreferredSizeWidget? topBar;

  /// Inhalt.
  final Widget body;

  /// Hauptaktion, in der Regel `AppFab`.
  final Widget? primaryAction;

  /// Leiste am unteren Rand, z. B. die Hauptnavigation.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: topBar,
        body: body,
        floatingActionButton: primaryAction,
        bottomNavigationBar: bottomBar,
      );
}
