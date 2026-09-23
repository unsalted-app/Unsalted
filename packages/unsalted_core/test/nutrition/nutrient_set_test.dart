// test/nutrition/nutrient_set_test.dart
//
// NS-01 bis NS-07 aus Kapitel 19.1.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/nutrition/nutrient_set.dart';

void main() {
  test('NS-01: Skalierung mit bekanntem Wert', () {
    final set = NutrientSet(
      energyKcal: Decimal.parse('100'),
      fatG: Decimal.parse('10'),
    );

    final scaled = set.scale(Decimal.fromInt(2).toRational());

    expect(scaled.energyKcal, equals(Decimal.parse('200')));
    expect(scaled.fatG, equals(Decimal.parse('20')));
  });

  test('NS-02: Skalierung von null bleibt null', () {
    const set = NutrientSet(energyKcal: null, fatG: null);

    final scaled = set.scale(Decimal.fromInt(2).toRational());

    expect(scaled.energyKcal, isNull);
    expect(scaled.fatG, isNull);
  });

  test('NS-03: Addition bekannt+bekannt', () {
    final a = NutrientSet(energyKcal: Decimal.parse('100'), fatG: Decimal.parse('10'));
    final b = NutrientSet(energyKcal: Decimal.parse('50'), fatG: Decimal.parse('5'));

    final result = a.plus(b);

    expect(result.set.energyKcal, equals(Decimal.parse('150')));
    expect(result.set.fatG, equals(Decimal.parse('15')));
    // Nur die tatsächlich beidseitig bekannten Felder dürfen NICHT incomplete
    // sein. Die übrigen 6 Felder sind bei a und b beide null -> unbekannt +
    // unbekannt = incomplete (Kapitel 5.2) — das ist hier korrektes Verhalten,
    // kein Fehler.
    expect(result.incomplete, isNot(contains('energy_kcal')));
    expect(result.incomplete, isNot(contains('fat_g')));
  });

  test('NS-04: bekannt+unbekannt -> Wert + incomplete', () {
    final a = NutrientSet(energyKcal: Decimal.parse('100'));
    final b = NutrientSet(energyKcal: null);

    final result = a.plus(b);

    expect(result.set.energyKcal, equals(Decimal.parse('100')));
    expect(result.incomplete, contains('energy_kcal'));
  });

  test('NS-05: unbekannt+unbekannt -> null + incomplete', () {
    const a = NutrientSet(energyKcal: null);
    const b = NutrientSet(energyKcal: null);

    final result = a.plus(b);

    expect(result.set.energyKcal, isNull);
    expect(result.incomplete, contains('energy_kcal'));
  });

  test('NS-06: extra-Schlüssel addieren', () {
    final a = NutrientSet(extra: {'sodium_mg': Decimal.parse('5')});
    final b = NutrientSet(extra: {'sodium_mg': Decimal.parse('3')});

    final result = a.plus(b);

    expect(result.set.extra['sodium_mg'], equals(Decimal.parse('8')));
    expect(result.incomplete, isNot(contains('sodium_mg')));
  });

  test('NS-07: extra-Schlüssel nur in einer Zutat -> incomplete', () {
    final a = NutrientSet(extra: {'sodium_mg': Decimal.parse('5')});
    const b = NutrientSet(extra: {});

    final result = a.plus(b);

    expect(result.set.extra['sodium_mg'], equals(Decimal.parse('5')));
    expect(result.incomplete, contains('sodium_mg'));
  });

  test('isEmpty: alle Felder null und extra leer', () {
    const set = NutrientSet();
    expect(set.isEmpty, isTrue);
  });

  test('isEmpty: false sobald ein Feld gesetzt ist', () {
    final set = NutrientSet(energyKcal: Decimal.parse('1'));
    expect(set.isEmpty, isFalse);
  });

  test('copyWith kann ein Feld explizit auf null zurücksetzen', () {
    final set = NutrientSet(energyKcal: Decimal.parse('100'));
    final reset = set.copyWith(energyKcal: null);
    expect(reset.energyKcal, isNull);
  });

  test('toJsonMap/fromJsonMap Roundtrip, null bleibt null', () {
    final set = NutrientSet(
      energyKcal: Decimal.parse('350'),
      fatG: null,
      extra: {'sodium_mg': Decimal.parse('4')},
    );

    final json = set.toJsonMap();
    expect(json['energy_kcal'], equals('350'));
    expect(json['fat_g'], isNull);
    expect(json['extra'], equals({'sodium_mg': '4'}));

    final roundtripped = NutrientSet.fromJsonMap(json);
    expect(roundtripped, equals(set));
  });

  test('== und hashCode sind wertbasiert, unabhängig von extra-Reihenfolge', () {
    final a = NutrientSet(
      energyKcal: Decimal.parse('100'),
      extra: {'a': Decimal.parse('1'), 'b': Decimal.parse('2')},
    );
    final b = NutrientSet(
      energyKcal: Decimal.parse('100'),
      extra: {'b': Decimal.parse('2'), 'a': Decimal.parse('1')},
    );

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
  });
}