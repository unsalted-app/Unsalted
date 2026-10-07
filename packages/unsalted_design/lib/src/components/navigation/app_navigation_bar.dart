// lib/src/components/navigation/app_navigation_bar.dart
//
// Komponente (Teil 1.2): Hauptnavigation der App-Hülle (Figma
// `Navigation/Navigation Bar`). Baut eine `NavigationBar`.

import 'package:flutter/material.dart';

/// Ziel der Hauptnavigation.
@immutable
class AppNavigationDestination {
  /// Erzeugt das Ziel.
  const AppNavigationDestination({required this.icon, required this.label});

  /// Symbol, in der Regel aus `AppIcons`.
  final IconData icon;

  /// Beschriftung.
  final String label;
}

/// Hauptnavigation.
class AppNavigationBar extends StatelessWidget {
  /// Erzeugt die Navigation.
  const AppNavigationBar({super.key, required this.destinations, required this.selectedIndex, required this.onSelected});

  /// Ziele in Reihenfolge.
  final List<AppNavigationDestination> destinations;

  /// Index des aktiven Ziels.
  final int selectedIndex;

  /// Meldet das gewählte Ziel.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final d in destinations) NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      );
}
