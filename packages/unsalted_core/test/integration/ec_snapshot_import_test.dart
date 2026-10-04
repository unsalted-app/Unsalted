// test/integration/ec_snapshot_import_test.dart
//
// Schritt 9.1, ergänzende Edge Cases Snapshot-Import (Kapitel 13.3–13.7).
// Export immer auf Gerät A, Import auf einem getrennten Gerät.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

Future<String> exportSeedSnapshot() async {
  final deviceA = Device.open();
  final foods = await seedFoods(deviceA);
  final (_, versionA) = await seedRecipe(deviceA, foods);
  await deviceA.recipes.snapshotVersion(versionA);
  return deviceA.snapshots.exportVersionAsJsonString(versionA);
}

Map<String, dynamic> decode(String json) => jsonDecode(json) as Map<String, dynamic>;

void main() {
  test('SI-1: Import und erneuter Export sind byte-identisch, auch mit unbekannten Feldern', () async {
    final json = await exportSeedSnapshot();

    final deviceB = Device.open();
    final plain = await deviceB.snapshots.importJsonString(json);
    final plainVersion = (await deviceB.versionsOf(plain)).single.id;
    expect(await deviceB.snapshots.exportVersionAsJsonString(plainVersion), json);

    final withUnknown = decode(json)
      ..['zz_future_top'] = {'a': '1'}
      ..['version'] = {...(decode(json)['version'] as Map<String, dynamic>), 'zz_future_version': true};
    (withUnknown['ingredients'] as List).first['zz_future_ingredient'] = ['x'];
    final jsonWithUnknown = jsonEncode(withUnknown);

    final extended = await deviceB.snapshots.importJsonString(jsonWithUnknown);
    final extendedVersion = (await deviceB.versionsOf(extended)).single.id;
    expect(await deviceB.snapshots.exportVersionAsJsonString(extendedVersion), jsonWithUnknown);
    expectSameNutrition(
      await deviceB.nutrition.forVersion(extendedVersion),
      await deviceB.nutrition.forVersion(plainVersion),
    );
  });

  test('SI-2: importierte Version hat neue IDs, state = snapshot, V1, parentVersionId aus dem JSON',
      () async {
    final json = await exportSeedSnapshot();
    final original = decode(json);

    final deviceB = Device.open();
    final recipeId = await deviceB.snapshots.importJsonString(json);
    final version = await deviceB.version((await deviceB.versionsOf(recipeId)).single.id);
    final recipe = (await deviceB.recipe(recipeId))!;

    expect(recipeId, isNot(original['recipe']['id']));
    expect(version.id, isNot(original['version']['id']));
    expect(version.parentVersionId, original['version']['id']);
    expect(version.state, VersionState.snapshot);
    expect(version.versionIndex, 1);
    expect(version.snapshottedAt, isNotNull);
    expect(recipe.title, original['recipe']['title']);
    expect(recipe.description, original['recipe']['description']);
    expect(recipe.masterVersionId, isNull);
  });

  group('SI-3: ungültiger Snapshot → Exception, nichts geschrieben', () {
    Future<void> expectRejected(Map<String, dynamic> Function(Map<String, dynamic>) mutate, Matcher error) async {
      final json = await exportSeedSnapshot();
      final deviceB = Device.open();
      await expectLater(deviceB.snapshots.importJsonString(jsonEncode(mutate(decode(json)))), throwsA(error));
      expect(await deviceB.allRecipes(), isEmpty);
      expect(await deviceB.allFoods(), isEmpty, reason: 'Varianten früherer Zutaten dürfen nicht angelegt sein');
    }

    test('negative Menge in der letzten Zutat', () async {
      await expectRejected((m) {
        (m['ingredients'] as List).last['quantity'] = '-1';
        return m;
      }, isA<ImportFormatException>());
    });

    test('Positionslücke in der letzten Zutat', () async {
      await expectRejected((m) {
        final list = m['ingredients'] as List;
        list.last['position'] = list.length + 1;
        return m;
      }, isA<ImportFormatException>());
    });

    test('format_version 2', () async {
      await expectRejected((m) => m..['format_version'] = 2, isA<ImportVersionException>());
    });
  });

  test('SI-4: Zutaten ohne per100g werden ohne Variante übernommen, keine Variante angelegt', () async {
    final deviceA = Device.open();
    final (_, versionA) = await createRecipeWith(
      deviceA,
      title: 'Nur Gewürze',
      ingredients: (v) => [
        ingredient(v, 1, 'Salz', '1', 'pinch'),
        ingredient(v, 2, 'Pfeffer', '2', 'g'),
      ],
    );
    await deviceA.recipes.snapshotVersion(versionA);
    final json = await deviceA.snapshots.exportVersionAsJsonString(versionA);
    expect((decode(json)['ingredients'] as List).map((i) => i['per100g']), everyElement(isNull));

    final deviceB = Device.open();
    final recipeId = await deviceB.snapshots.importJsonString(json);
    final version = await deviceB.version((await deviceB.versionsOf(recipeId)).single.id);

    expect(await deviceB.allFoods(), isEmpty);
    expect(version.ingredients.map((i) => i.foodVariantId), everyElement(isNull));
  });

  test('SI-5a: Treffer über Barcode und über normalisierten Name+Marke+Nährwerte werden verknüpft', () async {
    final json = await exportSeedSnapshot();
    final deviceB = Device.open();
    final butterNutrients = NutrientSet(
      energyKcal: d('741'),
      fatG: d('82'),
      saturatedFatG: d('54.3'),
      carbsG: d('0.6'),
      sugarsG: d('0.6'),
      fiberG: d('0'),
      proteinG: d('0.7'),
      saltG: d('0.02'),
    );
    final localButter = await deviceB.foods.createVariant(NewFoodVariant(
      name: '  BUTTER ',
      brand: ' alpenhof',
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: butterNutrients,
    ));
    final localMehl = await deviceB.foods.createVariant(NewFoodVariant(
      name: 'Mehl vom Bäcker',
      brand: null,
      barcode: '4000000000017',
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: d('350')),
    ));

    final recipeId = await deviceB.snapshots.importJsonString(json);
    final rows = (await deviceB.version((await deviceB.versionsOf(recipeId)).single.id)).ingredients;

    expect(rows.singleWhere((i) => i.displayName == 'Butter').foodVariantId, localButter);
    expect(rows.singleWhere((i) => i.displayName == 'Weizenmehl Type 550').foodVariantId, localMehl);
    expect(await deviceB.allFoods(), hasLength(4), reason: '2 lokale + neu Milch und Ei');
  });

  test('SI-5b: Name+Marke gleich, aber ein Nährwert abweichend → neue Variante', () async {
    final json = await exportSeedSnapshot();
    final deviceB = Device.open();
    final localButter = await deviceB.foods.createVariant(NewFoodVariant(
      name: 'Butter',
      brand: 'Alpenhof',
      barcode: null,
      source: FoodSource.custom,
      sourceRef: null,
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(
        energyKcal: d('741'),
        fatG: d('82'),
        saturatedFatG: d('54.3'),
        carbsG: d('0.6'),
        sugarsG: d('0.6'),
        fiberG: d('0'),
        proteinG: d('0.7'),
        saltG: d('0.03'),
      ),
    ));

    final recipeId = await deviceB.snapshots.importJsonString(json);
    final rows = (await deviceB.version((await deviceB.versionsOf(recipeId)).single.id)).ingredients;
    final linkedButter = rows.singleWhere((i) => i.displayName == 'Butter').foodVariantId;

    expect(linkedButter, isNot(localButter));
    expect((await deviceB.foods.getById(linkedButter!))!.source, FoodSource.imported);
    expect(await deviceB.allFoods(), hasLength(5));
  });

  test('SI-6: Draft ist nicht exportierbar; Kopie eines importierten Snapshots rechnet gleich', () async {
    final json = await exportSeedSnapshot();
    final deviceB = Device.open();
    final recipeId = await deviceB.snapshots.importJsonString(json);
    final imported = (await deviceB.versionsOf(recipeId)).single.id;

    final copy = await deviceB.recipes.createDraftFrom(imported);
    await expectLater(deviceB.snapshots.exportVersion(copy), throwsA(isA<IllegalStateException>()));
    await expectLater(deviceB.snapshots.exportVersionAsJsonString(copy), throwsA(isA<IllegalStateException>()));

    expect((await deviceB.version(copy)).ingredients.map((i) => i.foodVariantId).toList(),
        (await deviceB.version(imported)).ingredients.map((i) => i.foodVariantId).toList(),
        reason: 'Kopie muss die Verknüpfungen des Snapshots behalten');
    expectSameNutrition(await deviceB.nutrition.forVersion(copy), await deviceB.nutrition.forVersion(imported));
  });
}
