// lib/src/data/drift_nutrition_service.dart
//
// Implementierung von NutritionService (Kapitel 16.3, Schritt 6.5).
//
// Kapitel 17: `forVersion` liest je nach `state` entweder die aktuellen
// Zeilen (Draft) oder das decodierte `snapshotJson` (Snapshot, Kapitel
// 10.8) und ruft in BEIDEN Fällen `NutritionEngine.calculate(...)` mit den
// daraus abgeleiteten `IngredientInput`-Werten auf — auch für Snapshots,
// obwohl deren `nutrition`-Objekt im Snapshot-JSON bereits das fertige
// Ergebnis enthält. Das ist bewusst keine Abkürzung (einfaches Decodieren
// von `snapshot.nutrition`), sondern folgt Kapitel 17 wörtlich: ein
// einziger Berechnungspfad für Draft und Snapshot, nur die Herkunft der
// Zutatenliste unterscheidet sich. Da die per100g-Kopien im Snapshot
// eingefroren sind, liefert diese Neuberechnung deterministisch dasselbe
// Ergebnis wie das gespeicherte `nutrition`-Objekt (IT-04) und bleibt auch
// nach späteren Änderungen der verknüpften FoodVariant unverändert (IT-02).
//
// `preview` greift nicht auf die Datenbank zu (Kapitel 16.3/17).

import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../contracts/core_exceptions.dart';
import '../contracts/input_models.dart';
import '../contracts/nutrition_service.dart';
import '../food/food_variant.dart';
import '../nutrition/nutrition_engine.dart' as engine;
import '../nutrition/nutrition_result.dart';
import '../recipe/recipe_version.dart';
import '../recipe/snapshot_codec.dart';
import 'core_database.dart' as db;
import 'daos/food_dao.dart';
import 'daos/recipe_dao.dart';
import 'mappers/food_mapper.dart';

class DriftNutritionService implements NutritionService {
  DriftNutritionService(this._recipeDao, this._foodDao);

  final RecipeDao _recipeDao;
  final FoodDao _foodDao;

  @override
  Future<NutritionResult> forVersion(String versionId) async {
    final row = await _recipeDao.getVersion(versionId);
    if (row == null) {
      throw NotFoundException('Version "$versionId" nicht gefunden.');
    }

    final List<engine.IngredientInput> ingredients;
    final Decimal bakingLossPercent;
    final Decimal? finalWeightOverrideG;
    final int? servings;

    if (row.state == VersionState.snapshot.code) {
      final decoded = SnapshotCodec.decode(
        jsonDecode(row.snapshotJson!) as Map<String, dynamic>,
      );
      ingredients = decoded.ingredients
          .map((si) => engine.IngredientInput(
                displayName: si.name,
                quantity: si.quantity,
                unitCode: si.unit,
                per100g: si.per100g,
                densityGPerMl: si.densityGPerMl,
                gramsPerPiece: si.gramsPerPiece,
              ))
          .toList();
      bakingLossPercent = decoded.version.bakingLossPercent;
      finalWeightOverrideG = decoded.version.finalWeightOverrideG;
      servings = decoded.version.servings;
    } else {
      final ingredientRows = await _recipeDao.getIngredientsForVersion(versionId);
      final variants = await _resolveVariants(ingredientRows);
      ingredients = ingredientRows.map((r) {
        final variant = r.foodVariantId == null ? null : variants[r.foodVariantId];
        return engine.IngredientInput(
          displayName: r.displayName,
          quantity: r.quantity,
          unitCode: r.unitCode,
          per100g: variant?.nutrients,
          densityGPerMl: variant?.densityGPerMl,
          gramsPerPiece: variant?.gramsPerPiece,
        );
      }).toList();
      bakingLossPercent = row.bakingLossPercent;
      finalWeightOverrideG = row.finalWeightOverrideG;
      servings = row.servings;
    }

    return engine.NutritionEngine.calculate(
      ingredients: ingredients,
      bakingLossPercent: bakingLossPercent,
      finalWeightOverrideG: finalWeightOverrideG,
      servings: servings,
    );
  }

  @override
  NutritionResult preview({
    required List<IngredientInput> ingredients,
    required Decimal bakingLossPercent,
    Decimal? finalWeightOverrideG,
    int? servings,
  }) {
    final engineIngredients = ingredients
        .map((i) => engine.IngredientInput(
              displayName: i.displayName,
              quantity: i.quantity,
              unitCode: i.unitCode,
              per100g: i.variant?.nutrients,
              densityGPerMl: i.variant?.densityGPerMl,
              gramsPerPiece: i.variant?.gramsPerPiece,
            ))
        .toList();

    return engine.NutritionEngine.calculate(
      ingredients: engineIngredients,
      bakingLossPercent: bakingLossPercent,
      finalWeightOverrideG: finalWeightOverrideG,
      servings: servings,
    );
  }

  Future<Map<String, FoodVariant>> _resolveVariants(
    List<db.RecipeIngredientRow> ingredientRows,
  ) async {
    final ids = {
      for (final row in ingredientRows)
        if (row.foodVariantId != null) row.foodVariantId!,
    };
    final result = <String, FoodVariant>{};
    for (final id in ids) {
      final row = await _foodDao.getById(id);
      if (row != null) result[id] = foodVariantFromRow(row);
    }
    return result;
  }
}
