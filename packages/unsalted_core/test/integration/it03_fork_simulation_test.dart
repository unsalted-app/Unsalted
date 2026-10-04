// test/integration/it03_fork_simulation_test.dart
//
// IT-03 (Kapitel 23.5): Export von Gerät A, Import auf Gerät B ohne die
// zugehörigen Varianten → Varianten werden mit `source = import` neu
// angelegt, Nährwerte stimmen mit dem Original überein. Gerät A und B sind
// zwei getrennte Datenbanken.

import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

import 'support/integration_harness.dart';

void main() {
  test('IT-03: Import ohne Varianten legt sie mit source = import neu an, Nährwerte identisch',
      () async {
    final deviceA = Device.open();
    final deviceB = Device.open();

    final foodsA = await seedFoods(deviceA);
    final (_, versionA) = await seedRecipe(deviceA, foodsA);
    await deviceA.recipes.snapshotVersion(versionA);
    final nutritionA = await deviceA.nutrition.forVersion(versionA);
    final json = await deviceA.snapshots.exportVersionAsJsonString(versionA);

    expect(await deviceB.allFoods(), isEmpty);
    final recipeB = await deviceB.snapshots.importJsonString(json);
    final versionB = (await deviceB.versionsOf(recipeB)).single;

    // Vier verknüpfte Zutaten → vier neue Varianten, alle source = import.
    final variantsB = await deviceB.allFoods();
    expect(variantsB, hasLength(4));
    expect(variantsB.map((v) => v.source).toSet(), {FoodSource.imported});

    // Jede neue Variante trägt exakt die Daten des Originals von Gerät A.
    for (final originalId in [foodsA.mehl, foodsA.milch, foodsA.butter, foodsA.ei]) {
      final original = (await deviceA.foods.getById(originalId))!;
      final copy = variantsB.singleWhere((v) => v.name == original.name);
      expect(copy.id, isNot(original.id));
      expect(copy.brand, original.brand);
      expect(copy.barcode, original.barcode);
      expect(copy.densityGPerMl, original.densityGPerMl);
      expect(copy.gramsPerPiece, original.gramsPerPiece);
      expect(copy.nutrients, original.nutrients);
    }

    // Zeilenbestand der importierten Version ist mit den neuen Varianten
    // verknüpft; die Zutat ohne Variante bleibt ohne.
    final importedRows = (await deviceB.version(versionB.id)).ingredients;
    expect(importedRows.where((i) => i.foodVariantId != null).map((i) => i.foodVariantId).toSet(),
        variantsB.map((v) => v.id).toSet());
    expect(importedRows.singleWhere((i) => i.displayName == 'Salz').foodVariantId, isNull);

    expectSameNutrition(await deviceB.nutrition.forVersion(versionB.id), nutritionA);
  });
}
