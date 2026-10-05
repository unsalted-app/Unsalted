import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';

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

  // Kapitel 18.1: Testvertrag von recipe_step.dart liegt in dieser Datei
  // (Nachtrag 10.1a, Befund B3).
  group('RecipeStep', () {
    const step = RecipeStep(
      id: 's1',
      versionId: 'v1',
      position: 2,
      instruction: 'Teig 10 Minuten kneten.',
      timerSeconds: 600,
    );

    test('Konstruktion setzt alle Felder', () {
      expect(step.id, 's1');
      expect(step.versionId, 'v1');
      expect(step.position, 2);
      expect(step.instruction, 'Teig 10 Minuten kneten.');
      expect(step.timerSeconds, 600);
    });

    test('timerSeconds ist optional und standardmäßig null', () {
      const withoutTimer = RecipeStep(id: 's2', versionId: 'v1', position: 1, instruction: 'Ruhen lassen.');
      expect(withoutTimer.timerSeconds, isNull);
    });

    test('Gleichheit und hashCode über alle fünf Felder', () {
      const same = RecipeStep(
        id: 's1',
        versionId: 'v1',
        position: 2,
        instruction: 'Teig 10 Minuten kneten.',
        timerSeconds: 600,
      );
      expect(step, same);
      expect(step.hashCode, same.hashCode);

      for (final different in [
        step.copyWith(id: 'x'),
        step.copyWith(versionId: 'x'),
        step.copyWith(position: 3),
        step.copyWith(instruction: 'x'),
        step.copyWith(timerSeconds: 601),
        step.copyWith(timerSeconds: null),
      ]) {
        expect(step == different, isFalse, reason: '$different');
      }
    });

    test('copyWith ohne Argumente liefert eine gleiche Kopie', () {
      expect(step.copyWith(), step);
    });

    test('copyWith ändert nur die angegebenen Felder', () {
      final moved = step.copyWith(position: 5, instruction: 'Neu.');
      expect(moved.position, 5);
      expect(moved.instruction, 'Neu.');
      expect(moved.id, step.id);
      expect(moved.versionId, step.versionId);
      expect(moved.timerSeconds, step.timerSeconds);
    });

    test('copyWith unterscheidet „Timer nicht ändern“ von „Timer auf null setzen“', () {
      expect(step.copyWith(instruction: 'x').timerSeconds, 600, reason: 'nicht angegeben → unverändert');
      expect(step.copyWith(timerSeconds: null).timerSeconds, isNull, reason: 'explizit null → entfernt');
      expect(step.copyWith(timerSeconds: 90).timerSeconds, 90);

      const withoutTimer = RecipeStep(id: 's2', versionId: 'v1', position: 1, instruction: 'Ruhen lassen.');
      expect(withoutTimer.copyWith(timerSeconds: 300).timerSeconds, 300);
    });

    test('toString nennt id, position und instruction', () {
      expect(step.toString(), 'RecipeStep(id: s1, position: 2, instruction: Teig 10 Minuten kneten.)');
    });
  });
}
