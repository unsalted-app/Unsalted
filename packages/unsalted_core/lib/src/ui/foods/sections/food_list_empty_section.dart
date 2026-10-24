// lib/src/ui/foods/sections/food_list_empty_section.dart
//
// Bildschirm 9, Abschnitt „leer“ (Teil 1.2): kein Lebensmittel gefunden, mit
// Aktion „Eigenes Produkt anlegen“ (Kapitel 22).
//
// Seit Teil 1.4 (B03, Figma-Nachtrag N2 `09 Lebensmittel-Liste / Keine
// Treffer` 218:3919): Mit Suchbegriff ohne Ergebnis „Keine Treffer.“ mit
// Symbol, ohne Aktion und ohne Leerstelle (wie Bildschirm 1); ohne
// Suchbegriff unverändert.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Leerer Zustand der Lebensmittel-Liste.
class FoodListEmptySection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const FoodListEmptySection({super.key, required this.onCreate, this.searching = false});

  /// Legt ein neues Lebensmittel an.
  final VoidCallback onCreate;

  /// `true`: ein Suchbegriff ist gesetzt — „Keine Treffer.“ ohne Aktion.
  final bool searching;

  @override
  Widget build(BuildContext context) => AppEmptyState(
        icon: AppIcons.emptyPlate,
        message: searching ? 'Keine Treffer.' : 'Keine Lebensmittel gefunden.',
        action: searching ? null : AppButton.primary(label: 'Eigenes Produkt anlegen', onPressed: onCreate),
      );
}
