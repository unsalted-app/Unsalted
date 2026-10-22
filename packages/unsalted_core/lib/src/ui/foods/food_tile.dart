// lib/src/ui/foods/food_tile.dart
//
// Fachlicher Baustein (Teil 1.2): ein Lebensmittel in der Liste — Name und
// optional Marke. Seit Teil 1.4 (T03): [FoodTile.selected] zeigt den
// Auswahlbalken (Liste und Editor nebeneinander).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../food/food_variant.dart';

/// Listeneintrag eines Lebensmittels.
class FoodTile extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const FoodTile({super.key, required this.variant, required this.onTap, this.selected = false});

  /// Das Lebensmittel.
  final FoodVariant variant;

  /// Öffnet das Lebensmittel.
  final VoidCallback onTap;

  /// `true`: im Detailbereich geöffnet (Auswahlbalken).
  final bool selected;

  @override
  Widget build(BuildContext context) =>
      AppListItem(title: variant.name, subtitle: variant.brand, onTap: onTap, selected: selected);
}
