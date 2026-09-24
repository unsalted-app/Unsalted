import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';

void main() {
  group('RecipeChange Roundtrip (RC-01..RC-13)', () {
    test('RC-01 AddIngredient', () {
      final change = AddIngredient(
        position: 1,
        displayName: 'Mehl',
        foodVariantId: 'f1',
        quantity: Decimal.parse('600'),
        unitCode: 'g',
        note: 'gesiebt',
      );
      final decoded = RecipeChange.fromJson(change.toJson()) as AddIngredient;
      expect(decoded.position, 1);
      expect(decoded.displayName, 'Mehl');
      expect(decoded.foodVariantId, 'f1');
      expect(decoded.quantity, Decimal.parse('600'));
      expect(decoded.unitCode, 'g');
      expect(decoded.note, 'gesiebt');
    });

    test('RC-02 RemoveIngredient', () {
      final change = RemoveIngredient(position: 2);
      final decoded = RecipeChange.fromJson(change.toJson()) as RemoveIngredient;
      expect(decoded.position, 2);
    });

    test('RC-03 SetIngredientQuantity', () {
      final change = SetIngredientQuantity(
        position: 2,
        quantity: Decimal.parse('350'),
        unitCode: 'g',
      );
      final decoded = RecipeChange.fromJson(change.toJson()) as SetIngredientQuantity;
      expect(decoded.position, 2);
      expect(decoded.quantity, Decimal.parse('350'));
      expect(decoded.unitCode, 'g');
    });

    test('RC-04 ReplaceIngredient', () {
      final change = ReplaceIngredient(
        position: 1,
        displayName: 'Dinkelmehl',
        foodVariantId: 'f2',
        quantity: Decimal.parse('500'),
        unitCode: 'g',
      );
      final decoded = RecipeChange.fromJson(change.toJson()) as ReplaceIngredient;
      expect(decoded.displayName, 'Dinkelmehl');
      expect(decoded.foodVariantId, 'f2');
      expect(decoded.quantity, Decimal.parse('500'));
    });

    test('RC-05 MoveIngredient', () {
      final change = MoveIngredient(from: 3, to: 1);
      final decoded = RecipeChange.fromJson(change.toJson()) as MoveIngredient;
      expect(decoded.from, 3);
      expect(decoded.to, 1);
    });

    test('RC-06 AddStep', () {
      final change = AddStep(position: 1, instruction: '10 Minuten kneten', timerSeconds: 600);
      final decoded = RecipeChange.fromJson(change.toJson()) as AddStep;
      expect(decoded.instruction, '10 Minuten kneten');
      expect(decoded.timerSeconds, 600);
    });

    test('RC-07 RemoveStep', () {
      final change = RemoveStep(position: 2);
      final decoded = RecipeChange.fromJson(change.toJson()) as RemoveStep;
      expect(decoded.position, 2);
    });

    test('RC-08 SetStep — Instruktion ändern, Timer unberührt', () {
      final change = SetStep(position: 1, instruction: 'Neuer Text');
      final decoded = RecipeChange.fromJson(change.toJson()) as SetStep;
      expect(decoded.instruction, 'Neuer Text');
      expect(decoded.timerSeconds, isNull);
    });

    test('RC-08b SetStep — Timer explizit auf null setzen', () {
      final change = SetStep(position: 1, timerSeconds: const OptionalValue<int?>(null));
      final decoded = RecipeChange.fromJson(change.toJson()) as SetStep;
      expect(decoded.timerSeconds, isNotNull);
      expect(decoded.timerSeconds!.value, isNull);
    });

    test('RC-09 SetBakingLoss', () {
      final change = SetBakingLoss(percent: Decimal.parse('12.5'));
      final decoded = RecipeChange.fromJson(change.toJson()) as SetBakingLoss;
      expect(decoded.percent, Decimal.parse('12.5'));
    });

    test('RC-10 SetFinalWeightOverride', () {
      final change = SetFinalWeightOverride(grams: Decimal.parse('900'));
      final decoded = RecipeChange.fromJson(change.toJson()) as SetFinalWeightOverride;
      expect(decoded.grams, Decimal.parse('900'));
    });

    test('RC-11 SetServings', () {
      final change = SetServings(servings: 8);
      final decoded = RecipeChange.fromJson(change.toJson()) as SetServings;
      expect(decoded.servings, 8);
    });

    test('RC-12 SetTitle', () {
      final change = SetTitle(title: 'Pizzateig V2');
      final decoded = RecipeChange.fromJson(change.toJson()) as SetTitle;
      expect(decoded.title, 'Pizzateig V2');
    });

    test('RC-13 SetNotes', () {
      final change = SetNotes(notes: 'schmeckt besser mit Vorteig');
      final decoded = RecipeChange.fromJson(change.toJson()) as SetNotes;
      expect(decoded.notes, 'schmeckt besser mit Vorteig');
    });
  });

  group('Fehlerfälle (RC-14..RC-18)', () {
    test('RC-14 unbekannter type wirft UnknownChangeException', () {
      expect(
        () => RecipeChange.fromJson({'type': 'frobnicate'}),
        throwsA(isA<UnknownChangeException>()),
      );
    });

    test('RC-15 quantity ist ein JSON-String, keine Zahl', () {
      final change = AddIngredient(
        position: 1,
        displayName: 'Mehl',
        quantity: Decimal.parse('600'),
        unitCode: 'g',
      );
      final json = change.toJson();
      expect(json['quantity'], isA<String>());
      expect(json['quantity'], '600');
    });

    test('RC-16 validate() lehnt negative Menge ab', () {
      final change = AddIngredient(
        position: 1,
        displayName: 'Mehl',
        quantity: Decimal.parse('-1'),
        unitCode: 'g',
      );
      expect(change.validate, throwsA(isA<ValidationException>()));
    });

    test('RC-17 validate() lehnt servings = 0 ab', () {
      final change = SetServings(servings: 0);
      expect(change.validate, throwsA(isA<ValidationException>()));
    });

    test('RC-18 validate() lehnt Backverlust > 100 ab', () {
      final change = SetBakingLoss(percent: Decimal.parse('101'));
      expect(change.validate, throwsA(isA<ValidationException>()));
    });
  });
}