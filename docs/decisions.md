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