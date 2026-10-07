// lib/src/ui/foods/food_tile.dart
//
// Fachlicher Baustein (Teil 1.2): ein Lebensmittel in der Liste — Name und
// optional Marke.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../food/food_variant.dart';

/// Listeneintrag eines Lebensmittels.
class FoodTile extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const FoodTile({super.key, required this.variant, required this.onTap});

  /// Das Lebensmittel.
  final FoodVariant variant;

  /// Öffnet das Lebensmittel.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppListItem(title: variant.name, subtitle: variant.brand, onTap: onTap);
}
