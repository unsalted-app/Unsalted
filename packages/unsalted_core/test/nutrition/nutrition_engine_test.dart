// test/nutrition/nutrition_engine_test.dart
//
// EN-01 bis EN-20 aus Kapitel 19.1.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrition_engine.dart';

NutrientSet flourPer100g() => NutrientSet(
      energyKcal: Decimal.parse('343'),
      fatG: Decimal.parse('1.2'),
      saturatedFatG: Decimal.parse('0.2'),
      carbsG: Decimal.parse('70'),
      sugarsG: Decimal.parse('1.5'),
      fiberG: Decimal.parse('3.5'),
      proteinG: Decimal.parse('11'),
      saltG: Decimal.parse('0.01'),
    );

void main() {
  test('EN-01: keine Zutat', () {
    final result = NutritionEngine.calculate(
      ingredients: [],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.rawWeightG, equals(Decimal.zero));
    expect(result.finalWeightG, equals(Decimal.zero));
    expect(result.total.isEmpty, isTrue);
    expect(result.per100g.isEmpty, isTrue);
    expect(result.hasAnyNutrition, isFalse);
  });

  test('EN-02: eine Zutat', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('200'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.rawWeightG, equals(Decimal.parse('200')));
    expect(result.finalWeightG, equals(Decimal.parse('200')));
    expect(result.total.energyKcal, equals(Decimal.parse('686'))); // 343 * 2
    // per100g muss wieder die Ursprungswerte ergeben, da nichts verdunstet ist.
    expect(result.per100g.energyKcal, equals(Decimal.parse('343')));
  });

  test('EN-03: mehrere Zutaten', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
        IngredientInput(
          displayName: 'Zucker',
          quantity: Decimal.parse('50'),
          unitCode: 'g',
          per100g: NutrientSet(
            energyKcal: Decimal.parse('400'),
            carbsG: Decimal.parse('100'),
            sugarsG: Decimal.parse('100'),
          ),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.rawWeightG, equals(Decimal.parse('150')));
    // 343 (aus 100g Mehl) + 200 (aus 50g Zucker, 400*0.5)
    expect(result.total.energyKcal, equals(Decimal.parse('543')));
  });

  test('EN-04: eine Zutat ohne Nährwerte', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Unbekanntes Pulver',
          quantity: Decimal.parse('10'),
          unitCode: 'g',
          per100g: const NutrientSet(), // alle 8 Felder null, aber vorhanden
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.rawWeightG, equals(Decimal.parse('10')));
    expect(result.total.energyKcal, isNull);
    expect(result.incomplete, contains('energy_kcal'));
  });

  test('EN-05: teilweise unbekannte Nährwerte', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
        IngredientInput(
          displayName: 'Zutat ohne Zucker-Angabe',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: NutrientSet(
            energyKcal: Decimal.parse('50'),
            sugarsG: null, // sugars_g unbekannt
          ),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.incomplete, contains('sugars_g'));
    // energy_kcal ist bei beiden Zutaten bekannt, bleibt also vollständig.
    expect(result.incomplete, isNot(contains('energy_kcal')));
  });

  test('EN-06: Zutat ohne verknüpfte Variante', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Freie Zutat ohne Variante',
          quantity: Decimal.parse('20'),
          unitCode: 'g',
          per100g: null, // keine Variante verknüpft
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.rawWeightG, equals(Decimal.parse('20')));
    expect(result.total.isEmpty, isTrue);
    expect(result.incomplete, containsAll(NutrientSet.keys));
  });

  test('EN-07: Backverlust 0%', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.finalWeightG, equals(Decimal.parse('100')));
  });

  test('EN-08: Backverlust 12,5%', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.parse('12.5'),
    );

    expect(result.finalWeightG, equals(Decimal.parse('87.5')));
    // total bleibt unverändert (Backverlust ändert nie die Gesamt-Nährwerte).
    expect(result.total.energyKcal, equals(Decimal.parse('343')));
    // per100g steigt, weil dasselbe Total auf weniger Gewicht verteilt wird.
    expect(
      result.per100g.energyKcal,
      equals(Decimal.parse('392')),
    ); // 343 / 0.875 = 392, exakt (2744/7, kein periodischer Bruch)
  });

  test('EN-09: Backverlust 100% -> per100g alle null', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.parse('100'),
    );

    expect(result.finalWeightG, equals(Decimal.zero));
    expect(result.per100g.isEmpty, isTrue);
    // total bleibt erhalten, auch wenn per100g nicht mehr berechenbar ist.
    expect(result.total.energyKcal, equals(Decimal.parse('343')));
  });

  test('EN-10: finalWeightOverride gesetzt -> Backverlust ignoriert', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.parse('50'), // müsste ignoriert werden
      finalWeightOverrideG: Decimal.parse('90'),
    );

    expect(result.finalWeightG, equals(Decimal.parse('90')));
  });

  test('EN-11: finalWeightOverride = 0 -> ValidationException', () {
    expect(
      () => NutritionEngine.calculate(
        ingredients: [
          IngredientInput(
            displayName: 'Mehl',
            quantity: Decimal.parse('100'),
            unitCode: 'g',
            per100g: flourPer100g(),
          ),
        ],
        bakingLossPercent: Decimal.zero,
        finalWeightOverrideG: Decimal.zero,
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('EN-12: servings = null -> perServing = null', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
      servings: null,
    );

    expect(result.perServing, isNull);
  });

  test('EN-13: servings = 1', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
      servings: 1,
    );

    expect(result.perServing, isNotNull);
    expect(result.perServing!.energyKcal, equals(Decimal.parse('343')));
  });

  test('EN-14: servings = 10', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('1000'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
      servings: 10,
    );

    // total.energyKcal = 3430 (1000g Mehl), geteilt durch 10 Portionen.
    expect(result.perServing!.energyKcal, equals(Decimal.parse('343')));
  });

  test('EN-15: Gramm -> kcal (forAmount)', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    final for50g = result.forAmount(Decimal.parse('50'));
    expect(for50g.energyKcal, equals(Decimal.parse('171.5'))); // 343 * 0.5
  });

  test('EN-16: kcal -> Gramm (gramsForKcal)', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    final grams = result.gramsForKcal(Decimal.parse('343'));
    expect(grams, equals(Decimal.parse('100'))); // exakt, kein periodischer Bruch
  });

  test('EN-17: gramsForKcal bei energy_kcal = null -> null', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Ohne Energie-Angabe',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: const NutrientSet(energyKcal: null, fatG: null),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.gramsForKcal(Decimal.parse('100')), isNull);
  });

  test('EN-18: gramsForKcal bei energy_kcal = 0 -> null', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Wasser',
          quantity: Decimal.parse('100'),
          unitCode: 'g',
          per100g: NutrientSet(energyKcal: Decimal.zero),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.gramsForKcal(Decimal.parse('100')), isNull);
  });

  test('EN-19: Salz wird nicht gerundet gespeichert', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Mehl',
          quantity: Decimal.parse('137'), // krumme Menge, keine Rundung
          unitCode: 'g',
          per100g: flourPer100g(),
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    // 0.01 * 1.37 = 0.0137 -- exakt, nicht gerundet.
    expect(result.total.saltG, equals(Decimal.parse('0.0137')));
  });

  test('EN-20: alle Zutaten nicht berechenbar', () {
    final result = NutritionEngine.calculate(
      ingredients: [
        IngredientInput(
          displayName: 'Öl ohne Dichte',
          quantity: Decimal.parse('50'),
          unitCode: 'ml',
          per100g: NutrientSet(energyKcal: Decimal.parse('900')),
          // densityGPerMl fehlt absichtlich
        ),
        IngredientInput(
          displayName: 'Stück ohne Gewicht',
          quantity: Decimal.parse('2'),
          unitCode: 'piece',
          per100g: NutrientSet(energyKcal: Decimal.parse('100')),
          // gramsPerPiece fehlt absichtlich
        ),
      ],
      bakingLossPercent: Decimal.zero,
    );

    expect(result.rawWeightG, equals(Decimal.zero));
    expect(result.notCalculable, equals(['Öl ohne Dichte', 'Stück ohne Gewicht']));
    expect(result.total.isEmpty, isTrue);
    expect(result.hasAnyNutrition, isFalse);
  });
}