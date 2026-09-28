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