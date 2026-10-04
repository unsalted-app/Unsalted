// test/integration/it06_diff_apply_roundtrip_test.dart
//
// IT-06 (Kapitel 23.5, 15.5): `RecipeDiff` zweier Snapshots →
// `applyChangesAsNewDraft` → `snapshotVersion` → Diff gegen die Zielversion
// ist leer.
//
// A = eingefrorene V1 des Seed-Rezepts (Zutaten mit verknüpften
// Lebensmitteln). B entsteht wie in der App: Kopie von A als Draft,
// bearbeitet (Parameter, Schritte, Menge, Einheit, Zutat entfernt, Zutat
// hinzugefügt), Lebensmittel wie im Editor verknüpft, eingefroren.

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

void main() {
  test('IT-06: Diff → applyChangesAsNewDraft → snapshotVersion → Diff gegen Ziel ist leer', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (recipeId, versionA) = await seedRecipe(device, foods);
    await device.recipes.snapshotVersion(versionA);

    final versionB = await device.recipes.createDraftFrom(versionA);
    final copy = await device.version(versionB);
    final salz = copy.ingredients.singleWhere((i) => i.displayName == 'Salz');
    await device.recipes.updateRecipe(recipeId, const UpdateRecipeCommand(title: 'Hefezopf klassisch'));
    await device.recipes.saveDraft(draftOf(
      copy,
      servings: 8,
      bakingLossPercent: d('10'),
      finalWeightOverrideG: d('850'),
      notes: 'Kühl gehen lassen',
      ingredients: [
        ingredient(versionB, 1, 'Weizenmehl Type 550', '550', 'g', variantId: foods.mehl),
        ingredient(versionB, 2, 'Vollmilch', '0.25', 'l', variantId: foods.milch),
        ingredient(versionB, 3, 'Butter', '80', 'g', variantId: foods.butter, note: 'weich'),
        ingredient(versionB, 4, 'Salz', '1', 'pinch', id: salz.id),
        ingredient(versionB, 5, 'Zucker', '60', 'g'),
      ],
      steps: [
        step(versionB, 1, 'Alles 8 Minuten verkneten.', timerSeconds: 480),
        step(versionB, 2, 'Gehen lassen.'),
        step(versionB, 3, 'Flechten und backen.'),
        step(versionB, 4, 'Mit Hagelzucker bestreuen.'),
      ],
    ));
    await device.recipes.snapshotVersion(versionB);

    final snapshotA = await device.snapshots.exportVersion(versionA);
    final snapshotB = await device.snapshots.exportVersion(versionB);
    final targetRows = (await device.version(versionB)).ingredients;
    final changes = RecipeDiff.between(snapshotA, snapshotB, targetRows: targetRows);
    expect(changes, isNotEmpty);

    final applied = await device.recipes.applyChangesAsNewDraft(versionA, changes);
    await device.recipes.snapshotVersion(applied);
    final result = await device.snapshots.exportVersion(applied);

    expect(RecipeDiff.between(result, snapshotB), isEmpty);
  });
}
