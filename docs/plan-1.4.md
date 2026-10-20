# Teil 1.4 – Stabilität, Bedienung, Tablet, Marke: Plan

Phase A · Stand 2026-10-20 · Branch `teil-1.4` (von `main` @ `ce6431f`) ·
Entwurfs-PR nach `main` · **Entwurf zur Freigabe** — offene Fragen F1–F13 in
Abschnitt (g)

Phase B läuft Commit für Commit nach Abschnitt (e), in vier Etappen mit
Stopp. Reihenfolge der Etappen = Priorität. Kein Code vor der Freigabe dieses
Plans.

Grundlage: `docs/status.md` (Kandidaten a–f), `docs/decisions.md` („Teil
1.3“, „Abschluss Teil 1.3“), `docs/design/plan-1.3.md` („Nicht Teil von
1.3“), `docs/design/rueckmeldung-figma.md`, `docs/design/screens.md`,
Spezifikation Kapitel 22, 25, 28; Figma-Bibliothek `5er28Cr7EMMcPzvusWjNyR`,
App-Datei `5eFqwnCRld6Ibu131541i8` (`docs/design/figma/figma-ids.json`), nur
gelesen.

---

## 0 Ziel und Leitplanken

- **Ziel:** (1) Die Core-Widget-Tests mit Datenbank laufen zuverlässig durch
  — Ursache der Hänger vom 20.10. finden und beheben. (2) Bedienung: Zeilen im
  Editor ohne Ziehen umsortieren und entfernen (WCAG 2.5.7), Master in der
  Fassungsleiste, „leer“ und „keine Treffer“ in der Lebensmittelliste
  getrennt. (3) Tablet: Liste und Detail nebeneinander ab 840. (4) Marke: ein
  App-Name auf allen Plattformen; App-Symbol und Startbild nur mit Dateien aus
  Figma.
- **Bildschirm-Dateien dürfen ab 1.4 geändert werden** — aber nur die in (c)
  benannten, je mit Commit: `recipe_list/recipe_list_screen.dart`,
  `recipe_detail/recipe_detail_screen.dart`, `foods/food_list_screen.dart`,
  `foods/food_editor_screen.dart`. Alle übrigen Bildschirm-Dateien bleiben
  unverändert (`recipe_create_screen.dart`, `recipe_editor_screen.dart`,
  `version_list_screen.dart`, `version_compare_screen.dart`,
  `settings_screen.dart`, `export_screen.dart`, `import_screen.dart`).
- **Core-Logik unberührt.** `contracts/`, `data/`, `recipe/`, `nutrition/`,
  `food/`, `providers/`, Schema, Snapshot-Format bleiben. Die **Core-Tür**
  (`lib/unsalted_core.dart`, AT-06-Golden) bleibt unverändert; geplant ist
  keine Erweiterung (höchstens additiv nach 25.2 und nur mit Freigabe).
  **`module/` (Routen) bleibt unverändert:** Liste und Detail nebeneinander
  entsteht über einen Auswahlzustand im Bildschirm, nicht über neue Routen
  (F8). Müsste `module/` doch geändert werden → Stopp, Begründung, Nachtrag in
  Kapitel 28.
- **Aussehen weiter nur aus dem Design-Paket** (AT-13, AT-14, AT-15, DS-51).
  Neue Gestaltung entsteht in `packages/unsalted_design`, Werte nur aus der
  Token-Datei. **Was Figma nicht zeigt, ist als Vorbedingung
  „Figma-Nachtrag“ markiert** (Liste N1–N6 im Figma-Abgleich) und wird nicht
  selbst gestaltet; der betroffene Commit wartet auf den Nachtrag oder auf
  die Antwort zur jeweiligen Frage.
- **Alle bestehenden Tests bleiben grün.** Jede Testzeile, die sich ändern
  muss, steht einzeln in (d2) mit Commit und Grund. Ungeplante Änderungen an
  bestehenden Testzeilen → Stopp und fragen. Für Etappe 1 kennt erst die
  Diagnose die genauen Zeilen; (d2) nennt sie deshalb vorläufig, die
  endgültige Liste kommt als Nachtrag zu diesem Plan nach S01 zur Freigabe.
- **Sichtbare Abweichungen von Kapitel 22** bekommen je einen Nachtrag im
  neuen Kapitel **28.11** (Liste in (d5)).
- **Goldens wie in 1.3:** nur unter Linux (`goldens.yml`), Bilder über
  Hilfsbranches `goldens/<commit>`, jedes geänderte Bild angesehen, per
  `--amend` in den Commit, Hilfsbranch danach gelöscht (`plan-1.3.md`, d4).
- **Keine KI- oder Assistenten-Themen** (Teil 6) — erst auf ausdrückliche
  Anweisung.
- Tags (`part1-v1.0.0` … `part1-v1.3.0`, `design-v0.1.0`, `design-v0.2.0`)
  bleiben unberührt; neue Tags nur nach Freigabe (F11).

---

## Figma-Abgleich (nur gelesen, 2026-10-20)

| Thema | Figma | Folge |
|---|---|---|
| Liste und Detail (Tablet hoch, Handy quer, Tablet quer) | `147:9746` (01+04), `147:9823` (09+10), dazu dunkel `159:7039`/`159:7338`, Schrift 200 `159:8176`/`159:8475`, quer `148:3817`/`148:3938`/`148:4381`/`148:4840` | Aufbau: `Navigation Rail` 96 · Liste 360 (`size-list-pane`, eigene Kopfleiste mit Suche, Marker-Knopf im Listenbereich) · Detail füllt den Rest (eigene Kopfleiste, beim Lebensmittel eigener Marker-Knopf „Speichern“). Gewählter Eintrag mit Auswahlbalken links (`List/Item`, `selected`, „im Liste-Detail-Layout“). Gezeigt ist nur der Zustand **mit** Auswahl → N3 |
| Fassungsleiste mit Master | `Core/Version Switcher` (`142:19`), Detail `1:607`, `59:3577` | Master mit Markerfläche in der Leiste ist gestaltet (rueckmeldung-figma B) — kein Nachtrag |
| Zeilen im Editor | `Core/Ingredient Row` (`141:4`) und `Core/Step Row` (`141:10`) sind Anzeigezeilen ohne Aktionen; der Editor `7:895` zeigt `Icon/close` | kein Zeilenmenü in Figma → N1 |
| Menü | `Navigation/Overflow Menu` (`150:168`, bis 5 Einträge), `Navigation/Menu Item` (`150:166`), `Icon/more` (`137:6`, im Code `more_vert` = „⋮“) | Komponenten vorhanden; ein waagerechtes „⋯“ gibt es nicht (F4) |
| Lebensmittelliste | Zustände `Liste` `20:1130`, `Leer` `24:1776` („Keine Lebensmittel gefunden.“ + „Eigenes Produkt anlegen“), `Fehler` `24:1829`, `Laden` `46:2535`, `Wischen` `64:4395` | **kein** Zustand „Keine Treffer“ → N2 (Vorbild: `01 Rezeptliste / Keine Treffer` `31:1845`, „Keine Treffer.“ ohne Leerstelle) |
| Suchtreffer in der Rezeptliste | `List/Item` mit `showMatch` (Highlight im Titel), Liste `1:421`, Tablet `147:9746` | gestaltet — kein Nachtrag (B04, F5) |
| App-Symbol, Startbild | keine Seite und keine Datei; `system/03-markenelemente.md` gibt nur Vorgaben (Papier oder Tinte, ein Markerelement, lesbar bei 29 × 29 pt), `README.md` nennt das Punktraster „im Startbild“ | → N4, N5 |
| Textauswahl (Markieren, Kopieren) | keine Auswahlfarbe, keine Griffe in Figma; das Theme setzt keine `textSelectionTheme` (Material-Standard) | nur bei F1 = ja → N6 |

**Figma-Nachträge (Vorbedingungen):**

| Nr | Was Figma liefern soll | für |
|---|---|---|
| N1 | Editor-Zeilen (Zutat, Schritt) mit Zeilenmenü: `Icon/more` + `Navigation/Overflow Menu` mit „Nach oben“, „Nach unten“, „Entfernen“ (erster bzw. letzter Eintrag ausgegraut) statt `Icon/close` | B01 (F4) |
| N2 | `09 Lebensmittel-Liste / Keine Treffer` (wie `31:1845`) | B03 (F4: Vorbild genügt?) |
| N3 | Liste und Detail **ohne Auswahl** (01+04, 09+10; Tablet hoch/quer, Handy quer): Detailbereich leer — Gestaltung und Satz; dazu „Neues Lebensmittel“ im Detailbereich | T02, T03 (F7) |
| N4 | App-Symbol: Master 1024 × 1024 ohne Transparenz (iOS, macOS), Android adaptiv (Vorder- und Hintergrund) | M02 (F10) |
| N5 | Startbild (Punktraster laut Markenbuch), hell und dunkel | M02 (F10) |
| N6 | Textauswahl: Farbe der Markierung, Griffe | B05, nur bei F1 = ja |

---

## (a) Ordnerbaum

`NEU` = neue Datei, `ÄNDERN` = bestehende Datei. Commit in Klammern.

```text
unsalted/
├─ tool/
│  └─ repeat_tests.dart                  NEU     Wiederholungsläufe mit Zeitlimit, Last, Parallelität (S01)
├─ docs/
│  ├─ plan-1.4.md                        dieses Dokument (Nachtrag nach S01: Testzeilen für S02)
│  ├─ spezifikation.md                   ÄNDERN  Kapitel 28.11 (ab S02, vollständig mit M03)
│  ├─ status.md, decisions.md            ÄNDERN  je Commit
│  └─ design/
│     ├─ screens.md, components.md       ÄNDERN  (M03)
│     └─ rueckmeldung-figma.md           ÄNDERN  A2 (Entfernen) mit B01, B-Liste je Commit (M03)
├─ packages/unsalted_design/
│  ├─ pubspec.yaml, CHANGELOG.md, README.md   ÄNDERN  Version 0.3.0 (M03, F11)
│  ├─ lib/unsalted_design.dart           ÄNDERN  Tür: Liste-Detail-Rahmen (T01), ggf. Auswahlbereich (B05)
│  ├─ lib/src/components/navigation/app_overflow_menu.dart   ÄNDERN  additiv `tooltip` (B01)
│  ├─ lib/src/templates/list_detail_template.dart            NEU     Liste und Detail ab `breakpoint-expanded` (T01)
│  └─ test/…                             NEU     DS-62 (B01), DS-63 (T01); public_api_golden.txt (T01)
├─ packages/unsalted_core/
│  ├─ dart_test.yaml                     ÄNDERN  Zeitlimit je Test (S02, F12)
│  ├─ lib/src/ui/                        ÄNDERN  nur die Dateien aus (c)
│  └─ test/
│     ├─ ui/support/db_widget_harness.dart   NEU  gemeinsamer Helfer: Datenbank öffnen, auf Daten warten, schließen (S02)
│     ├─ ui/**/…_test.dart               ÄNDERN  nur die Zeilen aus (d2)
│     └─ goldens/…                       ÄNDERN  Bilder (B01, B02, T02), neues Motiv (T02)
└─ apps/
   ├─ unsalted_app/
   │  ├─ ios/Runner/Info.plist           ÄNDERN  sichtbarer Name (M01)
   │  ├─ macos/Runner/Info.plist         ÄNDERN  sichtbarer Name (M01)
   │  ├─ android/app/src/main/AndroidManifest.xml   ÄNDERN  `android:label` (M01)
   │  ├─ ios/…/Assets.xcassets, android/…/res/, macos/…/Assets.xcassets   ÄNDERN  nur mit N4/N5 (M02)
   │  └─ test/                           ÄNDERN  Teardown wie Core (S02, F13); NEU app_name_test.dart APP-06 (M01)
   └─ unsalted_widgetbook/lib/catalog/   ÄNDERN  Menü mit Tooltip (B01), Liste-Detail-Rahmen (T01)
```

---

## (b) Etappe 1 — Stabilität: Befund, Vermutungen, Diagnose

**Befund (decisions.md, „Abschluss Teil 1.3“, und C29).** In der Nacht zum
20.10. hingen lokal 3 von 4 vollen Core-Läufen auf `main`, jedes Mal in
anderen Widget-Tests mit Datenbank: UI-44 (`food_list_screen_test.dart`),
UC-04 (`core_ui_options_screens_test.dart`), „Versionsauswahl zeigt nur
eingefrorene Versionen …“ (`export_screen_test.dart`) und ein Test in
`recipe_editor_screen_test.dart`. Jeweils `TimeoutException after
0:10:00` (Standardgrenze je Widget-Test) mit Stapel in
`dart:isolate _RawReceivePort._handleMessage`; `flutter_tester` bei 0 % CPU.
Die Dateien einzeln grün (5 s, 8 s), ein voller Lauf grün in 22 s, CI unter
Linux grün; nach dem Neustart des Macs zwei volle Läufe grün. In C29 (Teil
1.2) blieb ein Lauf einmal mit zwei untätigen `flutter_tester` stehen.

**Bestand der Tests.** 15 Dateien unter `test/ui/` öffnen eine
`NativeDatabase.memory()` (88 Widget-Tests). 12 davon tragen je eine Kopie
der Helfer `_openDatabase`/`_disposeWidgetTree`/`_closeDatabase` aus 1.1d, 3
schließen inline auf dieselbe Weise. Auf Daten wartet jede Datei mit festen
Zeiten: 20 Stellen `tester.runAsync(() => Future<void>.delayed(…))` mit 50,
100, 150 oder 200 ms. Die App-Tests (5 Dateien) schließen noch mit dem alten
Muster `addTearDown(() => tester.runAsync(database.close))`.

**Vermutungen (zu prüfen, nicht entschieden).**

| Nr | Vermutung | Prüfung |
|---|---|---|
| H1 | Wie in 1.1d wartet `database.close()` auf einen Abbestell-Timer von Drift, der in der Fake-Zone liegt; ein einziges `pump(Duration.zero)` reicht nicht, wenn beim Abbau noch eine Abfrage läuft und danach einen weiteren Timer plant (zeitabhängig) | Instrumentierung des Teardowns (Zeitstempel vor/nach Abbau, `streamQueries.close`, `executor.close`) in einer Kopie, nicht committet; Gegenprobe mit wiederholtem Auspumpen |
| H2 | Feste Wartezeiten (50–200 ms) sind unter Last zu kurz; der Test läuft weiter, bevor die erste Emission da ist, und ein danach geplanter Timer bleibt in der Fake-Zone stehen | Läufe unter künstlicher Last; feste Wartezeit vorübergehend auf 0 ms → reproduziert? |
| H3 | Parallele Testprozesse (Standard: mehrere `flutter_tester`) verschärfen H1/H2 | Läufe mit `--concurrency=1` gegen Standard |
| H4 | Zustand der Maschine (Ruhezustand, Timer-Bündelung, Restprozesse) | Läufe nach Neustart vs. lange Laufzeit; Restprozesse vor jedem Lauf prüfen |

**Diagnose (S01).** Neues Werkzeug `tool/repeat_tests.dart` (nur `dart:io`):
`--package`, `--runs N`, `--concurrency N`, `--timeout <Dauer>` (an `flutter
test` weitergereicht, damit ein Hänger nach Sekunden statt 10 min mit Namen
endet), `--max-minutes M` je Lauf (danach Prozess **und alle
`flutter_tester`-Kinder** beenden — 1.1d: `perl alarm` ließ Waisen),
`--load K` (K Belastungsprozesse für die Laufzeit), `--randomize`
(`--test-randomize-ordering-seed random`); Ausgabe je Lauf: Dauer, Ergebnis,
rote und hängende Tests; Protokolle im Scratchpad. Matrix: D1 20 × Standard,
D2 20 × `--concurrency=1`, D3 10 × Standard unter Last, D4 10 × zufällige
Reihenfolge; bei einem Treffer D5 die betroffene Datei 50 × mit Instrumentierung.
Ergebnis in `decisions.md`; danach **Stopp** mit Bericht und der endgültigen
Liste der Testzeilen für S02 (Nachtrag zu (d2)).

**Behebung (S02), Richtung je nach Diagnose.** Ein gemeinsamer Helfer
`test/ui/support/db_widget_harness.dart` ersetzt die 12 Kopien und die 3
Inline-Teardowns: `openTestDatabase`, `closeTestDatabase` (Baum abbauen, so
lange auspumpen, bis Drift keine Timer mehr plant, dann schließen — mit
eigener Grenze und klarer Fehlermeldung statt Hänger) und `pumpUntil`
(wartet auf eine Bedingung, z. B. „Eintrag sichtbar“, in kleinen echten
Schritten mit Obergrenze) statt fester Wartezeiten. Keine Erwartung
(`expect`) ändert sich, kein Test wird übersprungen, keine Wartezeit wird nur
verlängert. `dart_test.yaml` bekommt ein Zeitlimit je Test (F12), damit ein
künftiger Hänger nach kurzer Zeit mit Namen rot wird statt nach 10 min. Wenn
die Ursache deterministisch nachstellbar ist: Regressionstest UI-83, der
ohne den Fix hängt bzw. rot wird. App-Tests nach F13.

---

## (c) Bildschirme, Bausteine, Abschnitte

Pfade relativ zu `packages/unsalted_core/lib/src/ui/`, Design relativ zu
`packages/unsalted_design/lib/src/`. Keys, Texte nach Kapitel 22 und Logik
bleiben, sofern nicht ausdrücklich genannt.

| Commit | Datei | Änderung | Bildschirm |
|---|---|---|---|
| B01 | Design `components/navigation/app_overflow_menu.dart` | additiv `tooltip` (Semantik des Menüknopfs); Standard wie heute | — |
| B01 | `recipe_editor/ingredient_row.dart` | Zeilenmenü (`AppOverflowMenu`: „Nach oben“, „Nach unten“, „Entfernen“) statt `AppIconButton` mit Papierkorb; neue optionale Callbacks `onMoveUp`/`onMoveDown` (`null` = ausgegraut); schreibgeschützt ohne Menü; Ziehgriff bleibt | 3 |
| B01 | `recipe_editor/step_row.dart` | dto. | 3 |
| B01 | `recipe_editor/sections/recipe_editor_ingredients_section.dart`, `…/recipe_editor_steps_section.dart` | „Nach oben/unten“ als `onReorder(i, i − 1)` bzw. `onReorder(i, i + 1)` (gleiche Semantik wie Ziehen); Bildschirm unverändert | 3 |
| B02 | `recipe_detail/version_switcher.dart` | additiv `masterVersionId`; die Master-Marke mit `isMaster: true` (Markerfläche, Semantik „…, Master“) | 4 |
| B02 | `recipe_detail/recipe_detail_screen.dart` | übergibt `recipe.masterVersionId` an die Fassungsleiste | 4 |
| B03 | `foods/food_list_screen.dart` | übergibt, ob gesucht wird (`_query.trim().isNotEmpty`) | 9 |
| B03 | `foods/sections/food_list_empty_section.dart` | mit Suche: „Keine Treffer.“ ohne Leerstelle und ohne Aktion (wie Bildschirm 1); ohne Suche unverändert | 9 |
| B04 (F5) | `recipe_list/recipe_list_screen.dart`, `recipe_list/sections/recipe_list_results_section.dart`, `recipe_list/recipe_card.dart` | Suchbegriff an die Karte; der Treffer im Titel als `AppHighlight` (Figma `List/Item` `showMatch`); Semantik = Titel | 1 |
| B05 (F1) | Design: neuer Auswahlbereich (Name nach F1); `recipe_detail/sections/recipe_detail_description_section.dart`, `…_ingredients_section.dart`, `…_steps_section.dart` | Texte markierbar und kopierbar; Farbe aus Tokens nach N6 | 4 |
| T01 | Design `templates/list_detail_template.dart` (NEU), `layout/responsive.dart` | ab `breakpoint-expanded` (840, Fensterbreite wie Material) Liste in `size-list-pane`, Haarlinie, Detail füllt den Rest; darunter nur die Liste; Detail ohne Auswahl über einen Slot (Gestaltung nach N3) | — |
| T02 | `recipe_list/recipe_list_screen.dart` | Auswahlzustand; ab 840 Tippen = auswählen, darunter wie heute `Navigator.push`; gelöschtes gewähltes Rezept hebt die Auswahl auf | 1 |
| T02 | `recipe_list/sections/recipe_list_results_section.dart`, `recipe_list/recipe_card.dart` | `selected` → `AppListItem.selected` (Auswahlbalken) | 1 |
| T02 | `recipe_detail/recipe_detail_screen.dart` | additiv `onClose` (im Detailbereich: nach „Rezept löschen“ Auswahl aufheben statt `pop`); Kopfleiste ohne Zurück im Bereich (kein `canPop`) | 4 |
| T03 | `foods/food_list_screen.dart`, `foods/sections/food_list_results_section.dart`, `foods/food_tile.dart` | wie T02; „Neues Lebensmittel“ öffnet den Editor im Detailbereich; nach dem Anlegen ist das neue Lebensmittel gewählt | 9 |
| T03 | `foods/food_editor_screen.dart` | additiv `onDone` (Speichern/Löschen im Bereich: kein `pop`) und `onDirtyChanged`; Auswahlwechsel mit ungespeicherten Änderungen fragt mit der bestehenden Rückfrage aus 10.0 (kein neuer Text) | 10 |

Unverändert bleiben `module/core_module.dart` (Routen: `/recipes/:id`,
`/foods/:id` öffnen weiter ganzseitig), `recipe_editor_screen.dart` und alle
übrigen Bildschirme. „Versionen“ und „Bearbeiten“ aus dem Detailbereich
öffnen ihre Seiten wie heute im Navigator der Hülle (über beide Bereiche).

**Nicht Teil von 1.4:** siehe Abschnitt (f).

---

## (d) Tests, Regeln, Kapitel 28

### d1 Neue Tests

| ID | Ort | Prüfregel | Commit |
|---|---|---|---|
| UI-83 | Core `test/ui/support/` | nur wenn die Ursache nachstellbar ist: der Fall aus S01 endet ohne Fix mit Hänger/rot, mit Fix grün | S02 |
| DS-62 | Design | `AppOverflowMenu.tooltip` in Semantik und Tooltip; Einträge ausgegraut über `enabled` | B01 |
| UI-84 | Core | Zeilenmenü der Zutatenzeile: drei Einträge, erste Zeile „Nach oben“ ausgegraut, letzte „Nach unten“ ausgegraut; „Nach unten“ verschiebt wie Ziehen (gleiche `onReorder`-Werte); „Entfernen“ entfernt; schreibgeschützt kein Menü | B01 |
| UI-85 | Core | dto. Schrittzeile, Nummern danach neu | B01 |
| UI-86 | Core | Bildschirm 3: Umsortieren über das Menü, Speichern, `position` wie beim Ziehen (wie UI-12, nur ohne Geste) | B01 |
| UI-87 | Core | Fassungsleiste: Master-Marke mit Markerfläche und Semantik „…, Master“; ohne Master unverändert | B02 |
| UI-88 | Core | Lebensmittelliste: Suche ohne Ergebnis → „Keine Treffer.“ ohne Leerstelle und ohne „Eigenes Produkt anlegen“; ohne Suche unverändert | B03 |
| UI-89 | Core | Suchtreffer im Titel markiert (`AppHighlight`), Semantik = ganzer Titel | B04 |
| UI-90 | Core | markierbare Texte im Rezeptdetail | B05 |
| DS-63 | Design | Liste-Detail-Rahmen: unter 840 nur Liste; ab 840 Liste `size-list-pane`, Haarlinie, Detail füllt; Slot ohne Auswahl; bei 200 % ohne Überlauf | T01 |
| UI-91 | Core | Rezepte bei 1024 × 1366 und 844 × 390: Tippen wählt (Auswahlbalken), Detail rechts; Wechsel; „Rezept löschen“ hebt die Auswahl auf; bei 390 × 844 wie heute `push` | T02 |
| UI-92 | Core | Lebensmittel bei 1024 × 1366: Auswahl, Editor rechts, Speichern ohne `pop`, Wechsel mit ungespeicherten Änderungen fragt nach, „Neues Lebensmittel“ im Bereich | T03 |
| APP-06 | App | sichtbarer Name „unsalted“ in iOS- und macOS-`Info.plist` und `AndroidManifest.xml` | M01 |

### d2 Testzeilen, die sich ändern (einzeln)

Pfade ab `packages/unsalted_core/` bzw. `apps/unsalted_app/`; Zeilennummern
Stand `ce6431f`. Jede Änderung nur wie angegeben; Ablauf, Testdaten und
Erwartungen bleiben.

**S02 — vorläufig, endgültig nach S01 (Nachtrag zur Freigabe).** Ersetzt
werden nur Helfer, Teardowns und feste Wartezeiten, keine Erwartung:

| Datei | Helfer (Definitionen) | Inline-Teardown | feste Wartezeit |
|---|---|---|---|
| `test/ui/config/core_ui_options_screens_test.dart` | 38, 43 | 47 | 33 |
| `test/ui/foods/food_editor_screen_test.dart` | 28, 54, 64 | 66 | 34 |
| `test/ui/foods/food_list_screen_test.dart` | 37, 58, 68 | 70 | 48, 98, 178 |
| `test/ui/recipe_detail/recipe_detail_menu_context_test.dart` | 52 | 62 | 47 |
| `test/ui/recipe_detail/recipe_detail_screen_test.dart` | 108, 120, 130 | 132 | 115 |
| `test/ui/recipe_editor/ingredient_row_test.dart` | 23, 28, 38 | 40 | 122 |
| `test/ui/recipe_editor/recipe_create_screen_test.dart` | 18, 28, 38 | 40 | 24, 165 |
| `test/ui/recipe_editor/recipe_editor_screen_test.dart` | 32, 43, 53 | 55 | 38, 398 |
| `test/ui/recipe_list/recipe_list_screen_test.dart` | 28, 42, 52 | 54 | 38, 103, 172 |
| `test/ui/settings/export_screen_test.dart` | 23, 35, 45 | 47 | 30 |
| `test/ui/settings/import_screen_test.dart` | 20, 32, 42 | 44 | 27 |
| `test/ui/settings/settings_screen_test.dart` | 40, 45, 55 | 57 | — |
| `test/ui/shared/decimal_comma_test.dart` | — | 138–142 | 65 |
| `test/ui/versions/version_compare_screen_test.dart` | 29, 41, 51 | 53 | 36 |
| `test/ui/versions/version_list_screen_test.dart` | 24, 36, 46 | 48 | 31 |

Dazu die Aufrufstellen der Helfer (je `addTearDown(() => _closeDatabase(…))`
und `_disposeWidgetTree(tester)` am Testende, 1.1d: 80 Stellen) — nur der
Name des Helfers. App (nur nach F13): `test/widget_test.dart:16, 24–25`,
`localization_test.dart:16, 23–24`, `theme_test.dart:17, 25–26`,
`ui_options_test.dart:17, 23–24`, `navigation_test.dart:18, 29–30`.

**B01 — Zeilenmenü**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `test/ui/recipe_editor/recipe_editor_screen_test.dart:176` | `tester.tap(find.byIcon(AppIcons.deleteOutline).first)` | Menü der ersten Zeile öffnen (`find.byTooltip(<Tooltip nach F4>).first`), dann `tester.tap(find.text('Entfernen'))` | Entfernen steht im Zeilenmenü (28.11); Z. 177–178 bleiben |
| `test/ui/recipe_editor/editor_design_test.dart:133` | `find.byTooltip('Zutat entfernen')` | `find.byTooltip(<Tooltip nach F4>)` | dto. |

`version_list_screen_test.dart:166` (Papierkorb einer Version, Bildschirm 7)
bleibt. UI-12 (Ziehen) bleibt unverändert.

**B02, B03, B04, T02, T03, M01:** keine Änderung bestehender Zeilen
erwartet. B02 fügt einen optionalen Parameter hinzu (Standard: kein Master
markiert, UI-67 unverändert); B03 ändert nur den Fall mit Suchbegriff
(`food_list_screen_test.dart:112–119` prüft den leeren Zustand ohne Suche und
bleibt); T02/T03: die Core-Tests laufen auf 800 × 600 bzw. 800 × 3000, also
unter 840; APP-04 (`navigation_test.dart:50`) findet „Noch keine Rezepte.“
bei 1024 und 844 weiter rechts der Leiste (jetzt im Listenbereich). Zeigt sich
beim Umsetzen doch eine Änderung → Stopp und fragen.

### d3 Bewusst unverändert

UI-12 (Ziehen bleibt), UI-67/68 (Fassungsleiste ohne Master), alle Tests bei
800 Breite (unter `breakpoint-expanded`), die C28-Liste aus
`plan-1.3.md` (d3), `bundle_language_test.dart` (APP-05).

### d4 Goldens

Ablauf wie `plan-1.3.md` (d4). Erwartete Änderungen: B01 → GL-02
`03_rezept_bearbeiten` (8 Bilder, Menü statt Papierkorb); B02 →
`04_rezeptdetail` (8, Master V2 in der Leiste; Fixture setzt V2 als Master);
T02 → `01_rezeptliste` Tablet (4 Bilder, Liste und leerer Detailbereich),
neues Motiv `01_04_liste_detail` mit gewähltem Rezept (8 Bilder; am Handy das
geöffnete Detail); T01 → GL-01 neues Motiv „liste_detail“; B03, B04 je nur,
wenn ein Motiv den Zustand zeigt (heute keins). Jedes Bild wird angesehen und
mit Figma verglichen (`147:9746`, `148:3817`).

### d5 Nachträge Kapitel 28 (neues 28.11 „Teil 1.4 – Stabilität, Bedienung, Tablet, Marke“)

1. **Kapitel 23 / 28.5 — Tests.** Widget-Tests mit Datenbank nutzen einen
   gemeinsamen Helfer, warten auf Bedingungen statt fester Zeiten und haben
   ein Zeitlimit je Test; neue IDs. (S02, M03)
2. **Kapitel 22, Bildschirm 3.** Jede Zutaten- und Schrittzeile hat ein
   Zeilenmenü mit „Nach oben“, „Nach unten“, „Entfernen“ statt des
   Papierkorbs; Umsortieren ist damit ohne Ziehen möglich (WCAG 2.5.7), das
   Ziehen bleibt. (B01)
3. **Kapitel 22, Bildschirm 4 / 28.10.4.** Die Fassungsleiste markiert die
   Master-Version (Markerfläche, „Master“ in der Semantik); der letzte Satz
   von 28.10.4 entfällt. (B02)
4. **Kapitel 22, Bildschirm 9.** Mit Suchbegriff ohne Ergebnis „Keine
   Treffer.“ ohne Aktion; ohne Suchbegriff unverändert. (B03)
5. **Kapitel 22, Bildschirm 1 — nur nach F5.** Der Suchtreffer im Titel ist
   markiert. (B04)
6. **Kapitel 22, Bildschirm 4 — nur nach F1.** Beschreibung, Zutaten und
   Schritte sind markierbar und kopierbar. (B05)
7. **Kapitel 22, Bildschirm 1/4 und 9/10, 28.4.1, 28.10.10.** Ab einer
   Fensterbreite von 840 stehen Liste und Detail nebeneinander (Liste in
   `size-list-pane`); Tippen wählt aus statt zu navigieren, der gewählte
   Eintrag trägt den Auswahlbalken; ohne Auswahl zeigt der Detailbereich
   [Gestaltung und Satz nach N3/F7]. Darunter wie bisher (`Navigator.push`).
   Routen unverändert. (T02, T03)
8. **Kapitel 22, Bildschirm 10 im Detailbereich.** Speichern und Löschen
   lassen den Bereich offen; Auswahlwechsel mit ungespeicherten Änderungen
   fragt wie „Zurück“ (28.4.6). (T03)
9. **Kapitel 21/28.2.4 — App.** Der sichtbare Name ist auf allen Plattformen
   „unsalted“; Bundle-Kennungen und Produktnamen bleiben (F9). (M01)
10. **Nur mit N4/N5 — App-Symbol und Startbild** nach Figma. (M02)
11. **28.10.12 — Design-Paket.** Neue Bausteine (Liste-Detail-Rahmen, ggf.
    Auswahlbereich), `AppOverflowMenu.tooltip`; Version 0.3.0. (B01, T01, M03)

---

## (e) Commit-Reihenfolge

Jeder Commit: `flutter analyze` und `flutter test` in allen betroffenen
Paketen grün (Mac ohne Goldens, CI mit Goldens), `dart run
tool/check_architecture.dart` Exit 0, `status.md`, `decisions.md` und
`CLAUDE.MD` Abschnitt 2 nachgeführt; Präfix „Teil 1.4 Xnn: …“. Jeder neue
Test mit Gegenprobe (Produktivcode vorübergehend zurück → rot). Kein Merge,
kein Tag.

### Etappe 1 — Stabilität (Stopp nach S01 und nach S03)

**S01 — Wiederholungswerkzeug und Diagnose.** Neu: `tool/repeat_tests.dart`.
Keine Änderung an Tests oder `lib/`. Läufe D1–D5 aus (b); Ergebnis,
Ursache (oder „nicht reproduzierbar“ mit Messwerten) in `decisions.md`.
**Stopp:** Bericht und endgültige Testzeilen für S02 als Nachtrag zu (d2).

**S02 — Behebung.** Neu: `test/ui/support/db_widget_harness.dart` (+ UI-83,
falls nachstellbar). Ändern: Zeilen aus (d2) S02, `dart_test.yaml`
(Zeitlimit, F12), App-Tests nach F13; `spezifikation.md` 28.11.1.
Abnahme: alle Tests grün; Gegenprobe des Helfers (Auspumpen vorübergehend
entfernt → der Fall aus S01 hängt/wird rot, mit Zeitlimit nach kurzer Zeit
mit Namen).

**S03 — Abnahme Stabilität.** Nur Doku. `tool/repeat_tests.dart`: Core
**20 volle Läufe** mit Standard-Parallelität ohne Hänger und ohne roten Test,
dazu 10 Läufe unter Last (`--load` = Zahl der Kerne) und App 10 Läufe;
Messwerte (Dauer min/median/max) in `decisions.md`. CI auf dem PR grün.
**Stopp** mit Bericht.

### Etappe 2 — Bedienung (Stopp nach B05 bzw. dem letzten freigegebenen Commit)

**B01 — Zeilenmenü (a).** Dateien aus (c) B01, Tests aus (d2) B01, neu
DS-62, UI-84–86; Widgetbook (Menü mit Tooltip); `rueckmeldung-figma.md` A2
nachführen; 28.11.2. Vorbedingung N1 bzw. F4. Goldens `03`.

**B02 — Master in der Fassungsleiste (b).** Dateien aus (c) B02, neu UI-87;
28.11.3; `rueckmeldung-figma.md` B-Zeile entfällt. Goldens `04`.

**B03 — „Keine Treffer.“ in der Lebensmittelliste.** Dateien aus (c) B03,
neu UI-88; 28.11.4; Vorbedingung N2 bzw. F4.

**B04 — Suchtreffer markiert (nur nach F5).** Dateien aus (c) B04, neu
UI-89; 28.11.5.

**B05 — Markierbare Rezepttexte (nur nach F1 = ja).** Design-Komponente mit
Katalog und DS-Test, Dateien aus (c) B05, neu UI-90; 28.11.6; Vorbedingung N6.

Frage d) (Rezept löschen) braucht nach Empfehlung F2 keinen Commit.

### Etappe 3 — Tablet (Stopp nach T03)

**T01 — Liste-Detail-Rahmen (Design).** Neu: `templates/list_detail_template.dart`,
DS-63, Katalog-Eintrag (WB-02), GL-01-Motiv. Ändern: Tür +
`public_api_golden.txt`, `CHANGELOG.md`. Abnahme: DS-46–48 und DS-60
unverändert; Figma `147:9746`, `148:3817`, `159:8176` (200 %).

**T02 — Rezepte: Liste und Detail.** Dateien aus (c) T02, neu UI-91,
Goldens (d4). Vorbedingung N3 (leerer Detailbereich) bzw. F7. 28.11.7.
Abnahme zusätzlich: Rezeptdetail zweispaltig im Bereich bei Tablet quer
gegen `148:4381`.

**T03 — Lebensmittel: Liste und Editor.** Dateien aus (c) T03, neu UI-92.
Vorbedingung N3. 28.11.7, 28.11.8. Abnahme: UI-29–32 und 10.0 (Rückfrage)
unverändert grün.

### Etappe 4 — Marke und Abschluss

**M01 — App-Name (e).** `ios/Runner/Info.plist` (`CFBundleDisplayName` und
`CFBundleName` „unsalted“), `macos/Runner/Info.plist` (`CFBundleName`
„unsalted“, neu `CFBundleDisplayName`), `android/app/src/main/AndroidManifest.xml`
(`android:label="unsalted"`); `PRODUCT_NAME`, Bundle-Kennungen und
`applicationId` bleiben (F9). Neu APP-06 mit Gegenprobe; Prüfung mit
`plutil -lint` und, soweit lokal möglich, `flutter build ios --no-codesign`,
`flutter build macos`; auf dem Gerät durch den Projektverantwortlichen.
28.11.9.

**M02 — App-Symbol und Startbild (nur mit N4/N5).** Dateien aus Figma in
die nativen Ordner (Weg nach F10). Ohne Lieferung entfällt M02 und wandert in
einen späteren Teil.

**M03 — Abschluss.** `screens.md`, `components.md`, `rueckmeldung-figma.md`,
`design_system.md` (falls neue Regel), README/CHANGELOG und Version 0.3.0
von `unsalted_design` (F11), Kapitel 28.11 vollständig, `status.md`,
`decisions.md`, `CLAUDE.MD`. Abnahme: alle Tests aller vier Pakete grün (CI
mit Goldens), Exit 0. Merge und Tags erst nach Freigabe.

---

## (f) Bewertung der übrigen Punkte

Aus `plan-1.3.md` („Nicht Teil von 1.3“, Kandidaten) und
`rueckmeldung-figma.md`.

| Punkt | Quelle | 1.4? | Begründung |
|---|---|---|---|
| Sichtbares Umsortieren ohne Ziehen | Kandidat 2026-10-18 | **ja** (B01) | = Kandidat a |
| Master in der Fassungsleiste | Kandidat, rueckmeldung B | **ja** (B02) | = Kandidat b; in Figma gestaltet |
| „leer“/„keine Treffer“ in der Lebensmittelliste | Kandidat | **ja** (B03) | N2 bzw. Vorbild `31:1845` |
| Liste und Detail ab 840 (F4) | Kandidat, rueckmeldung B | **ja** (Etappe 3) | in Figma gestaltet bis auf N3 |
| Suchtreffer im Marker | Nicht Teil von 1.3, rueckmeldung B | **ja, nach F5** (B04) | klein, in Figma gestaltet (`List/Item` `showMatch`), die Rezeptliste wird in T02 ohnehin geändert |
| Fassungsmarke und Versionszahl je Rezept in der Liste | Nicht Teil von 1.3, rueckmeldung B | später | braucht die Versionen je Rezept: `watchVersions` je Karte (eine Abfrage je Eintrag) oder eine neue Abfrage im Repository — Core-Logik, gegen die Leitplanke; eigener Teil mit Datenfrage |
| Rezepttitel als `display` im Inhalt, leere Kopfleiste | Nicht Teil von 1.3, rueckmeldung B | später | ändert Kopfleiste und Aktionen aller Detail-Zustände; Gestaltungsangleich ohne Bedienungsgewinn |
| Reihenfolge der Detail-Abschnitte | Nicht Teil von 1.3 | später | Kapitel 22 legt die Reihenfolge fest; Änderung braucht eine eigene Entscheidung zu Kapitel 22 |
| Kopfzeile mit beiden Marken statt Spalten A/B | Nicht Teil von 1.3, rueckmeldung B | später | Gestaltungsangleich, Bildschirm 8 sonst unberührt |
| Zutaten im Rezeptdetail als `Core/Ingredient Row` | rueckmeldung B | später | Gestaltungsangleich |
| Editor-Vorschau im Rahmen mit Kennzahlen (pro Portion, pro 100 g) | Nicht Teil von 1.3, rueckmeldung B | später | inhaltliche Erweiterung, eigene Freigabe (wie in 1.3 festgehalten) |
| Portionen und Backverlust nebeneinander | rueckmeldung B | später | gestapelt mit `space-m` entschieden (D16b, D18d); Gestaltungsangleich |
| Auswahlfeld umrandet auch ohne Beschriftung (`Input/Select`) | rueckmeldung B | später | Komponentenänderung mit breiter Golden-Wirkung; Gestaltungsangleich |
| Aktion im Hinweis in `size-control-small` | rueckmeldung B | später | Gestaltungsangleich, klein |
| Signaturmomente Einfrieren und Küren | Nicht Teil von 1.3, rueckmeldung B | später | braucht Bewegungsgestaltung aus Figma (eigener Nachtrag) |
| Halbgeviertstrich in „Eingefroren — …“ | Nicht Teil von 1.3 | nein | Text nach Kapitel 22 (rueckmeldung A1: Figma zieht nach) |
| A1–A4 (bewusste Abweichungen) | rueckmeldung A | kein Code | Figma zieht nach; A2 „Entfernen mit Papierkorb“ entfällt mit B01 und wird nachgeführt |

Die „später“-Punkte mit reinem Gestaltungsangleich bilden zusammen einen
möglichen eigenen Teil „Figma-Angleich“. Ebenfalls nicht Teil von 1.4:
Teilen-Dialog und Dateiauswahl (28.8.1/2, neue Pakete und Rechte), die
Mapper-Leichen (`data/`, Core-Logik), KI-Themen (Teil 6), `material_ui` (F3).

---

## (g) Risiken und offene Fragen

### Risiken

| Nr | Risiko | Gegenmaßnahme |
|---|---|---|
| R1 | Die Hänger lassen sich nicht nachstellen | Abnahme über Wiederholungsläufe (S03) plus Härtung (Warten auf Bedingungen, Zeitlimit je Test), Messwerte im Bericht; Ursache bleibt dann offen benannt |
| R2 | Härtung verdeckt echte Fehler | keine längeren festen Zeiten; `pumpUntil` mit Obergrenze und klarer Meldung; Erwartungen unverändert; Gegenprobe |
| R3 | S02 berührt 15 Testdateien (und 5 App-Dateien) | nur Helfer, Teardown und Wartezeilen; Liste nach S01 zur Freigabe; maschinell geprüft, dass sich keine `expect`-Zeile ändert |
| R4 | Ursache liegt in Flutter oder Drift | Umgehung nur in Tests; `lib/` unverändert; keine Meldung an fremde Projekte ohne Freigabe |
| R5 | Zeilenmenü: Entfernen braucht zwei Tipps statt einem | Ziehen bleibt; Entfernen bleibt sofort wirksam (Entwurf, erst „Speichern“ schreibt); Figma entscheidet über N1 |
| R6 | Liste und Detail: verschachtelte Seiten, Navigator, `PopScope` | Detail im Bereich ohne Zurück, `onClose`/`onDone` statt `pop`; Tests bei 1024 und 844; Routen unverändert |
| R7 | Ungespeicherte Änderungen beim Auswahlwechsel (Lebensmittel) | Rückfrage wie 10.0, gleiche Texte; UI-92 |
| R8 | App-Name: Änderung von `PRODUCT_NAME` bricht Pfade, Schemes und Signatur | nur sichtbare Namen (F9); lokale Builds als Nachweis |
| R9 | Figma-Nachträge kommen nicht rechtzeitig | betroffene Commits warten oder entfallen (B01/B03 nach F4, T02/T03 nach F7, M02, B05); Etappen 1 und B02 hängen nicht davon ab |
| R10 | Golden-Umfang (03, 04, 01-Tablet, neues Motiv) | Ablauf aus 1.3; jedes Bild angesehen |
| R11 | Freeze Teil 1 | Core-Tür, Logik, Schema, `module/` unverändert; Kapitel 28.11 + `decisions.md` |
| R12 | Fensterbreite vs. verfügbare Breite: bei 844 quer bleiben neben der Leiste 748 | Entscheidung nach Fensterbreite wie Material und Figma (`148:3817` zeigt Liste und Detail bei 844) |

### Fragen F1–F13 (mit Empfehlung)

- **F1 — c) Rezepttexte markierbar und kopierbar?** *Empfehlung:* **ja, nur
  im Rezeptdetail** (Beschreibung, Zutaten, Schritte) über eine
  Design-Komponente (Auswahlbereich mit Farbe aus Tokens), als B05 nach N6.
  Nicht in Listen (Wischen, Tippen) und nicht in Eingabefeldern (können das
  schon). Kopieren eines ganzen Rezepts als Text wäre eine eigene Funktion.
- **F2 — d) Rezept löschen.** *Empfehlung:* **Rückgängig beibehalten** (5 s,
  wie 1.1b und wie Lebensmittel), keine zusätzliche Rückfrage; kein Commit.
- **F3 — Umstieg auf `material_ui` (F1 aus 1.3).** *Empfehlung:* **eigener
  kleiner Teil nach 1.4**, nicht in 1.4. Der Umstieg ist mechanisch, ändert
  aber die Architekturregeln des Design-Pakets (Abhängigkeiten von
  `material_ui`, DS-01, `allowed_in_design`, `check_architecture.dart`,
  28.9.1/3) und würde jedes Golden und jeden Etappen-Diff mit fremden
  Änderungen mischen. Zeitpunkt: sobald `flutter/material.dart` in einer
  Flutter-Version veraltet ist, spätestens vor Teil 2.
- **F4 — Zeilenmenü und „Keine Treffer“ ohne eigenen Figma-Entwurf?**
  *Empfehlung:* N1 vorher von Figma (kleiner Nachtrag). Falls nicht
  rechtzeitig: B01 aus vorhandenen Komponenten (`Icon/more` „⋮“ +
  `Navigation/Overflow Menu`), Abweichung in `rueckmeldung-figma.md`. Ein
  waagerechtes „⋯“ gibt es in Figma nicht; empfohlen ist `Icon/more`.
  Tooltip des Menüs: „Aktionen für Zutat“ bzw. „Aktionen für Schritt“ (neue
  Texte, Nachtrag 28.11.2). Für B03 genügt das Vorbild `31:1845`; N2 nur zur
  Vollständigkeit.
- **F5 — Suchtreffer im Marker in 1.4 (B04)?** *Empfehlung:* ja (Figma
  gestaltet, klein).
- **F6 — Liste und Detail beim Verkleinern unter 840 mit Auswahl.**
  *Empfehlung:* Auswahl bleibt im Bildschirm erhalten, unter 840 nur die Liste
  (kein automatisches Öffnen); beim Vergrößern erscheint das Detail wieder.
  Alternative: Detail unter 840 automatisch als Seite öffnen (mehr Navigation
  im `build`, fehleranfälliger).
- **F7 — Detailbereich ohne Auswahl.** *Empfehlung:* Gestaltung aus N3; bis
  dahin Vorschlag Leerstelle ohne Aktion mit „Rezept auswählen.“ bzw.
  „Lebensmittel auswählen.“ (neue Texte, 28.11.7). Ohne N3 und ohne Antwort
  warten T02/T03.
- **F8 — Liste und Detail über Auswahlzustand statt Routen.** *Empfehlung:*
  ja; `module/` und die Routen bleiben, Deep Links `/recipes/:id` und
  `/foods/:id` öffnen weiter ganzseitig. Alternative (verschachtelte Routen in
  der Hülle) ändert `module/` und 28.2.3/28.4.1 und hat ohne Deep-Link-Bedarf
  keinen Nutzen.
- **F9 — App-Name.** *Empfehlung:* „unsalted“ klein (Markenbuch README,
  03-markenelemente: „Bis zur Gestaltung … klein gesetzt“); nur sichtbare
  Namen ändern, nicht `PRODUCT_NAME`, Bundle-Kennung (`de.unsalted.unsaltedApp`)
  und `applicationId` — sonst neue Installation statt Update und andere
  Build-Pfade.
- **F10 — App-Symbol und Startbild.** *Empfehlung:* nur mit Dateien aus Figma
  (N4, N5). Weg: Figma liefert Master und Android-Ebenen; die Größen erzeugt
  einmalig `flutter_launcher_icons` als `dev_dependency` der App (Ergebnis
  eingecheckt) — oder von Hand ohne neue Abhängigkeit. Ohne Lieferung bis
  Etappe 4: M02 in einen späteren Teil.
- **F11 — Versionen und Tags.** *Empfehlung:* `unsalted_design` 0.3.0 (neue
  Bausteine); nach Freigabe Tags `part1-v1.4.0` und `design-v0.3.0`.
- **F12 — Zeitlimit je Test und Abnahme.** *Empfehlung:* `timeout: 2m` in
  `packages/unsalted_core/dart_test.yaml` (ein Widget-Test braucht heute unter
  10 s; 2 min lassen Luft unter Last), CI-Grenze 20 min bleibt; Abnahme 20
  volle Core-Läufe ohne Hänger plus 10 unter Last plus App 10.
- **F13 — App-Tests mitziehen?** *Empfehlung:* ja, in S02: die 5 App-Dateien
  schließen noch nach dem alten Muster (vor 1.1d) und hätten bei einem roten
  Test dasselbe Hänger-Risiko; Zeilen in (d2).
