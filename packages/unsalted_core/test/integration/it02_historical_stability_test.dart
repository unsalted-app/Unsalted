// test/integration/it02_historical_stability_test.dart
//
// IT-02 (Kapitel 23.5): Snapshot erstellen → verknüpftes Lebensmittel ändern
// → Snapshot-Nährwerte unverändert. Gegenprobe: ein Draft mit demselben
// Lebensmittel rechnet danach tatsächlich mit den neuen Werten.

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

void main() {
  test('IT-02: Änderung am verknüpften Lebensmittel lässt den Snapshot unverändert', () async {
    final device = Device.open();
    final foods = await seedFoods(device);
    final (_, snapshotId) = await seedRecipe(device, foods, title: 'Eingefroren');
    final (_, draftId) = await seedRecipe(device, foods, title: 'Entwurf');

    await device.recipes.snapshotVersion(snapshotId);
    final snapshotBefore = await device.nutrition.forVersion(snapshotId);
    final jsonBefore = await device.snapshots.exportVersionAsJsonString(snapshotId);
    final draftBefore = await device.nutrition.forVersion(draftId);

    final mehl = (await device.foods.getById(foods.mehl))!;
    await device.foods.updateVariant(FoodVariant(
      id: mehl.id,
      name: mehl.name,
      brand: mehl.brand,
      barcode: mehl.barcode,
      source: mehl.source,
      sourceRef: mehl.sourceRef,
      densityGPerMl: mehl.densityGPerMl,
      gramsPerPiece: mehl.gramsPerPiece,
      servingSizeG: mehl.servingSizeG,
      nutrients: NutrientSet(
        energyKcal: d('364'),
        fatG: d('1.4'),
        saturatedFatG: d('0.3'),
        carbsG: d('72.5'),
        sugarsG: d('1.1'),
        fiberG: d('2.9'),
        proteinG: d('10.5'),
        saltG: d('0.02'),
      ),
    ));

    expectSameNutrition(await device.nutrition.forVersion(snapshotId), snapshotBefore);
    expect(await device.snapshots.exportVersionAsJsonString(snapshotId), jsonBefore);

    final draftAfter = await device.nutrition.forVersion(draftId);
    expect(draftAfter.total.energyKcal, isNot(draftBefore.total.energyKcal),
        reason: 'Gegenprobe: der Draft muss die Änderung sehen');
  });
}
