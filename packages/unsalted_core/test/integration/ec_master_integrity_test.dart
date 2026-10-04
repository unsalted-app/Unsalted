// test/integration/ec_master_integrity_test.dart
//
// Schritt 9.1, ergänzende Edge Cases Master-Integrität (Kapitel 12.1, 12.5,
// 16.1): masterVersionId zeigt immer auf einen aktiven Snapshot desselben
// Rezepts und bleibt über alle anderen Versionsoperationen stabil.

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

Future<String?> masterOf(Device device, String recipeId) async => (await device.recipe(recipeId))!.masterVersionId;

void main() {
  test('MI-1: Master nur auf Snapshot; bleibt über Kopieren, Übernehmen, Einfrieren, Umbenennen stabil',
      () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (recipeId, v1) = await seedRecipe(device, foods);

    await expectLater(device.recipes.setMasterVersion(recipeId, v1), throwsA(isA<IllegalStateException>()));
    expect(await masterOf(device, recipeId), isNull);

    await device.recipes.snapshotVersion(v1);
    await device.recipes.setMasterVersion(recipeId, v1);
    expect(await masterOf(device, recipeId), v1);

    final v2 = await device.recipes.createDraftFrom(v1);
    expect(await masterOf(device, recipeId), v1);
    await device.recipes.snapshotVersion(v2);
    expect(await masterOf(device, recipeId), v1);
    final v3 = await device.recipes.applyChangesAsNewDraft(v1, [
      const SetServings(servings: 2),
      const SetTitle(title: 'Hefezopf neu'),
    ]);
    expect(await masterOf(device, recipeId), v1);
    await device.recipes.updateRecipe(recipeId, const UpdateRecipeCommand(title: 'Hefezopf final'));
    expect(await masterOf(device, recipeId), v1);

    await expectLater(device.recipes.setMasterVersion(recipeId, v3), throwsA(isA<IllegalStateException>()));
    expect(await masterOf(device, recipeId), v1);

    await device.recipes.setMasterVersion(recipeId, v2);
    expect(await masterOf(device, recipeId), v2);
  });

  test('MI-2: Master-Version ist nicht löschbar, andere Versionen schon', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (recipeId, v1) = await seedRecipe(device, foods);
    await device.recipes.snapshotVersion(v1);
    final v2 = await device.recipes.createDraftFrom(v1);
    await device.recipes.setMasterVersion(recipeId, v1);

    await expectLater(device.recipes.deleteVersion(v1), throwsA(isA<IllegalStateException>()));
    expect((await device.versionsOf(recipeId)).map((v) => v.id), containsAll([v1, v2]));
    expect(await masterOf(device, recipeId), v1);

    await device.recipes.deleteVersion(v2);
    expect((await device.versionsOf(recipeId)).map((v) => v.id), [v1]);
    expect(await masterOf(device, recipeId), v1);
  });

  test('MI-3: Master auf fremde, gelöschte oder unbekannte Version wird abgelehnt', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (recipeA, a1) = await seedRecipe(device, foods, title: 'A');
    final (_, b1) = await seedRecipe(device, foods, title: 'B');
    await device.recipes.snapshotVersion(a1);
    await device.recipes.snapshotVersion(b1);
    await device.recipes.setMasterVersion(recipeA, a1);

    final a2 = await device.recipes.createDraftFrom(a1);
    await device.recipes.snapshotVersion(a2);
    await device.recipes.deleteVersion(a2);

    for (final invalid in [b1, a2, 'gibt-es-nicht']) {
      await expectLater(device.recipes.setMasterVersion(recipeA, invalid), throwsA(isA<IllegalStateException>()),
          reason: invalid);
      expect(await masterOf(device, recipeA), a1, reason: invalid);
    }
  });

  test('MI-4: nach Import ist kein Master gesetzt; der importierte Snapshot kann Master werden', () async {
    final deviceA = Device.open();
    final foods = await seedFoods(deviceA);
    final (recipeA, versionA) = await seedRecipe(deviceA, foods);
    await deviceA.recipes.snapshotVersion(versionA);
    await deviceA.recipes.setMasterVersion(recipeA, versionA);
    final json = await deviceA.snapshots.exportVersionAsJsonString(versionA);

    final deviceB = Device.open();
    final recipeB = await deviceB.snapshots.importJsonString(json);
    final versionB = (await deviceB.versionsOf(recipeB)).single.id;

    expect(await masterOf(deviceB, recipeB), isNull);
    await deviceB.recipes.setMasterVersion(recipeB, versionB);
    expect(await masterOf(deviceB, recipeB), versionB);
  });
}
