import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../food/food_variant.dart';
import '../../nutrition/nutrient_set.dart';
import '../core_database.dart' as db;

/// Drift-generierte Zeile `db.FoodVariant` -> Fachmodell `FoodVariant`
/// (Kapitel 10.6). Die 8 einzelnen Nährwertspalten + extra_json werden zu
/// einem eingebetteten `NutrientSet` zusammengeführt (Kapitel 8.1, 10.6).
/// ownerId wird bewusst nicht übernommen (Kapitel 10.6, wie Recipe.ownerId).
FoodVariant foodVariantFromRow(db.FoodVariant row) {
  final rawExtra = jsonDecode(row.extraJson) as Map<String, dynamic>;
  final extra = rawExtra.map(
    (key, value) => MapEntry(key, Decimal.parse(value as String)),
  );

  return FoodVariant(
    id: row.id,
    name: row.name,
    brand: row.brand,
    barcode: row.barcode,
    source: FoodSource.fromCode(row.source),
    sourceRef: row.sourceRef,
    densityGPerMl: row.densityGPerMl,
    gramsPerPiece: row.gramsPerPiece,
    servingSizeG: row.servingSizeG,
    nutrients: NutrientSet(
      energyKcal: row.energyKcal,
      fatG: row.fatG,
      saturatedFatG: row.saturatedFatG,
      carbsG: row.carbsG,
      sugarsG: row.sugarsG,
      fiberG: row.fiberG,
      proteinG: row.proteinG,
      saltG: row.saltG,
      extra: extra,
    ),
  );
}

Map<String, dynamic> _extraToJsonMap(Map<String, Decimal> extra) =>
    extra.map((key, value) => MapEntry(key, value.toString()));

/// Fachmodell -> Companion für INSERT.
db.FoodVariantsCompanion foodVariantToInsertCompanion(
  FoodVariant variant, {
  required int createdAtMs,
  required int updatedAtMs,
  String? ownerId,
}) {
  final n = variant.nutrients;
  return db.FoodVariantsCompanion.insert(
    id: variant.id,
    createdAt: createdAtMs,
    updatedAt: updatedAtMs,
    name: variant.name,
    brand: Value(variant.brand),
    barcode: Value(variant.barcode),
    source: variant.source.code,
    sourceRef: Value(variant.sourceRef),
    ownerId: Value(ownerId),
    densityGPerMl: Value(variant.densityGPerMl),
    gramsPerPiece: Value(variant.gramsPerPiece),
    servingSizeG: Value(variant.servingSizeG),
    energyKcal: Value(n.energyKcal),
    fatG: Value(n.fatG),
    saturatedFatG: Value(n.saturatedFatG),
    carbsG: Value(n.carbsG),
    sugarsG: Value(n.sugarsG),
    fiberG: Value(n.fiberG),
    proteinG: Value(n.proteinG),
    saltG: Value(n.saltG),
    extraJson: Value(jsonEncode(_extraToJsonMap(n.extra))),
  );
}

/// Fachmodell -> Companion für UPDATE (ohne id).
db.FoodVariantsCompanion foodVariantToUpdateCompanion(
  FoodVariant variant, {
  required int updatedAtMs,
}) {
  final n = variant.nutrients;
  return db.FoodVariantsCompanion(
    updatedAt: Value(updatedAtMs),
    name: Value(variant.name),
    brand: Value(variant.brand),
    barcode: Value(variant.barcode),
    source: Value(variant.source.code),
    sourceRef: Value(variant.sourceRef),
    densityGPerMl: Value(variant.densityGPerMl),
    gramsPerPiece: Value(variant.gramsPerPiece),
    servingSizeG: Value(variant.servingSizeG),
    energyKcal: Value(n.energyKcal),
    fatG: Value(n.fatG),
    saturatedFatG: Value(n.saturatedFatG),
    carbsG: Value(n.carbsG),
    sugarsG: Value(n.sugarsG),
    fiberG: Value(n.fiberG),
    proteinG: Value(n.proteinG),
    saltG: Value(n.saltG),
    extraJson: Value(jsonEncode(_extraToJsonMap(n.extra))),
  );
}