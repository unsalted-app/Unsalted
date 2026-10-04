// test/integration/it05_double_import_test.dart
//
// IT-05 (Kapitel 23.5): Import desselben JSON zweimal → zwei unabhängige
// Rezepte, aber (bei Barcode- oder Name+Brand+Nährwert-Treffer) nur ein Satz
// Lebensmittel-Varianten. Export auf Gerät A, beide Importe auf Gerät B.
// Die Fixture enthält zwei Varianten mit Barcode (Mehl, Milch) und zwei ohne
// (Butter mit Marke, Ei ohne Marke), damit beide Trefferwege greifen.

import 'package:flutter_test/flutter_test.dart';

import 'support/integration_harness.dart';

void main() {
  test('IT-05: zweimal importiert → zwei Rezepte, ein Satz Varianten', () async {
    final deviceA = Device.open();
    final deviceB = Device.open();

    final foodsA = await seedFoods(deviceA);
    final (_, versionA) = await seedRecipe(deviceA, foodsA);
    await deviceA.recipes.snapshotVersion(versionA);
    final json = await deviceA.snapshots.exportVersionAsJsonString(versionA);

    final first = await deviceB.snapshots.importJsonString(json);
    final variantsAfterFirst = await deviceB.allFoods();
    final second = await deviceB.snapshots.importJsonString(json);

    expect(first, isNot(second));
    expect((await deviceB.allRecipes()).map((r) => r.id).toSet(), {first, second});

    final firstVersion = (await deviceB.versionsOf(first)).single;
    final secondVersion = (await deviceB.versionsOf(second)).single;
    expect(firstVersion.id, isNot(secondVersion.id));

    final variantsAfterSecond = await deviceB.allFoods();
    expect(variantsAfterSecond, hasLength(4));
    expect(variantsAfterSecond.map((v) => v.id).toSet(), variantsAfterFirst.map((v) => v.id).toSet());

    // Beide Rezepte zeigen positionsweise auf dieselben Varianten.
    final rowsFirst = (await deviceB.version(firstVersion.id)).ingredients;
    final rowsSecond = (await deviceB.version(secondVersion.id)).ingredients;
    expect(rowsSecond.map((i) => i.foodVariantId).toList(), rowsFirst.map((i) => i.foodVariantId).toList());
    expect(rowsSecond.map((i) => i.id).toSet().intersection(rowsFirst.map((i) => i.id).toSet()), isEmpty);
  });
}
