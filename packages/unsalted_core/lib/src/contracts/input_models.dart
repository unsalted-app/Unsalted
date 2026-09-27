import 'package:decimal/decimal.dart';

import '../food/food_variant.dart';
import '../nutrition/nutrient_set.dart';
import '../recipe/recipe_ingredient.dart';
import '../recipe/recipe_step.dart';

/// Kapitel 16.0.1. Bei einem optionalen Patch-Feld bedeutet `null`
/// außerhalb von [PatchField], dass das Zielfeld unverändert bleibt.
/// `PatchField(null)` bedeutet ausdrücklich „Zielfeld auf `null` setzen“.
class PatchField<T> {
  final T value;
  const PatchField(this.value);
}

/// Kapitel 16.0.2. Schreib-Input für `RecipeRepository.updateRecipe`.
class UpdateRecipeCommand {
  final String? title;
  final PatchField<String?>? description;

  const UpdateRecipeCommand({this.title, this.description});
}

/// Kapitel 16.0.3. Schreib-Input für `RecipeRepository.createRecipe`.
class NewRecipe {
  final String title;
  final String? description;

  const NewRecipe({required this.title, this.description});
}

/// Kapitel 16.0.4. Vollständiger Schreib-Input für einen Draft. Enthält
/// keine Snapshot-Felder und kein `state` — ein Draft ist per Definition
/// nicht eingefroren. Die Listen enthalten fachliche
/// `RecipeIngredient`-/`RecipeStep`-Objekte inklusive stabiler `id`
/// (Kapitel 10.7: Upsert-/Soft-Delete-Delta anhand dieser IDs).
class RecipeVersionDraft {
  final String id;
  final String recipeId;
  final String? parentVersionId;
  final int versionIndex;
  final String? label;
  final int? servings;
  final Decimal bakingLossPercent;
  final Decimal? finalWeightOverrideG;
  final String? notes;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  const RecipeVersionDraft({
    required this.id,
    required this.recipeId,
    required this.parentVersionId,
    required this.versionIndex,
    required this.label,
    required this.servings,
    required this.bakingLossPercent,
    required this.finalWeightOverrideG,
    required this.notes,
    required this.ingredients,
    required this.steps,
  });
}

/// Kapitel 16.0.5. Eingabe für `NutritionService.preview` — eine Zutat im
/// Editor, bevor sie gespeichert wird.
class IngredientInput {
  final String displayName;
  final Decimal quantity;
  final String unitCode;
  final FoodVariant? variant;

  const IngredientInput({
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    required this.variant,
  });
}

/// Kapitel 16.0.6. Schreib-Input für `FoodRepository.createVariant`.
class NewFoodVariant {
  final String name;
  final String? brand;
  final String? barcode;
  final FoodSource source;
  final String? sourceRef;
  final Decimal? densityGPerMl;
  final Decimal? gramsPerPiece;
  final Decimal? servingSizeG;
  final NutrientSet nutrients;

  const NewFoodVariant({
    required this.name,
    required this.brand,
    required this.barcode,
    required this.source,
    required this.sourceRef,
    required this.densityGPerMl,
    required this.gramsPerPiece,
    required this.servingSizeG,
    required this.nutrients,
  });
}