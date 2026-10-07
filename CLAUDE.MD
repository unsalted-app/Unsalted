# unsalted — Briefing für Claude Code

Diese Datei wird von Claude Code automatisch zu Beginn jeder Session gelesen.
Sie ist die Kurzfassung; die **verbindliche technische Spezifikation** ist
`docs/spezifikation.md` — bei jedem Widerspruch zwischen dieser Datei und
`docs/spezifikation.md` gilt `docs/spezifikation.md`. **Innerhalb der
Spezifikation gilt Kapitel 28 („Nachträge und Klarstellungen zu Teil 1“) vor
Kapitel 1–27** — vor dem Lesen eines Kapitels prüfen, ob Kapitel 28 dazu
etwas festlegt.

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
   auch nicht "kurz aufräumen" — auch keine "kleine" Ergänzung wie ein
   einzelnes `onTap`. `docs/status.md`, `docs/decisions.md` und diese Datei
   sind davon ausgenommen (Projekt-Meta-Dokumentation, nach jedem Schritt
   zu pflegen, unabhängig vom Dateiscope des Schritts).
4. Nach jeder Änderung: passenden Test ergänzen, `flutter analyze` und
   `flutter test` laufen lassen, `docs/status.md` aktualisieren.
5. Bei Unsicherheit über eine Paket-API (Drift, Riverpod, go_router,
   drift_flutter etc.): über `web_search`/offizielle Doku bzw. den lokalen
   Pub-Cache (`~/.pub-cache/hosted/pub.dev/<paket>-<version>/lib/...`)
   verifizieren, nicht raten. Diese Regel hat uns in der Vorarbeit mehrfach
   vor kaputtem generiertem Code bewahrt (siehe Abschnitt 4).
6. Nach `dart run build_runner build --delete-conflicting-outputs`: prüfen,
   ob eine `.dart`-Quelldatei ihre `part`-Direktive verloren hat (z. B. weil
   sie von einer konkreten Klasse zu einem Interface wurde). In dem Fall
   bleibt die alte `.g.dart` als Leiche liegen und muss **manuell** gelöscht
   werden — `--delete-conflicting-outputs` erkennt das nicht automatisch.
7. **Scope-Konflikt → stoppen und fragen, nicht selbst erweitern.** Wenn
   eine Arbeitskarte nur erfüllbar ist, indem man eine Datei außerhalb
   ihres Dateiscopes ändert oder gegen ein ausdrückliches Verbot
   („VERBOTENE ÄNDERUNGEN") verstößt, nicht improvisieren, sondern den
   Konflikt dem Projektverantwortlichen vorlegen. Präzedenzfall: Nachtrag
   8.7a (`docs/decisions.md`) — freigegeben als eng begrenzter Nachtrag,
   nicht vom Assistenten eigenmächtig.
8. **Diese Datei tatsächlich schreiben, nicht nur planen:** Am Ende jedes
   Schritts prüfen, ob Abschnitt 1 (Projektstruktur) und Abschnitt 2
   (Aktueller Stand) noch stimmen, und editieren, falls nicht. Diese Datei
   war zwischen Schritt 6.2 und Schritt 8.8 nicht aktuell gehalten worden
   (sie zeigte noch „Nächster Schritt: 6.2", obwohl Phase 6–8 längst fertig
   waren) — das führt dazu, dass eine neue Session mit falschem Kontext
   startet. Nicht wiederholen.

---

## 1. Projektstruktur (Stand: `part1-v1.0.0` — Teil 1 abgeschlossen, Phase 0–10)

```text
unsalted/
├─ CLAUDE.md                       diese Datei
├─ architecture.yaml
├─ docs/
│  ├─ spezifikation.md             VERBINDLICHE Spezifikation (Quelle der Wahrheit)
│  ├─ status.md                    Phase/Schritt-Tracker
│  ├─ decisions.md                 Protokoll technischer Entscheidungen
│  └─ design/                      Teil 1.2: plan.md, design_system.md, components.md, screens.md
├─ tool/
│  └─ check_architecture.dart      muss mit Exit 0 enden (seit Nachtrag 1.1a)
├─ .github/workflows/ci.yml       CI: check_architecture, analyze + test in Design, Core, App, Widgetbook
├─ apps/
│  ├─ unsalted_widgetbook/         Komponenten-Katalog (Teil 1.2, C11), Rang 99, nur macOS;
│  │                               lib/catalog/ je Design-Ordner eine Datei, Tests WB-01–03
│  └─ unsalted_app/                App-Hülle (Schritt 8.8)
│     ├─ pubspec.yaml              unsalted_core (path-Dependency), drift_flutter,
│     │                            flutter_riverpod, go_router
│     ├─ lib/config/ui_options.dart  einzige Stelle mit den Anzeige-Schaltern (C29)
     ├─ lib/main.dart             ProviderScope-Overrides (appOverrides), GoRouter aus
│     │                            modules.expand((m) => m.routes), ShellRoute
│     │                            mit NavigationBar (/, /foods, /settings)
│     └─ test/widget_test.dart     App-Start-Rauchtest
└─ packages/
   ├─ unsalted_design/             Design-System (Teil 1.2), Rang 0, nur Flutter, Tür mit show
   │  └─ lib/src/  tokens/ theme/ layout/ components/<gruppe>/ templates/; Tests DS-01–48
   └─ unsalted_core/
      ├─ pubspec.yaml
      ├─ drift_schemas/
      │  └─ drift_schema_v1.json      Schema v1, eingefroren (Kapitel 25.1)
      ├─ lib/
      │  ├─ unsalted_core.dart               öffentliche Tür — eingefroren seit Schritt 7.4;
      │  │                                   additiv: CoreUiOptions, coreUiOptionsProvider (28.9 Punkt 6)
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
      │     │  ├─ recipe_diff.dart           between(a, b, {targetRows}) — siehe Abschnitt 4
      │     │  ├─ snapshot_row_match.dart    Sicherheitsregel Zeile ↔ Snapshot-Zutat (9.1a), nicht exportiert
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
      │     ├─ data/                         Phase 5+6, fertig
      │     │  ├─ core_database.dart         + Typedefs RecipeRow/RecipeVersionRow/
      │     │  │                             RecipeIngredientRow/RecipeStepRow/FoodVariantRow
      │     │  ├─ domain_event_bus.dart      DomainEventBus (Schritt 6.2)
      │     │  ├─ drift_recipe_repository.dart  (Schritt 6.3)
      │     │  ├─ drift_food_repository.dart     (Schritt 6.4)
      │     │  ├─ drift_nutrition_service.dart   (Schritt 6.5)
      │     │  ├─ drift_snapshot_service.dart    (Schritt 6.6)
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
      │     │  └─ mappers/                   ACHTUNG: siehe Abschnitt 3 — Review nötig vor Aufräum-Schritt
      │     │     ├─ recipe_mapper.dart
      │     │     ├─ version_mapper.dart     recipeVersionToSnapshotCompanion = toter Code
      │     │     ├─ ingredient_mapper.dart
      │     │     ├─ step_mapper.dart
      │     │     └─ food_mapper.dart        Insert-/Update-Companion-Funktionen = toter Code
      │     ├─ module/                       Phase 7, fertig
      │     │  ├─ unsalted_module.dart       abstract UnsaltedModule
      │     │  ├─ extension_types.dart       RecipeContext, RecipeDetailSection, RecipeAction,
      │     │  │                             SettingsEntry, SyncTableSpec
      │     │  └─ core_module.dart           class CoreModule — routes seit Nachtrag 8.7a gefüllt (Kapitel 22)
      │     ├─ providers/                    Phase 7, fertig
      │     │  └─ core_providers.dart        alle 8 Provider aus Kapitel 16.7
      │     └─ ui/                           Bildschirm 1–13; seit Teil 1.2 nur aus Design-Komponenten
      │        │                             (Templates + Abschnitte, docs/design/screens.md)
      │        ├─ config/core_ui_options.dart   Anzeige-Schalter (Teil 1.2 C29), über die Tür exportiert
      │        ├─ <bereich>/<name>_screen.dart  Zustand, Daten, Aktionen
      │        ├─ <bereich>/sections/*_section.dart  je Abschnitt eine Datei, zustandslos
      │        ├─ recipe_list/recipe_card.dart, foods/food_tile.dart, versions/version_tile.dart,
      │        │  versions/snapshot_column.dart, versions/change_list.dart,
      │        │  recipe_editor/ingredient_row.dart, recipe_editor/step_row.dart (StepRowData),
      │        │  recipe_editor/food_variant_picker_dialog.dart, recipe_detail/version_switcher.dart,
      │        │  nutrition/*, foods/package_form.dart   fachliche Bausteine
      │        ├─ versions/change_descriptions.dart     Texte der Änderungsliste (9.2a)
      │        ├─ settings/export_screen.dart / import_screen.dart  Lücken: kein Teilen-Dialog,
      │        │                                                    keine Datei-Auswahl
      │        ├─ shared/undoable_deletion.dart         Löschen mit 5 s „Rückgängig“ (Teil 1.1b),
      │        │                                        UI-interne Provider, nicht exportiert
      │        └─ shared/unit_labels.dart               Einheiten deutsch, Dezimalkomma (Teil 1.2 C27b)
      └─ test/
         ├─ architecture/                    AT-01 bis AT-15, alle grün (AT-13–15 seit Teil 1.2)
         │  ├─ at01_no_upper_imports_test.dart … at15_design_only_in_ui_test.dart
         │  ├─ public_api_golden.txt
         │  └─ support/  architecture_test_utils.dart, ui_rules.dart (Detektoren AT-13/14)
         ├─ nutrition/                       6 Testdateien, Phase 2
         ├─ recipe/
         │  ├─ recipe_test.dart
         │  ├─ recipe_version_test.dart
         │  ├─ recipe_ingredient_test.dart
         │  ├─ recipe_change_test.dart
         │  └─ recipe_diff_test.dart
         │     (RecipeStep wird laut 18.1 in recipe_ingredient_test.dart getestet, seit 10.1a)
         ├─ food/food_variant_test.dart
         ├─ contract/
         │  ├─ recipe_snapshot_v1_test.dart
         │  ├─ golden_test.dart
         │  └─ golden/gd01…gd04.json     Schlüssel alphabetisch (13.4, seit 10.1b)
         ├─ data/
         │  ├─ decimal_converter_test.dart   MG-04
         │  ├─ mg01_schema_dump_exists_test.dart
         │  ├─ mg02_migration_test.dart
         │  ├─ mg03_core_database_test.dart
         │  ├─ mg05_no_real_columns_test.dart
         │  ├─ event_bus_test.dart
         │  ├─ recipe_repository_test.dart   RP-01…23
         │  ├─ food_repository_test.dart     FD-01…05
         │  ├─ nutrition_service_test.dart
         │  └─ snapshot_service_test.dart    IT-01/03/05, GD-11/12
         ├─ spike/                           Schritt 9.3: mehrere Drift-Klassen auf einer DB
         │                                   (SpikeDatabase, SpikeCombinedDatabase + .g.dart,
         │                                   echte Temp-Datei), Ergebnis in decisions.md
         ├─ integration/                     Schritt 9.1: IT-01…IT-06 + Edge Cases DA/SI/MI,
         │                                   echte Systemkette über die Provider, Gerät A/B
         │                                   = getrennte In-Memory-Datenbanken (support/)
         └─ ui/                              Phase 8, je Bildschirm eine Testdatei
            ├─ recipe_list/, recipe_editor/, recipe_detail/, nutrition/,
            │  versions/, foods/, settings/  — Testmuster siehe Abschnitt 4
```

---

## 2. Aktueller Stand

**Teil 1 (`unsalted_core` + App-Hülle) ist abgeschlossen und eingefroren:**
annotierter Tag `part1-v1.0.0` auf dem Commit „Schritt 10.3: Release-Check --
Teil 1 abgeschlossen“. Phase 0–10 sind fertig; der Freeze-Nachweis (alle
Kriterien aus Kapitel 25 erfüllt) steht in `docs/status.md`, alle Nachträge
und Klarstellungen in Kapitel 28 der Spezifikation.

**Was das für jede weitere Arbeit bedeutet:**
- Den Tag `part1-v1.0.0` nie verschieben oder neu setzen.
- Änderungen an Teil 1 nur noch im Rahmen von Kapitel 25.2 (Fehlerbehebung
  ohne Signatur- oder Formatänderung, additive Erweiterungen) und nur mit
  eigener, vom Projektverantwortlichen freigegebener Arbeitskarte; jede
  solche Änderung bekommt einen Eintrag in `docs/decisions.md` und, wo sie
  die Spezifikation berührt, in Kapitel 28.
- Bekannte Grenzen von `part1-v1.0.0` (Teilen-Dialog, Dateiauswahl, E2,
  Design-Punkte): Kapitel 28.8 und `docs/status.md`.

**Teil 1.1 (abgeschlossen, Tag `part1-v1.1.0` auf `25b09d9`):** 1.1a fertig (kein Flackern beim
Versionswechsel im Rezeptdetail), 1.1b fertig (Rezepte und Lebensmittel
löschen mit 5 s „Rückgängig“), 1.1c fertig (Ladebalken im Rezeptdetail erst
nach 300 ms), 1.1d fertig (CI-Zeitlimit, Tests räumen auch bei
Fehlschlag auf); Test-IDs bis UI-46.

**Teil 1.2 – Design-System (abgeschlossen, Tags `part1-v1.2.0` und
`design-v0.1.0` auf Merge-Commit `763fa45`):** eigenes Paket
`packages/unsalted_design` (Rang 0, nur Flutter), Widgetbook-Katalog
`apps/unsalted_widgetbook`, alle Core-Bildschirme aus Templates und
Abschnitten (AT-13/14/15 ohne Ausnahmen), Anzeige-Schalter `CoreUiOptions`
(Werte nur in `apps/unsalted_app/lib/config/ui_options.dart`), deutsche
Einheiten und Dezimalkomma in der ganzen Anzeige. Plan, Regeln und
Bildschirme: `docs/design/`; Entscheidungen C01–C30 in `docs/decisions.md`;
Spezifikation Kapitel 28.9. Der frühere Design-Pass `design/1.1` wurde nicht
übernommen und ist gelöscht. Test-IDs neu: DS-01–48 (+DS-20b), WB-01–03,
AT-13–15, UI-58–66, UC-01–07, APP-02.

**Nächster Schritt:** neue Arbeitskarten (z. B. echtes Design aus Figma über
die Tokens, Teil 2 `unsalted_experiments`) nach Vorgabe des
Projektverantwortlichen.

---

## 3. Offene Punkte, die beim Weiterbauen nicht vergessen werden dürfen

- **Mapper-Leichen (Kapitel 16.8):** `foodVariantToInsertCompanion`/
  `foodVariantToUpdateCompanion` in `food_mapper.dart` und
  `recipeVersionToSnapshotCompanion` in `version_mapper.dart` sind toter
  Code (0 Aufrufer) — die zugehörigen Repositories/Services bauen die
  Zeilen seit Schritt 6.4/6.6 direkt selbst, weil die DAO-Signaturen einen
  vollen Row-Typ statt eines Companions erwarten. Aufräumen, sobald eine
  Arbeitskarte `data/mappers/*.dart` in ihrem Dateiscope erlaubt.
- **`export_screen.dart`/`import_screen.dart` ohne nativen Teilen-Dialog
  bzw. Datei-Auswahl** (nur Zwischenablage/Text einfügen) — bräuchte
  `share_plus`/`file_picker` und damit eine `pubspec.yaml`-Änderung von
  `unsalted_core`, die außerhalb des Dateiscopes von Schritt 8.7 lag.
- **Upsert-/Soft-Delete-Delta für `recipe_ingredients`/`recipe_steps`**
  (Kapitel 10.7) verlangt **stabile IDs** über mehrere `saveDraft`-Aufrufe
  hinweg. `drift_recipe_dao.dart` setzt das um; darauf achten, dass
  Aufrufer tatsächlich stabile IDs übergeben (z. B. bei UI-Formularen: die
  vom DAO zurückgegebene/kopierte ID weiterverwenden, nie bei jedem Save
  neu generieren — siehe auch den Testfallstrick in Abschnitt 4 zu
  `createDraftFrom`).

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
- **`testWidgets()` + `NativeDatabase.memory()` hängt scheinbar (seit
  Schritt 8.1):** `testWidgets`-Tests laufen in einer FakeAsync-Zone; echte
  Async-Arbeit (Drift-FFI/Isolate-Kommunikation von `NativeDatabase`) muss
  über `await tester.runAsync(() async { ... })` laufen, sonst wartet der
  Test scheinbar endlos. **Wichtig beim Debuggen:** niemals `flutter test
  ... | tail -N` verwenden, um das zu diagnostizieren — `tail` ohne `-f`
  puffert alles bis zum Prozessende und zeigt bis dahin **gar nichts** an,
  was wie ein echter Hänger aussieht, obwohl der Test in Wahrheit nur ein
  paar Sekunden braucht und dann sauber fehlschlägt. Direkt ohne Pipe
  laufen lassen. Zweite Falle derselben Ursache: am Testende „A Timer is
  still pending even after the widget tree was disposed" — Drifts
  `QueryStream` plant beim Abbestellen (StreamBuilder-Dispose) einen
  echten Zero-Duration-Timer; vor Testende `await
  tester.pumpWidget(const SizedBox.shrink()); await
  tester.pump(Duration.zero);` einbauen, um ihn auszupumpen, solange noch
  aktiv gepumpt werden kann. Dritte Falle: Formulare mit vielen Feldern
  passen nicht in die Standard-Testfläche (800×600) — `ListView` baut dann
  untere Felder gar nicht erst auf; `tester.view.physicalSize` vor dem
  ersten `pumpWidget` vergrößern (z. B. `Size(800, 3000)`) statt in jedem
  Test zu scrollen. Siehe `test/ui/foods/food_list_screen_test.dart` und
  `food_editor_screen_test.dart` für das vollständige Muster.
- **`PopScope(canPop: ...)` + programmatischer Pop direkt nach `setState`
  schlägt fehl (seit Schritt 8.2):** Wenn `canPop` von einem State-Feld
  abhängt (z. B. „ungespeicherte Eingaben"), reicht `setState(() =>
  feld = neuerWert)` gefolgt von einem sofortigen `Navigator.of(context).pop()`
  **nicht** — Flutter liest `canPop` aus dem zuletzt gebauten `PopScope`-
  Widget, nicht live aus dem State-Feld, und ein `setState`-Aufruf wird
  erst zum nächsten Frame angewendet. Ein Pop unmittelbar danach sieht
  deshalb noch den alten (blockierenden) Wert und wird kommentarlos zu
  einem No-Op (`RoutePopDisposition.doNotPop`) — kein Fehler, kein Crash,
  die Seite bleibt einfach sichtbar. Das ist ein echter Bug im
  Anwendungscode, kein reines Testartefakt (in der echten App tritt er
  identisch auf, weil Rebuilds auch dort erst zum nächsten Frame
  angewendet werden). Fix: `setState(...)` gefolgt von
  `WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) ...pop...; })`
  statt direktem Pop. In Widget-Tests danach `pumpAndSettle()` statt einer
  festen Dauer verwenden (die Standard-Transition dauert exakt 300 ms —
  ein `pump(Duration(milliseconds: 300))` kann genau auf der Grenze
  landen). Siehe `recipe_create_screen.dart`/`_save()`.
- **AT-12 ("kein kJ") schlägt auch auf eigene Test-Strings/-Kommentare an
  (seit Schritt 8.4):** AT-12 scannt `lib/` **und** `test/` zeilenweise auf
  das wörtliche Zeichenpaar — nur `test/architecture/` selbst ist
  ausgenommen. Ein Test, der die Abwesenheit dieser Energieeinheit prüft
  (z. B. für eine Nährwerttabelle), darf sie deshalb weder im
  Testnamen-String noch im Kommentar noch im erwarteten Suchbegriff wörtlich
  ausschreiben — sonst schlägt AT-12 auf die eigene Testdatei an, nicht auf
  einen echten Verstoß. Lösung: den Suchbegriff zur Laufzeit aus
  Zeichencodes zusammenbauen (`String.fromCharCodes([0x6b, 0x4a])`), nie als
  Literal. Betrifft nur `test/`-Dateien außerhalb von `test/architecture/`;
  `lib/`-Code darf die Einheit ohnehin nirgends erwähnen (R7).
- **Dropdown-Einträge (`DropdownButtonFormField`) existieren erst im
  Widget-Baum, während das Overlay-Menü offen ist** — `find.text(...)` auf
  einen Menüpunkt schlägt fehl, wenn davor nicht per `tester.tap()` geöffnet
  wurde. Erst öffnen, dann prüfen.
- **Wiederverwendete, hartkodierte IDs in Test-Fixtures kollidieren mit
  automatisch kopierten IDs:** `createDraftFrom(versionA)` kopiert
  Zutaten/Schritte mit **neu generierten** IDs in die neue Version. Ein Test,
  der für Version B einen `RecipeVersionDraft` mit einer wiederverwendeten
  literalen ID aus Version A baut (z. B. `'i1'`), löst
  `UNIQUE constraint failed: recipe_ingredients.id` aus, weil diese ID
  bereits (mit neuer Zeile) existiert — IDs sind global pro Tabelle
  eindeutig, nicht pro Version gescoped. Stattdessen die tatsächlich
  kopierte ID über `getIngredientsForVersion`/`getStepsForVersion` holen,
  bevor man den Update-Draft baut.
- **AT-09 gilt projektweit, auch für `apps/unsalted_app` (seit Schritt
  8.8):** Die App darf nur `package:unsalted_core/unsalted_core.dart`
  importieren, niemals `package:unsalted_core/src/...` — auch wenn
  `architecture.yaml` der App Rang 99 („darf alles") gibt (das betrifft nur
  die Rangregel AT-01, nicht die Tür-Regel). Da die Tür keine Widgets
  exportiert, erreicht die App Bildschirme ausschließlich über
  `UnsaltedModule.routes`. Ein erster 8.8-Versuch mit direkten
  `src/ui`-Importen wurde von AT-09 zu Recht abgelehnt.
- **Wer `RecipeDiff.between` für eine anzuwendende Änderungsliste aufruft,
  MUSS `targetRows` der Zielversion übergeben, sonst gehen
  Lebensmittel-Verknüpfungen verloren** (seit 9.1a). Das Snapshot-Format
  führt keine Variant-ID; ohne `targetRows` tragen `AddIngredient`/
  `ReplaceIngredient` immer `foodVariantId: null`, und der übernommene Draft
  rechnet anders als die Zielversion. Die Zeilen kommen über
  `RecipeRepository.getVersion(versionB)` (auch für Snapshots), siehe
  `version_compare_screen.dart`. Nur für reine Anzeige- oder Prüf-Diffs, die
  nie angewendet werden, darf `targetRows` fehlen.
- **Integrationstests vergleichen exakt, ohne Toleranz** (seit 9.1): Nährwerte
  als Decimal über `expectSameNutrition`, Snapshot-JSON byte-genau. Jede
  Rundreise prüft zusätzlich die Nährwerte — ein leerer Rest-Diff allein
  beweist nichts, wenn der Diff eine Änderung übersieht (so wurde F5
  gefunden).
- **Im Rezept-Editor ist `IngredientRowData.foodVariantId` die gespeicherte
  Verknüpfung, `variant` nur das aufgelöste Lebensmittel** (seit 9.1b).
  Gespeichert wird immer `foodVariantId`, nie `variant?.id` — sonst verliert
  jede Zeile mit weich gelöschtem Lebensmittel beim Speichern ihre
  Verknüpfung. Die Verknüpfung ändert sich nur über `copyWith(variant: …)`
  (Auswahl oder Namensänderung).
- **Texte im Versionsvergleich nie durch Nachschlagen in Version A bilden**
  (seit 9.2a): Positionen einer `RecipeChange` beziehen sich auf die Liste
  unmittelbar vor dieser Änderung (Kapitel 14.4). `describeChanges` wendet
  die Liste deshalb nur für die Anzeige der Reihe nach an; die Liste selbst
  bleibt unverändert und wird exakt so übernommen.
- **`build_runner --build-filter` kann fremde generierte Dateien löschen**
  (seit 9.3): Ein auf `test/spike/**` gefilterter zweiter Lauf hat
  `core_database.g.dart` und die DAO-`.g.dart` gelöscht. Nach jedem
  `build_runner`-Lauf `git status` prüfen und gelöschte, committete
  `.g.dart` mit `git checkout -- <datei>` wiederherstellen. Zwei
  `@DriftDatabase`-Klassen mit derselben Tabelle gehören in getrennte
  Bibliotheken, sonst erzeugt Drift doppelte Klassen im selben `part` und
  der Compiler bricht ab (sieht in `flutter test` wie ein Hänger aus).
- **Mehrere Drift-Klassen auf einer Datenbank: Ergebnis des Spikes 9.3
  beachten** (docs/decisions.md, „Spike 20.1“): nur eine Klasse besitzt
  Schema, Migrationen und `user_version` und öffnet zuerst; alle anderen
  Klassen auf derselben `DatabaseConnection`-Instanz; keine Transaktion über
  mehrere Klassen; nie getrennte Verbindungen auf dieselbe Datei.
- **Long-Press-Drag in `ReorderableListView`-Widget-Tests** (seit 9.1b):
  Ein einzelnes `gesture.moveTo` auf das Ziel löst kein Umsortieren aus.
  Muster: `startGesture` auf den Drag-Handle, `pump(Duration(seconds: 1))`
  für den Long-Press, dann in ~10 Schritten mit `Offset.lerp` und kurzem
  `pump` je Schritt bis knapp über das Ziel bewegen, `up()`,
  `pumpAndSettle()`. Siehe UI-12 in `recipe_editor_screen_test.dart`.
- **„hit test missed" ist nur eine Warnung — der Test kann trotzdem grün
  sein** (seit Teil 1.1a): Ein Tap, der danebengeht, wirft keinen Fehler.
  Typischer Fall: zwei Chip-Wechsel nacheinander mit `_settle`-artigem
  Pumpen ohne Zeitvorschub — die `ChoiceChip`-Auswahl-Animation steht still,
  der zweite Tap verfehlt den Chip. Nach einem Auswahlwechsel die Animation
  mit `pump(Duration(milliseconds: 500))` auslaufen lassen
  (`pumpAndSettle` hängt, solange ein `LinearProgressIndicator` läuft) und
  direkt nach jedem Tap seine Wirkung prüfen (z. B. gewählter Chip), nicht
  erst das Endergebnis. Siehe `_tapVersion` in
  `recipe_detail_screen_test.dart`.
- **`SnackBar` mit `action` schließt in Flutter 3.47.5 nie von selbst**
  (seit Teil 1.1b): `persist` ist standardmäßig `action != null`, `duration`
  wird dann ignoriert. Für eine zeitlich begrenzte SnackBar mit Aktion
  `persist: false` setzen. `controller.close()` setzt voraus, dass die SnackBar
  noch vorne in der Warteschlange steht (Assert) — nur aufrufen, solange
  `controller.closed` nicht abgeschlossen ist. Siehe
  `ui/shared/undoable_deletion.dart`.
- **`tester.runAsync` liefert bei einer Ausnahme still `null`** (seit Teil
  1.1b): Der Fehler landet in `takeException`, der Rückgabewert ist `null`.
  Wer `expect(await tester.runAsync(...), isNull)` prüft (z. B. „gelöscht“),
  muss danach `expect(tester.takeException(), isNull)` prüfen, sonst gilt eine
  Ausnahme als Erfolg.
- **Datenbank in Widget-Tests immer über `_closeDatabase` schließen** (seit
  Teil 1.1d): `addTearDown(() => _closeDatabase(tester, database));` direkt
  nach dem Öffnen, nie `addTearDown(() => tester.runAsync(database.close))`.
  Nach einem roten Test lässt `flutter_test` den Widget-Baum stehen; Drift
  wartet in `close()` auf seine Abbestell-Timer (`Timer.run`) in der
  Fake-Zone, die dann niemand mehr auspumpt — der ganze Lauf hing (z. B. wenn
  ein Test direkt nach Tap + `pump()` ohne Dauer scheitert). `_closeDatabase`
  baut erst den Baum ab und pumpt aus, dann schließt es. Der Aufruf von
  `_disposeWidgetTree` am Ende des Testkörpers bleibt trotzdem nötig (sonst
  „A Timer is still pending“ bei grünen Tests). `ci.yml` bricht nach 20 min ab.
  Für Gegenproben mit Zeitlimit nicht `perl alarm` verwenden: Das beendet nur
  das `flutter`-Startskript, die `flutter_tester`-Kinder laufen als Waisen
  weiter.
- **`dart doc` meldet fehlende Doku-Kommentare nicht** (seit 10.2): Lücken
  findet man nur mit vorübergehend aktiviertem Lint `public_member_api_docs`
  (nicht committen) und Filter auf die über `lib/unsalted_core.dart`
  exportierten Deklarationen. Neue öffentliche API immer mit `///` anlegen;
  in `lib/` nie die verbotene Energieeinheit schreiben, auch nicht in
  Kommentaren (AT-12).
- **`tool/check_architecture.dart` rechnete Pfade falsch (behoben mit
  Nachtrag 1.1a):** Die Ausnahmen prüfen Pfade relativ zu `lib/`
  (`src/ui/`, `src/module/`, `src/data/`). Das Tool ist seitdem grün und
  sollte bei jedem Schritt zusätzlich zu AT-01–AT-12 mit Exit 0 enden.

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
- **Aussehen nur im Design-System (Teil 1.2):** `packages/unsalted_design`
  (Rang 0, nur Flutter, keine Fachbegriffe, keine UI-Texte). In
  `lib/src/ui/` keine Material-Bausteine, für die es eine Design-Komponente
  gibt, keine festen Farben, keine Stile, keine Zahlen für Abstände (AT-13,
  AT-14, Liste in `test/architecture/support/ui_rules.dart`);
  `package:unsalted_design/` nur in `lib/src/ui/` (AT-15). Regeln:
  `docs/design/design_system.md`.
- Fachmodell ≠ Persistenzmodell — welches Standardfeld (`id`,
  `created_at`, `updated_at`, `deleted_at`) in welches Fachmodell gehört,
  legt Kapitel 10 der Spezifikation pro Modell einzeln fest.
