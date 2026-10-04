// test/integration/it01_export_import_test.dart
//
// IT-01 (Kapitel 23.5): Rezept anlegen → Zutaten → einfrieren → exportieren
// → importieren → Nährwerte identisch.

import 'package:flutter_test/flutter_test.dart';

import 'support/integration_harness.dart';

void main() {
  test('IT-01: anlegen → Zutaten → einfrieren → exportieren → importieren → Nährwerte identisch',
      () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, versionId) = await seedRecipe(device, foods);

    final beforeFreeze = await device.nutrition.forVersion(versionId);
    expect(beforeFreeze.hasAnyNutrition, isTrue);
    expect(beforeFreeze.total.energyKcal, isNotNull);

    await device.recipes.snapshotVersion(versionId);
    final frozen = await device.nutrition.forVersion(versionId);

    final json = await device.snapshots.exportVersionAsJsonString(versionId);
    final importedRecipeId = await device.snapshots.importJsonString(json);
    final importedVersion = (await device.versionsOf(importedRecipeId)).single;
    final imported = await device.nutrition.forVersion(importedVersion.id);

    expectSameNutrition(frozen, beforeFreeze);
    expectSameNutrition(imported, frozen);
  });
}
