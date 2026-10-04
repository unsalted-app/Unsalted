// test/integration/ec_diff_apply_test.dart
//
// Schritt 9.1, ergänzende Edge Cases Diff/Apply (Kapitel 14.4, 15).
// Jede Rundreise: Diff(A, B) → applyChangesAsNewDraft(A) → snapshotVersion
// → Diff gegen B muss leer sein, Nährwerte exakt identisch (Kapitel 15.5).
//
// Wo möglich sind die Fälle so gebaut, dass genau ein Mechanismus geprüft
// wird: Zutaten ohne Lebensmittel-Verknüpfung, wenn nur die Diff-Mechanik
// gemeint ist, verknüpfte Zutaten nur dort, wo die Verknüpfung der
// Gegenstand ist.

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

Future<void> expectRoundTripComplete(Device device, RoundTrip trip, String versionB) async {
  expect(trip.remainingDiff, isEmpty,
      reason: 'Diff(Ergebnis, Ziel) nicht leer: ${describe(trip.remainingDiff)}\n'
          'angewendete Liste: ${describe(trip.changes)}');
  expectSameNutrition(
    await device.nutrition.forVersion(trip.resultVersionId),
    await device.nutrition.forVersion(versionB),
  );
}

void main() {
  test('DA-1: Rundreise mit allen Änderungsarten ohne Verknüpfung, inkl. doppelter Zutat', () async {
    final device = Device.open();
    final (_, versionA) = await createRecipeWith(
      device,
      title: 'Brot',
      notes: 'alt',
      bakingLossPercent: '10',
      servings: 4,
      ingredients: (v) => [
        ingredient(v, 1, 'Mehl', '500', 'g'),
        ingredient(v, 2, 'Wasser', '300', 'ml'),
        ingredient(v, 3, 'Salz', '10', 'g'),
        ingredient(v, 4, 'Hefe', '21', 'g'),
        ingredient(v, 5, 'Mehl', '50', 'g', note: 'zum Bestäuben'),
        ingredient(v, 6, 'Zucker', '5', 'g'),
      ],
      steps: (v) => [
        step(v, 1, 'Mischen.', timerSeconds: 300),
        step(v, 2, 'Kneten.'),
        step(v, 3, 'Backen.', timerSeconds: 2400),
      ],
    );
    await device.recipes.snapshotVersion(versionA);
    final recipeId = (await device.version(versionA)).recipeId;
    await device.recipes.updateRecipe(recipeId, const UpdateRecipeCommand(title: 'Brot hell'));
    final versionB = await createTargetVersion(
      device,
      versionA,
      notes: 'neu',
      bakingLossPercent: '12.5',
      finalWeightOverrideG: '900',
      servings: 6,
      ingredients: (v) => [
        ingredient(v, 1, 'Salz', '12', 'g'),
        ingredient(v, 2, 'Mehl', '550', 'g'),
        ingredient(v, 3, 'Wasser', '0.3', 'l'),
        ingredient(v, 4, 'Hefe', '21', 'g'),
        ingredient(v, 5, 'Mehl', '50', 'g', note: 'zum Bestäuben'),
        ingredient(v, 6, 'Butter', '20', 'g'),
      ],
      steps: (v) => [
        step(v, 1, 'Mischen.', timerSeconds: 300),
        step(v, 2, 'Kneten und falten.', timerSeconds: 600),
        step(v, 3, 'Backen.', timerSeconds: 2400),
        step(v, 4, 'Auskühlen lassen.'),
      ],
    );

    await expectRoundTripComplete(device, await roundTrip(device, versionA, versionB), versionB);
  });

  test('DA-2: Diff(A, A) ist leer; leere Änderungsliste reproduziert A', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, versionA) = await seedRecipe(device, foods);
    await device.recipes.snapshotVersion(versionA);
    final a = await device.snapshots.exportVersion(versionA);

    expect(RecipeDiff.between(a, a), isEmpty);

    final applied = await device.recipes.applyChangesAsNewDraft(versionA, const []);
    await device.recipes.snapshotVersion(applied);
    final result = await device.snapshots.exportVersion(applied);

    expect(RecipeDiff.between(result, a), isEmpty, reason: describe(RecipeDiff.between(result, a)));
    expectSameNutrition(await device.nutrition.forVersion(applied), await device.nutrition.forVersion(versionA));
  });

  test('DA-3: ungültige Änderung mitten in der Liste → nichts geschrieben', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (recipeId, versionA) = await seedRecipe(device, foods);
    await device.recipes.snapshotVersion(versionA);
    final jsonBefore = await device.snapshots.exportVersionAsJsonString(versionA);
    final recipeBefore = await device.recipe(recipeId);

    await expectLater(
      device.recipes.applyChangesAsNewDraft(versionA, [
        const SetServings(servings: 4),
        const SetTitle(title: 'Darf nicht ankommen'),
        RemoveIngredient(position: 5),
        SetBakingLoss(percent: d('150')),
        const AddStep(position: 4, instruction: 'Nie angewendet.'),
      ]),
      throwsA(isA<ValidationException>()),
    );

    expect((await device.versionsOf(recipeId)).map((v) => v.id), [versionA]);
    expect(await device.recipe(recipeId), recipeBefore);
    expect(await device.snapshots.exportVersionAsJsonString(versionA), jsonBefore);
  });

  test('DA-4: neue Version hat parentVersionId, nächsten versionIndex, lückenlose Positionen', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (recipeId, versionA) = await seedRecipe(device, foods);
    await device.recipes.snapshotVersion(versionA);
    final rowsABefore = await device.version(versionA);
    final jsonBefore = await device.snapshots.exportVersionAsJsonString(versionA);
    await device.recipes.createDraftFrom(versionA); // V2

    final applied = await device.recipes.applyChangesAsNewDraft(versionA, [
      const RemoveIngredient(position: 2),
      AddIngredient(position: 1, displayName: 'Zucker', quantity: d('40'), unitCode: 'g'),
      const RemoveStep(position: 1),
      const MoveIngredient(from: 5, to: 2),
    ]);
    final v = await device.version(applied);

    expect(v.state, VersionState.draft);
    expect(v.parentVersionId, versionA);
    expect(v.versionIndex, 3);
    expect(v.ingredients.map((i) => i.position), [1, 2, 3, 4, 5]);
    expect(v.ingredients.map((i) => i.displayName),
        ['Zucker', 'Salz', 'Weizenmehl Type 550', 'Butter', 'Ei']);
    expect(v.steps.map((s) => s.position), [1, 2]);
    expect(v.ingredients.map((i) => i.id).toSet().intersection(rowsABefore.ingredients.map((i) => i.id).toSet()),
        isEmpty);
    expect(await device.version(versionA), rowsABefore);
    expect(await device.snapshots.exportVersionAsJsonString(versionA), jsonBefore);
    expect((await device.recipe(recipeId))!.masterVersionId, isNull);
  });

  test('DA-5 (a): Add und Replace mit verknüpftem Lebensmittel → Rundreise vollständig', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, versionA) = await createRecipeWith(
      device,
      title: 'Rührteig',
      ingredients: (v) => [
        ingredient(v, 1, 'Mehl', '250', 'g'),
        ingredient(v, 2, 'Butter', '125', 'g'),
        ingredient(v, 3, 'Salz', '1', 'pinch'),
      ],
    );
    await device.recipes.snapshotVersion(versionA);
    final versionB = await createTargetVersion(
      device,
      versionA,
      ingredients: (v) => [
        ingredient(v, 1, 'Mehl', '250', 'g'),
        ingredient(v, 2, 'Butter', '125', 'g', variantId: foods.butter),
        ingredient(v, 3, 'Salz', '1', 'pinch'),
        ingredient(v, 4, 'Ei', '2', 'piece', variantId: foods.ei),
      ],
    );

    final trip = await roundTrip(device, versionA, versionB);
    expect(trip.changes.whereType<ReplaceIngredient>(), hasLength(1), reason: describe(trip.changes));
    expect(trip.changes.whereType<AddIngredient>(), hasLength(1), reason: describe(trip.changes));
    await expectRoundTripComplete(device, trip, versionB);
  });

  test('DA-6 (b): Remove + Move (DF-13) → Rundreise vollständig', () async {
    final device = Device.open();
    final (_, versionA) = await createRecipeWith(
      device,
      title: 'Mürbeteig',
      ingredients: (v) => [
        ingredient(v, 1, 'Mehl', '300', 'g'),
        ingredient(v, 2, 'Zucker', '100', 'g'),
        ingredient(v, 3, 'Salz', '1', 'pinch'),
        ingredient(v, 4, 'Butter', '200', 'g'),
      ],
    );
    await device.recipes.snapshotVersion(versionA);
    final versionB = await createTargetVersion(
      device,
      versionA,
      ingredients: (v) => [
        ingredient(v, 1, 'Salz', '1', 'pinch'),
        ingredient(v, 2, 'Mehl', '300', 'g'),
        ingredient(v, 3, 'Butter', '200', 'g'),
      ],
    );

    final trip = await roundTrip(device, versionA, versionB);
    expect(trip.changes.whereType<RemoveIngredient>(), hasLength(1), reason: describe(trip.changes));
    expect(trip.changes.whereType<MoveIngredient>(), isNotEmpty,
        reason: 'Kapitel 15.4/DF-13: Move auch neben Remove. Liste: ${describe(trip.changes)}');
    await expectRoundTripComplete(device, trip, versionB);
  });

  test('DA-6b: Add + Move → Rundreise vollständig', () async {
    final device = Device.open();
    final (_, versionA) = await createRecipeWith(
      device,
      title: 'Pfannkuchen',
      ingredients: (v) => [
        ingredient(v, 1, 'Mehl', '200', 'g'),
        ingredient(v, 2, 'Milch', '400', 'g'),
        ingredient(v, 3, 'Salz', '1', 'pinch'),
      ],
    );
    await device.recipes.snapshotVersion(versionA);
    final versionB = await createTargetVersion(
      device,
      versionA,
      ingredients: (v) => [
        ingredient(v, 1, 'Milch', '400', 'g'),
        ingredient(v, 2, 'Zucker', '20', 'g'),
        ingredient(v, 3, 'Mehl', '200', 'g'),
        ingredient(v, 4, 'Salz', '1', 'pinch'),
      ],
    );

    await expectRoundTripComplete(device, await roundTrip(device, versionA, versionB), versionB);
  });

  test('DA-7 (c): "Mehl" ohne Barcode in A und mit Barcode in B ist dieselbe Zutat (15.1)', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, versionA) = await createRecipeWith(
      device,
      title: 'Fladen',
      ingredients: (v) => [
        ingredient(v, 1, 'Weizenmehl Type 550', '500', 'g'),
        ingredient(v, 2, 'Salz', '1', 'pinch'),
      ],
    );
    await device.recipes.snapshotVersion(versionA);
    final versionB = await createTargetVersion(
      device,
      versionA,
      ingredients: (v) => [
        ingredient(v, 1, 'Weizenmehl Type 550', '500', 'g', variantId: foods.mehl),
        ingredient(v, 2, 'Salz', '1', 'pinch'),
      ],
    );

    final trip = await roundTrip(device, versionA, versionB);
    expect(trip.changes.whereType<RemoveIngredient>(), isEmpty,
        reason: 'gleicher Name → dieselbe Zutat, kein Entfernen: ${describe(trip.changes)}');
    expect(trip.changes.whereType<AddIngredient>(), isEmpty,
        reason: 'gleicher Name → dieselbe Zutat, kein Hinzufügen: ${describe(trip.changes)}');
    await expectRoundTripComplete(device, trip, versionB);
  });

  test('DA-8: gleiche Zutat, nur die Verknüpfung kommt hinzu (Barcode, keine Marke) → erkannt und übernommen',
      () async {
    // Kapitel 15.3: "verknüpfte Variante unterscheidet sich" → ReplaceIngredient.
    // Name, Marke (beide null), Menge und Einheit sind gleich; nur die
    // Verknüpfung mit "Vollmilch" (Barcode, ohne Marke) kommt in B hinzu.
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, versionA) = await createRecipeWith(
      device,
      title: 'Kakao',
      ingredients: (v) => [ingredient(v, 1, 'Vollmilch', '250', 'ml')],
    );
    await device.recipes.snapshotVersion(versionA);
    final versionB = await createTargetVersion(
      device,
      versionA,
      ingredients: (v) => [ingredient(v, 1, 'Vollmilch', '250', 'ml', variantId: foods.milch)],
    );

    final trip = await roundTrip(device, versionA, versionB);
    expect(trip.changes, isNotEmpty, reason: 'A und B rechnen unterschiedlich, der Diff darf nicht leer sein');
    await expectRoundTripComplete(device, trip, versionB);
  });
}
