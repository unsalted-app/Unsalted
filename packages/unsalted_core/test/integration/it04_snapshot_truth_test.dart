// test/integration/it04_snapshot_truth_test.dart
//
// IT-04 (Kapitel 23.5): Zum Zeitpunkt des Einfrierens liefern Zeilen und
// `snapshotJson` dasselbe Berechnungsergebnis. Geprüft über drei Wege:
// Live-Berechnung des Drafts aus den Zeilen, `preview` aus denselben
// Zutaten, `forVersion` nach dem Einfrieren (aus `snapshotJson`) und der im
// exportierten Snapshot eingebettete `nutrition`-Block.

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

void main() {
  test('IT-04: Zeilen und snapshotJson liefern beim Einfrieren dasselbe Ergebnis', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, versionId) = await seedRecipe(device, foods);

    final fromRows = await device.nutrition.forVersion(versionId);
    final draft = await device.version(versionId);
    final fromPreview = device.nutrition.preview(
      ingredients: [
        for (final i in draft.ingredients)
          IngredientInput(
            displayName: i.displayName,
            quantity: i.quantity,
            unitCode: i.unitCode,
            variant: i.foodVariantId == null ? null : await device.foods.getById(i.foodVariantId!),
          ),
      ],
      bakingLossPercent: draft.bakingLossPercent,
      finalWeightOverrideG: draft.finalWeightOverrideG,
      servings: draft.servings,
    );

    await device.recipes.snapshotVersion(versionId);
    final fromSnapshot = await device.nutrition.forVersion(versionId);
    final embedded = (await device.snapshots.exportVersion(versionId)).nutrition;

    expectSameNutrition(fromPreview, fromRows);
    expectSameNutrition(fromSnapshot, fromRows);
    expect(embedded.rawWeightG, fromRows.rawWeightG);
    expect(embedded.finalWeightG, fromRows.finalWeightG);
    expect(embedded.total, fromRows.total);
    expect(embedded.per100g, fromRows.per100g);
    expect(embedded.incomplete.toSet(), fromRows.incomplete);
    expect(embedded.notCalculable, fromRows.notCalculable);
  });
}
