# unsalted — Briefing für Claude Code

Diese Datei wird von Claude Code automatisch zu Beginn jeder Session gelesen.
Sie ist die Kurzfassung; die **verbindliche technische Spezifikation** ist
`docs/spezifikation.md` — bei jedem Widerspruch zwischen dieser Datei und
`docs/spezifikation.md` gilt `docs/spezifikation.md`.

`PROJECT.md` (falls noch vorhanden) ist **veraltet** und wurde durch diese
Datei ersetzt — nicht mehr verwenden, ggf. löschen, um Widersprüche zu
vermeiden.

---

## 0. Wie du in diesem Projekt arbeitest

1. Lies `docs/status.md` **zuerst**, um zu sehen, welcher Schritt gerade
   aktiv ist.
2. Lies in `docs/spezifikation.md` das Kapitel, das der aktuelle Schritt in
   Kapitel 24 ("Entwicklungsplan"/"Arbeitskarten") referenziert, **bevor**
   du Code schreibst.
3. Arbeite **ausschließlich** im Dateiscope, den die Arbeitskarte des
   aktuellen Schritts nennt. Keine Datei außerhalb dieses Scopes anfassen,
   auch nicht "kurz aufräumen".
4. Nach jeder Änderung: passenden Test ergänzen, `flutter analyze` und
   `flutter test` laufen lassen, `docs/status.md` aktualisieren.
5. Bei Unsicherheit über eine Paket-API (Drift, Riverpod, etc.): über
   `web_search`/offizielle Doku verifizieren, nicht raten. Diese Regel hat
   uns in der Vorarbeit mehrfach vor kaputtem generiertem Code bewahrt
   (siehe Abschnitt 4).
6. Nach `dart run build_runner build --delete-conflicting-outputs`: prüfen,
   ob eine `.dart`-Quelldatei ihre `part`-Direktive verloren hat (z. B. weil
   sie von einer konkreten Klasse zu einem Interface wurde). In dem Fall
   bleibt die alte `.g.dart` als Leiche liegen und muss **manuell** gelöscht
   werden — `--delete-conflicting-outputs` erkennt das nicht automatisch.

---

## 1. Projektstruktur (Stand: nach Schritt 6.1)

```text
unsalted/
├─ CLAUDE.md                       diese Datei
├─ architecture.yaml
├─ docs/
│  ├─ spezifikation.md             VERBINDLICHE Spezifikation (Quelle der Wahrheit)
│  ├─ status.md                    Phase/Schritt-Tracker
│  └─ decisions.md                 Protokoll technischer Entscheidungen
├─ tool/
│  └─ check_architecture.dart
├─ drift_schemas/
│  └─ drift_schema_v1.json         Schema v1, eingefroren (Kapitel 25.1)
└─ packages/
   └─ unsalted_core/
      ├─ pubspec.yaml
      ├─ lib/
      │  ├─ unsalted_core.dart               öffentliche Tür — NOCH LEER (Schritt 8.4 offen)
      │  └─ src/
      │     ├─ nutrition/                    Phase 2, fertig, reines Dart
      │     │  ├─ decimal_math.dart
      │     │  ├─ unit_catalog.dart
      │     │  ├─ nutrient_set.dart
      │     │  ├─ nutrition_result.dart
      │     │  ├─ nutrition_engine.dart
      │     │  ├─ nutrient_validator.dart
      │     │  └─ nutrition_formatter.dart
      │     ├─ recipe/                       Phase 3+4, fertig
      │     │  ├─ recipe.dart
      │     │  ├─ recipe_version.dart
      │     │  ├─ recipe_ingredient.dart
      │     │  ├─ recipe_step.dart
      │     │  ├─ recipe_change.dart
      │     │  ├─ recipe_diff.dart
      │     │  ├─ recipe_snapshot_v1.dart
      │     │  └─ snapshot_codec.dart
      │     ├─ food/
      │     │  └─ food_variant.dart
      │     ├─ contracts/                    Schritt 3.3 + 6.1, fertig
      │     │  ├─ core_exceptions.dart
      │     │  ├─ input_models.dart          PatchField, UpdateRecipeCommand, NewRecipe,
      │     │  │                             RecipeVersionDraft, IngredientInput, NewFoodVariant
      │     │  ├─ domain_events.dart
      │     │  ├─ recipe_repository.dart     abstract RecipeRepository
      │     │  ├─ food_repository.dart       abstract FoodRepository
      │     │  ├─ nutrition_service.dart     abstract NutritionService
      │     │  └─ snapshot_service.dart      abstract SnapshotService
      │     ├─ data/                         Phase 5, fertig
      │     │  ├─ core_database.dart         + Typedefs RecipeRow/RecipeVersionRow/
      │     │  │                             RecipeIngredientRow/RecipeStepRow/FoodVariantRow
      │     │  ├─ converters/decimal_converter.dart
      │     │  ├─ tables/
      │     │  │  ├─ recipes.dart
      │     │  │  ├─ recipe_versions.dart
      │     │  │  ├─ recipe_ingredients.dart
      │     │  │  ├─ recipe_steps.dart
      │     │  │  └─ food_variants.dart
      │     │  ├─ daos/                      Kapitel 16.8: Interface + Drift-Implementierung getrennt
      │     │  │  ├─ recipe_dao.dart         abstract RecipeDao
      │     │  │  ├─ drift_recipe_dao.dart   class DriftRecipeDao implements RecipeDao
      │     │  │  ├─ food_dao.dart           abstract FoodDao
      │     │  │  └─ drift_food_dao.dart     class DriftFoodDao implements FoodDao
      │     │  └─ mappers/                   ACHTUNG: siehe Abschnitt 3 — Review nötig vor Schritt 6.3
      │     │     ├─ recipe_mapper.dart
      │     │     ├─ version_mapper.dart
      │     │     ├─ ingredient_mapper.dart
      │     │     ├─ step_mapper.dart
      │     │     └─ food_mapper.dart
      │     ├─ module/                       NOCH NICHT ANGELEGT (Phase 7)
      │     ├─ providers/                    NOCH NICHT ANGELEGT (Phase 7)
      │     └─ ui/                           NOCH NICHT ANGELEGT (Phase 8)
      └─ test/
         ├─ architecture/                    AT-01 bis AT-12, alle fertig und grün
         │  ├─ at01_no_upper_imports_test.dart … at12_no_kj_text_test.dart
         │  ├─ public_api_golden.txt
         │  └─ support/architecture_test_utils.dart
         ├─ nutrition/                       6 Testdateien, Phase 2
         ├─ recipe/
         │  ├─ recipe_test.dart
         │  ├─ recipe_version_test.dart
         │  ├─ recipe_ingredient_test.dart
         │  ├─ recipe_change_test.dart
         │  └─ recipe_diff_test.dart
         │     (recipe_step_test.dart fehlt noch — bekannte Lücke, siehe Abschnitt 3)
         ├─ food/food_variant_test.dart
         ├─ contract/
         │  ├─ recipe_snapshot_v1_test.dart
         │  ├─ golden_test.dart
         │  └─ golden/gd01…gd04.json
         └─ data/
            ├─ decimal_converter_test.dart   MG-04
            ├─ mg01_schema_dump_exists_test.dart
            ├─ mg02_migration_test.dart
            ├─ mg03_core_database_test.dart
            └─ mg05_no_real_columns_test.dart
```

---

## 2. Aktueller Stand

**Abgeschlossen:** Phase 0 (Projektgrundlage), Phase 1 (Architektur, AT-01–AT-12),
Phase 2 (Rechenkern), Phase 3 (Fachmodelle), Phase 4 (Snapshot-Format,
`RecipeDiff`), Phase 5 (Drift-Datenbank: Tabellen, Converter, `CoreDatabase`,
Schema v1 eingefroren, DAOs), **Schritt 6.1** (Verträge und Input-Modelle).

**Nächster Schritt: 6.2 — `DomainEventBus`.** In-Memory-Broadcast für
`DomainEvent` (siehe `contracts/domain_events.dart`), Datei
`lib/src/data/domain_event_bus.dart`. Details: `docs/spezifikation.md`,
Kapitel 16.5 / Arbeitskarte Schritt 6.2.

Danach: 6.3 `DriftRecipeRepository`, 6.4 `DriftFoodRepository`,
6.5 `DriftNutritionService`, 6.6 `DriftSnapshotService`, dann Phase 7
(Modul-/Steckplatzsystem), Phase 8 (UI), Phase 9 (Integration/Spike),
Phase 10 (Freeze).

---

## 3. Offene Punkte, die beim Weiterbauen nicht vergessen werden dürfen

- **Mapper vs. neue DAO-Signaturen (Kapitel 16.8):** `data/mappers/*.dart`
  wurden für den *alten* DAO-Methodensatz aus Schritt 5.5 gebaut
  (einzelne `insertRecipe`/`insertVersion`/`insertIngredients` usw.). Die
  DAOs heißen jetzt anders und haben ein konsolidiertes Methodenset
  (`saveDraftIngredients`/`saveDraftSteps` mit Upsert-/Soft-Delete-Delta,
  `insertRecipe(recipe, version)` kombiniert beide Inserts). **Vor Schritt
  6.3 prüfen, ob die Mapper-Funktionen noch zu den DAO-Signaturen passen,
  insbesondere `food_mapper.dart`: `FoodDao.insertVariant`/`updateVariant`
  nehmen einen vollen `FoodVariantRow` entgegen, kein
  `FoodVariantsCompanion` — `food_mapper.dart` liefert aber bisher nur
  Companions.**
- **`recipe_step_test.dart` fehlt.** `RecipeStep` selbst ist korrekt gebaut
  (Schritt 3.1), aber ungetestet. Nachholen, sobald ein Test dafür
  ansteht — kein Blocker, aber Lücke.
- **Upsert-/Soft-Delete-Delta für `recipe_ingredients`/`recipe_steps`**
  (Kapitel 10.7 der neuen Spezifikation) verlangt **stabile IDs** über
  mehrere `saveDraft`-Aufrufe hinweg. Das ist ein Verhaltenswechsel
  gegenüber der alten Spezifikation (dort: hart löschen + neu einfügen).
  Die DAO-Implementierung (`drift_recipe_dao.dart`) setzt das bereits um;
  darauf achten, dass Aufrufer (Repository, Schritt 6.3) tatsächlich
  stabile IDs übergeben, nicht bei jedem Speichern neue erzeugen.

---

## 4. Bereits gelöste Stolperfallen — nicht erneut hineinlaufen

- **Namenskollision Drift-Zeilen vs. Fachmodelle:** `Recipes` (Tabelle)
  erzeugt automatisch die Drift-Zeilenklasse `Recipe` — identisch zum
  Fachmodell `Recipe` aus `recipe/recipe.dart`. Gelöst über Typedefs in
  `core_database.dart` (`RecipeRow = Recipe` usw.). In DAO-Interfaces und
  -Implementierungen **immer** `RecipeRow`/`RecipeVersionRow`/etc.
  verwenden, nie den rohen Drift-Namen direkt neben dem Fachmodell-Import.
- **`TypeConverter` + `.nullable()`-Reihenfolge:** Immer
  `text().map(const DecimalConverter()).nullable()()` — **niemals**
  `.nullable().map(...)`. Die falsche Reihenfolge erzeugt kaputten
  generierten Code (bestätigter Drift-Bug, siehe `decimal_converter.dart`).
- **`@DriftAccessor`/`@DriftDatabase` brauchen direkte Tabellen-Importe.**
  `import '../core_database.dart';` allein reicht nicht, um an die
  Tabellenklassen zu kommen — jede Tabelle einzeln importieren
  (`import '../tables/recipes.dart';` usw.), sonst „Undefined name
  'Recipes'" trotz korrektem `core_database.dart`.
- **Verwaiste `.g.dart`-Dateien nach Refactoring:** Wenn eine Datei ihre
  `part`-Direktive verliert (z. B. Interface statt konkreter Klasse), bleibt
  die alte generierte Datei liegen und erzeugt kryptische Fehler wie
  „Superinterfaces don't have a valid override for 'managers'". Immer
  manuell löschen vor `build_runner build --delete-conflicting-outputs`.

---

## 5. Grundregeln (Kurzfassung — vollständig in `docs/spezifikation.md`, Kapitel 1)

- Abhängigkeit nur nach hinten (`architecture.yaml`).
- Eine öffentliche Tür je Paket (`lib/unsalted_core.dart`), alles unter
  `lib/src/` privat.
- Keine Fremdschlüssel, Text-UUIDs, kein Auto-Increment.
- Alle Schreibzugriffe über Repositories.
- Fachliche Zahlen: `Decimal`, intern `Rational`, niemals `double`.
- Energie ausschließlich `energy_kcal`, kein kJ.
- Rundung ausschließlich im `NutritionFormatter`.
- Fachmodell ≠ Persistenzmodell — welches Standardfeld (`id`,
  `created_at`, `updated_at`, `deleted_at`) in welches Fachmodell gehört,
  legt Kapitel 10 der Spezifikation pro Modell einzeln fest.