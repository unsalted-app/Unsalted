// lib/src/components/navigation/app_navigation_bar.dart
//
// Komponente (Teil 1.2): Hauptnavigation der App-Hülle (Figma
// `Navigation/Navigation Bar`). Seit Teil 1.3 (D10, NavigationBar-Karte) eine
// eigene Komponente statt des Material-`NavigationBar`: Die Auswahl ist ein
// Balken `stroke-rule` in `line-strong` (Breite `size-target`) oben am Ziel
// statt einer Pille; Ziele teilen die Breite; `surface-page`, Haarlinie oben;
// Ziel mit Innenabstand `space-m` oben und `space-s` unten, Symbol
// `size-icon`, Abstand `space-xs`, Beschriftung `label-small`; gewählt
// `text-primary`, sonst `text-secondary`; Mindesthöhe `size-nav-bar`.
// Als Systemleiste folgt sie der Textgröße nicht; langes Drücken zeigt das
// Ziel als Tooltip. [AppNavigationBar.rail] ist dieselbe Navigation als
// seitliche Leiste (Figma `Navigation/Navigation Rail`, Breite
// `size-nav-rail`, Haarlinie rechts) — `AppPage` wählt die Form nach der
// Fensterbreite.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

/// Ein Ziel der Hauptnavigation.
@immutable
class AppNavigationDestination {
  /// Erzeugt das Ziel.
  const AppNavigationDestination({required this.icon, required this.label});

  /// Symbol, in der Regel aus `AppIcons`.
  final IconData icon;

  /// Beschriftung.
  final String label;
}

/// Hauptnavigation unten (oder als seitliche Leiste).
class AppNavigationBar extends StatelessWidget {
  /// Navigationsleiste unten.
  const AppNavigationBar({super.key, required this.destinations, required this.selectedIndex, required this.onSelected})
      : rail = false;

  /// Dieselbe Navigation als seitliche Leiste links.
  const AppNavigationBar.rail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  }) : rail = true;

  /// Ziele in Reihenfolge.
  final List<AppNavigationDestination> destinations;

  /// Index des aktiven Ziels.
  final int selectedIndex;

  /// Meldet das gewählte Ziel.
  final ValueChanged<int> onSelected;

  /// `true`: seitliche Leiste.
  final bool rail;

  /// Gleiche Navigation als seitliche Leiste.
  AppNavigationBar asRail() =>
      AppNavigationBar.rail(destinations: destinations, selectedIndex: selectedIndex, onSelected: onSelected);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final targets = [
      for (var i = 0; i < destinations.length; i++)
        _Destination(destination: destinations[i], selected: i == selectedIndex, onTap: () => onSelected(i)),
    ];
    final Widget content = rail
        ? SafeArea(
            right: false,
            child: SizedBox(
              width: AppSize.navRail,
              child: AppStack(crossAxisAlignment: CrossAxisAlignment.stretch, children: targets),
            ),
          )
        : SafeArea(
            top: false,
            child: AppStack(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              children: [for (final target in targets) Expanded(child: target)],
            ),
          );
    final edge = BorderSide(color: c.lineHairline, width: AppStroke.hairline);
    return MediaQuery.withNoTextScaling(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surfacePage,
            border: rail ? Border(right: edge) : Border(top: edge),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({required this.destination, required this.selected, required this.onTap});

  final AppNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = selected ? c.textPrimary : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: ExcludeSemantics(
        child: Tooltip(
          message: destination.label,
          triggerMode: TooltipTriggerMode.longPress,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSize.navBar),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: AppSize.target,
                        height: AppStroke.rule,
                        child: selected ? ColoredBox(color: c.lineStrong) : null,
                      ),
                    ),
                  ),
                  AppPadding.only(
                    top: AppSpace.m,
                    bottom: AppSpace.s,
                    left: AppSpace.xs,
                    right: AppSpace.xs,
                    child: Center(
                      heightFactor: 1,
                      child: AppStack(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        gap: AppSpace.xs,
                        children: [
                          Icon(destination.icon, size: AppSize.icon, color: color),
                          Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.copyWith(color: color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
