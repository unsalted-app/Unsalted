import 'package:decimal/decimal.dart';

import '../nutrition/nutrition_result.dart';
import 'input_models.dart';

/// Kapitel 16.3. Öffentlicher Vertrag, über die Tür exportiert. Kennt
/// `RecipeRepository` nicht und wird nicht von ihm referenziert; liest
/// über eigene DAO-Zugriffe bzw. `SnapshotService`. Implementierung folgt
/// in Schritt 6.5 (`DriftNutritionService`).
abstract class NutritionService {
  /// state = draft: live aus den Zeilen berechnet.
  /// state = snapshot: aus snapshot_json decodiert (Kapitel 10.8).
  Future<NutritionResult> forVersion(String versionId);

  /// Reine Vorschau ohne Speichern, für den Editor.
  NutritionResult preview({
    required List<IngredientInput> ingredients,
    required Decimal bakingLossPercent,
    Decimal? finalWeightOverrideG,
    int? servings,
  });
}