// lib/src/layout/app_page.dart
//
// Layout (Teil 1.2): Seitenrahmen jeder Seite — Kopfleiste, Inhalt,
// Hauptaktion, Fußleiste. Baut vorerst genau ein `Scaffold` (Plan R1).
//
// Seit Teil 1.3 (D10): Slot [AppPage.navigation] für die Hauptnavigation, die
// sich nach der Fensterbreite richtet (Material 3, nach Breite, nicht nach
// Ausrichtung): unter `breakpoint-medium` als Leiste unten, ab
// `breakpoint-medium` als seitliche Leiste links (UEBERGABE Punkt 2).

import 'package:flutter/material.dart';

import '../components/navigation/app_navigation_bar.dart';
import 'responsive.dart';

/// Seitenrahmen.
class AppPage extends StatelessWidget {
  /// Erzeugt den Rahmen.
  const AppPage({super.key, this.topBar, required this.body, this.primaryAction, this.bottomBar, this.navigation});

  /// Kopfleiste, in der Regel `AppTopBar`.
  final PreferredSizeWidget? topBar;

  /// Inhalt.
  final Widget body;

  /// Hauptaktion, in der Regel `AppFab`.
  final Widget? primaryAction;

  /// Leiste am unteren Rand, z. B. eine Aktionsleiste.
  final Widget? bottomBar;

  /// Hauptnavigation: unten bzw. ab `breakpoint-medium` links.
  final AppNavigationBar? navigation;

  @override
  Widget build(BuildContext context) {
    final nav = navigation;
    final side = nav != null && AppWindowSize.of(context).isAtLeast(AppWindowSize.medium);
    final scaffold = Scaffold(
      appBar: topBar,
      body: body,
      floatingActionButton: primaryAction,
      bottomNavigationBar: side ? bottomBar : (nav ?? bottomBar),
    );
    if (!side) return scaffold;
    return Material(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [nav.asRail(), Expanded(child: scaffold)],
      ),
    );
  }
}
