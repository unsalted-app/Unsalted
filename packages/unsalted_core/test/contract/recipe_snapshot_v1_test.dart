import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_snapshot_v1.dart';

void main() {
  final per100g = NutrientSet(
    energyKcal: Decimal.parse('343'),
    fatG: Decimal.parse('1.2'),
    saturatedFatG: Decimal.parse('0.2'),
    carbsG: Decimal.parse('70'),
    sugarsG: Decimal.parse('1.5'),
    fiberG: Decimal.parse('3.5'),
    proteinG: Decimal.parse('11'),
    saltG: Decimal.parse('0.01'),
    extra: {'sodium_mg': Decimal.parse('4')},
  );

  group('RecipeSnapshotV1', () {
    test('Konstruktion setzt alle Felder', () {
      final snapshot = RecipeSnapshotV1(
        recipe: const RecipeSnapshotRecipe(id: '8b1f', title: 'Pizzateig'),
        version: RecipeSnapshotVersion(
          id: 'c92a',
          parentVersionId: null,
          versionIndex: 3,
          label: 'mit Vorteig',
          servings: 10,
          bakingLossPercent: Decimal.zero,
          finalWeightOverrideG: null,
          notes: null,
          createdAt: DateTime.utc(2026, 9, 19, 10),
          snapshottedAt: DateTime.utc(2026, 9, 19, 12),
        ),
        ingredients: [
          RecipeSnapshotIngredient(
            position: 1,
            name: 'Weizenmehl Type 550',
            quantity: Decimal.parse('600'),
            unit: 'g',
            grams: Decimal.parse('600'),
            per100g: per100g,
          ),
        ],
        steps: const [
          RecipeSnapshotStep(
            position: 1,
            instruction: 'Alles 10 Minuten kneten.',
            timerSeconds: 600,
          ),
        ],
        nutrition: RecipeSnapshotNutrition(
          rawWeightG: Decimal.parse('1000'),
          finalWeightG: Decimal.parse('1000'),
          total: per100g,
          per100g: per100g,
          incomplete: const ['sugars_g'],
          notCalculable: const [],
        ),
      );

      expect(snapshot.formatVersion, 1);
      expect(snapshot.recipe.title, 'Pizzateig');
      expect(snapshot.version.versionIndex, 3);
      expect(snapshot.version.snapshottedAt, DateTime.utc(2026, 9, 19, 12));
      expect(snapshot.ingredients, hasLength(1));
      expect(snapshot.ingredients.first.per100g, per100g);
      expect(snapshot.nutrition.incomplete, contains('sugars_g'));
    });

    test('Zutat ohne verknüpfte Variante hat per100g = null', () {
      final ingredient = RecipeSnapshotIngredient(
        position: 1,
        name: 'Prise Liebe',
        quantity: Decimal.one,
        unit: 'pinch',
        grams: Decimal.parse('0.3'),
      );

      expect(ingredient.per100g, isNull);
    });

    test('nicht berechenbare Zutat hat grams = null', () {
      final ingredient = RecipeSnapshotIngredient(
        position: 1,
        name: 'Olivenöl',
        quantity: Decimal.parse('2'),
        unit: 'tbsp',
      );

      expect(ingredient.grams, isNull);
    });
  });
}