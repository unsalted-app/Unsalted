import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';
import 'package:unsalted_core/src/recipe/recipe_diff.dart';
import 'package:unsalted_core/src/recipe/recipe_snapshot_v1.dart';

RecipeSnapshotV1 _snapshot({
  String title = 'Testrezept',
  String? notes,
  Decimal? bakingLossPercent,
  Decimal? finalWeightOverrideG,
  int? servings,
  List<RecipeSnapshotIngredient>? ingredients,
  List<RecipeSnapshotStep>? steps,
}) {
  final empty = const NutrientSet();
  return RecipeSnapshotV1(
    recipe: RecipeSnapshotRecipe(id: 'r1', title: title),
    version: RecipeSnapshotVersion(
      id: 'v1',
      versionIndex: 1,
      bakingLossPercent: bakingLossPercent ?? Decimal.zero,
      finalWeightOverrideG: finalWeightOverrideG,
      notes: notes,
      servings: servings,
      createdAt: DateTime.utc(2026, 1, 1),
      snapshottedAt: DateTime.utc(2026, 1, 1),
    ),
    ingredients: ingredients ??
        [
          RecipeSnapshotIngredient(
            position: 1,
            name: 'Mehl',
            quantity: Decimal.parse('500'),
            unit: 'g',
            grams: Decimal.parse('500'),
          ),
        ],
    steps: steps ??
        const [
          RecipeSnapshotStep(position: 1, instruction: 'Mischen.'),
        ],
    nutrition: RecipeSnapshotNutrition(
      rawWeightG: Decimal.parse('500'),
      finalWeightG: Decimal.parse('500'),
      total: empty,
      per100g: empty,
      incomplete: const [],
      notCalculable: const [],
    ),
  );
}

RecipeSnapshotIngredient _ing(
  int position,
  String name,
  String quantity,
  String unit, {
  String? brand,
  String? barcode,
  String? note,
}) {
  return RecipeSnapshotIngredient(
    position: position,
    name: name,
    brand: brand,
    barcode: barcode,
    quantity: Decimal.parse(quantity),
    unit: unit,
    note: note,
  );
}

void main() {
  group('RecipeDiff.between', () {
    test('DF-01 identische Snapshots -> leere Liste', () {
      final a = _snapshot();
      final b = _snapshot();
      expect(RecipeDiff.between(a, b), isEmpty);
    });

    test('DF-02 Menge geändert -> SetIngredientQuantity', () {
      final a = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g')]);
      final b = _snapshot(ingredients: [_ing(1, 'Mehl', '600', 'g')]);

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as SetIngredientQuantity;
      expect(change.position, 1);
      expect(change.quantity, Decimal.parse('600'));
      expect(change.unitCode, isNull); // Einheit unverändert
    });

    test('DF-03 Einheit geändert bei gleicher Grammzahl -> dennoch Änderung', () {
      final a = _snapshot(
        ingredients: [_ing(1, 'Butter', '1', 'tbsp')],
      );
      final b = _snapshot(
        ingredients: [_ing(1, 'Butter', '15', 'g')],
      );

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as SetIngredientQuantity;
      expect(change.unitCode, 'g');
      expect(change.quantity, Decimal.parse('15'));
    });

    test('DF-04 Zutat hinzugefügt -> AddIngredient', () {
      final a = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g')]);
      final b = _snapshot(
        ingredients: [
          _ing(1, 'Mehl', '500', 'g'),
          _ing(2, 'Salz', '10', 'g'),
        ],
      );

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as AddIngredient;
      expect(change.position, 2);
      expect(change.displayName, 'Salz');
      expect(change.foodVariantId, isNull);
    });

    test('DF-05 Zutat entfernt -> RemoveIngredient', () {
      final a = _snapshot(
        ingredients: [
          _ing(1, 'Mehl', '500', 'g'),
          _ing(2, 'Salz', '10', 'g'),
        ],
      );
      final b = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g')]);

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as RemoveIngredient;
      expect(change.position, 2);
    });

    test('DF-06 Zutat ersetzt -> ReplaceIngredient', () {
  final a = _snapshot(
    ingredients: [_ing(1, 'Mehl', '500', 'g', barcode: '4001234567890')],
  );
  final b = _snapshot(
    ingredients: [
      _ing(1, 'Dinkelmehl', '500', 'g', barcode: '4001234567890'),
    ],
  );

  final changes = RecipeDiff.between(a, b);

    expect(changes, hasLength(1));
    final change = changes.single as ReplaceIngredient;
    expect(change.position, 1);
    expect(change.displayName, 'Dinkelmehl');
    expect(change.foodVariantId, isNull);
    });

    test('DF-07 nur verschoben -> MoveIngredient', () {
      final a = _snapshot(
        ingredients: [
          _ing(1, 'Mehl', '500', 'g'),
          _ing(2, 'Zucker', '100', 'g'),
          _ing(3, 'Salz', '10', 'g'),
        ],
      );
      final b = _snapshot(
        ingredients: [
          _ing(1, 'Salz', '10', 'g'),
          _ing(2, 'Mehl', '500', 'g'),
          _ing(3, 'Zucker', '100', 'g'),
        ],
      );

      final changes = RecipeDiff.between(a, b);

      expect(changes, isNotEmpty);
      expect(changes, everyElement(isA<MoveIngredient>()));

      // Die berechnete Move-Folge muss a tatsächlich in b überführen.
      final order = ['Mehl', 'Zucker', 'Salz'];
      for (final c in changes.cast<MoveIngredient>()) {
        final tag = order.removeAt(c.from - 1);
        order.insert(c.to - 1, tag);
      }
      expect(order, ['Salz', 'Mehl', 'Zucker']);
    });

    test('DF-08 Schritt geändert -> SetStep', () {
      final a = _snapshot(
        steps: const [RecipeSnapshotStep(position: 1, instruction: 'Kneten.')],
      );
      final b = _snapshot(
        steps: const [
          RecipeSnapshotStep(
            position: 1,
            instruction: 'Kneten.',
            timerSeconds: 300,
          ),
        ],
      );

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as SetStep;
      expect(change.position, 1);
      expect(change.instruction, isNull); // unverändert
      expect(change.timerSeconds!.value, 300);
    });

    test('DF-09 Backverlust geändert -> SetBakingLoss', () {
      final a = _snapshot(bakingLossPercent: Decimal.zero);
      final b = _snapshot(bakingLossPercent: Decimal.parse('12.5'));

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as SetBakingLoss;
      expect(change.percent, Decimal.parse('12.5'));
    });

    test('DF-10 Portionen geändert -> SetServings', () {
      final a = _snapshot(servings: null);
      final b = _snapshot(servings: 4);

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as SetServings;
      expect(change.servings, 4);
    });

    test('DF-12 doppelte Zutaten werden positionsweise zugeordnet', () {
      final a = _snapshot(
        ingredients: [
          _ing(1, 'Mehl', '500', 'g'),
          _ing(2, 'Mehl', '50', 'g', note: 'zum Bestäuben'),
        ],
      );
      final b = _snapshot(
        ingredients: [
          _ing(1, 'Mehl', '600', 'g'),
          _ing(2, 'Mehl', '50', 'g', note: 'zum Bestäuben'),
        ],
      );

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      final change = changes.single as SetIngredientQuantity;
      expect(change.position, 1);
      expect(change.quantity, Decimal.parse('600'));
    });
  });
}