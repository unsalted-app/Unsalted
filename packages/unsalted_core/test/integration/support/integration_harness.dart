// test/integration/support/integration_harness.dart
//
// Schritt 9.1: gemeinsamer Aufbau der Integrationstests. Ein "Gerät" ist
// eine eigene In-Memory-CoreDatabase plus ein ProviderContainer mit
// denselben Overrides wie apps/unsalted_app/lib/main.dart. Repositories und
// Services kommen ausschließlich über die Provider, Importe ausschließlich
// über die öffentliche Tür -- die Tests sehen das System so, wie die App es
// verdrahtet.

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

Decimal d(String value) => Decimal.parse(value);

class Device {
  Device._(this.db, this.container);

  final CoreDatabase db;
  final ProviderContainer container;

  /// Öffnet ein frisches Gerät; wird am Testende automatisch geschlossen.
  static Device open() {
    // Gerät A/B: zwei CoreDatabase-Instanzen gleichzeitig sind hier gewollt.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = CoreDatabase(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      coreDatabaseProvider.overrideWithValue(db),
      modulesProvider.overrideWithValue(const <UnsaltedModule>[CoreModule()]),
    ]);
    final device = Device._(db, container);
    addTearDown(device._close);
    return device;
  }

  RecipeRepository get recipes => container.read(recipeRepositoryProvider);
  FoodRepository get foods => container.read(foodRepositoryProvider);
  NutritionService get nutrition => container.read(nutritionServiceProvider);
  SnapshotService get snapshots => container.read(snapshotServiceProvider);

  Future<List<Recipe>> allRecipes() => recipes.watchRecipes().first;
  Future<List<FoodVariant>> allFoods() => foods.watchAll().first;
  Future<List<RecipeVersion>> versionsOf(String recipeId) => recipes.watchVersions(recipeId).first;
  Future<Recipe?> recipe(String recipeId) => recipes.watchRecipe(recipeId).first;

  Future<RecipeVersion> version(String versionId) async {
    final v = await recipes.getVersion(versionId);
    expect(v, isNotNull, reason: 'Version $versionId fehlt');
    return v!;
  }

  Future<void> _close() async {
    container.dispose();
    await db.close();
  }
}

/// Eindeutige IDs für neue Zutaten-/Schrittzeilen innerhalb eines Tests.
int _idCounter = 0;
String newRowId(String prefix) => '$prefix-${++_idCounter}';

// ---------------------------------------------------------------------------
// Lebensmittel: je zwei Varianten mit Barcode und zwei ohne (Name/Marke),
// damit beide Zuordnungswege aus Kapitel 13.6 Punkt 5 abgedeckt sind. Werte
// mit krummen Nachkommastellen, damit exakte Decimal-Vergleiche etwas
// bedeuten.
// ---------------------------------------------------------------------------

class SeedFoods {
  SeedFoods(this.mehl, this.milch, this.butter, this.ei);
  final String mehl;
  final String milch;
  final String butter;
  final String ei;
}

final _mehlNutrients = NutrientSet(
  energyKcal: d('343'),
  fatG: d('1.2'),
  saturatedFatG: d('0.2'),
  carbsG: d('70.1'),
  sugarsG: d('1.5'),
  fiberG: d('3.5'),
  proteinG: d('11.03'),
  saltG: d('0.013'),
);

Future<SeedFoods> seedFoods(Device device) async {
  final mehl = await device.foods.createVariant(NewFoodVariant(
    name: 'Weizenmehl Type 550',
    brand: 'Mühle Nord',
    barcode: '4000000000017',
    source: FoodSource.custom,
    sourceRef: null,
    densityGPerMl: null,
    gramsPerPiece: null,
    servingSizeG: null,
    nutrients: _mehlNutrients,
  ));
  final milch = await device.foods.createVariant(NewFoodVariant(
    name: 'Vollmilch',
    brand: null,
    barcode: '4000000000024',
    source: FoodSource.custom,
    sourceRef: null,
    densityGPerMl: d('1.032'),
    gramsPerPiece: null,
    servingSizeG: null,
    nutrients: NutrientSet(
      energyKcal: d('64'),
      fatG: d('3.5'),
      saturatedFatG: d('2.3'),
      carbsG: d('4.8'),
      sugarsG: d('4.8'),
      fiberG: null,
      proteinG: d('3.3'),
      saltG: d('0.13'),
    ),
  ));
  final butter = await device.foods.createVariant(NewFoodVariant(
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
      saltG: d('0.02'),
    ),
  ));
  final ei = await device.foods.createVariant(NewFoodVariant(
    name: 'Ei',
    brand: null,
    barcode: null,
    source: FoodSource.custom,
    sourceRef: null,
    densityGPerMl: null,
    gramsPerPiece: d('58.333'),
    servingSizeG: null,
    nutrients: NutrientSet(
      energyKcal: d('137'),
      fatG: d('9.3'),
      saturatedFatG: d('2.6'),
      carbsG: d('1.5'),
      sugarsG: d('0.7'),
      fiberG: d('0'),
      proteinG: d('11.9'),
      saltG: d('0.35'),
    ),
  ));
  return SeedFoods(mehl, milch, butter, ei);
}

/// Legt "Hefezopf" mit fünf Zutaten (vier verknüpft, eine ohne Variante),
/// drei Schritten, Portionen und Backverlust als Draft an. Liefert
/// (recipeId, versionId) der Draft-Version V1.
Future<(String, String)> seedRecipe(Device device, SeedFoods foods, {String title = 'Hefezopf'}) async {
  final recipeId = await device.recipes.createRecipe(NewRecipe(title: title, description: 'Sonntagsgebäck'));
  final versionId = (await device.versionsOf(recipeId)).single.id;
  await device.recipes.saveDraft(RecipeVersionDraft(
    id: versionId,
    recipeId: recipeId,
    parentVersionId: null,
    versionIndex: 1,
    label: 'mit Vorteig',
    servings: 12,
    bakingLossPercent: d('12.5'),
    finalWeightOverrideG: null,
    notes: 'Über Nacht gehen lassen',
    ingredients: [
      ingredient(versionId, 1, 'Weizenmehl Type 550', '500', 'g', variantId: foods.mehl),
      ingredient(versionId, 2, 'Vollmilch', '250.5', 'ml', variantId: foods.milch),
      ingredient(versionId, 3, 'Butter', '80', 'g', variantId: foods.butter, note: 'weich'),
      ingredient(versionId, 4, 'Ei', '2', 'piece', variantId: foods.ei),
      ingredient(versionId, 5, 'Salz', '1', 'pinch'),
    ],
    steps: [
      step(versionId, 1, 'Alles verkneten.', timerSeconds: 600),
      step(versionId, 2, 'Gehen lassen.', timerSeconds: 3600),
      step(versionId, 3, 'Flechten und backen.'),
    ],
  ));
  return (recipeId, versionId);
}

RecipeIngredient ingredient(
  String versionId,
  int position,
  String name,
  String quantity,
  String unit, {
  String? variantId,
  String? note,
  String? id,
}) =>
    RecipeIngredient(
      id: id ?? newRowId('ing'),
      versionId: versionId,
      position: position,
      foodVariantId: variantId,
      displayName: name,
      quantity: d(quantity),
      unitCode: unit,
      note: note,
    );

RecipeStep step(String versionId, int position, String instruction, {int? timerSeconds, String? id}) => RecipeStep(
      id: id ?? newRowId('step'),
      versionId: versionId,
      position: position,
      instruction: instruction,
      timerSeconds: timerSeconds,
    );

/// Baut einen Draft aus einer bestehenden Version, mit ersetzten Feldern.
RecipeVersionDraft draftOf(
  RecipeVersion v, {
  List<RecipeIngredient>? ingredients,
  List<RecipeStep>? steps,
  int? servings,
  Decimal? bakingLossPercent,
  Decimal? finalWeightOverrideG,
  String? notes,
}) =>
    RecipeVersionDraft(
      id: v.id,
      recipeId: v.recipeId,
      parentVersionId: v.parentVersionId,
      versionIndex: v.versionIndex,
      label: v.label,
      servings: servings ?? v.servings,
      bakingLossPercent: bakingLossPercent ?? v.bakingLossPercent,
      finalWeightOverrideG: finalWeightOverrideG ?? v.finalWeightOverrideG,
      notes: notes ?? v.notes,
      ingredients: ingredients ?? v.ingredients,
      steps: steps ?? v.steps,
    );

/// Legt ein Rezept an und speichert dessen V1-Draft mit den gegebenen
/// Zutaten/Schritten. Liefert (recipeId, versionId).
Future<(String, String)> createRecipeWith(
  Device device, {
  required String title,
  required List<RecipeIngredient> Function(String versionId) ingredients,
  List<RecipeStep> Function(String versionId)? steps,
  int? servings,
  String bakingLossPercent = '0',
  String? finalWeightOverrideG,
  String? notes,
}) async {
  final recipeId = await device.recipes.createRecipe(NewRecipe(title: title));
  final versionId = (await device.versionsOf(recipeId)).single.id;
  await device.recipes.saveDraft(RecipeVersionDraft(
    id: versionId,
    recipeId: recipeId,
    parentVersionId: null,
    versionIndex: 1,
    label: null,
    servings: servings,
    bakingLossPercent: d(bakingLossPercent),
    finalWeightOverrideG: finalWeightOverrideG == null ? null : d(finalWeightOverrideG),
    notes: notes,
    ingredients: ingredients(versionId),
    steps: steps?.call(versionId) ?? const [],
  ));
  return (recipeId, versionId);
}

/// Erzeugt aus dem Snapshot [versionA] wie in der App eine bearbeitete
/// Zielversion B (Kopie als Draft, vollständig neu gespeichert, eingefroren).
/// Zutaten und Schritte von B werden komplett vorgegeben, inklusive
/// Lebensmittel-Verknüpfung -- so wie der Nutzer sie im Editor setzt.
Future<String> createTargetVersion(
  Device device,
  String versionA, {
  required List<RecipeIngredient> Function(String versionId) ingredients,
  List<RecipeStep> Function(String versionId)? steps,
  int? servings,
  String? bakingLossPercent,
  String? finalWeightOverrideG,
  String? notes,
}) async {
  final versionB = await device.recipes.createDraftFrom(versionA);
  final copy = await device.version(versionB);
  await device.recipes.saveDraft(draftOf(
    copy,
    ingredients: ingredients(versionB),
    steps: steps?.call(versionB) ?? copy.steps,
    servings: servings,
    bakingLossPercent: bakingLossPercent == null ? null : d(bakingLossPercent),
    finalWeightOverrideG: finalWeightOverrideG == null ? null : d(finalWeightOverrideG),
    notes: notes,
  ));
  await device.recipes.snapshotVersion(versionB);
  return versionB;
}

/// Kapitel 15.5: Diff(A, B) → applyChangesAsNewDraft(A) → snapshotVersion.
class RoundTrip {
  RoundTrip(this.changes, this.target, this.result, this.resultVersionId);
  final List<RecipeChange> changes;
  final RecipeSnapshotV1 target;
  final RecipeSnapshotV1 result;
  final String resultVersionId;

  List<RecipeChange> get remainingDiff => RecipeDiff.between(result, target);
}

Future<RoundTrip> roundTrip(Device device, String versionA, String versionB) async {
  final a = await device.snapshots.exportVersion(versionA);
  final b = await device.snapshots.exportVersion(versionB);
  final targetRows = (await device.version(versionB)).ingredients;
  final changes = RecipeDiff.between(a, b, targetRows: targetRows);
  final applied = await device.recipes.applyChangesAsNewDraft(versionA, changes);
  await device.recipes.snapshotVersion(applied);
  return RoundTrip(changes, b, await device.snapshots.exportVersion(applied), applied);
}

String describe(List<RecipeChange> changes) => changes.map((c) => c.toJson()).toList().toString();

/// Exakter Vergleich zweier Berechnungsergebnisse, ohne Toleranz.
void expectSameNutrition(NutritionResult actual, NutritionResult expected) {
  expect(actual.rawWeightG, expected.rawWeightG, reason: 'rawWeightG');
  expect(actual.finalWeightG, expected.finalWeightG, reason: 'finalWeightG');
  expect(actual.total, expected.total, reason: 'total');
  expect(actual.per100g, expected.per100g, reason: 'per100g');
  expect(actual.perServing, expected.perServing, reason: 'perServing');
  expect(actual.incomplete, expected.incomplete, reason: 'incomplete');
  expect(actual.notCalculable, expected.notCalculable, reason: 'notCalculable');
  expect(actual.hasAnyNutrition, expected.hasAnyNutrition, reason: 'hasAnyNutrition');
}
