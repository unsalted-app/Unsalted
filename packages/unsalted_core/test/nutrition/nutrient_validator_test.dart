// test/nutrition/nutrient_validator_test.dart
//
// VA-01 bis VA-07 aus Kapitel 19.1.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/nutrition/nutrient_validator.dart';

void main() {
  test('VA-01: negativer Wert -> Fehler', () {
    final set = NutrientSet(fatG: Decimal.parse('-1'));
    expect(
      () => NutrientValidator.check(set),
      throwsA(isA<ValidationException>()),
    );
  });

  test('VA-02: gesättigte > Fett -> Warnung', () {
    final set = NutrientSet(
      fatG: Decimal.parse('5'),
      saturatedFatG: Decimal.parse('10'), // unplausibel: mehr als Gesamtfett
    );
    final warnings = NutrientValidator.check(set);
    expect(
      warnings.any((w) => w.kind == NutrientWarningKind.saturatedFatExceedsFat),
      isTrue,
    );
  });

  test('VA-03: Zucker > KH -> Warnung', () {
    final set = NutrientSet(
      carbsG: Decimal.parse('10'),
      sugarsG: Decimal.parse('20'), // unplausibel: mehr Zucker als KH gesamt
    );
    final warnings = NutrientValidator.check(set);
    expect(
      warnings.any((w) => w.kind == NutrientWarningKind.sugarsExceedCarbs),
      isTrue,
    );
  });

  test('VA-04: Summe > 100 g -> Warnung', () {
    final set = NutrientSet(
      fatG: Decimal.parse('40'),
      carbsG: Decimal.parse('40'),
      proteinG: Decimal.parse('40'),
      fiberG: Decimal.parse('10'), // Summe = 130 > 100
    );
    final warnings = NutrientValidator.check(set);
    expect(
      warnings.any((w) => w.kind == NutrientWarningKind.macrosExceed100g),
      isTrue,
    );
  });

  test('VA-05: kcal-Abweichung > 20% -> Warnung', () {
    // Errechnet: 9*0 + 4*0 + 4*0 + 2*0 = 0 -> dieser Fall würde durch
    // computedEnergy > 0 abgefangen. Realistisches Beispiel stattdessen:
    // 9*10 + 4*10 + 4*10 + 2*0 = 170 kcal errechnet, aber 500 angegeben
    // -> weit über 20% Abweichung.
    final set = NutrientSet(
      energyKcal: Decimal.parse('500'),
      fatG: Decimal.parse('10'),
      carbsG: Decimal.parse('10'),
      proteinG: Decimal.parse('10'),
      fiberG: Decimal.parse('0'),
    );
    final warnings = NutrientValidator.check(set);
    expect(
      warnings.any((w) => w.kind == NutrientWarningKind.energyMismatch),
      isTrue,
    );
  });

  test('VA-06: alle Felder null -> Warnung', () {
    const set = NutrientSet();
    final warnings = NutrientValidator.check(set);
    expect(
      warnings.any((w) => w.kind == NutrientWarningKind.allFieldsEmpty),
      isTrue,
    );
  });

  test('VA-07: plausibles Produkt -> keine Warnung', () {
    // Mehl, realistische Werte, energy_kcal passt zu den Makros:
    // 9*1.2 + 4*70 + 4*11 + 2*3.5 = 10.8 + 280 + 44 + 7 = 341.8, nahe an 343.
    final set = NutrientSet(
      energyKcal: Decimal.parse('343'),
      fatG: Decimal.parse('1.2'),
      saturatedFatG: Decimal.parse('0.2'),
      carbsG: Decimal.parse('70'),
      sugarsG: Decimal.parse('1.5'),
      fiberG: Decimal.parse('3.5'),
      proteinG: Decimal.parse('11'),
      saltG: Decimal.parse('0.01'),
    );
    final warnings = NutrientValidator.check(set);
    expect(warnings, isEmpty);
  });

  test('negativer extra-Wert -> ebenfalls Fehler', () {
    final set = NutrientSet(extra: {'sodium_mg': Decimal.parse('-4')});
    expect(
      () => NutrientValidator.check(set),
      throwsA(isA<ValidationException>()),
    );
  });
}