import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';

void main() {
  group('RecipeIngredient', () {
    test('Konstruktion setzt alle Felder', () {
      final ingredient = RecipeIngredient(
        id: 'i1',
        versionId: 'v1',
        position: 1,
        foodVariantId: 'f1',
        displayName: 'Weizenmehl Type 550',
        quantity: Decimal.parse('600'),
        unitCode: 'g',
        note: 'gesiebt',
      );

      expect(ingredient.id, 'i1');
      expect(ingredient.position, 1);
      expect(ingredient.quantity, Decimal.parse('600'));
      expect(ingredient.unitCode, 'g');
    });

    test('freie Zutat ohne foodVariantId', () {
      final ingredient = RecipeIngredient(
        id: 'i2',
        versionId: 'v1',
        position: 2,
        foodVariantId: null,
        displayName: 'Prise Liebe',
        quantity: Decimal.one,
        unitCode: 'pinch',
        note: null,
      );

      expect(ingredient.foodVariantId, isNull);
      expect(ingredient.note, isNull);
    });

    test('copyWith ändert nur die angegebenen Felder', () {
      final original = RecipeIngredient(
        id: 'i1',
        versionId: 'v1',
        position: 1,
        foodVariantId: 'f1',
        displayName: 'Mehl',
        quantity: Decimal.parse('600'),
        unitCode: 'g',
        note: null,
      );

      final updated = original.copyWith(quantity: Decimal.parse('350'));

      expect(updated.id, original.id);
      expect(updated.quantity, Decimal.parse('350'));
      expect(updated.displayName, original.displayName);
    });
  });
}