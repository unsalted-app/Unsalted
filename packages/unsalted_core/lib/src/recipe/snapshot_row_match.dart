// lib/src/recipe/snapshot_row_match.dart
//
// Fehlerbehebung 9.1a (docs/decisions.md): Das Snapshot-Format (Kapitel
// 13.1) trägt keine Variant-ID. Wo eine Snapshot-Zutat wieder mit einem
// Lebensmittel verknüpft werden muss (Draft-Kopie, F1; Diff-Zielzeilen, F3),
// kommt die ID aus der Zeile derselben Version an gleicher Position -- aber
// nur, wenn diese Zeile nachweislich zur Snapshot-Zutat gehört. Nicht über
// die öffentliche Tür exportiert.

import 'recipe_ingredient.dart';
import 'recipe_snapshot_v1.dart';

/// `foodVariantId` der Zeile an der Position von [ingredient], sofern Name,
/// Menge (Decimal-Wert) und Einheit übereinstimmen; sonst `null`.
String? linkedVariantIdFor(RecipeSnapshotIngredient ingredient, List<RecipeIngredient> rows) {
  for (final row in rows) {
    if (row.position != ingredient.position) continue;
    final matches = row.displayName == ingredient.name &&
        row.quantity == ingredient.quantity &&
        row.unitCode == ingredient.unit;
    return matches ? row.foodVariantId : null;
  }
  return null;
}
