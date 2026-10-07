// test/ui/shared/decimal_comma_test.dart
//
// UI-64 bis UI-66 (Teil 1.2, C30): Dezimalkomma in der ganzen Anzeige —
// Änderungsliste des Versionsvergleichs (Mengen, Backverlust,
// Fertiggewicht-Override), Verpackungsformular und Parameter des
// Rezept-Editors. Die Felder sind mit Komma vorbelegt und nehmen Komma und
// Punkt an; gespeichert wird der unveränderte Decimal-Wert.

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';
import 'package:unsalted_core/src/recipe/recipe_snapshot_v1.dart';
import 'package:unsalted_core/src/ui/foods/package_form.dart';
import 'package:unsalted_core/src/ui/recipe_editor/recipe_editor_screen.dart';
import 'package:unsalted_core/src/ui/versions/change_descriptions.dart';

Decimal d(String v) => Decimal.parse(v);

RecipeSnapshotV1 _snapshot({required String bakingLoss, String? override, List<RecipeSnapshotIngredient> ingredients = const []}) {
  const empty = NutrientSet();
  return RecipeSnapshotV1(
    recipe: const RecipeSnapshotRecipe(id: 'r', title: 'Brot'),
    version: RecipeSnapshotVersion(
      id: 'v',
      versionIndex: 1,
      bakingLossPercent: d(bakingLoss),
      finalWeightOverrideG: override == null ? null : d(override),
      notes: null,
      servings: null,
      createdAt: DateTime.utc(2026),
      snapshottedAt: DateTime.utc(2026),
    ),
    ingredients: ingredients,
    steps: const [],
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

String _fieldText(WidgetTester tester, String label) => tester
    .widget<EditableText>(find.descendant(of: find.widgetWithText(AppTextField, label), matching: find.byType(EditableText)))
    .controller
    .text;

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump();
  }
}

final _anyDecimalPoint = RegExp(r'\d\.\d');

void main() {
  test('UI-64: Änderungsliste mit Dezimalkomma (Mengen, Backverlust, Fertiggewicht)', () {
    final a = _snapshot(
      bakingLoss: '7.5',
      override: '850.25',
      ingredients: [RecipeSnapshotIngredient(position: 1, name: 'Mehl', quantity: d('0.25'), unit: 'kg')],
    );
    final texts = describeChanges(a, [
      SetBakingLoss(percent: d('12.5')),
      SetFinalWeightOverride(grams: d('900.5')),
      SetIngredientQuantity(position: 1, quantity: d('1.5'), unitCode: 'kg'),
      AddIngredient(position: 2, displayName: 'Hefe', quantity: d('0.5'), unitCode: 'g'),
    ]);
    expect(texts, [
      'Backverlust: 7,5 % → 12,5 %',
      'Fertiggewicht-Override: 850,25 g → 900,5 g',
      'Mehl: 0,25 kg → 1,5 kg',
      'Hefe hinzugefügt (0,5 g)',
    ]);
    expect(texts.where(_anyDecimalPoint.hasMatch), isEmpty);
  });

  testWidgets('UI-65: Verpackungsformular — Vorbelegung mit Komma, Eingabe mit Komma und Punkt', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final key = GlobalKey<PackageFormState>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PackageForm(
          key: key,
          initial: (
            name: 'Haferflocken',
            brand: null,
            barcode: null,
            densityGPerMl: d('0.4'),
            gramsPerPiece: d('50.5'),
            servingSizeG: d('40'),
            nutrients: NutrientSet(energyKcal: d('370'), fatG: d('7.5'), saltG: d('0.25')),
          ),
        ),
      ),
    ));
    expect(_fieldText(tester, 'Dichte (g/ml)'), '0,4');
    expect(_fieldText(tester, 'Stückgewicht (g)'), '50,5');
    expect(_fieldText(tester, 'Portionsgröße (g)'), '40');
    expect(_fieldText(tester, 'Fett (g)'), '7,5');
    expect(_fieldText(tester, 'Salz (g)'), '0,25');
    expect(key.currentState!.hasChanges, isFalse, reason: 'die Komma-Vorbelegung ist der Ausgangszustand');
    expect(key.currentState!.value!.nutrients.fatG, d('7.5'), reason: 'unverändert gespeichert');

    await tester.enterText(find.widgetWithText(AppTextField, 'Fett (g)'), '1,5');
    await tester.enterText(find.widgetWithText(AppTextField, 'Salz (g)'), '0.3');
    await tester.enterText(find.widgetWithText(AppTextField, 'Dichte (g/ml)'), '1,03');
    await tester.enterText(find.widgetWithText(AppTextField, 'Stückgewicht (g)'), '0.9');
    await tester.pump();
    final value = key.currentState!.value!;
    expect(value.nutrients.fatG, d('1.5'));
    expect(value.nutrients.saltG, d('0.3'));
    expect(value.densityGPerMl, d('1.03'));
    expect(value.gramsPerPiece, d('0.9'));
  });

  testWidgets('UI-66: Rezept-Editor — Backverlust und Fertiggewicht mit Komma, Eingabe mit Komma und Punkt',
      (tester) async {
    final database = (await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory())))!;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      await tester.runAsync(database.close);
    });
    final repo = DriftRecipeRepository(DriftRecipeDao(database), DriftFoodDao(database), database);
    final (recipeId, versionId) = (await tester.runAsync(() async {
      final recipeId = await repo.createRecipe(const NewRecipe(title: 'Brot'));
      final versionId = (await DriftRecipeDao(database).watchVersions(recipeId).first).first.id;
      await repo.saveDraft(RecipeVersionDraft(
        id: versionId,
        recipeId: recipeId,
        parentVersionId: null,
        versionIndex: 1,
        label: null,
        servings: null,
        bakingLossPercent: d('12.5'),
        finalWeightOverrideG: d('900.5'),
        notes: null,
        ingredients: const [],
        steps: const [],
      ));
      return (recipeId, versionId);
    }))!;

    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [coreDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(home: RecipeEditorScreen(recipeId: recipeId, versionId: versionId)),
    ));
    await _settle(tester);

    expect(_fieldText(tester, 'Backverlust (%)'), '12,5');
    expect(_fieldText(tester, 'Fertiggewicht-Override (g)'), '900,5');

    await tester.tap(find.widgetWithText(AppButton, 'Speichern'));
    await _settle(tester);
    final unchanged = (await tester.runAsync(() => repo.getVersion(versionId)))!;
    expect(unchanged.bakingLossPercent, d('12.5'), reason: 'Vorbelegung mit Komma speichert den gleichen Wert');
    expect(unchanged.finalWeightOverrideG, d('900.5'));

    await tester.enterText(find.widgetWithText(AppTextField, 'Backverlust (%)'), '7.5');
    await tester.enterText(find.widgetWithText(AppTextField, 'Fertiggewicht-Override (g)'), '850,25');
    await tester.pump();
    await tester.tap(find.widgetWithText(AppButton, 'Speichern'));
    await _settle(tester);
    final edited = (await tester.runAsync(() => repo.getVersion(versionId)))!;
    expect(edited.bakingLossPercent, d('7.5'));
    expect(edited.finalWeightOverrideG, d('850.25'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
