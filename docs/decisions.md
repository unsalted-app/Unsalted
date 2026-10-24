# Entscheidungsprotokoll

Kurze, datierte Einträge zu Entscheidungen, die vom Bericht abweichen oder ihn
präzisieren. Jeder Eintrag: Datum, betroffenes Kapitel, Entscheidung, Begründung.

# Entscheidungsprotokoll

Kurze, datierte Einträge zu Entscheidungen, die vom Bericht abweichen oder ihn
präzisieren. Jeder Eintrag: Datum, betroffenes Kapitel, Entscheidung, Begründung.

Aktuell keine Einträge.

---

## 2026-09-24 — Standardfelder nicht pauschal in Fachmodelle übernommen

**Betroffenes Kapitel:** 7.1 (Standardfelder), 14 (Datei-für-Datei-Plan), 9 (Snapshot-Format)

**Entscheidung:** Die vier Standardfelder aus Kapitel 7.1 (`id`, `created_at`,
`updated_at`, `deleted_at`) wandern NICHT pauschal in jede Phase-3-Fachmodell-
Klasse. Stattdessen:
- `Recipe.id`, `RecipeVersion.id`, `FoodVariant.id` → ja, als Feld vorhanden.
- `RecipeVersion.createdAt` → ja, als Feld vorhanden.
- `RecipeIngredient` und `RecipeStep` → kein `id`-Feld, kein `createdAt`-Feld.
- `updated_at` und `deleted_at` → in KEINEM Fachmodell als Feld vorhanden,
  bleiben reine Tabellenspalten (erst ab Phase 5 relevant).

**Begründung:** Kapitel 14 trennt Fachmodelle (`recipe/*.dart`, "keine
Drift-Typen") klar von Tabellen (`data/tables/*.dart`, dort stehen die
Standardfelder) und Mappern (übersetzen zwischen beiden). Was tatsächlich in
die Fachmodelle gehört, ergibt sich daraus, was die Fachlogik nachweislich
braucht:
- Snapshot-Format v1 (Kapitel 9) enthält `version.id` und `version.created_at`
  als Pflichtfelder, aber kein `id`-Feld bei ingredients/steps.
- `RecipeChange` (Kapitel 10) adressiert Zutaten/Schritte über `position`,
  nie über eine `id`.
- Kapitel 7.3 verlangt Sortierung "stabil über (version_index, created_at, id)"
  — das setzt voraus, dass RecipeVersion beide Felder trägt.
- `updated_at`/`deleted_at` sind laut Kapitel 7.1 reine Repository-/Sync-
  Mechanik ("vom Repository gesetzt, nie von SQLite"; "Alle Lesezugriffe
  filtern deleted_at IS NULL") — die Fachlogik selbst braucht sie nirgends.

**Alternativen verworfen:** Alle vier Standardfelder pauschal in jede
Fachmodell-Klasse übernehmen — verworfen, weil das Fachmodelle mit
DB-/Sync-Metadaten belastet hätte, die laut Kapitel 14 explizit Sache der
Tabellen-/Mapper-Schicht sind, und weil RecipeIngredient/RecipeStep dadurch
ein `id`-Feld bekommen hätten, das nirgends im Bericht (Snapshot-Format,
RecipeChange) tatsächlich verwendet wird.

**STATUS: durch den Eintrag vom 2026-09-24 (neue Spezifikation, Kapitel 10)
überholt — siehe unten.**

---

## 2026-09-24 — Neue Spezifikation ersetzt Fachmodell/Standardfeld-Entscheidung

**Betroffenes Kapitel:** 10 (Fachmodell und Persistenzmodell), R9

**Entscheidung:** Der Bericht wurde durch eine neue, deutlich präzisere
Spezifikation ersetzt (Kapitel 10 regelt jetzt explizit pro Fachmodell, welche
Standardfelder aufgenommen werden, statt es offenzulassen). Die eigene
Entscheidung vom selben Tag (siehe oben) wird dadurch an vier Stellen
korrigiert:

1. `Recipe.ownerId` entfällt (Kapitel 10.3) — reines Sync-Feld, kein
   Fachmodell-Feld nötig, `assignOwner` schreibt direkt auf die Tabelle.
2. `RecipeVersion.createdAt` entfällt (Kapitel 10.4) — kein UI-Bildschirm
   zeigt ihn, keine Sortierung braucht ihn (`versionIndex` reicht).
   `RecipeSnapshotV1.version.created_at` (Snapshot-Format, Kapitel 13) ist
   eine eigenständige Datenklasse und unabhängig davon vorhanden; die
   Data-Schicht liest den Wert beim Einfrieren direkt aus der DB-Zeile.
   `snapshottedAt` bleibt als einzige bewusste Ausnahme im Fachmodell
   (Kapitel 10.4: "ausdrücklich fachlich relevant", UI zeigt
   "eingefroren am …").
3. `RecipeIngredient.id` und `RecipeStep.id` werden neu aufgenommen
   (Kapitel 10.5) — Identität für Drag-Reorder in der UI (Bildschirm 3),
   unabhängig von `position`, das sich während eines Reorders für mehrere
   Zeilen gleichzeitig ändert. `RecipeChange` adressiert weiterhin über
   `position`, nicht über `id` — beide Identifikatoren dienen
   unterschiedlichen Zwecken und stehen nicht im Widerspruch.
4. `FoodVariant.ownerId` entfällt (Kapitel 10.6), aus demselben Grund wie
   `Recipe.ownerId`. Der Enum-Name wird von `FoodVariantSource` auf
   `FoodSource` geändert (Kapitel 18.1, Dateivertragstabelle).

Zusätzlich: AT-05 wird breiter gefasst (nicht mehr nur `ui/`, sondern
`ui/`, `nutrition/`, `recipe/`, `food/`, `contracts/`, `module/`,
`providers/` — überall außer `data/`), und ein neuer Test AT-12 kommt dazu
("kJ" darf nirgends in `lib/` oder `test/` vorkommen).

**Begründung:** Die neue Spezifikation ist an den entscheidenden Stellen
präziser als der ursprüngliche Bericht und wurde gegen alle anderen Kapitel
(Snapshot-Format, RecipeChange, RecipeDiff, ID-Regeln, DB-Tabellen,
UI-Spezifikation) auf Widerspruchsfreiheit geprüft — keine gefunden.

**Alternativen verworfen:** Bei der eigenen, ersten Entscheidung bleiben —
verworfen, weil die neue Spezifikation an vier Stellen eine begründetere,
im Gesamtdokument konsistentere Lösung vorgibt (insbesondere die
Trennung Fachmodell/Snapshot-Format bei `createdAt`, die im alten Bericht
gar nicht auflösbar war).

---

## 2026-09-29 — Schritt 6.3: `drift_recipe_repository.dart` importiert `nutrition/*`

**Betroffenes Kapitel:** 12.3 (`snapshotVersion`), 18.1 (Dateivertragstabelle)

**Entscheidung:** `DriftRecipeRepository` (Schritt 6.3) importiert
`nutrition/nutrition_engine.dart`, `nutrition/unit_catalog.dart` und
`nutrition/decimal_math.dart` direkt, obwohl die Dateivertragstabelle in
Kapitel 18.1 für `drift_recipe_repository.dart` `nutrition/*` unter "darf
nicht importieren" listet.

**Begründung:** Kapitel 12.3 ("`snapshotVersion(versionId)` — vollständiger
Ablauf"), das die Arbeitskarte für Schritt 6.3 selbst als verbindlichen
Contract nennt, schreibt in Punkt 3 ausdrücklich
`NutritionEngine.calculate(...)` vor, um beim Einfrieren einer Version das
`nutrition`-Objekt des Snapshots (Kapitel 13.1/13.2, Pflichtfeld) zu
erzeugen. Der Dateiscope von Schritt 6.3 erlaubt das Anlegen genau einer
Datei (`drift_recipe_repository.dart` + Test) — es gibt keine andere
erlaubte Stelle, an der diese Berechnung stattdessen passieren könnte.
`DriftSnapshotService` (Schritt 6.6, Kapitel 16.4) kommt dafür nicht in
Frage: laut Kapitel 13.7 liefert `exportVersion` das bereits gespeicherte
`snapshotJson` unverändert zurück und berechnet zum Exportzeitpunkt nichts
neu — die Berechnung beim Einfrieren muss also bereits vorher, in
`snapshotVersion`, geschehen sein. Kein Architekturtest verbietet diesen
Import tatsächlich: AT-02 prüft nur, dass Dateien innerhalb von
`nutrition/` nichts Unerlaubtes importieren (nicht die Gegenrichtung),
AT-05 nur, dass Nicht-`data/`-Dateien kein `package:drift` importieren.

**Alternativen verworfen:** Eine eigene Berechnungslogik innerhalb von
`drift_recipe_repository.dart` duplizieren, ohne `NutritionEngine` zu
importieren — verworfen, weil das die einzige-Berechnungsstelle-Regel
(Kapitel 4.3/AT-08) unterlaufen und die Nährwertlogik dupliziert hätte.
Die Berechnung stattdessen auf einen späteren Schritt verschieben —
verworfen, weil `snapshotVersion` laut Kapitel 12.3 zwingend zum Zeitpunkt
des Einfrierens ein vollständiges, korrektes `nutrition`-Objekt im
Snapshot-JSON ablegen muss.

---

## 2026-09-29 — Schritt 7.2: `CoreModule.routes` leer, `ownerColumn` einheitlich `'owner_id'`

**Betroffenes Kapitel:** 21 (Modul-/Steckplatzsystem)

**Entscheidung 1 (Routen):** `CoreModule.routes` liefert für Phase 1 eine
leere Liste, obwohl Kapitel 21 "seine eigenen Routen" als Teil von
`CoreModule` nennt. Begründung: Die zugehörigen Bildschirme (Kapitel 22,
Bildschirm 1–13) sind erst Phase 8; ein `GoRoute` ohne existierendes
Bildschirm-Widget lässt sich nicht sinnvoll bauen. Die Arbeitskarte für
Schritt 7.2 verlangt in §10 (Tests) ausdrücklich nur die Prüfung von `id`,
Tabellenliste und `immutableAfterCreate` — `routes` ist dort nicht
genannt — und §12 (Stop-Bedingung) schließt Provider-/main.dart-
Verdrahtung für diesen Schritt ausdrücklich aus. Phase 8 ergänzt die
echten `GoRoute`-Einträge, sobald die Bildschirm-Widgets existieren.

**Entscheidung 2 (ownerColumn):** Alle fünf `SyncTableSpec`-Einträge
tragen `ownerColumn: 'owner_id'`, obwohl nur `recipes` und `food_variants`
(Kapitel 11.2, 11.6) tatsächlich eine eigene `owner_id`-Spalte besitzen;
`recipe_versions`/`recipe_ingredients`/`recipe_steps` (Kapitel 11.3–11.5)
haben keine. Kapitel 21 gibt für `ownerColumn` nur ein Beispiel
(`'owner_id'`), keine Tabelle mit Werten je Zeile, und die Arbeitskarte
prüft dieses Feld nicht. Für die drei Zeilentabellen ohne eigene Spalte ist
der Wert als Hinweis für die künftige Sync-Schicht (Teil 3) gedacht,
Besitz über die Elternkette (`version_id` → `recipe_id` →
`recipes.owner_id`) aufzulösen — keine Behauptung einer physisch
vorhandenen Spalte. Endgültige Festlegung bleibt Sache von Teil 3.

**Alternativen verworfen:** Bei Entscheidung 1 Platzhalter-Routen auf
Dummy-Widgets bauen — verworfen, weil das totem Code in Phase 8 hinterlassen
und suggerieren würde, die Routen seien bereits final, obwohl die
eigentlichen Bildschirme fehlen. Bei Entscheidung 2 `ownerColumn` für die
drei Zeilentabellen auf `'recipe_id'`/`'version_id'` setzen — verworfen,
weil das Feld laut Kapitel 21 die *Besitzer*-Spalte meint (Konto-Bezug),
nicht die Eltern-Referenz, und eine falsche Spalte suggerieren würde, die
gar nicht existiert.

---

## 2026-09-29 — Schritt 7.3: AT-05 um Ausnahme für `src/providers/` erweitert

**Betroffenes Kapitel:** 16.7 (Riverpod-Provider), AT-05 (Testsuite)

**Entscheidung:** `test/architecture/at05_data_boundary_test.dart` (AT-05)
wurde um eine Ausnahme für `src/providers/` erweitert — dieser Ordner darf
jetzt wie `src/data/` aus `data/` importieren, statt dagegen zu verstoßen.

**Begründung:** `lib/src/providers/core_providers.dart` (Schritt 7.3) hat
laut Arbeitskarte §5 ("BENÖTIGTE TYPEN UND DATEIEN") die ausdrückliche
Aufgabe, `CoreDatabase`, `RecipeDao` und die konkreten `Drift*`-
Implementierungen aus `data/` hinter den öffentlichen Contracts zu
verdrahten (Kapitel 16.7). Das ist ohne einen Import aus `data/` technisch
nicht möglich — eine Verdrahtungs-/Composition-Root-Datei referenziert per
Definition beide Seiten (Interface und konkrete Implementierung). AT-05 war
zum Zeitpunkt seiner letzten Erweiterung (Eintrag vom 2026-09-24) offenbar
noch nicht gegen die tatsächlichen Anforderungen von Phase 7 geprüft worden
— der Test hätte in seiner bisherigen Form jede mögliche Umsetzung von
Schritt 7.3 zwangsläufig scheitern lassen, unabhängig von deren Qualität.

**Alternativen verworfen:** `core_providers.dart` unter `lib/src/data/`
ablegen, um die bestehende Ausnahme zu nutzen — verworfen, weil das der in
Kapitel 18 vorgegebenen Verzeichnisstruktur (`lib/src/providers/`)
widersprochen und die klare Trennung „Persistenz" vs. „Verdrahtung"
verwischt hätte. Die Test-Verletzung ignorieren/den Test nicht laufen
lassen — verworfen, da AT-05 Teil der regulären, in CLAUDE.md
vorgeschriebenen Prüfkette (`flutter test`) ist und stillschweigend
ignorierte rote Tests gegen die Projektregeln verstoßen.

---

## 2026-09-29 — Schritt 7.4: öffentliche Tür ohne `recipeDaoProvider`/`foodDaoProvider` und ohne Snapshot-/Unit-Detailtypen

**Betroffenes Kapitel:** 16.7 (Riverpod-Provider), 16.8 (DAO-Contracts),
17 (Rechenkern als öffentliche Schnittstelle), 18.1 (Regel für die Tür)

**Entscheidung 1:** `lib/unsalted_core.dart` exportiert `coreDatabaseProvider`,
`modulesProvider`, `recipeRepositoryProvider`, `foodRepositoryProvider`,
`nutritionServiceProvider`, `snapshotServiceProvider`,
`domainEventsProvider` — **nicht** `recipeDaoProvider`/`foodDaoProvider`,
obwohl Kapitel 16.7 alle acht (inkl. `recipeDaoProvider`) im selben
Codeblock als "Öffentlich exportiert" bezeichnet. Begründung: Kapitel 16.8
sagt für DAO-Contracts unmissverständlich "keine externe Public API", und
Kapitel 18.1s Regel für die Tür schließt DAOs ausdrücklich aus ("Niemals
... DAOs ... exportieren"). Ein `Provider<RecipeDao>` öffentlich zu
exportieren würde genau das unterlaufen, was diese Regel verhindern soll —
UI-Code könnte sich dann direkt gegen `RecipeDao` statt gegen
`RecipeRepository` verdrahten. Die speziellere, später im Dokument stehende
Regel (18.1) hat Vorrang vor der allgemeineren Formulierung in 16.7.

**Entscheidung 2:** Von `recipe_snapshot_v1.dart` wird nur `RecipeSnapshotV1`
exportiert (nicht `RecipeSnapshotRecipe`/`RecipeSnapshotVersion`/
`RecipeSnapshotIngredient`/`RecipeSnapshotStep`/`RecipeSnapshotNutrition`
oder die Format-Konstanten). Von `unit_catalog.dart` wird nur `UnitCatalog`
exportiert (nicht `Unit`/`UnitKind`). `NutrientValidator`/`NutrientWarning`/
`NutrientWarningKind` werden gar nicht exportiert. Begründung: Kapitel 18.1
nennt namentlich nur `RecipeSnapshotV1` bzw. `UnitCatalog`; Kapitel 17 sagt
für die Nährwerttypen ausdrücklich, `NutritionResult`/`NutrientSet`/
`UnitCatalog`/`NutritionFormatter` seien "die einzigen Typen, mit denen UI
und spätere Teile über Nährwerte kommunizieren" — ein geschlossener
Vier-Typen-Katalog ohne `NutrientValidator`. Die Tür wird ab diesem Schritt
eingefroren (Kapitel 25.1); ein zu knapper Export lässt sich später gezielt
und bewusst erweitern, ein zu großzügiger nicht ohne Bruch zurücknehmen —
deshalb im Zweifel die engere, textlich exakt belegte Lesart gewählt.

**Alternativen verworfen:** Bei Entscheidung 1 `recipeDaoProvider`/
`foodDaoProvider` trotzdem exportieren, weil Kapitel 16.7 sie zeigt —
verworfen als Widerspruch zu Kapitel 16.8s expliziter Aussage. Bei
Entscheidung 2 vorsorglich alle Snapshot-Detailtypen und `Unit`/`UnitKind`
mitexportieren, "falls Phase 8 sie braucht" — verworfen, weil das über den
in Kapitel 17/18.1 wörtlich benannten Umfang hinausgeht und die Tür ab
diesem Schritt als eingefroren gilt; ein späterer, dokumentierter
Nachtrag ist der vorgesehene Weg, keine Vorratshaltung jetzt.

## 2026-09-30 — Nachtrag 8.7a: `CoreModule.routes` gefüllt

**Betroffenes Kapitel:** 21 (Modul-/Steckplatzsystem), 22 (Routen-Tabelle),
18.1 (öffentliche Tür), Arbeitskarten 7.2 und 8.8.

**Entscheidung:** `core_module.dart` liefert in `routes` je einen `GoRoute`
für alle Bildschirme mit eigener Route aus Kapitel 22: `/`, `/recipes/new`,
`/recipes/:id`, `/recipes/:id/versions`, `/recipes/:id/versions/:vid/edit`,
`/recipes/:id/compare` (Query `a`, `b`), `/foods`, `/foods/new`,
`/foods/:id`, `/settings`, `/settings/export`, `/settings/import`. Die
Bildschirme werden unverändert über ihre bestehenden Konstruktoren
eingebunden; ihre interne Navigation per `Navigator.push` bleibt, wie sie
ist. `core_module_test.dart` prüft jetzt genau diese Pfadmenge statt
`routes isEmpty`.

**Begründung:** Planungslücke. Schritt 7.2 hat die Routen ausdrücklich auf
„Phase 8" verschoben (die Bildschirme existierten noch nicht), aber keine
Arbeitskarte 8.1–8.7 hatte `core_module.dart` im Dateiscope, und 8.8
verbietet Änderungen an `unsalted_core`. Gleichzeitig setzen Kapitel 21
(„`CoreModule` liefert … seine eigenen Routen") und 8.8 §8 („Router
verbindet die Core-Routen") gefüllte Routen voraus. Die App-Hülle kann
Bildschirme auf keinem anderen legalen Weg erreichen: AT-09 verbietet
`package:unsalted_core/src/...` außerhalb des Pakets, und die öffentliche
Tür exportiert (eingefroren seit 7.4) keine Widgets. Weder die Freeze-Liste
in Kapitel 25.1 (7.1 = nur Typen, 7.4 = nur Exportinhalt der Tür) noch
AT-01/05/09 werden durch diesen Nachtrag verletzt. Vom Projektverantwortlichen
als eng begrenzter Nachtrag vor 8.8 freigegeben.

**Alternativen verworfen:** Bildschirme über die öffentliche Tür exportieren
— verstößt gegen Kapitel 18.1 und die eingefrorene Tür aus 7.4.
`src/`-Import in der App-Hülle — verstößt gegen AT-09 (so zunächst versucht,
von AT-09 zu Recht abgelehnt). 8.8 „teilweise" abschließen (App startet ohne
Bildschirme) — verfehlt das Fertig-Kriterium von 8.8 („Core-Flows sind
erreichbar").

## 2026-09-30 — Schritt 8.8: `apps/unsalted_app/pubspec.yaml` ergänzt

**Betroffenes Kapitel:** 21, Arbeitskarte 8.8 (Dateiscope: `lib/main.dart`
plus App-Testdatei).

**Entscheidung:** `pubspec.yaml` der App um `unsalted_core` (Pfad
`../../packages/unsalted_core`), `flutter_riverpod`, `go_router` und
`drift_flutter` ergänzt, dazu `drift` als Dev-Dependency für
`NativeDatabase.memory()` im App-Start-Test. Versionen ausschließlich über
`flutter pub add`. Ohne diese Einträge kompiliert die in §8 geforderte
Verdrahtung nicht; der Dateiscope nennt das Manifest nicht, schließt es aber
auch nicht aus. Vom Projektverantwortlichen vorab freigegeben.

**Umsetzung:** `main.dart` importiert nur `package:unsalted_core/unsalted_core.dart`
(AT-09). Der `GoRouter` bezieht seine Routen ausschließlich aus
`modules.expand((m) => m.routes)`; ein `ShellRoute` der App-Hülle legt eine
`NavigationBar` (Rezepte `/`, Lebensmittel `/foods`, Einstellungen
`/settings`) um alle Modulrouten. Datenbank über
`CoreDatabase(driftDatabase(name: 'unsalted'))` — `driftDatabase` liefert
eine `DatabaseConnection`, die `QueryExecutor` implementiert (im Pub-Cache
von drift_flutter 0.3.1/drift 2.35.0 verifiziert).

## 2026-09-30 — Nachtrag 8.8a: Navigation zwischen den Core-Bildschirmen geschlossen

**Betroffenes Kapitel:** 22 (Bildschirm 1, 4, 7), Arbeitskarte 9.2 §8.

**Befund:** Die Rezeptliste öffnete kein Rezept (`ListTile` ohne `onTap`),
das Rezeptdetail hatte keinen Weg zum Editor oder zur Versionsliste, und die
Versionsliste (und damit der Vergleich) wurde von keinem Bildschirm geöffnet.
Der Ablauf aus 9.2 §8 („einfrieren → Draft kopieren → ändern → vergleichen")
war damit in der App unmöglich.

**Entscheidung:** `recipe_list_screen.dart`: `onTap` öffnet
`RecipeDetailScreen(recipeId)`. `recipe_detail_screen.dart`: zwei feste
Core-Aktionen in der AppBar vor den generisch gerenderten `recipeActions`:
„Versionen" → `VersionListScreen(recipeId)`, „Bearbeiten" →
`RecipeEditorScreen(recipeId, versionId der gewählten Version)`. Bei einer
eingefrorenen Version zeigt der Editor seinen vorhandenen Schreibschutz mit
„als neuen Entwurf kopieren". Navigation wie in allen anderen Bildschirmen
per `Navigator.push(MaterialPageRoute)`, nicht per `context.go/push` — die
Widget-Tests pumpen die Bildschirme ohne `GoRouter`. `CoreModule.recipeActions`
bleibt leer (Entscheidung aus 7.2): Die beiden Aktionen gehören fest zu
Bildschirm 4, sie sind kein Erweiterungspunkt. Vom Projektverantwortlichen
als eng begrenzter Nachtrag vor 9.1 freigegeben.

**Alternativen verworfen:** Die beiden Aktionen als `RecipeAction` in
`CoreModule.recipeActions` — widerspricht der Entscheidung aus 7.2.
Navigation über GoRouter-Pfade — würde die bestehenden Widget-Tests ohne
Router brechen und wäre uneinheitlich zu allen übrigen Bildschirmen.

## 2026-09-30 — Nachtrag 1.1a: `tool/check_architecture.dart` repariert

**Betroffenes Kapitel:** 5.1 (Architektur-Prüfwerkzeug), Kapitel 27 Regel 14.

**Befund:** `relativePath` wurde relativ zum Paketordner berechnet
(`lib/src/ui/...`), die Ausnahmen prüften aber auf `src/ui/` bzw.
`src/data/`. Dadurch wurden alle 35 Flutter-/Drift-Importe in
`unsalted_core` fälschlich gemeldet, und das Tool endete immer mit Exit 1.
AT-01–AT-12 waren davon nicht betroffen.

**Entscheidung:** `relativePath` wird relativ zum `lib`-Ordner berechnet
(Meldungen zeigen weiter den vollen Pfad mit `lib/`). `package:flutter/`
ist zusätzlich in `src/module/` erlaubt (Kapitel 27, Regel 14 —
`extension_types.dart` braucht `Widget`/`BuildContext`/`IconData`).
Eine Ausnahme für `src/providers/` war nicht nötig, weil das Tool dort nach
der Korrektur nichts meldet. Ergebnis: Exit 0. Gegenprobe: ein temporär
eingefügter `package:flutter`-Import in `lib/src/nutrition/` wurde gemeldet
(Exit 1) und danach wieder entfernt. Vom Projektverantwortlichen als eng
begrenzter Nachtrag vor 9.1 freigegeben.

## 2026-10-01 — Nachtrag 0.1a: CI über GitHub Actions

**Betroffenes Kapitel:** 4/5 (Projektgrundlage, Architektur-Prüfwerkzeug).

**Entscheidung:** `.github/workflows/ci.yml` läuft bei jedem Push und Pull
Request auf `main` auf `ubuntu-latest` und führt aus:
`dart run tool/check_architecture.dart` (Projektstamm), danach in
`packages/unsalted_core` und `apps/unsalted_app` jeweils `flutter pub get`,
`flutter analyze`, `flutter test`. Flutter wird über
`subosito/flutter-action@v2` auf stable **3.47.5** fest eingetragen (die
lokal laufende Version); SDK und Pub-Cache werden über `cache`/`pub-cache`
der Action gecacht. Bei einem lokalen Flutter-Upgrade muss die Version in
`ci.yml` mitgezogen werden. Kein Produktionscode geändert. SQLite kommt auf
dem Runner über die Build-Hooks von `sqlite3` 3.x, kein `apt install` nötig.
Vom Projektverantwortlichen als Nachtrag freigegeben.

## 2026-10-05 — Fehlerbehebung 9.1a: Draft-Kopie und Diff/Apply (F1–F5)

**Anlass:** Die Integrationstests aus Schritt 9.1 (IT-06 und die Edge Cases
DA/SI in `test/integration/`) waren gegen den Produktionscode rot. Vom
Projektverantwortlichen als Fehlerbehebungskarte 9.1a freigegeben; Tests und
Fix liegen in einem Commit, damit die CI nie rot ist.

### Spezifikationslücke 12.4 / Variant-ID im Format (F1, ursprünglich Schritt 6.3)

Kapitel 12.4 verlangt, beim Kopieren eines Snapshots Zutaten aus
`snapshotJson` zu lesen; das Format (13.1) führt aber keine Variant-ID, und
nirgends war geregelt, wie die Verknüpfung wiederhergestellt wird. Die
bisherige Umsetzung (`foodVariantId: null`) war eine undokumentierte
Entscheidung und hat die Nährwerte jeder Kopie zerstört (Milch in ml und
Ei in Stück wurden nicht mehr berechenbar, Barcode und Marke fehlten im
nächsten Snapshot). **Klarstellung:** Der Inhalt kommt weiterhin aus dem
JSON; die `foodVariantId` kommt aus der Zeile derselben Snapshot-Version an
gleicher Position (Kapitel 10.8: diese Zeilen bleiben unverändert und sind
beim Einfrieren bzw. Import, 13.6 Punkt 7, verknüpft angelegt). Übernommen
wird sie nur, wenn Name, Menge (Decimal-Wert) und Einheit der Zeile mit dem
JSON übereinstimmen, sonst `null` (`lib/src/recipe/snapshot_row_match.dart`,
nicht über die Tür exportiert). Die Variant-ID kommt bewusst **nicht** ins
Format: Sie wäre geräte-lokal, und das Format bleibt unverändert (25.2 würde
ein optionales Feld erlauben, ist hier aber nicht gewollt). Tests: RP-22,
RP-23, IT-06, DA-2, SI-6.

### F2 — `MoveIngredient` auch neben Add/Remove (ursprünglich Schritt 4.2)

`RecipeDiff` erzeugte Verschiebungen nur, wenn weder hinzugefügt noch
entfernt wurde. Kapitel 15.4 und DF-13 verlangen sie aber auch daneben. Jetzt
werden sie auf der virtuellen Liste berechnet: zugeordnete Zutaten in
a-Reihenfolge, nach allen Remove (absteigend) und Add (aufsteigend an der
b-Position); Ziel ist die vollständige Reihenfolge von b. DF-13 hatte in
Phase 4 keinen Unit-Test; nachgeholt (DF-13, DF-13b). Tests: DA-1, DA-6,
DA-6b.

### F3 — Lebensmittel-Verknüpfung aus einem Diff (Variante V1)

`RecipeDiff.between(a, b, {List<RecipeIngredient>? targetRows})`: Mit den
Zeilen der Zielversion (über `RecipeRepository.getVersion`, bestehender
Vertrag) tragen erzeugte `AddIngredient`/`ReplaceIngredient` die
`foodVariantId` von b, mit derselben Sicherheitsregel wie F1. Ohne
`targetRows` bleibt sie `null` (bisheriges Verhalten). Der
Vergleichsbildschirm lädt die Zeilen und übergibt sie; die angezeigte Liste
ist weiterhin exakt die angewendete (15.5, 8.6 §8), die UI enthält keine
Diff-Logik. **Abweichungen:** Die Signatur weicht additiv vom Text in
Kapitel 15 ab (`RecipeDiff` steht nicht in der Freeze-Liste 25.1, die
Exportliste der Tür bleibt gleich), und `recipe_diff.dart` importiert
zusätzlich `recipe_ingredient` und `snapshot_row_match` (Tabelle 18.1 nennt
nur `recipe_snapshot_v1`/`recipe_change`); beides bleibt reines Dart (AT-03).
`RecipeChange`, Snapshot-Format und Repository-Signaturen sind unverändert.
**Verworfen:** V2 (eigene Funktion `linkVariants` nach `between`) — die
Position von `ReplaceIngredient` ist die a-Position, die Funktion müsste die
Zuordnung aus 15.1/15.2 neu berechnen. V3 (Repository verknüpft beim
Anwenden über den Namen) — reine Heuristik, verknüpft absichtlich
unverknüpfte Zutaten, angezeigte und angewendete Liste fielen auseinander.
UI-seitiges Nachtragen — Diff-Logik in der UI (8.6). Tests: DF-14, DF-15,
UI-08b, DA-5. **Pflicht für Aufrufer:** siehe CLAUDE.md Abschnitt 4.

### F4 + F5 — Zutaten-Identität (15.1) und Variantenvergleich (15.3)

F4: Zuordnung zweistufig, jeweils greedy nach Position (15.2) — erst gleicher,
nicht leerer Barcode, danach normalisierter Name (getrimmt, Kleinschreibung).
Bisher galt nur der Barcode, sobald einer vorhanden war; „Mehl“ ohne Barcode
in a und mit Barcode in b wurde zu Remove+Add. **Bewusste
Verhaltensänderung (bestätigt):** gleicher Name mit verschiedenen Barcodes
ergibt jetzt `ReplaceIngredient` statt Remove+Add.

F5: Kapitel 15.3 verlangt `ReplaceIngredient`, wenn sich die verknüpfte
Variante unterscheidet; `RecipeDiff` verglich nur Name und Marke. Da die
Variante nicht im Format steht, werden ihre eingebetteten Daten verglichen:
`barcode`, `brand`, `per100g` (inklusive `extra`), `densityGPerMl`,
`gramsPerPiece` — alle Zahlen als Decimal-Wert (600 == 600.0), nie als
String. **F4 nur zusammen mit F5:** F4 allein hätte Fälle wie DA-8 von einem
sichtbaren Remove+Add in einen leeren Diff verwandelt, obwohl a und b
unterschiedlich rechnen.

Auswirkung auf bestehende Tests: keine. DF-01 bis DF-12 unverändert grün
(nur DF-06 nutzt Barcodes, auf beiden Seiten denselben), GD-01 bis GD-12
rufen `RecipeDiff` nicht auf, UI-08 hat Testdaten ohne Barcodes. Tests:
DF-16 bis DF-21, DA-7, DA-8.

### Bekannte, spezifikationskonforme Grenze von Teil 1 (E2)

Beim Anwenden eines `ReplaceIngredient` wird die Notiz der Zutat auf `null`
gesetzt, weil `ReplaceIngredient` die Zutat laut Kapitel 14.1 „vollständig
ersetzt“ und kein `note`-Feld trägt. Durch F4/F5 entstehen mehr Ersetzungen,
damit gehen in übernommenen Diffs häufiger Notizen verloren; `RecipeDiff`
kann Notiz-Änderungen grundsätzlich nicht erkennen. Bewusst nicht behoben:
eine Lösung bräuchte ein neues Feld in `RecipeChange` (eingefroren seit 3.2)
oder eine neue `RecipeChange`-Klasse (nach 25.2 additiv möglich, aber
eigene Entscheidung).

### Offener Punkt für den Design-Pass: „Butter → Butter“

Ändert sich bei einer zugeordneten Zutat nur die Verknüpfung (Marke,
Barcode, Nährwerte, Dichte, Stückgewicht), zeigt der Vergleichsbildschirm
ein `ReplaceIngredient` mit identischem Namen auf beiden Seiten. Fachlich
korrekt, aber für Nutzer nicht verständlich. Die Anzeige sollte benennen,
was sich geändert hat (z. B. „Butter: anderes Lebensmittel verknüpft“).
Gehört zum Design-Pass, nicht zu Teil 1.

## 2026-10-05 — Fehlerbehebung 9.1b: Editor behält Lebensmittel-Verknüpfungen (E1)

**Betroffenes Kapitel:** 10.7 (weich gelöschte Lebensmittel), 22 (Bildschirm
3), Testplan 23.6.

**Befund:** Der Rezept-Editor hielt die Verknüpfung einer Zutatenzeile nur
als aufgelöstes Lebensmittel (`variant`). Lieferte `getById` für ein weich
gelöschtes Lebensmittel `null`, ging die Verknüpfung beim Laden verloren und
wurde beim nächsten Speichern als `null` geschrieben — auch für Zeilen, die
der Nutzer nicht angefasst hatte. Kapitel 10.7 sieht dagegen ausdrücklich
vor, dass eine Zeile auf ein gelöschtes Lebensmittel zeigen darf und nur wie
unverknüpft gerechnet wird.

**Entscheidung:** `IngredientRowData` führt die gespeicherte Verknüpfung
(`foodVariantId`) getrennt vom aufgelösten Lebensmittel (`variant`).
Gespeichert wird `foodVariantId`; Vorschau und Anzeige nutzen `variant`, ein
gelöschtes Lebensmittel rechnet also wie unverknüpft (10.7). Die Verknüpfung
ändert sich ausschließlich durch eine Lebensmittel-Auswahl (setzt sie neu)
oder eine Namensänderung (löst sie, bestehendes Verhalten). Änderungen an
Menge, Einheit, Notiz und Position derselben Zeile lassen sie unverändert.
Zeilen mit gelöschtem Lebensmittel zeigen den Hinweis „Verknüpftes
Lebensmittel wurde gelöscht – bitte neu auswählen.“; Farbe und Stil kommen
ausschließlich aus `Theme.of(context)` (`textTheme.bodySmall`,
`colorScheme.error`), kein `Colors.*` (Vorbereitung Design-Pass). Keine
Methode, die gelöschte Lebensmittel liefert (10.7 „Sichtbarkeit“); keine
Änderung an Daten-, Vertrags- oder Rechenschicht.

**Neue Test-IDs (Erweiterung von Kapitel 23.6, `docs/spezifikation.md`
bewusst unverändert):** UI-11 andere Zeile geändert → Verknüpfung zum
gelöschten Lebensmittel bleibt · UI-12 Menge, Einheit, Notiz und Position
derselben Zeile geändert → Verknüpfung bleibt · UI-13 Namensänderung löst die
Verknüpfung · UI-14 Auswahl eines anderen Lebensmittels ersetzt sie · UI-15
Hinweis erscheint, Vorschau rechnet die Zeile wie unverknüpft. Dazu ein
Unit-Test für `IngredientRowData` in `ingredient_row_test.dart`. Vom
Projektverantwortlichen als Karte 9.1b freigegeben.

## 2026-10-05 — Fehlerbehebung 9.2a: Timer, Vergleichstexte, Master, Mengenrechner

**Anlass:** Manueller Durchlauf 9.2 durch den Projektverantwortlichen —
Schritte A–G bestanden, vier Befunde. Umsetzung ausschließlich in
`lib/src/ui/` plus Tests und Doku; keine Änderung an `contracts/`, `data/`,
`recipe/`, `nutrition/`, `module/`, Snapshot-Format, Datenbank oder Tür.

### Befund 1 — Schritt-Timer nicht eingebbar (Spezifikationslücke Kapitel 22, Bildschirm 3)

Kapitel 22 beschreibt für Bildschirm 3 nur Zutatenzeilen; ein Eingabefeld für
`RecipeStep.timerSeconds` (Kapitel 10.5) fehlt, obwohl Bildschirm 4
Timer-Chips zeigen soll. `timerSeconds` wurde geladen und gespeichert, war
aber nicht editierbar. **Entscheidung:** Pro Schritt ein optionales Feld
„Timer (Min.)“. Ganze Minuten > 0 ergeben `timerSeconds = Minuten × 60`, ein
leeres Feld ergibt `null`; 0, negative Werte, Nachkommastellen und
Nicht-Zahlen markieren das Feld („Ganze Minuten > 0“, Fehlerfarbe aus dem
Theme) und sperren „Speichern“. Ein geladener Wert wird nur durch eine
Eingabe überschrieben: Er erscheint als Minuten („10“) bzw. als m:ss, wenn
er keine ganzen Minuten ergibt (importierte 90 s → „1:30“), und bleibt
sekundengenau erhalten, solange der Feldinhalt dem Ausgangstext entspricht —
auch nach Bearbeiten und Zurücktippen. Nur `int.tryParse`, keine
Gleitkommazahlen (AT-07).

### Befund 2 — Vergleichstexte unverständlich

Die Texte der Änderungsliste (Bildschirm 8) nannten Positionen statt
Zutaten. **Entscheidung:** Neue Datei
`lib/src/ui/versions/change_descriptions.dart` (`describeChanges`) erzeugt
die Texte, indem sie die Änderungsliste nur für die Anzeige der Reihe nach
auf eine Namens-/Mengenliste aus Version A anwendet (Positionen beziehen sich
auf den Stand unmittelbar davor, Kapitel 14.4). Die Änderungsliste selbst
bleibt exakt unverändert und wird so übernommen (8.6, 15.5); es gibt keine
eigene Diff-Logik. Beispiele: „Milch: 500 ml → 400 ml“, „Butter entfernt“,
„Ei hinzugefügt (3 Stück)“, „Butter ersetzt durch Margarine“, „Mehl
verschoben (Position 1 → 3)“, „Schritt 2 geändert: …“ (bei Timer-Änderung
„Timer 10:00 → 8:00“), Parameter mit alt → neu. Ersetzen bei gleichem Namen
(nur die Verknüpfung ändert sich, offener Punkt „Butter → Butter“ aus 9.1a):
„Butter: anderes Lebensmittel verknüpft“, bei geänderter Menge zusätzlich
„(alt → neu)“. Zahlen erscheinen ungerundet als Decimal-Ausgabe (Rundung nur
im `NutritionFormatter`). Einheiten: g/kg/ml/l als Kurzzeichen, alle anderen
mit dem Namen aus `UnitCatalog` („Stück“, „Prise“, „Esslöffel“ …).
Anweisungen werden am letzten Wortende vor 40 Zeichen gekürzt („…“).

**Bestehender Test geändert (vom Projektverantwortlichen freigegeben):** UI-08
prüfte wörtlich die alten Texte. Geändert wurden ausschließlich die zwei
Text-Erwartungen in `test/ui/versions/version_compare_screen_test.dart`
(„Menge an Position 1 geändert“ → „Mehl: 100 g → 200 g“, „Zutat "Salz"
hinzugefügt“ → „Salz hinzugefügt (5 g)“); Testdaten, Gruppenüberschrift und
alle übrigen Assertions sind unverändert.

### Befund 3 — Master-Version nicht setzbar (Spezifikationslücke Kapitel 22, Bildschirm 7)

`setMasterVersion` existiert (Kapitel 16.1), wurde aber von keinem Bildschirm
aufgerufen; Kapitel 22 nennt für Bildschirm 7 nur „Kopie als Entwurf,
Vergleichen, Löschen“, obwohl Kapitel 12.1 eine „vom Nutzer gekürte“
Master-Version vorsieht. **Entscheidung:** Aktion „Als Master markieren“ nur
bei eingefrorenen Versionen, die nicht schon Master sind. Der Stern erscheint
sofort (über `watchRecipe`), Farbe aus `colorScheme.primary` statt
`Colors.amber`. Ein `IllegalStateException` erscheint als Klartext-SnackBar;
das Löschen der Master-Version zeigt die bestehende Meldung des Repositorys
(RP-18).

### Befund 4 — Mengenrechner nicht eingebaut

`AmountCalculator` (Schritt 8.4, Bildschirm 6) war gebaut und getestet, wurde
aber nirgends verwendet. **Entscheidung:** Eingebaut im Rezeptdetail direkt
unter der Nährwerttabelle, mit demselben `NutritionResult` wie die Tabelle
(bei Snapshots also aus `snapshotJson`). `ValueKey(version.id)` setzt den
Rechner beim Versionswechsel zurück, damit keine Werte der vorherigen Version
stehen bleiben.

### Neue Test-IDs (Erweiterung von Kapitel 23.6, `docs/spezifikation.md` bewusst unverändert)

UI-16 Timer setzen · UI-17 Timer ändern · UI-18 Timer leeren · UI-19
ungültiger Timer markiert das Feld und sperrt Speichern · UI-20 unangefasster
Sekundenwert bleibt erhalten · UI-21 Timer-Chip im Rezeptdetail · UI-22
Zutaten-Texte (inkl. UI-22b Ersetzen mit Mengenänderung) · UI-23
Schritt-Texte · UI-24 Parameter-Texte · UI-25 Remove + Move, Name nur über
sequenzielle Anwendung korrekt · UI-26 „Als Master markieren“ nur bei
Snapshots, Stern erscheint sofort · UI-27 Löschen der Master-Version wird
abgelehnt · UI-28 Mengenrechner unter der Tabelle, Gramm ↔ kcal gekoppelt,
auch für Snapshots.

## 2026-10-05 — Spike 20.1: mehrere Drift-Datenbankklassen auf einer Datenbank (Schritt 9.3)

**Fragestellung (Kapitel 20.1):** Können mehrere Drift-Datenbankklassen (eine
je Paket) dieselbe Datenbankdatei bzw. denselben `QueryExecutor` nutzen, wie
Teil 3 es braucht?

**Aufbau:** `packages/unsalted_core/test/spike/` (nur Testcode, Teil 1
unverändert). Paket 1 = die echte `CoreDatabase` (schemaVersion 1). Paket 2 =
`SpikeDatabase` (Tabelle `spike_notes`, einstellbare schemaVersion,
protokolliert ausgeführte Migrationen). Variante C = `SpikeCombinedDatabase`
mit allen fünf Core-Tabellen plus `spike_notes`. Jeder Test nutzt eine echte
temporäre Datei unter `Directory.systemTemp` (wird gelöscht), keine
In-Memory-DB. 16 Tests, Laufzeit unter 1 s, dreimal in Folge stabil grün.
Einzige Wartezeit: 200 ms Timeout in A5/C5b, um einen Deadlock nachzuweisen
statt zu hängen.

- **A:** beide Klassen auf derselben `NativeDatabase`-Instanz (zusätzlich gemessen: dieselbe `DatabaseConnection`-Instanz).
- **B:** jede Klasse mit eigener `NativeDatabase` auf dieselbe Datei.
- **C:** eine gemeinsame Klasse mit allen Tabellen; dazu „C mit Teil 1“: `CoreDatabase` auf derselben `DatabaseConnection` wie die gemeinsame Klasse, damit die Teil-1-Repositories unverändert laufen.

**Ergebnis:**

| Punkt | A: ein Executor | B: eigene Verbindung je Klasse | C: gemeinsame Klasse |
|---|---|---|---|
| 1 Anlegen | Nur die zuerst öffnende Klasse migriert. Öffnet Core zuerst, fehlt `spike_notes`; öffnet Paket 2 zuerst, fehlen alle Core-Tabellen (A1). Paket 2 muss seine Tabellen selbst anlegen (`createMigrator().createTable`). | Gleiche Versionsnummer: Paket 2 migriert nicht, `spike_notes` fehlt (B1). Höhere Version: `onCreate` von Paket 2 läuft nie (B2). | Eine Migration legt alle Tabellen an (C1). |
| 2 Schema-Version | `user_version` gehört der zuerst öffnenden Klasse; die Migrationen der anderen laufen nie (A1, beide Reihenfolgen). | Gemeinsames `PRAGMA user_version`: Paket 2 (v2) hält Cores v1 für seine eigene Vorgängerversion (`onUpgrade 1→2`) und setzt v2. Beim nächsten Start sieht Core v2, ruft `onUpgrade(2→1)` und scheitert an der Standard-Strategie — **Core lässt sich nicht mehr öffnen** (B2). | Eine Version für die ganze Datei (C1). |
| 3 Lesen/Schreiben | Funktioniert über beide Klassen (A3). | Funktioniert, wenn nacheinander geschrieben wird (B3). | Funktioniert (C3, „C mit Teil 1“). |
| 4 Live-Streams | Rohe Executor-Instanz: nein, jede Klasse hat ihren eigenen Stream-Store (A4). Geteilte `DatabaseConnection`: ja (A4b). | Nein (B4); bestätigt durch die Drift-Doku. | Ja, innerhalb der Klasse und über eine geteilte `DatabaseConnection` auch für `CoreDatabase` („C mit Teil 1“). |
| 5 Transaktion über beide Klassen | Nicht möglich: Die zweite Klasse erkennt die Transaktion nicht und wartet auf den Executor, den die Transaktion hält — Deadlock. Nach dem Abbruch läuft ihr Schreiben außerhalb, also nicht atomar (A5). | Nicht möglich: „database is locked“ (SQLite-Code 5), Transaktion zurückgerollt (B5). | Atomar, solange alles über die gemeinsame Klasse läuft (C5). Ein Teil-1-Repository innerhalb ihrer Transaktion blockiert wie in A (C5b). |
| 6 Gleichzeitiges Schreiben | Funktioniert, der gemeinsame Executor serialisiert (A6). | Scheitert: Neben einer Teil-1-Transaktion (Repositories schreiben immer transaktional) bekommt die zweite Verbindung sofort „database is locked“; in der Messung 14 von 20 Schreibversuchen (B6). Drift setzt kein `busy_timeout`; mit synchronen Verbindungen im selben Isolate würde ein Timeout nur blockieren. | Funktioniert (C6). |
| 7 Schließen | Schließt den Executor für beide; danach schlägt jede Abfrage der anderen Klasse fehl (A7). | Unabhängig (B7). | Schließen der gemeinsamen Verbindung schließt sie für alle Klassen darauf (C7). |

**Urteil:**
- **A: eingeschränkt.** Funktioniert nur unter vier Bedingungen: (a) genau eine Klasse besitzt Schema und Migrationen für alle Tabellen und öffnet zuerst, (b) alle Klassen teilen dieselbe `DatabaseConnection`-Instanz (nicht nur den Executor), (c) keine Transaktion umfasst Schreibzugriffe mehrerer Klassen, (d) nur der Eigentümer schließt die Verbindung.
- **B: nicht unterstützt.** Das gemeinsame `user_version` macht unabhängige Migrationen unmöglich und kann Teil 1 dauerhaft aussperren; dazu gesperrte Schreibzugriffe und keine Stream-Synchronisierung.
- **C: unterstützt.** Bedingung wie in A: Klassenübergreifende atomare Transaktionen laufen ausschließlich über die gemeinsame Klasse.

**Empfehlung für Teil 3: C, kombiniert mit der geteilten Verbindung aus A** (so gemessen in „C mit Teil 1“):
1. Die App-Hülle erzeugt **eine** `DatabaseConnection` und **eine** gemeinsame Datenbankklasse, die die Tabellen aller Pakete auflistet. Sie allein besitzt `schemaVersion`, `user_version` und alle Migrationen.
2. Die gemeinsame Klasse wird **vor** jeder anderen Klasse geöffnet. Öffnet `CoreDatabase` zuerst, legt sie nur ihre eigenen Tabellen an (Mechanismus aus A1).
3. `CoreDatabase` (und jede Paketklasse) wird auf **derselben** `DatabaseConnection` erzeugt und über `coreDatabaseProvider.overrideWithValue(...)` bereitgestellt. Teil 1 bleibt unverändert (Kapitel 20.1); Streams sind geteilt.
4. Schreibzugriffe, die paketübergreifend atomar sein müssen (z. B. Sync-Merge), laufen vollständig über die gemeinsame Klasse, nie über Teil-1-Repositories innerhalb ihrer Transaktion (C5b).
5. Folge: Künftige Schema-Änderungen von Teil 1 (CoreDatabase v2 …) müssen als Migrationsschritte in die gemeinsame Klasse übernommen werden; `CoreDatabase.schemaVersion` und `CoreDatabase.migration` sind in dieser Aufstellung inaktiv.

**Versionen:** drift 2.35.0, drift_dev 2.35.0, build_runner 2.16.1, sqlite3 (Dart-Paket) 3.6.0, SQLite 3.53.4, Flutter 3.47.5 / Dart 3.13.4.

**Quellen:**
- Drift-Doku „Isolates“, https://drift.simonbinder.eu/isolates/ — „You can open two independent drift databases … but then stream queries won't synchronize between those independent instances“; `DatabaseConnection.delayed` synchronisiert auch Stream-Abfragen, `LazyDatabase` teilt nur den Executor.
- Drift-API `DatabaseConnection`, https://pub.dev/documentation/drift/latest/drift/DatabaseConnection-class.html — eine Verbindung besteht aus `QueryExecutor` und `StreamQueryStore`.
- Drift-FAQ, https://drift.simonbinder.eu/faq/#using-the-database — eine Instanz je Datenbankklasse.
- Quelltext drift 2.35.0 (die Migrationsseite der Doku beschreibt den `user_version`-Mechanismus nicht, daher maßgeblich): `lib/src/runtime/executor/helpers/engines.dart` (`DelegatedDatabase.ensureOpen`: ist der Executor schon offen, laufen keine Migrationen; `_runMigrations` vergleicht `user_version` mit dem `schemaVersion` der öffnenden Klasse; `close` schließt für alle), `lib/src/runtime/api/connection_user.dart` (Konstruktor übernimmt eine übergebene `DatabaseConnection` samt Stream-Store; `resolvedEngine` nutzt den Transaktions-Executor nur bei gleicher `attachedDatabase`), `lib/src/runtime/api/db_base.dart` (Mehrfach-Warnung „race conditions“ nur je `runtimeType`; `beforeOpen` ruft `onUpgrade` auch bei sinkender Version), `lib/src/runtime/query_builder/migration.dart` (Standard-`onUpgrade` wirft eine Exception). Kein `busy_timeout` im Drift-Quelltext.

**Nebenbefund Werkzeug:** `dart run build_runner build --build-filter="test/spike/**"` hat bei einem zweiten Lauf drei generierte Produktionsdateien gelöscht (`core_database.g.dart`, `drift_food_dao.g.dart`, `drift_recipe_dao.g.dart`). Sie wurden unverändert aus Git wiederhergestellt; `lib/` ist identisch mit dem vorherigen Commit. Siehe CLAUDE.md Abschnitt 4.

## 2026-10-05 — Nachtrag 10.0: PopScope im Lebensmittel-Editor

**Betroffenes Kapitel:** 22 (allgemeine Bildschirmregel „Abbrechen mit
ungespeicherten Änderungen fragt vor Verwerfen nach“), Bildschirm 10.

**Befund:** Seit Schritt 8.1 fehlte im Lebensmittel-Editor die Abfrage vor
dem Verwerfen (in Schritt 8.2 für `recipe_create_screen.dart` nachgeholt,
für `food_editor_screen.dart` als offene Lücke geführt).

**Entscheidung:** `food_editor_screen.dart` bekommt dasselbe Muster wie
`recipe_create_screen.dart`: `PopScope(canPop: …)` mit Dialog „Änderungen
verwerfen?“, und nach dem Speichern bzw. Verwerfen wird erst der Frame mit
gelöster Sperre gebaut und dann per `addPostFrameCallback` geschlossen
(CLAUDE.md Abschnitt 4). Als „ungespeicherte Änderung“ gilt jede Abweichung
eines Feldtextes vom Ausgangszustand. Dafür bekommt `PackageFormState` einen
lesenden Getter `hasChanges` (vergleicht die Texte aller Felder mit den beim
Öffnen geladenen). **Scope-Erweiterung um `package_form.dart`, vom
Projektverantwortlichen freigegeben:** `PackageForm` gab die Feldtexte nicht
heraus; `value` ist `null`, solange der Name fehlt (Eingaben nur bei Marke
oder kcal wären unbemerkt verworfen worden), und `onChanged` feuert auch bei
reinen Cursor-/Auswahländerungen (bloßes Antippen eines Feldes hätte eine
Abfrage ausgelöst). Keine neuen Farben; die bestehenden `Colors.*` der Datei
bleiben (Design-Pass).

**Neue Test-IDs (Erweiterung von Kapitel 23.6):** UI-29 ohne Änderung (nur
Feld angetippt) schließt Zurück ohne Nachfrage · UI-30 Eingabe ohne Namen
fragt nach, „Abbrechen“ bleibt, „Verwerfen“ schließt ohne Speichern · UI-31
Speichern nach Änderung schließt ohne Nachfrage · UI-32 auf den
Ausgangswert zurückgesetzter Text gilt nicht als Änderung.

## 2026-10-05 — Nachtrag 10.1b: SnapshotCodec sortiert Schlüssel nach 13.4

**Betroffenes Kapitel:** 13.1, 13.4 (Snapshot-Format), 23.3 (GD-Tests).

**Befund (bei der Arbeit an Befund B1 der Freeze-Abnahme):** Kapitel 13.1
nennt das JSON-Beispiel ausdrücklich „strukturell“ und erklärt 13.4 für
normativ; 13.4 verlangt: „In jedem JSON-Objekt werden die Schlüssel in
alphabetisch aufsteigender Reihenfolge erzeugt.“ `SnapshotCodec.encode`
erzeugte die Schlüssel dagegen in der Reihenfolge des Beispiels (`format`,
`format_version`, `recipe`, `version`, … ; `recipe`: `id`, `title`,
`description`). Die Golden-Dateien folgten derselben Reihenfolge, deshalb
fiel es nicht auf. Deterministisch war die Ausgabe trotzdem.

**Entscheidung (vom Projektverantwortlichen freigegeben):**
`SnapshotCodec.encode` sortiert die Schlüssel jedes Objekts rekursiv
alphabetisch (Code-Unit-Reihenfolge), auch in verschachtelten Objekten
(`recipe`, `version`, `nutrition`, `per100g`, `total`, `extra` …). Listen
(`ingredients`, `steps`, `incomplete`, `not_calculable`) behalten ihre
Reihenfolge. Keine Änderung an Struktur, Typen oder Werten des Formats
(Freeze 4.1 bleibt gewahrt), `decode` ist unverändert und war schon
reihenfolgeunabhängig.

**Bestehende Daten:** Snapshots, die vor 10.1b gespeichert wurden, behalten
ihre alte Schlüsselreihenfolge in `snapshot_json` und bleiben gültig:
`decode` liest jede Reihenfolge, und `exportVersionAsJsonString` liefert den
gespeicherten String unverändert (13.7). Neu eingefrorene oder per
`importSnapshot` importierte Snapshots werden kanonisch gespeichert;
`importJsonString` speichert weiterhin den eingelesenen Originaltext (13.6,
GD-12 unverändert grün).

**Golden-Dateien:** `gd01_minimal.json` bis `gd04_extra.json` inhaltlich
unverändert alphabetisch umsortiert. Nachweis: alte Fassung (aus Git) und
neue Fassung als JSON geparst und auf tiefe Gleichheit geprüft — bei allen
vier gleich. Vorher waren 7/12/8/8 Objekte je Datei unsortiert, nachher 0.
Einrückung (zwei Leerzeichen) und fehlender Schluss-Zeilenumbruch bleiben.

**Tests:** Neuer GD-13 (Erweiterung von 23.3) prüft für jedes Objekt eines
kodierten Snapshots — direkt aus `encode` und nach `jsonEncode`/`jsonDecode`
wie gespeichert —, dass die Schlüssel alphabetisch sortiert sind (über 70
Objekte). Gegenprobe: Mit dem alten Codec werden GD-13 und GD-01 bis GD-04
rot.

## 2026-10-05 — Nachtrag 10.1a: Befunde B1 bis B4 aus der Freeze-Abnahme

### B1 — GD-05 prüft jetzt Kapitel 23.3 wörtlich

**Befund:** GD-05 kodierte dasselbe dekodierte Objekt zweimal und verglich
nur die beiden Ausgaben (Determinismus); 23.3 verlangt „Decodieren +
erneutes Encodieren ergibt byteweise identisches JSON“. Der Kopfkommentar
von `golden_test.dart` beschrieb das unzutreffend.

**Entscheidung (freigegeben):** GD-05 prüft für jede Golden-Datei:
`jsonEncode(SnapshotCodec.encode(SnapshotCodec.decode(jsonDecode(datei))))`
ist byteweise gleich `jsonEncode(jsonDecode(datei))`. Verglichen wird in der
Betriebsform (kompakt, 13.4), die Dateien bleiben eingerückt und lesbar. Der
bisherige Determinismus-Test bleibt als GD-05b. Voraussetzung war Nachtrag
10.1b (alphabetische Schlüssel). Gegenprobe: eine geänderte Wertdarstellung
(„0“ → „0.0“) in einer Golden-Datei macht GD-05 rot.

### B3 — Tests für `RecipeStep` (Testvertrag 18.1)

**Befund:** Laut Dateivertrag 18.1 deckt `test/recipe/recipe_ingredient_test.dart`
auch `recipe_step.dart` ab; `RecipeStep` war seit Schritt 3.1 ungetestet.

**Entscheidung (freigegeben):** Eine Gruppe `RecipeStep` in dieser Datei
prüft Konstruktion, das optionale `timerSeconds`, Gleichheit und
`hashCode` über alle fünf Felder, `copyWith` (einschließlich „Timer nicht
ändern“ gegenüber „Timer auf null setzen“) und `toString`. Keine
Produktionsänderung.

### B2 — AT-12 nimmt `test/architecture/` aus

**Betroffenes Kapitel:** 5.2 (AT-12), 25 („Kein Vorkommen von "kJ" in lib/
und test/“).

**Befund:** Kapitel 5.2 und 25 verlangen das Fehlen der Zeichenfolge in
`lib/` und `test/` ohne Ausnahme. `test/architecture/at12_no_kj_text_test.dart`
nimmt seit Phase 1 den Ordner `test/architecture/` aus; das stand bisher nur
im Testcode.

**Entscheidung:** Die Ausnahme bleibt und wird hiermit festgehalten. Ein
Prüfwerkzeug, das nach der Zeichenfolge sucht, muss sie selbst enthalten
(Testname, Kommentar, Suchmuster); das ist kein Verstoß gegen R7. Alle
übrigen Testdateien bauen den Suchbegriff zur Laufzeit aus Zeichencodes
zusammen (CLAUDE.md Abschnitt 4). In `lib/` gilt das Verbot ohne Ausnahme.
Übernahme als Klarstellung in Kapitel 28.

### B4 — Testorte weichen von Kapitel 23.3/23.5 ab

**Betroffenes Kapitel:** 23.3 (GD-11, GD-12 unter `test/contract/`), 23.5
(IT-01 bis IT-06 unter `test/integration/`).

**Befund:** GD-11 und GD-12 liegen in `test/data/snapshot_service_test.dart`,
weil sie den `DriftSnapshotService` (Schritt 6.6) gegen eine Datenbank prüfen
und nicht den reinen Codec. IT-01 bis IT-05 wurden in Schritt 6.5/6.6 bereits
auf Service-Ebene in `test/data/` umgesetzt und existieren seit Schritt 9.1
zusätzlich als Systemketten-Tests in `test/integration/`.

**Entscheidung:** Beide Orte bleiben. Maßgeblich für die Freeze-Abnahme sind
die Tests in `test/integration/` (IT-01 bis IT-06) bzw. in
`test/data/snapshot_service_test.dart` (GD-11, GD-12); die Service-Varianten
von IT-01 bis IT-05 in `test/data/` sind zusätzliche Absicherung. Kein
Verschieben, weil sich dadurch nur Pfade, nicht die Prüfung ändern würden.
Übernahme als Klarstellung in Kapitel 28.

## 2026-10-05 — Schritt 10.2: API-Dokumentation

**Betroffenes Kapitel:** 18, 25 („Öffentliche API dokumentiert, dart doc ohne
Warnung“), Arbeitskarte 10.2.

**Vorgehen:** `dart doc` meldet fehlende Kommentare nicht. Die Lücken wurden
deshalb mit vorübergehend aktiviertem Lint `public_member_api_docs` ermittelt
(nicht committet, `analysis_options.yaml` danach unverändert) und auf das
gefiltert, was `lib/unsalted_core.dart` exportiert — bei `show`-Exporten nur
die genannte Deklaration mit ihren Mitgliedern (`RecipeSnapshotV1`,
`UnitCatalog`, `CoreDatabase`, die sieben exportierten Provider).
Überschriebene Mitglieder (`==`, `hashCode`, `toString`, Implementierungen
von Interface-Gettern) erben ihre Doku und zählen nicht.

**Ergebnis:** 280 Lücken vorher, 0 nachher, in 21 Dateien. Ausschließlich
`///`-Kommentare hinzugefügt; jeder beschreibt bestehendes Verhalten (am Code
geprüft, z. B. welche Methode welches Event mit welcher `versionId` auslöst)
und verweist auf das Kapitel der Spezifikation. `dart doc --dry-run`: 0
Warnungen, 0 Fehler. Die verbotene Energieeinheit kommt in keinem Kommentar
vor (AT-12).

**Einzige Formatierungsänderung (freigegeben):** Die einzeiligen Enums
`FoodChangeKind` und `RecipeActionPlacement` wurden umgebrochen, damit jeder
Wert einen eigenen Kommentar bekommt. Per Tokenvergleich geprüft: keine
Code-Änderung, auch kein zusätzliches Komma.

**Beobachtung, nicht behoben:** Einige bereits vorhandene `///`-Kommentare
verweisen auf Kapitelnummern einer älteren Berichtsfassung (z. B.
`NutritionResult.perServing` „Kapitel 13.2“, `UnitCatalog` „Kapitel 21.1“,
`NutrientSet` „Kapitel 5.1“). Laut Arbeitskarte wurden nur fehlende
Kommentare ergänzt, bestehende nicht geändert. Korrektur wäre ein eigener
kleiner Nachtrag.

## 2026-10-05 — Nachtrag 10.2a: AT-05 erzwingt 28.1.3, Kapitelverweise korrigiert

**a) AT-05.** `src/providers/` darf weiterhin aus `src/data/` importieren
(Verdrahtung, Kapitel 16.7), aber `package:drift` ist dort jetzt verboten —
AT-05 prüft den Drift-Import für alle Dateien außer `src/data/`, die
Ausnahme für `src/providers/` gilt nur noch für Importe aus `data/`. Damit
wird Kapitel 28.1.3 durch einen Test erzwungen. Gegenprobe: ein temporär
eingefügtes `import 'package:drift/drift.dart';` in `core_providers.dart`
macht AT-05 rot; danach wieder entfernt.

**b) Kapitelverweise.** 151 bestehende `///`-Zeilen in `lib/` mit
Kapitelverweis geprüft. Veraltet waren nur Verweise in `src/nutrition/` aus
Phase 2, geschrieben gegen die ältere Berichtsfassung (dort Nährwertgrundlagen
in Kapitel 5, Rechenkern in 13, Einheiten in 6, Datei-Plan in 14, Freeze in
21; heute zusammengeführt in Kapitel 8 bzw. 9, 18, 25). Jeder Verweis wurde
anhand des Inhalts dem Unterkapitel zugeordnet, in dem die Aussage heute
steht; 17 Verweise in 6 Dateien ersetzt, nur Kommentarzeilen:

- `nutrient_set.dart`: 5.1 → 8.1 (zweimal), 5.2 → 8.3 (zweimal), 13.1 → 8.3
  (`incomplete` ist nur in 8.3 definiert), „4.1, 9“ → „7.4, 13.2“ (Decimal
  als JSON-String, `null` als JSON-`null`).
- `nutrition_result.dart`: 13.2 Randfall-Tabelle → 8.5, „5.2 / 13.1“ → 8.3,
  6 → 9, 13.2 (`forAmount`- und `gramsForKcal`-Formel) → 8.4 (zweimal).
- `nutrition_engine.dart`: 14 (Datei-Vertrag) → 18.1.
- `nutrient_validator.dart`: 13.3 → 8.6. `decimal_math.dart`: 13.4 → 8.6.
- `unit_catalog.dart`: 6 → 9 (zweimal), 21.1 → 25.1.

**Unklar, nicht geändert:**
- `nutrition/nutrition_engine.dart:39` „freie Zutat ohne Nährwerte,
  Kapitel 7.4“ — heute passend sind 8.5 (Randfall „Zutat ohne verknüpfte
  FoodVariant“), 10.5 und 11.4 (`foodVariantId` nullable); keine eindeutige
  Zuordnung.
- `data/tables/recipe_ingredients.dart:26` „1-basiert, lückenlos innerhalb
  einer Version (Kapitel 10.10)“ — 10.10 regelt heute Zeitstempel; passend
  wären 10.7 (Positionen nach `saveDraft`) oder 11.4 (Spalte `position`).

**Beobachtung, nicht geändert (Inhalt statt Nummer):** Die Kopfkommentare von
`data/tables/recipe_ingredients.dart` und `data/tables/recipe_steps.dart`
beschreiben `deleted_at` als „ohne eigenen Schreibpfad“ und `saveDraft` als
„Hart-Löschen + Neu-Einfügen“. Seit der aktuellen Spezifikation (Kapitel
10.7) schreibt `saveDraft` per Upsert-/Soft-Delete-Delta `deleted_at`. Normale
`//`-Kommentare mit alten Nummern wurden nicht angefasst (Auftrag: nur
`///`).

## 2026-10-05 — Teil 1.1a: Kein Flackern beim Versionswechsel

Fehlerbehebung nach Kapitel 25.2 (ohne Signatur- oder Formatänderung).
`part1-v1.0.0` bleibt unverändert; getaggt wird Teil 1.1 gesammelt nach dem
Design-Pass als `part1-v1.1.0`.

**Befund.** Im Rezeptdetail blendete beim Versionswechsel (z. B. V1 → V3)
der Titel kurz aus und wieder ein. Ursache: `_VersionLoader` baute mit einem
`FutureBuilder` bei jedem `connectionState != done` ein eigenes Lade-Scaffold
(nur AppBar-Titel, keine Aktionen, keine Versionsleiste, zentrierter
Ladekreis) und tauschte so für die Dauer des Ladens den ganzen Bildschirm aus.

**Fix (nur `recipe_detail_screen.dart`).**
- `_VersionLoaderState` hält den zuletzt geladenen Inhalt (`RecipeVersion` +
  `NutritionResult`) selbst statt über einen `FutureBuilder`. Während eine
  neue Version lädt, bleibt `_DetailScaffold` mit dem alten Inhalt stehen —
  Titel, AppBar-Aktionen und Versionsleiste bleiben sichtbar, es entsteht
  kein zweites Scaffold. Erst wenn die neue Version samt Nährwerten da ist,
  wird der Inhalt ausgetauscht.
- Ladeanzeige: ein `LinearProgressIndicator` oben im Body, per `Stack` über
  die Liste gelegt, also direkt unter der AppBar. Bewusst nicht als
  `AppBar.bottom`: das würde die AppBar beim Ein- und Ausblenden um 4 px
  verändern und den Inhalt verschieben — ein neues, kleineres Flackern.
  Farben kommen aus dem Theme (Standard des `LinearProgressIndicator`).
- Die Versionsleiste markiert die neue Wahl sofort (`selectedVersionId`
  des Bildschirms), damit der Tipp eine sichtbare Rückmeldung hat. Inhalt,
  `RecipeContext` und die Aktionen (z. B. „Bearbeiten“) beziehen sich bis zum
  Austausch weiter auf die angezeigte Version — eine Aktion wirkt also immer
  auf das, was gerade zu sehen ist.
- Der zentrierte Ladekreis erscheint nur noch beim allerersten Laden (noch
  kein Inhalt da, Kapitel 22). Der Fehlerfall bleibt wie bisher: das
  Fehler-Scaffold mit Titel und Fehlertext.
- Veraltete Antworten werden ignoriert: Jeder Ladevorgang bekommt eine
  laufende Nummer (`_request`); nur die Antwort des jüngsten wird
  übernommen, auch im Fehlerfall. Bei V1 → V3 → V2 überschreibt eine späte
  Antwort für V3 also nicht mehr V2. Antworten nach `dispose` werden über
  `mounted` verworfen.
- Nebenbei: `_load` liest beide Provider vor dem ersten `await`. Vorher wurde
  `nutritionServiceProvider` erst nach `getVersion` gelesen; wer den
  Bildschirm in diesem Moment verließ, bekam einen `StateError`, weil
  flutter_riverpod 3.4.3 `ref.read` nach dem Unmount ablehnt
  (`_assertNotDisposed`).
- Unverändert: kein Neuladen bei Stream-Updates ohne Versionswechsel (wie
  bisher nur bei geänderter `selectedVersionId`), keine Änderung an
  Verträgen, Daten, Modulen, Tür oder anderen Bildschirmen.

**Tests (neue IDs, Erweiterung von 23.6).** UI-33: während eines Wechsels
bleiben Titel, Aktionen „Versionen“/„Bearbeiten“ und die Versionsleiste
stehen; genau ein Scaffold, kein zentrierter Ladekreis, Ladebalken sichtbar,
alter Inhalt bleibt bis zur Antwort; beim allerersten Laden dagegen der
zentrierte Ladekreis. UI-34: V1 → V3 → V2 mit zurückgehaltener V3-Antwort
endet auf V2, auch nachdem V3 nachträglich antwortet.
Für einen deterministischen Zwischenzustand hält ein Test-Wrapper um den
echten `DriftNutritionService` (`_GatedNutritionService`) `forVersion` je
Version an, bis der Test ihn freigibt. `_pumpDetail` hat dafür einen
optionalen Parameter `nutritionService` bekommen (ohne Angabe wie bisher kein
Override); die neun bestehenden Tests der Datei sind unverändert.

**Gegenprobe.** Mit dem alten Bildschirmcode sind UI-33 und UI-34 rot, die
übrigen neun grün. Ohne den `_request`-Schutz ist UI-34 rot: nach der späten
V3-Antwort fehlt „Zucker V2“.

**Stolperfalle beim Testen.** Ein erster Entwurf von UI-34 war grün, obwohl
der Tap auf „V3“ danebenging (nur eine Warnung „hit test missed“, kein
Fehler): `_settle` pumpt ohne Zeitvorschub, die Auswahl-Animation der
`ChoiceChip`s nach dem vorherigen Wechsel stand still. Behoben mit dem
Helfer `_tapVersion` (Chip antippen, laden, Animation 500 ms auslaufen
lassen) und einer Prüfung direkt nach dem Tap, dass V3 gewählt ist und lädt.

**Nicht geändert:** Kapitel 28 (Liste der neuen Test-IDs bis UI-32) bleibt,
wie es ist; die Arbeitskarte nennt nur `docs/decisions.md` und
`docs/status.md`.

## 2026-10-05 — Teil 1.1b: Rezepte und Lebensmittel löschen (mit Rückgängig)

Nach Kapitel 25.2, ohne Vertragsänderung. Kein Tag; Teil 1.1 wird gesammelt
als `part1-v1.1.0` getaggt.

**Spezifikationslücke.** `softDeleteRecipe` (RP-12, kaskadiert auf alle
Versionen) und `softDeleteVariant` gibt es seit Phase 6 (Kapitel 16.1, 16.2).
Kapitel 22 sieht aber auf Bildschirm 1, 4 und 9/10 keinen Weg zum Löschen
vor, und kein Bildschirm rief die Methoden auf; nur Versionen waren löschbar
(bekannte Grenze von `part1-v1.0.0`, Kapitel 28.8). Geschlossen nur mit
Dateien unter `lib/src/ui/` und Tests; `contracts/`, `data/`, `module/`, Tür
und Datenbank sind unverändert, eine Wiederherstellen-Methode gibt es weiter
nicht.

**Entscheidung: „Rückgängig“ statt Bestätigungsdialog** (Vorgabe der
Arbeitskarte). Der Vertrag kennt kein Wiederherstellen; umkehrbar wird das
Löschen deshalb nur, indem es verzögert wird. Der Eintrag verschwindet
sofort, eine SnackBar („„<Titel>“ gelöscht“ bzw. „„<Name>“ gelöscht.
Eingefrorene Versionen behalten ihre Nährwerte.“) bietet 5 s lang
„Rückgängig“ an, erst danach ruft ein Timer `softDeleteRecipe` bzw.
`softDeleteVariant` auf. „Rückgängig“ bricht den Timer ab — gelöscht wurde
dann nie etwas.

**Umsetzung.**
- Neue Datei `lib/src/ui/shared/undoable_deletion.dart`: `PendingDeletions`
  (Riverpod-`Notifier` mit den ausgeblendeten IDs und je einem Timer pro
  Löschung), `pendingRecipeDeletionsProvider`, `pendingFoodDeletionsProvider`,
  `deleteRecipeWithUndo`, `deleteFoodWithUndo` und der Wisch-Hintergrund
  `DeleteSwipeBackground` (Farben aus `colorScheme.errorContainer`/
  `onErrorContainer`).
- Warum ein Provider: Das Rezeptdetail startet die Löschung und schließt sich
  sofort; die Liste muss den Eintrag trotzdem ausblenden, und der Timer muss
  das Schließen des Bildschirms überleben. Der Provider lebt so lange wie der
  `ProviderScope` der App. Wird die App beendet, bricht `ref.onDispose` alle
  Timer ab: Nichts wird gelöscht (der sichere Fall). Er ist reiner UI-Zustand,
  wird nicht über die Tür exportiert und erweitert die Provider-Liste aus
  Kapitel 16.7 nicht.
- Gelöschte IDs bleiben ausgeblendet. Würden sie nach dem Löschen sofort
  wieder freigegeben, tauchte der Eintrag für einen Frame wieder auf, bis der
  Stream der Liste die Löschung meldet. IDs werden nie wiederverwendet.
- Mehrere Löschungen kurz hintereinander: Jede hat ihren eigenen Timer und
  ihre eigene SnackBar. Eine neue SnackBar ersetzt eine noch sichtbare
  (`hideCurrentSnackBar`; Material zeigt immer nur eine). Die frühere Löschung
  läuft weiter und wird zu ihrem eigenen Zeitpunkt ausgeführt, ihr
  „Rückgängig“ ist dann aber nicht mehr erreichbar. „Rückgängig“ wirkt immer
  nur auf die eigene Löschung.
- `persist: false`: In Flutter 3.47.5 bleibt eine SnackBar mit Aktion
  standardmäßig stehen (`persist = persist ?? action != null`) und würde nie
  von selbst schließen. Zusätzlich schließt der Timer die SnackBar beim Ablauf
  selbst, weil „Rückgängig“ danach wirkungslos wäre; der Messenger würde sie
  erst 5 s nach der Einblend-Animation schließen.
- Rezeptliste und Lebensmittel-Liste: `Dismissible` nur nach links
  (`endToStart`). Rezeptdetail: Das AppBar-Menü ist jetzt immer da (vorher nur
  mit Menü-Aktionen von Modulen), „Rezept löschen“ steht als letzter Eintrag
  nach den Modul-Aktionen. Der Menütyp ist von
  `PopupMenuButton<RecipeAction>` auf `PopupMenuButton<VoidCallback>`
  umgestellt; Modul-Aktionen verhalten sich unverändert (EX-01 bis EX-05
  grün). Danach geht es zurück zur Liste, die SnackBar erscheint dort. Ist das
  Detail die erste Seite (z. B. über einen Deep Link), gibt es nichts zu
  schließen: Die Löschung läuft trotzdem, nach 5 s zeigt die Seite „Rezept
  nicht gefunden.“.
- Lebensmittel-Editor: Das Menü „Löschen“ erscheint nur beim Bearbeiten und
  ist aktiv, sobald das Lebensmittel geladen ist. Ungespeicherte Änderungen
  sind beim Löschen hinfällig. Deshalb setzt der Editor wie beim Speichern
  `_leaving`, damit der Verwerfen-Dialog aus 10.0 nicht erscheint, und
  schließt sich erst im nächsten Frame (Muster aus CLAUDE.md Abschnitt 4).
- Fehler beim Ablauf: Eine `NotFoundException` heißt „schon gelöscht“ und wird
  ignoriert. Bei jedem anderen Fehler erscheint der Eintrag wieder, und der
  Fehler wird weitergeworfen, nicht verschluckt.
- Unverändert aus 9.1b: Entwürfe mit einem gelöschten Lebensmittel zeigen
  „Verknüpftes Lebensmittel wurde gelöscht – bitte neu auswählen.“, Snapshots
  rechnen mit ihren eingebetteten Nährwerten weiter (Kapitel 12.3).

**Bewusst nicht abgedeckt:** Ausgeblendet werden ausstehende Löschungen nur in
den beiden Listen. Die Lebensmittelsuche im Rezept-Editor
(`FoodRepository.search`) zeigt ein Lebensmittel bis zum Ablauf der 5 s
weiter an.

**Tests (neue IDs UI-35 bis UI-44, Erweiterung von 23.6).** Die Karte nannte
„UI-33 ff.“; UI-33 und UI-34 sind seit 1.1a vergeben, deshalb geht es bei
UI-35 weiter.
- UI-35: Wischen blendet sofort aus, nach 3 s ist noch nichts gelöscht, nach
  5 s sind Rezept und beide Versionen gelöscht.
- UI-36: „Rückgängig“ löscht nichts, auch nach 10 s nicht.
- UI-37: Zwei Löschungen 2 s nacheinander: Die zweite SnackBar ersetzt die
  erste, jede wird zu ihrem eigenen Zeitpunkt gelöscht.
- UI-38: „Rückgängig“ der zweiten Löschung lässt die erste weiterlaufen.
- UI-39: Wird der `ProviderScope` vor Ablauf abgebaut (App-Ende), ist nichts
  gelöscht.
- UI-40: „Rezept löschen“ im Detail kehrt zur Liste zurück, SnackBar dort,
  nach 5 s sind Rezept und Versionen gelöscht.
- UI-41 und UI-42: Lebensmittel-Liste, Wischen bzw. „Rückgängig“.
- UI-43: „Löschen“ im Lebensmittel-Editor mit ungespeicherter Änderung kehrt
  ohne Verwerfen-Dialog zur Liste zurück, nach 5 s gelöscht; beim Anlegen gibt
  es kein Menü.
- UI-44: Ein gelöschtes Lebensmittel lässt einen Snapshot bei 600 kcal, der
  Entwurf daraus zeigt den Hinweis aus 9.1b.

Die bestehenden Tests der vier Testdateien sind unverändert (ergänzt wurden
nur Importe, Helfer und neue Tests); vor den neuen Tests liefen alle 94
UI-Tests gegen den neuen Code grün.

**Gegenprobe** (je ein absichtlich eingebauter Fehler in
`undoable_deletion.dart`, danach zurückgesetzt):
1. Ein gemeinsamer Timer für alle Löschungen: UI-37 und UI-38 rot.
2. Timer überleben das Ende des `ProviderScope`: UI-39 rot.
3. Sofort löschen (Frist 0): UI-35 bis UI-43 rot. UI-44 prüft kein Timing.
4. „Rückgängig“ ohne Wirkung auf den Timer: UI-36, UI-38 und UI-42 rot.

## 2026-10-05 — Teil 1.1c: Ladebalken im Rezeptdetail erst nach 300 ms

Nach Kapitel 25.2, freigegeben vom Projektverantwortlichen nach seinem Befund
„der Strich kommt immer noch, wenn ich Versionen wechsle“. Setzt die
Design-Notiz aus 1.1b um. Kein Tag.

**Befund.** Der Ladebalken aus 1.1a erschien bei jedem Versionswechsel sofort
und verschwand mit der Antwort wieder. Auf dem Gerät dauert das Laden nur
Sekundenbruchteile, der Strich blitzte deshalb bei fast jedem Wechsel kurz auf.

**Fix (nur `recipe_detail_screen.dart`).**
- Beim Übergang von „ruhend“ zu „lädt“ startet `_VersionLoaderState` einen
  Timer über 300 ms; erst wenn er abläuft, wird der Ladebalken gezeigt
  (`_showProgress`). Kommt die Antwort des jüngsten Ladevorgangs vorher, wird
  der Timer abgebrochen — bei schnellem Laden erscheint der Strich nie.
- Ein Wechsel während des Ladens startet keine neue Verzögerung. Ein schon
  sichtbarer Strich bleibt stehen, statt kurz aus- und wieder einzublenden;
  die Verzögerung gilt nur für den Beginn einer Ladephase.
- Mit der jüngsten Antwort (Erfolg oder Fehler) endet die Ladephase: Timer
  abgebrochen, Strich aus. `dispose` bricht den Timer ebenfalls ab.
- `_DetailScaffold.loading` heißt jetzt `showProgress`: Es steuert nur noch die
  Anzeige, nicht den Ladezustand.
- Unverändert: Inhalt, Versionsleiste und Aktionen aus 1.1a, der zentrierte
  Ladekreis beim allerersten Laden, der Fehlerfall und der Schutz gegen
  veraltete Antworten.

**Tests (neue IDs, Erweiterung von 23.6).** UI-45: Ein schneller Wechsel zeigt
weder während des Ladens noch nach Ablauf der 300 ms einen Strich. UI-46: Bei
langsamem Laden fehlt der Strich nach 250 ms und erscheint nach 350 ms; ein
weiterer Wechsel lässt ihn sofort stehen; nach der jüngsten Antwort ist er
weg, eine späte, veraltete Antwort ändert nichts.
UI-33 und UI-34 bleiben unverändert grün, weil ihr Helfer `_tapVersion` nach
jedem Wechsel 500 ms vorspult; damit ist der verzögerte Strich zum
Prüfzeitpunkt sichtbar.

**Gegenprobe.**
1. Bildschirm aus 1.1b (ohne Verzögerung): UI-45 und UI-46 rot. UI-46 musste
   einzeln laufen, siehe Beobachtung.
2. Timer wird bei der Antwort nicht abgebrochen: UI-45 rot, der Strich
   erscheint nach der Antwort doch noch. Ebenso rot ist UI-40: Der Timer des
   ersten Ladens läuft nach dem Laden ab und blendet den Strich bei fertigem
   Inhalt ein. Weil er dauerhaft animiert, läuft `pumpAndSettle` beim Öffnen
   des Menüs in den Timeout (einzeln geprüft).
3. Jeder Wechsel setzt die Verzögerung neu: UI-46 rot, der sichtbare Strich
   verschwindet beim zweiten Wechsel.

**Beobachtung, nicht geändert.** In mehreren Gegenproben (1.1b, 1.1c) blieb
`flutter test` nach einem roten Widget-Test in derselben Datei hängen, statt
sich zu beenden. Grüne Läufe sind nicht betroffen, und einzeln gestartet endet
derselbe rote Test sauber mit Exit 1. Die Ursache ist nicht untersucht;
vermutlich bleiben der Widget-Baum und Drift-Streams nach dem Abbruch offen,
und der Teardown wartet. `.github/workflows/ci.yml` hat kein
`timeout-minutes`, ein solcher Hänger würde die CI bis zum GitHub-Standardlimit
von 6 Stunden blockieren. Ein Zeitlimit wäre eine eigene Arbeitskarte
(`ci.yml`).

## 2026-10-05 — Teil 1.1d: CI-Zeitlimit und Test-Hänger

**Teil A — CI-Zeitlimit.** `.github/workflows/ci.yml` setzt für den Job `check`
jetzt `timeout-minutes: 20`. Vorher galt das GitHub-Standardlimit von 6 h: Ein
hängender Testlauf (beobachtet in den Gegenproben zu 1.1b/1.1c) hätte die CI so
lange blockiert. Die letzten fünf Läufe auf `main` dauerten 145–172 s, 20 min
lassen also reichlich Luft. Geändert ist nur der Job-Kopf; die Schritte sind
unverändert.

**Teil B — Ursache der Hänger nach fehlgeschlagenen Tests.**

*Reproduktion.* Ein einfacher roter Test hängt nicht: Erwartet der
Timer-Chip-Test `10:01` statt `10:00`, endet die ganze Datei nach 27 s mit
Exit 1. Es hängt dagegen, wenn der Test direkt nach einem Tap mit `pump()`
ohne Dauer scheitert. Fester Nachweis, nur im Test erzeugt: UI-45 erwartet
nach dem Wechsel `V9` statt `V1`. Der Lauf hing, bis er nach 938 s von Hand
abgebrochen wurde.

*Ursache (nur in Testdateien).* Drei Dinge greifen ineinander:
1. Nach einem Fehlschlag lässt `flutter_test` den Widget-Baum absichtlich
   stehen und räumt nicht auf (`binding.dart`, `_runTestBody`: „If we got an
   exception already, then we instead leave everything alone“). Der
   Abschluss-Aufruf `_disposeWidgetTree` am Ende des Testkörpers wird beim
   Fehlschlag übersprungen.
2. Drift plant beim Abbestellen eines Query-Streams einen Zero-Duration-Timer
   (`Timer.run` in `StreamQueryStore`) und wartet in `close()`, bis alle diese
   Timer gelaufen sind (`while (_pendingTimers.isNotEmpty) await …`). In einem
   Widget-Test liegt dieser Timer in der FakeAsync-Zone; `tester.pump()` ohne
   Dauer feuert ihn nicht. Ausgelöst wird das Abbestellen hier durch einen
   Neuaufbau des Rezeptdetails, der `watchRecipe`/`watchVersions` neu
   abonniert.
3. Der Teardown `tester.runAsync(database.close)` wartet in der echten Zone
   auf diesen Timer, den niemand mehr auspumpt.

Mit Markierungen im Teardown bestätigt: `database.streamQueries.close()`
kehrt nicht zurück, `executor.close()` wird nie erreicht. Ein
`pump(Duration.zero)` vor dem Schließen genügt: Derselbe rote Test endet dann
nach 3 s mit Exit 1. Im echten Betrieb laufen Drifts Timer normal ab; die
Ursache liegt nicht in `lib/`, `lib/` bleibt unverändert.

*Fix.* In den 12 Widget-Testdateien mit Datenbank gibt es einen neuen Helfer
`_closeDatabase(tester, database)`: Er baut erst den Widget-Baum ab und pumpt
aus (`_disposeWidgetTree`), dann schließt er die Datenbank. Die Teardown-Zeile
direkt nach dem Öffnen (80 Stellen) ruft jetzt ihn auf statt
`tester.runAsync(database.close)`. Das Aufräumen läuft damit auch bei einem
Fehlschlag. Es läuft vor `binding.postTest`, weil `testWidgets` diesen als
ersten Teardown registriert und Teardowns in umgekehrter Reihenfolge laufen;
die Fake-Zone darf dort also noch gepumpt werden. Der Aufruf von
`_disposeWidgetTree` am Ende der Testkörper bleibt: Ohne ihn meldet
`flutter_test` bei grünen Tests „A Timer is still pending“, bevor die
Teardowns laufen. Keine Assertion ist geändert, kein Test übersprungen;
entfernt wurden nur die 80 alten Teardown-Zeilen.

*Nicht betroffen.* Tests ohne FakeAsync-Zone (`test/data/`, `test/integration/`,
`test/spike/`, `test/providers/`): Ein roter MG-03 vor seinem `db.close()` am
Körperende endet nach 3 s mit Exit 1. Diese Tests sind unverändert. Die
Widget-Tests ohne Datenbank (`package_form`, `amount_calculator`,
`nutrition_header`, `nutrition_table`) haben keine Drift-Streams.

*Gegenprobe.*
1. UI-45 rot (`V9`), ganze Datei: endet nach 25 s mit Exit 1 (vorher Hänger).
2. Bildschirm aus 1.1b, ganze Datei (Fall aus der 1.1c-Gegenprobe): UI-45 und
   UI-46 rot nach 23 s. Vorher hing der Lauf nach UI-45, und UI-46 lief nie.
3. Sofort löschen (Mutante aus 1.1b) über Rezeptliste, Lebensmittel und
   Rezeptdetail: UI-35 bis UI-43 rot, der Lauf endet selbst mit Exit 1 (294 s,
   weil mehrere rote Tests in das Zeitlimit von `pumpAndSettle` laufen).
Danach ist alles zurückgesetzt und grün: Core 380, App 1,
`check_architecture` Exit 0.

*Nebenbefund zum Werkzeug.* `perl -e 'alarm N; exec …' flutter test` beendet nur
das Startskript; die `flutter_tester`-Kindprozesse liefen als Waisen weiter, ein
Lauf ignorierte das Signal ganz. Die Waisen aus den Gegenproben zu 1.1b/1.1c
sind beendet; für Gegenproben ein Skript verwenden, das nach Ablauf auch die
Kindprozesse beendet.

## 2026-10-07 — Teil 1.2: Design-System statt Design-Pass `design/1.1`

**Betroffenes Kapitel:** 2, 3, 4, 5, 19, 22, 27 (Regel 14); Nachträge in
Kapitel 28.9.

**Entscheidung (Projektverantwortlicher):** Der Design-Pass auf `design/1.1`
wird nicht übernommen; der Branch bleibt als Referenz. Stattdessen baut
Teil 1.2 auf `design-system` ein eigenes Paket `packages/unsalted_design`
(Rang 0, nur Flutter) mit Tokens, Theme, Layout, Komponenten und Templates,
einen Widgetbook-Katalog und stellt die Core-Bildschirme ohne
Funktionsänderung auf diese Komponenten um. Plan und Antworten auf F1–F12:
`docs/design/plan.md` (freigegeben 2026-10-07). Teil 1.1a–d ist als
`part1-v1.1.0` auf `25b09d9` getaggt; Teil 1.2 wird erst nach Freigabe als
`part1-v1.2.0` + `design-v0.1.0` getaggt.

**Antworten auf F1–F12:** F1 streng — AT-14 verbietet auch `Icons.`,
`TextStyle(`, `FontWeight.`, `Theme.of(`, `EdgeInsets.`, `BorderRadius.` und
`SizedBox` mit Zahl, über die Übergangsliste. F2 ja. F3 `unit_labels.dart`
übernehmen und nach C27 als eigener Commit C27b einsetzen (eigene Tests,
Kapitel 28.9); Skelett übernehmen, aber nicht einsetzen, der Ladekreis
bleibt. F4 `darkTheme` ab C26, folgt dem System. F5–F8 wie empfohlen (Media
erst Teil 4; Token-Namen jetzt, Generator später; C28 nur Finder;
Widgetbook Web + macOS, von Hand). F9 UI-Konfiguration wie vorgeschlagen;
Werte zunächst nur in `apps/unsalted_app/lib/config/ui_options.dart`;
unbekannte Schlüssel werden ignoriert; Kapitel 28.9 hält fest, dass
`CoreUiOptions` eine Konfiguration und kein Widget ist (18.1 verbietet nur
den Export von Widgets). F10 Präfix `App…`. F11 Entwurfs-PR
`design-system` → `main`, nicht mergen. F12 `part1-v1.1.0` jetzt, Teil 1.2
später nach Freigabe.

**C01 — Regeln.** `architecture.yaml`: `unsalted_design` Rang 0,
`unsalted_widgetbook` Rang 99, `package:unsalted_design/` in
`forbidden_in_core` (nur `src/ui/`), neuer Block `allowed_in_design`.
`tool/check_architecture.dart` hing die Ausnahmen bisher an
`contains('flutter')`/`contains('drift')`; ein Design-Eintrag wäre damit
überall gemeldet worden. Jetzt eine Tabelle Eintrag → Ausnahmeordner (für
Flutter und Drift unverändert), dazu die Prüfung des Design-Pakets (nur
`allowed_in_design`, kein `dart:io`/`dart:ffi`). *Gegenprobe:* vorübergehend
ein Design-Import in `src/recipe/` und `src/ui/` von Core sowie ein
Riverpod-, ein `dart:io`-, ein Flutter- und ein Eigenimport in
`packages/unsalted_design/lib/` → genau drei Meldungen (Core `src/recipe/`,
Riverpod, `dart:io`), Exit 1; nach dem Entfernen Exit 0.

**C02 — Gerüst `unsalted_design`.** `flutter create --template=package`,
Version 0.1.0 (`design-v0.1.0`, unveröffentlicht), `publish_to: none`,
einzige Abhängigkeit `flutter`. Die Tür verlangt `show` an jedem Export, damit
DS-03 neue oder umbenannte Komponenten erkennt (bei Core prüft AT-06 nur die
Exportzeilen). Neue Tests: DS-01 (nur Flutter, auch `pubspec.yaml`), DS-03
(Tür = Golden-Liste), DS-06 (keine Fachbegriffe in `lib/`, keine andere
Energieeinheit in `lib/` und `test/`). CI prüft das Paket vor Core.
*Gegenprobe:* `dart:io`-Import, ein Export ohne `show` und das Wort „Rezept“
vorübergehend in der Tür → DS-01, DS-03 und DS-06 rot; danach grün.

**C03 — Tokens.** Sieben Dateien unter `lib/src/tokens/`, Figma-Name je Wert
im Doku-Kommentar und in `byFigmaName`. Farbwerte per Skript aus
`_colorSchemeLightM3`/`_colorSchemeDarkM3` in
`material/theme_data.dart` (Flutter 3.47.5) übernommen, 46 Rollen ohne die
veralteten `background`, `onBackground`, `surfaceVariant`. Folge: Ein aus
den Tokens gebautes `ColorScheme` ist nicht `==` zu dem von `ThemeData()`,
weil `surfaceVariant` dann auf `surfaceContainerHighest` zurückfällt
(`E6E0E9` statt `E7E0EC`, dunkel `36343B` statt `49454F`). Kein
Flutter-Widget liest `surfaceVariant` mehr (SDK durchsucht); `background`
fällt auf `surface` zurück und ist in beiden Standardschemata gleich. DS-07
vergleicht deshalb rollenweise. Typo-Tokens = `Typography.englishLike2021`
(Größe, Schnitt, Zeilenhöhe, Laufweite; ohne Farbe und Schriftfamilie).
Bewegung: `AppMotion.durationOf` aus `motion.dart` (`design/1.1`); Kurven
`Easing.standard` und `Curves.easeInOutCubicEmphasized`. Tests DS-02 (Farbwerte
nur in `tokens/`), DS-04 (Vollständigkeit, Figma-Namensformat, Typo =
Flutter-Skala, Bewegung reduzieren), DS-05 (alle 45 Text-auf-Fläche-Paare je
Modus ≥ 4,5:1 — die Material-Standardfarben bestehen ohne Ausnahme).
*Gegenprobe DS-02:* `Color(…)` in einer Datei außerhalb von `tokens/` → rot.

**C04 — Theme.** `AppTheme.light()`/`.dark()` bauen `ThemeData` nur aus
`AppColorTokens` und `AppTypography`. DS-07 vergleicht mit `ThemeData()` bzw.
`ThemeData(brightness: dark)`: alle 46 Rollen einzeln, die abgeleiteten
Flächenfarben (`scaffoldBackgroundColor`, `canvasColor`, `cardColor`,
`dividerColor`, `hintColor`, `disabledColor`, `primaryColor`) und die Typo
nach `ThemeData.localize` (so wendet `MaterialApp` das Theme an) — gleich.
*Abweichung vom Plan:* `theme/app_tokens.dart` (ThemeExtension) und
`theme/component_themes.dart` entfallen vorerst. Komponenten lesen
Abstände, Radien und Bewegung als statische Tokens und Farben/Typo aus
`Theme.of(context)`; ohne Design-Theme liefert `ThemeData()` dieselben
Werte, damit ist Risiko R2 (Core-Tests pumpen `MaterialApp` ohne Theme)
ohne Rückfall-Logik gelöst. Komponenten-Themes und eine Erweiterung (z. B.
für Farben außerhalb der Material-Rollen) kommen, sobald das Figma-Design
sie verlangt (KI-S4).

**C05 — Layout.** `AppSpace` (Enum der Abstandsstufen, in
`spacing_tokens.dart`): Bildschirme geben Abstände nur als Stufe an, nie als
Zahl. `AppGap`, `AppStack` (Abstand nur zwischen Kindern), `AppPadding`
(`all`/`symmetric`/`only`; im Plan nicht eigens genannt, ersetzt
`EdgeInsets` in Bildschirmen), `AppPage` (baut genau ein `Scaffold`),
`AppGrid` (aus `card_layout.dart`, ohne Sliver, Spalten nach verfügbarer
Breite), `AppWindowSize` + `ResponsiveBuilder` (statt des im Plan genannten
`Responsive.of`; `AppWindowSize.of(context)` für die Fensterbreite).
`AppSection` folgt in C06, weil sie `AppText` und `AppDivider` nutzt. Tests
DS-10 bis DS-13 laufen über `test/support/design_harness.dart` in vier
Varianten (hell/dunkel × Handy 390×844 / Tablet 1024×1366).

**C06 — Komponenten I.** `AppButton` (`primary`/`secondary`/`tertiary` →
`ElevatedButton`/`OutlinedButton`/`TextButton`, mit Symbol die `.icon`-
Varianten), `AppIconButton` und `AppFab` mit Pflicht-Tooltip
(Screenreader-Text; heute haben FABs und die Entfernen-Knöpfe der Zeilen
keinen — kommt mit der Umstellung hinzu), `AppFab` mit Ladezustand
(Ladekreis in `onPrimaryContainer` statt `Colors.white`, das auf dem hellen
FAB kaum zu sehen war). `AppIcons` mit Figma-Namen; DS-06 ignoriert jetzt
Material-Symbolnamen (`Icons.no_food` ist kein eigener Fachbegriff).
`AppText` (`body` = schlichter `Text` ohne Stil, `strong` = fett wie die
bisherigen Überschriften, `title`, `caption`) und `AppTone` (normal, muted,
primary, error aus dem ColorScheme). `AppSurface` (Töne low/medium/high),
`AppDivider` (Höhe als Stufe, `.flush()`, `.vertical()`), `AppCard`,
`AppSection` (Trennlinie `space/xxl` + fette Überschrift = bisheriges Muster
„Divider(height: 32) + fetter Text“). Tests DS-14 bis DS-22.

**C07 — Komponenten II.** `AppTextField` baut mit Controller ein
`TextField`, mit Startwert ein `TextFormField` (die Schrittfelder des
Editors und ihre Tests verwenden `TextFormField`); `helperMaxLines` immer 2
wie bisher in der Zutatenzeile; Varianten `width: narrow` (120, ersetzt
`SizedBox(width: 120)` um das Timer-Feld) und `expands` (Importfeld: füllend,
oben ausgerichtet, mit Rahmen). `AppSelect<T>` baut ohne Label ein
`DropdownButton<T>`, mit Label ein `DropdownButtonFormField<T>` — so finden
die bestehenden Tests ihre Typen weiter. Neu gegenüber dem Plan:
`AppItemList` (`List/Items`) als zentrale Stelle für Listen ganzer Seiten
(später Raster ab Tablet). `AppSwipeToDelete` übernimmt den Hintergrund aus
`DeleteSwipeBackground`. Texte (Platzhalter, Beschriftungen) liefert immer
der Aufrufer; das Design-Paket enthält keine UI-Texte. Tests DS-23 bis DS-31.

**C08 — Komponenten III.** `AppNotice` aus `notice.dart` (`design/1.1`),
Radius/Abstände aus Tokens. `AppEmptyState` und `AppErrorState` bilden den
heutigen Aufbau 1:1 nach (Symbol 48, Satz, Aktion; Text + „Erneut
versuchen“) statt der umgestalteten Fassung aus `design/1.1`. Meldungen über
`AppMessenger.of(context)`: kapselt `ScaffoldMessenger`, `persist: false` und
die Regel aus 1.1b, `close()` nur auf noch offene Meldungen
(`AppSnackbarHandle.close`); Fristen und Löschlogik bleiben in Core.
Dialoge: `showAppConfirmDialog` (`false` auch beim Schließen ohne Wahl, wie
bisher `result ?? false`), `showAppChoiceDialog`, `showAppDialog` +
`AppDialog` (feste Inhaltsgröße 400 × 400 wie der bisherige
Lebensmittel-Auswahldialog), `showAppAboutDialog`. `AppSkeleton` übernommen,
nicht eingesetzt (F3). Tests DS-32 bis DS-39.

**C09 — Komponenten IV.** `AppTopBar` (`AppBar` mit unterem Bereich 56 hoch,
Innenabstand `l`/`s` wie bisher um die Suchfelder), `AppOverflowMenu`
(`PopupMenuButton<VoidCallback>` wie im Rezeptdetail und im
Lebensmittel-Editor), `AppNavigationBar`, `AppBottomActionBar` (eine Aktion
in eigener Breite wie im Versionsvergleich, mehrere teilen sich die Breite
wie im Editor), `AppKeyValueTable` (Spalten 2 : 1 : 1, Zellabstand `xs`,
fette Kopfzeile — wie die Nährwerttabelle), `AppCodeBlock`. Media-Ordner
bleibt bis Teil 4 leer (F5). Tests DS-40 bis DS-45.

**C10 — Templates.** Templates bekommen den Inhalt des aktuellen Zustands
als `body` (der Bildschirm entscheidet: `AppLoading`, `AppErrorState`, leer
oder Inhalt). Inhalt-Layouts: `DetailSections` (scrollend; ein- oder
zweispaltig über die **eine** zentrale Einstellung `DetailLayout.standard`,
zunächst `oneColumn`), `DetailSplit` (zwei Bereiche übereinander +
Fußzeile, wie der Versionsvergleich), `FormSections` und
`FormSections.fixed` (Innenabstand `l`; fest für `Expanded`-Kinder wie
Export/Import). Stabilität als Teil des Vertrags: `DetailPageTemplate`
legt den Inhalt immer in einen `Stack` (`StackFit.expand`), damit das
Ein- und Ausblenden des Ladebalkens (1.1a/1.1c) Inhalt und Scrollposition
nicht neu aufbaut; `FormPageTemplate` hält den Inhalt in einem `Expanded`
mit festem Key, damit erscheinende Meldungen Eingaben nicht verwerfen.
Tests DS-46 bis DS-48. *Gegenprobe DS-47:* `Stack` nur bei sichtbarem
Ladebalken → alle vier Varianten rot (Scrollposition 0, Inhalt neu
erzeugt); zurückgesetzt, grün.

**C11 — Widgetbook.** `apps/unsalted_widgetbook`, `widgetbook` 3.25.0 per
`flutter pub add`; API im Pub-Cache geprüft (`Widgetbook.material`,
`MaterialThemeAddon` + `WidgetbookTheme`, `ViewportAddon` mit
`IosViewports.iPhone13`/`iPadPro11Inches`, `WidgetbookFolder`/
`WidgetbookCategory`/`WidgetbookComponent`/`WidgetbookUseCase`). Katalog von
Hand (kein Generator, F8), je Ordner des Design-Pakets eine Datei;
Komponentenname = Dart-Klasse, Anwendungsfall = Figma-Variante. Tests WB-01
(alle 63 Anwendungsfälle bauen in hell/dunkel × Handy/Tablet ohne Fehler und
ohne Überlauf), WB-02 (jedes Symbol der Tür ist Katalogeintrag oder
ausdrücklich ausgenommen, z. B. Tokens und Parametertypen), WB-03 (die App
startet). *Abweichung von F8:* Nur macOS — `flutter create
--platforms=web,macos` hat keinen `web/`-Ordner angelegt, weil Web in der
lokalen Flutter-Konfiguration abgeschaltet ist (`enable-web: false`). Die
globale Konfiguration wurde nicht geändert; Web lässt sich nachrüsten mit
`flutter config --enable-web` und `flutter create --platforms=web .` im
App-Ordner. CI prüft die App (analyze + test). Rang 99 in
`architecture.yaml` seit C01.

**C12 — Doku.** `docs/design/design_system.md` (Ebenen, acht Regeln,
Benennung = Figma-Namen, Ablauf Figma → Code), `components.md` (Komponente |
Figma-Name | Datei | Status | Test, dazu die fachlichen Bausteine in Core),
`screens.md` (je Bildschirm Zweck, Daten, Aktionen, Zustände, Template,
Abschnitte; Spalte „Umgestellt“ wird mit C14–C26 nachgeführt), README und
CHANGELOG des Pakets.

**C13 — Core-Anbindung.** `flutter pub add unsalted_design --path
../unsalted_design` in Core; dazu `publish_to: 'none'` in Core-`pubspec.yaml`,
weil der Analyzer Pfad-Abhängigkeiten in veröffentlichbaren Paketen meldet
(`invalid_dependency`). Die App-`pubspec.lock` ändert sich transitiv.
Neue Architekturtests mit gemeinsamen Detektoren in
`test/architecture/support/ui_rules.dart`:
- **AT-13** (feste Farben) wie auf `design/1.1`.
- **AT-14** (nur Design-Komponenten, F1 „streng“). Gegenüber der Liste im
  Plan zusätzlich verboten, weil es eine Komponente dafür gibt: `Icon`
  (`AppIcon`), `InputDecoration` (`AppTextField`), `ListView`
  (`AppItemList`/Templates), `Container`, `DecoratedBox`, `ColoredBox`
  (`AppSurface`), `Padding` (`AppPadding`), `NavigationDestination`,
  `TableRow`, `ScaffoldMessenger.` (`AppMessenger`), `SizedBox.square` und
  `SizedBox(width: double.…)`. Erlaubt bleiben Struktur-Widgets (`Text`
  ohne Stil, `Column`, `Row`, `Expanded`, `Flexible`, `Stack`, `Center`,
  `SingleChildScrollView`, Builder, `PopScope`, `Navigator`,
  `MaterialPageRoute`). Detektor mit Selbsttest (20 Verstöße, 12 erlaubte
  Fälle).
- **AT-15** (Design-Import nur in `lib/src/ui/`).
- **Übergangsliste** `support/design_transition.dart`: die 18 noch nicht
  umgestellten UI-Dateien (alle außer `change_descriptions.dart`, die schon
  sauber ist). Ein zweiter AT-14-Test schlägt fehl, wenn eine Datei ohne
  Verstoß auf der Liste steht oder es sie nicht gibt.
AT-01 inhaltlich unverändert (Rang 0 < 1), Kopfkommentar korrigiert.
*Gegenproben:* `Colors.red` in einer neuen Datei unter `src/ui/` → AT-13 rot;
`settings_screen.dart` von der Liste gestrichen → AT-14 rot
(`settings_screen.dart:25 → return Scaffold(`); Design-Import in
`src/recipe/` → AT-15 rot; alles zurückgesetzt, grün. Core 386 Tests
(+6), App 1, Design 208, Widgetbook 6; `check_architecture` Exit 0.

**C14 — Einstellungen (Bildschirm 13).** `ListPageTemplate` mit
`AppItemList`; Abschnitte `settings_core_entries_section.dart` (Export,
Import, „Über unsalted“) und `settings_module_entries_section.dart`
(Trennlinie + `settingsEntries`, leer = nichts). Modul-Einträge erhalten wie
bisher den Kontext des Bildschirms (`entry.onTap(context)` im Bildschirm).
Keine sichtbare Änderung. `components.md`: eigene Zeilen für die in
Etappe 1 hinzugekommenen Bausteine `AppSpace`, `AppPadding`, `AppItemList`,
`AppTone`, `AppMessenger`, `AppWindowSize`. Bestehende Tests unverändert,
Core 386 grün.

**C15 — Lebensmittel-Liste (Bildschirm 9).** `ListPageTemplate`; Abschnitte
`food_list_search_section.dart`, `food_list_empty_section.dart`,
`food_list_results_section.dart`, Baustein `foods/food_tile.dart`.
`undoable_deletion.dart` zeigt die Meldung jetzt über
`AppMessenger.showWithAction`; die Regel „nur schließen, solange offen“ liegt
im `AppSnackbarHandle`. *Abweichung vom Plan:* `undoable_deletion.dart`
bleibt bis C16 auf der Übergangsliste, weil `DeleteSwipeBackground` noch von
der Rezeptliste benutzt wird; es entfällt mit C16. *Sichtbare Änderung
(freigegeben):* Die Hauptaktion hat den Tooltip „Neues Lebensmittel“ —
bewusst nicht „Lebensmittel anlegen“, weil ein bestehender Test nach dem
Öffnen des Editors genau einen solchen Text erwartet. Bestehende Tests
unverändert, Core 386 grün.

**C16 — Rezeptliste (Bildschirm 1).** `ListPageTemplate`; Abschnitte
`recipe_list_search_section.dart`, `recipe_list_empty_section.dart`,
`recipe_list_results_section.dart`, Baustein `recipe_list/recipe_card.dart`
(vorerst `AppListItem`, damit die Liste aussieht wie bisher).
`DeleteSwipeBackground` entfällt in `undoable_deletion.dart` (jetzt
`AppSwipeToDelete`); beide Dateien sind von der Übergangsliste gestrichen.
Im leeren Zustand „Keine Treffer.“ steht statt der Aktion ein leerer
Platzhalter, damit der Abstand unter dem Satz bleibt wie bisher (keine
Verschiebung). *Sichtbare Änderung (freigegeben):* Tooltip „Neues Rezept“
an der Hauptaktion — nicht „Rezept erstellen“, weil ein bestehender Test
diesen Text nach dem Öffnen genau einmal erwartet. Bestehende Tests
unverändert, Core 386 grün.

**C17 — Rezept erstellen (Bildschirm 2).** `FormPageTemplate` mit
`FormSections`; Abschnitt `recipe_create_fields_section.dart`; Rückfrage
über `showAppConfirmDialog` (gleiche Texte, `false` beim Schließen ohne
Wahl). `PopScope` und `addPostFrameCallback` bleiben unverändert im
Bildschirm. Der Speicherfehler bleibt unter den Feldern. *Sichtbare
Änderungen (freigegeben):* Speicherfehler in `color/error` statt
`Colors.red`; Ladekreis im FAB in `onPrimaryContainer` statt `Colors.white`;
Tooltip „Rezept speichern“. Bestehende Tests unverändert, Core 386 grün.

**C18 — Export (Bildschirm 11).** `FormPageTemplate` mit
`FormSections.fixed`; Abschnitte `export_selection_section.dart` (Rezept,
Version) und `export_result_section.dart` (JSON in `AppCodeBlock`,
„In Zwischenablage kopieren“). Die Auswahl bekommt die beiden Streams als
Daten und baut ihre `StreamBuilder` an derselben Stelle wie bisher, damit
Abonnements und der Formularzustand der Auswahllisten unverändert bleiben
(Abschnitte lesen weiter keine Provider). Meldung „In Zwischenablage
kopiert.“ über `showAppMessage`. *Sichtbare Änderung (freigegeben):*
Fehlertext in `color/error` statt `Colors.red`. Bestehende Tests
unverändert, Core 386 grün.

**C19 — Import (Bildschirm 12).** `FormPageTemplate` mit
`FormSections.fixed`; Abschnitte `import_input_section.dart` (füllendes
Feld mit Rahmen, `AppTextField.expands`) und `import_preview_section.dart`
(Titel fett, Zutatenzahl, Gesamt-kcal über `NutritionFormatter`).
Reihenfolge, Abstände und Logik unverändert. *Sichtbare Änderung
(freigegeben):* Vorschau- und Importfehler in `color/error` statt
`Colors.red`. Bestehende Tests unverändert, Core 386 grün.

**C20 — Versionen (Bildschirm 7).** `ListPageTemplate` ohne Suche und
Hauptaktion; Abschnitt `version_list_results_section.dart`, Baustein
`versions/version_tile.dart` (Stern, Titel, Entwurf/Eingefroren mit Datum,
vier Aktionen mit den bisherigen Tooltips — alle innerhalb des
Listeneintrags, wie die Tests es erwarten). Rückfrage beim Löschen über
`showAppConfirmDialog`, Vergleichsziel über `showAppChoiceDialog`, Fehler
des Repositorys über `showAppMessage` — Texte unverändert. Keine sichtbare
Änderung. Bestehende Tests unverändert, Core 386 grün.

**C21 — Versionsvergleich (Bildschirm 8).** `DetailPageTemplate` mit
`DetailSplit`; Abschnitte `version_compare_columns_section.dart`,
`version_compare_changes_section.dart`, `version_compare_apply_section.dart`;
Bausteine `versions/snapshot_column.dart` und `versions/change_list.dart`
(herausgelöst, Kategorie-Logik unverändert und privat). Diff,
`targetRows` und Übernehmen bleiben im Bildschirm. *Sichtbare Änderung
(freigegeben):* Fehler beim Übernehmen in `color/error` statt
`Colors.red`. Bestehende Tests unverändert, Core 386 grün.

**C22 — Nährwertanzeige und Mengenrechner (Bildschirm 5, 6).**
`NutritionTable` aus `AppKeyValueTable` (Spalten 2 : 1 : 1, fette Köpfe wie
bisher), Spalte 2 über `AppSelect<NutritionTableColumn2>` (baut weiter
`DropdownButton`), Fußnoten als `AppText.caption` (= bisher `bodySmall`).
`NutritionHeader` aus `AppText`; `AmountCalculator` aus zwei
`AppTextField` in einem `AppStack` (Abstand `l` wie bisher). Rechnung,
Rundung (nur `NutritionFormatter`) und Kopplung unverändert.
*Design-Paket, additiv:* `AppSurface` bekommt die im Plan vorgesehenen Töne
`info`, `warning`, `error` (Fläche `…Container`, Text und Symbole im Inhalt
`on…Container`), Test DS-20b, Katalogeintrag. Grund: Die bisherigen
farbigen Kästen (hier „Nicht berechenbar“, später Verpackungsformular und
Editor) haben weder Symbol noch runde Ecken; `AppNotice` brächte beides
mit und wäre eine weitere sichtbare Änderung. `AppNotice` bleibt im
Design-System, wird in Core vorerst nicht eingesetzt. *Sichtbare Änderung
(freigegeben, Theme-Farben statt `Colors.*`):* Hinweis „Nicht berechenbar“
in `color/tertiary-container` mit `color/on-tertiary-container` statt
`Colors.amber.shade100`. Bestehende Tests unverändert; Core 386, Design 212,
Widgetbook 6 grün.

**C23 — Rezeptdetail (Bildschirm 4).** Alle Zustände über `AppPage`
(Rezept lädt/Fehler/nicht gefunden, wie bisher ohne Kopfleiste) bzw.
`DetailPageTemplate` mit Titel; Inhalt über `DetailSections`: Haupt
`VersionSwitcher`, `recipe_detail_description_section.dart`,
`recipe_detail_nutrition_section.dart`; Neben
`recipe_detail_ingredients_section.dart`, `recipe_detail_steps_section.dart`,
`recipe_detail_extensions_section.dart` — einspaltig in genau der bisherigen
Reihenfolge. Kopfleiste über `recipe_detail_actions_section.dart`
(Material 3 ordnet AppBar-Aktionen ohnehin in einer mittig ausgerichteten
`Row` an, die zusätzliche Zeile ändert das Layout nicht). Modul-Abschnitte
werden wie bisher im Bildschirm mit dessen Kontext und dem `RecipeContext`
gebaut. `_VersionLoader` (1.1a, 1.1c) unverändert; der Ladebalken sitzt im
`Stack` des Templates.

*Menü-Kontext (freigegebene Änderung, geprüft):* Modul-Aktionen im Menü
erhalten jetzt den Kontext der Detailseite. Die Gegenprobe (alter
Bildschirm aus `HEAD` mit dem neuen Test) zeigte, dass der alte Kontext
**nicht** der der Menü-Route war, sondern der des `PopupMenuButton`
(`itemBuilder` wird mit dem Kontext des Knopfs aufgerufen) — ebenfalls
gültig und unter `RecipeDetailScreen`. Die Änderung ist damit geringer als
angekündigt (Knopf- statt Seitenkontext, gleiche Vorfahren für Navigator,
Theme, ScaffoldMessenger). EX-01, EX-02, EX-04, EX-05 (hier) und EX-03
(Einstellungen) grün. Neuer Test **UI-58**
(`test/ui/recipe_detail/recipe_detail_menu_context_test.dart`, bisher gab es
keinen Test für Menü-Aktionen): gültiger Kontext unter `RecipeDetailScreen`,
richtiger `RecipeContext`, gesperrte Aktion wird nicht ausgeführt; er ist
mit altem und neuem Bildschirm grün. Keine weitere sichtbare Änderung.
Bestehende Tests unverändert, Core 387 grün.

**C24 — Lebensmittel bearbeiten (Bildschirm 10).** `FormPageTemplate`
(Menü „Löschen“ über `AppOverflowMenu`, Speicherfehler als Meldung über dem
Formular, Hauptaktion `AppFab`); Laden, Fehler und „nicht gefunden“ über
`AppLoading`/`AppErrorState`. `PackageForm` behält Controller,
`hasChanges` (10.0), Prüfung und Natrium-Umrechnung; dargestellt in
`package_identity_section.dart`, `package_measures_section.dart`,
`package_nutrients_section.dart` (Feldbeschreibung `PackageNumberField`)
und `package_validation_section.dart`. Warn- und Fehlerkasten sind
`AppSurface` mit den Tönen `warning`/`error`, gleicher Innen- und
Außenabstand, Keys `package_form_warning`/`package_form_error` unverändert.
`PopScope` und `addPostFrameCallback` bleiben im Bildschirm.
*Sichtbare Änderungen (freigegeben):* Warnkasten in
`color/tertiary-container` statt `Colors.yellow.shade100`, Fehlerkasten in
`color/error-container` mit `color/on-error-container` statt
`Colors.red.shade100`/`Colors.red`, Speicherfehler in `color/error`,
Ladekreis im FAB in `onPrimaryContainer`; Tooltip „Lebensmittel speichern“.
Bestehende Tests unverändert, Core 387 grün.

**C25 — Rezept-Editor (Bildschirm 3).** `FormPageTemplate` in allen
Zuständen (laden, Fehler + „Erneut versuchen“, nicht gefunden, eingefroren,
bearbeitbar); bearbeitbar mit Vorschauleiste (`header`), Speicherfehler
(`messages`), `FormSections` und Aktionsleiste (`bottomBar`). Abschnitte
`recipe_editor_preview_section.dart`, `recipe_editor_frozen_section.dart`,
`recipe_editor_parameters_section.dart`,
`recipe_editor_ingredients_section.dart`, `recipe_editor_steps_section.dart`,
`recipe_editor_actions_section.dart`. Bausteine: `IngredientRow` aus
Design-Komponenten (`IngredientRowData` und Verknüpfungsregel 9.1b
unverändert); neu herausgelöst `step_row.dart` mit `StepRowData` und
`timerInputText` (bisher privat im Editor, Code und Timer-Regel 9.2a
wörtlich übernommen) und `food_variant_picker_dialog.dart`. Das Suchfeld im
Auswahldialog bleibt ohne Lupe (`AppTextField` mit Platzhalter statt
`AppSearchField`), damit sich dort nichts sichtbar ändert. Stabile Keys
(`ValueKey(id)`) an jeder Zeile, Umsortieren über `AppReorderableList`.
*Sichtbare Änderungen (freigegeben):* Vorschauleiste in
`color/surface-container-high` statt `Colors.grey.shade100`, Hinweis
„Eingefroren …“ in `color/secondary-container` statt `Colors.blue.shade50`,
Speicherfehler in `color/error`; Tooltips „Zutat entfernen“ und „Schritt
entfernen“ an den Entfernen-Knöpfen. Die Übergangsliste ist damit leer.
Bestehende Tests unverändert, Core 387 grün.

**C26 — App-Hülle.** `apps/unsalted_app/pubspec.yaml` + `unsalted_design`
(per `flutter pub add … --path`). `MaterialApp.router` bekommt
`theme: AppTheme.light()` und `darkTheme: AppTheme.dark()`, `themeMode`
bleibt `system` (Antwort F4). Die Navigationsschale baut `AppPage` mit
`AppNavigationBar` (gleiche Ziele, Symbole und Beschriftungen). Import nur
über die Tür (AT-09). Neuer Test **APP-02** (`test/theme_test.dart`):
Themes aus dem Design-Paket, `ThemeMode.system`, hell und dunkel je nach
Systemeinstellung, Navigationsleiste mit drei Zielen. *Gegenprobe:* ohne
`darkTheme` → APP-02 rot; zurückgesetzt, grün. *Sichtbare Änderung
(freigegeben, F4):* Die App folgt jetzt dem Dunkelmodus des Systems. Der
bestehende App-Test ist unverändert; App 3 Tests grün.

**C27 — Abschluss Etappe 2.** Übergangsliste leer: alle Dateien unter
`lib/src/ui/` erfüllen AT-13 und AT-14 ohne Ausnahme. *Abweichung vom
Plan:* Der Mechanismus der Übergangsliste (`support/design_transition.dart`
und seine Verwendung in AT-13/AT-14) ist **nicht** entfernt, weil das die
Testdateien AT-13/AT-14 ändern würde und bestehende Tests in Etappe 2 nicht
geändert werden durften; die leere Liste wirkt nicht mehr. Entfernen nach
Freigabe (reine Aufräumarbeit). `docs/design/screens.md` auf den
tatsächlichen Stand gebracht (Abschnitte je Bildschirm mit Pfad, in
Anzeigereihenfolge), `components.md` (fachliche Bausteine, nicht eingesetzte
Komponenten), Kapitel 28.9 Punkt 5, CLAUDE.MD.

*Sichtbare Änderungen Etappe 2, vollständig (alle in den freigegebenen
Gruppen):* (1) Theme-Farben statt `Colors.*`: Fehlertexte in `color/error`
(Rezept erstellen, Export, Import, Versionsvergleich, Lebensmittel-Editor,
Rezept-Editor); Hinweis „Nicht berechenbar“ und Warnkasten im
Verpackungsformular in `tertiary-container`; Fehlerkasten im
Verpackungsformular in `error-container`/`on-error-container`; Vorschauleiste
des Editors in `surface-container-high`; Hinweis „Eingefroren …“ in
`secondary-container`; Ladekreis in den FABs in `on-primary-container`.
(2) Tooltips: „Neues Rezept“, „Neues Lebensmittel“, „Rezept speichern“,
„Lebensmittel speichern“, „Zutat entfernen“, „Schritt entfernen“.
(3) Menü-Kontext im Rezeptdetail (Knopf- → Seitenkontext, ohne
beobachtbaren Unterschied, UI-58). (4) Dunkelmodus nach System (F4, C26).
Keine weiteren: Reihenfolge, Texte, Abstände und Verhalten unverändert.
Stand: Design 212, Core 387, App 3, Widgetbook 6 Tests grün;
`check_architecture` Exit 0.

## 2026-10-07 — Teil 1.2, Etappe 3 (freigegeben)

Reihenfolge nach Vorgabe: C27c, C28, C27b, C29; je ein Commit.

**C27c — Übergangsmechanismus entfernt.** `test/architecture/support/
design_transition.dart` gelöscht; AT-13 und AT-14 ohne Ausnahmeprüfung;
der zweite AT-14-Test („Übergangsliste enthält nur nicht umgestellte
Dateien“) entfällt mit der Liste. Regeln und Detektoren unverändert streng.
*Gegenprobe:* `Color(…)` und `Divider()` vorübergehend in
`lib/src/ui/foods/food_tile.dart` → AT-13 und AT-14 rot mit genau diesen
Zeilen; zurückgesetzt, grün. Core 386 Tests (−1).

**C28 — Test-Finder auf Design-Typen (F7).** In 14 Testdateien unter
`packages/unsalted_core/test/ui/` 116 Zeilen geändert, jede nur im Typ des
Finders (maschinell geprüft: ohne den Typnamen sind alte und neue Zeile
gleich), dazu je Datei der Import der Design-Tür. Keine Erwartung, kein
Ablauf, keine Testdaten geändert. Zeilennummern im neuen Stand:

- `test/ui/foods/food_editor_screen_test.dart`
  - Z. 16: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 81, 121, 139, 140, 195, 212, 240, 260, 262, 306: `find.widgetWithText(TextField` → `find.widgetWithText(AppTextField`
  - Z. 87, 123, 242, 331: `find.byType(FloatingActionButton` → `find.byType(AppFab`
  - Z. 218, 224: `find.widgetWithText(TextButton` → `find.widgetWithText(AppButton`
  - Z. 309, 334: `find.byType(PopupMenuButton<VoidCallback>` → `find.byType(AppOverflowMenu`
- `test/ui/foods/food_list_screen_test.dart`
  - Z. 19: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 116: `find.widgetWithText(ElevatedButton` → `find.widgetWithText(AppButton`
  - Z. 173: `find.byType(TextField` → `find.byType(AppSearchField`
  - Z. 190: `find.byType(FloatingActionButton` → `find.byType(AppFab`
- `test/ui/foods/package_form_test.dart`
  - Z. 11: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 45, 79, 81, 83, 96, 97, 107, 108, 109, 126, 127, 128: `find.widgetWithText(TextField` → `find.widgetWithText(AppTextField`
- `test/ui/nutrition/amount_calculator_test.dart`
  - Z. 11: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 35, 47, 59, 71, 73: `find.widgetWithText(TextField` → `find.widgetWithText(AppTextField`
- `test/ui/recipe_detail/recipe_detail_menu_context_test.dart`
  - Z. 15: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 110: `find.byType(PopupMenuButton<VoidCallback>` → `find.byType(AppOverflowMenu`
- `test/ui/recipe_detail/recipe_detail_screen_test.dart`
  - Z. 27: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 237, 718, 761, 772: `find.widgetWithText(ChoiceChip` → `find.widgetWithText(AppChoiceChip`
  - Z. 318: `find.widgetWithIcon(IconButton` → `find.widgetWithIcon(AppIconButton`
  - Z. 558, 564, 576: `find.byType(CircularProgressIndicator` → `find.byType(AppLoading`
  - Z. 559, 575, 587, 628, 633, 642, 722, 726, 730, 764, 766, 775, 780, 787: `find.byType(LinearProgressIndicator` → `find.byType(AppProgressBar`
  - Z. 570, 588: `find.byType(Scaffold` → `find.byType(AppPage`
  - Z. 671: `find.byType(PopupMenuButton<VoidCallback>` → `find.byType(AppOverflowMenu`
- `test/ui/recipe_editor/ingredient_row_test.dart`
  - Z. 13: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 71: `find.widgetWithText(TextField` → `find.widgetWithText(AppTextField`
- `test/ui/recipe_editor/recipe_create_screen_test.dart`
  - Z. 11: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 57, 76, 108, 109, 158, 202: `find.widgetWithText(TextField` → `find.widgetWithText(AppTextField`
  - Z. 111, 160: `find.byType(FloatingActionButton` → `find.byType(AppFab`
- `test/ui/recipe_editor/recipe_editor_screen_test.dart`
  - Z. 16: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 140, 170, 174, 178, 226, 321, 339, 340, 358, 359, 360, 380: `find.widgetWithText(TextField` → `find.widgetWithText(AppTextField`
  - Z. 144, 228, 296, 467: `find.widgetWithText(ElevatedButton` → `find.widgetWithText(AppButton`
  - Z. 172, 230: `find.widgetWithText(TextButton` → `find.widgetWithText(AppButton`
  - Z. 342: `find.byType(DropdownButton<String>` → `find.byType(AppSelect<String>`
  - Z. 461, 542: `find.widgetWithText(TextFormField` → `find.widgetWithText(AppTextField`
  - Z. 574, 575, 576: `find.widgetWithText(Chip` → `find.widgetWithText(AppChip`
- `test/ui/recipe_list/recipe_list_screen_test.dart`
  - Z. 16: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 121: `find.widgetWithText(ElevatedButton` → `find.widgetWithText(AppButton`
  - Z. 167: `find.byType(TextField` → `find.byType(AppSearchField`
  - Z. 184: `find.byType(FloatingActionButton` → `find.byType(AppFab`
- `test/ui/settings/export_screen_test.dart`
  - Z. 13: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 91, 99, 134: `find.widgetWithText(DropdownButtonFormField<String>` → `find.widgetWithText(AppSelect<String>`
  - Z. 108: `find.widgetWithText(ElevatedButton` → `find.widgetWithText(AppButton`
- `test/ui/settings/import_screen_test.dart`
  - Z. 13: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 130, 148, 164, 183: `find.byType(TextField` → `find.byType(AppTextField`
  - Z. 186: `find.widgetWithText(ElevatedButton` → `find.widgetWithText(AppButton`
- `test/ui/versions/version_compare_screen_test.dart`
  - Z. 14: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 174, 317: `find.widgetWithText(ElevatedButton` → `find.widgetWithText(AppButton`
- `test/ui/versions/version_list_screen_test.dart`
  - Z. 13: Import `package:unsalted_design/unsalted_design.dart` ergänzt
  - Z. 133, 166: `find.widgetWithIcon(IconButton` → `find.widgetWithIcon(AppIconButton`
  - Z. 174, 275: `find.widgetWithText(TextButton` → `find.widgetWithText(AppButton`
  - Z. 234: `find.byType(ListTile` → `find.byType(AppListItem`

*Bewusst unverändert* (sie prüfen Eigenschaften des gerenderten
Material-Widgets; eine Umstellung hinge am Typ-Argument von
`tester.widget<…>` und würde die Prüfung selbst ändern — z. B. ist
`AppFab.onPressed` beim Laden gesetzt, das `onPressed` des FAB aber `null`):
`import_screen_test.dart:134`, `version_compare_screen_test.dart:249`,
`recipe_editor_screen_test.dart:524` (`widget<ElevatedButton>`),
`recipe_create_screen_test.dart:54, 60, 79`,
`food_editor_screen_test.dart:78, 84, 143` (`widget<FloatingActionButton>`),
`amount_calculator_test.dart:38, 50, 76`, `package_form_test.dart:118`,
`recipe_detail_screen_test.dart:512, 513` (Finder für `widget<TextField>`
in Z. 516, 519), `version_list_screen_test.dart:198`
(`widget<IconButton>`), `recipe_detail_screen_test.dart:229`
(`widgetList<ChoiceChip>`, liest `label`). Ebenso die drei Finder auf
`SnackBarAction` (`recipe_detail_screen_test.dart:681`,
`recipe_list_screen_test.dart:229`, `food_list_screen_test.dart:212`) —
dafür gibt es kein Design-Widget. Symbol-Finder (`find.byIcon(Icons.…)`)
sind keine Typ-Finder und bleiben. Der App-Test nutzt keine
Material-Typ-Finder. Core 386 Tests grün.

**C27b — deutsche Einheiten (F3).** `lib/src/ui/shared/unit_labels.dart`
aus `design/1.1` übernommen (`unitLabel`, `formatQuantity`, `formatAmount`).
Eingesetzt: Zutaten im Rezeptdetail („0,5 l“, „2 Stück · Notiz“,
„3 Prisen“), eingefrorene Ansicht des Editors, Vergleichsspalten
(„Ei: 2 Stück“), Zutatenzeile (Auswahlliste „Stück“ statt `piece`,
Mengenfeld startet mit Dezimalkomma; die Eingabe akzeptierte Komma schon
vorher). Gespeichert bleibt der Code. Neue Tests: UI-59
(`test/ui/shared/unit_labels_test.dart`, 6 Fälle) und UI-60 bis UI-63
(`test/ui/shared/german_units_display_test.dart`). *Gegenprobe:*
`unitLabel` liefert vorübergehend den Code → UI-60 bis UI-63 rot;
zurückgesetzt, grün. Kein bestehender Test erwartet einen englischen Code
als Anzeigetext; bestehende Tests unverändert.
*Bewusst nicht umgestellt (Abweichung, zur Entscheidung):*
`versions/change_descriptions.dart` nennt Einheiten seit 9.2a schon deutsch,
zeigt Mengen aber mit Dezimalpunkt („Mehl: 500 g → 0.5 kg“). Eine
Umstellung auf `formatAmount` würde `change_descriptions_test.dart:78`
ändern (erwartet „0.5 kg“) — das deckt die freigegebene Ausnahme
(englischer Code als Anzeigetext) nicht. Ebenso unverändert: Zahlenfelder
ohne Einheitencode (Backverlust, Fertiggewicht, Verpackungsformular).
Core 396 Tests grün.

**C29 — Anzeige-Schalter (UI-Konfiguration d1, F9).**
`lib/src/ui/config/core_ui_options.dart`: `CoreUiOptions` (`hiddenNutrients`,
`showBarcodeField`, `showAdvancedFields`, `showsNutrient`, Wertgleichheit)
und `coreUiOptionsProvider` (Standard = Verhalten vor Teil 1.2). Tür: eine
neue Exportzeile mit beiden Symbolen — die AT-06-Golden wächst damit um
**eine** Zeile (plus Kommentar), nicht um zwei wie im Plan formuliert; die
Golden-Datei führt Exportzeilen, nicht Symbole. Wirkung: `NutritionTable`
(Zeilen und Fußnoten; der Fußnotenblock entfällt, wenn nur Ausgeblendetes
unvollständig ist), `PackageForm` (Barcode; Dichte, Stückgewicht,
Portionsgröße, Natrium; Nährwertfelder, mit Salz auch Natrium), Rezept-Editor
(Backverlust, Fertiggewicht-Override). Bausteine bekommen die Optionen als
Parameter mit Standardwert; die Bildschirme (Rezeptdetail,
Lebensmittel-Editor, Rezept-Editor) lesen den Provider — so laufen die
bestehenden Baustein-Tests ohne `ProviderScope` unverändert. Warnungen
(F9b): eine Validator-Warnung entfällt, wenn eines ihrer Felder
ausgeblendet ist (Zuordnung Warnungsart → Felder in `PackageForm`); ein
ausgeblendetes Feld mit ungültigem oder negativem Wert wird eingeblendet.
App: `apps/unsalted_app/lib/config/ui_options.dart` (`uiOptions`, explizit
die Standardwerte, mit Beispielen im Kommentar); `main.dart` baut die
Overrides über `appOverrides(database:, modules:, options: uiOptions)` —
`Override` kommt in Riverpod 3.4.3 aus `package:flutter_riverpod/misc.dart`
(im Pub-Cache geprüft). Tests: UC-01 bis UC-06 auf Baustein-Ebene
(`test/ui/config/core_ui_options_test.dart`), UC-02/04/05 zusätzlich auf
Bildschirm-Ebene mit Speichern (`core_ui_options_screens_test.dart`), UC-07
in der App (`test/ui_options_test.dart`). *Gegenprobe:* Lebensmittel-Editor
ohne Optionen → UC-04 (Bildschirm) rot; zurückgesetzt, grün. Mit den
Standardwerten keine sichtbare Änderung.
*Beobachtung:* Ein Core-Testlauf blieb einmal mit zwei untätigen
`flutter_tester`-Prozessen stehen; drei Wiederholungen (mit
`--timeout 60s` und ohne) liefen vollständig grün durch (26 s bis 1:15 min).
Nicht reproduzierbar; vermutlich Rechnerlast bzw. ein Restprozess.
Stand: Design 212, Core 409, App 6, Widgetbook 6 Tests grün;
`check_architecture` Exit 0.

**C30 — Dezimalkomma in der ganzen Anzeige (Freigabe 2026-10-07).**
`change_descriptions.dart` formatiert Mengen, Backverlust und
Fertiggewicht-Override über `formatQuantity` aus `unit_labels.dart`; die
eigene Einheitenbenennung der Änderungsliste (9.2a) bleibt. Rezept-Editor
(Backverlust, Fertiggewicht-Override) und Verpackungsformular (alle
Zahlenfelder) sind mit `formatQuantity` vorbelegt; die Eingabe nahm Komma
und Punkt schon vorher an (`replaceAll(',', '.')`), daran ändert sich nichts.
Keine zweite Hilfsfunktion. Gespeichert, exportiert und im Snapshot bleibt
der unveränderte Decimal-Wert. `hasChanges` (10.0) vergleicht mit der
Komma-Vorbelegung als Ausgangszustand.
*Geänderte bestehende Testzeilen (freigegeben):*
`packages/unsalted_core/test/ui/versions/change_descriptions_test.dart:78`
„Mehl: 500 g → 0.5 kg“ → „Mehl: 500 g → 0,5 kg“ (UI-22, Zutatenmenge) und
`…/change_descriptions_test.dart:135` „Backverlust: 10 % → 12.5 %“ →
„Backverlust: 10 % → 12,5 %“ (UI-24, Backverlust) — jeweils nur der
erwartete Text, weil die Änderungsliste jetzt Dezimalkomma zeigt. Die
zweite Zeile wurde vor der Änderung gemeldet und einzeln freigegeben.
Neue Tests (`test/ui/shared/decimal_comma_test.dart`): UI-64
(Änderungsliste mit Komma inkl. Fertiggewicht 850,25 → 900,5 g, kein
Dezimalpunkt mehr), UI-65 (Verpackungsformular: Vorbelegung mit Komma,
Eingabe mit Komma und Punkt, `hasChanges` false bei Vorbelegung), UI-66
(Rezept-Editor: Vorbelegung 12,5 / 900,5, unverändertes Speichern, Eingabe
„7.5“ und „850,25“ wird als 7.5 / 850.25 gespeichert). *Gegenprobe:* die
drei Produktivdateien vorübergehend auf C29 → UI-64 bis UI-66 rot;
zurückgesetzt, grün. Stand: Design 212, Core 412, App 6, Widgetbook 6 Tests
grün; `check_architecture` Exit 0.

## 2026-10-17 — Teil 1.3: Gestaltung aus Figma (Plan freigegeben)

**Betroffenes Kapitel:** 4, 22, 23, 28 (neues 28.10 „Teil 1.3 – Gestaltung
aus Figma“, entsteht mit D03–D18).

**Ausgangslage.** Branch `design-1.3` von `main` @ `1022185`; vorab
`571da1e` (`.DS_Store` aus dem Repository, in `.gitignore`), Übergabe aus
Figma `c8bdfe3` (`docs/design/UEBERGABE.md`, `system/`, `figma/`), Plan
`docs/design/plan-1.3.md` (`af4ebbd`), Entwurfs-PR #2 `design-1.3` → `main`.
Figma-Abgleich Variablen ↔ `tokens.json` (nur gelesen): 158 Werte gleich,
Abweichungen A1–A4 (Plan, Abschnitt „Figma-Abgleich“).

**Entscheidung (Projektverantwortlicher, 2026-10-17):** Plan freigegeben.
F1 `material_ui` nicht vorher, eigener kleiner Teil nach 1.3. F2 deutsche
Systemtexte ja, eigener Commit in der App-Hülle (D17b). F3 Golden-Grundstand
ja (D01). F4 Seitenleiste ab 600 in 1.3; Liste/Detail nebeneinander als
eigener Teil 1.4; Rezeptdetail zweispaltig ab 1200 in 1.3. F5 Figma ist die
Quelle der `reflow`-Werte: Werte aus A1/A2 in beide Token-Dateien (Format
`"value": {"100": …, "200": …}`), eigener Commit D12a vor D12 mit
Figma-Abgleich; D12 nicht mehr gesperrt. F6 Die WOFF2 der Übergabe sind
vollständig (je 392 Glyphen, 362 Zeichen, Version 2.001 mit ttfautohint,
tnum); verlustfrei mit fontTools in TTF umwandeln, SHA-256, Version und
Glyphenzahl hier festhalten; R6 im Plan korrigiert. F7 Code-Schrift =
Systemschrift-Stapel, keine weitere Datei. F8 zwei Token-Dateien mit
Gleichheitstest. F9 Master = Markerfläche + Wort „Master“. F10 Pfeil als
Symbol, `describeChanges` unverändert. F11 Golden-Umfang ~136 Bilder. F12
Outlined-Symbole mit vorgezogenem Finder-Commit D05a. F13 Entwurfs-PR. F14
Versionen `unsalted_design` 0.2.0 und Tags `part1-v1.3.0`/`design-v0.2.0`
erst nach Freigabe.

**Zusätzlich vorgegeben:** (1) Goldens müssen vom Branch aus erzeugt werden
können, weil `workflow_dispatch` erst wirkt, wenn die Workflow-Datei auf
`main` liegt. *Gewählt:* `goldens.yml` reagiert auf `push` nach `goldens/**`;
GitHub liest den Workflow bei `push` aus dem gepushten Commit. Ein Commit
wird zuerst auf einen Hilfsbranch `goldens/dNN` gepusht, die Bilder kommen
als Artefakt zurück, werden mit `--amend` in denselben Commit gelegt, erst
dann geht der Commit nach `design-1.3`; der Hilfsbranch wird gelöscht.
*Verworfen:* Markierung „[goldens]“ in der Commit-Nachricht auf
`design-1.3` — der Code-Commit käme vor seinen Bildern in den PR, die CI des
PRs wäre für diesen Commit rot, und die Bilder bräuchten einen zweiten
Commit. Ablauf Schritt für Schritt: Plan, Abschnitt (d4). (2) DS-51: Die
Übergangsliste ist am Ende von Etappe 2 (D12) leer und der Mechanismus
entfernt, wie C27c.

**D01 — Golden-Grundlage und Grundstand (F3).** Neu: `.github/workflows/goldens.yml`
(Push auf `goldens/**`, zusätzlich `workflow_dispatch`; `ubuntu-24.04`,
Flutter 3.47.5: erst Vergleich mit den eingecheckten Bildern — Liste der
abweichenden Bilder in der Zusammenfassung und im Artefakt
`golden-vergleich` —, dann `flutter test --tags golden --update-goldens` in
Design und Core, Bilder als Artefakt `goldens`); `ci.yml` läuft fest auf
`ubuntu-24.04`. `dart_test.yaml` (Tag `golden`) in Design und Core. Harness
`test/goldens/support/golden_harness.dart` (in Core als Kopie, Pakete teilen
keine Testdateien): acht Varianten hell/dunkel × Handy 390 × 844 / Tablet
1024 × 1366 × Text 100/200 % über `textScaleFactorTestValue`; Schriften per
`FontLoader` nur hier (Roboto und Material-Symbole aus
`$FLUTTER_ROOT/bin/cache/artifacts/material_fonts`, lokal und in CI
geprüft), nicht global — sonst änderten sich die Textmaße aller übrigen
Tests. Überlauf ist in Goldens kein Fehler (er steht als Streifen im Bild),
jede andere Ausnahme schon; streng geprüft wird Überlauf in WB-01 und ab D12
in WB-04. Schatten bleiben wie von `flutter_test` vorgegeben schwarze Kontur
(`debugDisableShadows`, für stabile Bilder). GL-01
(`test/goldens/gl01_catalog_golden_test.dart`): 13 Motive aus dem Katalog
(Farbe, Typo, Aktionen, Text/Symbole, Flächen, Eingaben, Listen/Chips,
Rückmeldung, Navigation, Daten, drei Templates, auf der Listenseite mit
„Rückgängig“-Meldung) = 104 Bilder; Plan F11 nannte 12 Motive, Farbe und
Typo sind getrennt, weil beide zusammen am Handy nicht auf eine Seite passen.
GL-02 (`test/goldens/gl02_screens_golden_test.dart`, Daten aus
`support/screen_fixtures.dart`: Rezept „Hefezopf klassisch“ mit V1/V2
eingefroren, V2 Master, V3 Entwurf, drei Lebensmittel, zweites Rezept):
Bildschirme 1, 3, 4, 8, 10 = 40 Bilder. Alle Golden-Dateien tragen
`@TestOn('linux')` und `@Tags(['golden'])`; auf dem Mac nicht geladen.
*Bilder:* Lauf `38976239721` (Hilfsbranch `goldens/d01`), 144 Bilder, mit
`--amend` in den Commit. *Prüflauf* (`goldens/d01-pruefung`, fertiger
Commit, Lauf `38976710765`): 0 abweichende Bilder, die neu erzeugten 144 Bilder byte-gleich mit den eingecheckten — Erzeugen und Vergleichen unter Linux sind deterministisch. *Gegenprobe*
(`goldens/d01-gegenprobe`, Wegwerf-Commit mit `primary` hell = `#00A000`,
Lauf `38976726542`): 24 abweichende Bilder, genau die hellen Varianten von
Aktionen, Rückmeldung, Formular-Template, Farbtabelle, Rezept-Editor und
Versionsvergleich; dunkle Varianten und Motive ohne `primary` unverändert.
Hilfsbranches danach gelöscht.
*Befunde im Grundstand (heutiges Verhalten, nicht behoben):* (1)
Versionsvergleich am Handy: die Spalte B läuft schon bei 100 % über
(Streifen unter der Schrittliste). (2) Der Pfeil → der Änderungstexte
erscheint als Ersatzzeichen, weil die Testschrift ihn nicht hat (auf dem
Gerät aus der Systemschrift) — wird mit D14 Symbol. (3) Bei 200 % schneiden
Editor-Zeilen und Nährwertkopf ab (D12). Mac: Design 212, Core 412, App 6,
Widgetbook 6 Tests grün (Goldens dort nicht geladen); `check_architecture`
Exit 0.

**D02 — Schrift und Lizenz.** Die drei WOFF2 der Übergabe
(`docs/design/system/fonts/`) mit fontTools 4.60.2 (`woff2.decompress`, mit
brotli) verlustfrei in TTF umgewandelt. Gemessen an WOFF2 und TTF gleich: je
392 Glyphen, 362 Zeichen, Version „Version 2.001; ttfautohint
(v1.8.4.7-5d5b)“, `tnum` vorhanden, alle Tabellen außer `head` inhaltlich
identisch; Gewicht (OS/2) 400/600/700. SHA-256 der TTF:

| Datei | Bytes | SHA-256 |
|---|---|---|
| `AtkinsonHyperlegibleNext-Regular.ttf` | 64 656 | `4b3bfd9de494d727fd0c3459a438b290b108c5684debe2258a93f142a6b479ff` |
| `AtkinsonHyperlegibleNext-SemiBold.ttf` | 66 268 | `ad0d0607aebc2b4715149d88dae2a1713b8e5f4272715feb729276ae97731d20` |
| `AtkinsonHyperlegibleNext-Bold.ttf` | 66 400 | `fb0fb12e976161da3d9ae0eebe9c66137431922b660b2b0129965d48b946ea88` |

Quelle (WOFF2, SHA-256): Regular `378aea0f5c1d179f4e0b5382c06bfc87571b98cfcc4fd1352bc979e2e2259c54`,
SemiBold `4ab00275cc496a478fce7baafe89ed44af875acf57655dfd1183ff22bd23829a`,
Bold `dda449f0f556a595cffd0a9ce479bb1210beba286cb4c2f5aeca6975f9c85a3b`.
`OFL.txt` = `docs/design/system/assets/Lizenzen/OFL-Atkinson-Hyperlegible-Next.txt`.
Der Schrift fehlen → ← ↑ ↓ ✓ ★ µ und U+202F; vorhanden sind u. a. U+00A0,
– — „ “ … · × €. `pubspec.yaml` des Design-Pakets deklariert die Familie
`AtkinsonHyperlegibleNext` (Gewichte aus den Dateien) und `lib/fonts/OFL.txt`
als Asset; Abhängigkeiten unverändert nur `flutter`. `AppFonts`
(`lib/src/theme/app_fonts.dart`, über die Tür): `family`, `package`,
`qualifiedFamily` (`packages/unsalted_design/AtkinsonHyperlegibleNext`),
`licenseAsset`, `registerLicenses()` (`LicenseRegistry`, Text erst beim
Öffnen der Lizenzseite gelesen); aufgerufen in `apps/unsalted_app/lib/main.dart`.
Katalog: Eintrag `AppFonts` (drei Schnitte), damit WB-02 ohne neue Ausnahme
grün bleibt. Golden-Harness (Design und Core) lädt die Schrift zusätzlich
unter `qualifiedFamily`; das Theme nutzt sie erst ab D03, die Bilder bleiben
gleich. Neue Tests: DS-49 (`test/typography/ds49_glyph_coverage_test.dart`,
Zeichentabelle per eigenem `cmap`-Leser, Format 4 und 12): drei Schnitte mit
gleicher Tabelle (362 Zeichen), fehlende und vorhandene Zeichen wie oben,
und alle Zeichen außerhalb von Kommentaren — wörtlich oder `\uXXXX` — in
`unsalted_design/lib/` und `unsalted_core/lib/src/ui/` haben eine Glyphe;
einzige Ausnahme der Pfeil in `versions/change_descriptions.dart` (bis D14
noch als Text gezeichnet). DS-50 (`ds50_font_license_test.dart`): Schriften
und Lizenz in `pubspec.yaml` deklariert, `registerLicenses` lädt genau
`packages/unsalted_design/lib/fonts/OFL.txt` (Asset-Kanal im Test bedient,
weil das Paket im eigenen Test die Wurzel ist und der Schlüssel dort kein
Präfix hätte) und registriert die OFL. *Gegenprobe DS-49:* „★“ vorübergehend
in `version_tile.dart` → rot mit genau dieser Zeile; zurückgesetzt, grün.
Gefundene Zeichen außerhalb von ASCII heute (alle mit Glyphe): Umlaute, ß,
– — „ “ … · ×, U+00A0.
*Nachtrag zu D02:* Golden-Lauf `38977364693` (Hilfsbranch `goldens/d02`):
0 abweichende Bilder, neu erzeugte Bilder byte-gleich — die Schrift lädt
unter Linux, das Theme nutzt sie noch nicht.

**D03 — Token-Datei, Generator, Theme-Zuordnung.**
`packages/unsalted_design/tokens/unsalted.tokens.json` = Kopie von
`docs/design/system/tokens.json` (byte-gleich, F8). Generator
`tool/generate_tokens.dart` (nur `dart:convert`/`dart:io`, außerhalb von
`lib/`; DS-01 und `check_architecture` prüfen nur `lib/`): liest die JSON,
löst Aliase auf und schreibt zehn Dateien `lib/src/tokens/*_tokens.g.dart`;
nicht mehr erzeugte Dateien löscht er. *Abweichung vom Plan:* Statt
Hand-Dateien neben dem Generat ist der ganze Ordner `lib/src/tokens/`
generiert — die Hilfslogik (`AppSpace`, `AppMotion.reduceMotion`/`durationOf`)
kommt als feste Vorlage aus dem Generator, dazu
`AppMotion.emphasized = Curves.easeInOutCubicEmphasized`, das laut Hinweis
der Token-Datei (`easing.note`) nur im Code bleibt, bis eine Komponente es
braucht. *Abweichung vom Plan:* Die `reflow-*`-Grundwerte stehen in einer
eigenen Klasse `AppReflow`, weil `reflow-value-column` und
`size-value-column` sonst beide `AppSize.valueColumn` hießen. Umrechnung:
`px` → `double`, `ms` → `Duration`, `cubic-bezier` → `Cubic`, CSS-Farbe
`#rrggbbaa` → `0xAARRGGBB`, CSS-Schatten → `List<BoxShadow>` in umgekehrter
Reihenfolge (CSS zeichnet den ersten oben, Flutter den letzten; der
Fokusring hat so den Spalt in Papierfarbe oben). Tabellarische Ziffern
(`FontFeature.tabularFigures()`) für die Gruppe „Daten“ und jeden Stil,
dessen Hinweis `tnum` nennt — ergibt display, label-small, data,
data-strong wie in 02. `code` nutzt den Systemschrift-Stapel der JSON
(`ui-monospace` mit Rückfall `SF Mono`, `Menlo`, `Consolas`, `monospace`;
F7). Die Verwendungshinweise der JSON kommen nicht in die Doku-Kommentare:
sie nennen Fachbegriffe, DS-06 prüft auch Kommentare. Primitive stehen in
`AppColorPrimitives` (nicht über die Tür), Rollen in `AppColorTokens`
(28 Rollen, `light`/`dark`, `byFigmaName`). Tür: `*.g.dart`-Pfade; neu
`AppStroke`, `AppSize`, `AppReflow`, `AppOpacity`, `AppShadow`; `AppElevation`
entfällt (Golden-Liste DS-03 bewusst nachgeführt, CHANGELOG). `AppTheme`
(`lib/src/theme/app_theme.dart`): `colorSchemeOf` bildet alle 46
Material-Rollen nach der Tabelle in 01 ab (Primitive nur, wo 01 sie nennt:
`secondaryFixed…`, `tertiaryFixed…`, `surfaceBright` hell, `onTertiary`/
`onError` dunkel), `textTheme` die 15 Textrollen nach 02;
`fontFamily: AppFonts.qualifiedFamily`. Komponenten importieren die
`*.g.dart`-Dateien; `AppRadius.m`/`.xs` in `AppNotice` und `AppSkeleton`
behalten ihre Namen, bekommen aber die neuen Werte (8 bzw. 2).
*Tests:* DS-04 neu gefasst (`ds04_tokens_complete_test.dart`, Z. 1–76
ersetzt, „Bewegung reduzieren“ unverändert): Token-Datei = Übergabe,
`lib/src/tokens/` = Generat (Dateien und Inhalt), Farbrollen und Textstile
gegen die JSON, Zahlengruppen und Namensregel 05, Fokusring-Reihenfolge,
Generator stabil. DS-05 neu gefasst: die 24 Paare aus 01 mit Mindestwert
(Text 4,5, Kontur 3) und dem in 01 genannten Wert (±0,01) je Modus, dazu die
zwei begründeten Ausnahmen (Marker auf Papier hell 1,19; Punktraster).
DS-07 neu (`test/theme/ds07_theme_mapping_test.dart`, ersetzt
`ds07_neutral_theme_test.dart`): 46 Farbrollen und 15 Textrollen gegen die
Tabellen; `dividerColor` leitet Flutter 3.47.5 aus `outline` ab — die
Trennerfarbe setzen die Komponenten-Themes (D04, DS-52). DS-51 neu
(`test/architecture/ds51_no_numbers_in_components_test.dart`): keine Zahlen
für Maße in `components/`, `layout/`, `templates/`, `theme/` (benannte
Maß-Parameter, `EdgeInsets`, `Radius`, `Size`, `Offset`, `Duration`,
`FlexColumnWidth`, Literale ab zwei Stellen, Bruchzahlen; 0 und einstellige
Zählwerte erlaubt), Selbsttest mit 17 Verstößen und 14 erlaubten Fällen;
Übergangsliste (8 Dateien, 12 Stellen): `app_fab.dart`,
`app_key_value_table.dart`, `app_dialog.dart`, `app_notice.dart`,
`app_skeleton.dart`, `app_icon.dart`, `app_text_field.dart`,
`app_top_bar.dart`. Geänderte bestehende Testzeilen (Plan d2 D03):
`apps/unsalted_widgetbook/test/catalog_test.dart:22–23` (Ausnahmeliste:
neue Token-Klassen statt `AppElevation`), `apps/unsalted_app/test/theme_test.dart:48`
(`expected.surface` → `expected.surfacePage`), dazu die drei DS-Dateien
oben. Katalog `catalog/tokens.dart`: Linie, Größe, Deckkraft, Schatten statt
Höhe. *Gegenprobe DS-04:* `space-l` in der Token-Datei auf 18px, nicht neu
generiert → drei DS-04-Tests rot (Übergabe, Generat, Zahlengruppen);
zurückgesetzt, grün; Generator zweimal → kein Unterschied. Kapitel 28.10
angelegt (Punkte 1, 12, 13). Mac: Design 224, Core 412, App 6, Widgetbook 6
Tests grün; `check_architecture` Exit 0. *Goldens:* Lauf `38978048474`
(`goldens/d03`): 144 von 144 Bildern geändert (Farben, Schrift, Radien;
Komponenten-Themes folgen in D04). Der Stil `code` erscheint in den
Linux-Bildern als Ersatzkasten, weil der Runner keine Monospace-Systemschrift
hat (Folge von F7, auf Geräten die Systemschrift).

**D04 — Komponenten-Themes.** Neu `lib/src/theme/component_themes.dart`
(`AppComponentThemes`, nicht über die Tür): je Material-Widget, das die
Komponenten bauen, Fläche, Kontur, Ecke, Innenabstand, Mindesthöhe,
Schrift und Zustände aus Tokens nach 07 (Abschnitt 7) und den
Komponentenkarten. Zustände: Überlagerung in der Inhaltsfarbe mit
`opacity-hover` (Hover, Fokus) bzw. `opacity-pressed` (Drücken);
deaktiviert `surface-sunken`/`text-disabled` bzw. Kontur `line-hairline`.
Primärbutton `ElevatedButton` (Tintenfläche, elevation 0), Sekundär
`OutlinedButton` (Kontur `line-strong`, `stroke-frame`), Tertiär `TextButton`
(Innenabstand `space-m`), alle `radius-s`, Mindesthöhe `size-control`,
`body-strong`, Symbol `size-icon-small`. Marker-Knopf: Markerfläche,
Tintenkontur `stroke-frame` in `text-on-marker`, alle Höhen 0,
`size-fab`. Eingabefeld gefüllt (`surface-raised`, deaktiviert
`surface-sunken`), Kontur `line-control` 1 px, Fokus `line-focus` und Fehler
`text-error` in `stroke-focus`, Innenabstand `space-m` (48 = `size-control`
bei `body`). Chips: `surface-raised` mit Kontur `line-control`, gewählt
`surface-inverse` mit `text-inverse` und Häkchen; Innenabstand `space-xs` +
Beschriftung `space-s` = `space-m`. Listeneintrag: Titel `body-strong`,
Untertitel `body-small`/`text-secondary` (02), `size-list-item`, Innenabstand
`space-l`/`space-m`; bewusst ohne `textColor` — `ListTile` färbt damit auch
den Untertitel (im ersten Golden-Lauf `38978822725` gesehen: Untertitel in
Tinte; Lauf verworfen, nicht eingecheckt). Trenner Haarlinie (`dividerTheme` und `dividerColor` —
`ThemeData` leitet sie sonst aus `outline` ab). Meldung: invers,
`action-inverse`, `radius-s`, `SnackBarBehavior.floating` mit Breite
`size-dialog` (Snackbar-Karte „höchstens size-dialog breit“; schwebend steht
sie über dem FAB statt ihn zu verschieben). Dialog `surface-raised`,
Haarlinie, `radius-m`, Scrim `scrim` mit `opacity-scrim`. Menü und Karte
`surface-raised`, Haarlinie, flach. Ladekreis/-balken `text-primary`, Spur
`line-hairline`, Balken `stroke-rule`, Kreis `stroke-focus`. Kopfleiste
`surface-page`, flach, `size-top-bar`, Haarlinie unten als `shape`.
Navigationsleiste `surface-page`, `size-nav-bar`, Pille in Seitenfarbe (also
unsichtbar), gewählt `text-primary`, sonst `text-secondary` — der
Auswahlbalken kommt mit der eigenen Komponente in D10. Tooltip invers,
`label-small`. `VisualDensity.standard` und `MaterialTapTargetSize.padded`
fest, damit Maße auf macOS (Widgetbook) wie auf dem Handy den Tokens
entsprechen. *Nicht mit Material-Themes ausdrückbar* und deshalb in den
Komponenten (D06–D10): `shadow-overlay` an Menü, Dialog und Meldung (Material
kennt nur `elevation`), Fokusring mit Spalt (`shadow-focus`), Beschriftung über
dem Feld, Auswahlbalken der Navigation, Tag mit `radius-xs`. Farben ohne
`Colors.*` (DS-02): wo ein durchsichtiger Wert nötig wäre, steht die
Seitenfarbe (Pille der Navigationsleiste). Neu DS-52
(`test/theme/ds52_component_themes_test.dart`): Werte der Themes je Modus
gegen die Tokens, ein gebauter Listeneintrag (Untertitel `text-secondary`,
Titel `text-primary`) und ein gebauter Primärbutton (Fläche `action-primary`,
Höhe ≥ `size-control`) in allen vier Varianten; *Gegenprobe:* `textColor`
vorübergehend wieder im Theme → der Listeneintrag-Fall rot. DS-51: Die Regel für
`Size(…)`/`Offset(…)` meldet nur noch Literale ungleich 0 (vorher auch
`Size(0, AppSize.control)`), Selbsttest um diesen Fall ergänzt — Änderung an
einem in D03 eingeführten Test. Keine bestehende Testzeile geändert: Die
Komponenten bauen dieselben Widgets, die Material-Prüfungen aus C28 bleiben
(Plan d3). Kapitel 28.10.2. Mac: Design 240, Core 412, App 6, Widgetbook 6
Tests grün; `check_architecture` Exit 0. *Goldens:* Lauf `38979853362`
(`goldens/d04`): 112 Bilder geändert — alle Motive mit Buttons, Feldern,
Chips, Listen, Meldung oder Kopfleiste; unverändert nur Farbtabelle,
Typografie, Text/Symbole und Daten. Bekannter Zwischenstand bis D08: Die
schwebenden Beschriftungen sitzen in der Kontur der Felder, und gestapelte
Felder liegen ohne Abstand aneinander (Beschriftung über dem Feld folgt mit
`AppTextField`).

**D05a — Symbol-Finder in Tests (F12).** Vor der Umstellung auf
Outlined-Symbole zeigen die Finder auf `AppIcons` statt auf `Icons`, damit
D05b keinen Test berührt. Geänderte Zeilen (je nur der Symbolname,
maschinell geprüft: ohne Symbolnamen sind alte und neue Zeile gleich, 11
Zeilen):
- `packages/unsalted_core/test/ui/versions/version_list_screen_test.dart:133`
  `Icons.copy` → `AppIcons.copy`; `:166` `Icons.delete_outline` →
  `AppIcons.deleteOutline`; `:198` `Icons.compare_arrows` → `AppIcons.compare`
  (Typ `IconButton` in `widget<…>` bleibt, Plan d3)
- `packages/unsalted_core/test/ui/recipe_editor/ingredient_row_test.dart:120`
  `Icons.search` → `AppIcons.search`
- `packages/unsalted_core/test/ui/recipe_editor/recipe_editor_screen_test.dart:176`
  `Icons.delete_outline` → `AppIcons.deleteOutline`; `:348, 349`
  `Icons.drag_handle` → `AppIcons.dragHandle`; `:396` `Icons.search` →
  `AppIcons.search`
- `apps/unsalted_app/test/widget_test.dart`: Import
  `package:unsalted_design/unsalted_design.dart` ergänzt (neue Z. 12, die
  folgenden Zeilen rücken um eins); Z. 39 (vorher 38) `Icons.restaurant` →
  `AppIcons.restaurant`, Z. 44 (43) `Icons.settings` → `AppIcons.settings`,
  Z. 50 (49) `Icons.menu_book` → `AppIcons.book`.
Die drei übrigen Core-Testdateien importieren die Design-Tür schon seit C28.
`Icons.star` in `version_list_screen_test.dart:96, 249, 254, 281` bleibt
(Master-Stern, ändert sich mit D13); `Icons.info` in
`recipe_detail_menu_context_test.dart:78, 90` ist Eingabe einer
Modul-Aktion, kein Finder. Vorher und nachher grün (Core 412, App 6), weil bis
D05b `AppIcons.x == Icons.x` gilt.

**D05b — Symbole Outlined (F12).** `AppIcons` zeigt auf die
Outlined-Varianten der mitgelieferten Material Icons (UEBERGABE Punkt 4: bis
zum eigenen Linienset; Material Symbols bräuchten eine eigene Schriftdatei)
und führt alle 32 Namen der Figma-Bibliothek in der Reihenfolge von
`docs/design/figma/figma-ids.json`; neu `timer` (`timer_outlined`), `arrow`
(`arrow_forward_outlined`), `back` (`arrow_back_outlined`), `lock`
(`lock_outlined`), `more` (`more_vert_outlined`), `close`
(`close_outlined`), `undo` (`undo_outlined`), `chevron`
(`expand_more_outlined`, für das Auswahlfeld), `link` (`link_outlined`),
`photo` (`photo_outlined`), `swap` (`swap_horiz_outlined`). Alle Namen im SDK
geprüft. `delete-outline`, `info`, `error` und `star-outline` waren schon
Umrisse und bleiben; `star` bleibt gefüllt als Gegenstück zu `star-outline`
(markiert/markieren; der Master-Stern entfällt ohnehin mit D13). DS-17 um
einen Fall ergänzt (bestehende Zeilen unverändert, nur Importe und Kopf
erweitert): Namen = die 32 Symbole aus `figma-ids.json`, Stichproben
Outlined. Keine Testzeile in Core oder App geändert (dank D05a).
*Gegenprobe:* `widget_test.dart:39` vorübergehend wieder `Icons.restaurant`
→ App-Rauchtest rot; zurückgesetzt, grün. *Figma-Abgleich:* Namen 32/32
(DS-17); ein Sichtvergleich der Symbolseite (`21:388`) per Bild war nicht
aussagekräftig (schwarze Symbole auf dunkler Seite). Bekannte, in der
Übergabe festgelegte Abweichung: Figma zeigt Material Symbols mit Gewicht
300, der Code die Material Icons Outlined (Strich etwas kräftiger). Mac:
Design 241, Core 412, App 6, Widgetbook 6 Tests grün;
`check_architecture` Exit 0. *Goldens:* Lauf `38982743613` (`goldens/d05b`):
48 Bilder geändert (Aktionen, Navigation, Rückmeldung, Detail-Template,
Text/Symbole, Rezeptdetail); Motive, deren Symbole in der Outlined-Variante
gleich aussehen (`add`, `search`, `drag-handle`), unverändert. Beobachtung:
`delete` (`delete_outlined`) und `delete-outline` (`delete_outline`) sehen
jetzt gleich aus (Papierkorb-Umriss); beide Namen bleiben, bis das eigene
Linienset sie unterscheidet.

## 2026-10-17 — Teil 1.3, Etappe 2 (freigegeben)

**Freigabe Etappe 1 und Vorgaben für Etappe 2 (Projektverantwortlicher):**
Etappe 1 geprüft und freigegeben; weiter mit D06–D12, D12a vor D12.
Zusätzlich: Überlauf der Spalte B im Versionsvergleich am Handy — Ursache
finden und, wenn ohne Änderung der Bildschirm-Datei möglich, im passenden
Commit mit Test beheben; Papierkorb doppelt — in Figma prüfen, nur
berichten, keinen Namen entfernen; Ersatzkästchen der Code-Schrift in den
Linux-Goldens akzeptiert (Vermerk hier genügt: siehe D03); am Ende von D12
DS-51-Übergangsliste leer und Mechanismus entfernt, WB-04 (200 %) grün;
Hilfsbranches `goldens/*` nach jedem Lauf löschen.

*Ursache Überlauf Versionsvergleich (Befund aus D01):* `DetailSplit` legt den
oberen Bereich in ein `Expanded` (halbe Höhe); der Abschnitt
`version_compare_columns_section.dart` ist eine `Row` aus zwei
`SnapshotColumn` (`AppStack` ohne Scrollen). Sind die Spalten höher als die
halbe Seite, laufen sie über. Behebbar im Template (`DetailSplit`: oberer
Bereich scrollt), ohne Bildschirm-Datei → D11.

**D06 — Komponenten I: Aktionen, Text, Flächen.** `AppFab`: Ladekreis
`size-icon-small` mit Strich `stroke-focus` (vorher 20/2 von Hand; von der
DS-51-Liste gestrichen). `AppChip` (Tag, Chip-Karte): weiter ein
Material-`Chip` (DS-31 sucht ihn), aber Höhe `size-mark` über
`VisualDensity(vertical: VisualDensity.minimumDensity)` — Flutters Chip ist
mindestens `32 + Dichte/2` hoch —, Kontur `line-control` 1 px über `shape`
(über `side` rechnet Flutter die Kontur als Innenabstand hinzu: 26 statt 24,
gemessen), `radius-xs`, Fläche durchsichtig, `label-small` mit
tabellarischen Ziffern, Innenabstand `space-s`, optional `icon`
(`size-icon-xs`, Abstand `space-xs`) — additiv. `AppText`: alle elf Stile
als benannte Konstruktoren (neu `display`, `titlePage`, `heading`,
`bodySmall`, `labelSmall`, `data`, `dataStrong`, `code`; `AppTextRole`
additiv erweitert); `strong` setzt nur noch den Schnitt von `body-strong`
(600) und übernimmt Größe und Zeilenhöhe der Umgebung; `title` und
`caption` lesen weiter die Material-Rollen (`titleMedium` = `body-strong`,
`bodySmall` = `caption`). `AppDivider.rule()`: Abschnittslinie
(`stroke-rule`, `line-strong`, ohne Abstand); `AppDivider.flush()` jetzt
`stroke-hairline` hoch statt 1 von Hand. `AppSection` nach der Section-Karte:
`space-xxl`, Abschnittslinie, `space-m`, Überschrift `heading`, optional
`meta` rechts (`caption`, `text-secondary`, additiv), `space-s`, Inhalt;
ohne Trennlinie entfallen Abstand und Linie. `AppStack` additiv mit
`textBaseline` (Überschrift und Metadaten auf einer Grundlinie). Intern
`lib/src/theme/app_colors.dart`: `AppColors.of(context)` liefert die
Farbrollen passend zur Helligkeit des Themes (Rollen außerhalb des
`ColorScheme`, z. B. `line-strong`); ohne ThemeExtension, damit es auch unter
einem `MaterialApp` ohne Design-Theme gilt. *Nicht geändert:* `AppButton`,
`AppIconButton`, `AppChoiceChip`, `AppCard` (Gestalt aus D04); `AppSurface`
bleibt ohne Rundung, weil DS-19/DS-20b dort `ColoredBox` prüfen.
*Geänderte bestehende Testzeilen:* `packages/unsalted_design/test/components/ds18_text_test.dart:30`
`FontWeight.bold` → `FontWeight.w600` (geplant, `strong` = `body-strong`);
zusätzlich, nicht im Plan: `packages/unsalted_design/test/components/ds40_navigation_test.dart:114`
`FontWeight.bold` → `FontWeight.w600` — der Tabellenkopf nutzt `AppText.strong`
und wird mit D10 `label-small`, ebenfalls 600. *Neue Tests:* DS-18b (die
acht neuen Stile), DS-22b (Abschnittslinie `stroke-rule`/`line-strong`,
Überschrift `heading`, Metadaten `text-secondary`, Abstände), DS-31b (Tag
24 hoch, Kontur, Radius, `label-small` tnum, Symbol). Katalog: neue Stile,
Tag mit Symbol, Abschnitt mit Metadaten. DS-51: 7 Dateien auf der Liste.
Mac: Design 253, Core 412, App 6, Widgetbook 6 Tests grün;
`check_architecture` Exit 0. *Goldens:* Lauf `39010713758` (`goldens/d06`): 80 Bilder
geändert (Abschnittslinie und Überschriften in Formularen und Detail, Tag,
Text-Stile). *Papierkorb doppelt (Figma, nur gelesen):* `Icon/delete`
(`149:4`) und `Icon/delete-outline` (`205:2`) sind in Figma dasselbe Symbol —
gleiche Vektordaten (Material Symbols Outlined 300, Papierkorb), byte-gleiches
Bild; nur die Beschreibungen unterscheiden sich („Löschen (Papierkorb). In
List/Swipe to Delete und Menüs“ bzw. „Material Symbols Outlined 300“). Der
Code entspricht damit Figma; beide Namen bleiben.

**D07 — Markenelemente.** Neu unter `lib/src/components/brand/` (fachneutral
wegen DS-06, Karten Mark, Frame, Highlight, Value): `AppMark` mit
`AppMarkState` (`provisional`: Strichlinie `state-draft`, Text
`text-secondary`; `fixed`: Kontur `state-frozen`, Text `text-primary`;
`highlighted`: Fläche `state-master`, Text und Kontur `text-on-marker`), Höhe
mindestens `size-mark`, `label-small` tnum, `radius-xs`, `stroke-frame`,
optional Siegel `lock`; Semantik = `semanticLabel` des Aufrufers. Mit
`onTap` ist sie ein Auswahlziel nach Figma `Core/Version Switcher`
(mindestens `size-target`, oben `space-xs`, Abstand `space-xs`, gewählt ein
Balken `stroke-rule` in `line-strong` in voller Zielbreite, Semantik
`button`/`selected`) — damit baut Core in D13 die Fassungsleiste, ohne selbst
zu zeichnen (AT-14). `AppFrame.provisional`/`.fixed` (benannte
Konstruktoren statt Enum): Kontur gestrichelt bzw. durchgezogen,
`radius-s`, Innenabstand `space-m`/`space-l`, Abstand `space-s`, Kopfzeile
aus Marke und Zustandswort (`label-small`, `text-secondary`). `AppSlot`
(Leerstelle): Strichlinie, Punktraster als Hintergrund (abschaltbar für
„keine Treffer“), Symbol `size-icon`, Satz `body`, eine Aktion, Innenabstand
`space-xl`/`space-l`. `AppDashedUnderline`: gestrichelte Unterstreichung für
noch nicht verknüpfte Einträge (D16). `AppHighlight`: `marker`,
`text-on-marker`, `radius-xs`, seitlich `space-xxs`. `AppChangeText`
(Gegenstand `body-strong`, alt `text-secondary` durchgestrichen in
`stroke-frame`, Symbol `arrow` `size-icon-xs`, neu als `AppHighlight`;
hinzugefügt nur Marker, entfernt nur Strich, Klartext über `note`;
Semantik = `semanticLabel`, Einzelteile ausgeschlossen). `AppValue` mit
`AppCertainty` und `.strong`/`.display`: Zahl im Datenstil mit tnum, Einheit
nach U+00A0 in `text-secondary` (400, bei `display` `body-strong`), unbekannt
„—“, unvollständig „*“ fett. Intern `dashed_painter.dart` (Muster
`stroke-dash`/`stroke-gap` per `PathMetric` entlang abgerundeter Kontur oder
Unterstreichung) und `dot_pattern.dart` (Punkte `size-dot` in `line-dot`,
Abstand `space-xl`, erster Punkt `space-l` von der Kante). Tür und
Golden-Liste DS-03 um vier Zeilen ergänzt, CHANGELOG. Neue Tests DS-53 bis
DS-58 (`test/components/ds53_brand_test.dart`, 32 Fälle; u. a. Punktraster
dunkel in `line-dot` dunkel, Pfeil nur bei alt → neu, „—“ nie „0“).
Katalog: Ordner `brand` mit allen Elementen; GL-01 neues Motiv „marken“
(8 Bilder). *Geänderte bestehende Testzeile:* keine; in
`apps/unsalted_widgetbook/test/catalog_test.dart` ist nur eine Zeile
**hinzugekommen** (`'AppMarkState', 'AppCertainty'` in der Ausnahmeliste
der Parametertypen für WB-02). Mac: Design 285, Core 412, App 6,
Widgetbook 6 Tests grün; `check_architecture` Exit 0. *Goldens:* Lauf `39011115616`
(`goldens/d07`): 8 neue Bilder (Motiv „marken“). Der Vergleichsschritt meldete
zusätzlich „listen_chips“ (8 × 342 Pixel), die dort neu erzeugten Bilder sind
aber pixelgleich mit den eingecheckten (nur die PNG-Bytes unterscheiden
sich) — nicht übernommen. Vermutete Ursache: Die „marken“-Tests liefen im
Vergleich rot (noch kein Bild), und nach einem roten Test lässt
`flutter_test` den Widget-Baum stehen (CLAUDE.md, Abschnitt 4). Nachweis über
die PR-CI, in der alle Bilder vorhanden sind.

**D08 — Eingaben und Listen.** `AppTextField` (TextField-Karte): Beschriftung
`space-xs` über dem Feld in `label-small`/`text-secondary` statt schwebend;
semantisch hängt sie per `Semantics(label:)` am Feld, die sichtbare
Beschriftung ist ausgenommen. Erster Versuch mit `MergeSemantics` verworfen:
Er zog eine Schaltfläche am Feldende (`suffix`, z. B. Suche) in den Knoten des
Textfelds, Flutter brach mit `node.isMergedIntoParent` ab (WB-01, „Input/Text
Field“ mit Aktion). Zahlenfelder (`TextInputType.number`) in `data`,
rechtsbündig; neu `unit` (Einheit im Feld, `text-secondary`, additiv); Fehler
als Zeile mit Symbol `error` (`size-icon-xs`, Abstand `space-xs`) und Text
`caption`/`text-error`; Hilfetext `caption`; schmal = `reflow-field-min`
(120, von der DS-51-Liste gestrichen). `AppSelect`: Beschriftung über dem
Feld wie oben, Symbol `chevron`. `AppSearchField` unverändert (Gestalt aus
dem Theme). `AppListItem` (ListItem-Karte): Haarlinie unten in
`line-hairline`; neu `selected` (additiv) mit Auswahlbalken `stroke-rule` in
`line-strong` links — für Liste/Detail (Teil 1.4) vorbereitet. Umsortieren
ohne Ziehen (WCAG 2.5.7): Flutters `ReorderableListView` bietet die
Bedienhilfe-Aktionen „nach oben/unten/an den Anfang/an das Ende“ selbst (Texte
aus `MaterialLocalizations`, mit D17b deutsch) — keine eigene Umsetzung,
DS-29b sichert sie. *Fehler aus D06 behoben:* Der Tag zeigte keine Kontur —
Flutters `Chip` ersetzt die Kontur aus `shape` durch den `side`-Parameter, und
`BorderSide.none` entfernt sie; DS-31b prüfte nur den Parameter. Jetzt zeichnet
eine Vordergrund-Dekoration um den Chip die Kontur (`line-control`,
`stroke-hairline`, `radius-xs`), die Höhe bleibt `size-mark`; DS-31b prüft die
gezeichnete Kontur. *Geänderte bestehende Testzeilen* (alle nur der Finder:
das Material-Feld innerhalb der `App…`-Komponente mit der Beschriftung, weil
die Beschriftung nicht mehr im Material-Feld steht):
`packages/unsalted_core/test/ui/nutrition/amount_calculator_test.dart:38, 50, 76`,
`packages/unsalted_core/test/ui/foods/package_form_test.dart:118`,
`packages/unsalted_core/test/ui/recipe_detail/recipe_detail_screen_test.dart:512, 513`
(alle geplant) und `packages/unsalted_design/test/components/ds23_inputs_test.dart:37`
(geplant); zusätzlich, nicht im Plan, aus demselben Grund:
`ds23_inputs_test.dart:31, 32, 33, 38` (DS-23, TextField/TextFormField mit
Beschriftung), `ds23_inputs_test.dart:86` (DS-25,
`DropdownButtonFormField<int>` mit Beschriftung) und
`packages/unsalted_design/test/templates/ds46_templates_test.dart:151` (DS-48,
Eingabe über die Beschriftung). Die `widget<TextField>`-Prüfungen selbst
bleiben. Neue Tests: DS-23b (Beschriftung über dem Feld, nicht im Feld;
Zahl rechtsbündig mit tnum und Einheit; Semantik Textfeld mit Beschriftung
und Wert; Fehler mit Symbol), DS-25b (Auswahl: Beschriftung oben,
`chevron`), DS-26b (Haarlinie, Auswahlbalken, Mindesthöhe), DS-29b
(Bedienhilfe-Aktionen beim Umsortieren). Katalog: Zahlenfeld mit Einheit,
gewählter Listeneintrag. DS-51: 6 Dateien auf der Liste. Mac: Design 301,
Core 412, App 6, Widgetbook 6 Tests grün; `check_architecture` Exit 0. *Goldens:*
Lauf `39011651009` (`goldens/d08`): 80 Bilder geändert (Felder, Listen,
Tags, Templates, alle fünf Bildschirme). Sichtbar offen bis D16: Zwischen
gestapelten Feldern setzen die Core-Abschnitte noch keinen Abstand
(Verpackungsformular, Editor-Parameter).

**D09 — Rückmeldung.** `AppNotice` (Notice-Karte): Fehler und Warnung auf
`feedback-error-surface`/`feedback-warning-surface` mit den passenden
on-Farben, Info und neu `success` (additiv, Symbol `check`) neutral auf
`surface-sunken` mit Text `text-primary` und Symbol `text-secondary` (die
Material-Rolle `secondaryContainer` ist dunkel `surface-raised` — deshalb die
Rolle direkt); `radius-s`, Innenabstand und Abstand `space-m`, Symbol
`size-icon-small` um `space-xxs` abgesenkt, Text `body`. Nicht umgesetzt:
Aktion in `size-control-small` (Tertiärbutton bleibt `size-control`).
`AppEmptyState` (States-Karte): mit Aktion eine Leerstelle (`AppSlot`), ohne
Aktion nur Symbol und Satz. *Befund, zur Entscheidung:* Die Rezeptliste
übergibt bei „Keine Treffer.“ statt `null` einen leeren Platzhalter als
Aktion (`recipe_list_empty_section.dart`, Teil 1.2: „hält den Abstand“), die
Komponente kann den Fall nicht erkennen — „Keine Treffer.“ zeigt deshalb die
Leerstelle mit Punktraster, die Karte will sie ohne. Behebbar mit einer
Zeile im Abschnitt (`action: hasRecipes ? null : …`); die Datei liegt
außerhalb des Dateiscopes von D09 und ist in Plan (c) nicht genannt — nicht
geändert (CLAUDE.md Regel 7). `AppErrorState`: Symbol `error` in
`text-error` über dem Klartext, Abstand `space-s`. Rückfrage
(`showAppConfirmDialog`): Verb primär, „Abbrechen“ tertiär (Snackbar-Karte,
Dialog). `AppDialog`: feste Inhaltsgröße `size-dialog` × `size-dialog` statt
400 × 400 (keine Höhen-Token; quadratisch reicht für die Auswahlliste im
Rezept-Editor). `AppIconSize`: `xs`/`s`/`m` = `size-icon-xs`/`-small`/
`size-icon`; `l` (48) entfällt (die Leerstelle nutzt `size-icon`).
`AppSkeleton`: Zeilen wie Listeneinträge mit Haarlinie, Balken
`surface-sunken` in `body-strong`/`body-small`-Höhe, Breiten
`size-dialog`/`reflow-label-min`, Puls `duration-long` bis `opacity-scrim`
(weiter nicht eingesetzt, F3 aus Teil 1.2). Von der DS-51-Liste gestrichen:
`app_dialog.dart`, `app_notice.dart`, `app_skeleton.dart`, `app_icon.dart`.
*Restzeitlinie der Meldung nicht gebaut (Abweichung von Plan D09/28.10.9):*
In drei Core-Tests ruft `_swipeAway` direkt nach dem Wischen
`pumpAndSettle` auf, während die Meldung erscheint
(`recipe_list_screen_test.dart:110`, `food_list_screen_test.dart:105`, dazu
`recipe_detail_screen_test.dart:672–674` nach „Rezept löschen“); eine
ablaufende 5-s-Animation hielte `pumpAndSettle` bis zum Ablauf fest, die
Meldung wäre danach zu und das Löschen ausgeführt — die Tests würden
scheitern. Die Snackbar-Karte nennt die Restzeit ausdrücklich „Vorschlag“;
umsetzbar nur mit Änderung dieser Test-Helfer (`pumpAndSettle` → feste
Dauer) — zur Entscheidung. *Geänderte bestehende Testzeilen:*
`packages/unsalted_design/test/components/ds17_icons_test.dart:39`
(`AppIconSize.l` → `AppIconSize.s`) und `:43` (`Size(48, 48)` →
`Size(AppSize.iconSmall, AppSize.iconSmall)`) — geplant (Plan nannte Z. 24/29,
durch D05b verschoben; statt `m` ist es `s`, damit der Fall sich vom Standard
unterscheidet); `ds32_feedback_test.dart:54` (`Size(48, 48)` →
`Size(AppSize.icon, AppSize.icon)`, geplant); zusätzlich, nicht im Plan:
`ds38_overlays_test.dart:80` (`find.widgetWithText(TextButton, 'Verwerfen')` →
`AppButton`: das Verb ist jetzt primär) und `:128, 129` (Dialoggröße 400 →
`AppSize.dialog`). Neue Tests: DS-32b (Info/Erfolg neutral, Symbol, Radius),
DS-33b (mit Aktion Leerstelle, ohne Aktion nicht), DS-34b (Symbol im
Fehlerzustand), DS-39b (Verb primär). Mac: Design 317, Core 412, App 6,
Widgetbook 6 Tests grün; `check_architecture` Exit 0. *Goldens:* Lauf
`39012074968` (`goldens/d09`): 8 Bilder geändert (Motiv „rueckmeldung“); die
fünf Bildschirme zeigen in GL-02 keinen Hinweis, Leer- oder Fehlerzustand.

**D10 — Navigation und Daten.** `AppNavigationBar` (NavigationBar-Karte) ist
eine eigene Komponente statt des Material-`NavigationBar`, dessen Auswahl
eine Pille um das Symbol ist: Ziele teilen die Breite, Auswahl als Balken
`stroke-rule` in `line-strong` (Breite `size-target`) oben am Ziel, Ziel mit
`space-m` oben/`space-s` unten, Symbol `size-icon`, Abstand `space-xs`,
Beschriftung `label-small`, gewählt `text-primary`, sonst `text-secondary`,
Mindesthöhe `size-nav-bar`, `surface-page` mit Haarlinie oben; Semantik je
Ziel `button`/`selected`; Tooltip beim langen Drücken; folgt der Textgröße
nicht (`MediaQuery.withNoTextScaling`, Systemleiste nach UEBERGABE 3).
`AppNavigationBar.rail()`/`asRail()`: dieselbe Navigation als seitliche
Leiste (`size-nav-rail`, Haarlinie rechts, Balken oben am Ziel). `AppPage`
bekommt den Slot `navigation` (additiv): unter `breakpoint-medium` unten,
sonst links neben dem Inhalt. Die App nutzt ihn erst mit D17 (Seitenleiste
einschalten); bis dahin steht die Navigation über `bottomBar` unten, auch
auf dem Tablet. `AppTopBar`: Gestalt aus dem Theme, ohne Textskalierung;
`bottomHeight` = `space-s` + `size-control` + `space-m` (vorher 56 von Hand;
von der DS-51-Liste gestrichen), Suchbereich mit `space-s` oben, `space-l`
seitlich, `space-m` unten; Höhe aus `size-top-bar` statt `kToolbarHeight`
(gleicher Wert). `AppOverflowMenu`: Symbol `more`. `AppBottomActionBar`:
`surface-page`, Haarlinie oben, Innenabstand `space-m`/`space-l`, Abstand
`space-m` (vorher `space-l`). `AppKeyValueTable` (KeyValueTable-Karte) als
Deklaration: Kopf `label-small`/`text-secondary` rechtsbündig, darunter
`stroke-frame` in `line-strong`; Zeilen `data` mit Haarlinie; Wertspalten fest
`space-m` + `size-value-column` (vorher Verhältnis 2 : 1 : 1; von der
DS-51-Liste gestrichen), Werte rechtsbündig mit tnum; neu `AppTableRow.sub`
(um `space-l` eingerückt, `text-secondary`) und `.strong` (`data-strong`),
additiv — `NutritionTable` setzt sie in D15. `AppCodeBlock`:
`surface-sunken`, `radius-s`, `space-m`, Stil `code`. Die DS-51-Übergangsliste
ist damit leer; der Mechanismus wird wie vorgegeben mit D12 entfernt.
*Geänderte bestehende Testzeilen:*
`packages/unsalted_design/test/components/ds40_navigation_test.dart:75`
(`find.byType(NavigationBar)` → `AppNavigationBar`, geplant) und
`apps/unsalted_app/test/theme_test.dart:52` (dto., geplant); zusätzlich,
nicht im Plan: `ds40_navigation_test.dart:97` (Breite zweier Aktionen mit
Abstand `space-m` statt `space-l`), `:118` (Breite der Bezeichnungsspalte =
Rest neben zwei festen Wertspalten statt höchstens die Hälfte) und `:119`
(rechte Kante des ersten Werts am Ende der ersten Wertspalte statt linke
Kante bei der Hälfte) — die alte 2 : 1 : 1-Aufteilung ist durch die
Deklaration ersetzt. `ds40_navigation_test.dart:29` bleibt (`kToolbarHeight`
= `size-top-bar`). Neue Tests (`test/components/ds59_navigation_test.dart`):
DS-59 (unten unter 600, links mit `size-nav-rail` ab 600, genau ein Balken
`size-target` × `stroke-rule` in `line-strong`, Farben gewählt/nicht
gewählt, Tippen, keine Material-`NavigationBar`; Systemleisten ohne
Textskalierung, Inhalt mit; Semantik und Tooltip), DS-40b (Suchbereich aus
Tokens), DS-43b (Haarlinie der Aktionsleiste), DS-44b (Tintenlinie,
Haarlinie, `strong`, `sub` eingerückt), DS-45b (Codeblock). Katalog:
`AppPage · navigation`. Mac: Design 345, Core 412, App 6, Widgetbook 6 Tests
grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39012444464 (`goldens/d10`); abweichend 76 Bilder, alle
erwartet: GL-01 `daten`, `navigation`, `template_detail`, `template_formular`,
`template_liste` (je 8), GL-02 `01_rezeptliste`, `03_rezept_bearbeiten`,
`04_rezeptdetail`, `08_versionsvergleich` (je 8; Kopfleiste, Navigation,
Aktionsleiste, Deklaration) und `10_lebensmittel_bearbeiten` nur bei 200 %
(Kopfleiste folgt der Textgröße nicht mehr).

**D11 — Templates und Layout.** Maße aus Figma (nur gelesen): `Template/Detail
Page` und `Template/Form Page` beschreiben einen Rahmen „Inhalt“ (Fill, Max
width `size-content-max`, Padding `space-l`, ab medium `space-xl`), die
Tablet-Seiten (`147:9902`, `147:9935`, `147:10005`) zeigen ihn mit Innenabstand
16/24/16/24 bei 720 Breite samt Rand, mittig; `Template/List Page` hat „Body
ohne Seitenrand“ (Tablet: Einstellungen-Liste 928 breit). Umsetzung:
`templates/page_content.dart` (nicht exportiert) rechnet den Innenabstand aus
der verfügbaren Breite; `FormSections` (beide Formen), `DetailSections`
(einspaltig) und der obere Bereich von `DetailSplit` stehen darin;
`ListPageTemplate` bleibt ohne Rand. Der Seitenrand richtet sich nach der
Fenstergröße (Material 3), neu `AppWindowSize.pageMargin` (additiv).
`DetailLayout` bekommt `twoColumnsFromLarge` und `twoColumnsAt` (additiv);
`DetailLayout.standard` = `twoColumnsFromLarge` (UEBERGABE 2, F4). Maßgeblich
ist die Fenstergröße, nicht die Breite des Inhalts: In Figma Tablet quer
(`148:4381`) ist der Detailbereich neben der Liste nur 910 breit und trotzdem
zweispaltig — das gilt dann auch mit Liste/Detail (Teil 1.4). Damit nutzt
`DetailSections` nicht mehr `ResponsiveBuilder`; für `twoColumnsFromExpanded`
ändert sich in der App nichts, weil der Inhalt bis D17 fensterbreit ist. Je
Spalte ein eigener Rahmen (Figma `Spalten`/`Haupt`/`Neben`: Innenabstand wie
oben, höchstens `size-content-max`), beide Spalten zusammen mittig. Den
Abstand `space-xxl` zwischen Abschnitten bringt `AppSection` selbst mit (D06);
die Templates setzen keinen zusätzlichen.
*Überlauf im Versionsvergleich (Auftrag Etappe 2):* Ursache war `DetailSplit`
— der obere Bereich lag in einem `Expanded` (halbe Höhe) ohne Scrollen, die
nicht scrollende Zeile aus zwei `SnapshotColumn` lief bei längeren Rezepten
über. Behoben im Template ohne Änderung der Bildschirm-Datei: Der obere
Bereich scrollt (`SingleChildScrollView` im Rahmen „Inhalt“; er darf selbst
nicht scrollen), der untere ist höchstens `size-content-max` breit und mittig,
die Fußzeile steht in voller Breite (vorher zentriert in eigener Breite).
Gegenprobe: DS-60 mit nicht scrollendem oberem Bereich → rot („RenderFlex
overflowed by 1087 pixels“), mit Fix grün.
*Nicht umgesetzt (außerhalb des Dateiscopes):* In Figma füllt eine einzelne
Aktion die Aktionsleiste (Karte „Buttons teilen die Breite“, Bildschirm 08
Handy und Tablet); `AppBottomActionBar` lässt eine einzelne Aktion seit C09 in
eigener Breite, und `version_compare_apply_section.dart` zentriert die Leiste.
Vorschlag im Bericht.
*Geänderte bestehende Testzeilen*
(`packages/unsalted_design/test/templates/ds46_templates_test.dart`, Nummern
vor der Änderung): `:177` (`field.left == AppSpacing.l` → linke Kante im
Rahmen „Inhalt“) und `:178` (Breite entsprechend), beide geplant; zusätzlich
`:97` (`DetailLayout.standard` ist jetzt `twoColumnsFromLarge` statt
`oneColumn`) und `:98` (Position „Haupt“ im Rahmen „Inhalt“ statt fest
`space-l`) — gleicher Grund. Neu dort die Hilfsfunktion `_contentLeft`.
Neue Tests `test/templates/ds60_templates_test.dart` (DS-60, 16 Fälle):
Seitenrand je Fenstergröße; Formular und Detailseite bei 390/600/1024/1600 im
Rahmen „Inhalt“; Liste ohne Rand; zweispaltig erst ab 1200, je Spalte
höchstens 720, mittig; `DetailSplit` mit hohem oberem Bereich ohne Überlauf,
scrollbar, unterer Bereich mittig, Fußzeile voll breit. Nachträge 28.10.1
(ergänzt), 28.10.4, 28.10.7 (in D12 von 28.10.9 nach 28.10.1 verschoben —
Punkt 9 ist laut Plan „Rückgängig“); dazu nachgeholt für D10: 28.10.5 (Deklaration) und
28.10.10 (Navigation, Systemleisten ohne Textskalierung). Mac: Design 361,
Core 412, App 6, Widgetbook 6 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39013130648 (`goldens/d11`); abweichend 32 Bilder, alle
erwartet: auf dem Tablet (100 und 200 %) GL-01 `daten`, `template_detail`,
`template_formular` und GL-02 `03_rezept_bearbeiten`, `04_rezeptdetail`,
`10_lebensmittel_bearbeiten` (Inhalt 720 breit, mittig, Rand `space-xl`);
GL-02 `08_versionsvergleich` in allen acht Varianten (oberer Bereich mit
Seitenrand, scrollt statt überzulaufen). Handy sonst unverändert (Rand
`space-l` wie bisher).

**D12a — Token-Nachtrag `reflow` (F5).** Quelle Figma, nur gelesen
(Bibliothek `5er28Cr7EMMcPzvusWjNyR`, Variablensammlung `type`, Modi `100`
und `200`, gelesen am 2026-10-17). In beiden Token-Dateien (byteweise gleich,
F8) stehen die Maße jetzt im Format `"value": {"100": "…px", "200": "…px"}`:

| Token | 100 | 200 | Figma |
|---|---|---|---|
| `reflow-value-column` | 96 | 160 | `reflow/value-column` 96 / 160 |
| `reflow-label-min` | 120 | 200 | `reflow/label-min` 120 / 200 |
| `reflow-stat-min` | 96 | 240 | `reflow/stat-min` 96 / 240 |
| `reflow-field-min` | 120 | 240 | `reflow/field-min` 120 / 240 |
| `reflow-select-min` | 104 | 208 | `reflow/select-min` 104 / 208 |
| `reflow-rule-inline` (neu, A2) | 1 | 0 | `reflow/rule-inline` 1 / 0 |
| `reflow-rule-stacked` (neu, A2) | 0 | 1 | `reflow/rule-stacked` 0 / 1 |
| `reflow-inset-inline` (neu, A2) | 12 | 0 | `reflow/inset-inline` 12 / 0 |

Figma-Abgleich: Die Sammlung hat genau diese acht `reflow/*`-Variablen, alle
in beiden Modi gleich der Token-Datei; die übrigen Einträge der Sammlung
(Schriftgrößen und Zeilenhöhen 100/200, Familien, Schnitte) betrifft der
Nachtrag nicht. Die Verwendungstexte der drei neuen Einträge sind die
Figma-Beschreibungen; die bestehenden Texte bleiben. Die Notiz der Gruppe
`size` nennt jetzt das Format und die Regel aus F5 (zwischen 100 und 200 %
linear, darüber der Wert bei 200). Generator: `_baseValue` liest beide Formen
und schreibt vorerst den Wert bei 100 % (Werte je Textgröße folgen mit D12);
`AppReflow` bekommt `ruleInline`, `ruleStacked`, `insetInline` (additiv).
Keine sichtbare Änderung, daher kein eigener Golden-Lauf (die PR-CI vergleicht
alle Bilder). *Geänderte Testzeile:*
`packages/unsalted_design/test/tokens/ds04_tokens_complete_test.dart:93`
(`px` liest bei einem Wert je Textgröße den Wert bei 100 %; geplant als
„DS-04-Anpassung“). Neu dort: „DS-04: reflow-Werte je Textgröße 100 und 200“
(Namen und Reihenfolge der acht Einträge, je genau `100` und `200` in `px`;
`size-*` bleiben einfache Werte). Mac: Design 362, Core 412, App 6, Widgetbook 6 Tests grün; `check_architecture` Exit 0.

**D12 — Große Schrift.** *Werte je Textgröße:* Der Generator schreibt
zusätzlich `AppReflow.byFigmaNameAt200` (Modus `200` der Token-Datei); die
Felder und `byFigmaName` bleiben die Werte bei 100 %. Neu
`lib/src/theme/app_reflow.dart` mit `AppReflowMetric` (je `reflow-*`-Token
ein Eintrag, Werte nur aus dem Generat): `at(scale)` zwischen 100 und 200 %
linear, darüber der Wert bei 200 %, darunter der bei 100 % (F5);
`of(context)` misst die Textgröße an `type/body`
(`MediaQuery.textScalerOf(context).scale(16) / 16`), damit auch eine nicht
lineare Skalierung des Systems einen Faktor ergibt; `arranged(stacked:)` für
`rule-inline`, `rule-stacked`, `inset-inline` — die wechseln mit dem Umbruch,
nicht stufenlos (eine halbe Linie bei 150 % wäre sinnlos). Über die Tür
exportiert (additiv), im Katalog als Token ausgenommen (`catalog_test.dart`,
Ausnahmeliste, geplant).
*Komponenten:* `AppKeyValueTable` — Figma (`Data/Key Value Row`, nur gelesen)
legt die Wertzelle als „Fixed size/value-column“ mit Innenabstand `space-m`
*innerhalb* der Zelle fest; D10 hatte `space-m` zusätzlich addiert (108 statt
96). Korrigiert: Wertspalte = `reflow-value-column` der Textgröße (96 … 160).
Bliebe der Bezeichnung weniger als `reflow-label-min` (120 … 200), bricht
jede Zeile um: Bezeichnung oben in voller Breite, Werte darunter rechtsbündig
(`Wrap`, falls auch die Werte nicht nebeneinander passen); Kopf ebenso
(Figma „Bildschirme · Schrift 200“, `73:3815`: Zeilen mit Umbruch, Werte am
Ende, 160 breit). Am Handy bei 200 % bricht die Tabelle um, auf dem Tablet
nicht. `AppBottomActionBar` — Aktionen teilen sich immer die volle Breite,
auch eine einzelne (Karte „Buttons teilen die Breite“, Bildschirm 08 Handy
und Tablet: `Primär` füllt die Leiste); das ersetzt C09 („eine Aktion in
eigener Breite“) und erledigt den Befund aus D11 ohne Änderung von
`version_compare_apply_section.dart`. Würde eine Aktion schmaler als
`reflow-field-min` (120 … 240), stehen sie untereinander in der gegebenen
Reihenfolge, je in voller Breite, Abstand `space-m` (Figma 03 bei 200 %:
„Einfrieren“ über „Speichern“). `AppSkeleton`: Balkenbreite
`reflow-label-min` der Textgröße. *Nicht geändert:* `AppTextField` mit
`AppFieldWidth.narrow` bleibt bei `reflow-field-min` für 100 % (120): Mit
mitwachsender Breite bliebe der Anweisung im `StepRow` bei 200 % am Handy nur
rund 30 px; die Zeile wird mit D16 umgebaut (Timer als Tag) und erst dann
umgestellt. Nährwert-Kopf, Mengenrechner und Zutatenzeile sind Core-Bausteine
(D15/D16) und nutzen dann `AppReflowMetric`.
*Katalog:* Textgrößen-Addon (`TextScaleAddon`, 100–200 %); WB-04 baut jeden
Anwendungsfall bei 200 % in hell/dunkel × Handy/Tablet und sammelt alle
Fehler. Drei Anwendungsfälle liefen über, alle wegen fester Reihen im Katalog
(nicht in Komponenten): „Mark · state“ und „Chip/Choice“ jetzt als `Wrap`,
„Divider“ ohne feste Höhe mit zwei Hälften. Hinweis: In Widget-Tests ist
jedes Zeichen ein volles Quadrat (Testschrift), Text ist dort etwa doppelt so
breit wie mit Atkinson — WB-04 ist damit strenger als die echte Darstellung.
*DS-51:* Übergangsliste und Ausnahmeprüfung entfernt (wie C27c), Regel ohne
Ausnahme; Gegenprobe mit `EdgeInsets.all(8)` in `app_code_block.dart` → rot,
danach grün. Gegenprobe DS-43c/DS-44c mit abgeschaltetem Umbruch → 6 Fälle
rot (Handy, 200 %).
*Geänderte bestehende Testzeilen:*
`packages/unsalted_design/test/components/ds40_navigation_test.dart:98`
(eine Aktion füllt die Leiste statt eigener Breite — Figma, ersetzt C09),
`:118` und `:119` (Wertspalte `size-value-column` statt `space-m` +
`size-value-column` — Korrektur zu D10); beide nicht im Plan.
`packages/unsalted_design/test/architecture/ds51_no_numbers_in_components_test.dart`
Z. 11–13 (Kopfkommentar), 21–24 (Übergangsliste) und 68 (Ausnahme) entfernt
bzw. umgeschrieben, Test „die Übergangsliste enthält nur Dateien mit Zahlen“
(Z. 76–83) gelöscht (geplant).
`apps/unsalted_widgetbook/test/catalog_test.dart:23` (`AppReflowMetric` in
der Ausnahmeliste, geplant) und Z. 5 (Kopfkommentar). Ergänzt:
`ds04_tokens_complete_test.dart` (Werte bei 200 % = Token-Datei),
`public_api_golden.txt` (Export `AppReflowMetric`). Neue Tests:
`test/theme/ds04b_reflow_test.dart` (DS-04b: Einträge = Generat, Interpolation
und Grenzen, Wert aus dem Kontext bei 100/150/200/250 %, Anordnung),
`test/components/ds44c_reflow_components_test.dart` (DS-43c, DS-44c bei 100
und 200 %, Handy/Tablet), WB-04 (4 Fälle). Mac: Design 385, Core 412, App 6,
Widgetbook 10 Tests grün; `check_architecture` Exit 0. Nachträge 28.10.7
(ergänzt), 28.10.11, 28.10.13 (ergänzt).
*Goldens:* erster Lauf 39014086466 zeigte bei 200 % am Handy in zwei Motiven
von GL-01 noch Überlaufmarken — feste Chip-Reihen im Testcode
(`gl01_catalog_golden_test.dart:158, 245`), jetzt `Wrap` wie im Katalog.
Zweiter Lauf 39014482254 (`goldens/d12`): abweichend 36 Bilder, alle
erwartet: GL-01 `daten` und `template_detail` (je 8; Wertspalte 96 statt 108,
bei 200 % am Handy untereinander), `listen_chips` und `template_formular`
(je Handy 200 %: Chips umbrochen bzw. Knöpfe untereinander); GL-02
`04_rezeptdetail` (8; Nährwerttabelle), `03_rezept_bearbeiten` (Handy 200 %:
„Einfrieren“ über „Speichern“ wie Figma), `08_versionsvergleich` (6; die
Aktion füllt die Leiste — bei 200 % am Handy füllte sie schon vorher).
*Abgleich mit Figma „Bildschirme · Schrift 200“ (`73:3778`):* Aktionsleiste
(03) und Tabelle (04) entsprechen der Vorlage. Bei 200 % am Handy schneiden
noch Core-Bausteine außerhalb von D12: die Versionsleiste läuft rechts über
(D13, Fassungsleiste), die Zutatenzeile ist zu schmal (D16), und die Spalten
A/B im Versionsvergleich trennen lange Wörter („Weizenme|hl“) — dafür gibt es
keine Arbeitskarte (Vorschlag im Bericht). Kein abgeschnittener Text in
Komponenten des Design-Pakets; Ersatzkästchen der Code-Schrift wie in D03
vermerkt.

## 2026-10-17 — Teil 1.3, Etappe 3 (freigegeben)

**Freigabe Etappe 2 und Entscheidungen (Projektverantwortlicher):** Etappe 2
geprüft und freigegeben; weiter mit D13–D16, Stopp nach D16.
1. Restzeitlinie: ja, als eigener Commit D09b zu Beginn von Etappe 3; die
   drei Core-Test-Helfer dürfen `pumpAndSettle` durch feste Pumps ersetzen,
   keine Erwartung ändert sich; bei „Bewegung reduzieren“ statisch;
   Gegenprobe.
2. „Keine Treffer.“ ohne Punktraster: in `recipe_list_empty_section.dart`
   (Lebensmittelliste mitprüfen), mit Test, in D16.
3. Versionsvergleich bei 200 %: A über B, sobald eine Spalte schmaler als
   `reflow-label-min` würde, in `version_compare_columns_section.dart`, mit
   Test, in D14.
4. Hinweis mit Aktion bei 200 %: Aktion unter den Text (28.10.11), im
   passenden Commit, mit Goldens.
Außerdem: Umsortieren ohne Ziehen (28.10.3) prüfen — genügen die
Bedienhilfe-Aktionen von `ReorderableListView` (deutsch nach D17)? Eine
sichtbare Alternative änderte Bildschirm-Dateien → nur berichten (Kandidat
Teil 1.4). `AppFieldWidth.narrow` bei 200 % in D16. **Regel ab jetzt:**
Bestehende Testzeilen in Core, die nicht im Plan stehen → vorher Stopp und
fragen; Testzeilen im Design-Paket dürfen an das neue Design angepasst
werden, jede mit Grund hier. `CLAUDE.MD` Abschnitt 2 nach jedem Commit
nachführen (Regel 8).

**D09b — Restzeit der Meldung.** Snackbar-Karte und Figma `Feedback/Snackbar`
(`136:50`, nur gelesen): Restzeit „absolut unten, Höhe stroke/rule, Fläche
action-inverse, läuft in 5 s ab“; Innenabstand `space-xs`, links `space-l`,
Abstand `space-m`; Aktion `space-m` seitlich, Mindesthöhe `size-target`,
`body-strong` in `action-inverse`. Flutters `SnackBar` setzt Inhalt und
Aktion in eine eigene Zeile mit festem Innenabstand; eine Linie über die
ganze Breite am unteren Rand ist dort nicht möglich. Deshalb baut
`showWithAction` den Inhalt selbst (`SnackBar(padding: EdgeInsets.zero)`,
intern `_TimedMessage`): Zeile aus Text und Aktion, darunter in einem `Stack`
die Linie, die die Rundung der Meldung beschneidet. Die Aktion bleibt eine
`SnackBarAction` (schließt mit Grund `action`, Farbe aus dem Snackbar-Thema);
die Meldung hat damit selbst keine `action` mehr. Ihr Ablauf hängt in Flutter
3.47.5 nur an `persist` (`ScaffoldMessenger.build`, unabhängig von der
Bedienhilfe-Navigation) und bleibt `persist: false` — Frist und Ablauf
unverändert. Die Linie startet bei `SnackBar.onVisible`, also in dem Moment,
in dem der Messenger seine Frist beginnt (nach dem Einblenden), und ist zum
Ablauf leer. Bei „Bewegung reduzieren“ (`AppMotion.reduceMotion`) bleibt sie
still in voller Breite; die Frist läuft trotzdem. `showMessage` (ohne Aktion,
ohne Frist im Sinne von 1.1b) bleibt unverändert. *Große Schrift:* Der erste
Golden-Lauf (39035743639) zeigte bei 200 % am Handy getrennte Wörter
(„Eintra|g 3“), weil „Rückgängig“ den größten Teil der 328 breiten Meldung
brauchte. Jetzt gilt die Regel aus 28.10.11: Bliebe dem Text neben der Aktion
weniger als `reflow-label-min` (Breite der Aktion aus ihrer Beschriftung in
`body-strong` bei der Textgröße des Kontexts, dazu `space-m` beidseitig),
steht die Aktion rechtsbündig unter dem Text.
*Geänderte Core-Testzeilen (freigegeben, Punkt 1):*
`packages/unsalted_core/test/ui/recipe_list/recipe_list_screen_test.dart:110`
und `packages/unsalted_core/test/ui/foods/food_list_screen_test.dart:105`
(`_swipeAway`) sowie
`packages/unsalted_core/test/ui/recipe_detail/recipe_detail_screen_test.dart:674`
(nach „Rezept löschen“): `pumpAndSettle()` → zehn Pumps à 100 ms (1 s, mehr
als Wischen, Schließen der Seite und Einblenden der Meldung brauchen), mit
Kommentar; keine Erwartung geändert. `:672` (Menü öffnen, noch keine Meldung)
blieb. Ohne die Änderung scheiterten UI-35 bis UI-39, UI-41 und UI-42
(`pumpAndSettle` pumpt bis zum Ablauf der Linie, danach ist gelöscht); UI-40
blieb zwar grün, spulte aber unbemerkt 5 s vor — deshalb auch dort feste
Pumps. Die übrigen `pumpAndSettle` in diesen Dateien folgen erst nach dem
Schließen der Meldung und bleiben.
*Geänderte Design-Testzeilen:*
`packages/unsalted_design/test/components/ds38_overlays_test.dart:25, 52, 55, 59`
(`pumpAndSettle` → `_appear`: zwei Pumps, 500 ms; Grund wie oben — die Meldung
soll sichtbar geprüft werden, nicht nach ihrem Ablauf). Neu dort DS-38b:
Linie am unteren Rand, `stroke-rule`, `action-inverse`, eben erschienen voll,
nach der halben Frist halb; Text `space-l` vom Rand; Aktion mindestens
`size-target`; Frist unverändert; bei „Bewegung reduzieren“ still, Frist läuft.
Weitere DS-38b-Fälle: Aktion bei 100 und 200 % neben bzw. unter dem Text,
geprüft über die Regel selbst (die Testschrift ist etwa doppelt so breit wie
Atkinson, „Rückgängig“ steht im Test schon bei 100 % unter dem Text), bei
200 % am Handy immer darunter; eine kurze Aktion („Ja“) steht daneben.
Gegenprobe: Linie ohne Ablauf → DS-38b rot (4 Fälle); ohne Rücksicht auf
„Bewegung reduzieren“ → rot (4 Fälle); ohne Umbruch → rot (8 Fälle); danach
grün. Kapitel 28.10.9 neu.
Goldens: Die Meldung erscheint im GL-01-Motiv `template_liste` (Linie nach
1 s bei rund 85 %). Mac: Design 405, Core 412, App 6, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.
*Goldens:* Lauf 39040576908 (`goldens/d09b`, nach der Korrektur für große
Schrift): abweichend genau die 8 Bilder von GL-01 `template_liste` — die
Meldung mit Restzeitlinie (nach 1 s bei rund 85 %), bei 200 % „Rückgängig“
rechtsbündig unter dem vollständigen Text.

**D13a — Bedienhilfe und große Schrift in Komponenten (Nachtrag, Design-Paket).**
Gefunden beim Schreiben von UI-67 (D13), behoben vor D13, weil die
Fassungsleiste darauf aufbaut. *Fehler aus D07 und D10:* `AppMark` mit `onTap`
und das Ziel der `AppNavigationBar` setzen ihre Semantik selbst
(`Semantics(button, selected, label)`) und schließen die Kinder aus
(`ExcludeSemantics`) — damit fiel auch die Tippaktion des `InkWell` weg. Der
Knoten war für Screenreader eine Schaltfläche ohne Aktion. Jetzt
`Semantics(onTap: onTap)`; die Aktion löst dieselbe Rückmeldung aus wie ein
Tippen. Die übrigen Merkmale (Beschriftung, Schaltfläche, gewählt) bleiben.
*Große Schrift:* Der Text einer `AppMark` steht in einem `Flexible` und
bricht um, statt bei schmaler Fläche überzulaufen (UI-67 bei 200 %).
*Entscheidung 4 (Hinweis mit Aktion bei 200 %):* `AppNotice` stellt die Aktion
rechtsbündig unter den Text, sobald dem Text daneben weniger als
`reflow-label-min` bliebe. Weil die Aktion ein beliebiges Widget ist (ihre
Breite ist erst beim Layout bekannt), misst ein kleines internes Layout
`lib/src/layout/reflow_row.dart` (`ReflowRow`, nicht exportiert) zuerst die
Aktion und entscheidet dann (mit Dry-Layout und Intrinsic-Maßen). Die
Meldung (D09b) rechnet die Breite aus ihrer Beschriftung, weil sie nur Text
als Aktion kennt.
*Geänderte bestehende Testzeilen:* keine. Neue Tests
`test/components/ds53b_semantics_reflow_test.dart`: DS-53b (Marke als Ziel —
Tippaktion in der Semantik, Auslösen über die Semantik; langer Text bricht in
`size-target` Breite um, ohne Überlauf), DS-59b (Navigationsziel über die
Semantik antippen), DS-32c (Hinweis bei 100 und 200 %, geprüft über die Regel;
bei 200 % am Handy darunter, auf dem Tablet bei 100 % daneben; schmaler
Hinweis auch bei 100 % darunter). Gegenprobe: ohne Tippaktion → DS-53b und
DS-59b rot (je 4); ohne Umbruch → DS-32c rot (6); danach grün. Mac: Design
429 Tests grün.
*Goldens:* Lauf 39041140045 (`goldens/d13a`): abweichend nur GL-01
`rueckmeldung` bei 200 % am Handy (hell, dunkel) — „Kopieren“ rechtsbündig
unter „Hinweis mit Aktion.“ statt des auf drei Zeilen gedrängten Texts; die
Tippaktion in der Semantik ist nicht sichtbar.

**D13 — Fassungsmarke, Fassungsleiste, Master.** Neu
`lib/src/ui/versions/version_mark.dart`: `VersionMark(version:, isMaster:)`
aus `AppMark` — Entwurf `provisional`, eingefroren `fixed`, Master
`highlighted`; optional `seal` (für D16), `selected`, `onTap`. Text wie
bisher „V{versionIndex}“ bzw. „V{versionIndex} · label“. *Semantik:* „Version
3 · mit Vorteig, eingefroren, Master“ — der Plan nennt „Version n,
Entwurf/eingefroren[, Master]“; die Bezeichnung ist dazugekommen, weil der
bisherige Auswahl-Chip sie vorlas und sie sonst für Screenreader verloren
ginge. `VersionSwitcher` (Figma `Core/Version Switcher`, `Core/Version
Target`): `Wrap` aus Fassungsmarken als Ziele, Abstand `space-s`, unten
ausgerichtet; Auswahlbalken und Tippziel aus `AppMark`. Vorher scrollte die
Reihe waagerecht; jetzt bricht sie um (bei 200 % am Handy lief sie in GL-02
rechts aus dem Bild, D12-Bericht). Rückgabe und Callbacks unverändert.
*Abweichung von Figma:* Figma hebt in der Leiste die Master-Version hervor
(Markerfläche). Die Leiste bekommt nur die Versionen; `RecipeVersion` kennt
den Master nicht, die Master-ID hat nur der Bildschirm
(`recipe_detail_screen.dart`, gesperrt). Der Plan verlangt es für die Leiste
nicht; alle Marken zeigen deshalb Entwurf oder eingefroren — Kandidat für
Teil 1.4 (eine Zeile im Bildschirm: `masterVersionId` übergeben).
`VersionTile`: vorn `VersionMark` statt Titeltext (genau ein „V{n}“ je
Eintrag), Titel = Zustand als Wort („Entwurf“/„Eingefroren“), Untertitel =
Zeitpunkt des Einfrierens; Master: Markerfläche und `AppText.labelSmall(
'Master')` an der Stelle, an der sonst „Als Master markieren“ steht; Stern
entfällt. Aktionen und Tooltips unverändert. Figma (Bildschirm 07,
`20:1042`, nur gelesen) zeigt eine vereinfachte Liste (Titel „Version n“,
Datum, Marke rechts, keine Aktionen) — maßgeblich ist der freigegebene Plan
(Aktionen bleiben, 28.4.4).
*Geänderte bestehende Testzeilen (alle geplant, (d2) D13):*
`packages/unsalted_core/test/ui/recipe_detail/recipe_detail_screen_test.dart`
Plan-Z. 229–230 (jetzt 230–231: gewähltes Ziel über `AppMark.selected` und
`AppMark.label` statt `ChoiceChip`), 237 (jetzt 238), 718, 761, 772 (nach
D09b 721, 764, 775; jetzt 722, 765, 776): `find.widgetWithText(AppChoiceChip,
…)` → `find.widgetWithText(VersionMark, …)`. Dafür ist eine Importzeile
hinzugekommen (Z. 52, `version_mark.dart`) — keine bestehende Zeile, aber
nötig für den geplanten Finder. Die Kommentare Z. 227 und 233–235 sprechen
noch vom „Chip“; nicht geändert (nicht im Plan, Regel für Etappe 3) —
Vorschlag im Bericht. `packages/unsalted_core/test/ui/versions/version_list_screen_test.dart:96, 249, 254, 281`
(`find.byIcon(Icons.star)` → `find.text('Master')`).
Neue Tests `test/ui/versions/version_mark_test.dart`: UI-67 (Marken je
Zustand, genau eine gewählt, Semantik mit Tippaktion, Tippziel mindestens
`size-target`, Tippen meldet die Version; bei 200 % mit sechs Versionen
mehrzeilig ohne Überlauf), UI-68 (genau ein „V{n}“ je Eintrag, Zustand als
Wort, kein Stern, „Master“ genau im Master-Eintrag mit Markerfläche, „Als
Master markieren“ nur bei eingefrorenen Nicht-Master-Versionen, Semantik der
Marke vorn im Listeneintrag). Gegenprobe: Leiste als `Row` → UI-67 rot (200 %);
ohne „Master“ → UI-68 rot; danach grün. Nachträge 28.10.4 (ergänzt) und
28.10.6. Mac: Design 429, Core 415, App 6, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.
*Goldens:* Lauf 39041664242 (`goldens/d13`): abweichend die 8 Bilder von
GL-02 `04_rezeptdetail` — Fassungsleiste statt Auswahl-Chips (V3 gestrichelt,
V2 gewählt mit Balken, V1 eingefroren), bei 200 % in zwei Zeilen statt rechts
abgeschnitten. Bildschirm 7 ist kein GL-02-Motiv.

**D14 — Änderungsliste.** *Rückfrage zu einer Core-Testzeile (Regel für
Etappe 3):* Figma (Bildschirm 08, `3:595`, nur gelesen) zeichnet auch
Hinzufügen und Entfernen geteilt („neu“ + markiert „Olivenöl · 20 ml“,
„entfernt“ + durchgestrichen „Zucker · 5 g“). Damit steht „Salz hinzugefügt
(5 g)“ nicht mehr als ein sichtbarer Text da, und
`version_compare_screen_test.dart:153` (nicht im Plan) schlüge fehl.
Vorgelegt und vom Projektverantwortlichen entschieden (2026-10-17): Z. 153
wie die geplante Z. 152 auf `find.bySemanticsLabel` umstellen, alle
Änderungsarten nach Figma geteilt.
`change_descriptions.dart`: Dieselbe Schleife liefert zu jedem Text die
sichtbaren Teile (`ChangePart`: Gegenstand, alt, neu, Zusatz);
`describeChanges` gibt dieselben Strings zurück wie vorher
(`change_descriptions_test.dart`, `decimal_comma_test.dart` unverändert grün)
und hängt die Teile per `Expando` an die gelieferte Liste (`changePartsOf`).
Grund: Der Abschnitt `version_compare_changes_section.dart` übergibt der
`ChangeList` nur die Texte und liegt außerhalb des Dateiscopes von D14; so
braucht es keinen neuen Parameter. Stammen die Texte nicht aus
`describeChanges`, stehen sie unverändert da. Zuordnung (Gegenstände ohne
Doppelpunkt wie in Figma): Titel/Notizen/Backverlust/Fertiggewicht-Override/
Portionen alt → neu; Schritt geändert „Schritt n“ alte → neue Anweisung, Timer
als eigener Teil „Timer“ alt → neu; Schritt hinzugefügt „Schritt n“ + markiert;
Schritt entfernt „Schritt n“ + durchgestrichen; Menge „Name“ alt → neu;
anderes Lebensmittel „Name“ + Klartext, sonst „alt → neu“ für den Namen, je
mit Mengenteil; Zutat entfernt „entfernt“ + durchgestrichen „Name · Menge“
(die Menge kommt aus der laufenden Liste; der Text nennt sie nicht); Zutat
hinzugefügt „neu“ + markiert „Name · Menge“ (Wort „neu“ aus Figma);
verschoben „Name verschoben“ Position alt → neu. Kein Teil enthält den Pfeil
als Zeichen. `change_list.dart`: je Kategorie `AppSection` (Linie,
Überschrift; ohne die Figma-Metadaten „n Änderungen“ — das wäre ein neuer
Text), je Änderung eine Zeile mit `space-xs` oben und unten; die Teile stehen
in einem `Wrap` aus `AppChangeText`, die Zeile trägt `Semantics(container:
true, label: <bisheriger Text>)` — ohne `container` verschmolz der Knoten mit
seinen Nachbarn und war für `find.bySemanticsLabel` nicht auffindbar.
*Entscheidung 3 (Versionsvergleich bei 200 %):*
`version_compare_columns_section.dart` stellt A über B (getrennt durch eine
Haarlinie), sobald die halbe Breite kleiner als `reflow-label-min` wäre; die
Spalten selbst (`SnapshotColumn`) sind unverändert.
*Geänderte bestehende Testzeilen:*
`packages/unsalted_core/test/ui/versions/version_compare_screen_test.dart:152`
(geplant) und `:153` (freigegeben, s. o.): `find.textContaining(…)` →
`find.bySemanticsLabel(…)`. Design-Paket:
`packages/unsalted_design/test/typography/ds49_glyph_coverage_test.dart:11–14`
(Kommentar: der Pfeil wird seit D14 als Symbol gezeichnet). Neue Tests
`test/ui/versions/change_list_test.dart`: UI-69 (jede Änderung über ihren
bisherigen Text auffindbar, vier `AppChangeText`, genau zwei Pfeile, kein
sichtbarer Pfeil, alt durchgestrichen, neu markiert, Hinzugefügtes markiert,
Entferntes durchgestrichen, Abschnitte; Texte ohne Teile unverändert), UI-75
(bei 100 % am Handy nebeneinander, bei 200 % A über B, ohne Überlauf).
Gegenprobe: ohne Teile → UI-69 rot; ohne Umbruch → UI-75 (200 %) rot;
danach grün. Nachträge 28.10.7 (ergänzt) und 28.10.15. Mac: Design 429, Core
419, App 6, Widgetbook 10 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39043006290 (`goldens/d14`): abweichend die 8 Bilder von
GL-02 `08_versionsvergleich` — Abschnitte „Parameter“ und „Zutaten“ mit
Linie, „Portionen 8̶ → 10“, „Weizenmehl Type 550 500 g → 550 g“, „neu Salz ·
5 g“ (markiert); bei 200 % am Handy A über B.

**D15a — Kennzahlenleiste als Design-Komponente (Nachtrag, freigegeben).**
Die Kennzahlenleiste aus Figma (Bibliothek `Core/Nutrition Header` `142:57`,
`Core/Nutrition Field` `142:56`, nur gelesen: Felder auf Fill, Haarlinie oben
und unten, ab dem zweiten Feld links Haarlinie und `space-m` Einzug; Feld
`space-s` oben und unten, Beschriftung `caption`/`text-secondary`, Wert
`data-strong` mit Einheit `data`/`text-secondary`; Mindestbreite
`reflow-stat-min`) braucht Linien, die Core nicht zeichnen darf (AT-14), und
das Design-Paket hatte dafür keine Komponente. Vorgelegt (Rückfrage zu
D15, Regel 7) und vom Projektverantwortlichen entschieden (2026-10-17): neue
fachneutrale Komponente als eigener Commit. Neu
`lib/src/components/data/app_figure_row.dart`: `AppFigure(label:, value:)`
und `AppFigureRow(figures:)`, über die Tür exportiert (additiv,
`public_api_golden.txt` ergänzt). Die Linien und der Einzug kommen aus
`AppReflowMetric.arranged` (`rule-inline` 1/0, `rule-stacked` 0/1,
`inset-inline` 12/0 — genau dafür sind die Tokens aus D12a da). Bei großer
Schrift stehen alle Felder untereinander, sobald eines schmaler als
`reflow-stat-min` würde (Figma „Schrift 200“, Bildschirm 03: drei Kennzahlen
untereinander mit Haarlinien). Je Feld `MergeSemantics`: Beschriftung und
Wert werden zusammen vorgelesen („Gesamt, 3.500 kcal*“). Katalog:
`AppFigureRow` · „Kennzahlenleiste“; `AppFigure` als Parametertyp in der
Ausnahmeliste von WB-02 (`apps/unsalted_widgetbook/test/catalog_test.dart`,
eine Zeile ergänzt). GL-01 `daten` zeigt die Leiste über der Tabelle
(`gl01_catalog_golden_test.dart`, Motiv ergänzt). DS-06 schlug zuerst auf den
Figma-Namen im Kommentar an (englisches Fachwort) — der Kommentar nennt jetzt
die Figma-IDs. *Geänderte bestehende Testzeilen:* keine. Neu
`test/components/ds61_figure_row_test.dart` (DS-61, 12 Fälle): Haarlinien,
Beschriftung `caption`/`text-secondary`, bei 100 % nebeneinander mit Linie
und Einzug, bei 200 % am Handy untereinander mit Linie ohne Einzug,
gemeinsame Semantik. Gegenprobe: ohne Umbruch → 2 Fälle rot (200 %, Handy);
ohne gemeinsame Semantik → 4 rot; danach grün. Mac: Design 441, Core 419,
App 6, Widgetbook 10 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39043775683 (`goldens/d15a`): abweichend die 8 Bilder von
GL-01 `daten` — Kennzahlenleiste über der Tabelle, bei 200 % am Handy drei
Kennzahlen untereinander mit Haarlinien.

**D15 — Nährwerte.** `NutritionHeader` (Figma `Core/Nutrition Header`):
`AppFigureRow` (D15a) mit „Fertiggewicht“, „Gesamt“ und — nur mit Portionen
— „kcal/Portion“; Werte `AppValue.strong` mit der Zahl aus
`NutritionFormatter` (einzige Rundungsstelle, ohne den eigenen „*“) und der
Einheit „g“ bzw. „kcal“; unvollständige Energie als `AppCertainty.incomplete`
(„*“ nach der Einheit, Value-Karte — vorher „2.868 * kcal“, jetzt „2.868
kcal*“), fehlender Wert als `unknown` („—“). „Nicht berechenbar
(fehlende Dichte/Stückgewicht): …“ als `AppNotice` (Warnung, mit Symbol)
statt einer getönten Fläche, Text unverändert, Abstand `space-m`.
*Abweichungen von Figma, wegen unveränderter Testzeilen und Texte:* Figma
beschriftet „pro Portion“, der Bestand „kcal/Portion“
(`nutrition_header_test.dart:47, 52` suchen den Text) — bleibt. Im
Mengenrechner heißt das zweite Feld in Figma „Kalorien“ mit Einheit „kcal“;
der Bestand beschriftet es „kcal“ (`amount_calculator_test.dart:38, 47, 76`)
— bleibt, ohne zusätzliche Einheit im Feld (sonst stünde „kcal“ doppelt).
`NutritionTable`: Linien, Ziffern und Ausrichtung kommen aus
`AppKeyValueTable`; neu `isSub` für die zwei „davon“-Zeilen (eingerückt,
zurückgenommen) und `strong` für die Kalorien-Zeile; Zeilen, Werte (weiter
die Strings aus dem Formatter, z. B. „5,0 *“) und Fußnoten unverändert.
`AmountCalculator` (Figma `Core/Amount Calculator`): zwei Zahlenfelder
(`TextInputType.numberWithOptions(decimal: true)` — `AppTextField` zeigt
Zahlen damit rechtsbündig in `data`; Tastatur mit Komma), Gramm mit Einheit
„g“ im Feld, dazwischen `AppIcons.swap` in einem Rahmen `size-target`, Abstand
`space-s`, unten ausgerichtet; das Symbol ist nur Darstellung. Würde ein Feld
schmaler als `reflow-field-min`, steht das kcal-Feld in voller Breite unter
dem Gramm-Feld mit Symbol (Figma „Schrift 200“, `73:3816`). Kopplung,
Parsing und Rundung unverändert.
*Geänderte bestehende Testzeilen:* keine (Plan (d2) sieht für D15 keine vor;
UI-05–07, UC-01–06 und `amount_calculator_test.dart` unverändert grün). Neu
`test/ui/nutrition/nutrition_design_test.dart`: UI-70 (Kennzahlenleiste mit
Werten, Einheiten und Zuständen aus dem Formatter; ohne Portionen zwei
Kennzahlen; unbekannt „—“; Hinweis als Warnung mit unverändertem Text; bei
200 % untereinander ohne Überlauf), UI-71 (Deklaration: genau zwei
„davon“-Zeilen eingerückt, nur die Kalorien-Zeile hervorgehoben;
Mengenrechner bei 100 und 200 %: Felder, Einheit, rechtsbündig, Symbol,
nebeneinander bzw. zweites Feld darunter). Gegenprobe: Mengenrechner ohne
Umbruch → UI-71 (200 %) rot; danach grün. Nachträge 28.10.5 und 28.10.11
(ergänzt). Mac: Design 441, Core 425, App 6, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.
*Goldens:* Lauf 39044292470 (`goldens/d15`): abweichend die 8 Bilder von
GL-02 `04_rezeptdetail` — Kennzahlenleiste („643,5 g“, „2.868 kcal*“, „287
kcal*“), Warnhinweis mit Symbol, Kalorien-Zeile hervorgehoben, „davon“
eingerückt; bei 200 % am Handy Kennzahlen untereinander. Der Mengenrechner
liegt im Bild unterhalb des sichtbaren Ausschnitts.

**D16 — Editor und Lebensmittel.** *Rückfragen (Regel für Etappe 3),
entschieden vom Projektverantwortlichen (2026-10-17):* (1) Die Nährwertfelder
stehen ab `breakpoint-medium` zweispaltig (Plan);
`package_form_test.dart:68–72` (nicht im Plan) prüfte auf 800 Breite „jedes
Feld strikt unter dem vorigen“ und prüft jetzt die Lesereihenfolge (tiefer
oder in derselben Zeile rechts daneben). (2) Die Schrittnummer im Editor
braucht den Index aus `recipe_editor/sections/recipe_editor_steps_section.dart`
(nicht im D16-Scope): freigegeben, eine Zeile (`number: index + 1`, additiver
Parameter an `StepRow`).
*Zutatenzeile* (`ingredient_row.dart`, Figma Bildschirm 03, `7:895` und
Tablet `147:9935`, nur gelesen: `_Zeile/Zutat bearbeiten` immer zweizeilig):
oben Ziehgriff, Name (füllt), Entfernen; darunter eingerückt
(`size-icon` + `space-s`, Figma `Einzug`) die Menge in `reflow-value-column`,
Einheit und Notiz teilen sich den Rest (Figma 96/107/107 am Handy). Bliebe
der Einheit weniger als `reflow-select-min` (große Schrift), stehen Menge und
Einheit bzw. Menge, Einheit und Notiz untereinander. Abstände aus Figma:
`space-s` oben, `space-m` unten, `space-xs` zwischen den Zeilen. Eine nicht
verknüpfte Zutat (ohne `foodVariantId`) ist gestrichelt unterstrichen
(`AppDashedUnderline`, Plan; Figma zeigt im Editor stattdessen ein Tag
„nicht verknüpft“ bzw. ein Verknüpfungs-Symbol — das wäre ein neuer Text).
*Abweichungen von Figma, wegen unveränderter Testzeilen:* Die Felder behalten
ihre Beschriftungen über dem Feld („Name“, „Menge“, „Notiz“; Figma ohne),
Entfernen behält `deleteOutline` (Figma `close`). Damit die Einheit ihren
Anteil füllt, bekommt `AppSelect` additiv `expand` (`isExpanded`, lange
Einträge gekürzt) — ohne ihn war die Auswahl so breit wie „Messerspitze“ und
lief über (erster Lauf von UI-72).
*Schrittzeile* (`step_row.dart`): Nummer in `size-index-column`
(`data-strong`), Anweisung füllt, das Timer-Feld steht darunter (wie der
Timer in `Core/Step Row`); „Timer als Tag“ (Plan) geht im Editor nicht, weil
der Timer dort ein Eingabefeld ist (Tests suchen „Timer (Min.)“) — als Tag
erscheint er im Rezeptdetail. Das schmale Feld wächst seit D16 mit der
Textgröße (`AppFieldWidth.narrow` = `reflow-field-min` der Textgröße,
Entscheidung zu Etappe 2); in einer schmaleren Spalte wird es auf deren Breite
begrenzt.
*Eingefroren* (`recipe_editor_frozen_section.dart`, Figma 03 „Eingefroren“,
`42:2010`): der Hinweis als `AppNotice` mit „Kopieren“ (Text unverändert,
Figma-Text nicht übernommen), darunter der schreibgeschützte Inhalt in
`AppFrame.fixed` mit `VersionMark(seal: true)` und dem Zustandswort
„Eingefroren“ (Plan 28.10.3; Figma zeigt dort keinen Rahmen).
*Verpackungsformular:* Warnung und Fehler als `AppNotice` (Warnung/Fehler,
Keys `package_form_warning`/`package_form_error` am Hinweis); Nährwertfelder
im `AppGrid` (1 Spalte unter, 2 ab `breakpoint-medium` der verfügbaren
Breite; im Rahmen „Inhalt“ höchstens 672 breit, also nie 3), Abstand
`space-m` — damit ist der offene Punkt aus D08 (kein Abstand zwischen
gestapelten Feldern) hier erledigt; im Editor-Abschnitt „Parameter“ bleibt
er offen (Datei nicht im Scope).
*Rezeptdetail, Schritte* (`recipe_detail_steps_section.dart`, Figma
`Core/Step Row`): Nummer in `size-index-column` (`data-strong`), Anweisung,
darunter der Timer als Tag mit Symbol `timer`, Haarlinie je Schritt.
*Entscheidung 2:* `recipe_list_empty_section.dart` übergibt bei „Keine
Treffer.“ keine Aktion mehr (vorher ein leerer Platzhalter) — Symbol und Satz
ohne Leerstelle. Die Lebensmittelliste geprüft: Sie zeigt für „leer“ und
„keine Treffer“ denselben Abschnitt mit demselben Text und der Aktion
„Eigenes Produkt anlegen“; ob gesucht wird, weiß nur der Bildschirm
(gesperrt) — bleibt die Leerstelle mit Aktion (Bericht).
*Umsortieren ohne Ziehen (Prüfauftrag):* `ReorderableListView` (hinter
`AppReorderableList`) bietet je Eintrag die Bedienhilfe-Aktionen „an den
Anfang“, „nach oben“, „nach unten“, „an das Ende“ (DS-29b, Texte aus
`MaterialLocalizations`, deutsch mit D17b). Für Screenreader genügt das.
WCAG 2.5.7 verlangt aber eine Bedienung mit einfachem Zeigen für alle, ohne
Hilfstechnik — die gibt es nicht; eine sichtbare Alternative (z. B. „Nach
oben“/„Nach unten“ im Menü der Zeile) bräuchte Bildschirm- und
Callback-Änderungen → Kandidat Teil 1.4 (Bericht).
*Geänderte bestehende Testzeilen:*
`packages/unsalted_core/test/ui/foods/package_form_test.dart:68–72`
(freigegeben, s. o.). Design-Paket: keine. Neue Tests
`test/ui/recipe_editor/editor_design_test.dart`: UI-72 (zweizeilig, Menge in
`reflow-value-column`, eingerückt; bei 200 % untereinander ohne Überlauf;
gestrichelt nur ohne Verknüpfung), UI-73 (Hinweise mit Keys und Art;
Nährwertfelder bei 390 einspaltig, bei 800 zweispaltig), UI-74 (Nummern 1, 2
in `data-strong`, Timer unter der Anweisung, schmales Feld wächst bei 200 %;
Detail mit Nummer und Timer-Tag; eingefrorene Ansicht im Rahmen mit Siegel,
„Kopieren“ im Hinweis), UI-76 („Keine Treffer.“ ohne `AppSlot`, leere Liste
mit `AppSlot` und Aktion); Design `test/components/ds23c_reflow_inputs_test.dart`:
DS-23c (schmales Feld bei 100/150/200 %), DS-25c (Auswahl mit `expand` füllt
ohne Überlauf, ohne bleibt sie inhaltsbreit). Gegenprobe: ohne Umbruch, ohne
Unterstreichung → UI-72 rot (3); festes schmales Feld → UI-74 (200 %) und
DS-23c (8) rot; ohne `expand` → DS-25c rot (4); danach grün. Nachträge
28.10.3 (ergänzt), 28.10.8 (neu), 28.10.11 (ergänzt). Mac: Design 461, Core
436, App 6, Widgetbook 10 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39052303892 (`goldens/d16`): abweichend 12 Bilder, alle
erwartet: GL-02 `03_rezept_bearbeiten` (Handy 100 %, Tablet 100/200 %, je hell
und dunkel: Zutatenzeile zweizeilig, „Milch“ ohne Verknüpfung gestrichelt
unterstrichen; bei 200 % am Handy liegt die Zeile unterhalb des Ausschnitts)
und `10_lebensmittel_bearbeiten` (Handy 100 %, Tablet 100/200 %: Abstand
zwischen den Nährwertfeldern, auf dem Tablet zweispaltig). Die Schritte im
Rezeptdetail liegen in `04_rezeptdetail` unterhalb des Ausschnitts.

## 2026-10-18 — Teil 1.3, Etappe 4 (freigegeben)

**Freigabe Etappe 3 und Entscheidungen (Projektverantwortlicher):** Etappe 3
geprüft und freigegeben; weiter mit D17, D17b, D18, Stopp nach D18; kein
Merge, keine Tags. Zu den offenen Punkten des Berichts: (1)–(3) Master in der
Fassungsleiste, sichtbares Umsortieren ohne Ziehen, „leer“/„keine Treffer“ in
der Lebensmittelliste sind Kandidaten für Teil 1.4 — festgehalten in
`plan-1.3.md` („Nicht Teil von 1.3“) und `status.md`. (4) Abstand der
gestapelten Felder im Editor-Abschnitt „Parameter“: freigegeben, eigener
kleiner Commit mit Test und Golden. (5) Nährwertfelder im
Verpackungsformular: freigegeben — rechtsbündig mit Zahlentastatur (mit
Komma) wie die übrigen Zahlenfelder, mit Test. (6) Kommentare „Chip“ in
`recipe_detail_screen_test.dart`: freigegeben, nur die Kommentare. D18
zusätzlich: alle bewussten Abweichungen von Figma in
`docs/design/rueckmeldung-figma.md` sammeln.

*Umgesetzt in diesem Commit:* (1)–(3) wie oben; (6)
`packages/unsalted_core/test/ui/recipe_detail/recipe_detail_screen_test.dart:228`
und `:234–236` (Plan-Z. 227, 233–235; durch die Importzeile aus D13 um eins
verschoben) — nur Kommentare: „Marke in der Fassungsleiste“ statt „Chip in
der Versionsleiste“; der Code der Helfer bleibt.

**D16b — Abstand im Editor-Abschnitt „Parameter“ (freigegeben, Punkt 4).**
`recipe_editor/sections/recipe_editor_parameters_section.dart`: `AppStack`
mit `gap: AppSpace.m` zwischen Portionen, Backverlust,
Fertiggewicht-Override und Notizen (bzw. Portionen und Notizen, wenn C29 die
erweiterten Felder ausblendet) — derselbe Abstand wie zwischen den
Nährwertfeldern (D16) und im Figma-Raster von Bildschirm 03 (12). Der
Anlege-Abschnitt von Bildschirm 2 (`recipe_create_fields_section.dart`,
Titel und Beschreibung) stapelt seine Felder ebenfalls ohne Abstand; nicht
Teil der Freigabe, nicht geändert (Bericht). *Geänderte bestehende
Testzeilen:* keine. Neu in `test/ui/recipe_editor/editor_design_test.dart`:
UI-77 (Abstand genau `space-m`, mit und ohne erweiterte Felder). Gegenprobe:
ohne Abstand → beide Fälle rot; danach grün. Nachtrag 28.10.3 ergänzt. Mac:
Core 438 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39318263650 (`goldens/d16b`): abweichend die 8 Bilder von
GL-02 `03_rezept_bearbeiten` (Abstand zwischen den Parameter-Feldern).

**D16c — Nährwertfelder als Zahlenfelder (freigegeben, Punkt 5).**
`foods/sections/package_nutrients_section.dart`: jedes Nährwertfeld (auch
„oder: Natrium (mg)“) mit `keyboardType:
TextInputType.numberWithOptions(decimal: true)` — Tastatur mit Komma;
`AppTextField` zeigt Zahlenfelder rechtsbündig in `data` mit tabellarischen
Ziffern (D08). Parsing und Prüfung unverändert (Eingabe mit Komma wie
bisher). *Nicht Teil der Freigabe, nicht geändert:* die Maßfelder des
Verpackungsformulars (Dichte, Stückgewicht, Portionsgröße,
`package_measures_section.dart`) und die Zahlenfelder im Editor-Abschnitt
„Parameter“ (Portionen, Backverlust, Fertiggewicht-Override) sind weiter
linksbündig ohne Zahlentastatur (Bericht). *Geänderte bestehende
Testzeilen:* keine. Neu in `test/ui/recipe_editor/editor_design_test.dart`:
UI-78 (alle acht Nährwertfelder mit Zahlentastatur mit Komma, rechtsbündig,
tabellarische Ziffern; „2,5“ bleibt so stehen). Gegenprobe: ohne
Zahlentastatur → UI-78 rot; danach grün. Nachtrag 28.10.8 ergänzt. Mac: Core
439 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39319020903 (`goldens/d16c`): abweichend 6 Bilder von GL-02
`10_lebensmittel_bearbeiten` (Handy 100 %, Tablet 100/200 %; Werte der
Nährwertfelder rechtsbündig mit tabellarischen Ziffern; bei 200 % am Handy
liegen die Felder unterhalb des Ausschnitts).

**D17 — App-Hülle: Seitenleiste ab 600 (F4).** `apps/unsalted_app/lib/main.dart`:
`_NavigationShell` übergibt die `AppNavigationBar` an `AppPage.navigation`
statt `bottomBar` (eine Zeile, wie im Plan für D10/D17). `AppPage` (D10)
stellt sie unter `breakpoint-medium` unten dar, ab `breakpoint-medium` (nach
Fensterbreite, Material 3) als seitliche Leiste links mit `size-nav-rail`,
denselben Zielen und dem Auswahlbalken. Die Bildschirme liegen unverändert
rechts daneben im Rahmen „Inhalt“ (D11). Figma (nur gelesen): Tablet hoch
`147:9746` und Handy quer `148:3817` zeigen die Leiste links — dort
zusätzlich Liste und Detail nebeneinander, das bleibt Teil 1.4 (F4). Die
Unterseiten (Rezeptdetail, Editor …) öffnet der Bildschirm im Navigator der
Hülle; die Leiste bleibt wie bisher die Navigation unten sichtbar.
*Geänderte bestehende Testzeilen:* keine — `theme_test.dart:50–52` sucht
`AppNavigationBar` und findet auf der 800 breiten Testfläche jetzt die
Seitenleiste (dieselbe Komponente, `rail`), wie im Plan (d2) vorgesehen; der
Rauchtest tippt die Ziele über ihre Symbole. Neu `test/navigation_test.dart`:
APP-04 (390 × 844 unten in voller Breite; 1024 × 1366 und Handy quer 844 ×
390 links mit `size-nav-rail`, Inhalt rechts daneben; drei Ziele; Tippen
wechselt zu „Einstellungen“ und markiert das Ziel). Gegenprobe: wieder
`bottomBar` → APP-04 bei 1024 und 844 rot; danach grün. Keine Golden-Bilder
(die App ist kein Golden-Motiv; GL-02 baut die Bildschirme ohne Hülle).
Nachtrag 28.10.10 ergänzt. Mac: App 9 Tests grün; `check_architecture`
Exit 0.

**D17b — Deutsche Systemtexte (F2).** `apps/unsalted_app/pubspec.yaml`:
`flutter_localizations` aus dem SDK (in `pubspec.lock` nur von „transitive“
auf „direct main“, keine neue Version). `lib/main.dart`: `locale: Locale('de')`,
`supportedLocales: [Locale('de')]`, `localizationsDelegates:
GlobalMaterialLocalizations.delegates` (Material, Widgets, Cupertino). Damit
sind Tooltips („Zurück“), die Bedienhilfe-Aktionen von `ReorderableListView`
(„Nach oben verschieben“ …, vgl. D16 Prüfauftrag Umsortieren), Datums- und
Textfeld-Menüs sowie die Lizenzseite deutsch. Core und Design bleiben ohne
Lokalisierung (ihre Tests laufen weiter mit den englischen Standardtexten —
keine Testzeile prüft sie). *Geänderte bestehende Testzeilen:* keine. Neu
`apps/unsalted_app/test/localization_test.dart`: APP-03 (Sprache `de`,
„Zurück“, „Nach oben/unten verschieben“ aus `WidgetsLocalizations`,
„Lizenzen“). Gegenprobe: ohne Delegates und Sprache → APP-03 rot (`en_US`);
danach grün. Keine Golden-Bilder (App kein Golden-Motiv). Nachtrag 28.10.14
neu. Mac: App 10 Tests grün; `check_architecture` Exit 0.

**D18 — Abschluss Teil 1.3.** Doku nachgeführt: `docs/design/design_system.md`
(Stand 1.3: Ebenen mit Token-Datei und Generator, Regeln für Werte, große
Schrift, Katalog und Goldens; Benennung inkl. `reflow/*` und `Core/*`; Weg der
Werte Figma → Code; DS-07 neu als Zuordnung Material → Tokens),
`docs/design/components.md` (alle Komponenten mit Figma-Namen, -IDs aus
`figma-ids.json`, Datei und Tests; fachliche Bausteine mit Figma-Bezug und
UI-Tests), `docs/design/screens.md` (Stand 1.3 je Bildschirm und eine Zeile
„Figma“ mit ID: übereinstimmend, bewusst anders, offen; Golden-Motiv —
das ist der Figma-Abgleich je Hauptbildschirm aus der Abnahme von D18), neu
`docs/design/rueckmeldung-figma.md` (Vorgabe des Projektverantwortlichen:
alle bewussten Abweichungen von Figma, damit Figma nachgezogen werden kann —
A1 Texte nach Kapitel 22, A2 Symbole (`deleteOutline` statt `close`), A3
Komponenten (u. a. `AppFigureRow` ohne eigene Design-Komponente in Figma,
Zustandsrahmen der eingefrorenen Ansicht), A4 ergänzte Tokens und Regeln; B:
was Figma zeigt und der Code später umsetzt). `packages/unsalted_design`:
README (Stand 1.3), `CHANGELOG.md` (Zusammenfassung 0.2.0), `pubspec.yaml`
Version 0.2.0 (die Lock-Dateien von App und Katalog führen die Pfad-Version
mit). Kapitel 28.10: Einleitung „vollständig mit D18“ und Verweis auf die
Rückmeldedatei, 28.10.13 um DS-52–61, die Buchstaben-Ergänzungen, UI-67–78
und APP-03/04 ergänzt. *Nicht getan (F14, Vorgabe):* kein Merge, keine Tags;
`docs/design/system/README.md` bleibt „Entwurf zur Freigabe“, bis der
Projektverantwortliche freigibt. Keine Golden-Bilder (nur Doku und Version).
Mac: Design 461, Core 439, App 10, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.

**D18b — Nachtrag nach Prüfung von Etappe 4 (freigegeben).** Vorgabe des
Projektverantwortlichen: „Etappe 4 geprüft – sauber. Vor dem Merge noch ein
kleiner Commit D18b mit deinen zwei offenen Punkten (beide in Abschnitten
unter lib/src/ui)“ — die beiden „nicht Teil der Freigabe“-Punkte aus D16b und
D16c. Kein Merge, keine Tags.
(1) `recipe_editor/sections/recipe_create_fields_section.dart`: `AppStack`
mit `gap: AppSpace.m` zwischen Titel und Beschreibung (wie D16b; Figma
`20:978`). (2) Zahlenfelder wie D16c — `AppTextField` zeigt sie rechtsbündig
in `data` mit tabellarischen Ziffern (D08):
`foods/sections/package_measures_section.dart` Dichte, Stückgewicht,
Portionsgröße mit `TextInputType.numberWithOptions(decimal: true)`;
`recipe_editor/sections/recipe_editor_parameters_section.dart` Portionen mit
`TextInputType.number` (ganze Zahl, Tastatur ohne Komma), Backverlust und
Fertiggewicht-Override mit `numberWithOptions(decimal: true)`; Notizen bleiben
Textfeld. Parsing, Prüfung, Texte und Reihenfolge unverändert (Portionen
werden weiter als ganze Zahl gelesen, Komma und Punkt bei den übrigen wie
bisher). Die Maßfelder liegen weiter ohne Abstand untereinander in
`AppSection` — nicht Teil der Vorgabe, nicht geändert (Bericht).
*Geänderte bestehende Testzeilen:* keine (Core vor den neuen Tests 439 grün).
Neu in `test/ui/recipe_editor/editor_design_test.dart`: UI-79 (Abstand
zwischen Titel und Beschreibung genau `space-m`), UI-80 (Maßfelder mit
Zahlentastatur mit Komma, rechtsbündig, tabellarische Ziffern, „1,03“ bleibt
so stehen; Portionen `TextInputType.number` ohne Komma, Backverlust und
Fertiggewicht-Override mit Komma, Notizen weiter Text). Gegenproben: ohne
Abstand → UI-79 rot (0 statt 12); Maßfelder ohne Zahlentastatur → UI-80 rot;
Portionen mit Komma → UI-80 rot; Backverlust ohne Zahlentastatur → UI-80 rot;
danach grün. Nachträge 28.10.3, 28.10.8, 28.10.13 ergänzt; `screens.md`
(Bildschirm 2, 3, 10: „Offen“ erledigt) und `components.md` nachgeführt. Mac:
Design 461, Core 442, App 10, Widgetbook 10 Tests grün; `check_architecture`
Exit 0.
*Goldens:* Lauf 39322997334 (`goldens/d18b`): abweichend die 8 Bilder von
GL-02 `03_rezept_bearbeiten` (Portionen und Backverlust rechtsbündig mit
tabellarischen Ziffern). `10_lebensmittel_bearbeiten` unverändert — die
Maßfelder sind im Golden-Motiv leer, und die Tastatur erscheint nicht im Bild;
Bildschirm 2 ist kein Golden-Motiv.

**Befund aus dem iPhone-Test (Projektverantwortlicher):** Im
Textauswahlmenü stehen „Copy“ und „Cut“ englisch, „Nachschlagen“ deutsch.
Ursache: Copy/Cut/Paste zeichnet iOS selbst, in der Sprache des App-Bundles;
die `Info.plist` nannte keine Sprache (`CFBundleDevelopmentRegion` =
`$(DEVELOPMENT_LANGUAGE)`, im Xcode-Projekt `en`; `knownRegions` nur `en`,
`Base`). „Nachschlagen“ kommt aus den Flutter-Texten (D17b). Vorgabe: vor dem
Merge D17c und D18c, bei jeder Abweichung Stopp; danach prüft er das Menü
auf dem iPhone. Kein Merge, keine Tags.

**D17c — Deutsch als Sprache des App-Bundles.**
`apps/unsalted_app/ios/Runner/Info.plist` und
`apps/unsalted_app/macos/Runner/Info.plist`: `CFBundleDevelopmentRegion`
„de“ (statt `$(DEVELOPMENT_LANGUAGE)`), neu `CFBundleLocalizations` mit „de“
(eingeordnet nach Schlüssel wie Xcode). Das Bundle hat nur `Base.lproj`, kein
`en.lproj` — damit ist „de“ die einzige Sprache des Bundles, und iOS zeichnet
seine eigenen Menüs deutsch. Die Xcode-Projekte (`developmentRegion = en`,
`knownRegions`) bleiben unverändert (nicht Teil der Vorgabe; sie bestimmen
nur Xcodes Liste der Projektsprachen, nicht das Bundle). Geprüft mit
`plutil -lint` (beide OK) und `plutil -extract` („de“, `["de"]`). Auf dem
iPhone noch nicht geprüft (Projektverantwortlicher). *Geänderte bestehende
Testzeilen:* keine. Neu `apps/unsalted_app/test/bundle_language_test.dart`:
APP-05 (liest beide `Info.plist` als Text: Entwicklungssprache „de“,
`CFBundleLocalizations` enthält „de“). Gegenproben: iOS wieder mit
`$(DEVELOPMENT_LANGUAGE)` → rot; macOS ohne `CFBundleLocalizations` → rot; iOS
mit `CFBundleLocalizations` nur „en“ → rot; danach grün. Nachtrag 28.10.14
ergänzt, 28.10.13 um APP-05. Keine Golden-Bilder (App kein Golden-Motiv).
Mac: App 12 Tests grün; `check_architecture` Exit 0.

**D18c — Abstand zwischen den Maßfeldern.**
`foods/sections/package_measures_section.dart`: die sichtbaren Maßfelder
(Dichte, Stückgewicht, Portionsgröße; C29 kann sie ausblenden) stehen in
`AppSection` jetzt in einem `AppStack` mit `gap: AppSpace.m` — derselbe
Abstand wie im Editor-Abschnitt „Parameter“ (D16b), zwischen den
Nährwertfeldern (D16) und in Bildschirm 2 (D18b). Der Abschnitt
„Kennung“ (`package_identity_section.dart`: Name, Marke, Barcode) stapelt
seine Felder weiter ohne Abstand — nicht Teil der Vorgabe, nicht geändert
(Bericht). *Geänderte bestehende Testzeilen:* keine (Core vor dem neuen Test
442 grün). Neu in `test/ui/recipe_editor/editor_design_test.dart`: UI-81
(Abstand genau `space-m`, mit drei und mit zwei sichtbaren Feldern).
Gegenprobe: ohne Abstand → beide Fälle rot (0 statt 12); danach grün.
Nachträge 28.10.8 und 28.10.13 ergänzt; `screens.md` (Bildschirm 10) und
`components.md` nachgeführt. Mac: Design 461, Core 444, App 12, Widgetbook 10
Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39330602936 (`goldens/d18c`): abweichend die 8 Bilder von
GL-02 `10_lebensmittel_bearbeiten` (Abstand zwischen den Maßfeldern, der
Rest rückt nach unten).

**Freigabe Teil 1.3 (Projektverantwortlicher):** „Menü ist auf dem iPhone
jetzt deutsch – D17c bestätigt. Teil 1.3 ist freigegeben.“ Reihenfolge: D18d
(letzter Abstand-Durchgang), Status in `docs/design/system/README.md`,
Vorprüfung, Merge mit `--no-ff` nach `main`, Tests auf `main`, Tags
`part1-v1.3.0` und `design-v0.2.0`, Status und Kandidaten für Teil 1.4,
Aufräumen; bei jeder Abweichung Stopp.

**D18d — Letzter Abstand-Durchgang.** Vorgabe: `package_identity_section.dart`
bekommt `space-m` wie D16b; alle übrigen Abschnitte und Bausteine unter
`lib/src/ui` mit untereinander stehenden Eingabefeldern prüfen und die
restlichen Fälle im selben Commit beheben (keine Bildschirm-Dateien). Befund
der Durchsicht (alle Dateien mit `AppTextField`, `AppSelect`,
`PackageNumberField`): ohne Abstand nur noch „Kennung“; mit kleinerem Abstand
die Export-Auswahl (`space-s`), die Schrittzeile (Anweisung → Timer,
`space-s`), der Mengenrechner bei großer Schrift (`space-s`) und die
Zutatenzeile (`xs`); einzelne Felder ohne Nachbarn (Suche, Import,
Auswahldialog, Spalte der Nährwerttabelle) sind kein Fall; in
Bildschirm-Dateien steht kein gestapeltes Feld (kein Kandidat für 1.4).
Figma (nur gelesen) zeigt zwischen gestapelten Formularfeldern 16
(Bildschirm 10 Kennung/Maße `23:1517`/`23:1571`, Bildschirm 11 Auswahl
`23:1842`), 32 (Bildschirm 2 `20:978`), beim Mengenrechner bei Schrift 200
8 (`73:3816`); die Editor-Schrittzeile ist nicht abgebildet.
*Entscheidung des Projektverantwortlichen (Rückfrage):* Export-Auswahl und
Schrittzeile auf `space-m`; Zutatenzeile bleibt `xs` (Figma
`Core/Ingredient Row`, kompakte Listenzeile); Mengenrechner bleibt
`space-s` (wie Figma bei Schrift 200 — meine erste Rückfrage hatte
fälschlich „Figma zeigt nur nebeneinander“ genannt, korrigiert und erneut
gefragt). Umsetzung: `package_identity_section.dart` Felder in `AppStack`
mit `gap: AppSpace.m`; `export_selection_section.dart` `AppGap(AppSpace.m)`
statt `AppSpace.s` (der Abstand bleibt auch ohne Versionsauswahl stehen wie
bisher); `step_row.dart` innerer `AppStack` mit `gap: AppSpace.m`. Die
einheitlichen 12 statt Figmas 16/32 stehen in `rueckmeldung-figma.md` (A4).
*Geänderte bestehende Testzeilen:* keine (Core vor den neuen Tests 444 grün;
keine Testzeile legt `space-s`/`xs` fest). Neu in
`test/ui/recipe_editor/editor_design_test.dart`: UI-82 (Kennung mit und ohne
Barcode, Export-Auswahl Rezept → Version, Schrittzeile Anweisung → Timer;
jeweils genau `space-m`). Gegenproben: Kennung ohne Abstand → rot (0);
Export wieder `space-s` → rot (8); Schrittzeile wieder `space-s` → rot (8);
danach grün. Nachträge 28.10.1 (Regel für gestapelte Felder) und 28.10.13;
`screens.md`, `components.md`, `rueckmeldung-figma.md` nachgeführt. Mac:
Design 461, Core 448, App 12, Widgetbook 10 Tests grün; `check_architecture`
Exit 0.
*Goldens:* Lauf 39335480993 (`goldens/d18d`): abweichend die 8 Bilder von
GL-02 `10_lebensmittel_bearbeiten` (Abstand zwischen Name, Marke und Barcode,
der Rest rückt nach unten). `03_rezept_bearbeiten` unverändert — die Schritte
liegen unterhalb des Bildausschnitts; Export ist kein Golden-Motiv.

**Status des Design-Systems (F14).** `docs/design/system/README.md`: das
Status-Blockzitat lautet jetzt „freigegeben (design-v0.2.0)“; seine alten
Sätze (Material-3-Platzhalter im Code, Prüfung in Figma ausstehend) sind
damit überholt und ersetzt durch den Verweis auf `packages/unsalted_design`
0.2.0 und `rueckmeldung-figma.md`. Der übrige Inhalt der Übergabe bleibt
unverändert.

**Abschluss Teil 1.3 (2026-10-20).** Merge-Commit `36b7c41` „Teil 1.3:
Gestaltung aus Figma (D01–D18)“ (`--no-ff`, Eltern `1022185` und `e1808f5`,
Baum gleich `e1808f5`); Tags `part1-v1.3.0` und `design-v0.2.0` (annotiert)
auf `36b7c41`. *Befund vor dem Push:* in der Nacht auf den 20.10. hingen
lokal 3 von 4 vollen Core-Läufen auf `main` — jedes Mal andere Widget-Tests
mit Datenbank (u. a. UI-44, UC-04, Export-Test) bis zum Zeitlimit von
10 min, `flutter_tester` bei 0 % CPU; die betroffenen Dateien einzeln grün,
ein Lauf grün in 22 s, CI unter Linux grün. Stopp und Bericht; nach Neustart
des Macs (Vorgabe des Projektverantwortlichen) zwei volle Läufe nacheinander
grün in 22 s, `--concurrency=1` nicht nötig. Ursache offen → Kandidat f für
Teil 1.4 (hohe Priorität).

## 2026-10-20 — Teil 1.4: Plan (Entwurf zur Freigabe)

Vorgabe des Projektverantwortlichen: Plan für Teil 1.4 im Format von
`plan-1.3.md`, noch kein Code; Reihenfolge = Priorität (Stabilität,
Bedienung, Tablet, Marke); Bildschirm-Dateien ab 1.4 erlaubt (je benannt),
Core-Logik und Tür unberührt, `module/` nur mit Begründung; Figma nur lesend,
Fehlendes als „Figma-Nachtrag“. Plan: `docs/plan-1.4.md`, Branch `teil-1.4`
von `main` @ `ce6431f`.

*Grundlagen aus der Durchsicht (nur gelesen):* 15 Core-Testdateien unter
`test/ui/` öffnen eine Datenbank (88 Widget-Tests), 12 mit eigenen Kopien der
Helfer aus 1.1d, 3 inline; 20 feste Wartezeiten (50–200 ms); die 5 App-Tests
mit Datenbank schließen noch nach dem Muster vor 1.1d. Der „Vermerk C29“ ist
die Beobachtung eines stehenden Laufs in C29 (Teil 1.2). Figma zeigt Liste
und Detail nur mit Auswahl (`147:9746`, `147:9823`), keine Editor-Zeilen mit
Menü, keinen Zustand „Keine Treffer“ für Bildschirm 9, kein App-Symbol und
kein Startbild; der Master in der Fassungsleiste und Suchtreffer im
Listeneintrag sind gestaltet. Daraus die Figma-Nachträge N1–N6 und die Fragen
F1–F13 im Plan.

**Freigabe des Plans (Projektverantwortlicher, 2026-10-20):** Plan Teil 1.4
geprüft und freigegeben. Antworten: F1 ja — Rezepttexte nur im Rezeptdetail
markierbar (B05, nach N6); F2 Rückgängig beibehalten, kein Commit; F3
`material_ui` als eigener kleiner Teil nach 1.4; F4 `Icon/more` „⋮“, Tooltips
wie vorgeschlagen, N1 kommt von Figma — liegt sie zu Beginn von Etappe 2 nicht
vor, B01 aus vorhandenen Komponenten mit Abweichung in
`rueckmeldung-figma.md`; F5 ja (B04); F6–F8 wie empfohlen (F7: bis N3
vorliegt, Leerstelle „Rezept auswählen.“ bzw. „Lebensmittel auswählen.“); F9
„unsalted“ klein, nur sichtbare Namen; F10 nur mit Dateien aus Figma,
`flutter_launcher_icons` als `dev_dependency` der App in Ordnung; F11 ja; F12
ja (2 min je Test, Abnahme wie geplant); F13 ja. Weiter mit S01, Stopp nach S01
mit Bericht. Die Antworten stehen auch in `docs/plan-1.4.md`, Abschnitt (g).

**S01 — Wiederholungswerkzeug und Diagnose.** Neu `tool/repeat_tests.dart`
(nur `dart:io`, wie `check_architecture.dart`): `--package`, `--runs`,
`--concurrency`, `--timeout`, `--max-minutes` (beendet den Lauf samt aller
Kindprozesse über den Prozessbaum aus `ps`; geprüft: nach einem beendeten Lauf
kein `flutter_tester` übrig), `--load K` (K Endlosschleifen der Shell),
`--randomize`, `--log-dir`, `--` für weitere Argumente; Reporter `expanded`,
je Lauf Dauer, Ergebnis, rote Tests und Zeitüberschreitungen mit Namen,
`runs.csv`.

*Befund zum Zeitlimit (wichtig für F12/S02).* `testWidgets` setzt sein
Zeitlimit selbst: `timeout: timeout ?? binding.defaultTestTimeout`
(`flutter_test/lib/src/widget_tester.dart:204`), und
`AutomatedTestWidgetsFlutterBinding.defaultTestTimeout` ist 10 min
(`binding.dart:2240`). Ein ausdrückliches Zeitlimit am Test geht dem
Standard aus Kommandozeile und `dart_test.yaml` vor — `flutter test --timeout
300ms` ließ alle Widget-Tests grün. Wirksam ist das Limit nur über die Bindung,
z. B. in `test/flutter_test_config.dart` (`testExecutable`). Für die
Diagnose lag dort vorübergehend (nicht committet) eine Datei mit 90 s je
Widget-Test; Gegenprobe mit 100 ms: alle Tests der Datei mit „Test timed out
after 0.1 seconds“ rot, der Lauf endete trotzdem nach 3 s (die Teardowns aus
1.1d greifen).

*Matrix (Mac, 15 logische Kerne, Flutter 3.47.5, Drift 2.35.0; 90 s je
Widget-Test):*

| Serie | Läufe | grün | Dauer min/median/max | Befund |
|---|---|---|---|---|
| D1 Standard | 20 | 20 | 24 / 25 / 25 s | kein Hänger |
| D2 `--concurrency=1` | 20 | 18 | 101 / 103 / 445 s | 2 Hänger, beide in `recipe_detail_screen_test.dart`: Lauf 9 „Aktion "Bearbeiten" öffnet den Editor der gewählten Version (Nachtrag 8.8a)“, Lauf 14 „UI-33: beim Versionswechsel …“; danach jeweils weitere Tests derselben Datei rot (Lauf 9 dauerte 431 s, Lauf 14 232 s) |
| D3 Standard unter Last (15 Prozesse) | 10 | 10 | 26 / 27 / 27 s | kein Hänger |
| D4 zufällige Reihenfolge | 10 | 10 | 24 / 25 / 25 s | kein Hänger |

Last allein (H2) löst die Hänger nicht aus, die Reihenfolge innerhalb der
Dateien (D4) auch nicht; mit `--concurrency=1` traten sie auf (2 von 20) —
H3 in der Form „parallel verschärft“ ist damit widerlegt. Die Protokolle der
Matrix lagen im Scratchpad unter `/private/tmp` und gingen beim Neustart des
Macs verloren; die Zahlen oben stammen aus der Auswertung davor. D5 (die
betroffene Datei vorübergehend instrumentiert, 50 × allein und volle Läufe
mit `--concurrency=1`) ging mit einem zweiten Neustart verloren, bevor ein Lauf
ausgewertet war. Vorgabe des Projektverantwortlichen: S01a sichert Werkzeug,
Plan mit Antworten und D1–D4 (ohne die vorübergehende Instrumentierung und
ohne die vorübergehende `flutter_test_config.dart`); D5 neu mit Protokollen
unter `packages/unsalted_core/build/diagnose/` (von Git ignoriert, übersteht
Neustarts), lange Läufe unter `caffeinate -dims`, D5b mit 10 Läufen.

*D5 (2026-10-21, Protokolle in `packages/unsalted_core/build/diagnose/`, Lauf
unter `caffeinate -dims`).* `recipe_detail_screen_test.dart` vorübergehend
instrumentiert (Zeitmarken in `_settle`, `_seedDraftRecipe` und beim
Schließen getrennt nach `streamQueries.close` und `executor.close`; nicht
committet, Kopie als `instrumentierung.diff` im Diagnoseordner), 90 s je
Widget-Test:

| Serie | Läufe | grün | Dauer min/median/max |
|---|---|---|---|
| D5a: die Datei allein | 50 | 50 | 24 / 24 / 27 s |
| D5b: volle Suite, `--concurrency=1` | 10 | 10 | 101 / 101 / 101 s |

Kein Hänger. 840 Schließvorgänge (Baum abbauen bis geschlossen) dauerten
0,6 / 1,2 / 2,2 / 3,0 ms (min / median / p99 / max).

*Versuch zum Mechanismus (vorübergehend, nicht committet).* A: Abfrage in der
Fake-Zone abonniert, Baum abgebaut, Listener **nicht** abbestellt, dann
`runAsync(database.close)` → schließt sofort; ein offener Listener allein
löst den Hänger also nicht aus. B: dieselbe Lage, `database.close()` in der
Fake-Zone gestartet und abwechselnd gepumpt und echt gewartet → schließt.

*Ergebnis S01.* Hänger in 2 von 120 Läufen (D1–D5), beide in D2
(`--concurrency=1`) in `recipe_detail_screen_test.dart` (Versionswechsel bzw.
Navigation zum Editor), dazu die 3 von 4 Läufe in der Nacht zum 20.10. (mit
Standard-Parallelität) und die Beobachtung aus C29. Die Ursache ist lokal
**nicht nachgestellt**; Last (D3) und Reihenfolge (D4) lösen nichts aus, ein
offener Listener auch nicht. Das Muster (Test steht bei 0 % CPU, bis das
Zeitlimit greift) passt zur Klasse aus 1.1d: Das Schließen der Datenbank
wartet auf Arbeit in der Fake-Zone, die während `runAsync` niemand
weiterschaltet. S02 härtet deshalb das Schließen selbst (in der Fake-Zone
starten, abwechselnd pumpen und echt warten, mit Grenze und klarer Meldung)
und setzt ein wirksames Zeitlimit je Widget-Test (2 min über die Bindung);
feste Wartezeiten bleiben. Endgültige Testzeilen: `docs/plan-1.4.md`, (d2)
S02, Nachtrag nach S01 — zur Freigabe.

**Freigabe S01 (Projektverantwortlicher, 2026-10-21):** Testzeilen-Liste für
S02 und die Abweichungen 1–3 (Zeitlimit über die Bindung, feste Wartezeiten
bleiben, UI-83 prüft den Helfer) freigegeben. Ergänzung für S03: zusätzlich
30 volle Core-Läufe mit `--concurrency=1` (die einzige Bedingung mit Hängern
in der Matrix), Protokolle unter `packages/unsalted_core/build/diagnose/`,
lange Läufe mit `caffeinate -dims`; Plan-Nachtrag ergänzt.

**S02 — Behebung.** Neu in Core `test/ui/support/db_widget_harness.dart`
(`closeTestDatabase`, `closeDatabasePumping`: Baum abbauen und auspumpen,
`database.close()` in der Fake-Zone starten, dann abwechselnd `pump(50 ms)` und
`runAsync(20 ms)`, höchstens 200 Runden, sonst `fail` mit Meldung; Fehler aus
`close()` werden weitergereicht), `test/ui/support/db_widget_harness_test.dart`
(UI-83) und `test/flutter_test_config.dart` (`defaultTestTimeout` 2 min, nur
das Zeitlimit). In der App `test/support/db_teardown.dart` (gleiche Logik über
die Tür, AT-09) und `test/flutter_test_config.dart`. Geändert nur die Zeilen
aus `plan-1.4.md` (d2) S02: in 15 Core-Dateien je eine Importzeile, in 12 der
Körper von `_closeDatabase` (zwei Zeilen → eine), in 3 der Inline-Teardown; in
5 App-Dateien je eine Importzeile und die Teardown-Zeile — maschinell geprüft:
keine `expect`-Zeile, keine Aufrufstelle, keine feste Wartezeit geändert.
*Gegenproben:* UI-83 (a) mit Schließen nur über `runAsync(close)` →
„Test timed out after 30 seconds“; UI-83 (c) ohne `flutter_test_config.dart`
→ Erwartet 2 min, war 10 min; App-Zeitlimit vorübergehend 100 ms →
`widget_test.dart` „timed out after 0.1 seconds“; danach alles zurück und grün.
*Nebenbefund:* In UI-83 (a) hielt ein `await subscription.cancel()` nach einem
`runAsync` den Testkörper selbst an (die Fortsetzung lag in der Fake-Zone, die
niemand auspumpte); ohne `await` (Drift plant den Abbestell-Timer synchron)
grün. Im Bestand gibt es kein solches `await`. Nachtrag 28.11.1 neu,
`CLAUDE.MD` Abschnitt 4 nachgeführt. Mac: Design 461, Core 451, App 12,
Widgetbook 10 Tests grün; `check_architecture` Exit 0; `flutter analyze` ohne
Befund.

**S03 — Abnahme Stabilität (2026-10-21, Stand `1b7bf24`).**
`tool/repeat_tests.dart` unter `caffeinate -dims`, Protokolle unter
`packages/unsalted_core/build/diagnose/S03/`; Zeitlimit je Widget-Test 2 min
(S02, keine vorübergehende Konfiguration mehr):

| Serie | Läufe | grün | Tests je Lauf | Dauer min/median/max |
|---|---|---|---|---|
| Core Standard | 20 | 20 | 451 | 24 / 25 / 25 s |
| Core unter Last (15 Prozesse) | 10 | 10 | 451 | 26 / 27 / 27 s |
| Core `--concurrency=1` | 30 | 30 | 451 | 102 / 102 / 102 s |
| App Standard | 10 | 10 | 12 | 5 / 5 / 5 s |

Kein Hänger, kein roter Test, keine Restprozesse vor einem Lauf. Abnahme
nach Plan (20 + 10 + 10) und Ergänzung (30 × `--concurrency=1`) erfüllt. CI des
PRs auf `1b7bf24` grün (mit Goldens unter Linux). Einordnung: Vor S02 traten
die Hänger in 2 von 120 Läufen auf, in D5 (60 Läufe) schon nicht mehr; 0 von 70
nach S02 belegt deshalb nicht, dass S02 die (nicht nachgestellte) Ursache
beseitigt — wohl aber, dass der Helfer nichts verschlechtert. Gesichert ist:
ein Hänger in einem Widget-Test endet jetzt nach höchstens 2 min mit Namen,
beim Schließen der Datenbank nach rund 4 s mit klarer Meldung (UI-83).

## 2026-10-22 — Teil 1.4, Etappe 2 (Bedienung)

**Freigabe Etappe 1 und Vorgaben (Projektverantwortlicher):** Etappe 1
geprüft und freigegeben (S02/S03 sauber, CI grün). Weiter mit Etappe 2; zuerst
die Figma-Übergabe einspielen. Figma ist für 1.4 vollständig und
veröffentlicht: N1 liegt vor → B01 genau nach Figma („⋮“-Menü mit „Nach oben“
/ „Nach unten“ / „Entfernen“, in der ersten Zeile „Nach oben“ ausgegraut;
Beschriftungen 4 px zum eigenen Feld und 12 px zum Feld darüber; neue
Schrittzeile; gestrichelte Linie für „nicht verknüpft“ 2 px unter dem Feld).
N2 liegt vor (B03, mit Symbol). N6 liegt vor: `color/selection`,
`color/selection-handle` und `opacity/selection` stehen bisher nur in Figma →
vor B05 als Token-Nachtrag aus Figma in beide Token-Dateien (wie D12a), eigener
Commit. Für Etappe 3 vorgemerkt: N3 zeigt den leeren Detailbereich mit
Punktraster und **ohne Text** — das ersetzt die Zwischenlösung aus F7. Die ZIP
`unsalted-app-symbol-startbild.zip` bleibt bis Etappe 4 außerhalb des Repos.
Stopp nach Etappe 2.

**Figma-Nachträge N1–N6 übernommen.** `/Users/dalptri/teil-1.4-figma-nachtraege.md`
(aus dem Figma-Chat, Stand 21.10.2026; geprüft: reiner UTF-8-Text, 63 Zeilen,
keine Steuerzeichen) byte-gleich nach `docs/design/figma/teil-1.4-figma-nachtraege.md`.
`docs/design/figma/figma-ids.json`: `Navigation/Menu Item` jetzt `270:284`
(Set `state=default|disabled`), `Core/Nutrition Field` → `Data/Figure`
(`142:56`), `Core/Nutrition Header` → `Data/Figure Row` (`142:57`), neu
`Core/Nutrition Header` `272:297`, `Feedback/Tooltip` `273:374`,
`Input/Text Selection` `276:297`, `Brand/Logo` `275:18`, `Brand/Symbol`
`275:34`; neue Abschnitte `variablen_teil_1_4`, `muster` (Textauswahl
`276:304`), `marke` (App-Symbol und Startbild), in der App `teil_1_4` (neue
Rahmen), `bausteine_teil_1_4`, `entfernt_teil_1_4` („07 Versionen / Menü“).
Bestehende Schlüssel sonst unverändert, Format wie bisher; DS-17 (liest nur
`bibliothek.symbole`) grün. Die Hinweise „Für den Code“ der Übergabe gelten,
soweit die Vorgabe oben sie für Etappe 2 nennt (1–3 → B01, 5 → B05, 6 → B03;
7 → Etappe 3; 8 → Etappe 4). *Nicht im Umfang von Etappe 2, offen:* Hinweis 4
(Bildschirm 7 bei 200 %: Aktionen unter Titel und Datum) und die übrigen
Bibliotheksänderungen der Übergabe (`AppTextField(suffix:)`,
`AppListItem(leading:)`); Namen und IDs in `components.md` und
`rueckmeldung-figma.md` (A3 Kennzahlenleiste — Figma führt jetzt
`Data/Figure Row`) werden mit M03 nachgeführt.

**B01 — Zeilenmenü in Zutaten- und Schrittzeile (Figma N1).** Grundlage
`_Zeile/Zutat bearbeiten` (`7:712`) und `_Zeile/Schritt bearbeiten`
(`227:4142`), nur gelesen: beide vertikal mit `space-m` zwischen den Zeilen,
oben `space-s`, unten `space-m` und Haarlinie; Zeile 1 unten bündig (Griff
und Nummer mit `space-m` darunter, Feld mit Beschriftung `space-xs` darüber,
Menüknopf `Icon/more` 48 × 48); Zeile 2 eingerückt (Zutat: Menge
`reflow/value-column`, Einheit mit Beschriftung, Notiz; Schritt: Timer
`reflow/field-min`). *Design:* `AppOverflowMenu` additiv `tooltip`;
`AppDashedUnderline` zeichnet die Linie `space-xxs` unter dem Inhalt, außerhalb
des Layouts (`DashedPainter.underline(offset:)`), damit Griff und Menü bündig
bleiben; `AppSelect` berücksichtigt `expand` jetzt auch mit Beschriftung —
nötig, weil die beschriftete Einheit sonst die Breite des längsten Eintrags
(„Esslöffel“) nimmt und überläuft (UI-72 war damit rot); nur die Zutatenzeile
nutzt `expand`. Ein Kommentar mit Beispieltext „… Zutat“ im Design-Paket schlug
bei DS-06 an und ist ohne Beispiel neu gefasst. *Core:* `ingredient_row.dart`
und `step_row.dart` nach Figma (Menü statt `AppIconButton` mit Papierkorb,
optionale `onMoveUp`/`onMoveDown`, `null` = ausgegraut; Einheit mit
„Einheit“; `space-m`; `AppDivider.flush()` unten; schreibgeschützt ohne Menü),
die Abschnitte rufen für „Nach oben/unten“ `onReorder(i, i ∓ 1)` (gleiche
Werte wie Ziehen); Bildschirm-Dateien unverändert. *Geänderte bestehende
Testzeilen (freigegeben, Plan d2 B01):* `recipe_editor_screen_test.dart:176`
(Papierkorb-Tap → Menü öffnen, `pumpAndSettle`, „Entfernen“ — eine Zeile wird
drei), `editor_design_test.dart:133` (Tooltip „Zutat entfernen“ → „Aktionen
für Zutat“); sonst keine. *Neu:* DS-62 (Tooltip, Semantik, ausgegrauter
Eintrag; Standardtext ohne Tooltip), DS-64 (Unterstreichung `space-xxs`
darunter, Layout unverändert), DS-65 (`AppSelect` mit Beschriftung und
`expand` ohne Überlauf); UI-84 (Zutatenzeile: Menü, ausgegraute Einträge,
`onReorder`-Werte, Entfernen, „Einheit“, `space-m`, Menü bündig, Haarlinie,
schreibgeschützt ohne Menü), UI-85 (Schrittzeile: Menü, Griff/Nummer/Menü
bündig, Timer eingerückt, Haarlinie), UI-86 (Bildschirm 3: „Nach oben“,
Speichern, Positionen und Verknüpfungen wie bei UI-12). *Gegenproben:* ohne
Menü-Verschieben in den Abschnitten → UI-84, UI-85, UI-86 rot; Zutatenzeile
wieder `xs` → UI-84 rot; Schrittzeile oben ausgerichtet → UI-85 rot;
Unterstreichung ohne Abstand → DS-64 rot; `AppSelect` ohne `isExpanded` → DS-65
rot (Überlauf 96 px); danach alles zurück und grün. Nachtrag 28.11.2;
`rueckmeldung-figma.md` (neuer Abschnitt C: vier Abweichungen erledigt, B-Zeile
zum Auswahlfeld angepasst), `screens.md`, `components.md`, CHANGELOG des
Design-Pakets. Mac: Design 477, Core 455, App 12, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.
*Goldens:* Lauf 39806362646 (`goldens/b01`): abweichend 8 Bilder GL-01 `marken`
(Unterstreichung `space-xxs` unter dem Text) und 6 Bilder GL-02
`03_rezept_bearbeiten` (Menü „⋮“, „Einheit“ beschriftet, `space-m`, Haarlinie;
bei Handy 200 % liegen die Zutaten unterhalb des Ausschnitts). Angesehen:
„Milch“ (nicht verknüpft) zeigt die Strichlinie jetzt sichtbar unter dem Feld.

**B02 — Master in der Fassungsleiste.** `recipe_detail/version_switcher.dart`
additiv `masterVersionId`; die passende Marke bekommt `isMaster: true`
(`VersionMark` kannte den Master schon: Markerfläche, „…, Master“ in der
Semantik, seit D13). `recipe_detail/recipe_detail_screen.dart` übergibt
`recipe.masterVersionId` — eine Zeile in einer Bildschirm-Datei, im Plan
benannt. *Geänderte bestehende Testzeilen:* keine (ohne `masterVersionId`
bleibt die Leiste wie bisher, UI-67/68 unverändert). *Neu:* UI-87 in
`version_mark_test.dart` (Master `highlighted`, übrige unverändert, Auswahl
unabhängig, Semantik „Version 1, eingefroren, Master“) und in
`recipe_detail_screen_test.dart` (Rezept mit eingefrorener V1 als Master und
Entwurf V2: V1 mit Markerfläche). Im Bildschirmtest schlug das Einfrieren
zuerst still fehl („Eine Version ohne Zutaten kann nicht eingefroren
werden“ — `runAsync` gibt Ausnahmen nur über `takeException` weiter); der Test
legt deshalb eine Zutat an und prüft `takeException`. *Gegenproben:* ohne
Übergabe im Bildschirm → UI-87 (Bildschirm) rot; Leiste mit `isMaster: false`
→ UI-87 (Leiste) rot; danach grün. Nachtrag 28.11.3; `screens.md`,
`components.md`, `rueckmeldung-figma.md` (B-Zeile → C). Mac: Core 457 Tests
grün; `check_architecture` Exit 0.
*Goldens:* Lauf 39808152618 (`goldens/b02`): abweichend die 8 Bilder GL-02
`04_rezeptdetail` (V2 ist im Golden-Motiv Master: Markerfläche, Auswahlbalken
unverändert darunter).

**B03 — „Keine Treffer.“ in der Lebensmittelliste (Figma N2).**
`foods/sections/food_list_empty_section.dart` additiv `searching`: mit
Suchbegriff „Keine Treffer.“ mit Symbol `emptyPlate`, ohne Aktion, damit ohne
Leerstelle (Figma `09 / Keine Treffer` `218:3919`, Hinweis 6; wie Bildschirm 1,
D16); `foods/food_list_screen.dart` übergibt `_query.trim().isNotEmpty` — eine
Zeile in einer im Plan benannten Bildschirm-Datei. Ohne Suchbegriff
unverändert. *Geänderte bestehende Testzeilen:* keine
(`food_list_screen_test.dart:112–119` prüft den leeren Zustand ohne Suche).
*Neu:* UI-88 (Suche „Xyz“: „Keine Treffer.“, Symbol, kein „Eigenes Produkt
anlegen“, keine Leerstelle). *Gegenprobe:* ohne Übergabe von `searching` →
UI-88 rot; danach grün. Kein Golden-Motiv für Bildschirm 9. Nachtrag 28.11.4;
`screens.md`. Mac: Core 458 Tests grün.

**B04 — Suchtreffer in der Rezeptliste (F5).** *Design:* `AppListItem` additiv
`match` (Zeichenbereich des Titels): der Treffer als `TextSpan` in
`text-on-marker`, die Markerfläche (`marker`, `radius-xs`, seitlich
`space-xxs` wie `Highlight`) malt ein Painter hinter genau diese Zeichen
(`TextPainter.getBoxesForSelection`). Bewusst kein `WidgetSpan` mit
`AppHighlight`: damit bliebe der Titel kein Klartext, `find.text('Pizzateig')`
in `recipe_list_screen_test.dart:175` würde rot (ungeplante Testzeile) und die
Semantik müsste nachgebaut werden; so bleiben Klartext und Semantik
unverändert. Ungültige Bereiche werden ignoriert. *Core:*
`recipe_list/recipe_card.dart` additiv `query` mit `RecipeCard.matchOf` (erster
Treffer ohne Groß-/Kleinschreibung wie die Suche; nur wenn die Kleinschreibung
die Länge erhält), `recipe_list_results_section.dart` reicht `query` durch,
`recipe_list_screen.dart` übergibt `_query` (eine Zeile, Bildschirm-Datei im
Plan benannt). *Geänderte bestehende Testzeilen:* keine. *Neu:* DS-66
(Spans, Farbe, Markerfläche, `find.text` und Semantik mit dem ganzen Titel;
ohne/ungültig keine Markierung), UI-89 (Suche „TEIG“: Bereiche 4–8 und 5–9,
Semantik; `matchOf`-Fälle), Katalog-Anwendungsfall „Mit Suchtreffer“.
*Gegenprobe:* ohne Übergabe von `query` → UI-89 rot; danach grün. Kein
Golden-Motiv zeigt eine Suche. Nachtrag 28.11.5; `screens.md`,
`components.md`, `rueckmeldung-figma.md` (B-Zeile geteilt, Suchtreffer → C),
CHANGELOG. Mac: Design 485, Core 460, App 12, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.

**B05a — Token-Nachtrag Textauswahl aus Figma (N6, wie D12a).** Figma
(Bibliothek, nur gelesen): `color/selection` hell Alias `marker/400`, dunkel
`marker/500` („immer mit `opacity/selection`“); `color/selection-handle` hell
`neutral/900`, dunkel `neutral/50` (Griffe und Cursor); `opacity/selection`
40 %. Übernommen in `packages/unsalted_design/tokens/unsalted.tokens.json` und
`docs/design/system/tokens.json` (byte-gleich, F8): zwei Farbrollen hinter
`marker`, ein Deckkraft-Wert `opacity-selection` `"0.40"` (Format der übrigen
Deckkraftwerte), Nutzungstexte gekürzt aus den Figma-Beschreibungen. Die
Rundreise der JSON war vorher byte-gleich geprüft, sonst ist die Datei
unverändert. Generator neu: `AppColorTokens.selection`, `.selectionHandle`,
`AppOpacity.selection` (zweiter Lauf ohne Änderung). *Geänderte bestehende
Testzeilen (Design-Paket, Grund: zwei neue Rollen aus Figma):*
`ds04_tokens_complete_test.dart:7` (Kommentar „28 Farbrollen“ → „30“) und
`:53` (`hasLength(28)` → `hasLength(30)`). *Gegenprobe:* `opacity-selection`
nur in der JSON auf 0,45 geändert, nicht generiert → DS-04 rot; zurück.
Noch keine Verwendung im Theme (folgt in B05). `components.md`,
`design_system.md`, CHANGELOG. Mac: Design 485, Core 460, App 12, Widgetbook 10
Tests grün; `check_architecture` Exit 0.
*Goldens (Folge-Commit):* Die CI auf `5b3f602` war rot — das GL-01-Motiv
`tokens_farbe` zeigt alle Farbrollen, also auch die beiden neuen; meine
Annahme „ohne Verwendung im Theme kein Bild geändert“ war falsch, der
Golden-Lauf fehlte vor dem Push. Weil der Commit schon auf `teil-1.4` lag,
kommen die Bilder als eigener Commit (kein `--amend`, kein Force-Push). Lauf
39813330313 (`goldens/b05a`): abweichend die 8 Bilder `tokens_farbe`; angesehen:
`selection` (Marker) und `selection-handle` (Tinte) hinter `marker`, sonst nur
verschoben. Künftig vor jedem Push mit Token- oder Design-Änderung den
Golden-Lauf über den Hilfsbranch.

**B05 — Markierbare Rezepttexte (F1, Figma N6).** *Design:*
`component_themes.dart` mit `textSelection` (`TextSelectionThemeData`:
`selectionColor` = `selection` × `opacity-selection`, `selectionHandleColor`
und `cursorColor` = `selection-handle`, Figma-Hinweis 5) und `cupertino`
(`NoDefaultCupertinoThemeData(primaryColor: selection-handle)` — auf iOS nehmen
Griffe und Cursor diese Farbe); `AppTheme` setzt `textSelectionTheme` und
`cupertinoOverrideTheme`. Das gilt in der ganzen App, also auch für Cursor und
Auswahl in Eingabefeldern (vorher Material-Standard aus dem `ColorScheme`). Neu
`AppSelectableArea` (`SelectionArea`, Figma `Input/Text Selection`); Tür,
`public_api_golden.txt` (eine Zeile, DS-03), Katalog „Input/Text Selection“,
CHANGELOG. *Core:* `recipe_detail_description_section.dart`,
`…_ingredients_section.dart`, `…_steps_section.dart` betten ihren Inhalt in
`AppSelectableArea` (Überschriften bleiben außerhalb; Abstände und
Reihenfolge unverändert); keine Bildschirm-Datei. *Geänderte bestehende
Testzeilen:* keine (die Texte bleiben `Text`-Widgets; `find.text` und die
Semantik unverändert). *Neu:* DS-67 (Theme hell/dunkel, Cupertino-Primärfarbe;
langes Drücken markiert und zeigt „Copy“), UI-90 (Beschreibung, Zutat und
Schritt in `AppSelectableArea`, Titel, „V1“ und Überschriften nicht;
langes Drücken auf den Schritt zeigt das Kontextmenü). *Gegenproben:* Theme
ohne `textSelectionTheme` → DS-67 rot; `AppSelectableArea` ohne `SelectionArea`
→ DS-67 und UI-90 rot; Beschreibung nicht eingebettet → UI-90 rot; danach
grün. Nachträge 28.11.6 und 28.11.11 (Sammelpunkt Design-Paket);
`components.md`, `screens.md`. Mac: Design 491, Core 461, App 12, Widgetbook
10 Tests grün; `check_architecture` Exit 0.

## 2026-10-22 — Teil 1.4, Etappe 3 (Tablet)

**Freigabe Etappe 2 und Vorgaben (Projektverantwortlicher):** Etappe 2
geprüft und freigegeben (CI grün, nur geplante Testzeilen). Weiter mit Etappe
3; vorher als eigene Commits mit Tests und Goldens die Bibliotheksänderungen
aus der Figma-Übergabe, auf denen die Listen aufbauen: T00a
`AppListItem(leading:)` und Umbruch bei großer Schrift nach Hinweis 4 (damit
Bildschirm 7 bei 200 % stimmt; ohne Bildschirm-Datei, sonst Stopp), T00b
`AppTextField(suffix:)` für die Lupe „Lebensmittel verknüpfen“ am Feldende wie
in Figma. Dann T01–T03, leerer Detailbereich nach N3 (Punktraster, ohne Text).
Für Etappe 4 (vor M03) vorgemerkt: eingefrorene Ansicht nach Figma `42:2010`,
restliche Namen und IDs in `components.md` und `rueckmeldung-figma.md`.
Golden-Lauf vor jedem Push; ungeplante Core-Testzeilen → Stopp; Stopp nach
Etappe 3.

**T00a — Umbruch im Listeneintrag (Figma `List/Item`, Hinweis 4).**
`AppListItem(leading:)` gab es schon (seit 1.2); neu ist der Umbruch. Figma
(Schrift 200, `73:3817`, nur gelesen): `List/Item` als umbrechende Zeile
(Abstand 12, Innenabstand 12/16), Marke vorn, Zustand und Datum füllen, die
Aktionen rechtsbündig in eigener Zeile darunter. *Umsetzung (Design):* Mit
`trailing` steht der Eintrag (`ListTile` mit Element vorn, Titel, Untertitel —
unverändert) zusammen mit dem Element hinten in einer `ReflowRow`. Kriterium:
die minimale Eigenbreite des `ListTile` (Innenabstand + Element vorn + Abstand
+ breitestes Wort von Titel oder Untertitel, so rechnet Flutter selbst) muss
neben das Element hinten passen — sonst steht es rechtsbündig darunter, über
die volle Breite, mit `space-m` darunter; nebeneinander senkrecht mittig wie
bisher. Ein erster Versuch mit der `ReflowRow` nur im Titelplatz scheiterte an
UI-68 (lange Marke „V2 · mit Vorteig“ ließ den Aktionen zu wenig Breite,
Überlauf) — deshalb über den ganzen Eintrag. `ReflowRow` (intern) additiv
`stackedGap`, `stackedEndGap`, `centered`, `mainMinIntrinsic`; `AppNotice`
unverändert. Ohne `trailing` baut `AppListItem` exakt wie bisher. Keine
Bildschirm-Datei; `version_tile.dart` unverändert. *Geänderte bestehende
Testzeilen:* keine. *Neu:* DS-68 (Handy 200 %: Aktionen unter Titel und
Untertitel, rechtsbündig, `space-m` darunter, Titel einzeilig, kein Überlauf;
Tablet 100 %: daneben, mittig), UI-93 (Versionseintrag bei 600 Breite: 200 %
Aktionen unter Zustand und Datum, „Eingefroren“ einzeilig; 100 % daneben).
*Gegenprobe:* altes `ListTile(trailing:)` → DS-68 und UI-93 (200 %) rot;
danach grün. Nachtrag 28.11.12; `components.md`, `screens.md`, CHANGELOG. Mac:
Design 493, Core 463, App 12, Widgetbook 10 Tests grün; `check_architecture`
Exit 0.

**T00b — Suffix im Eingabefeld (Figma `Input/Text Field` `showSuffix`).**
`AppTextField(suffix:)` gab es schon (D08). Figma (nur gelesen): `Suffix` ist
ein `Button/Icon` 48 × 48 am Feldende, „bündig an der Kontur; der Wert endet
`space/m` davor“. Gemessen (vorübergehender Probetest, gelöscht): Knopf schon
48 × 48 und bündig, der Wert endete aber nur 4 px davor — Material 3 setzt
`inputToSuffixGap` fest auf 4. *Umsetzung:* das Suffix bekommt links `space-s`
Innenabstand (4 + 8 = `space-m`); Knopf bleibt bündig. *Geänderte bestehende
Testzeilen:* keine. *Neu:* DS-69 (Knopf `size-target`, bündig, Abstand genau
`space-m` — ändert Flutter seine 4 px, wird DS-69 rot), UI-94 (Lupe der
Zutatenzeile am Feldende, Name endet `space-m` davor). *Gegenprobe:* ohne
Innenabstand → DS-69 und UI-94 rot; danach grün. Nachtrag 28.11.13;
`components.md`, CHANGELOG. Mac: Design 497, Core 464, App 12, Widgetbook 10
Tests grün; `check_architecture` Exit 0.

**T01 — Rahmen „Liste und Detail“ (Design).** Figma (nur gelesen): Tablet
hochkant „01+04“ `147:9746` und „09+10“ `147:9823` (Seitenleiste 96, Liste
360, Detail 568 mit Haarlinie links, Inhalt ab x = 1, eigene Kopfleiste);
ohne Auswahl `219:4396`/`219:4706` (N3: Punktraster über die ganze Fläche,
ohne Text, ohne Kopfleiste); Handy quer `148:3817` (844: nebeneinander,
Detail 388, Seitenrand 24); Tablet quer `148:4381` (1366: Detail 910
zweispaltig, Spalten 455, Rand 16/24). *Umsetzung:* neu
`ListDetailTemplate(list:, detail:)` — unter `breakpoint-expanded`
(Fensterbreite, wie Seitenleiste und Material) nur `list`; ab da Liste in
`size-list-pane`, daneben das Detail über den Rest auf `surface-page` mit
Haarlinie links (`stroke-hairline`, `line-hairline`), Inhalt neben der Linie;
ohne `detail` das vorhandene Punktraster (`line-dot`), ohne Text und ohne
Semantik. Liste und Detail stehen in einer gemeinsamen Seite (`AppPage`):
eine Meldung wie „Rückgängig“ erscheint sonst in jeder der beiden Seiten
(Flutter zeigt eine `SnackBar` in jedem äußersten `Scaffold`; in der App fängt
das die Hülle ab, in Tests und Katalog nicht). `ListDetailTemplate.isSplit(context)`
sagt dem Bildschirm, ob Tippen auswählt oder navigiert. Die Seiten in Liste und Detail richten sich
weiter nach der Fensterbreite (Seitenrand, Detail zweispaltig ab
`breakpoint-large`) — genau so zeigt es Figma bei 844 und 1366 (gemessen:
`DetailSections` ergibt dort Spalten 455 mit Rand 16/24 bzw. Seitenrand 24);
die Fenstergröße wird für das Detail nicht übersteuert. Die Seitenleiste
bleibt in der App-Hülle (`AppPage.navigation`), Liste und Detail sind
innere Seiten. Katalog: „ohne Auswahl“, „mit Auswahl“. *Geänderte bestehende
Testzeilen:* keine; DS-46–48 und DS-60 unverändert grün. *Neu:* DS-63 (je
Variante: Handy nur Liste, Tablet Liste 360, Detail füllt den Rest,
Haarlinie nur links, Punktraster neben der Linie über die ganze Fläche,
erster Punkt bei `space-l`, kein Text; mit Detail zwei Kopfleisten, Detail
ab 361; Grenze 839/840 über `isSplit`; Meldung aus dem Detail einmal; 200 %
ohne Überlauf), GL-01-Motiv
`template_liste_detail`. *Gegenprobe:* Schwelle `medium` statt `expanded`
und Punkte in `line-hairline` → DS-63 rot (Grenze 839; Punktfarbe nur dunkel,
hell sind `line-dot` und `line-hairline` gleich); ohne gemeinsame Seite →
Meldungsfall rot (zwei Meldungen); danach grün. Nachtrag 28.11.11;
`components.md`, CHANGELOG. Mac: Design 510, Core 464, App 12,
Widgetbook 10 Tests grün; `check_architecture` Exit 0.

**T02 — Rezepte: Liste und Detail (Bildschirm 1/4).** *Umsetzung:*
`RecipeListScreen` baut `ListDetailTemplate`; die Liste ist die bisherige
`ListPageTemplate`. Auswahlzustand `_selectedId` im Bildschirm (F8, keine
Routen): ab 840 (`ListDetailTemplate.isSplit`) wählt Tippen aus, darunter
wie bisher `Navigator.push`. Das Detail ist `RecipeDetailScreen` mit
`ValueKey` der Auswahl (ein Wechsel lädt das andere Rezept frisch, Version =
Master) und additiv `onClose`: „Rezept löschen“ hebt dann die Auswahl auf,
statt die Seite zu schließen (`deleteRecipeWithUndo` liest Messenger,
Repository und Notifier sofort; der Bereich darf danach verschwinden).
Wischen-Löschen des gewählten Rezepts hebt die Auswahl ebenfalls auf; nach
„Rückgängig“ bleibt sie aufgehoben. Auswahlbalken über `RecipeCard.selected`
→ `AppListItem.selected`, nur nebeneinander. Die Auswahl übersteht das
Verkleinern (F6): unter 840 nur die Liste ohne Balken, beim Vergrößern
wieder das Detail. „Zurück“ gibt es im Bereich nicht, weil die Liste keine
geöffnete Seite ist (`AppTopBar` folgt Material). „Rezept anlegen“
(`recipe_create_screen.dart`, nicht im Plan) öffnet nach dem Speichern
weiter das Rezeptdetail als eigene Seite. *Geänderte bestehende
Testzeilen:* keine (12 Tests der Rezeptliste, UI-40 und APP-04 unverändert
grün). *Neu:* UI-91 (bei 1024 × 1366 und 844 × 390: ohne Auswahl leerer
Bereich, Tippen wählt — Detail rechts ab 360, Balken, keine neue Seite,
kein „Zurück“ —, Wechsel, „Rezept löschen“ hebt die Auswahl auf, eine
Meldung, nach 5 s gelöscht; Wischen hebt die Auswahl auf; Auswahl übersteht
390 × 844, unter 840 eigene Seite). GL-02: neues Motiv `01_04_liste_detail`
(Tippen auf „Hefezopf klassisch“) über einen zusätzlichen Helfer im
Golden-Test, bestehende Zeilen unverändert; `01_rezeptliste` Tablet ändert
sich (leerer Detailbereich). *Gegenprobe:* ohne `onClose` → UI-91 (Löschen)
rot; Tippen immer `push` → alle vier UI-91 rot; danach grün. Nachtrag
28.11.7; `screens.md`. Mac: Design 510, Core 468, App 12, Widgetbook 10
Tests grün; `check_architecture` Exit 0.

**T01a — Rahmen hält den Zustand beim Wechsel über 840 (Design).**
*Anlass (beim Vorbereiten von T03):* Unter `breakpoint-expanded` baute
`ListDetailTemplate` nur die Liste; ein gewähltes Detail fiel aus dem Baum.
Für das Rezeptdetail heißt das nur neu laden, für den Lebensmittel-Editor im
Bereich aber: Dreht man ein iPhone von quer (844, nebeneinander) auf hochkant
(390), sind ungespeicherte Eingaben ohne Rückfrage weg. F6 verlangt, dass die
Auswahl erhalten bleibt und beim Vergrößern wieder erscheint. *Umsetzung:*
`ListDetailTemplate` ist jetzt ein `StatefulWidget`; Liste und Detail hängen
an je einem `GlobalKey` und werden beim Wechsel der Anordnung umgehängt statt
neu gebaut (Suche, Scrollposition, Eingaben bleiben). Unter 840 bleibt ein
gewähltes Detail als `Visibility(visible: false, maintainState: true)` im
Baum: nicht gemalt, ohne Semantik, ohne Animation, ohne Fokus. Den Fokus
nimmt ein eigenes `ExcludeFocus` innerhalb des gehaltenen Teilbaums weg: Das
`ExcludeFocus` aus `Visibility` entsteht beim Umhängen neu und entzieht den
Fokus nur beim Umschalten, nicht beim Einhängen (gemessen: das Feld behielt
sonst den Fokus). Ohne Auswahl baut der Rahmen unter 840 wie bisher nur die
Liste. Öffentliche Schnittstelle unverändert; nur die T01-Datei. Bekannte
Grenze: Ein verborgener Editor mit ungespeicherten Eingaben hält seine
Rückfrage beim Zurück der Plattform (Android) auch unter 840. *Geänderte
bestehende Testzeilen:* keine. *Neu:* DS-63 „Zustand bleibt beim Wechsel“
(1024 → 839 → 1024: Detail verborgen, aber im Baum, ohne Fokus, ohne
Semantik; Liste behält ihre Suche; Detail behält ungespeicherte Eingaben).
*Gegenprobe:* ohne `GlobalKey` → DS-63 rot (Eingaben weg); ohne eigenes
`ExcludeFocus` → rot (Fokus bleibt im verborgenen Feld); danach grün.
`components.md`, CHANGELOG, 28.11.7 und 28.11.11. Mac: Design 511, Core 468,
App 12, Widgetbook 10 Tests grün (UI-91 unverändert); `check_architecture`
Exit 0.

**T03 — Lebensmittel: Liste und Editor (Bildschirm 9/10).** *Umsetzung:*
`FoodListScreen` baut `ListDetailTemplate` wie T02; Zustand `_selectedId`,
`_creating` (neues Lebensmittel im Bereich), `_round` (Schlüssel des Editors:
ein Abschluss lädt ihn frisch) und `_detailDirty`. Ab 840 wählt Tippen aus,
„Neues Lebensmittel“ (Marker-Knopf, leerer Zustand) öffnet den Editor im
Bereich; darunter wie bisher `Navigator.push`. `FoodEditorScreen` additiv:
`onDone` — nach dem Speichern mit der ID (beim Anlegen die neue aus
`createVariant`, die Liste wählt sie), nach Löschen und Verwerfen mit `null`
statt `pop` —, `onDirtyChanged` (gemeldet aus `PackageForm.onChanged` und
beim Verlassen, nie im `build`) und die Rückfrage als
`FoodEditorScreen.confirmDiscard` (Texte aus 10.0 unverändert; der Editor
selbst nutzt sie weiter). Die Liste fragt vor jedem Auswahlwechsel und vor
„Neues Lebensmittel“, solange der Editor Änderungen meldet; „Abbrechen“
lässt alles stehen. Löschen im Bereich und Wischen-Löschen des gewählten
Lebensmittels heben die Auswahl ohne Rückfrage auf (wie 1.1b). „Zurück“ der
Plattform mit Änderungen im Bereich fragt weiter über `PopScope`; nach
„Verwerfen“ meldet der Editor `onDone(null)` (Auswahl aufgehoben) statt die
Liste zu schließen (28.11.8). Seite unter 840 unverändert (UI-29–32, UI-43
grün). *Geänderte bestehende Testzeilen:* keine (Lebensmittel-Liste 8 Tests,
Editor 8 Tests unverändert grün). *Neu:* UI-92 (1024 × 1366: Auswahl, Editor
rechts ab 360, keine neue Seite, kein „Zurück“; Speichern lässt den Bereich
offen, Liste zeigt den neuen Namen; Wechsel ohne Änderungen ohne Rückfrage;
mit Änderungen Rückfrage — „Abbrechen“ bleibt, „Verwerfen“ wechselt ohne zu
speichern; „Neues Lebensmittel“ im Bereich, nach dem Anlegen gewählt;
„Löschen“ im Bereich ohne Rückfrage, Auswahl aufgehoben, eine Meldung, nach
5 s gelöscht; Eingaben überstehen 844 × 390 → 390 × 844 → zurück).
*Gegenprobe:* Wechsel ohne Rückfrage → UI-92 rot; ohne `onDone` → zwei UI-92
rot; danach grün. Goldens: kein Motiv betroffen (`10_lebensmittel_bearbeiten`
zeigt den Editor als eigene Seite). Nachträge 28.11.7 (ergänzt), 28.11.8;
`screens.md`. Mac: Design 511, Core 471, App 12, Widgetbook 10 Tests grün;
`check_architecture` Exit 0.

## 2026-10-24 — Teil 1.4, Etappe 4 (Marke und Abschluss)

**Freigabe Etappe 3 und Entscheidungen (Projektverantwortlicher):** Etappe 3
geprüft und freigegeben (CI auf `6c81299` grün, Goldens geprüft, nur
erlaubte Dateien, keine Testprüfung geändert). T01a nachträglich
freigegeben; die bekannte Grenze (Android-Zurück fragt auch bei verborgenem
Editor) ist Kandidat für später. Entscheidung 1 aus dem Bericht (Zurück im
Lebensmittel-Bereich fragt wie bisher, „Verwerfen“ hebt die Auswahl auf)
freigegeben. Entscheidung 2 („Rezept anlegen“ öffnet ab 840 weiter eine
eigene Seite) für 1.4 freigegeben; Anlegen im Liste-Detail-Rahmen ist
Kandidat (braucht `recipe_create_screen.dart`). App-Symbol und Startbild aus
Figma (Bibliothek `5er28Cr7EMMcPzvusWjNyR`, Seite „Marke“) freigegeben;
**das Startbild ist bewusst ohne Punktraster, nur Fläche und Symbol** wie in
`275:75`/`275:79`, weil Android 12 nur Fläche und Symbol erlaubt (auch in
28.11 festgehalten, mit M02b). Reihenfolge: M00a, M00b (Design), M00c,
M01, M02a, M02b, M03; Stopp nach M03, kein Merge, keine Tags.

**M00a — Eingefrorene Ansicht gegen Figma `42:2010`.** Figma (nur gelesen,
nach dem Code neu gebaut): `42:2010` hell, `217:18576` dunkel, Inhalt
`_Inhalt/Eingefroren · V3` `217:3883`. Vergleich: Bildschirm 3 für die
eingefrorene V1 der Golden-Fixture lokal mit echten Schriften gerendert
(vorübergehende Probe, nicht committet) und mit den Figma-Bildern
verglichen. Übereinstimmend: Hinweis `info` mit Kapitel-22-Text und
„Kopieren“ (tertiär), `space-l`, Zustandsrahmen `fixed` mit Marke samt
Siegel und „Eingefroren“, Zutaten als Listeneinträge mit Menge, Schritte nur
mit Titel. Unterschiede: (1) zwei Linien mit Abstand zwischen Zutaten und
Schritten statt einer (Figma: `Divider` direkt unter dem letzten Eintrag) —
behoben in `recipe_editor_frozen_section.dart` (`AppDivider.flush()`, die
Ausnahme von Plan (c)); (2)–(4) Höhe des Markenkastens, Mitte der
Kopfzeile, Lage der Hinweis-Aktion, Innenabstand des Rahmens — liegen in den
Komponenten selbst (vom Projektverantwortlichen in der Bibliothek
nachgeprüft) → M00b; (5) Titel der Kopfleiste „Rezept bearbeiten“ statt
„Pizzateig · V3“ → offene Textfrage (Kapitel 22, Entscheidung des
Projektverantwortlichen), in 1.4 bleibt der Text; `rueckmeldung-figma.md`
unter B, `screens.md`, Kandidat in `status.md`. *Geänderte bestehende
Testzeilen:* keine. *Neu:* UI-95 (eine Linie `stroke-hairline` hoch, direkt
unter dem letzten Zutateneintrag, Schritte direkt darunter). *Gegenprobe:*
`AppDivider()` → UI-95 rot; danach grün. `rueckmeldung-figma.md`: die
A-Zeilen zur eingefrorenen Ansicht (Hinweistext, Zustandsrahmen) sind
erledigt (Figma folgt dem Code) → Abschnitt C. Goldens: kein Motiv zeigt die
eingefrorene Ansicht.

**M00b — Marke, Rahmen, Hinweis nach den Figma-Komponenten (Design).**
*Vorgabe (Projektverantwortlicher, in der Bibliothek nachgeprüft):* `Mark`
(`114:68`, fest `107:48`) Kasten 52 × 24, Text 16 hoch mittig, links und
rechts 9,5 = `space-s` + `stroke-frame`; `Frame` (`135:55`, fest `135:47`)
Kopfzeile 24 hoch, Zustandswort mittig zur Marke, Innenabstand 13,5 / 17,5 =
`space-m`/`space-l` + `stroke-frame`; `Feedback/Notice` (Instanz `42:2034`)
Aktion oben, 32 hoch, Beschriftung auf Höhe der ersten Zeile. Nur
`app_mark.dart`, `app_frame.dart`, `app_notice.dart`, `ReflowRow` additiv.
*Umsetzung:* `AppMark` — die Mindesthöhe `size-mark` sitzt jetzt auf dem
gezeichneten Kasten (vorher um ihn herum: der Kasten war nur so hoch wie der
Text), der Inhalt darin senkrecht mittig, das Siegel quer mittig zum Text
(Figma `counterAxisAlignItems: CENTER`; vorher oben — bei großer Schrift im
Golden-Lauf sichtbar), waagrecht `space-s` + `stroke-frame`; das äußere
`Center` bleibt, damit eine kurze Marke als Ziel
der Fassungsleiste nicht auf die Zielbreite gestreckt wird. Die belegte Höhe
bleibt max(`size-mark`, Texthöhe) wie vorher. `AppFrame` — Kopfzeile
`crossAxisAlignment.center`, Innenabstand `space-m`/`space-l` +
`stroke-frame` (beide Zustände). `AppNotice` mit Aktion — der obere
Innenabstand sitzt im Text statt um die Zeile, die Aktion steht über
`ReflowRow.baseline` (neu, additiv, Standard aus) an der ersten Grundlinie des
Textes; ihr Tippziel (48) ragt dafür in den Innenabstand. Die Beschriftung
verteilt den Zeilenabstand wie der Text gleichmäßig
(`DefaultTextHeightBehavior` um die Aktion): Der Text erbt `even` aus dem
Theme, die Material-Knöpfe nicht — sonst lagen die Zeilen trotz gleicher
Grundlinie 2 px (Testschrift) versetzt und der Text rückte nach unten (DS-32c
schlug dann an). Untereinander (große Schrift) und ohne Aktion unverändert
(DS-32c, DS-72). Gemessen (vorübergehende Probe, gelöscht): Tippziel 0–48,
Beschriftung und erste Zeile beide ab 12, Höhe des Hinweises unverändert.
*Geänderte bestehende Testzeilen:* keine; DS-53 und DS-32c unverändert grün.
*Neu:* DS-70 (Kasten in drei Zuständen bei 100/200 %: Höhe max(`size-mark`,
Text), belegte Höhe = Kasten, Inhalt mittig, Siegel mittig zum Text, links/rechts `space-s` +
`stroke-frame`; als Ziel nicht gestreckt, mittig), DS-71 (Zustandswort mittig
zur Marke, Kasten `size-mark`, Innenabstand mit Kontur in beiden Zuständen,
`space-s` unter der Kopfzeile), DS-72 (bei 1024 Breite 100/200 %
nebeneinander: Text `space-m` unter der Kante, Beschriftung auf Höhe der
ersten Zeile, Tippziel ≥ `size-target` und nicht über der Kante; ohne Aktion
unverändert). *Gegenprobe:* alte `AppMark` → DS-70 rot; Siegel ohne Querzentrierung →
DS-70 (200 %) rot; alter `AppFrame` →
DS-71 rot; alter `AppNotice` → DS-72 (100 %) rot; ohne `baseline` → DS-72
(200 %) rot; ohne gleichmäßige Verteilung → DS-72 rot; danach grün.
`rueckmeldung-figma.md`: A3 Tippziel der Hinweis-Aktion 48 statt 32 (bewusst),
B-Zeile „Aktion im Hinweis in `size-control-small`“ dadurch ersetzt, C drei
Zeilen erledigt; `components.md` (Regel „Die Kontur zählt zum
Innenabstand“), CHANGELOG, 28.11.11. Mac: Design 533, Core 472, App 12,
Widgetbook 10 Tests grün; `check_architecture` Exit 0.
*Goldens:* Lauf 40068756165 (`goldens/m00b2`; der erste Lauf 40068316746
zeigte bei 200 % das Siegel oben — daraufhin quer mittig): 32 Bilder
geändert — GL-01 `marken` (8: Kästen 24 hoch, Kopfzeile mittig, Siegel
mittig), GL-01 `rueckmeldung` (8: „Kopieren“ auf Höhe der Zeile; der
einzeilige Hinweis daneben 60 statt 72 hoch; untereinander 1–2 px durch die
gleichmäßige Verteilung), GL-02 `04_rezeptdetail` und `01_04_liste_detail`
(je 8: Marken der Fassungsleiste 24 hoch). Alle Bilder angesehen, bei 200 %
auf Abschneiden und Überlauf geprüft: nichts Neues. Der Streifen unter
„Erneut versuchen“ und der angeschnittene Knopf der Leerstelle im Motiv
`rueckmeldung` (Handy 200 %) standen schon vorher im Bild (feste Motivfläche
des Katalogs, Überlauf ist in Goldens erlaubt).

**M00c — Restliche Namen und IDs aus den Figma-Nachträgen (Doku).** (Im
ersten Auftrag „M00b“; die Bezeichnung ging an den Design-Commit.)
`components.md`: `Data/Figure Row`/`Data/Figure` statt `Core/Nutrition
Header`/`Field` (`142:57`/`142:56`), `Core/Nutrition Header` `272:297` beim
`NutritionHeader`, `Navigation/Menu Item` `270:284` (Set `state`),
`Feedback/Tooltip` `273:374` beim `AppIconButton`, Muster „Textauswahl“
`276:304`, `Brand/Logo` `275:18` (noch nicht im Code) und `Brand/Symbol`
`275:34` (native Dateien, M02), Tablet-Rahmen samt „ohne Auswahl“ hoch/quer
beim `ListDetailTemplate`, `_Aktionen/Version · …` beim `VersionTile`, neu
die Zeile `RecipeEditorFrozenSection` (`217:3883`, `42:2010`).
`figma-ids.json`: Varianten `Mark` fest `107:48`, `Frame` fest `135:47`,
Instanzen in `42:2010` (`42:2034`, `217:3994`); alles Übrige stand schon
darin. `rueckmeldung-figma.md`: Abschnitt A gegen die Nachträge und die
Dateien geprüft (nur gelesen) — erledigt und nach C: Kennzahlenleiste
„kcal/Portion“ (`1:607`), Mengenrechner „kcal“ ohne Einheit (`179:392`),
Versionsvergleich ohne Metadaten (`3:595`), erste Kopfspalte der
Deklaration leer (`140:116`), Bildschirm 7 wie der Code (`20:1042`,
Aktionen in der Zeile), Kennzahlenleiste als `Data/Figure Row`, Tippziel
48 × 48 (`142:18`), Aktion bei großer Schrift darunter (`134:69`, `136:50`),
„*“ nach der Einheit (`134:179`); aus B nach C: Liste und Detail ab 840
(T01–T03). Offen bleiben in A: Hinzufügen/Entfernen im Vergleich (nur
Semantik), `Icon/delete`-Doppel, Größe des Auswahldialogs, Restzeitlinie
der Meldung, Tippziel der Hinweis-Aktion (M00b), Tokens/Regeln (A4, um die
Punkte ergänzt, die Figma jetzt zeigt). `screens.md`: Bildschirm 4 ohne
„bewusst anders“. Keine Code- und Teständerung.
