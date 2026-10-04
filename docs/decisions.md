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
