// lib/src/ui/foods/sections/food_list_search_section.dart
//
// Bildschirm 9, Abschnitt „Suche“ (Teil 1.2): Suchfeld unter dem Titel.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Suchfeld der Lebensmittel-Liste.
class FoodListSearchSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const FoodListSearchSection({super.key, required this.controller, required this.onChanged});

  /// Text der Suche.
  final TextEditingController controller;

  /// Meldet jede Änderung der Suche.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) =>
      AppSearchField(hint: 'Suchen …', controller: controller, onChanged: onChanged);
}
