# unsalted — Status

Diese Datei wird nach **jedem** Schritt aktualisiert (siehe CLAUDE.md,
Abschnitt 0). Status ist immer eines von: `offen` · `in Arbeit` · `fertig`.

Phasennummerierung ist die des konsolidierten Berichts (`docs/spezifikation.md`,
Kapitel 24) — **nicht** die einer älteren Berichtsfassung. Phase 6 vereint
Repositories **und** Nährwert-/Austausch-Services in einer Phase (STEP 6.1
bis 6.6); es gibt keine separate „Phase 7 — Nährwerte und Austausch" mehr.

## Phase 0 — Projektgrundlage — abgeschlossen
## Phase 1 — Architektur — abgeschlossen
## Phase 2 — Rechenkern — abgeschlossen
## Phase 3 — Fachmodelle — abgeschlossen
## Phase 4 — Snapshot-Format — abgeschlossen
## Phase 5 — Drift-Datenbank — abgeschlossen

Nachtrag 0.1a (docs/decisions.md): CI unter `.github/workflows/ci.yml`
(Architekturprüfung, analyze + test in Core und App, Flutter 3.47.5) — fertig.

Nachtrag 1.1a (docs/decisions.md): `tool/check_architecture.dart` repariert,
endet mit Exit 0 — fertig.

(Details/Teilschritte dieser sechs Phasen: Kapitel 24.2 der Spezifikation.
Alle Architekturtests AT-01 bis **AT-12** grün, inkl. AT-12 „kein kJ".)

## Phase 6 — Repositories und Services (Kapitel 24.3) — abgeschlossen
| Schritt | Beschreibung | Status |
|---|---|---|
| 6.1 | Verträge und Input-Modelle (`input_models.dart`, `domain_events.dart`, `recipe_repository.dart`, `food_repository.dart`, `nutrition_service.dart`, `snapshot_service.dart`) | fertig |
| 6.2 | DomainEventBus | fertig |
| 6.3 | DriftRecipeRepository | fertig |
| 6.4 | DriftFoodRepository | fertig |
| 6.5 | DriftNutritionService | fertig |
| 6.6 | DriftSnapshotService | fertig |

**Erledigt in 6.4 (ohne food_mapper.dart zu ändern):** `FoodDao.insertVariant`/
`updateVariant` verlangen einen vollen `FoodVariantRow`, `food_mapper.dart`
liefert aber nur `FoodVariantsCompanion` (CLAUDE.md Abschnitt 3). Der
Dateiscope von Schritt 6.4 erlaubte kein Ändern von Mappern — deshalb baut
`drift_food_repository.dart` die Zeile für insert/update direkt selbst
(`_toRow`), statt `food_mapper.dart` anzufassen.

## Phase 7 — Erweiterungssystem (Kapitel 24.4) — abgeschlossen
| Schritt | Beschreibung | Status |
|---|---|---|
| 7.1 | Modultypen | fertig |
| 7.2 | CoreModule | fertig |
| 7.3 | Provider | fertig |
| 7.4 | Öffentliche Tür schließen | fertig |

## Phase 8 — Oberfläche (Kapitel 24.5) — abgeschlossen
| Schritt | Beschreibung | Status |
|---|---|---|
| 8.1 | Lebensmittel-Liste + Editor | fertig |
| 8.2 | Rezeptliste + Erstellen | fertig |
| 8.3 | Rezept-Editor | fertig |
| 8.4 | Nährwertanzeige + Mengenrechner | fertig |
| 8.5 | Rezeptdetail mit Steckplätzen | fertig |
| 8.6 | Versionen + Vergleich | fertig |
| 8.7 | Einstellungen, Export, Import | fertig |
| 8.7a | Nachtrag: Core-Routen in `CoreModule.routes` (docs/decisions.md) | fertig |
| 8.8 | App-Hülle verdrahten | fertig |
| 8.8a | Nachtrag: Navigation Rezeptliste → Detail → Editor/Versionen (docs/decisions.md) | fertig |

Phase 8 — abgeschlossen.

## Phase 9 — Integration und Spike (Kapitel 24.6) — abgeschlossen
| Schritt | Beschreibung | Status |
|---|---|---|
| 9.1 | Integrationstests (IT-01–IT-06 + Edge Cases DA/SI/MI, `test/integration/`) | fertig |
| 9.1a | Fehlerbehebung Draft-Kopie und Diff/Apply, F1–F5 (docs/decisions.md) | fertig |
| 9.1b | Fehlerbehebung E1: Editor behält Lebensmittel-Verknüpfungen, auch zu weich gelöschten Lebensmitteln (UI-11–UI-15, docs/decisions.md) | fertig |
| 9.2 | Manueller Durchlauf (durch den Projektverantwortlichen) | bestanden mit 4 Befunden, behoben in 9.2a |
| 9.2a | Fehlerbehebung: Schritt-Timer, Vergleichstexte, Master markieren, Mengenrechner (UI-16–UI-28, docs/decisions.md) | fertig — Nachtest durch den Projektverantwortlichen bestätigt („alle 4 Punkte ok“) |
| 9.3 | Technischer Spike (mehrere Drift-Klassen auf einer Sync-DB, `test/spike/`) — Ergebnis: A eingeschränkt, B nicht unterstützt, C unterstützt; Empfehlung C mit geteilter `DatabaseConnection` (docs/decisions.md, „Spike 20.1“) | fertig |

**Beobachtungen für 9.2:**
- Einfrieren einer Version mit gelöschtem Lebensmittel erzeugt einen
  Snapshot ohne Nährwerte für diese Zutat (`per100g: null`), ohne Warnung.
  Spezifikationskonform nach Kapitel 10.7; im manuellen Durchlauf prüfen, ob
  das stört. Im Editor zeigt die Zeile vorher den Hinweis „Verknüpftes
  Lebensmittel wurde gelöscht – bitte neu auswählen.“ (9.1b), beim
  Einfrieren selbst gibt es keinen.

**Bekannte Grenze (spezifikationskonform, nicht behoben):** E2 — beim
Anwenden eines `ReplaceIngredient` geht die Notiz der Zutat verloren
(Kapitel 14.1), siehe docs/decisions.md. Die „Butter → Butter“-Anzeige ist
mit 9.2a erledigt („Butter: anderes Lebensmittel verknüpft“).

**Design-Notizen (für den Design-Pass, nicht Teil 1):**
- Der Editor zeigt live nur die Gesamt-kcal; pro Portion und pro 100 g wären
  hilfreich.
- Hinweis bei doppeltem Lebensmittelnamen (später).
- Ältere Bildschirme färben noch über `Colors.*` (15 Stellen in
  Nährwertkopf, Rezept-Editor, Rezept erstellen, Vergleich, Export, Import,
  Lebensmittel-Editor und Verpackungsformular); neue Stile seit 9.1b/9.2a
  kommen ausschließlich aus `Theme.of(context)`.
- Einheiten erscheinen nur in den Vergleichstexten mit deutschem Namen
  („Stück“, „Prise“); Editor, Rezeptdetail und Vergleichsspalten zeigen
  noch die Codes (`piece`, `pinch`).

## Phase 10 — Freeze (Kapitel 24.7) — abgeschlossen
| Schritt | Beschreibung | Status |
|---|---|---|
| 10.0 | Nachtrag: PopScope im Lebensmittel-Editor (UI-29–UI-32, docs/decisions.md) | fertig |
| 10.1 | Abnahmeliste vollständig abhaken | fertig — Nachweis siehe unten, Befunde B1–B4 erledigt (10.1a/10.1b) |
| 10.1a | Nachtrag: GD-05 nach 23.3, GD-05b, RecipeStep-Tests; B2/B4 dokumentiert (docs/decisions.md) | fertig |
| 10.1b | Nachtrag: SnapshotCodec sortiert Schlüssel nach 13.4 (GD-13, docs/decisions.md) | fertig |
| 10.2 | Öffentliche API dokumentieren — 280 Lücken in der exportierten API geschlossen, `dart doc` 0 Warnungen/0 Fehler (docs/decisions.md) | fertig |
| 10.2a | Nachtrag: AT-05 erzwingt 28.1.3, Kapitelverweise in `///`-Kommentaren korrigiert (docs/decisions.md) | fertig |
| 10.3 | Finaler Release-Check und annotierter Tag `part1-v1.0.0` auf den Release-Check-Commit (nach grüner CI) | fertig |

Kapitel 28 „Nachträge und Klarstellungen zu Teil 1“ ist in `docs/spezifikation.md` übernommen (2026-10-05); es gilt vor Kapitel 1–27 und ist Teil des Freeze von `part1-v1.0.0`.

### Freeze-Nachweis (10.1, abgeschlossen mit dem Release-Check 10.3, Stand 2026-10-05)

Ausgeführt mit Flutter 3.47.5, alle Befehle im jeweiligen Paketordner.
Testergebnisse aus `flutter test --reporter json` (Core und App), IDs gegen
die Testnamen geprüft. Alle 165 IDs aus Kapitel 23.1–23.6 (ohne das bewusst
fehlende DF-11) sind als eigene Tests vorhanden, grün und nicht übersprungen.

| Kriterium (Kapitel 25) | Nachweis | Ergebnis |
|---|---|---|
| Alle Tests grün (Ziel > 140) | `flutter test --reporter json` beim Release-Check: Core 366 Tests, App 1 Test; 0 fehlgeschlagen, 0 übersprungen; alle 165 Plan-IDs aus Kapitel 23 vorhanden | erfüllt (367) |
| AT-01 bis AT-12 grün | `test/architecture/at01_…` bis `at12_…`, je ein Test | erfüllt |
| Kein double in lib/ (AT-07) | AT-07 grün; `grep -rnwE "double\|num" lib` außerhalb `src/ui/`: 0, `.toDouble()`: 0. In `src/ui/` eine Layout-Stelle (`double.infinity`), nach 5.2 zulässig | erfüllt |
| Kein toDecimal außerhalb decimal_math.dart (AT-08) | AT-08 grün; `grep -rn "toDecimal(" lib` außerhalb `decimal_math.dart`: 0 | erfüllt |
| Kein „kJ“ in lib/ und test/ (AT-12) | AT-12 grün; `grep -rn "kJ" lib test` außerhalb `test/architecture/`: 0; Treffer nur im AT-12-Test selbst | erfüllt, Befund B2 |
| Schema-Dump eingecheckt, Migrationstest läuft | `packages/unsalted_core/drift_schemas/drift_schema_v1.json` (in Git); MG-01, MG-02 grün; frischer `dart run drift_dev schema dump` identisch mit dem eingecheckten (ohne `_meta`) | erfüllt |
| GD-01 bis GD-12 grün | `test/contract/golden_test.dart` (GD-01–GD-10), `test/data/snapshot_service_test.dart` (GD-11, GD-12) | erfüllt, Befunde B1, B4 |
| Export → Import → identische Nährwerte (IT-01) | `test/integration/it01_export_import_test.dart` (+ `test/data/snapshot_service_test.dart`) | erfüllt |
| Snapshot-Sperre (RP-03, RP-05) | `test/data/recipe_repository_test.dart` | erfüllt |
| Historische Stabilität (IT-02) | `test/integration/it02_historical_stability_test.dart` (+ `test/data/nutrition_service_test.dart`) | erfüllt |
| Snapshot-Wahrheit (IT-04) | `test/integration/it04_snapshot_truth_test.dart` (+ `test/data/nutrition_service_test.dart`) | erfüllt |
| UI-01 bis UI-10 grün | `test/ui/…`: UI-01/02 recipe_list, UI-03/04 recipe_editor, UI-05/07 nutrition_table, UI-06 amount_calculator, UI-08 version_compare, UI-09 package_form, UI-10 import_screen | erfüllt |
| EX-01 bis EX-05 | `test/ui/recipe_detail/recipe_detail_screen_test.dart` (EX-01, 02, 04, 05), `test/ui/settings/settings_screen_test.dart` (EX-03, EX-05) | erfüllt |
| Öffentliche Tür = Golden-Liste (AT-06) | AT-06 grün gegen `test/architecture/public_api_golden.txt` | erfüllt |
| Öffentliche API dokumentiert, dart doc ohne Warnung | Schritt 10.2: `public_member_api_docs` (vorübergehend) auf die exportierte API gefiltert: 280 → 0 Lücken; `dart doc --dry-run .`: 0 Warnungen, 0 Fehler | erfüllt |
| Spike 20.1 protokolliert | `docs/decisions.md`, „Spike 20.1“ | erfüllt |
| docs/status.md zeigt Phase 0 bis 10 fertig | Phase 0–10 abgeschlossen (diese Datei) | erfüllt |
| Git-Tag `part1-v1.0.0` | annotierter Tag auf den Commit „Schritt 10.3: Release-Check -- Teil 1 abgeschlossen“, gesetzt nach grüner CI für genau diesen Commit; Nachweis `git ls-remote --tags origin` | erfüllt |

**Befunde (nicht stillschweigend gleichgesetzt) — erledigt mit 10.1a/10.1b, Entscheidungen in docs/decisions.md:**
- **B1 — GD-05 prüft schwächer als 23.3.** 23.3 verlangt „Decodieren + erneutes Encodieren ergibt byteweise identisches JSON“. GD-05 kodiert dasselbe dekodierte Objekt zweimal und vergleicht die beiden Ausgaben (nur Determinismus). Der geforderte Sachverhalt wird von GD-01 bis GD-04 geprüft (`jsonEncode(encode(decode(golden))) == jsonEncode(golden)`), zusätzlich von SI-1 für den gespeicherten Export-String. Der Kopfkommentar von `golden_test.dart` beschreibt GD-05 unzutreffend als Vergleich mit dem Original.
- **B2 — AT-12-Ausnahme nicht spezifiziert.** 5.2 und 25 verlangen „kein kJ in lib/ oder test/“ ohne Ausnahme. Der AT-12-Test nimmt `test/architecture/` aus (er muss den Suchbegriff selbst enthalten); diese Ausnahme steht seit Phase 1 nur im Testcode, weder in der Spezifikation noch in `docs/decisions.md`.
- **B3 — Testvertrag 18.1 für `recipe_step.dart` nicht erfüllt.** Laut Dateivertrag deckt `recipe/recipe_ingredient_test.dart` auch `recipe_step.dart` ab; `RecipeStep` wird in `test/recipe/` nirgends getestet (bekannte Lücke seit Schritt 3.1). Indirekt über RP-, UI- und Integrationstests ausgeführt, aber ohne eigenen Unit-Test.
- **B4 — Testorte weichen von 23.3/23.5 ab.** GD-11 und GD-12 liegen in `test/data/` statt `test/contract/`; IT-01 bis IT-05 existieren zusätzlich (aus Schritt 6.5/6.6) in `test/data/`. Inhaltlich korrekt, nur die Zuordnung Datei ↔ Kapitel weicht ab.
- Hinweis, kein Befund: Kapitel 25 nennt AT-07 verkürzt („kein double in lib/“); maßgeblich ist 5.2 mit der Layout-Ausnahme in `src/ui/`.
- Korrigiert (nur Meta-Doku): CLAUDE.md zeigte `drift_schemas/` im Projektstamm; laut Spezifikation (Verzeichnisbaum vor 18.1) und tatsächlich liegt es in `packages/unsalted_core/`.

### Bekannte Grenzen von part1-v1.0.0 (für Teil 1.1 / Design-Pass)

- Kein nativer Teilen-Dialog beim Export und keine Dateiauswahl beim Import (Bildschirm 11/12); nur Zwischenablage bzw. eingefügter Text.
- E2: Beim Anwenden eines `ReplaceIngredient` geht die Notiz der Zutat verloren (spezifikationskonform nach 14.1).
- 15 `Colors.*`-Stellen in 8 UI-Dateien (Nährwertkopf, Rezept-Editor, Rezept erstellen, Vergleich, Export, Import, Lebensmittel-Editor, Verpackungsformular); neue Stile seit 9.1b nur über `Theme.of(context)`.
- Einheiten erscheinen außerhalb der Vergleichstexte als Codes (`piece`, `pinch`, `tbsp` …).
- Kein Löschen von Rezepten oder Lebensmitteln in der UI (`softDeleteRecipe`/`softDeleteVariant` existieren, werden von keinem Bildschirm aufgerufen; nur Versionen sind löschbar). → behoben in Teil 1.1b.
- Einfrieren einer Version mit gelöschtem Lebensmittel erzeugt ohne Warnung einen Snapshot ohne Nährwerte für diese Zutat (spezifikationskonform nach 10.7).
- Der Editor zeigt live nur die Gesamt-kcal; pro Portion und pro 100 g fehlen.
- Kein Hinweis bei doppeltem Lebensmittelnamen.

**Beobachtungen nach 10.2a (nicht blockierend, docs/decisions.md):**
- Zwei Kapitelverweise ohne eindeutige Zuordnung bleiben unverändert: `nutrition_engine.dart:39` (7.4) und `data/tables/recipe_ingredients.dart:26` (10.10).
- Die Kopfkommentare von `data/tables/recipe_ingredients.dart` und `recipe_steps.dart` beschreiben noch das frühere Hart-Löschen statt des Soft-Delete-Deltas aus Kapitel 10.7.

## Teil 1.1 — Fehlerbehebungen (Kapitel 25.2) — abgeschlossen, `part1-v1.1.0`

Änderungen an Teil 1 nach dem Freeze, je mit eigener Arbeitskarte. Der Tag
`part1-v1.0.0` bleibt unverändert; Teil 1.1 ist gesammelt als
`part1-v1.1.0` getaggt.

| Schritt | Beschreibung | Status |
|---|---|---|
| 1.1a | Fehlerbehebung: kein Flackern beim Versionswechsel im Rezeptdetail — alter Inhalt bleibt mit Ladebalken stehen, veraltete Antworten werden verworfen (UI-33, UI-34, docs/decisions.md) | fertig |
| 1.1b | Rezepte und Lebensmittel löschen: Wischen in beiden Listen, Menüpunkt im Rezeptdetail und im Lebensmittel-Editor; 5 s „Rückgängig“ statt Bestätigungsdialog, erst danach Soft-Delete (UI-35–UI-44, docs/decisions.md) | fertig |
| 1.1c | Ladebalken im Rezeptdetail erst nach 300 ms, bei schnellem Laden nie (UI-45, UI-46, docs/decisions.md) | fertig |
| 1.1d | CI-Zeitlimit (`timeout-minutes: 20`) und Test-Hänger nach fehlgeschlagenen Widget-Tests: Ursache in den Testdateien (Drift-Abbestell-Timer in der Fake-Zone), Datenbank-Teardowns räumen jetzt erst den Widget-Baum ab (docs/decisions.md) | fertig |

Stand nach 1.1d: Core 380 Tests, App 1 Test, alle grün; `tool/check_architecture.dart` Exit 0; CI mit Zeitlimit 20 min.

Teil 1.1 ist als annotierter Tag `part1-v1.1.0` auf `25b09d9` getaggt (2026-10-07). Der Design-Pass auf `design/1.1` wird nicht übernommen (Branch bleibt als Referenz); an seine Stelle tritt Teil 1.2.

## Teil 1.2 — Design-System — abgeschlossen, `part1-v1.2.0`, `design-v0.1.0`

Plan, Abschnitte und Antworten F1–F12: `docs/design/plan.md`. Etappen mit Stopp: C01–C13, C14–C27, C28/C27b/C29, dazu C30.

**Abgeschlossen 2026-10-07:** vom Projektverantwortlichen freigegeben; PR #1 (`design-system` → `main`, CI grün auf `fcf89bc`) als Merge-Commit `763fa45` „Teil 1.2: Design-System (C01–C30)“ übernommen (`--no-ff`, Historie C01–C30 erhalten). Annotierte Tags auf `763fa45`: `part1-v1.2.0` („Teil 1.2: Design-System, UI-Konfiguration, deutsche Anzeige“) und `design-v0.1.0` („unsalted_design 0.1.0: neutrales Design-System“). Auf `main` nach dem Merge: Design 212, Core 412, App 6, Widgetbook 6 Tests grün; `check_architecture` Exit 0; `flutter analyze` ohne Befund in allen vier Paketen. Branches `design-system` und `design/1.1` danach gelöscht.

| Schritt | Beschreibung | Status |
|---|---|---|
| C01 | Regeln: `architecture.yaml`, `check_architecture.dart`, Kapitel 28.9 (1–3) | fertig |
| C02 | Gerüst `unsalted_design`, DS-01/03/06, CI | fertig |
| C03 | Tokens, DS-02/04/05 | fertig |
| C04 | Theme, DS-07 | fertig |
| C05 | Layout, DS-10–13 | fertig |
| C06 | Komponenten I: Buttons, Symbole, Text, Flächen, `AppSection`; DS-14–22 | fertig |
| C07 | Komponenten II: Eingaben, Listen, Chips; DS-23–31 | fertig |
| C08 | Komponenten III: Hinweise, Zustände, Meldungen, Dialoge; DS-32–39 | fertig |
| C09 | Komponenten IV: Navigation, Daten; DS-40–45 | fertig |
| C10 | Templates, DS-46–48 | fertig |
| C11 | Widgetbook (macOS), WB-01–03 | fertig |
| C12 | Doku `docs/design/*`, README/CHANGELOG | fertig |
| C13 | Core-Anbindung, AT-13/14/15 mit Übergangsliste (18 Dateien) | fertig |
| C14 | Einstellungen (13) | fertig |
| C15 | Lebensmittel-Liste (9), Meldung in `undoable_deletion.dart` | fertig |
| C16 | Rezeptliste (1), Wischen in `undoable_deletion.dart` | fertig |
| C17 | Rezept erstellen (2) | fertig |
| C18 | Export (11) | fertig |
| C19 | Import (12) | fertig |
| C20 | Versionen (7) | fertig |
| C21 | Versionsvergleich (8) | fertig |
| C22 | Nährwertanzeige, Mengenrechner (5, 6); `AppSurface`-Hinweistöne | fertig |
| C23 | Rezeptdetail (4), UI-58 | fertig |
| C24 | Lebensmittel bearbeiten (10), `PackageForm` | fertig |
| C25 | Rezept-Editor (3), `IngredientRow`, `StepRow`, Auswahldialog | fertig |
| C26 | App-Hülle: Theme hell/dunkel, Navigationsleiste, APP-02 | fertig |
| C27 | Abschluss: Übergangsliste leer (Mechanismus bleibt bis zur Freigabe), Doku auf Ist-Stand | fertig |
| C27c | Übergangsmechanismus entfernt | fertig |
| C28 | Test-Finder auf Design-Typen (116 Zeilen, nur Finder) | fertig |
| C27b | deutsche Einheiten (UI-59–63) | fertig |
| C29 | UI-Konfiguration: `CoreUiOptions`, App-Datei, UC-01–07 | fertig |
| C30 | Dezimalkomma in der ganzen Anzeige (Änderungsliste, Editor-Parameter, Verpackungsformular), UI-64–66 | fertig |

Stand nach C30 (= `part1-v1.2.0`): Design 212 Tests, Core 412, App 6, Widgetbook 6, alle grün; `check_architecture` Exit 0.

Stand nach Etappe 3 (C27c, C28, C27b, C29): Design 212 Tests, Core 409, App 6, Widgetbook 6, alle grün; `check_architecture` Exit 0. 

Stand nach Etappe 2 (C14–C27): Design 212 Tests, Core 387, App 3, Widgetbook 6, alle grün; `check_architecture` Exit 0; Übergangsliste leer.

Stand nach Etappe 1 (C01–C13): Design 208 Tests, Core 386, App 1, Widgetbook 6, alle grün; `tool/check_architecture.dart` Exit 0. Entwurfs-PR `design-system` → `main` steht noch aus (`gh` lokal nicht angemeldet).

### Design-Notizen (für den Design-Pass)

- ~~Ladebalken im Rezeptdetail erst nach ~300 ms Verzögerung zeigen (blitzt bei schnellem Laden kurz auf).~~ → umgesetzt in Teil 1.1c.

## Teil 1.3 — Gestaltung aus Figma — abgeschlossen, `part1-v1.3.0`, `design-v0.2.0`

Branch `design-1.3` von `main` @ `1022185`, PR #2. Plan, Commit-Reihenfolge D01–D18 und Antworten F1–F14: `docs/design/plan-1.3.md`; Entscheidungen: `docs/decisions.md`, „Teil 1.3“; Nachträge: Spezifikation Kapitel 28.10; Abweichungen für Figma: `docs/design/rueckmeldung-figma.md`.

**Abgeschlossen 2026-10-20:** vom Projektverantwortlichen freigegeben (Textauswahlmenü auf dem iPhone nach D17c deutsch bestätigt); PR #2 (`design-1.3` → `main`, CI grün auf `e1808f5`) als Merge-Commit `36b7c41` „Teil 1.3: Gestaltung aus Figma (D01–D18)“ übernommen (`--no-ff`, Historie D01–D18d erhalten). Annotierte Tags auf `36b7c41`: `part1-v1.3.0` („Teil 1.3: Gestaltung aus Figma“) und `design-v0.2.0` („unsalted_design 0.2.0: Design-System aus Figma (Bleistift · Tinte · Marker)“). Auf `main` nach dem Merge: Design 461, Core 448 (zwei volle Läufe nacheinander), App 12, Widgetbook 10 Tests grün; `check_architecture` Exit 0; `flutter analyze` ohne Befund in allen vier Paketen; CI auf `main` grün. Vor dem Neustart des Macs hingen in der Nacht lokal 3 von 4 vollen Core-Läufen (Kandidat f unten); `docs/design/system/README.md` steht auf „freigegeben (design-v0.2.0)“. Branch `design-1.3` danach gelöscht (lokal und remote).

| Schritt | Beschreibung | Status |
|---|---|---|
| — | Aufräumen: `.DS_Store` aus dem Repository, in `.gitignore` (`571da1e`) | fertig |
| — | Design-Übergabe aus Figma nach `docs/design/` (`UEBERGABE.md`, `system/`, `figma/`; `c8bdfe3`) | fertig |
| — | Figma-Abgleich Variablen ↔ `tokens.json` (nur gelesen): 158 Werte gleich, Abweichungen A1–A4 im Plan | fertig |
| — | Plan `docs/design/plan-1.3.md` | fertig, freigegeben 2026-10-17 (F1–F14) |
| D01 | Golden-Grundlage und Grundstand: `goldens.yml` (Hilfsbranch `goldens/**`), `ci.yml` auf `ubuntu-24.04`, GL-01 (13 Motive, 104 Bilder), GL-02 (5 Bildschirme, 40 Bilder); Prüflauf 0 Abweichungen, Gegenprobe 24 | fertig |
| D02 | Schrift und Lizenz: Atkinson Hyperlegible Next als TTF (392 Glyphen, Version 2.001) mit OFL im Design-Paket, `AppFonts`, Lizenz in der App registriert; DS-49 (Glyphen), DS-50 (Lizenz) | fertig |
| D03 | Token-Datei und Generator (`tool/generate_tokens.dart`, alle Token-Dateien generiert), Theme-Zuordnung nach 01/02, Schrift Atkinson im Theme; DS-04/05/07 neu gefasst, DS-51 mit Übergangsliste (8 Dateien); Kapitel 28.10 (Punkte 1, 12, 13) | fertig |
| D04 | Komponenten-Themes aus Tokens (`component_themes.dart`): Buttons, Marker-Knopf, Symbol-Schaltfläche, Eingabe, Chips, Liste, Trenner, Meldung, Dialog, Menü, Karte, Laden, Kopfleiste, Navigation, Tooltip; DS-52; Kapitel 28.10.2 | fertig |
| D05a | Symbol-Finder in Tests auf `AppIcons` (11 Zeilen in 4 Dateien, nur der Symbolname) | fertig |
| D05b | Symbole Outlined, alle 32 Namen der Figma-Bibliothek (11 neu); DS-17 gegen `figma-ids.json` | fertig |
| D06 | Komponenten I: Marker-Knopf (Ladekreis aus Tokens), Tag, Text-Stile, Abschnitt mit Abschnittslinie | fertig |
| D07 | Markenelemente: `AppMark` (auch als Auswahlziel), `AppFrame`/`AppSlot`/`AppDashedUnderline`, `AppHighlight`/`AppChangeText`, `AppValue`; DS-53–58; GL-01-Motiv „marken“ | fertig |
| D08 | Eingaben und Listen: Beschriftung über dem Feld, Zahl mit Einheit, Fehler mit Symbol, Auswahlfeld mit `chevron`, Listeneintrag mit Haarlinie und Auswahlbalken; Kontur des Tags behoben | fertig |
| D09 | Rückmeldung: Hinweis mit Symbol (neutral/Warnung/Fehler/Erfolg), Leerstelle, Fehlerzustand mit Symbol, Dialog `size-dialog` mit primärem Verb, Symbolgrößen aus Tokens; Restzeitlinie der Meldung nachgeholt in D09b | fertig |
| D10 | Navigation und Daten: eigene Navigationsleiste (Balken statt Pille, Seitenleiste ab 600 über `AppPage.navigation`), Kopfleiste und Navigation ohne Textskalierung, Aktionsleiste, Deklarationstabelle, Codeblock; DS-59; DS-51-Liste leer | fertig |
| D11 | Templates und Layout: Rahmen „Inhalt“ (Seitenrand ab 600, höchstens 720, mittig), Listen ohne Rand, Detail zweispaltig ab 1200, `DetailSplit` oben scrollend (Überlauf Versionsvergleich behoben); DS-60 | fertig |
| D12a | Token-Nachtrag `reflow` aus Figma: acht Maße mit Werten für 100/200 % in beiden Token-Dateien, Generator liest beide Formen, Figma-Abgleich gleich | fertig |
| D12 | Große Schrift: Werte je Textgröße (`AppReflowMetric`, linear 100–200 %), Deklaration bricht um, Aktionsleiste untereinander, Textgrößen-Addon im Katalog, WB-04; DS-51-Übergangsliste und Mechanismus entfernt | fertig |
| D09b | Restzeitlinie der Meldung mit Aktion (`stroke-rule` in `action-inverse`, läuft ab dem Erscheinen in der Frist ab, bei „Bewegung reduzieren“ still); Inhalt der Meldung nach Snackbar-Karte, bei großer Schrift Aktion unter dem Text; drei Core-Test-Helfer mit festen Pumps (freigegeben); DS-38b | fertig |
| D13a | Bedienhilfe und große Schrift in Komponenten: Tippaktion in der Semantik von Marke (Ziel) und Navigationsziel (Fehler aus D07/D10), Text in der Marke bricht um, Hinweis-Aktion unter dem Text (Entscheidung 4, `ReflowRow`); DS-53b, DS-59b, DS-32c | fertig |
| D13 | Fassungsmarke (`VersionMark`), Fassungsleiste (Marken mit Auswahlbalken, Umbruch statt Abschneiden), Versionseintrag mit Marke, Zustand als Wort und „Master“ statt Stern; UI-67/68 | fertig |
| D14 | Änderungsliste in Abschnitten, je Änderung `AppChangeText` (alt durchgestrichen, Pfeil-Symbol, neu markiert), Semantik = bisheriger Text; Versionsvergleich bei großer Schrift A über B; UI-69, UI-75 | fertig |
| D15a | Kennzahlenleiste als fachneutrale Design-Komponente `AppFigureRow` (Haarlinien, Einzug, bei großer Schrift untereinander; freigegeben); DS-61, Katalog, GL-01 `daten` | fertig |
| D15 | Nährwerte: Kopf als Kennzahlenleiste, Hinweis als Warnung, Deklaration („davon“ eingerückt, kcal hervorgehoben), Mengenrechner mit Einheit und Tausch-Symbol, bei großer Schrift untereinander; UI-70/71 | fertig |
| D16 | Editor und Lebensmittel: Zutatenzeile zweizeilig mit gestrichelter Unterstreichung, Schrittzeile mit Nummer (freigegeben) und Timer darunter, Zustandsrahmen der eingefrorenen Ansicht, Hinweise im Verpackungsformular, Nährwertfelder zweispaltig (Testzeilen freigegeben), Schritte im Detail mit Nummer und Timer-Tag, „Keine Treffer.“ ohne Leerstelle, schmales Feld und Auswahl bei großer Schrift; UI-72–74, UI-76, DS-23c, DS-25c | fertig |
| — | Nachträge aus Etappe 3: Kandidaten für Teil 1.4 festgehalten, Kommentare im Detail-Test (`7296aff`) | fertig |
| D16b | Abstand `space-m` zwischen den Feldern im Editor-Abschnitt „Parameter“ (freigegeben); UI-77 | fertig |
| D16c | Nährwertfelder im Verpackungsformular als Zahlenfelder (Tastatur mit Komma, rechtsbündig, tnum; freigegeben); UI-78 | fertig |
| D17 | App-Hülle: Hauptnavigation über `AppPage.navigation` — unter 600 unten, ab 600 seitliche Leiste links (F4); APP-04 | fertig |
| D17b | Deutsche Systemtexte: `flutter_localizations` aus dem SDK, Delegates und `Locale('de')` in der App (F2); APP-03 | fertig |
| D18 | Abschluss: `design_system.md` (Weg der Werte, DS-07 neu), `components.md` (Figma-IDs), `screens.md` (Figma-Abgleich je Bildschirm), neu `rueckmeldung-figma.md` (bewusste Abweichungen), README/CHANGELOG und Version 0.2.0 des Design-Pakets, Kapitel 28.10 vollständig; kein Merge, keine Tags | fertig |
| D18b | Nach Prüfung Etappe 4 (freigegeben): Abstand `space-m` zwischen Titel und Beschreibung (Bildschirm 2); Maßfelder des Verpackungsformulars und Editor-Parameter als Zahlenfelder (Portionen ohne Komma); UI-79/80 | fertig |
| D17c | Befund iPhone-Test: Deutsch als Sprache des App-Bundles (`CFBundleDevelopmentRegion` „de“, `CFBundleLocalizations` mit „de“ in iOS und macOS), damit „Kopieren“/„Ausschneiden“ der Textauswahl deutsch sind; APP-05 | fertig |
| D18c | Abstand `space-m` zwischen den Maßfeldern im Verpackungsformular (wie D16b); UI-81 | fertig |
| D18d | Letzter Abstand-Durchgang (nach Freigabe von Teil 1.3): `space-m` in Kennung (Name, Marke, Barcode), Export-Auswahl und Schrittzeile (Anweisung → Timer); Zutatenzeile und Mengenrechner bleiben wie Figma (entschieden); UI-82 | fertig |
| — | Status des Design-Systems „freigegeben (design-v0.2.0)“ (`e1808f5`, F14) | fertig |
| — | Merge `36b7c41`, Tags `part1-v1.3.0` und `design-v0.2.0` | fertig |

Stand nach D18d (= `part1-v1.3.0`): Design 461 Tests, Core 448, App 12, Widgetbook 10, alle grün; `check_architecture` Exit 0.

**Kandidaten für Teil 1.4** (eingeordnet 2026-10-18, ergänzt 2026-10-20;
Details der ersten Gruppe in `docs/design/plan-1.3.md`, „Nicht Teil von 1.3“):

- **f) Hohe Priorität:** Hänger in Core-Widget-Tests mit Datenbank
  untersuchen (lokal 3 von 4 Läufen am 20.10., Vermerk C29, CI-Zeitgrenze
  aus 1.1d).
- a) Zutaten- und Schrittzeile: „⋯“-Menü mit „Nach oben“, „Nach unten“,
  „Entfernen“ statt Papierkorb (löst auch Umsortieren ohne Ziehen, WCAG 2.5.7).
- b) Master auch in der Fassungsleiste markieren.
- c) Entscheidung offen: Rezepttexte markierbar/kopierbar machen?
- d) Entscheidung offen: Rezept löschen – Rückgängig beibehalten (Empfehlung)
  oder anders?
- e) App-Name auf dem Gerät vereinheitlichen (heute „Unsalted App“ bzw.
  „unsalted_app“).
- Aus 2026-10-18: „leer“ und „keine Treffer“ in der Lebensmittelliste
  unterscheiden; Liste und Detail nebeneinander ab 840 (F4). (Master in der
  Fassungsleiste = b; sichtbares Umsortieren ohne Ziehen = a.)

## Teil 1.4 — Stabilität, Bedienung, Tablet, Marke — Plan zur Freigabe

Branch `teil-1.4` von `main` @ `ce6431f`, Entwurfs-PR #3. Plan: `docs/plan-1.4.md` (Etappen 1 Stabilität, 2 Bedienung, 3 Tablet, 4 Marke; Fragen F1–F13 mit Antworten; Figma-Nachträge N1–N6), freigegeben 2026-10-20.

| Schritt | Beschreibung | Status |
|---|---|---|
| — | Plan `docs/plan-1.4.md` | fertig, freigegeben 2026-10-20 |
| S01a | Diagnosewerkzeug `tool/repeat_tests.dart`; Matrix D1–D4: 2 Hänger in 60 Läufen, beide mit `--concurrency=1` in `recipe_detail_screen_test.dart`; `testWidgets` ignoriert `--timeout`/`dart_test.yaml` | fertig |
| S01b | D5 (instrumentiert, 60 Läufe): kein Hänger; Ursache lokal nicht nachgestellt; Nachtrag zum Plan mit endgültigen Testzeilen für S02 (zur Freigabe) | fertig |
| S02 | Robustes Schließen der Datenbank in Widget-Tests (`closeTestDatabase`, Core und App), Zeitlimit 2 min je Widget-Test über `flutter_test_config.dart`; UI-83 | fertig |
| S03 | Abnahme: Core 20 × Standard, 10 × unter Last, 30 × `--concurrency=1` (je 451 Tests), App 10 × (12 Tests) — 70 Läufe, alle grün, kein Hänger | fertig |

Stand nach S03 (Etappe 1 fertig): Design 461 Tests, Core 451, App 12, Widgetbook 10, alle grün; `check_architecture` Exit 0.
| — | Figma-Nachträge N1–N6 übernommen (`docs/design/figma/teil-1.4-figma-nachtraege.md`, `figma-ids.json`) | fertig |
| B01 | Zeilenmenü „⋮“ in Zutaten- und Schrittzeile (Nach oben/unten, Entfernen) nach Figma N1, Einheit beschriftet, `space-m`, Haarlinie, Unterstreichung `space-xxs` darunter; DS-62/64/65, UI-84–86 | fertig |
| B02 | Master in der Fassungsleiste (Markerfläche, Semantik), `masterVersionId` aus dem Rezeptdetail; UI-87 | fertig |
| B03 | „Keine Treffer.“ in der Lebensmittelliste mit Suchbegriff (Symbol, ohne Aktion, ohne Leerstelle) nach Figma N2; UI-88 | fertig |
| B04 | Suchtreffer im Titel der Rezeptliste markiert (`AppListItem.match`, Klartext unverändert); DS-66, UI-89 | fertig |
| B05a | Token-Nachtrag Textauswahl aus Figma N6 (`selection`, `selection-handle`, `opacity-selection`) in beiden Token-Dateien | fertig |
| B05 | Markierbare Rezepttexte im Rezeptdetail (`AppSelectableArea`), Textauswahl im Theme aus `selection`/`selection-handle`; DS-67, UI-90 | fertig |

Stand nach Etappe 2: Design 491 Tests, Core 461, App 12, Widgetbook 10, alle grün; `check_architecture` Exit 0.
| T00a | Listeneintrag bricht bei großer Schrift um (Aktionen unter Titel und Untertitel, Figma `List/Item`, Hinweis 4); DS-68, UI-93 | fertig |
| T00b | Suffix im Eingabefeld bündig am Feldende, Wert endet `space-m` davor (Lupe „Lebensmittel verknüpfen“); DS-69, UI-94 | fertig |
| T01–T03 | Etappe 3: Liste und Detail ab 840 | in Arbeit |
| M01–M03 | Etappe 4: App-Name, ggf. App-Symbol und Startbild, Abschluss | offen |

## Bekannte offene Lücken (nicht blockierend)

- `foodVariantToInsertCompanion`/`foodVariantToUpdateCompanion` in
  `food_mapper.dart` sind seit Schritt 6.4 toter Code (0 Aufrufer) —
  `drift_food_repository.dart` baut die Zeile stattdessen selbst
  (`_toRow`), weil `FoodDao.insertVariant`/`updateVariant` einen vollen
  `FoodVariantRow` statt eines Companions erwarten. `drift_snapshot_service.dart`
  hat aus demselben Grund eine eigene, fast identische `_toFoodRow`-Kopie
  (für neu angelegte Import-Varianten, Kapitel 13.6). `recipeVersionToSnapshotCompanion`
  in `version_mapper.dart` ist ebenfalls toter Code (0 Aufrufer) —
  `drift_snapshot_service.dart` baut die volle Insert-Companion für eine
  direkt als Snapshot angelegte Version selbst, weil keine Mapper-Funktion
  Basis- und Snapshot-Felder gleichzeitig setzt. Aufräumen (Funktionen
  entfernen oder Mapper korrigieren und Repository/Service umstellen),
  sobald eine Arbeitskarte `data/mappers/*.dart` in ihrem Dateiscope
  erlaubt.
- `export_screen.dart` (Schritt 8.7) hat keinen nativen Teilen-Dialog
  (nur "In Zwischenablage kopieren"), `import_screen.dart` keine
  Datei-Auswahl (nur Text einfügen) — beides bräuchte ein zusätzliches
  Paket (`share_plus`/`file_picker`) und damit eine pubspec.yaml-Änderung,
  die außerhalb des Dateiscopes von Schritt 8.7 lag (nur
  `lib/src/ui/settings/*`). Nachholen, sobald ein Schritt pubspec.yaml
  ändern darf.
- Zwei kosmetische Analyzer-`info`-Hinweise akzeptiert, bewusst nicht
  behoben: `use_super_parameters` in `core_database.dart`.

## Umgestellte Grundlage

Ab dem konsolidierten Bericht (`docs/spezifikation.md`) gilt dieser als
alleinige Spezifikation. Die DAO-Schicht aus Schritt 5.5 wurde entsprechend
Kapitel 16.8 umgebaut: `recipe_dao.dart`/`food_dao.dart` sind jetzt
abstrakte Interfaces, `drift_recipe_dao.dart`/`drift_food_dao.dart` die
konkreten Implementierungen (vorher: eine einzige konkrete Klasse je DAO).