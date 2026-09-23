// test/nutrition/unit_catalog_test.dart
//
// UT-01 bis UT-14 aus Kapitel 19.1.

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/nutrition/unit_catalog.dart';

Rational r(String value) => Decimal.parse(value).toRational();

void main() {
  test('UT-01: g', () {
    final result = UnitCatalog.toGrams(Decimal.parse('100'), 'g');
    expect(result, equals(r('100')));
  });

  test('UT-02: kg', () {
    final result = UnitCatalog.toGrams(Decimal.parse('2'), 'kg');
    expect(result, equals(r('2000')));
  });

  test('UT-03: ml mit Dichte', () {
    final result = UnitCatalog.toGrams(
      Decimal.parse('100'),
      'ml',
      densityGPerMl: Decimal.parse('1.03'),
    );
    expect(result, equals(r('103')));
  });

  test('UT-04: ml ohne Dichte -> nicht berechenbar', () {
    final result = UnitCatalog.toGrams(Decimal.parse('100'), 'ml');
    expect(result, isNull);
  });

  test('UT-05: l mit Dichte', () {
    final result = UnitCatalog.toGrams(
      Decimal.one,
      'l',
      densityGPerMl: Decimal.one,
    );
    expect(result, equals(r('1000')));
  });

  test('UT-06: tsp', () {
    final result = UnitCatalog.toGrams(
      Decimal.parse('3'),
      'tsp',
      densityGPerMl: Decimal.one,
    );
    expect(result, equals(r('15'))); // 3 * 5 * 1.0
  });

  test('UT-07: tbsp', () {
    final result = UnitCatalog.toGrams(
      Decimal.parse('2'),
      'tbsp',
      densityGPerMl: Decimal.one,
    );
    expect(result, equals(r('30'))); // 2 * 15 * 1.0
  });

  test('UT-08: cup', () {
    final result = UnitCatalog.toGrams(
      Decimal.one,
      'cup',
      densityGPerMl: Decimal.one,
    );
    expect(result, equals(r('240'))); // 1 * 240 * 1.0
  });

  test('UT-09: pinch', () {
    final result = UnitCatalog.toGrams(Decimal.parse('2'), 'pinch');
    expect(result, equals(r('0.6'))); // 2 * 0.3, keine Dichte nötig
  });

  test('UT-10: piece mit Stückgewicht', () {
    final result = UnitCatalog.toGrams(
      Decimal.parse('3'),
      'piece',
      gramsPerPiece: Decimal.parse('50'),
    );
    expect(result, equals(r('150')));
  });

  test('UT-11: piece ohne Stückgewicht -> nicht berechenbar', () {
    final result = UnitCatalog.toGrams(Decimal.parse('3'), 'piece');
    expect(result, isNull);
  });

  test('UT-12: unbekannter Einheiten-Code -> ArgumentError', () {
    expect(
      () => UnitCatalog.toGrams(Decimal.one, 'unknown_unit'),
      throwsArgumentError,
    );
  });

  test('UT-13: Menge 0 -> 0 g, nicht "nicht berechenbar"', () {
    final result = UnitCatalog.toGrams(Decimal.zero, 'g');
    expect(result, isNotNull);
    expect(result, equals(r('0')));
  });

  test('UT-14: negative Menge -> ValidationException', () {
    expect(
      () => UnitCatalog.toGrams(Decimal.parse('-5'), 'g'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('die neun Codes sind vollständig', () {
    final codes = UnitCatalog.all.map((u) => u.code).toSet();
    expect(
      codes,
      equals({'g', 'kg', 'pinch', 'ml', 'l', 'tsp', 'tbsp', 'cup', 'piece'}),
    );
    expect(UnitCatalog.all.length, equals(9));
  });
}