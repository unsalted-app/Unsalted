import 'package:decimal/decimal.dart';

import '../food/food_variant.dart';
import '../nutrition/nutrient_set.dart';
import '../recipe/recipe_ingredient.dart';
import '../recipe/recipe_step.dart';

/// Kapitel 16.0.1. Bei einem optionalen Patch-Feld bedeutet `null`
/// außerhalb von [PatchField], dass das Zielfeld unverändert bleibt.
/// `PatchField(null)` bedeutet ausdrücklich „Zielfeld auf `null` setzen“.
class PatchField<T> {
  /// Der zu setzende Wert; `null` setzt das Zielfeld auf `null`.
  final T value;
  /// Umhüllt [value].
  const PatchField(this.value);
}

/// Kapitel 16.0.2. Schreib-Input für `RecipeRepository.updateRecipe`.
class UpdateRecipeCommand {
  /// Neuer Titel oder `null`, wenn der Titel unverändert bleibt.
  final String? title;
  /// `null` = Beschreibung unverändert; sonst der neue Wert, auch `null`.
  final PatchField<String?>? description;

  /// Erzeugt den Befehl; nicht angegebene Felder bleiben unverändert.
  const UpdateRecipeCommand({this.title, this.description});
}

/// Kapitel 16.0.3. Schreib-Input für `RecipeRepository.createRecipe`.
class NewRecipe {
  /// Titel des neuen Rezepts, 1–200 Zeichen (Kapitel 16.1).
  final String title;
  /// Optionale Beschreibung.
  final String? description;

  /// Erzeugt den Input für `RecipeRepository.createRecipe`.
  const NewRecipe({required this.title, this.description});
}

/// Kapitel 16.0.4. Vollständiger Schreib-Input für einen Draft. Enthält
/// keine Snapshot-Felder und kein `state` — ein Draft ist per Definition
/// nicht eingefroren. Die Listen enthalten fachliche
/// `RecipeIngredient`-/`RecipeStep`-Objekte inklusive stabiler `id`
/// (Kapitel 10.7: Upsert-/Soft-Delete-Delta anhand dieser IDs).
class RecipeVersionDraft {
  /// ID der Draft-Version, die gespeichert wird.
  final String id;
  /// ID des Rezepts, zu dem die Version gehört.
  final String recipeId;
  /// Herkunftsversion oder `null` (Kapitel 12.1).
  final String? parentVersionId;
  /// Fortlaufende Versionsnummer je Rezept, ab `1` (Kapitel 12.1).
  final int versionIndex;
  /// Optionaler, rein informativer Zusatztext (Kapitel 12.1).
  final String? label;
  /// Portionen (`>= 1`) oder `null`.
  final int? servings;
  /// Backverlust in Prozent, `0`–`100` (Kapitel 8.4).
  final Decimal bakingLossPercent;
  /// Übersteuertes Fertiggewicht in Gramm (`> 0`) oder `null` (Kapitel 8.4).
  final Decimal? finalWeightOverrideG;
  /// Notizen zur Version oder `null`.
  final String? notes;
  /// Vollständige Zutatenliste mit stabilen IDs; `saveDraft` gleicht sie per
  /// Upsert-/Soft-Delete-Delta ab (Kapitel 10.7).
  final List<RecipeIngredient> ingredients;
  /// Vollständige Schrittliste mit stabilen IDs; `saveDraft` gleicht sie per
  /// Upsert-/Soft-Delete-Delta ab (Kapitel 10.7).
  final List<RecipeStep> steps;

  /// Erzeugt den Input für `RecipeRepository.saveDraft`.
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
  /// Anzeigename der Zutat.
  final String displayName;
  /// Menge in der Einheit [unitCode].
  final Decimal quantity;
  /// Einheitencode aus `UnitCatalog` (Kapitel 9).
  final String unitCode;
  /// Verknüpftes Lebensmittel oder `null`; ohne Lebensmittel gelten die
  /// Nährwerte der Zutat als unbekannt (Kapitel 8.5).
  final FoodVariant? variant;

  /// Erzeugt die Eingabe für `NutritionService.preview`.
  const IngredientInput({
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    required this.variant,
  });
}

/// Kapitel 16.0.6. Schreib-Input für `FoodRepository.createVariant`.
class NewFoodVariant {
  /// Name des Lebensmittels.
  final String name;
  /// Marke oder `null`.
  final String? brand;
  /// EAN oder `null`; dient der Duplikaterkennung beim Import (Kapitel 13.6).
  final String? barcode;
  /// Herkunft des Lebensmittels (Kapitel 11.6).
  final FoodSource source;
  /// Fremd-ID der Quelle oder `null` (Kapitel 11.6).
  final String? sourceRef;
  /// Dichte in g/ml für Volumeneinheiten oder `null` (Kapitel 9).
  final Decimal? densityGPerMl;
  /// Gewicht eines Stücks in Gramm für die Einheit `piece` oder `null` (Kapitel 9).
  final Decimal? gramsPerPiece;
  /// „Portion laut Packung“ in Gramm oder `null` (Kapitel 11.6).
  final Decimal? servingSizeG;
  /// Die acht Nährwertfelder und `extra`, alle pro 100 g (Kapitel 8.1).
  final NutrientSet nutrients;

  /// Erzeugt den Input; `FoodRepository.createVariant` prüft die Nährwerte mit
  /// dem Validator (Kapitel 8.6).
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