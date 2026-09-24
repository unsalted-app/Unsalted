import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';

void main() {
  group('FoodVariant', () {
    final nutrients = NutrientSet(
      energyKcal: Decimal.parse('343'),
      fatG: Decimal.parse('1.2'),
      saturatedFatG: Decimal.parse('0.2'),
      carbsG: Decimal.parse('70'),
      sugarsG: Decimal.parse('1.5'),
      fiberG: Decimal.parse('3.5'),
      proteinG: Decimal.parse('11'),
      saltG: Decimal.parse('0.01'),
      extra: const {},
    );

    test('Konstruktion setzt alle Felder', () {
      final variant = FoodVariant(
        id: 'f1',
        name: 'Weizenmehl Type 550',
        brand: 'Mühle X',
        barcode: '4001234567890',
        source: FoodSource.custom,
        sourceRef: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: Decimal.parse('100'),
        nutrients: nutrients,
      );

      expect(variant.name, 'Weizenmehl Type 550');
      expect(variant.source, FoodSource.custom);
      expect(variant.nutrients, nutrients);
    });

    test('optionale Felder dürfen null sein', () {
      final variant = FoodVariant(
        id: 'f2',
        name: 'Sonnenblumenöl',
        brand: null,
        barcode: null,
        source: FoodSource.usda,
        sourceRef: 'usda:12345',
        densityGPerMl: Decimal.parse('0.92'),
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: nutrients,
      );

      expect(variant.brand, isNull);
      expect(variant.gramsPerPiece, isNull);
      expect(variant.densityGPerMl, Decimal.parse('0.92'));
    });

    test('copyWith ändert nur die angegebenen Felder', () {
      final original = FoodVariant(
        id: 'f1',
        name: 'Mehl',
        brand: null,
        barcode: null,
        source: FoodSource.custom,
        sourceRef: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: nutrients,
      );

      final updated = original.copyWith(name: 'Mehl Type 405');

      expect(updated.id, original.id);
      expect(updated.name, 'Mehl Type 405');
      expect(updated.nutrients, original.nutrients);
    });
  });
}