// lib/src/ui/foods/sections/food_list_results_section.dart
//
// Bildschirm 9, Abschnitt „Treffer“ (Teil 1.2): Lebensmittel als Liste;
// nach links wischen löscht (mit „Rückgängig“, Teil 1.1b).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../food/food_variant.dart';
import '../food_tile.dart';

/// Trefferliste der Lebensmittel.
class FoodListResultsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const FoodListResultsSection({super.key, required this.variants, required this.onOpen, required this.onDelete});

  /// Anzuzeigende Lebensmittel.
  final List<FoodVariant> variants;

  /// Öffnet ein Lebensmittel.
  final ValueChanged<FoodVariant> onOpen;

  /// Löscht ein weggewischtes Lebensmittel.
  final ValueChanged<FoodVariant> onDelete;

  @override
  Widget build(BuildContext context) => AppItemList.builder(
        itemCount: variants.length,
        itemBuilder: (context, index) {
          final variant = variants[index];
          return AppSwipeToDelete(
            key: ValueKey('food-${variant.id}'),
            onDelete: () => onDelete(variant),
            child: FoodTile(variant: variant, onTap: () => onOpen(variant)),
          );
        },
      );
}
