// lib/src/recipe/recipe_ingredient.dart
//
// Fachmodell für eine Zutatenzeile (Kapitel 10.5 der neuen Spezifikation).
// Trägt `id` — Identität für UI-Listenoperationen/Drag-Reorder (Bildschirm 3),
// unabhängig von `position`, das sich während eines Reorders für mehrere
// Zeilen gleichzeitig ändert. `RecipeChange` (Kapitel 14) adressiert trotzdem
// weiterhin über `position`, nicht über `id` — beide dienen verschiedenen
// Zwecken. Siehe docs/decisions.md.

import 'package:decimal/decimal.dart';

const Object _unset = Object();

class RecipeIngredient {
  final String id;
  final String versionId;

  /// 1-basiert, lückenlos innerhalb einer Version (Kapitel 11.4).
  final int position;

  /// null = freie Zutat ohne Nährwerte (Kapitel 11.4).
  final String? foodVariantId;

  /// Angezeigter Name, auch wenn eine Variante verknüpft ist.
  final String displayName;

  /// >= 0 (Kapitel 11.4). Die Prüfung selbst liegt bei RecipeChange.validate()
  /// bzw. UnitCatalog.toGrams (Schritt 2.2), nicht in dieser reinen Entität.
  final Decimal quantity;

  /// Code aus UnitCatalog (Kapitel 9).
  final String unitCode;

  /// z. B. "zimmerwarm" (Kapitel 11.4).
  final String? note;

  const RecipeIngredient({
    required this.id,
    required this.versionId,
    required this.position,
    this.foodVariantId,
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    this.note,
  });

  RecipeIngredient copyWith({
    String? id,
    String? versionId,
    int? position,
    Object? foodVariantId = _unset,
    String? displayName,
    Decimal? quantity,
    String? unitCode,
    Object? note = _unset,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      versionId: versionId ?? this.versionId,
      position: position ?? this.position,
      foodVariantId:
          identical(foodVariantId, _unset) ? this.foodVariantId : foodVariantId as String?,
      displayName: displayName ?? this.displayName,
      quantity: quantity ?? this.quantity,
      unitCode: unitCode ?? this.unitCode,
      note: identical(note, _unset) ? this.note : note as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeIngredient &&
        id == other.id &&
        versionId == other.versionId &&
        position == other.position &&
        foodVariantId == other.foodVariantId &&
        displayName == other.displayName &&
        quantity == other.quantity &&
        unitCode == other.unitCode &&
        note == other.note;
  }

  @override
  int get hashCode => Object.hash(
        id,
        versionId,
        position,
        foodVariantId,
        displayName,
        quantity,
        unitCode,
        note,
      );

  @override
  String toString() =>
      'RecipeIngredient(id: $id, position: $position, displayName: $displayName, '
      'quantity: $quantity $unitCode)';
}