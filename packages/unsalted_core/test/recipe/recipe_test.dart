import 'package:test/test.dart';
import 'package:unsalted_core/src/recipe/recipe.dart';

void main() {
  group('Recipe', () {
    test('Konstruktion setzt alle Felder', () {
      final recipe = Recipe(
        id: 'r1',
        title: 'Pizzateig',
        description: 'Klassischer Pizzateig',
        masterVersionId: 'v1',
      );

      expect(recipe.id, 'r1');
      expect(recipe.title, 'Pizzateig');
      expect(recipe.description, 'Klassischer Pizzateig');
      expect(recipe.masterVersionId, 'v1');
    });

    test('optionale Felder dürfen null sein', () {
      final recipe = Recipe(id: 'r1', title: 'Pizzateig');
      expect(recipe.description, isNull);
      expect(recipe.masterVersionId, isNull);
    });

    test('copyWith ändert nur die angegebenen Felder', () {
      final original = Recipe(id: 'r1', title: 'Pizzateig', description: 'alt');
      final updated = original.copyWith(title: 'Pizzateig V2');

      expect(updated.id, original.id);
      expect(updated.title, 'Pizzateig V2');
      expect(updated.description, original.description);
    });

    test('Wertgleichheit über ==', () {
      final a = Recipe(id: 'r1', title: 'Pizzateig');
      final b = Recipe(id: 'r1', title: 'Pizzateig');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}