import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';
import 'package:unsalted_core/src/recipe/recipe_diff.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
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
  NutrientSet? per100g,
  String? densityGPerMl,
  String? gramsPerPiece,
}) {
  return RecipeSnapshotIngredient(
    position: position,
    name: name,
    brand: brand,
    barcode: barcode,
    quantity: Decimal.parse(quantity),
    unit: unit,
    note: note,
    per100g: per100g,
    densityGPerMl: densityGPerMl == null ? null : Decimal.parse(densityGPerMl),
    gramsPerPiece: gramsPerPiece == null ? null : Decimal.parse(gramsPerPiece),
  );
}

RecipeIngredient _row(int position, String name, String quantity, String unit, String? variantId) =>
    RecipeIngredient(
      id: 'row-$position',
      versionId: 'vb',
      position: position,
      foodVariantId: variantId,
      displayName: name,
      quantity: Decimal.parse(quantity),
      unitCode: unit,
    );

/// Wendet Remove/Add/Move einer Änderungsliste auf eine Namensliste an
/// (Kapitel 14.4: jede Position bezieht sich auf den Stand davor).
List<String> _applyOrder(List<String> names, List<RecipeChange> changes) {
  final list = [...names];
  for (final c in changes) {
    switch (c) {
      case RemoveIngredient(:final position):
        list.removeAt(position - 1);
      case AddIngredient(:final position, :final displayName):
        list.insert(position - 1, displayName);
      case MoveIngredient(:final from, :final to):
        list.insert(to - 1, list.removeAt(from - 1));
      default:
    }
  }
  return list;
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

    test('DF-13 Remove + Move berechnet from/to auf der virtuellen Liste', () {
      final a = _snapshot(ingredients: [
        _ing(1, 'Mehl', '300', 'g'),
        _ing(2, 'Zucker', '100', 'g'),
        _ing(3, 'Salz', '1', 'pinch'),
        _ing(4, 'Butter', '200', 'g'),
      ]);
      final b = _snapshot(ingredients: [
        _ing(1, 'Salz', '1', 'pinch'),
        _ing(2, 'Mehl', '300', 'g'),
        _ing(3, 'Butter', '200', 'g'),
      ]);

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(2));
      expect((changes[0] as RemoveIngredient).position, 2);
      final move = changes[1] as MoveIngredient;
      expect((move.from, move.to), (2, 1));
      expect(_applyOrder(['Mehl', 'Zucker', 'Salz', 'Butter'], changes), ['Salz', 'Mehl', 'Butter']);
    });

    test('DF-13b Add + Move führt zur Reihenfolge von b', () {
      final a = _snapshot(ingredients: [
        _ing(1, 'Mehl', '200', 'g'),
        _ing(2, 'Milch', '400', 'g'),
        _ing(3, 'Salz', '1', 'pinch'),
      ]);
      final b = _snapshot(ingredients: [
        _ing(1, 'Milch', '400', 'g'),
        _ing(2, 'Zucker', '20', 'g'),
        _ing(3, 'Mehl', '200', 'g'),
        _ing(4, 'Salz', '1', 'pinch'),
      ]);

      final changes = RecipeDiff.between(a, b);

      expect(changes.whereType<AddIngredient>(), hasLength(1));
      expect(changes.whereType<MoveIngredient>(), isNotEmpty);
      expect(_applyOrder(['Mehl', 'Milch', 'Salz'], changes), ['Milch', 'Zucker', 'Mehl', 'Salz']);
    });

    test('DF-14 mit targetRows tragen Add und Replace die foodVariantId von b', () {
      final a = _snapshot(ingredients: [_ing(1, 'Butter', '125', 'g')]);
      final b = _snapshot(ingredients: [
        _ing(1, 'Butter', '125', 'g', brand: 'Alpenhof'),
        _ing(2, 'Ei', '2', 'piece'),
      ]);

      final changes = RecipeDiff.between(a, b, targetRows: [
        _row(1, 'Butter', '125', 'g', 'v-butter'),
        _row(2, 'Ei', '2', 'piece', 'v-ei'),
      ]);

      expect(changes.whereType<ReplaceIngredient>().single.foodVariantId, 'v-butter');
      expect(changes.whereType<AddIngredient>().single.foodVariantId, 'v-ei');
    });

    test('DF-15 ohne targetRows oder bei abweichender Zeile bleibt foodVariantId null', () {
      final a = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g')]);
      final b = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g'), _ing(2, 'Ei', '2', 'piece')]);

      final withoutRows = RecipeDiff.between(a, b).whereType<AddIngredient>().single;
      final mismatchingRow = RecipeDiff.between(a, b, targetRows: [
        _row(1, 'Mehl', '500', 'g', 'v-mehl'),
        _row(2, 'Ei', '3', 'piece', 'v-ei'),
      ]).whereType<AddIngredient>().single;

      expect(withoutRows.foodVariantId, isNull);
      expect(mismatchingRow.foodVariantId, isNull);
    });

    test('DF-16 gleicher Name, Barcode nur in b → dieselbe Zutat (15.1)', () {
      final a = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g')]);
      final b = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g', barcode: '4000000000017')]);

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      expect((changes.single as ReplaceIngredient).position, 1);
    });

    test('DF-17 gleicher Name, verschiedene Barcodes → ReplaceIngredient', () {
      final a = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g', barcode: '4000000000017')]);
      final b = _snapshot(ingredients: [_ing(1, 'Mehl', '500', 'g', barcode: '4000000000024')]);

      final changes = RecipeDiff.between(a, b);

      expect(changes, hasLength(1));
      expect(changes.single, isA<ReplaceIngredient>());
    });

    test('DF-18 abweichende per100g → ReplaceIngredient', () {
      final a = _snapshot(ingredients: [
        _ing(1, 'Mehl', '500', 'g', per100g: NutrientSet(energyKcal: Decimal.parse('343'))),
      ]);
      final b = _snapshot(ingredients: [
        _ing(1, 'Mehl', '500', 'g', per100g: NutrientSet(energyKcal: Decimal.parse('350'))),
      ]);

      expect(RecipeDiff.between(a, b).single, isA<ReplaceIngredient>());
    });

    test('DF-19 abweichende Dichte oder abweichendes Stückgewicht → ReplaceIngredient', () {
      final base = _snapshot(ingredients: [_ing(1, 'Milch', '250', 'ml', densityGPerMl: '1.03')]);
      final density = _snapshot(ingredients: [_ing(1, 'Milch', '250', 'ml', densityGPerMl: '1.032')]);
      final piece = _snapshot(ingredients: [
        _ing(1, 'Milch', '250', 'ml', densityGPerMl: '1.03', gramsPerPiece: '58'),
      ]);

      expect(RecipeDiff.between(base, density).single, isA<ReplaceIngredient>());
      expect(RecipeDiff.between(base, piece).single, isA<ReplaceIngredient>());
    });

    test('DF-20 Variantendaten werden als Decimal-Wert verglichen (600 == 600.0)', () {
      final a = _snapshot(ingredients: [
        _ing(1, 'Mehl', '500', 'g',
            densityGPerMl: '1',
            per100g: NutrientSet(energyKcal: Decimal.parse('600'), extra: {'sodium_mg': Decimal.parse('4')})),
      ]);
      final b = _snapshot(ingredients: [
        _ing(1, 'Mehl', '500.0', 'g',
            densityGPerMl: '1.00',
            per100g: NutrientSet(energyKcal: Decimal.parse('600.0'), extra: {'sodium_mg': Decimal.parse('4.0')})),
      ]);

      expect(RecipeDiff.between(a, b), isEmpty);
    });

    test('DF-21 Barcode-Treffer haben Vorrang vor der Namenszuordnung (15.1)', () {
      final a = _snapshot(ingredients: [
        _ing(1, 'Mehl', '500', 'g', barcode: '4000000000017'),
        _ing(2, 'Mehl', '50', 'g'),
      ]);
      final b = _snapshot(ingredients: [
        _ing(1, 'Mehl', '50', 'g'),
        _ing(2, 'Mehl', '500', 'g', barcode: '4000000000017'),
      ]);

      final changes = RecipeDiff.between(a, b);

      expect(changes, everyElement(isA<MoveIngredient>()));
      expect(_applyOrder(['Mehl 500', 'Mehl 50'], changes), ['Mehl 50', 'Mehl 500']);
    });
  });
}
