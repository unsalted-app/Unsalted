// test/ui/versions/change_descriptions_test.dart
//
// Fehlerbehebung 9.2a, Befund 2: UI-22 bis UI-25 (Erweiterung von 23.6) --
// verständliche Texte im Versionsvergleich, Namen über die sequenzielle
// Anwendung der Änderungsliste (Kapitel 14.4).

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';
import 'package:unsalted_core/src/recipe/recipe_diff.dart';
import 'package:unsalted_core/src/recipe/recipe_snapshot_v1.dart';
import 'package:unsalted_core/src/ui/versions/change_descriptions.dart';

Decimal d(String v) => Decimal.parse(v);

RecipeSnapshotIngredient ing(int position, String name, String quantity, String unit) =>
    RecipeSnapshotIngredient(position: position, name: name, quantity: d(quantity), unit: unit);

RecipeSnapshotV1 snapshot({
  String title = 'Brot',
  String? notes,
  String bakingLoss = '0',
  String? override,
  int? servings,
  List<RecipeSnapshotIngredient> ingredients = const [],
  List<RecipeSnapshotStep> steps = const [],
}) {
  const empty = NutrientSet();
  return RecipeSnapshotV1(
    recipe: RecipeSnapshotRecipe(id: 'r', title: title),
    version: RecipeSnapshotVersion(
      id: 'v',
      versionIndex: 1,
      bakingLossPercent: d(bakingLoss),
      finalWeightOverrideG: override == null ? null : d(override),
      notes: notes,
      servings: servings,
      createdAt: DateTime.utc(2026),
      snapshottedAt: DateTime.utc(2026),
    ),
    ingredients: ingredients,
    steps: steps,
    nutrition: RecipeSnapshotNutrition(
      rawWeightG: Decimal.zero,
      finalWeightG: Decimal.zero,
      total: empty,
      per100g: empty,
      incomplete: const [],
      notCalculable: const [],
    ),
  );
}

void main() {
  test('UI-22: Zutaten-Texte mit Namen und alt → neu', () {
    final a = snapshot(ingredients: [
      ing(1, 'Mehl', '500', 'g'),
      ing(2, 'Milch', '500', 'ml'),
      ing(3, 'Butter', '125', 'g'),
      ing(4, 'Zucker', '80', 'g'),
    ]);

    final texts = describeChanges(a, [
      SetIngredientQuantity(position: 2, quantity: d('400')),
      SetIngredientQuantity(position: 1, quantity: d('0.5'), unitCode: 'kg'),
      ReplaceIngredient(position: 3, displayName: 'Margarine', quantity: d('125'), unitCode: 'g'),
      ReplaceIngredient(position: 4, displayName: 'Zucker', quantity: d('80'), unitCode: 'g'),
      const RemoveIngredient(position: 3),
      AddIngredient(position: 4, displayName: 'Ei', quantity: d('3'), unitCode: 'piece'),
      AddIngredient(position: 5, displayName: 'Salz', quantity: d('1'), unitCode: 'pinch'),
      const MoveIngredient(from: 1, to: 3),
    ]);

    expect(texts, [
      'Milch: 500 ml → 400 ml',
      'Mehl: 500 g → 0,5 kg',
      'Butter ersetzt durch Margarine',
      'Zucker: anderes Lebensmittel verknüpft',
      'Margarine entfernt',
      'Ei hinzugefügt (3 Stück)',
      'Salz hinzugefügt (1 Prise)',
      'Mehl verschoben (Position 1 → 3)',
    ]);
  });

  test('UI-22b: Ersetzen mit geänderter Menge nennt alt → neu', () {
    final a = snapshot(ingredients: [ing(1, 'Butter', '125', 'g')]);
    expect(
      describeChanges(a, [ReplaceIngredient(position: 1, displayName: 'Butter', quantity: d('100'), unitCode: 'g')]),
      ['Butter: anderes Lebensmittel verknüpft (125 g → 100 g)'],
    );
  });

  test('UI-23: Schritt-Texte mit gekürzter Anweisung und Timer', () {
    final a = snapshot(steps: const [
      RecipeSnapshotStep(position: 1, instruction: 'Mischen.', timerSeconds: 600),
      RecipeSnapshotStep(position: 2, instruction: 'Kneten.'),
      RecipeSnapshotStep(position: 3, instruction: 'Backen.'),
    ]);

    final texts = describeChanges(a, [
      const SetStep(
        position: 2,
        instruction: 'Den Teig zehn Minuten kräftig kneten, bis er sich vom Rand löst.',
      ),
      const SetStep(position: 1, timerSeconds: OptionalValue<int?>(480)),
      const RemoveStep(position: 3),
      const AddStep(position: 3, instruction: 'Auskühlen lassen.', timerSeconds: 1800),
    ]);

    expect(texts, [
      'Schritt 2 geändert: Den Teig zehn Minuten kräftig kneten,…',
      'Schritt 1 geändert: Timer 10:00 → 8:00',
      'Schritt 3 entfernt: Backen.',
      'Schritt 3 hinzugefügt: Auskühlen lassen. (Timer 30:00)',
    ]);
  });

  test('UI-24: Parameter-Texte zeigen alt → neu', () {
    final a = snapshot(title: 'Brot', notes: 'alt', bakingLoss: '10', servings: 4);

    final texts = describeChanges(a, [
      const SetTitle(title: 'Brot hell'),
      const SetNotes(notes: null),
      SetBakingLoss(percent: d('12.5')),
      SetFinalWeightOverride(grams: d('900')),
      const SetServings(servings: 6),
    ]);

    expect(texts, [
      'Titel: „Brot“ → „Brot hell“',
      'Notizen: „alt“ → —',
      'Backverlust: 10 % → 12,5 %',
      'Fertiggewicht-Override: — → 900 g',
      'Portionen: 4 → 6',
    ]);
  });

  test('UI-25: Remove + Move -- Name stimmt nur über die sequenzielle Anwendung', () {
    final a = snapshot(ingredients: [
      ing(1, 'Mehl', '300', 'g'),
      ing(2, 'Zucker', '100', 'g'),
      ing(3, 'Salz', '1', 'pinch'),
      ing(4, 'Butter', '200', 'g'),
    ]);
    final b = snapshot(ingredients: [
      ing(1, 'Salz', '1', 'pinch'),
      ing(2, 'Mehl', '300', 'g'),
      ing(3, 'Butter', '200', 'g'),
    ]);
    final changes = RecipeDiff.between(a, b);

    // Nach dem Entfernen steht "Salz" an Position 2; in A steht dort
    // "Zucker" -- ein Nachschlagen in A wäre falsch.
    expect(changes.whereType<MoveIngredient>().single.from, 2);
    expect(describeChanges(a, changes), [
      'Zucker entfernt',
      'Salz verschoben (Position 2 → 1)',
    ]);
  });
}
