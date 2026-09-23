import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/nutrition/nutrition_formatter.dart';

void main() {
  Decimal d(String val) => Decimal.parse(val);

  group('NutritionFormatter (FO-01 bis FO-05)', () {
    test('FO-01: kcal ganzzahlig mit Tausenderpunkt', () {
      expect(NutritionFormatter.formatKcal(d('3500')), equals('3.500'));
      expect(NutritionFormatter.formatKcal(d('3500.6')), equals('3.501'));
    });

    test('FO-02: Gramm eine Nachkommastelle', () {
      expect(NutritionFormatter.formatGrams(d('3')), equals('3,0'));
      expect(NutritionFormatter.formatGrams(d('3.51')), equals('3,5'));
      expect(NutritionFormatter.formatGrams(d('1234.5')), equals('1.234,5'));
    });

    test('FO-03: Salz zwei Nachkommastellen', () {
      expect(NutritionFormatter.formatSalt(d('1.8')), equals('1,80'));
      expect(NutritionFormatter.formatSalt(d('1.809')), equals('1,81'));
      expect(NutritionFormatter.formatSalt(d('1234.0')), equals('1.234,00'));
    });

    test('FO-04: null → —', () {
      expect(NutritionFormatter.formatKcal(null), equals('—'));
      expect(NutritionFormatter.formatGrams(null), equals('—'));
      expect(NutritionFormatter.formatSalt(null), equals('—'));
    });

    test('FO-05: incomplete erzeugt *', () {
      expect(NutritionFormatter.formatKcal(d('100'), isIncomplete: true), equals('100 *'));
      expect(NutritionFormatter.formatGrams(d('10.5'), isIncomplete: true), equals('10,5 *'));
      expect(NutritionFormatter.formatSalt(d('1.5'), isIncomplete: true), equals('1,50 *'));
    });
  });
}