// test/nutrition/decimal_math_test.dart
//
// DC-01 bis DC-06 aus Kapitel 19.1. Diese Tests sind der Nachweis dafür,
// dass die in Kapitel 4.2 dokumentierten API-Fallen von package:decimal
// tatsächlich abgefangen sind, und dass Decimal für die klassischen
// double-Rundungsprobleme immun ist.

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/nutrition/decimal_math.dart';

void main() {
  test('DC-01: 1/3 durch die Pipeline ohne Wurf', () {
    final oneThird = Decimal.one.r / Decimal.fromInt(3).r;

    // Ohne scaleOnInfinitePrecision würde toDecimal() hier werfen, weil 1/3
    // keine endliche Dezimaldarstellung hat (Kapitel 4.2). toFixedDecimal()
    // muss das abfangen.
    expect(() => oneThird.toFixedDecimal(), returnsNormally);

    final result = oneThird.toFixedDecimal();
    // Auf kInternalScale (12) Nachkommastellen gekürzt: 0.333333333333
    expect(result, equals(Decimal.parse('0.333333333333')));
  });

  test('DC-02: sehr kleiner Wert bleibt erhalten', () {
    final tiny = Decimal.parse('0.000000001'); // 1e-9

    final roundtripped = tiny.r.toFixedDecimal();

    expect(roundtripped, equals(tiny));
  });

  test('DC-03: sehr großer Wert bleibt erhalten', () {
    final huge = Decimal.parse('999999999999.99');

    final roundtripped = huge.r.toFixedDecimal();

    expect(roundtripped, equals(huge));
  });

  test('DC-04: exakter Vergleich ohne Toleranz', () {
    // Ergebnis einer Rechnung muss exakt gleich dem geparsten Literal sein —
    // keine Toleranzgrenze wie bei double nötig.
    final computed = Decimal.fromInt(35) * Decimal.fromInt(10);
    final expected = Decimal.parse('350');

    expect(computed, equals(expected));
    expect(computed == expected, isTrue);
  });

  test('DC-05: 0.1 + 0.2 == 0.3 (scheitert mit double)', () {
    final a = Decimal.parse('0.1');
    final b = Decimal.parse('0.2');
    final sum = a + b;

    expect(sum, equals(Decimal.parse('0.3')));
    expect(sum == Decimal.parse('0.3'), isTrue);

    // Zur Dokumentation, warum dieser Test existiert: mit double wäre
    // 0.1 + 0.2 == 0.30000000000000004, also ungleich 0.3.
  });

  test('DC-06: Roundtrip Decimal -> String -> Decimal identisch', () {
    final original = Decimal.parse('123.456');
    final asString = original.toString();
    final parsedBack = Decimal.parse(asString);

    expect(parsedBack, equals(original));
  });

  test('rHundred und rZero sind korrekt vorbelegt', () {
    expect(rHundred, equals(Rational.parse('100')));
    expect(rZero, equals(Rational.zero));
  });
}