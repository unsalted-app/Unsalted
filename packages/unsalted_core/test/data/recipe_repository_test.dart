// test/data/recipe_repository_test.dart
//
// RP-01 bis RP-21 (Kapitel 23.4, Schritt 6.3), RP-22/RP-23 (Fehlerbehebung
// 9.1a, F1): DriftRecipeRepository gegen
// eine In-Memory-SQLite-Instanz. Jeder Test bekommt eine frische
// CoreDatabase + einen frischen DomainEventBus (Kapitel 16.5), damit Events
// aus einem Test keinen anderen beeinflussen.
//
// core_database.dart wird aliasiert importiert (`as db`), weil es die
// Drift-Zeilenklassen `RecipeIngredient`/`RecipeStep`/... erzeugt, die
// namensgleich mit den Fachmodellen aus recipe/ sind (Kapitel 16.8,
// CLAUDE.md Abschnitt 4).

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/contracts/domain_events.dart';
import 'package:unsalted_core/src/contracts/input_models.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_food_dao.dart';
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/data/domain_event_bus.dart';
import 'package:unsalted_core/src/data/drift_food_repository.dart';
import 'package:unsalted_core/src/data/drift_recipe_repository.dart';
import 'package:unsalted_core/src/food/food_variant.dart';
import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/recipe/recipe_change.dart';
import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_step.dart';

void main() {
  late db.CoreDatabase database;
  late DriftRecipeDao recipeDao;
  late DriftFoodDao foodDao;
  late DomainEventBus eventBus;
  late DriftRecipeRepository repo;

  setUp(() {
    database = db.CoreDatabase(NativeDatabase.memory());
    recipeDao = DriftRecipeDao(database);
    foodDao = DriftFoodDao(database);
    eventBus = DomainEventBus();
    repo = DriftRecipeRepository(recipeDao, foodDao, database, eventBus: eventBus);
  });

  tearDown(() async {
    await database.close();
  });

  // Hilfsfunktion: legt ein Rezept mit einem Draft (versionIndex 1) an und
  // gibt dessen recipeId + versionId zurück.
  Future<(String recipeId, String versionId)> createRecipeWithDraft({
    String title = 'Test',
  }) async {
    final recipeId = await repo.createRecipe(NewRecipe(title: title));
    final version = (await recipeDao.watchVersions(recipeId).first).first;
    return (recipeId, version.id);
  }

  RecipeVersionDraft draft(
    String versionId,
    String recipeId, {
    List<RecipeIngredient> ingredients = const [],
    List<RecipeStep> steps = const [],
    int versionIndex = 1,
    Decimal? bakingLossPercent,
    int? servings,
    Decimal? finalWeightOverrideG,
    String? notes,
    String? label,
  }) {
    return RecipeVersionDraft(
      id: versionId,
      recipeId: recipeId,
      parentVersionId: null,
      versionIndex: versionIndex,
      label: label,
      servings: servings,
      bakingLossPercent: bakingLossPercent ?? Decimal.zero,
      finalWeightOverrideG: finalWeightOverrideG,
      notes: notes,
      ingredients: ingredients,
      steps: steps,
    );
  }

  RecipeIngredient ingredient(
    String id,
    String versionId, {
    int position = 1,
    String displayName = 'Mehl',
    Decimal? quantity,
    String unitCode = 'g',
  }) {
    return RecipeIngredient(
      id: id,
      versionId: versionId,
      position: position,
      displayName: displayName,
      quantity: quantity ?? Decimal.fromInt(100),
      unitCode: unitCode,
    );
  }

  test('RP-01: createRecipe legt Rezept + Draft mit versionIndex = 1 an', () async {
    final (recipeId, versionId) = await createRecipeWithDraft(title: 'Pizzateig');

    final recipeRow = await recipeDao.getRecipe(recipeId);
    expect(recipeRow, isNotNull);
    expect(recipeRow!.title, 'Pizzateig');

    final versionRow = await recipeDao.getVersion(versionId);
    expect(versionRow, isNotNull);
    expect(versionRow!.versionIndex, 1);
    expect(versionRow.state, 'draft');
  });

  test(
      'RP-02: saveDraft führt das definierte Upsert-/Soft-Delete-Delta '
      'transaktional aus', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();

    final ing1 = ingredient('i1', versionId, position: 1, displayName: 'Mehl');
    final ing2 = ingredient('i2', versionId, position: 2, displayName: 'Salz');
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing1, ing2]));

    var active = await recipeDao.getIngredientsForVersion(versionId);
    expect(active.map((r) => r.id).toSet(), {'i1', 'i2'});

    // i1 aktualisieren, i2 weglassen (-> soft delete), i3 neu (-> insert).
    final ing1Updated = ing1.copyWith(quantity: Decimal.fromInt(600));
    final ing3 = ingredient('i3', versionId, position: 2, displayName: 'Zucker');
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing1Updated, ing3]));

    active = await recipeDao.getIngredientsForVersion(versionId);
    expect(active.map((r) => r.id).toSet(), {'i1', 'i3'});
    expect(active.firstWhere((r) => r.id == 'i1').quantity, Decimal.fromInt(600));
  });

  test('RP-03: saveDraft auf Snapshot wirft SnapshotImmutableException', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));
    await repo.snapshotVersion(versionId);

    expect(
      () => repo.saveDraft(draft(versionId, recipeId, ingredients: [ing])),
      throwsA(isA<SnapshotImmutableException>()),
    );
  });

  test('RP-04: snapshotVersion setzt state, snapshotJson, snapshottedAt', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));

    await repo.snapshotVersion(versionId);

    final row = await recipeDao.getVersion(versionId);
    expect(row!.state, 'snapshot');
    expect(row.snapshotJson, isNotNull);
    expect(row.snapshottedAt, isNotNull);
  });

  test('RP-05: snapshotVersion auf Snapshot wirft IllegalStateException', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));
    await repo.snapshotVersion(versionId);

    expect(() => repo.snapshotVersion(versionId), throwsA(isA<IllegalStateException>()));
  });

  test('RP-06: snapshotVersion ohne Zutaten wirft ValidationException', () async {
    final (_, versionId) = await createRecipeWithDraft();

    expect(() => repo.snapshotVersion(versionId), throwsA(isA<ValidationException>()));
  });

  test('RP-07: createDraftFrom kopiert tief mit neuen IDs und setzt parentVersionId', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    final step = RecipeStep(id: 's1', versionId: versionId, position: 1, instruction: 'Mischen');
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing], steps: [step]));

    final newVersionId = await repo.createDraftFrom(versionId);
    expect(newVersionId, isNot(versionId));

    final newVersionRow = await recipeDao.getVersion(newVersionId);
    expect(newVersionRow!.parentVersionId, versionId);

    final newIngredients = await recipeDao.getIngredientsForVersion(newVersionId);
    expect(newIngredients, hasLength(1));
    expect(newIngredients.first.id, isNot('i1'));
    expect(newIngredients.first.displayName, 'Mehl');

    final newSteps = await recipeDao.getStepsForVersion(newVersionId);
    expect(newSteps, hasLength(1));
    expect(newSteps.first.id, isNot('s1'));
    expect(newSteps.first.instruction, 'Mischen');
  });

  test('RP-08: createDraftFrom vergibt nächsten freien versionIndex', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));

    final v2Id = await repo.createDraftFrom(versionId);
    expect((await recipeDao.getVersion(v2Id))!.versionIndex, 2);

    final v3Id = await repo.createDraftFrom(v2Id);
    expect((await recipeDao.getVersion(v3Id))!.versionIndex, 3);
  });

  test('RP-09: applyChangesAsNewDraft wendet mehrere Änderungen sequenziell an', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId, quantity: Decimal.fromInt(500));
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));

    // Nach AddIngredient: [Mehl(1), Salz(2)]. SetIngredientQuantity(1)
    // bezieht sich auf den Zustand NACH dem Add (Mehl), RemoveIngredient(2)
    // ebenfalls auf den Zustand nach dem Set (Salz) -- Kapitel 14.4 Punkt 2:
    // sequenziell, nicht gegen den ursprünglichen Ausgangszustand.
    final newVersionId = await repo.applyChangesAsNewDraft(versionId, [
      AddIngredient(
        position: 2,
        displayName: 'Salz',
        quantity: Decimal.fromInt(10),
        unitCode: 'g',
      ),
      SetIngredientQuantity(position: 1, quantity: Decimal.fromInt(600)),
      const RemoveIngredient(position: 2),
    ]);

    final ingredients = await recipeDao.getIngredientsForVersion(newVersionId);
    expect(ingredients, hasLength(1));
    expect(ingredients.first.displayName, 'Mehl');
    expect(ingredients.first.quantity, Decimal.fromInt(600));
    expect(ingredients.first.position, 1);
  });

  test('RP-10: Fehler mitten in der Änderungsliste -> nichts wird geschrieben', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId, quantity: Decimal.fromInt(500));
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));

    await expectLater(
      repo.applyChangesAsNewDraft(versionId, [
        SetIngredientQuantity(position: 1, quantity: Decimal.fromInt(700)),
        SetIngredientQuantity(position: 99, quantity: Decimal.one),
      ]),
      throwsA(isA<ValidationException>()),
    );

    final versions = await recipeDao.watchVersions(recipeId).first;
    expect(versions, hasLength(1));
    expect(versions.first.id, versionId);
    final stillOriginal = await recipeDao.getIngredientsForVersion(versionId);
    expect(stillOriginal.single.quantity, Decimal.fromInt(500));
  });

  test('RP-11: setMasterVersion auf Draft wirft Fehler', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();

    expect(
      () => repo.setMasterVersion(recipeId, versionId),
      throwsA(isA<IllegalStateException>()),
    );
  });

  test('RP-12: softDeleteRecipe kaskadiert auf alle Versionen', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));
    final v2Id = await repo.createDraftFrom(versionId);

    await repo.softDeleteRecipe(recipeId);

    expect(await recipeDao.getRecipe(recipeId), isNull);
    final versions = await recipeDao.watchVersions(recipeId).first;
    expect(versions, isEmpty);
    expect(await recipeDao.getVersion(versionId), isNull);
    expect(await recipeDao.getVersion(v2Id), isNull);
  });

  test('RP-13: deleteVersion der letzten verbleibenden Version wirft Fehler', () async {
    final (_, versionId) = await createRecipeWithDraft();

    expect(() => repo.deleteVersion(versionId), throwsA(isA<IllegalStateException>()));
  });

  test('RP-14: assignOwner setzt ausschließlich null-Besitzer', () async {
    final (recipeId1, _) = await createRecipeWithDraft(title: 'A');
    final (recipeId2, _) = await createRecipeWithDraft(title: 'B');

    await recipeDao.updateRecipe(
      recipeId1,
      const db.RecipesCompanion(ownerId: Value('owner-existing')),
      0,
    );

    await repo.assignOwner('owner-new');

    final r1 = await recipeDao.getRecipe(recipeId1);
    final r2 = await recipeDao.getRecipe(recipeId2);
    expect(r1!.ownerId, 'owner-existing');
    expect(r2!.ownerId, 'owner-new');
  });

  test(
      'RP-15: updatedAt wird bei jedem Schreibvorgang neu gesetzt, auch ohne '
      'Wertänderung', () async {
    final (recipeId, _) = await createRecipeWithDraft();
    final before = (await recipeDao.getRecipe(recipeId))!.updatedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.updateRecipe(recipeId, const UpdateRecipeCommand(title: 'Test'));

    final after = (await recipeDao.getRecipe(recipeId))!.updatedAt;
    expect(after, greaterThan(before));
  });

  test('RP-16: gelöschte Zeilen erscheinen in keinem watch-Ergebnis', () async {
    final (recipeId, _) = await createRecipeWithDraft();
    await repo.softDeleteRecipe(recipeId);

    expect(await repo.watchRecipes().first, isEmpty);
    expect(await repo.watchRecipe(recipeId).first, isNull);
  });

  test(
      'RP-17: jedes dokumentierte Event wird pro erfolgreichem Aufruf genau '
      'einmal ausgelöst, kein Event bei Rollback', () async {
    final events = <DomainEvent>[];
    final sub = eventBus.events.listen(events.add);

    final (recipeId, versionId) = await createRecipeWithDraft();
    await Future<void>.delayed(Duration.zero);
    expect(events.whereType<RecipeCreated>(), hasLength(1));

    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));
    await Future<void>.delayed(Duration.zero);
    expect(events.whereType<RecipeUpdated>(), hasLength(1));

    await expectLater(
      repo.applyChangesAsNewDraft(versionId, [
        SetIngredientQuantity(position: 99, quantity: Decimal.one),
      ]),
      throwsA(isA<ValidationException>()),
    );
    await Future<void>.delayed(Duration.zero);
    // Kein zusätzliches RecipeUpdated durch den fehlgeschlagenen Aufruf.
    expect(events.whereType<RecipeUpdated>(), hasLength(1));

    await sub.cancel();
  });

  test('RP-18: Löschen der Master-Version wird abgelehnt', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing]));
    await repo.snapshotVersion(versionId);
    await repo.createDraftFrom(versionId); // zweite Version, damit nicht die letzte
    await repo.setMasterVersion(recipeId, versionId);

    expect(() => repo.deleteVersion(versionId), throwsA(isA<IllegalStateException>()));
  });

  test('RP-19: setMasterVersion mit fremder/gelöschter/Draft-Version wird abgelehnt', () async {
    final (recipeId1, versionId1) = await createRecipeWithDraft(title: 'A');
    final (recipeId2, versionId2) = await createRecipeWithDraft(title: 'B');

    // fremd: versionId2 gehört zu recipeId2, nicht recipeId1.
    expect(
      () => repo.setMasterVersion(recipeId1, versionId2),
      throwsA(isA<IllegalStateException>()),
    );
    // Draft: versionId1 ist kein Snapshot.
    expect(
      () => repo.setMasterVersion(recipeId1, versionId1),
      throwsA(isA<IllegalStateException>()),
    );
    // gelöscht/unbekannt.
    expect(
      () => repo.setMasterVersion(recipeId1, 'nicht-vorhanden'),
      throwsA(isA<IllegalStateException>()),
    );
  });

  test('RP-20: updateRecipe unterscheidet Nicht-Ändern und explizites null über PatchField',
      () async {
    final recipeId = await repo.createRecipe(
      const NewRecipe(title: 'Test', description: 'Beschreibung'),
    );

    // Nicht-Ändern: description weggelassen.
    await repo.updateRecipe(recipeId, const UpdateRecipeCommand(title: 'Neuer Titel'));
    var row = await recipeDao.getRecipe(recipeId);
    expect(row!.title, 'Neuer Titel');
    expect(row.description, 'Beschreibung');

    // Explizites null über PatchField.
    await repo.updateRecipe(recipeId, const UpdateRecipeCommand(description: PatchField(null)));
    row = await recipeDao.getRecipe(recipeId);
    expect(row!.description, isNull);
  });

  test(
      'RP-21: fehlende aktive Draft-Unterzeilen werden weich gelöscht und IDs '
      'nicht wiederverwendet', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final ing1 = ingredient('i1', versionId);
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [ing1]));

    // i1 im nächsten saveDraft weglassen -> weich gelöscht.
    await repo.saveDraft(draft(versionId, recipeId, ingredients: const []));
    expect(await recipeDao.getIngredientsForVersion(versionId), isEmpty);

    // dieselbe id erneut anbieten -> darf NICHT reaktiviert werden.
    await expectLater(
      repo.saveDraft(draft(versionId, recipeId, ingredients: [ing1])),
      throwsA(anything),
    );
  });

  Future<String> createMehlVariant() => DriftFoodRepository(foodDao).createVariant(NewFoodVariant(
        name: 'Mehl',
        brand: null,
        barcode: '4000000000017',
        source: FoodSource.custom,
        sourceRef: null,
        densityGPerMl: null,
        gramsPerPiece: null,
        servingSizeG: null,
        nutrients: NutrientSet(energyKcal: Decimal.fromInt(343)),
      ));

  test('RP-22: Kopie eines Snapshots behält die foodVariantId der Zeilen (9.1a, F1)', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final variantId = await createMehlVariant();
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [
      ingredient('i1', versionId).copyWith(foodVariantId: variantId),
      ingredient('i2', versionId, position: 2, displayName: 'Salz'),
    ]));
    await repo.snapshotVersion(versionId);

    final copy = await repo.createDraftFrom(versionId);
    final applied = await repo.applyChangesAsNewDraft(versionId, const []);

    for (final newVersionId in [copy, applied]) {
      final rows = await recipeDao.getIngredientsForVersion(newVersionId);
      expect(rows.map((r) => r.foodVariantId).toList(), [variantId, null], reason: newVersionId);
    }
  });

  test('RP-23: weicht die Zeile vom snapshotJson ab, bleibt foodVariantId null (9.1a, F1)', () async {
    final (recipeId, versionId) = await createRecipeWithDraft();
    final variantId = await createMehlVariant();
    await repo.saveDraft(draft(versionId, recipeId, ingredients: [
      ingredient('i1', versionId).copyWith(foodVariantId: variantId),
    ]));
    await repo.snapshotVersion(versionId);
    // Zeile an der DAO-Sperre vorbei verändern, um eine Abweichung zu erzwingen.
    await database.customStatement("UPDATE recipe_ingredients SET quantity = '999' WHERE id = 'i1'");

    final copy = await repo.createDraftFrom(versionId);
    final row = (await recipeDao.getIngredientsForVersion(copy)).single;

    expect(row.quantity, Decimal.fromInt(100), reason: 'Inhalt kommt aus snapshotJson');
    expect(row.foodVariantId, isNull);
  });
}
