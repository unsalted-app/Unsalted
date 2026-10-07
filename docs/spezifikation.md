# unsalted — Technische Spezifikation

Maßgebliches Dokument für die Entwicklung von `unsalted`. Nur Technik. Kein Recht, keine Kosten, kein Store. Energie ist im gesamten System ausschließlich `energy_kcal`. Es gibt kein kJ-Feld, keine kJ-Anzeige, keine kJ-Umrechnung.

Phase 0 bis Phase 5 sind abgeschlossen. Die dort getroffenen Entscheidungen — Projektstruktur, Architekturregeln, Decimal-/Rational-Regeln, Rechenkern, Fachmodelle, Snapshot-Format und Drift-Datenbank — sind Teil dieser Spezifikation und binden alle folgenden Kapitel. Ab Phase 6 ist der Bericht die alleinige Grundlage für die weitere Entwicklung.

---

## Präambel: Globale KI-Regeln

Dieses Dokument dient als verbindliche technische Wahrheit und Ausführungsgrundlage. Die Bearbeitung der Entwicklungsschritte unterliegt zwingend den folgenden Regeln:

**KI-S1 — Isolierte Arbeitskarte.** Jeder Entwicklungsschritt muss ausschließlich anhand seiner Arbeitskarte, der dort referenzierten verbindlichen Contracts und des vorhandenen Projektzustands ausführbar sein. Nicht dokumentiertes Wissen aus früheren Implementierungen ist keine Voraussetzung.

**KI-S2 — Read Broad, Write Narrow.** Eine KI darf bestehende Projektdateien lesen, soweit dies zum Verständnis des aktuellen Schrittes erforderlich ist. Sie darf jedoch ausschließlich Dateien erstellen oder verändern, die im aktuellen Schritt ausdrücklich im Schreib-Scope („Erstellen“ / „Ändern“) gelistet sind.

**KI-S3 — Kein impliziter Contract.** Jede benötigte Klasse, Methode, Exception, Enum oder sonstige Schnittstelle muss entweder im aktuellen Schritt definiert oder als bestehender Contract mit vollständigem Pfad und vollständiger Signatur referenziert sein. Platzhalter, beispielhafte Signaturen und implizit angenommene APIs sind nicht zulässig.

**KI-S4 — Kein Vorgriff.** Ein Schritt erfüllt ausschließlich seine eigene Aufgabe. Funktionalität späterer Schritte oder späterer Teile darf nicht vorweggenommen, vorgezogen oder durch ungeplantes Refactoring vorbereitet werden.

Diese vier Regeln bilden die globale Ausführungsregel für KI-Agenten. Fachliche und architektonische Details bleiben jeweils in den dafür zuständigen Kapiteln autoritativ.
---


## Inhalt

1. Grundregeln
2. Projektstruktur
3. Pakete und Verantwortlichkeiten
4. Phase 0 — Projektgrundlage *(abgeschlossen)*
5. Phase 1 — Architektur *(abgeschlossen)*
6. Phase 2 — Rechenkern *(abgeschlossen)*
7. Zahlenregel (Decimal/Rational)
8. Nährwertsystem
9. Einheiten
10. Fachmodell und Persistenzmodell
11. Datenmodell (Datenbank)
12. Draft-Lebenszyklus und Versionierung
13. Snapshot-Format
14. RecipeChange
15. RecipeDiff
16. Öffentliche Verträge (Repositories, Services, Events, Provider)
17. Rechenkern als öffentliche Schnittstelle
18. Datei-für-Datei-Struktur
19. Architekturtests
20. Tragfähigkeit für die Teile 2–6
21. Modul-/Steckplatzsystem
22. UI-Spezifikation
23. Testplan
24. Entwicklungsplan
25. Freeze-Kriterien
26. Fehlersuche
27. Regeln für die KI
28. Nachträge und Klarstellungen zu Teil 1

---

# 1 Grundregeln

**R1 — Abhängigkeit nur nach hinten.** Ein Paket mit Rang N darf nur Pakete mit Rang < N importieren. Die Rangfolge steht in `architecture.yaml`.

**R2 — Eine öffentliche Tür je Paket.** Jedes Paket exportiert genau eine Datei `lib/<paketname>.dart`. Alles unter `lib/src/` ist privat. Fremde Pakete importieren ausschließlich die Tür, niemals `src/` eines anderen Pakets.

**R3 — Eigene Tabellen pro Teil.** Ein Teil legt nur neue Tabellen an. Verweise zwischen Teilen sind Text-UUIDs, keine Fremdschlüssel.

**R4 — Additive Erweiterung nach dem Freeze.** Neue Funktion = neue Datei, neue Tabelle, neue optionale Spalte, neuer Steckplatz. Eingefrorene Signaturen, Spalten und Formatfelder werden nicht verändert.

**R5 — Repository-Pflicht.** Alle Schreibzugriffe auf die Datenbank laufen über ein Repository. Kein Widget, kein Service, kein fremdes Paket schreibt direkt in eine Tabelle.

**R6 — Kein `double` für fachliche Werte.** Fachliche Zahlen sind `Decimal`, intern `Rational`. Kapitel 7 legt die vollständige Regel fest.

**R7 — Kein kJ.** Energie ist ausschließlich `energy_kcal`.

**R8 — Rundung nur im Formatter.** Rechenlogik im Rechenkern arbeitet ungerundet. Sichtbare Rundung entsteht ausschließlich in `NutritionFormatter`.

**R9 — Fachmodell ≠ Persistenzmodell.** Domain-Klassen und Drift-Tabellenzeilen sind getrennte Typen mit getrennter Verantwortung. Kapitel 10 legt die Grenze verbindlich fest.

---

# 2 Projektstruktur

```text
unsalted/
├─ PROJECT.md                     Regeln für Mensch und KI (Kapitel 27)
├─ architecture.yaml               Rangfolge der Pakete
├─ pubspec.yaml                    Pub-Workspace-Wurzel
├─ docs/
│  ├─ status.md                    Phase/Schritt: offen / in Arbeit / fertig
│  └─ decisions.md                 Protokoll technischer Entscheidungen und Spikes
├─ apps/
│  └─ unsalted_app/                App-Hülle: main.dart, DB-Executor, Modulliste, Router
├─ packages/
│  ├─ unsalted_core/               Kern — Rang 1
│  ├─ unsalted_experiments/        Experimente — Rang 2
│  ├─ unsalted_sync/                Konto & Synchronisation — Rang 3
│  ├─ unsalted_media/               Medien — Rang 4
│  ├─ unsalted_social/              Teilen/Forken/Sterne — Rang 5
│  └─ unsalted_assistant/           KI-Assistent — Rang 6
├─ server/
│  ├─ sync/ · media/ · social/ · assistant/
└─ tool/
   ├─ check_architecture.dart      Architektur-Prüfwerkzeug
   └─ import_usda.dart             außerhalb von Teil 1

```

`architecture.yaml`:

```yaml
packages:
  unsalted_core:        { rank: 1 }
  unsalted_experiments: { rank: 2 }
  unsalted_sync:         { rank: 3 }
  unsalted_media:        { rank: 4 }
  unsalted_social:       { rank: 5 }
  unsalted_assistant:    { rank: 6 }
  unsalted_app:          { rank: 99 }
forbidden_in_core:
  - "package:flutter/"      # erlaubt in lib/src/ui/ und lib/src/module/
  - "package:drift/"        # nur in lib/src/data/ erlaubt

```

Verwaltung über Pub-Workspaces (`workspace:` in der Wurzel, `resolution: workspace` in jedem Paket) oder Pfad-Abhängigkeiten (`path: ../unsalted_core`). Beide Varianten sind mit allen Regeln in diesem Bericht vereinbar.

---

# 3 Pakete und Verantwortlichkeiten

| **TeilPaketInhaltRangBrauchtEigene TabellenFertig wenn** |                        |                                                                                                                     |   |           |                                                                                     |                                                       |
| -------------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------- | - | --------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------- |
| 1                                                        | `unsalted_core`        | Rezepte, Versionen, Zutaten, Schritte, Lebensmittel, Nährwert-Rechner, Diff, Export/Import, UI, Steckplätze, Events | 1 | —         | `recipes`, `recipe_versions`, `recipe_ingredients`, `recipe_steps`, `food_variants` | Kapitel 25                                            |
| 2                                                        | `unsalted_experiments` | Experimente, Läufe, Bewertungen                                                                                     | 2 | 1         | `experiments`, `experiment_runs`                                                    | Experiment → Draft → Snapshot → Bewertung → Vergleich |
| 3                                                        | `unsalted_sync`        | Konto, Server-Datenbank, Geräteabgleich                                                                             | 3 | 1, 2      | server-seitig + `sync_state`                                                        | zwei Geräte gleichen ab, fremde Daten unsichtbar      |
| 4                                                        | `unsalted_media`       | Fotos/Videos                                                                                                        | 4 | 1, 3      | `media`                                                                             | Foto → Upload → Gerät B                               |
| 5                                                        | `unsalted_social`      | Veröffentlichen, Forken, Sterne, Feed                                                                               | 5 | 1, 3, 4   | server-seitig                                                                       | veröffentlichen, forken, Stern setzen                 |
| 6                                                        | `unsalted_assistant`   | KI-Chat mit Änderungsvorschlägen                                                                                    | 6 | 1, (2), 3 | `assistant_messages`                                                                | Vorschlag → Diff → Übernehmen                         |

Kapitel 20 beschreibt, welche Verträge aus Teil 1 die Teile 2–6 tragen, ohne deren eigene Spezifikation vorwegzunehmen.

---

# 4 Phase 0 — Projektgrundlage *(abgeschlossen)*

Diese Phase ist abgeschlossen. Sie ist die verbindliche Grundlage für jede folgende Phase.

## 4.1 Ergebnis

- Ordnerstruktur nach Kapitel 2 angelegt, Git initialisiert.
- `architecture.yaml` mit allen sieben Einträgen (Kapitel 2).
- `PROJECT.md` enthält die Grundregeln (Kapitel 1) und die KI-Regeln (Kapitel 27).
- `docs/status.md` führt jede Phase mit Status `offen` / `in Arbeit` / `fertig`.
- `docs/decisions.md` protokolliert technische Entscheidungen und Spike-Ergebnisse (siehe Kapitel 20 und 25).
- Paket `unsalted_core` angelegt (`flutter create --template=package packages/unsalted_core`), App-Hülle `unsalted_app` angelegt (`flutter create --org de.unsalted apps/unsalted_app`).
- Öffentliche Tür `lib/unsalted_core.dart` existiert als leere Exportdatei und wird in Phase 7 (Schritt 7.4) geschlossen.
- Abhängigkeiten von `unsalted_core` gesetzt: `decimal`, `rational`, `uuid`, `drift`, `drift_flutter`, `flutter_riverpod`, `go_router`, `intl` sowie als Dev-Abhängigkeiten `drift_dev`, `build_runner`, `test`.

## 4.2 Verbindliche Nebenregeln

- Versionsnummern von Paketen werden nie manuell eingetragen, sondern über `flutter pub add <paket>`bzw. `dart pub add <paket>` gesetzt und mit `dart pub outdated` kontrolliert. Referenz für aktuelle Versionen und Migrationsschritte: die `pub.dev`-Seite des jeweiligen Pakets (Reiter „Installing“ und „Changelog“) sowie `drift.simonbinder.eu` und `riverpod.dev`.
- `packages/unsalted_core/pubspec.yaml` enthält zu keinem Zeitpunkt eine Abhängigkeit auf `unsalted_experiments`, `unsalted_sync`, `unsalted_media`, `unsalted_social` oder `unsalted_assistant`.

**Fertig-Kriterium:** `flutter pub get` läuft in allen Paketen fehlerfrei, `git log` enthält den Grundlagen-Commit.

---

# 5 Phase 1 — Architektur *(abgeschlossen)*

Diese Phase ist abgeschlossen. Sie stellt sicher, dass jede spätere Phase automatisiert gegen die Grundregeln geprüft wird.

## 5.1 Architektur-Prüfwerkzeug

**Datei:** `tool/check_architecture.dart` Liest `architecture.yaml`, durchsucht alle `lib/`-Dateien aller Pakete, meldet jeden Import eines Pakets mit höherem Rang sowie jeden Treffer aus `forbidden_in_core`außerhalb der zulässigen Unterordner. `exitCode = 1` bei jedem Fund, sonst `0`.

## 5.2 Architekturtests

Alle Tests liegen in `packages/unsalted_core/test/architecture/` und laufen bei jedem Commit. Jeder Test hat eine feste, im Folgenden definierte Prüfregel (nicht nur ein Ziel):

| **IDTestPrüfregel** |                                     |                                                                                                                                                                                                           |
| ------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AT-01               | `no_upper_imports_test`             | Kein `import 'package:unsalted_<x>/...'` in `unsalted_core`, wobei `<x>` ein Paket mit höherem Rang laut `architecture.yaml` ist.                                                                         |
| AT-02               | `nutrition_is_pure_test`            | Keine Datei unter `lib/src/nutrition/` enthält einen Import, dessen Paketname `flutter`, `drift`, `sqlite3`oder `dart:io` ist.                                                                            |
| AT-03               | `recipe_is_pure_test`               | Dieselbe Prüfung wie AT-02 für `lib/src/recipe/` und `lib/src/food/`.                                                                                                                                     |
| AT-04               | `contracts_are_pure_test`           | Keine Datei unter `lib/src/contracts/` importiert `drift` oder `flutter/material.dart`.                                                                                                                   |
| AT-05               | `data_boundary_test`                | Kein Import von `package:drift/drift.dart` oder eines Drift-generierten Symbols außerhalb von `lib/src/data/`. Umfasst `ui/`, `nutrition/`, `recipe/`, `food/`, `contracts/`, `module/`, `providers/`.    |
| AT-06               | `public_api_test`                   | `lib/unsalted_core.dart` exportiert exakt die Menge an Symbolen, die in `test/architecture/public_api_golden.txt`aufgeführt ist (zeilenweiser Abgleich, sortiert).                                        |
| AT-07               | `no_double_test`                    | Kein Vorkommen von `double `, `.toDouble()` oder `num `in `lib/`, außer in Dateien unter `lib/src/ui/` (dort ausschließlich für Layout-Werte zulässig, niemals für Nährwert-, Mengen- oder Preisangaben). |
| AT-08               | `no_raw_todecimal_test`             | Der Text `toDecimal(` kommt in `lib/` ausschließlich in der Datei `lib/src/nutrition/decimal_math.dart`vor.                                                                                               |
| AT-09               | `no_src_import_test`                | Weder `unsalted_app` noch ein Test außerhalb von `unsalted_core` importiert einen Pfad, der `/src/`enthält.                                                                                               |
| AT-10               | `tables_have_standard_columns_test` | Jede Klasse unter `lib/src/data/tables/`, die `Table`erweitert, deklariert die Spalten `id`, `created_at`, `updated_at`, `deleted_at` und keine Spalte mit `.autoIncrement()`.                            |
| AT-11               | `no_foreign_keys_test`              | Kein Vorkommen von `.references(` in `lib/src/data/tables/`.                                                                                                                                              |
| AT-12               | `no_kj_text_test`                   | Kein Vorkommen der Zeichenfolge `"kJ"` (Groß-/Kleinschreibung exakt) in `lib/` oder `test/`.                                                                                                              |

**Fertig-Kriterium:** `dart run tool/check_architecture.dart` liefert `0`, alle zwölf Architekturtests sind grün.

---

# 6 Phase 2 — Rechenkern *(abgeschlossen)*

Diese Phase ist abgeschlossen. Ihre Verträge sind ab Kapitel 7 verbindlich referenziert und werden dort nicht erneut hergeleitet.

## 6.1 Ergebnis

Paket `unsalted_core`, Ordner `lib/src/nutrition/`, ausschließlich reines Dart (kein Flutter, kein Drift):

| **DateiInhalt**            |                                                                                                                                                                                           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `decimal_math.dart`        | `kInternalScale`, `RationalToDecimalX.toFixedDecimal`, `DecimalRationalX.r`, `rHundred`, `rZero` — die einzige Stelle mit direktem `toDecimal(...)`-Aufruf im gesamten Paket (Kapitel 7). |
| `unit_catalog.dart`        | `UnitKind`, `Unit`, `UnitCatalog` mit den neun Einheiten aus Kapitel 9 und `toGrams(...)`.                                                                                                |
| `nutrient_set.dart`        | `NutrientSet` mit den acht nullable Feldern aus Kapitel 8 sowie `extra`.                                                                                                                  |
| `nutrition_result.dart`    | `NutritionResult` mit `forAmount` und `gramsForKcal`.                                                                                                                                     |
| `nutrition_engine.dart`    | `NutritionEngine.calculate(...)`, Berechnungspipeline aus Kapitel 8.4.                                                                                                                    |
| `nutrient_validator.dart`  | `NutrientValidator.check(...)`, Regeln aus Kapitel 8.5.                                                                                                                                   |
| `nutrition_formatter.dart` | `NutritionFormatter`, einzige Rundungsstelle.                                                                                                                                             |

## 6.2 Tests (Phase-2-Abnahme)

44 Tests in `test/nutrition/`, im Einzelnen in Kapitel 23.1 aufgeführt (UT-01…UT-14, NS-01…NS-07, EN-01…EN-20, DC-01…DC-06, VA-01…VA-07, FO-01…FO-05).

**Fertig-Kriterium (erreicht):** alle 44 Tests grün, AT-02, AT-07 und AT-08 grün, `lib/src/nutrition/`importiert ausschließlich `decimal`, `rational` und — nur in `nutrition_formatter.dart` — `intl`.

---

# 7 Zahlenregel (Decimal/Rational)

Diese Regel gilt für das gesamte Projekt, alle sechs Teile.

## 7.1 Fachtyp und interner Rechentyp

- **Fachtyp** (Felder von Domain-Objekten, DB-Spalten, JSON-Werte): `Decimal` aus `package:decimal`.
- **Interner Rechentyp** (innerhalb einer Berechnungskette, z. B. in `NutritionEngine`): `Rational` aus `package:rational`. Ein Fachwert wird zu Beginn der Kette über `.toRational()` (Erweiterungsmethode `DecimalRationalX.r`, Kapitel 6.1) in `Rational` überführt und erst am Ende der Kette wieder in `Decimal`zurückverwandelt.
- Ganzzahlige, nicht-fachliche Felder (`position`, `servings`, `timerSeconds`, `versionIndex`, `formatVersion`) sind `int`.
- `double`, `num` und implizite Zahlliterale ohne Dezimalpunkt-Kontext sind für fachliche Werte verboten (AT-07). Ausnahme: reine Layout-Werte in `lib/src/ui/`.

## 7.2 API-Verhalten von `package:decimal`/`package:rational`(verbindlich für Implementierung und Tests)

| **AusdruckRückgabetypFolge für die Implementierung**          |                                                                                                                    |                                                                                              |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------- |
| `Decimal + Decimal`, `Decimal - Decimal`, `Decimal * Decimal` | `Decimal`                                                                                                          | direkt verwendbar                                                                            |
| `Decimal / Decimal`                                           | `Rational`                                                                                                         | nur innerhalb einer `Rational`-Kette verwenden                                               |
| `Decimal ~/ Decimal`                                          | `BigInt`                                                                                                           | im Rechenkern nicht verwenden                                                                |
| `Decimal.pow(int)`                                            | `Rational`                                                                                                         | im Rechenkern nicht verwenden                                                                |
| `Rational.toDecimal()` ohne `scaleOnInfinitePrecision`        | wirft `AssertionError`, wenn `hasFinitePrecision == false`                                                         | nie ohne Scale aufrufen                                                                      |
| `Rational.toDecimal(scaleOnInfinitePrecision: n)`             | `Decimal`, bei unendlicher Präzision auf `n`Nachkommastellen **gekürzt** (`truncate`, nicht kaufmännisch gerundet) | Rundungsverhalten ist bewusst „kürzen“; sichtbare Rundung entsteht separat im Formatter (R8) |

## 7.3 Zentraler Helfer

Einzige zulässige Stelle für die Rückkonvertierung `Rational → Decimal` ist `lib/src/nutrition/decimal_math.dart` (Kapitel 6.1). Jeder andere Aufruf von `toDecimal(` im Paket ist ein Verstoß gegen AT-08.

```dart
const int kInternalScale = 12;

extension RationalToDecimalX on Rational {
  Decimal toFixedDecimal([int scale = kInternalScale]) =>
      toDecimal(scaleOnInfinitePrecision: scale);
}

extension DecimalRationalX on Decimal {
  Rational get r => toRational();
}

```

`kInternalScale = 12` ist die interne Rechengenauigkeit für Zwischenschritte ohne endliche Dezimaldarstellung (z. B. `1/3`). Sie ist von der Anzeige-Rundung (Kapitel 8.6) unabhängig und wird ausschließlich in dieser Datei geändert.

## 7.4 Speicherung und Austausch

- **SQLite:** jede `Decimal`-Spalte ist `TEXT`, über `DecimalConverter` (`TypeConverter<Decimal, String>`), niemals `REAL`.
- **JSON:** jeder `Decimal`-Wert ist ein JSON-**String** (`"12.5"`), niemals eine JSON-Number (`12.5`). Diese Regel gilt für alle eingefrorenen Formate (Kapitel 13) ohne Ausnahme, auch für Werte innerhalb von `extra`.
- **Parsen:** ausschließlich `Decimal.parse(String)`. Ein `Decimal` wird niemals über den Umweg `double`erzeugt oder geparst.

## 7.5 Tests

Exakte Vergleiche sind möglich und verbindlich: `expect(result.per100g.energyKcal, Decimal.parse('350'))`, ohne Toleranzband. Ein Test, der mit `double` fehlschlagen würde (`0.1 + 0.2 == 0.3`), ist Pflichtbestandteil des Testplans (DC-05, Kapitel 23.1).

---

# 8 Nährwertsystem

## 8.1 Felder

Acht feste Felder, jedes einzeln nullable:

| **SchlüsselEinheitTypBedeutung von `null`** |      |            |           |
| ------------------------------------------- | ---- | ---------- | --------- |
| `energy_kcal`                               | kcal | `Decimal?` | unbekannt |
| `fat_g`                                     | g    | `Decimal?` | unbekannt |
| `saturated_fat_g`                           | g    | `Decimal?` | unbekannt |
| `carbs_g`                                   | g    | `Decimal?` | unbekannt |
| `sugars_g`                                  | g    | `Decimal?` | unbekannt |
| `fiber_g`                                   | g    | `Decimal?` | unbekannt |
| `protein_g`                                 | g    | `Decimal?` | unbekannt |
| `salt_g`                                    | g    | `Decimal?` | unbekannt |

`null` bedeutet „nicht bekannt“. `Decimal.zero` bedeutet „bekanntermaßen null“. Diese Unterscheidung gilt unverändert in Berechnung, Speicherung, JSON und Anzeige.

Zusätzliche Nährwerte: `extra` als `Map<String, Decimal>`, Schlüssel im Muster `<name>_<einheit>`(Beispiel: `sodium_mg`). In JSON ebenfalls String-Werte.

Es existiert kein Energiefeld außer `energy_kcal`.

## 8.2 Natrium-Eingabehilfe

Im Lebensmittel-Formular (Bildschirm 10, Kapitel 22) kann statt `salt_g` optional Natrium in mg eingegeben werden. Die Umrechnung `salt_g = sodium_mg / 1000 * 2.5` erfolgt ausschließlich beim Speichern des Formulars, innerhalb der UI-Schicht. Gespeichert wird ausschließlich `salt_g`; der Rechenkern kennt keine Natrium-Umrechnung und erhält niemals einen `sodium`-Parameter.

## 8.3 Addition und Skalierung (`NutrientSet`)

- Skalierung eines Felds mit einem Faktor: `null` bleibt `null`, ein bekannter Wert wird skaliert.
- Addition zweier `NutrientSet` je Feld: bekannt + bekannt = Summe. bekannt + unbekannt = das bekannte Ergebnis, zusätzlich wird der Feldschlüssel in `NutritionResult.incomplete` aufgenommen. unbekannt + unbekannt = `null`, ebenfalls in `incomplete`.
- `extra`: Schlüssel werden nur addiert, wenn sie in beiden Operanden vorkommen; fehlt ein Schlüssel bei einem Operanden, gilt dieselbe `incomplete`-Regel wie bei den acht festen Feldern.

## 8.4 Berechnungspipeline (`NutritionEngine`)

Eingabe je Zutat: `quantity` (`Decimal`), `unitCode` (`String`), optionale Referenz auf `FoodVariant` (Kapitel 10.6) mit `densityGPerMl`, `gramsPerPiece`, `per100g` (`NutrientSet`). Intern wird ausschließlich mit `Rational` gerechnet; Rückkonvertierung nur an den in Kapitel 7.3 genannten Ausgängen.

```text
je Zutat i:
  grams_i  = UnitCatalog.toGrams(quantity_i, unitCode_i, density?, gramsPerPiece?)   // Rational? ; null = nicht berechenbar
  set_i    = variant?.per100g.scale(grams_i / 100)                                    // fehlt variant -> set_i ist "leer" (alle Felder unbekannt)

rawWeight   = Σ grams_i über alle berechenbaren Zutaten                               // Rational
finalWeight = finalWeightOverrideG != null
                ? finalWeightOverrideG.r
                : rawWeight * (Decimal.fromInt(100) - bakingLossPercent).r / rHundred

total       = Σ set_i                                                                 // NutrientSet, Kapitel 8.3
per100g     = finalWeight > rZero ? total.scale(rHundred / finalWeight) : NutrientSet.allUnknown()
perServing  = servings != null ? total.scale(Rational.one / Rational.fromInt(servings!)) : null

forAmount(g)      = per100g.scale(g.r / rHundred)
gramsForKcal(kcal) = (per100g.energyKcal != null && per100g.energyKcal! > Decimal.zero)
                       ? (kcal.r * rHundred / per100g.energyKcal!.r).toFixedDecimal()
                       : null

```

## 8.5 Randfälle (verbindlich, keine weiteren Interpretationsspielräume)

| **FallDefiniertes Ergebnis**                                 |                                                                                                                                                                                              |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| keine Zutaten                                                | `rawWeightG = 0`, `finalWeightG = 0`, `total`/`per100g` alle Felder `null`, `perServing = null` falls `servings == null`, `hasAnyNutrition = false`, `notCalculable = []`, `incomplete = {}` |
| `quantity = 0` bei einer Zutat                               | zählt mit `0 g` zum Gewicht; die Zutat ist **nicht** in `notCalculable`, sofern die Einheit grundsätzlich umrechenbar ist                                                                    |
| `quantity < 0`                                               | wird nicht erreicht — `RecipeChange.validate()` und der UI-Formularvalidator lehnen negative Mengen vor dem Erreichen der Engine ab; die Engine selbst prüft dies nicht erneut               |
| Zutat ohne verknüpfte `FoodVariant`(`foodVariantId == null`) | zählt zum Gewicht (sofern Masse-/Volumen-/Stückangabe vorhanden), liefert aber ein „leeres“ `NutrientSet` (alle acht Felder `null`) → alle acht Feldschlüssel landen in `incomplete`         |
| fehlende Dichte bei Volumeneinheit                           | `grams_i = null` → Zutat in `notCalculable`, zählt nicht zu `rawWeight`                                                                                                                      |
| fehlendes Stückgewicht bei `piece`                           | wie oben                                                                                                                                                                                     |
| `finalWeightOverrideG`gesetzt                                | hat Vorrang; `bakingLossPercent` wird für die Berechnung ignoriert (der gespeicherte Wert bleibt unverändert, die UI zeigt ihn als „außer Kraft gesetzt“ an, Kapitel 22)                     |
| `finalWeightOverrideG = 0`                                   | wird nicht erreicht — abgelehnt durch `RecipeChange.validate()`(`SetFinalWeightOverride` verlangt `> 0` oder `null`)                                                                         |
| `bakingLossPercent = 100` und kein Override                  | `finalWeight = 0` → `per100g` alle Felder `null` (Division durch `0` wird durch die explizite Prüfung `finalWeight > rZero` verhindert); `total` bleibt unverändert erhalten                 |
| `servings = null`                                            | `perServing = null`                                                                                                                                                                          |
| `servings` gesetzt                                           | immer `>= 1` — durch `RecipeChange.validate()` erzwungen; die Engine erhält nie `0`                                                                                                          |
| alle Zutaten nicht berechenbar                               | `rawWeightG = 0`, `notCalculable` enthält alle Anzeigenamen, `total`/`per100g` alle Felder `null`                                                                                            |
| `gramsForKcal` bei `energy_kcal = null`oder `= 0`            | `null`                                                                                                                                                                                       |

Backverlust ändert ausschließlich das Gewicht (`finalWeight`), niemals die absoluten Gesamt-Nährwerte (`total`). Die Werte pro 100 g steigen dadurch an — das ist die korrekte fachliche Folge geringeren Endgewichts bei gleicher Nährstoffmenge.

Es wird zu keinem Zeitpunkt innerhalb der Berechnung gerundet. Rundung ist ausschließlich Aufgabe des Formatters (Kapitel 8.6, R8).

## 8.6 Validator und Formatter

`NutrientValidator.check(NutrientSet per100g) → List<NutrientWarning>`:

| **PrüfungArtVerhalten**                                                                 |         |                           |
| --------------------------------------------------------------------------------------- | ------- | ------------------------- |
| ein Feld `< Decimal.zero`                                                               | Fehler  | Speichern wird verhindert |
| `saturatedFatG > fatG`                                                                  | Warnung | Speichern bleibt möglich  |
| `sugarsG > carbsG`                                                                      | Warnung | Speichern bleibt möglich  |
| `fatG + carbsG + proteinG + fiberG > 100`                                               | Warnung | Speichern bleibt möglich  |
| `energyKcal` weicht um mehr als 20 % von `9·fatG + 4·carbsG + 4·proteinG + 2·fiberG` ab | Warnung | Speichern bleibt möglich  |
| alle acht Felder `null`                                                                 | Warnung | Speichern bleibt möglich  |

`NutritionFormatter` — einzige Rundungsstelle im gesamten Projekt:

| **WertFormat**                                  |                                                               |
| ----------------------------------------------- | ------------------------------------------------------------- |
| kcal                                            | ganzzahlig, mit Tausenderpunkt (`3.500 kcal`)                 |
| Gramm (allgemein)                               | eine Nachkommastelle, Komma als Dezimaltrennzeichen (`3,0 g`) |
| Salz                                            | zwei Nachkommastellen (`1,80 g`)                              |
| unbekannt (`null`)                              | `—`                                                           |
| Wert, dessen Feldschlüssel in `incomplete`steht | Wert + `*`, zugehörige Fußnote je betroffenem Feld            |

---

# 9 Einheiten

Einheiten sind eine Code-Konstante im Rechenkern (`UnitCatalog`), keine Datenbanktabelle. Der Rechenkern darf keine Datenbank kennen (AT-02); eine Tabelle würde diese Trennung verletzen. Eine neue Einheit ist ein Code-Release mit neuer Testabdeckung, kein Datenmigrationsvorgang.

**Datei:** `lib/src/nutrition/unit_catalog.dart`

| **CodeName`UnitKind`FaktorBezugsgrößeVoraussetzungUmrechnung nach GrammFehlerfall** |            |          |        |            |                             |                         |                                          |
| ----------------------------------------------------------------------------------- | ---------- | -------- | ------ | ---------- | --------------------------- | ----------------------- | ---------------------------------------- |
| `g`                                                                                 | Gramm      | `mass`   | `1`    | Gramm      | —                           | `menge * 1`             | —                                        |
| `kg`                                                                                | Kilogramm  | `mass`   | `1000` | Gramm      | —                           | `menge * 1000`          | —                                        |
| `pinch`                                                                             | Prise      | `mass`   | `0.3`  | Gramm      | —                           | `menge * 0.3`           | —                                        |
| `ml`                                                                                | Milliliter | `volume` | `1`    | Milliliter | `densityGPerMl`der Variante | `menge * 1 * dichte`    | fehlt Dichte → `null`(nicht berechenbar) |
| `l`                                                                                 | Liter      | `volume` | `1000` | Milliliter | `densityGPerMl`der Variante | `menge * 1000 * dichte` | fehlt Dichte → `null`                    |
| `tsp`                                                                               | Teelöffel  | `volume` | `5`    | Milliliter | `densityGPerMl`der Variante | `menge * 5 * dichte`    | fehlt Dichte → `null`                    |
| `tbsp`                                                                              | Esslöffel  | `volume` | `15`   | Milliliter | `densityGPerMl`der Variante | `menge * 15 * dichte`   | fehlt Dichte → `null`                    |
| `cup`                                                                               | Cup        | `volume` | `240`  | Milliliter | `densityGPerMl`der Variante | `menge * 240 * dichte`  | fehlt Dichte → `null`                    |
| `piece`                                                                             | Stück      | `count`  | —      | —          | `gramsPerPiece`der Variante | `menge * gramsPerPiece` | fehlt Stückgewicht → `null`              |

Es gibt keine Standarddichte (auch nicht für Wasser) und keinen Platzhalterwert für ein fehlendes Stückgewicht. Eine Zutat ohne die für ihre Einheit nötige Angabe ist „nicht berechenbar“ (`NutritionResult.notCalculable`) und wird nicht geschätzt.

`UnitCatalog.byCode(String code)` wirft `ArgumentError`, wenn `code` keiner der neun Einträge entspricht. `UnitCatalog.toGrams(...)` wirft `ValidationException`, wenn `quantity < Decimal.zero` (dieser Fall wird in der Praxis bereits vor Erreichen der Engine durch `RecipeChange.validate()` und die UI-Formularvalidierung ausgeschlossen, Kapitel 8.5).

Die neun Faktoren sind ab dem Freeze von Teil 1 unveränderlich (Kapitel 25), weil sie in historische Snapshots eingerechnet sind.

---

# 10 Fachmodell und Persistenzmodell

## 10.1 Grundsatz

Die Standardfelder aus Kapitel 11.1 (`id`, `created_at`, `updated_at`, `deleted_at`) sind zunächst Eigenschaften der Persistenzschicht, weil sie dort die Spalten jeder Tabelle beschreiben. Ein Standardfeld wird nur dann in ein Fachmodell aufgenommen, wenn es für den fachlichen Vertrag, die Identität, die Sortierung oder ein beobachtbares Verhalten des jeweiligen Modells erforderlich ist. Diese Aufnahme wird pro Fachmodell einzeln entschieden und in diesem Kapitel abschließend festgelegt. Es gibt danach keine abweichende Aussage an anderer Stelle im Bericht.

## 10.2 Allgemeine Entscheidung für alle Fachmodelle

- **`id`** ist in jedem Fachmodell enthalten. Ohne stabile Identität ist keine Referenzierung (Events, `RecipeChange`, UI-Navigation, Repository-Methoden) möglich.
- **`createdAt`** ist in keinem Fachmodell enthalten. Kein UI-Bildschirm zeigt einen Erstellungszeitpunkt, keine fachliche Sortierung verwendet ihn (Rezepte sortieren nach Titel, Versionen nach `versionIndex`, Zutaten/Schritte nach `position`, Lebensmittel nach Name). Die Spalte existiert ausschließlich zu Diagnose- und Sync-Zwecken und wird nur von der Persistenzschicht gelesen.
- **`updatedAt`** ist in keinem Fachmodell enthalten. Er ist ausschließlich für die Synchronisation (Teil 3) relevant, die direkt auf die Drift-Zeile zugreift (`SyncTableSpec`, Kapitel 21), nicht über das Fachmodell.
- **`deletedAt`** ist in keinem Fachmodell enthalten. Die Persistenzschicht filtert gelöschte Zeilen vor der Abbildung auf ein Fachmodell heraus (`WHERE deleted_at IS NULL`); ein gelöschtes Fachobjekt existiert für den Rest des Systems schlicht nicht. Kapitel 10.7 legt das Soft-Delete-Verhalten vollständig fest.

Diese Entscheidung gilt einheitlich für `Recipe`, `RecipeVersion`, `RecipeIngredient`, `RecipeStep` und `FoodVariant`. Eine abweichende Aufnahme eines Standardfelds wird pro Modell unten explizit begründet, sofern sie vorkommt — sie kommt nicht vor.

## 10.3 `Recipe`

| **FeldTypNullBedeutungPersistenzfeldIm FachmodellMapper** |           |      |                                                                                                              |    |                                                                                                       |                         |
| --------------------------------------------------------- | --------- | ---- | ------------------------------------------------------------------------------------------------------------ | -- | ----------------------------------------------------------------------------------------------------- | ----------------------- |
| `id`                                                      | `String`  | nein | UUID v4, Identität                                                                                           | ja | **ja**                                                                                                | 1:1                     |
| `title`                                                   | `String`  | nein | Rezepttitel, 1–200 Zeichen                                                                                   | ja | **ja**                                                                                                | 1:1                     |
| `description`                                             | `String?` | ja   | Freitext                                                                                                     | ja | **ja**                                                                                                | 1:1                     |
| `masterVersionId`                                         | `String?` | ja   | weicher Verweis auf die vom Nutzer gekürte Version; nur eine Version mit `state = snapshot` darf hier stehen | ja | **ja**                                                                                                | 1:1                     |
| `ownerId`                                                 | `String?` | ja   | `null`, solange kein Konto zugewiesen ist (Teil 3)                                                           | ja | **nicht enthalten** — reines Sync-/Persistenzfeld, kein Teil-1-Verhalten liest es über das Fachmodell | — (nur `data/`-Schicht) |
| `createdAt`                                               | —         | —    | siehe 10.2                                                                                                   | ja | nein                                                                                                  | —                       |
| `updatedAt`                                               | —         | —    | siehe 10.2                                                                                                   | ja | nein                                                                                                  | —                       |
| `deletedAt`                                               | —         | —    | siehe 10.2                                                                                                   | ja | nein                                                                                                  | —                       |

`ownerId` erfüllt zwar keinen der vier Aufnahmegründe aus 10.1 innerhalb von Teil 1 (kein Bildschirm zeigt ihn, keine Sortierung, kein Change referenziert ihn), bleibt aber aus demselben Grund wie `updatedAt`/`deletedAt`außerhalb des Fachmodells und wird ausschließlich über die Persistenzschicht (`assignOwner`, Kapitel 16.1) geschrieben.

## 10.4 `RecipeVersion`

| **FeldTypNullBedeutungPersistenzfeldIm FachmodellMapper** |                                    |      |                                                                                                                                                                |    |                                                                                                                                                                                            |                         |
| --------------------------------------------------------- | ---------------------------------- | ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| `id`                                                      | `String`                           | nein | UUID v4, Identität                                                                                                                                             | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `recipeId`                                                | `String`                           | nein | weicher Verweis auf `Recipe.id`                                                                                                                                | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `parentVersionId`                                         | `String?`                          | ja   | Herkunft; darf lokal unbekannt sein (Import/Fork)                                                                                                              | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `versionIndex`                                            | `int`                              | nein | fortlaufend pro Rezept ab `1`, vom Repository vergeben; alleinige Sortier- und Anzeigegrundlage (`„V3“ = versionIndex 3`)                                      | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `label`                                                   | `String?`                          | ja   | freier Zusatztext, rein informativ                                                                                                                             | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `state`                                                   | `VersionState`(`draft`/`snapshot`) | nein | bestimmt Schreibbarkeit und Wahrheitsquelle (Kapitel 10.8)                                                                                                     | ja | **ja**                                                                                                                                                                                     | 1:1, Enum ⇄ Text        |
| `servings`                                                | `int?`                             | ja   | `null` oder `>= 1`                                                                                                                                             | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `bakingLossPercent`                                       | `Decimal`                          | nein | `0`…`100`, Standard `0`                                                                                                                                        | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `finalWeightOverrideG`                                    | `Decimal?`                         | ja   | `> 0` oder `null`; hat Vorrang vor `bakingLossPercent`                                                                                                         | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `notes`                                                   | `String?`                          | ja   | Freitext                                                                                                                                                       | ja | **ja**                                                                                                                                                                                     | 1:1                     |
| `snapshottedAt`                                           | `DateTime?`                        | ja   | Zeitpunkt des Einfrierens; **ausdrücklich fachlich relevant** (UI zeigt „eingefroren am …“, Bildschirm 7) — deshalb aufgenommen, obwohl es ein Zeitstempel ist | ja | **ja** (Ausnahme zu 10.2, begründet)                                                                                                                                                       | 1:1                     |
| `snapshotJson`                                            | `String?`                          | ja   | Rohdaten des Snapshots                                                                                                                                         | ja | **nicht enthalten** — wird nie als Rohstring im Fachmodell gehalten, um Doppelrepräsentation zu vermeiden; Zugriff ausschließlich über `SnapshotService`als `RecipeSnapshotV1`(Kapitel 13) | — (nur `data/`-Schicht) |
| `snapshotFormatVersion`                                   | `int?`                             | ja   | Formatversion des Snapshots                                                                                                                                    | ja | **nicht enthalten**, aus demselben Grund wie `snapshotJson`                                                                                                                                | — (nur `data/`-Schicht) |
| `createdAt`                                               | —                                  | —    | siehe 10.2                                                                                                                                                     | ja | nein                                                                                                                                                                                       | —                       |
| `updatedAt`                                               | —                                  | —    | siehe 10.2                                                                                                                                                     | ja | nein                                                                                                                                                                                       | —                       |
| `deletedAt`                                               | —                                  | —    | siehe 10.2                                                                                                                                                     | ja | nein                                                                                                                                                                                       | —                       |

`snapshottedAt` ist die einzige bewusste Ausnahme von der allgemeinen Zeitstempel-Regel in 10.2: Er ist keine technische Buchhaltungsangabe, sondern eine vom Nutzer beobachtbare fachliche Tatsache („wann wurde diese Version eingefroren“).

## 10.5 `RecipeIngredient` und `RecipeStep`

| **Feld (`RecipeIngredient`)TypNullPersistenzfeldIm Fachmodell** |           |      |    |                                                                                       |
| --------------------------------------------------------------- | --------- | ---- | -- | ------------------------------------------------------------------------------------- |
| `id`                                                            | `String`  | nein | ja | **ja** (Identität für UI-Listenoperationen, Drag-Reorder)                             |
| `versionId`                                                     | `String`  | nein | ja | **ja**                                                                                |
| `position`                                                      | `int`     | nein | ja | **ja** (Sortier- und Referenzgrundlage, Kapitel 14)                                   |
| `foodVariantId`                                                 | `String?` | ja   | ja | **ja**                                                                                |
| `displayName`                                                   | `String`  | nein | ja | **ja**                                                                                |
| `quantity`                                                      | `Decimal` | nein | ja | **ja**                                                                                |
| `unitCode`                                                      | `String`  | nein | ja | **ja**                                                                                |
| `note`                                                          | `String?` | ja   | ja | **ja**                                                                                |
| `createdAt`/`updatedAt`/`deletedAt`                             | —         | —    | ja | nein (Begründung wie 10.2; siehe zusätzlich 10.7 zum Schreibverhalten dieser Tabelle) |

| **Feld (`RecipeStep`)TypNullPersistenzfeldIm Fachmodell** |          |      |    |        |
| --------------------------------------------------------- | -------- | ---- | -- | ------ |
| `id`                                                      | `String` | nein | ja | **ja** |
| `versionId`                                               | `String` | nein | ja | **ja** |
| `position`                                                | `int`    | nein | ja | **ja** |
| `instruction`                                             | `String` | nein | ja | **ja** |
| `timerSeconds`                                            | `int?`   | ja   | ja | **ja** |
| `createdAt`/`updatedAt`/`deletedAt`                       | —        | —    | ja | nein   |

## 10.6 `FoodVariant`

| **FeldTypNullPersistenzfeldIm Fachmodell** |                                           |      |                                      |                                                 |
| ------------------------------------------ | ----------------------------------------- | ---- | ------------------------------------ | ----------------------------------------------- |
| `id`                                       | `String`                                  | nein | ja                                   | **ja**                                          |
| `name`                                     | `String`                                  | nein | ja                                   | **ja**                                          |
| `brand`                                    | `String?`                                 | ja   | ja                                   | **ja**                                          |
| `barcode`                                  | `String?`                                 | ja   | ja                                   | **ja**                                          |
| `source`                                   | `FoodSource`(`custom`/`import`/`usda`)    | nein | ja                                   | **ja**                                          |
| `sourceRef`                                | `String?`                                 | ja   | ja                                   | **ja**                                          |
| `densityGPerMl`                            | `Decimal?`                                | ja   | ja                                   | **ja**                                          |
| `gramsPerPiece`                            | `Decimal?`                                | ja   | ja                                   | **ja**                                          |
| `servingSizeG`                             | `Decimal?`                                | ja   | ja                                   | **ja**                                          |
| `nutrients`                                | `NutrientSet` (die acht Felder + `extra`) | —    | ja (als acht Spalten + `extra_json`) | **ja** (als eingebettetes `NutrientSet`)        |
| `ownerId`                                  | `String?`                                 | ja   | ja                                   | **nicht enthalten**, wie `Recipe.ownerId`(10.3) |
| `createdAt`/`updatedAt`/`deletedAt`        | —                                         | —    | ja                                   | nein                                            |

## 10.7 Soft Delete und Draft-Zeilen — verbindliches Verhalten

- **`recipes.deletedAt`**: wird von `softDeleteRecipe` gesetzt. Ein Rezept mit gesetztem `deletedAt` erscheint in keinem `watchRecipes()`/`watchRecipe(id)`-Ergebnis.
- **`recipe_versions.deletedAt`**: wird von `deleteVersion` für eine einzelne Version gesetzt, oder kaskadierend für alle Versionen eines Rezepts, wenn `softDeleteRecipe` aufgerufen wird. Eine Version mit gesetztem `deletedAt` erscheint in keinem `watchVersions()`-Ergebnis und ist nicht mehr über `getVersion` erreichbar.
- **`recipe_ingredients.deletedAt` / `recipe_steps.deletedAt`**: `saveDraft` führt ein transaktionales Delta aus. Eine aktive Zeile mit derselben ID wie im neuen Draft wird aktualisiert; eine neue ID wird eingefügt; eine zuvor aktive Zeile, deren ID im neuen Draft fehlt, wird per `deleted_at = now()` weich gelöscht. Die ID bestehender Unterelemente bleibt dabei stabil.
- **Gelöschte Unterelemente**: Eine einmal vergebene und gelöschte `RecipeIngredient.id` oder `RecipeStep.id` darf nicht wiederverwendet und nicht reaktiviert werden. Ein `saveDraft`-Input mit einer bereits soft-gelöschten Unterelement-ID ist ungültig.
- **Positionen**: Nach einem erfolgreichen `saveDraft` sind die aktiven Zutaten- und Schrittpositionen innerhalb der Version jeweils lückenlos `1..n`.
- **Snapshot-Sperre**: Bei `state = snapshot` sind Zutaten- und Schrittzeilen schreibgeschützt. `saveDraft` auf eine Snapshot-Version wirft `SnapshotImmutableException`; dieselbe Sperre gilt für direkte DAO-Schreibpfade.
- **`food_variants.deletedAt`**: wird von `softDeleteVariant` gesetzt. `FoodRepository.getById` liefert für eine gelöschte Variante `null`. Eine `recipe_ingredients`-Zeile, deren `foodVariantId` auf eine gelöschte oder anderweitig nicht auflösbare Variante zeigt, wird von `NutritionEngine` wie eine Zutat ohne Variante behandelt.
- **Snapshots und Löschung**: Eine bereits eingefrorene Version ist durch die Kopie der aktuellen FoodVariant-Nährwerte in `snapshotJson` von späteren Änderungen oder Löschungen der referenzierten FoodVariants unabhängig.
- **Sichtbarkeit**: Jede lesende Repository-Methode filtert implizit `deleted_at IS NULL` auf der jeweils betroffenen Tabelle, bevor auf ein Fachmodell abgebildet wird. Es gibt keine öffentliche Methode, die gelöschte Zeilen zurückgibt.

## 10.8 Snapshot-Wahrheit

- `state = draft`: Wahrheit sind die Zeilen in `recipe_ingredients`/`recipe_steps` sowie die Felder von `RecipeVersion`. `snapshotJson`/`snapshotFormatVersion`/`snapshottedAt` sind `null`.
- `state = snapshot`: Wahrheit ist ausschließlich der über `SnapshotService` decodierte Inhalt von `snapshotJson`. Die Zeilen in `recipe_ingredients`/`recipe_steps` bleiben zu Anzeigezwecken (z. B. schnelle Listenansichten ohne Codec-Aufruf) unverändert erhalten, sind aber ab dem Einfrieren schreibgeschützt (Kapitel 12.2) und gelten nicht als Quelle für Export, Diff oder Nährwertberechnung einer Snapshot-Version. Test IT-04 (Kapitel 23.5) stellt sicher, dass beide Quellen zum Zeitpunkt des Einfrierens übereinstimmen.

## 10.9 IDs — vollständige Regel

- Alle `id`-Werte sind UUID v4, erzeugt über `Uuid().v4()` aus `package:uuid`, ausschließlich clientseitig.
- **Erzeugung**: `createRecipe` erzeugt `Recipe.id` und `RecipeVersion.id`. `createVariant` erzeugt `FoodVariant.id`. `createDraftFrom` erzeugt eine neue `RecipeVersion.id`; die kopierten Zutaten- und Schrittzeilen erhalten ebenfalls **neue** IDs (sie sind unabhängige Zeilen der neuen Version, keine Wiederverwendung der Quell-IDs). `AddIngredient`/`AddStep` erzeugen je eine neue `RecipeIngredient.id`/`RecipeStep.id`.
- **Import**: `Recipe.id` und `RecipeVersion.id` werden beim Import immer neu erzeugt, niemals aus dem JSON übernommen (Kapitel 13.6). Für `FoodVariant` gilt die Duplikaterkennung aus Kapitel 13.6: bei Treffer wird die vorhandene ID wiederverwendet, sonst eine neue erzeugt.
- **Fork**: verwendet denselben Importmechanismus wie Export/Import; es gelten dieselben ID-Regeln.
- **Draft-Kopie** (`createDraftFrom`): siehe „Erzeugung“ oben.
- **Sync** (Teil 3, hier nur referenziert): IDs werden während der Synchronisation niemals neu vergeben; die clientseitig erzeugte ID ist die dauerhafte Sync-Identität eines Datensatzes.
- **Wiederverwendung**: Eine einmal vergebene ID wird nach dem Löschen ihres Datensatzes nicht für einen neuen Datensatz wiederverwendet. UUID v4 macht eine zufällige Kollision praktisch ausgeschlossen; eine darüberhinausgehende Prüfung findet nicht statt.

## 10.10 Zeitstempel — vollständige Regel

- **Einheit**: Millisekunden seit der Unix-Epoche (`DateTime.now().toUtc().millisecondsSinceEpoch`), gespeichert als `INTEGER`-Spalte. Es wird nicht die Drift-eigene `DateTimeColumn`-Sekundendarstellung verwendet, sondern eine reine `IntColumn`, um die Einheit unabhängig von Drift-Konfigurationsänderungen eindeutig festzulegen.
- **Zeitzone**: ausschließlich UTC. Umrechnung in die Anzeigezeitzone geschieht ausschließlich in der UI-Schicht, nie in Persistenz oder Fachmodell.
- **Erzeugung von `createdAt`**: wird einmalig beim `INSERT` von der Repository-Implementierung gesetzt (nicht von einem SQL-Default).
- **Aktualisierung von `updatedAt`**: wird von der Repository-Implementierung bei **jedem** erfolgreichen Schreibvorgang auf die Zeile neu gesetzt — unabhängig davon, ob sich ein Feldwert tatsächlich geändert hat. Es findet keine Vergleichsprüfung vor dem Schreiben statt; `updatedAt` bedeutet „Zeitpunkt des letzten abgeschlossenen Schreibvorgangs“, nicht „Zeitpunkt der letzten inhaltlichen Änderung“. Eine inhaltliche No-Op-Erkennung ist nicht Aufgabe von Teil 1.
- **Sortierung bei Gleichstand**: Wo eine Sortierung nicht durch ein eigenes Ordnungsfeld eindeutig ist (Rezeptliste nach Titel, Lebensmittelliste nach Name), ist `id` (lexikografischer String-Vergleich) das feste Tie-Break-Kriterium. `versionIndex` ist pro Rezept eindeutig vom Repository vergeben und benötigt kein Tie-Break. `position` ist pro Version eindeutig und lückenlos (Kapitel 10.5) und benötigt ebenfalls kein Tie-Break.

---

# 11 Datenmodell (Datenbank)

## 11.1 Standardfelder

Jede Tabelle besitzt:

| **SpalteTypNullBedeutung** |         |      |                                |
| -------------------------- | ------- | ---- | ------------------------------ |
| `id`                       | TEXT    | nein | Primärschlüssel, UUID v4       |
| `created_at`               | INTEGER | nein | Millisekunden UTC, siehe 10.10 |
| `updated_at`               | INTEGER | nein | Millisekunden UTC, siehe 10.10 |
| `deleted_at`               | INTEGER | ja   | `null` = aktiv, siehe 10.7     |

Kein Auto-Increment, keine Fremdschlüssel. Verweise zwischen Zeilen (auch innerhalb desselben Pakets) sind reine Text-Spalten mit UUID-Inhalt.

## 11.2 `recipes`

| **SpalteTypNullBedeutungIndexSync** |      |      |                                                                      |    |    |
| ----------------------------------- | ---- | ---- | -------------------------------------------------------------------- | -- | -- |
| `title`                             | TEXT | nein | 1–200 Zeichen                                                        | ja | ja |
| `description`                       | TEXT | ja   | Freitext                                                             | —  | ja |
| `master_version_id`                 | TEXT | ja   | weicher Verweis, muss auf eine Version mit `state = snapshot` zeigen | —  | ja |
| `owner_id`                          | TEXT | ja   | `null` bis Teil 3 `assignOwner` ruft                                 | ja | ja |

## 11.3 `recipe_versions`

| **SpalteTypNullBedeutungIndexSync** |                |      |                                                |                      |    |
| ----------------------------------- | -------------- | ---- | ---------------------------------------------- | -------------------- | -- |
| `recipe_id`                         | TEXT           | nein | weicher Verweis                                | ja                   | ja |
| `parent_version_id`                 | TEXT           | ja   | Herkunft, darf lokal unbekannt sein            | —                    | ja |
| `version_index`                     | INTEGER        | nein | fortlaufend pro Rezept ab `1`                  | ja (mit `recipe_id`) | ja |
| `label`                             | TEXT           | ja   | freier Zusatztext                              | —                    | ja |
| `state`                             | TEXT           | nein | `draft` \| `snapshot`                          | ja                   | ja |
| `servings`                          | INTEGER        | ja   | `null` oder `>= 1`                             | —                    | ja |
| `baking_loss_percent`               | TEXT (Decimal) | nein | `0`…`100`, Standard `0`                        | —                    | ja |
| `final_weight_override_g`           | TEXT (Decimal) | ja   | `> 0` oder `null`                              | —                    | ja |
| `notes`                             | TEXT           | ja   | Freitext                                       | —                    | ja |
| `snapshot_json`                     | TEXT           | ja   | nur bei `state = snapshot`gesetzt              | —                    | ja |
| `snapshot_format_version`           | INTEGER        | ja   | nur bei `state = snapshot`gesetzt, aktuell `1` | —                    | ja |
| `snapshotted_at`                    | INTEGER        | ja   | nur bei `state = snapshot`gesetzt              | —                    | ja |

## 11.4 `recipe_ingredients`

| **SpalteTypNullBedeutungIndexSync** |                |      |                                              |                       |    |
| ----------------------------------- | -------------- | ---- | -------------------------------------------- | --------------------- | -- |
| `version_id`                        | TEXT           | nein | weicher Verweis                              | ja                    | ja |
| `position`                          | INTEGER        | nein | 1-basiert, lückenlos innerhalb einer Version | ja (mit `version_id`) | ja |
| `food_variant_id`                   | TEXT           | ja   | `null` = freie Zutat ohne Nährwerte          | —                     | ja |
| `display_name`                      | TEXT           | nein | angezeigter Name                             | —                     | ja |
| `quantity`                          | TEXT (Decimal) | nein | `>= 0`                                       | —                     | ja |
| `unit_code`                         | TEXT           | nein | Code aus `UnitCatalog`                       | —                     | ja |
| `note`                              | TEXT           | ja   | Freitext                                     | —                     | ja |

## 11.5 `recipe_steps`

| **SpalteTypNullBedeutungIndexSync** |         |      |                                              |                       |    |
| ----------------------------------- | ------- | ---- | -------------------------------------------- | --------------------- | -- |
| `version_id`                        | TEXT    | nein | weicher Verweis                              | ja                    | ja |
| `position`                          | INTEGER | nein | 1-basiert, lückenlos innerhalb einer Version | ja (mit `version_id`) | ja |
| `instruction`                       | TEXT    | nein | Anweisungstext                               | —                     | ja |
| `timer_seconds`                     | INTEGER | ja   | optionaler Timer                             | —                     | ja |

## 11.6 `food_variants`

| **SpalteTypNullBedeutungIndexSync** |                |                        |                                          |    |    |
| ----------------------------------- | -------------- | ---------------------- | ---------------------------------------- | -- | -- |
| `name`                              | TEXT           | nein                   | z. B. „Weizenmehl Type 550“              | ja | ja |
| `brand`                             | TEXT           | ja                     | Hersteller                               | —  | ja |
| `barcode`                           | TEXT           | ja                     | EAN, Grundlage der Duplikaterkennung     | ja | ja |
| `source`                            | TEXT           | nein                   | `custom` \| `import` \| `usda`           | —  | ja |
| `source_ref`                        | TEXT           | ja                     | Fremd-ID der Quelle                      | —  | ja |
| `owner_id`                          | TEXT           | ja                     | wie `recipes.owner_id`                   | —  | ja |
| `density_g_per_ml`                  | TEXT (Decimal) | ja                     | für Volumeneinheiten                     | —  | ja |
| `grams_per_piece`                   | TEXT (Decimal) | ja                     | für `piece`                              | —  | ja |
| `serving_size_g`                    | TEXT (Decimal) | ja                     | „Portion laut Packung“                   | —  | ja |
| `energy_kcal` … `salt_g`            | TEXT (Decimal) | ja (alle acht einzeln) | Werte pro 100 g                          | —  | ja |
| `extra_json`                        | TEXT           | nein                   | Standard `{}`, Decimal-Werte als Strings | —  | ja |

Es existieren in Teil 1 keine weiteren Tabellen. Insbesondere gibt es keine Tabelle für Einheiten (Kapitel 9) und keine separaten Tabellen für Lebensmittel-Konzepte oder -Quellen; letztere sind Spalten von `food_variants`(`source`, `source_ref`).

---

# 12 Draft-Lebenszyklus und Versionierung

## 12.1 Begriffe

- **Draft** — veränderbare Arbeitsversion (`state = draft`). Beliebig viele je Rezept.
- **Snapshot** — eingefrorene Version (`state = snapshot`). Unveränderlich für die gesamte Lebensdauer des Rezepts.
- **`parentVersionId`** — Herkunftsbeziehung. Darf auf eine lokal nicht vorhandene ID zeigen (Import, Fork).
- **`masterVersionId`** (auf `Recipe`) — die vom Nutzer gekürte beste Version. Nur eine Version mit `state = snapshot` darf hierfür gesetzt werden.
- **`versionIndex`** — fortlaufende, vom Repository vergebene Ganzzahl je Rezept, beginnend bei `1`. Alleinige Grundlage für Reihenfolge und Anzeige („V3“ = `versionIndex 3`). `label` ist rein informativer Zusatztext ohne Ordnungsfunktion.

## 12.2 Zustandsübergänge

| **ÜbergangAuslösende MethodeErgebnis** |                              |                                                                                                                                                          |
| -------------------------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| — → Draft                              | `createRecipe`               | neues Rezept, erste Version mit `versionIndex = 1`, `state = draft`                                                                                      |
| Snapshot → Draft                       | `createDraftFrom(versionId)` | neue Version, `state = draft`, `parentVersionId = versionId`, nächster freier `versionIndex`, tiefe Kopie aller Zutaten/Schritte mit neuen IDs           |
| Draft → Draft                          | `saveDraft(...)`             | dieselbe Version bleibt `state = draft`; Zutaten-/Schrittzeilen werden per Upsert-/Soft-Delete-Delta aktualisiert (Kapitel 10.7)                                                |
| Draft → Snapshot                       | `snapshotVersion(versionId)` | Kapitel 12.3                                                                                                                                             |
| Snapshot → Snapshot                    | nicht vorgesehen             | ein Snapshot kann nicht direkt in einen neuen Snapshot überführt werden; der einzige Weg ist Snapshot → Draft (`createDraftFrom`) → … → Draft → Snapshot |

Der einzige erlaubte Änderungsweg für eine eingefrorene Version ist:

```text
Snapshot --createDraftFrom--> neuer Draft --saveDraft / applyChangesAsNewDraft (mehrfach)--> --snapshotVersion--> neuer Snapshot

```

Ein Snapshot wird niemals direkt verändert. `saveDraft` auf eine Version mit `state = snapshot` wirft `SnapshotImmutableException`. Dieselbe Prüfung erfolgt zusätzlich auf DAO-Ebene für Zutaten- und Schrittzeilen, sodass eine Umgehung über einen direkten DAO-Aufruf ebenfalls fehlschlägt.

Begründung der Unveränderlichkeit: Snapshots sind Referenzpunkte für Experimente (Teil 2), veröffentlichte Rezepte (Teil 5) und KI-Vorschläge (Teil 6). Eine nachträgliche Änderung würde eine bereits bewertete, veröffentlichte oder vorgeschlagene Version rückwirkend verfälschen.

## 12.3 `snapshotVersion(versionId)` — vollständiger Ablauf

1. Version laden; `state != draft` → `IllegalStateException`.
2. Mindestens eine Zutat vorhanden; sonst `ValidationException`.
3. `NutritionEngine.calculate(...)` wird mit dem aktuellen Zeilenbestand ausgeführt.
4. `SnapshotCodec` erzeugt `RecipeSnapshotV1` aus Rezept, Version, Zutaten (inklusive einer **Kopie** der aktuellen Nährwerte jeder verknüpften Variante), Schritten und dem Berechnungsergebnis.
5. In einer Transaktion: `snapshot_json`, `snapshot_format_version = 1`, `snapshotted_at = jetzt (UTC)`, `state = snapshot` werden geschrieben. Die Zeilen in `recipe_ingredients`/`recipe_steps`bleiben unverändert bestehen (Kapitel 10.8).
6. Nach erfolgreichem Commit: Event `VersionSnapshotted`.

## 12.4 `createDraftFrom(versionId)` — vollständiger Ablauf

1. Quellversion laden (beliebiger Zustand, Draft oder Snapshot); nicht vorhanden → `NotFoundException`.
2. Neue `RecipeVersion.id` erzeugen, `versionIndex` = höchster bisheriger Wert des Rezepts + 1, `parentVersionId = versionId`, `state = draft`.
3. Bei Quelle `state = snapshot`: Zutaten und Schritte werden aus `snapshotJson` (nicht aus den ggf. abweichenden Zeilen) gelesen und mit neuen IDs für die neue Version eingefügt. Bei Quelle `state = draft`: Zutaten und Schritte werden direkt aus den vorhandenen Zeilen mit neuen IDs kopiert.
4. Alles in einer Transaktion.
5. Nach Commit: Event `RecipeUpdated` mit `versionId` der neuen Version.

## 12.5 `deleteVersion` und `softDeleteRecipe`

- `deleteVersion(versionId)`: setzt `deleted_at` der Version. Ist dies die einzige verbleibende (nicht gelöschte) Version des Rezepts, wird `IllegalStateException` geworfen — ein Rezept ohne jede Version ist kein gültiger Zustand.
- `softDeleteRecipe(recipeId)`: setzt `deleted_at` des Rezepts sowie kaskadierend `deleted_at` aller seiner (bis dahin nicht gelöschten) Versionen, in einer Transaktion. Nach Commit: Event `RecipeDeleted`.

---

# 13 Snapshot-Format

Ein einziges, handgeschriebenes Format (kein Code-Generator, weil es ein eingefrorener Vertrag ist) dient gleichzeitig als Export/Import-Datei, Fork-Vorlage (Teil 5) und Kontext für den KI-Assistenten (Teil 6).

## 13.1 Aufbau

Die folgende Darstellung ist ein strukturelles Beispiel. Die normative Schlüsselreihenfolge ist in 13.4 definiert.

```json
{
  "format": "unsalted_recipe_snapshot",
  "format_version": 1,
  "recipe": {
    "id": "8b1f…",
    "title": "Pizzateig",
    "description": null
  },
  "version": {
    "id": "c92a…",
    "parent_version_id": null,
    "version_index": 3,
    "label": "mit Vorteig",
    "servings": 10,
    "baking_loss_percent": "0",
    "final_weight_override_g": null,
    "notes": null,
    "created_at": "2026-09-19T10:00:00.000Z",
    "snapshotted_at": "2026-09-19T12:00:00.000Z"
  },
  "ingredients": [
    {
      "position": 1,
      "name": "Weizenmehl Type 550",
      "brand": null,
      "barcode": null,
      "quantity": "600",
      "unit": "g",
      "grams": "600",
      "note": null,
      "density_g_per_ml": null,
      "grams_per_piece": null,
      "per100g": {
        "energy_kcal": "343",
        "fat_g": "1.2",
        "saturated_fat_g": "0.2",
        "carbs_g": "70",
        "sugars_g": "1.5",
        "fiber_g": "3.5",
        "protein_g": "11",
        "salt_g": "0.01",
        "extra": { "sodium_mg": "4" }
      }
    }
  ],
  "steps": [
    { "position": 1, "instruction": "Alles 10 Minuten kneten.", "timer_seconds": 600 }
  ],
  "nutrition": {
    "raw_weight_g": "1000",
    "final_weight_g": "1000",
    "total":  { "energy_kcal": "3500" },
    "per100g": { "energy_kcal": "350" },
    "incomplete": ["sugars_g"],
    "not_calculable": []
  }
}

```

## 13.2 Feldtabelle

| **FeldPflicht (Schlüssel vorhanden)Darf `null`seinTyp**                                                              |    |                                                        |                                               |
| -------------------------------------------------------------------------------------------------------------------- | -- | ------------------------------------------------------ | --------------------------------------------- |
| `format`                                                                                                             | ja | nein                                                   | String, konstant `"unsalted_recipe_snapshot"` |
| `format_version`                                                                                                     | ja | nein                                                   | Integer, aktuell `1`                          |
| `recipe.id`, `recipe.title`                                                                                          | ja | nein                                                   | String                                        |
| `recipe.description`                                                                                                 | ja | ja                                                     | String?                                       |
| `version.id`, `version.version_index`, `version.created_at`                                                          | ja | nein                                                   | String / Integer / ISO-8601-String            |
| `version.parent_version_id`, `version.label`, `version.servings`, `version.final_weight_override_g`, `version.notes` | ja | ja                                                     | —                                             |
| `version.baking_loss_percent`                                                                                        | ja | nein                                                   | Decimal-String                                |
| `version.snapshotted_at`                                                                                             | ja | nein                                                   | ISO-8601-String                               |
| `ingredients`                                                                                                        | ja | nein (mindestens ein Eintrag)                          | Array                                         |
| `ingredients[].position`, `.name`, `.quantity`, `.unit`                                                              | ja | nein                                                   | —                                             |
| `ingredients[].brand`, `.barcode`, `.note`, `.density_g_per_ml`, `.grams_per_piece`                                  | ja | ja                                                     | —                                             |
| `ingredients[].grams`                                                                                                | ja | ja (= zum Zeitpunkt des Einfrierens nicht berechenbar) | Decimal-String?                               |
| `ingredients[].per100g`                                                                                              | ja | ja (= Zutat ohne verknüpfte Variante)                  | Objekt?                                       |
| jedes der acht Nährwertfelder in `per100g`                                                                           | ja | ja                                                     | Decimal-String?                               |
| `steps`                                                                                                              | ja | nein (darf leer sein)                                  | Array                                         |
| `nutrition`                                                                                                          | ja | nein                                                   | Objekt                                        |

Alle Dezimalwerte sind JSON-Strings (Kapitel 7.4), ohne Ausnahme, auch innerhalb von `extra`. `null` wird als JSON `null` kodiert, niemals als `"null"` oder `"0"`.

## 13.3 IDs im Format

`recipe.id` und `version.id` im JSON sind die IDs des **exportierenden** Geräts. Beim Import werden sie nicht übernommen (Kapitel 13.6); sie dienen ausschließlich als Referenzwert für `parent_version_id` der neu entstehenden Version.

## 13.4 Deterministische Serialisierung

`SnapshotCodec.encode` erzeugt für denselben `RecipeSnapshotV1`-Wert stets byteweise identisches JSON. In jedem JSON-Objekt werden die Schlüssel in alphabetisch aufsteigender Reihenfolge erzeugt. Die Serialisierung verwendet den regulären Dart-`JsonEncoder`/`jsonEncode`; Decimal-Werte sind JSON-Strings und Integer-Felder JSON-Numbers. Test GD-05 prüft die deterministische Rundreise.

### 13.4.1 `created_at`-Boundary

`version.created_at` ist Teil von `RecipeSnapshotV1`, obwohl `RecipeVersion.createdAt` kein Fachmodellfeld ist. `DriftSnapshotService` übernimmt den Persistenzzeitstempel `versionRow.createdAt` beim Erzeugen des Snapshot-Wertes. `SnapshotCodec` verarbeitet anschließend ausschließlich den vollständigen `RecipeSnapshotV1`-Wert und kennt keine Drift-Zeilentypen.

## 13.5 Format- und Versionsprüfung beim Import

- `format != "unsalted_recipe_snapshot"` → `ImportFormatException`.
- `format_version > 1` → `ImportVersionException` mit der Nutzermeldung „Dieses Rezept stammt aus einer neueren Version von unsalted.“
- `format_version < 1` oder fehlend → `ImportFormatException`.
- Fehlt ein Pflichtfeld (Spalte „Pflicht“ = ja in 13.2) → `ImportFormatException`.
- Ein im JSON vorhandenes, in 13.2 nicht gelistetes Feld wird auf **jeder** Ebene ignoriert, ohne Fehler und ohne Warnung.

### 13.5.1 Semantische Validierung

Zusätzlich zur strukturellen Formatprüfung werden vor dem ersten Schreibzugriff die fachlichen Constraints geprüft:

- `ingredients[].quantity >= 0`
- `ingredients[].unit` muss einem der neun Codes aus Kapitel 9 entsprechen
- `version.baking_loss_percent` liegt zwischen `0` und `100`
- `version.final_weight_override_g` ist `null` oder `> 0`
- `version.servings` ist `null` oder `>= 1`
- `ingredients[].position` und `steps[].position` sind positiv und jeweils lückenlos `1..n`

Ein semantisch ungültiger Snapshot löst `ImportFormatException` mit Klartextnachricht aus. Vor einer erfolgreichen Gesamtvalidierung darf kein Teil des Imports geschrieben werden.

## 13.6 Import — vollständiger Ablauf

1. Format- und Versionsprüfung (13.5).
2. Neue lokale UUIDs für `Recipe` und `RecipeVersion` erzeugen (Kapitel 10.9). Die neue Version erhält `parentVersionId` = `version.id` aus dem JSON, sofern die neue Version nicht bereits über ein anderes Feld einen `parentVersionId` besitzt (in Teil 1 stets der Fall: Import setzt ihn immer).
3. Die neue Version wird direkt mit `state = snapshot` angelegt; `snapshotJson` = der eingelesene, unverändert übernommene JSON-String (nicht neu generiert); `snapshotFormatVersion = 1`; `snapshottedAt` = Zeitpunkt des Imports. Ein Import erzeugt keinen Draft.
4. `versionIndex` der neuen Version = `1` (neues Rezept beginnt bei `1`).
5. Für jede Zutat mit vorhandenem `per100g`-Objekt wird eine `FoodVariant` gesucht, in dieser Reihenfolge: a. `barcode` im JSON nicht leer und eine lokale Variante mit identischem `barcode` existiert → diese Variante verknüpfen. b. sonst: `name` und `brand` (jeweils getrimmt und in Kleinschreibung normalisiert) stimmen mit einer lokalen Variante überein **und** alle acht Nährwertfelder sind identisch → diese Variante verknüpfen. c. sonst: neue `FoodVariant` mit `source = import` und neuer ID anlegen.
6. Zutaten ohne `per100g`-Objekt werden mit `foodVariantId = null` übernommen.
7. Die Zeilen für `recipe_ingredients`/`recipe_steps` der neuen Version werden zusätzlich zum `snapshotJson` angelegt (konsistent mit Kapitel 10.8: auch eine importierte Snapshot-Version hat einen Zeilenbestand für schnelle Listenansichten, der zum Importzeitpunkt exakt dem JSON entspricht).
8. Alles in einer Transaktion; jeder Fehler in einem der Schritte 1–7 verwirft die gesamte Operation, es wird nichts geschrieben.
9. Nach Commit: Event `RecipeCreated`.

Zwei Importe derselben Exportdatei erzeugen zwei unabhängige Rezepte (mit unabhängigen IDs), verwenden aber — sofern Barcode oder Name+Brand+Nährwerte übereinstimmen — dieselbe(n) `FoodVariant`-Zeile(n) (Test IT-05).

## 13.7 Export

Nur Versionen mit `state = snapshot` sind exportierbar; ein Aufruf mit einer Draft-Version wirft `IllegalStateException`. `exportVersion` liefert das gespeicherte `snapshotJson`, decodiert über `SnapshotCodec`, **unverändert** — es wird zum Exportzeitpunkt nicht neu berechnet. Damit enthält jede Exportdatei exakt den Stand, der beim Einfrieren galt, unabhängig von späteren Änderungen an verknüpften Lebensmitteln.

---

# 14 RecipeChange

Jede Änderung ist ein unveränderliches Dart-Objekt mit `toJson()`, `fromJson()` und `validate()`.

## 14.1 Vollständige Liste

| **KlasseFelder`type`-StringWirkung** |                                                                                                                                                 |                             |                                                                                |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | ------------------------------------------------------------------------------ |
| `AddIngredient`                      | `position` (int), `displayName`(String), `foodVariantId`(String?), `quantity`(Decimal), `unitCode`(String), `note`(String?)                     | `add_ingredient`            | fügt an `position` ein, verschiebt nachfolgende Positionen um `+1`             |
| `RemoveIngredient`                   | `position` (int)                                                                                                                                | `remove_ingredient`         | entfernt die Zutat an `position`, schließt die Lücke                           |
| `SetIngredientQuantity`              | `position` (int), `quantity`(Decimal), `unitCode`(String?)                                                                                      | `set_ingredient_quantity`   | ändert Menge und optional Einheit der Zutat an `position`                      |
| `ReplaceIngredient`                  | `position` (int), `displayName`(String), `foodVariantId`(String?), `quantity`(Decimal), `unitCode`(String)                                      | `replace_ingredient`        | ersetzt die Zutat an `position` vollständig                                    |
| `MoveIngredient`                     | `from` (int), `to`(int)                                                                                                                         | `move_ingredient`           | verschiebt die Zutat von `from` nach `to`, alle dazwischenliegenden rücken auf |
| `AddStep`                            | `position` (int), `instruction`(String), `timerSeconds`(int?)                                                                                   | `add_step`                  | fügt an `position` ein                                                         |
| `RemoveStep`                         | `position` (int)                                                                                                                                | `remove_step`               | entfernt an `position`                                                         |
| `SetStep`                            | `position` (int), `instruction`(String?), `timerSeconds`(int?, `Optional`-Wrapper zur Unterscheidung von „nicht ändern“ und „auf `null`setzen“) | `set_step`                  | ändert nur die angegebenen Felder                                              |
| `SetBakingLoss`                      | `percent`(Decimal, `0`–`100`)                                                                                                                   | `set_baking_loss`           | ersetzt `bakingLossPercent`                                                    |
| `SetFinalWeightOverride`             | `grams`(Decimal?, `null` löscht die Übersteuerung)                                                                                              | `set_final_weight_override` | ersetzt `finalWeightOverrideG`                                                 |
| `SetServings`                        | `servings` (int?, `null` oder `>= 1`)                                                                                                           | `set_servings`              | ersetzt `servings`                                                             |
| `SetTitle`                           | `title` (String)                                                                                                                                | `set_title`                 | wirkt auf `Recipe.title`, nicht auf die Version                                |
| `SetNotes`                           | `notes` (String?)                                                                                                                               | `set_notes`                 | ersetzt `RecipeVersion.notes`                                                  |

`SetUnit` existiert nicht als eigene Klasse; ein Einheitenwechsel ist Teil von `SetIngredientQuantity`. `SetDescription` existiert nicht als `RecipeChange`, weil sie nicht versionsbezogen ist; eine Beschreibungsänderung läuft über `RecipeRepository.updateRecipe`.

## 14.2 JSON-Form

```json
{ "type": "set_ingredient_quantity", "position": 2, "quantity": "350", "unit": "g" }

```

Numerische Payload-Felder sind Decimal-Strings (Kapitel 7.4). `RecipeChange.fromJson` wirft `UnknownChangeException`, wenn `type` keinem der 13 Werte aus 14.1 entspricht. Der `type`-String jeder Klasse ist ab dem Freeze (Kapitel 25) unveränderlich.

## 14.3 Validierung

`validate()` prüft je Klasse mindestens:

- `quantity >= 0` (`AddIngredient`, `SetIngredientQuantity`, `ReplaceIngredient`).
- `unitCode` ist ein bekannter Code aus `UnitCatalog` (Kapitel 9).
- `percent` zwischen `0` und `100` (`SetBakingLoss`).
- `grams > 0` oder `null` (`SetFinalWeightOverride`).
- `servings >= 1` oder `null` (`SetServings`).
- `title` ist 1–200 Zeichen (`SetTitle`).
- `position`/`from`/`to` sind `>= 1`.

Ein Verstoß wirft `ValidationException` mit dem Namen des verletzten Feldes im Klartext.

## 14.4 Anwendung — `applyChangesAsNewDraft(baseVersionId, changes)`

1. `createDraftFrom(baseVersionId)` (Kapitel 12.4).
2. Jede Änderung wird **sequenziell in Listenreihenfolge** angewendet: `position`, `from` und `to` einer Änderung beziehen sich stets auf den Zustand der Zutaten-/Schrittliste **unmittelbar vor** dieser Änderung, nicht auf den ursprünglichen Ausgangszustand vor der ersten Änderung. Eine aufrufende Stelle (insbesondere `RecipeDiff`, Kapitel 15.4) muss Änderungen entsprechend in einer Reihenfolge liefern, die unter dieser Regel zum gewünschten Endzustand führt.
3. Vor jeder einzelnen Änderung wird `validate()` aufgerufen; schlägt eine Validierung fehl, wird die **gesamte**Operation zurückgerollt (kein Teilergebnis wird gespeichert).
4. Nach Anwendung aller Änderungen werden die Positionen der Zutaten- und Schrittliste auf `1..n`, lückenlos, normalisiert.
5. Alles in einer Transaktion; die neue Draft-ID wird zurückgegeben.
6. Nach Commit: Event `RecipeUpdated`.

---

# 15 RecipeDiff

**Signatur:** `static List<RecipeChange> RecipeDiff.between(RecipeSnapshotV1 a, RecipeSnapshotV1 b)`

Reine Funktion: keine Datenbank, kein Flutter, kein veränderlicher Zustand. Eingabe und Ausgabe sind ausschließlich die in Kapitel 13/14 definierten Typen.

## 15.1 Zutaten-Identität

Zwei Zutaten gelten als „dieselbe Zutat“, wenn — in dieser Prüfreihenfolge — entweder ihr `barcode` (nicht leer) übereinstimmt, oder ihr normalisierter `name` (getrimmt, Kleinschreibung) übereinstimmt. Die Position wird **nicht**zur Identifikation herangezogen, damit ein reines Verschieben nicht als Entfernen+Hinzufügen erkannt wird.

## 15.2 Umgang mit doppelten Zutaten

Existieren in `a` oder `b` mehrere Zutaten mit demselben Identitätsschlüssel (z. B. „Mehl“ zweimal, für Teig und zum Bestäuben), erfolgt die Zuordnung greedy in Positions-Reihenfolge: die erste noch nicht zugeordnete Zutat mit passendem Schlüssel in `a` wird der ersten noch nicht zugeordneten Zutat mit passendem Schlüssel in `b` zugeordnet, danach die jeweils zweite, und so weiter.

## 15.3 Vergleichsregeln

| **GegenstandRegel**                                                                          |                                                                                                                                                                           |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Menge                                                                                        | exakter `Decimal`-Wertvergleich (`==`); `600` und `600.0` gelten als gleich                                                                                               |
| Einheit                                                                                      | Code-Vergleich; unterschiedlicher Code bei rechnerisch gleicher Grammzahl gilt dennoch als Änderung, weil die Einheit eine eigene fachliche Aussage trägt                 |
| Zutat nur in `a` (kein Partner in `b`gefunden)                                               | `RemoveIngredient`                                                                                                                                                        |
| Zutat nur in `b`                                                                             | `AddIngredient`                                                                                                                                                           |
| Zutat in beiden zugeordnet, gleicher Name/Barcode, andere Menge oder Einheit                 | `SetIngredientQuantity`                                                                                                                                                   |
| Zutat in beiden zugeordnet, aber `name`, `brand` oder verknüpfte Variante unterscheiden sich | `ReplaceIngredient`                                                                                                                                                       |
| Zutat in beiden zugeordnet, alle Werte gleich, aber andere Position                          | `MoveIngredient`                                                                                                                                                          |
| Schritte                                                                                     | Zuordnung über `position`; abweichender `instruction`- oder `timerSeconds`-Wert bei gleicher Anzahl → `SetStep`; mehr Schritte in `b` → `AddStep`; weniger → `RemoveStep` |
| `bakingLossPercent`, `finalWeightOverrideG`, `servings`, `recipe.title`, `version.notes`     | je ein `Set…`-Change bei Ungleichheit, sonst keiner                                                                                                                       |

## 15.4 Deterministische Ausgabereihenfolge und Anwendbarkeit

`between(a, b)` liefert die Änderungsliste in genau dieser festen Kategorienreihenfolge, damit die Liste unter der sequenziellen Anwendungsregel aus Kapitel 14.4 korrekt zum Zustand von `b` führt und für gegebene `(a, b)` reproduzierbar ist:

1. `SetTitle`, `SetNotes`, `SetBakingLoss`, `SetFinalWeightOverride`, `SetServings`(positionsunabhängig, werden zuerst angewendet).
2. `SetStep`-Änderungen in aufsteigender `position`.
3. `AddStep`/`RemoveStep`, sofern die Schrittanzahl abweicht: `RemoveStep` in absteigender `position`, danach `AddStep` in aufsteigender `position`.
4. `SetIngredientQuantity`/`ReplaceIngredient` für einander zugeordnete, positionsgleiche Zutaten, in aufsteigender `position`.
5. `RemoveIngredient` in **absteigender** `position` (damit das Entfernen einer Zutat die Positionen noch nicht verarbeiteter Einträge nicht verschiebt).
6. `AddIngredient` in **aufsteigender** `position`.
7. `MoveIngredient` zuletzt, für verbleibende reine Verschiebungen.

## 15.5 Zusammenhang mit `RecipeChange` und Anzeige

Da `RecipeDiff.between` dieselbe `RecipeChange`-Liste erzeugt, die auch `applyChangesAsNewDraft`konsumiert, ist „Vergleich anzeigen“ und „Änderungen übernehmen“ (Bildschirm 8, Kapitel 22) derselbe Datenweg: Die UI zeigt die von `between` gelieferte Liste gruppiert nach Kategorie (Zutaten/Schritte/Parameter) an; ein Klick auf „Übernehmen“ reicht exakt dieselbe Liste an `applyChangesAsNewDraft` weiter. Test IT-06 (Kapitel 23.5) prüft, dass `snapshotVersion` des Ergebnisses gegen `b` einen leeren Diff liefert (Rundreise). Dieser Test gehört bewusst zu den Integrationstests, nicht zu den reinen `RecipeDiff`-Tests in Kapitel 23.2, weil er `applyChangesAsNewDraft` und `snapshotVersion` benötigt — beides Repository-Methoden, die erst in Phase 6 existieren (Kapitel 24, Schritt 6.3), während `RecipeDiff` selbst bereits in Phase 4 fertiggestellt wird, ohne jede Datenbankabhängigkeit.

---

# 16 Öffentliche Verträge (Repositories, Services, Events, Provider)

Alle externen Contracts liegen in `lib/src/contracts/` und werden gemäß Kapitel 18 über die öffentliche Tür exportiert. Interne DAO-Contracts liegen in `lib/src/data/` und sind nicht Bestandteil der öffentlichen Tür. Eingefrorene externe Contracts sind ab dem in Kapitel 25 definierten Zeitpunkt unveränderlich.

## 16.0 Input-, Patch- und interne Datenzugriffsverträge

Die folgenden Typen sind verbindliche Contracts für Repositorys und Services und liegen in `lib/src/contracts/`. Sie importieren weder Drift noch Flutter.

### 16.0.1 `PatchField<T>`

```dart
class PatchField<T> {
  final T value;
  const PatchField(this.value);
}
```

Bei einem optionalen Patch-Feld bedeutet `null` außerhalb von `PatchField`, dass das Zielfeld unverändert bleibt. `PatchField(null)` bedeutet ausdrücklich „Zielfeld auf `null` setzen“.

### 16.0.2 `UpdateRecipeCommand`

```dart
class UpdateRecipeCommand {
  final String? title;
  final PatchField<String?>? description;

  const UpdateRecipeCommand({
    this.title,
    this.description,
  });
}
```

### 16.0.3 `NewRecipe`

```dart
class NewRecipe {
  final String title;
  final String? description;

  const NewRecipe({
    required this.title,
    this.description,
  });
}
```

### 16.0.4 `RecipeVersionDraft`

`RecipeVersionDraft` ist der vollständige Schreib-Input für einen Draft. Er enthält keine Snapshot-Felder und kein `state`.

```dart
class RecipeVersionDraft {
  final String id;
  final String recipeId;
  final String? parentVersionId;
  final int versionIndex;
  final String? label;
  final int? servings;
  final Decimal bakingLossPercent;
  final Decimal? finalWeightOverrideG;
  final String? notes;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  const RecipeVersionDraft({
    required this.id,
    required this.recipeId,
    required this.parentVersionId,
    required this.versionIndex,
    required this.label,
    required this.servings,
    required this.bakingLossPercent,
    required this.finalWeightOverrideG,
    required this.notes,
    required this.ingredients,
    required this.steps,
  });
}
```

Die Listen enthalten fachliche `RecipeIngredient`-/`RecipeStep`-Objekte inklusive stabiler `id`.

### 16.0.5 `IngredientInput`

```dart
class IngredientInput {
  final String displayName;
  final Decimal quantity;
  final String unitCode;
  final FoodVariant? variant;

  const IngredientInput({
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    required this.variant,
  });
}
```

### 16.0.6 `NewFoodVariant`

```dart
class NewFoodVariant {
  final String name;
  final String? brand;
  final String? barcode;
  final FoodSource source;
  final String? sourceRef;
  final Decimal? densityGPerMl;
  final Decimal? gramsPerPiece;
  final Decimal? servingSizeG;
  final NutrientSet nutrients;

  const NewFoodVariant({
    required this.name,
    required this.brand,
    required this.barcode,
    required this.source,
    required this.sourceRef,
    required this.densityGPerMl,
    required this.gramsPerPiece,
    required this.servingSizeG,
    required this.nutrients,
  });
}
```

### 16.0.7 Transaktionsverantwortung

Die fachliche Transaction Boundary liegt beim jeweiligen Repository. DAO-Methoden eröffnen innerhalb eines Repository-Schreibvorgangs keine unabhängige eigene Transaction Boundary.

---

## 16.1 `RecipeRepository`

| **MethodeParameterRückgabeVerhaltenFehlerfälleBetroffene TabellenTransaktionEvent** |                                      |                               |                                                                  |                                                                      |                              |                    |                      |
| ----------------------------------------------------------------------------------- | ------------------------------------ | ----------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------- | ------------------ | -------------------- |
| `watchRecipes()`                                                                    | —                                    | `Stream<List<Recipe>>`        | aktive Rezepte, sortiert nach `title`, bei Gleichstand nach `id` | —                                                                    | `recipes`                    | — (reine Abfrage)  | —                    |
| `watchRecipe(id)`                                                                   | `String`                             | `Stream<Recipe?>`             | `null`, wenn gelöscht oder unbekannt                             | —                                                                    | `recipes`                    | —                  | —                    |
| `watchVersions(recipeId)`                                                           | `String`                             | `Stream<List<RecipeVersion>>` | aktive Versionen, sortiert absteigend nach `versionIndex`        | —                                                                    | `recipe_versions`            | —                  | —                    |
| `getVersion(versionId)`                                                             | `String`                             | `Future<RecipeVersion?>`      | inklusive Zutaten und Schritte                                   | —                                                                    | 3 Tabellen                   | —                  | —                    |
| `createRecipe(NewRecipe)`                                                           | `title`, `description?`              | `Future<String>` (Rezept-ID)  | legt Rezept + ersten Draft (`versionIndex = 1`) an               | `ValidationException` bei leerem/zu langem Titel                     | `recipes`, `recipe_versions` | ja                 | `RecipeCreated`      |
| `updateRecipe(String id, UpdateRecipeCommand command)`                                          | —                                    | `Future<void>`                | ändert nur die angegebenen Felder                                | `NotFoundException`                                                  | `recipes`                    | nein (Einzelzeile) | `RecipeUpdated`      |
| `saveDraft(RecipeVersionDraft)`                                                     | volle Version inkl. Zutaten/Schritte | `Future<void>`                | ersetzt den Zeilenbestand vollständig (Kapitel 10.7)             | `SnapshotImmutableException`, `ValidationException`                  | 3 Tabellen                   | ja                 | `RecipeUpdated`      |
| `snapshotVersion(versionId)`                                                        | `String`                             | `Future<void>`                | Kapitel 12.3                                                     | `IllegalStateException`, `ValidationException`                       | `recipe_versions`            | ja                 | `VersionSnapshotted` |
| `createDraftFrom(versionId)`                                                        | `String`                             | `Future<String>`              | Kapitel 12.4                                                     | `NotFoundException`                                                  | 3 Tabellen                   | ja                 | `RecipeUpdated`      |
| `applyChangesAsNewDraft(baseVersionId, changes)`                                    | `List<RecipeChange>`                 | `Future<String>`              | Kapitel 14.4                                                     | `ValidationException`, `UnknownChangeException`, `NotFoundException` | 3 Tabellen                   | ja                 | `RecipeUpdated`      |
| `setMasterVersion(recipeId, versionId)`                                             | —                                    | `Future<void>`                | nur Versionen mit `state = snapshot`zulässig                     | `IllegalStateException`                                              | `recipes`                    | nein               | `RecipeUpdated`      |
| `deleteVersion(versionId)`                                                          | `String`                             | `Future<void>`                | Kapitel 12.5                                                     | `IllegalStateException`                                              | `recipe_versions`            | nein               | `RecipeUpdated`      |
| `softDeleteRecipe(recipeId)`                                                        | `String`                             | `Future<void>`                | Kapitel 12.5                                                     | —                                                                    | `recipes`, `recipe_versions` | ja                 | `RecipeDeleted`      |
| `assignOwner(ownerId)`                                                              | `String`                             | `Future<void>`                | setzt `owner_id` auf allen Zeilen, bei denen er `null`ist        | —                                                                    | `recipes`, `food_variants`   | ja                 | —                    |

`assignOwner` liegt in Teil 1, obwohl er erst von Teil 3 aufgerufen wird: Nur Teil 1 darf gemäß R3/R5 in seine eigenen Tabellen schreiben. Die Methode ist ohne Konto folgenlos und wird bereits in Teil 1 getestet (RP-14, Kapitel 23.4).

## 16.2 `FoodRepository`

| **MethodeRückgabeVerhaltenFehlerfälleEvent** |                             |                                                                      |                                                      |               |
| -------------------------------------------- | --------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------- | ------------- |
| `watchAll()`                                 | `Stream<List<FoodVariant>>` | aktive Varianten, sortiert nach `name`, bei Gleichstand nach `id`    | —                                                    | —             |
| `search(String query)`                       | `Stream<List<FoodVariant>>` | Teilstringsuche in `name`/`brand`, leerer Query liefert alle         | —                                                    | —             |
| `getById(String id)`                         | `Future<FoodVariant?>`      | `null` bei gelöscht/unbekannt                                        | —                                                    | —             |
| `findByBarcode(String code)`                 | `Future<FoodVariant?>`      | `null`, wenn kein Treffer                                            | —                                                    | —             |
| `createVariant(NewFoodVariant)`              | `Future<String>`            | —                                                                    | `ValidationException`(Validator-Fehler, Kapitel 8.6) | `FoodChanged` |
| `updateVariant(FoodVariant)`                 | `Future<void>`              | ändert nie vorhandene `snapshotJson`-Kopien in bestehenden Snapshots | `NotFoundException`, `ValidationException`           | `FoodChanged` |
| `softDeleteVariant(String id)`               | `Future<void>`              | Kapitel 10.7                                                         | —                                                    | `FoodChanged` |

## 16.3 `NutritionService`

```dart
abstract class NutritionService {
  /// state = draft: live aus den Zeilen berechnet.
  /// state = snapshot: aus snapshot_json decodiert (Kapitel 10.8).
  Future<NutritionResult> forVersion(String versionId);

  /// Reine Vorschau ohne Speichern, für den Editor.
  NutritionResult preview({
    required List<IngredientInput> ingredients,
    required Decimal bakingLossPercent,
    Decimal? finalWeightOverrideG,
    int? servings,
  });
}

```

`NutritionService` kennt `RecipeRepository` nicht und wird nicht von ihm referenziert; er liest über eigene DAO-Zugriffe bzw. den `SnapshotService`.

## 16.4 `SnapshotService`

```dart
abstract class SnapshotService {
  Future<RecipeSnapshotV1> exportVersion(String versionId);
  Future<String> exportVersionAsJsonString(String versionId);
  Future<String> importSnapshot(RecipeSnapshotV1 s);
  Future<String> importJsonString(String json);
}

```

Verhalten wie in Kapitel 13.6/13.7 festgelegt.

## 16.5 Domain Events

```dart
sealed class DomainEvent { final String id; final DateTime at; }

class RecipeCreated      extends DomainEvent { final String recipeId, versionId; }
class RecipeUpdated      extends DomainEvent { final String recipeId; final String? versionId; }
class VersionSnapshotted extends DomainEvent { final String recipeId, versionId; }
class RecipeDeleted      extends DomainEvent { final String recipeId; }
class FoodChanged        extends DomainEvent { final String variantId; final FoodChangeKind kind; }

```

- **Auslösung**: jede Methode aus 16.1/16.2, die in der Spalte „Event“ einen Eintrag trägt, löst **nach erfolgreichem Transaktions-Commit** genau ein Event aus — nie null, nie mehr als eines, nie vor dem Commit.
- **Rollback**: Wird die Transaktion einer Methode zurückgerollt, wird kein Event ausgelöst. Es gibt keine „Kompensations“-Events.
- **Verteilung**: `DomainEventBus.events` ist ein Broadcast-`Stream<DomainEvent>`. Beliebig viele Abonnenten sind gleichzeitig möglich, unabhängig voneinander.
- **Persistenz**: Events werden in Teil 1 **nicht** in einer Tabelle gespeichert. Sie existieren ausschließlich als In-Memory-Broadcast für die Laufzeit des App-Prozesses. Ein Abonnent, der erst nach dem Auslösen eines Events zu lauschen beginnt, sieht dieses Event nicht rückwirkend. Teil 3 darf sich für die eigentliche Synchronisation daher **nicht** ausschließlich auf den Event-Stream verlassen, sondern muss für Offline-Robustheit auf `updated_at`-Abfragen der Tabellen zurückgreifen (`SyncTableSpec`, Kapitel 21); der Event-Stream dient ausschließlich der sofortigen Reaktion lebender UI- oder Modul-Instanzen (z. B. Teil 2/6), während die App läuft.

## 16.6 Fehlerklassen

`lib/src/contracts/core_exceptions.dart`: `ValidationException`, `NotFoundException`, `SnapshotImmutableException`, `IllegalStateException`, `ImportFormatException`, `ImportVersionException`, `UnknownChangeException`. Jede Fehlerklasse trägt eine Klartextnachricht (`message`-Feld), die direkt in der UI anzeigbar ist (Kapitel 22).

## 16.7 Riverpod-Provider

Öffentlich exportiert; sie sind die einzige vorgesehene Art, Implementierungen bereitzustellen oder zu ersetzen.

```dart
final coreDatabaseProvider      = Provider<CoreDatabase>((ref) => throw UnimplementedError());
final modulesProvider           = Provider<List<UnsaltedModule>>((ref) => const []);
final recipeDaoProvider          = Provider<RecipeDao>((ref) => DriftRecipeDao(ref.watch(coreDatabaseProvider)));
final recipeRepositoryProvider  = Provider<RecipeRepository>((ref) => DriftRecipeRepository(ref.watch(recipeDaoProvider)));
final foodRepositoryProvider    = Provider<FoodRepository>((ref) => DriftFoodRepository(ref.watch(coreDatabaseProvider)));
final nutritionServiceProvider  = Provider<NutritionService>((ref) => DriftNutritionService(ref.watch(coreDatabaseProvider)));
final snapshotServiceProvider   = Provider<SnapshotService>((ref) => DriftSnapshotService(ref.watch(coreDatabaseProvider)));
final domainEventsProvider      = StreamProvider<DomainEvent>((ref) => DomainEventBus.instance.events);

```

**Default:** `coreDatabaseProvider` und `modulesProvider` werfen bzw. sind leer, solange sie nicht überschrieben wurden — ein Start ohne Override ist ein Programmierfehler und wird absichtlich nicht stillschweigend toleriert. **Override:** ausschließlich durch die App-Hülle, in `apps/unsalted_app/lib/main.dart`, über `ProviderScope(overrides: [...])` (Kapitel 21, Beispiel).**Spätere Pakete:** Teil 2–6 definieren eigene Provider in ihrer jeweils eigenen öffentlichen Tür und lesen die hier definierten Provider ausschließlich lesend über `ref.watch(...)`; sie überschreiben keinen der hier gelisteten Provider.

## 16.8 Interne DAO-Contracts

DAO-Contracts sind interne Verträge innerhalb von `unsalted_core`; sie sind keine externe Public API. Für die folgenden Signaturen bezeichnen `RecipeRow`, `RecipeVersionRow`, `RecipeIngredientRow`, `RecipeStepRow` und `FoodVariantRow` die jeweiligen Drift-generierten Zeilentypen der fünf Tabellen. `RecipesCompanion`, `RecipeVersionsCompanion`, `RecipeIngredientsCompanion` und `RecipeStepsCompanion` bezeichnen die zugehörigen Drift-Companion-Typen.

### `RecipeDao`

```dart
abstract class RecipeDao {
  Stream<List<RecipeRow>> watchRecipes();
  Stream<RecipeRow?> watchRecipe(String recipeId);
  Stream<List<RecipeVersionRow>> watchVersions(String recipeId);

  Future<RecipeRow?> getRecipe(String recipeId);
  Future<RecipeVersionRow?> getVersion(String versionId);
  Future<List<RecipeIngredientRow>> getIngredientsForVersion(String versionId);
  Future<List<RecipeStepRow>> getStepsForVersion(String versionId);

  Future<void> insertRecipe(
    RecipesCompanion recipe,
    RecipeVersionsCompanion version,
  );
  Future<void> updateRecipe(
    String recipeId,
    RecipesCompanion changes,
    int updatedAt,
  );
  Future<void> insertVersion(RecipeVersionsCompanion version);
  Future<void> updateVersion(RecipeVersionsCompanion changes);
  Future<void> updateVersionSnapshotState(
    String versionId,
    String state,
    String? snapshotJson,
    int? snapshotFormatVersion,
    int? snapshottedAt,
    int updatedAt,
  );
  Future<void> setMasterVersionId(
    String recipeId,
    String versionId,
    int updatedAt,
  );
  Future<void> softDeleteVersion(
    String versionId,
    int deletedAt,
    int updatedAt,
  );
  Future<void> saveDraftIngredients(
    String versionId,
    List<RecipeIngredientsCompanion> items,
    int nowMs,
  );
  Future<void> saveDraftSteps(
    String versionId,
    List<RecipeStepsCompanion> items,
    int nowMs,
  );
}
```

`saveDraftIngredients` und `saveDraftSteps` setzen die Delta-Regel aus Kapitel 10.7 um. Sie reaktivieren keine soft-gelöschten Unterelemente.

### `FoodDao`

```dart
abstract class FoodDao {
  Stream<List<FoodVariantRow>> watchAll();
  Stream<List<FoodVariantRow>> search(String query);
  Future<FoodVariantRow?> getById(String id);
  Future<FoodVariantRow?> findByBarcode(String barcode);
  Future<void> insertVariant(FoodVariantRow row);
  Future<void> updateVariant(FoodVariantRow row, int nowMs);
  Future<void> softDeleteVariant(String id, int deletedAt);
}
```

DAO-Methoden liefern ausschließlich Persistenztypen. Sie liefern niemals Fachmodelle.


---

# 17 Rechenkern als öffentliche Schnittstelle

Dieses Kapitel beschreibt, wie andere Schichten (Repositories, Services, UI, spätere Teile) den in Phase 2 fertiggestellten Rechenkern konsumieren; die Implementierung selbst ist in Kapitel 6 und 8 abschließend festgelegt.

- `DriftNutritionService.forVersion` liest je nach `state` entweder die aktuellen Zeilen (Draft) oder das decodierte `snapshotJson` (Snapshot, Kapitel 10.8) und ruft `NutritionEngine.calculate(...)` mit den daraus abgeleiteten `IngredientInput`-Werten auf.
- `DriftNutritionService.preview` ruft `NutritionEngine.calculate(...)` unmittelbar mit den vom Editor übergebenen, noch nicht gespeicherten Werten auf; es findet kein Datenbankzugriff statt.
- Kein Aufrufer außerhalb von `lib/src/nutrition/` führt eigene Berechnungsschritte aus; jede Nährwertberechnung im gesamten Paket läuft über `NutritionEngine.calculate(...)`.
- `NutritionResult`, `NutrientSet`, `UnitCatalog` und `NutritionFormatter` sind über die öffentliche Tür exportiert und damit die einzigen Typen, mit denen UI und spätere Teile über Nährwerte kommunizieren.

---

# 18 Datei-für-Datei-Struktur

```text
packages/unsalted_core/
├─ pubspec.yaml
├─ lib/
│  ├─ unsalted_core.dart          ÖFFENTLICHE TÜR
│  └─ src/
│     ├─ nutrition/                        (Phase 2, abgeschlossen)
│     │  ├─ decimal_math.dart
│     │  ├─ unit_catalog.dart
│     │  ├─ nutrient_set.dart
│     │  ├─ nutrition_result.dart
│     │  ├─ nutrition_engine.dart
│     │  ├─ nutrient_validator.dart
│     │  └─ nutrition_formatter.dart
│     ├─ recipe/
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
│     ├─ contracts/
│     │  ├─ input_models.dart
│     │  ├─ recipe_repository.dart
│     │  ├─ food_repository.dart
│     │  ├─ nutrition_service.dart
│     │  ├─ snapshot_service.dart
│     │  ├─ domain_events.dart
│     │  └─ core_exceptions.dart
│     ├─ data/
│     │  ├─ core_database.dart
│     │  ├─ converters/decimal_converter.dart
│     │  ├─ tables/{recipes,recipe_versions,recipe_ingredients,recipe_steps,food_variants}.dart
│     │  ├─ daos/{recipe_dao,food_dao}.dart
│     │  ├─ mappers/{recipe_mapper,version_mapper,ingredient_mapper,step_mapper,food_mapper}.dart
│     │  ├─ domain_event_bus.dart
│     │  ├─ drift_recipe_repository.dart
│     │  ├─ drift_food_repository.dart
│     │  ├─ drift_nutrition_service.dart
│     │  └─ drift_snapshot_service.dart
│     ├─ module/
│     │  ├─ unsalted_module.dart
│     │  ├─ extension_types.dart
│     │  └─ core_module.dart
│     ├─ providers/core_providers.dart
│     └─ ui/
│        ├─ recipe_list/recipe_list_screen.dart
│        ├─ recipe_editor/{recipe_create_screen,recipe_editor_screen,ingredient_row}.dart
│        ├─ recipe_detail/{recipe_detail_screen,version_switcher}.dart
│        ├─ nutrition/{nutrition_header,nutrition_table,amount_calculator}.dart
│        ├─ versions/{version_list_screen,version_compare_screen}.dart
│        ├─ foods/{food_list_screen,food_editor_screen,package_form}.dart
│        └─ settings/{settings_screen,export_screen,import_screen}.dart
├─ drift_schemas/
└─ test/{nutrition,recipe,data,contract,integration,ui,architecture}/

```

## 18.1 Dateiverträge

| **DateiZweckDarf importierenDarf nichtimportierenWichtige Klassen/MethodenTests** |                                        |                                                                       |                                                   |                                                    |                                      |
| --------------------------------------------------------------------------------- | -------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------- | -------------------------------------------------- | ------------------------------------ |
| `recipe.dart`                                                                     | Fachmodell Rezept (Kapitel 10.3)       | —                                                                     | `drift`, `flutter`                                | `Recipe`                                           | `recipe/recipe_test.dart`            |
| `recipe_version.dart`                                                             | Fachmodell Version (Kapitel 10.4)      | `decimal`                                                             | `drift`, `flutter`                                | `RecipeVersion`, `VersionState`                    | `recipe/recipe_version_test.dart`    |
| `recipe_ingredient.dart`, `recipe_step.dart`                                      | Fachmodelle (Kapitel 10.5)             | `decimal`                                                             | `drift`, `flutter`                                | `RecipeIngredient`, `RecipeStep`                   | `recipe/recipe_ingredient_test.dart` |
| `food_variant.dart`                                                               | Fachmodell Lebensmittel (Kapitel 10.6) | `decimal`, `nutrient_set`                                             | `drift`, `flutter`                                | `FoodVariant`, `FoodSource`                        | `food/food_variant_test.dart`        |
| `recipe_change.dart`                                                              | Änderungsbefehle (Kapitel 14)          | `decimal_math`                                                        | `drift`, `flutter`                                | 13 Klassen + `fromJson`/`toJson`/`validate`        | `recipe/recipe_change_test.dart`     |
| `recipe_diff.dart`                                                                | Vergleich (Kapitel 15)                 | `recipe_snapshot_v1`, `recipe_change`                                 | `drift`, `flutter`, `data/*`                      | `RecipeDiff.between`                               | `recipe/recipe_diff_test.dart`       |
| `snapshot_codec.dart`                                                             | JSON ⇄ Modell (Kapitel 13)             | `recipe_snapshot_v1`                                                  | `drift`, `flutter`                                | `SnapshotCodec.encode/decode`                      | `contract/golden_test.dart`          |
| `core_database.dart`                                                              | Drift-Datenbank                        | `drift`, `tables/*`                                                   | `ui/*`, keine eigene Implementierung der Verträge | `CoreDatabase(QueryExecutor)`, `schemaVersion = 1` | `data/migration_test.dart`           |
| `domain_event_bus.dart`                                                           | Event-Verteilung (Kapitel 16.5)        | `domain_events.dart`                                                  | `drift`, `flutter`                                | `DomainEventBus`, `events`                         | `data/event_bus_test.dart`           |
| `drift_recipe_repository.dart`                                                    | Implementierung von 16.1               | `daos/*`, `mappers/*`, `contracts/*`, `domain_event_bus.dart`         | `ui/*`, `nutrition/*`                             | 14 Methoden                                        | `data/recipe_repository_test.dart`   |
| `drift_nutrition_service.dart`                                                    | Implementierung von 16.3               | `daos/*`, `mappers/*`, `nutrition/*`, `snapshot_codec.dart`           | `ui/*`                                            | `forVersion`, `preview`                            | `data/nutrition_service_test.dart`   |
| `drift_snapshot_service.dart`                                                     | Implementierung von 16.4               | `daos/*`, `mappers/*`, `snapshot_codec.dart`, `domain_event_bus.dart` | `ui/*`                                            | `exportVersion`, `importSnapshot`                  | `data/snapshot_service_test.dart`    |
| `unsalted_core.dart`                                                              | öffentliche Tür                        | alles aus `src/`                                                      | —                                                 | nur `export`-Anweisungen                           | `architecture/public_api_test.dart`  |

**Regel für die Tür:** exportiert ausschließlich Verträge (`contracts/`), Fachmodelle (`recipe/`, `food/`), die Nährwert-Typen `NutritionResult`/`NutrientSet`/`UnitCatalog`/`NutritionFormatter`, `RecipeChange`/`RecipeDiff`/`RecipeSnapshotV1`, Fehlerklassen, die Modultypen (`module/`), `CoreModule`, die Provider (`providers/`) und `CoreDatabase`. Niemals Tabellenklassen, DAOs, Mapper oder Widgets aus `ui/`.

---

# 19 Architekturtests

Siehe Kapitel 5.2 (AT-01 bis AT-12) für die vollständige, abgeschlossene Definition. Kein weiterer Architekturtest ist für Teil 1 erforderlich.

---

# 20 Tragfähigkeit für die Teile 2–6

| **BedarfDeckung durch Teil 1Urteil**             |                                                                              |                                  |
| ------------------------------------------------ | ---------------------------------------------------------------------------- | -------------------------------- |
| Teil 2: neue Version aus Basis + eine Änderung   | `createDraftFrom`, `applyChangesAsNewDraft`, `snapshotVersion`               | gedeckt                          |
| Teil 2: eigener Block auf der Rezeptseite        | `recipeDetailSections` + `RecipeContext`(Kapitel 21)                         | gedeckt                          |
| Teil 2: Vergleich zweier Läufe                   | `RecipeDiff.between` auf zwei Snapshots                                      | gedeckt                          |
| Teil 3: Besitzer setzen                          | `assignOwner`                                                                | gedeckt                          |
| Teil 3: eigene Datenbankdatei/Executor           | `CoreDatabase(QueryExecutor)`                                                | gedeckt                          |
| Teil 3: Liste der zu synchronisierenden Tabellen | `SyncTableSpec` je Modul, `CoreModule` liefert seine fünf Tabellen           | gedeckt                          |
| Teil 3: Änderungszeitpunkte für Abgleich         | `updated_at`, `deleted_at` auf jeder Tabelle (Kapitel 10.10, 10.7)           | gedeckt                          |
| Teil 4: Anhang an beliebige Entität              | eigene Tabelle mit `target_type`/`target_id`(Text-UUID, kein Fremdschlüssel) | gedeckt, ohne Änderung an Teil 1 |
| Teil 5: veröffentlichbares Format                | `SnapshotService.exportVersion`(unveränderliches JSON)                       | gedeckt                          |
| Teil 5: Fork                                     | `importSnapshot` setzt `parentVersionId` auf die fremde ID                   | gedeckt                          |
| Teil 6: Kontext für den Assistenten              | Snapshot-JSON                                                                | gedeckt                          |
| Teil 6: Vorschlag anwenden                       | `RecipeChange` + `applyChangesAsNewDraft` + `RecipeDiff` zur Anzeige         | gedeckt                          |

## 20.1 Technischer Spike

**Fragestellung:** Tragen mehrere Drift-Datenbankklassen (eine je Paket) dieselbe zugrundeliegende Sync-Datenbankdatei, wie sie Teil 3 voraussichtlich benötigt? **Zeitpunkt:** vor dem Freeze von Teil 1, Schritt 25.1 (Phase 11). **Benötigtes Ergebnis:** ein protokollierter, lauffähiger Testaufbau in `docs/decisions.md`, der entweder bestätigt, dass mehrere `@DriftDatabase`-Klassen denselben `QueryExecutor` teilen können, oder das Gegenteil zeigt. **Auswirkung bei Scheitern:** Teil 3 setzt in der App-Hülle eine gemeinsame Datenbankklasse zusammen, die die Tabellenklassen aller Pakete auflistet. Teil 1 wird in beiden Fällen nicht verändert, da `CoreDatabase` den Executor bereits von außen erhält (Kapitel 16.7, `coreDatabaseProvider`).

Ein zweiter, bereits im laufenden Betrieb sichtbarer Punkt betrifft die Synchronisation von `recipe_ingredients`/`recipe_steps`: `saveDraft` arbeitet in Teil 1 mit stabilen Unterelement-IDs und einem Upsert-/Soft-Delete-Delta. Teil 3 definiert separat die Konfliktstrategie für konkurrierende Offline-Änderungen; aus `updated_at` und `deleted_at` wird in Teil 1 keine zeilenweise fachliche Merge-Strategie abgeleitet.

---

# 21 Modul-/Steckplatzsystem

```dart
abstract class UnsaltedModule {
  String get id;
  List<RouteBase> get routes;
  List<RecipeDetailSection> get recipeDetailSections;
  List<RecipeAction> get recipeActions;
  List<SettingsEntry> get settingsEntries;
  List<SyncTableSpec> get syncTables;
}

class RecipeContext {
  final String recipeId;
  final String versionId;
  final RecipeVersion version;
  final NutritionResult nutrition;
  final WidgetRef ref;              // Zugriff auf alle Provider aus Kapitel 16.7
}

class RecipeDetailSection {
  final String id;
  final int order;                                  // Sortierung über Module hinweg, aufsteigend
  final Widget Function(BuildContext, RecipeContext) build;
}

class RecipeAction {
  final String id;
  final int order;
  final String label;
  final IconData icon;
  final RecipeActionPlacement placement;            // appBar | menu
  final bool Function(RecipeContext)? isEnabled;
  final void Function(BuildContext, RecipeContext) onPressed;
}

class SettingsEntry {
  final String id;
  final int order;
  final String title;
  final String? subtitle;
  final void Function(BuildContext) onTap;
}

class SyncTableSpec {
  final String tableName;
  final String ownerColumn;          // z. B. 'owner_id'
  final bool immutableAfterCreate;   // true für Zeilen einer eingefrorenen Version
}

```

Die Rezeptseite (Bildschirm 4, Kapitel 22) rendert `recipeDetailSections` und `recipeActions` generisch, sortiert nach `order`, bereits ab Teil 1 — unabhängig davon, ob zur Laufzeit nur `CoreModule` registriert ist. `CoreModule` selbst liefert `id = 'core'`, seine eigenen Routen sowie die fünf `SyncTableSpec`-Einträge für `recipes`, `recipe_versions`, `recipe_ingredients`, `recipe_steps` und `food_variants`; alle vier zutatenbezogenen Tabellen tragen dort `immutableAfterCreate = true` für Zeilen, deren zugehörige Version `state = snapshot` ist.

Verdrahtung ausschließlich in `apps/unsalted_app/lib/main.dart`:

```dart
final modules = <UnsaltedModule>[CoreModule()];   // je weiterer Teil eine zusätzliche Zeile
runApp(ProviderScope(
  overrides: [
    coreDatabaseProvider.overrideWithValue(CoreDatabase(executor)),
    modulesProvider.overrideWithValue(modules),
  ],
  child: const UnsaltedApp(),
));

```

Kein anderer Ort im Projekt registriert oder verändert die Modulliste.

---

# 22 UI-Spezifikation

Gemeinsame Regeln für jeden Bildschirm: **Ladezustand** = zentrierter `CircularProgressIndicator`. **Fehlerzustand** = Klartext aus der jeweiligen Exception (Kapitel 16.6) + Button „Erneut versuchen“. **Leerer Zustand** = Symbol, ein Satz, Primäraktion. Speichern ist nur bei gültigem Formular aktiv; Abbrechen mit ungespeicherten Änderungen fragt vor Verwerfen nach. Keine Anzeige verwendet eine andere Energieeinheit als `energy_kcal` (AT-12).

| **#BildschirmRouteZweckDatenquelle / Repository-ServiceBesonderheiten** |                           |                                   |                              |                                                               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----------------------------------------------------------------------- | ------------------------- | --------------------------------- | ---------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1                                                                       | Rezeptliste               | `/`                               | Einstieg                     | `RecipeRepository.watchRecipes()`                             | Suche über Titel; leer → „Erstes Rezept anlegen“; FAB → `/recipes/new`; keine Steckplätze                                                                                                                                                                                                                                                                                                                                                                           |
| 2                                                                       | Rezept erstellen          | `/recipes/new`                    | Titel + Beschreibung         | `createRecipe`                                                | Validierung: Titel 1–200 Zeichen; nach Speichern → Editor der neuen Draft-Version                                                                                                                                                                                                                                                                                                                                                                                   |
| 3                                                                       | Rezept bearbeiten (Draft) | `/recipes/:id/versions/:vid/edit` | Zutaten, Schritte, Parameter | `getVersion`, `saveDraft`, `NutritionService.preview`         | Zutatenzeile: Name (Autocomplete über `FoodRepository.search`), Menge, Einheit-Dropdown aus `UnitCatalog`, Notiz; Drag-Reorder ändert `position`; Live-Nährwerte oben über `preview`; Button „Einfrieren“ → `snapshotVersion`; bei `state = snapshot` ist der Editor schreibgeschützt mit dem Hinweis „Eingefroren — als neuen Entwurf kopieren?“ und einer Aktion, die `createDraftFrom` aufruft                                                                   |
| 4                                                                       | Rezeptdetail              | `/recipes/:id`                    | Lesen                        | `watchRecipe`, `watchVersions`, `NutritionService.forVersion` | Versionsumschalter zeigt `„V{versionIndex}“` + optionales `label`; Zutaten, Schritte (mit Timer-Chips bei gesetztem `timerSeconds`); darunter alle `recipeDetailSections` nach `order`; AppBar/Menü rendert `recipeActions`                                                                                                                                                                                                                                         |
| 5                                                                       | Nährwertanzeige           | Teil von 4                        | Werte zeigen                 | `NutritionResult`                                             | Kopf: Fertiggewicht, Gesamt-kcal, kcal/Portion (nur wenn `servings != null`). Tabelle in EU-Reihenfolge ohne kJ: Kalorien, Fett, davon gesättigte, Kohlenhydrate, davon Zucker, Ballaststoffe, Eiweiß, Salz. Spalte 1 „pro 100 g“, Spalte 2 frei wählbar (Standard: eine Portion, falls `servings` gesetzt, sonst 100 g). `*` bei jedem Feldschlüssel in `incomplete`, mit Fußnote je betroffenem Feld; eigener Hinweisblock, sofern `notCalculable` nicht leer ist |
| 6                                                                       | Mengenrechner             | Teil von 5                        | Umrechnen                    | `NutritionResult.forAmount`, `.gramsForKcal`                  | Zwei Eingabefelder, beidseitig gekoppelt: Gramm → kcal und kcal → Gramm; Eingabe als Text, geparst mit `Decimal.parse`; ungültige Eingabe färbt das Feld, löst keine Exception aus                                                                                                                                                                                                                                                                                  |
| 7                                                                       | Versionen                 | `/recipes/:id/versions`           | Verlauf                      | `watchVersions`                                               | Liste absteigend nach `versionIndex`; Badge `Entwurf`/`Eingefroren`; Stern-Symbol markiert `masterVersionId`; Zeile zeigt `snapshottedAt`, sofern vorhanden; Aktionen: Kopie als Entwurf, Vergleichen, Löschen                                                                                                                                                                                                                                                      |
| 8                                                                       | Versionsvergleich         | `/recipes/:id/compare?a=&b=`      | Diff                         | `exportVersion` (beide Versionen) + `RecipeDiff.between`      | Zwei-Spalten-Ansicht + Änderungsliste, gruppiert nach Kategorie (Kapitel 15.4); Button „Als neuen Entwurf übernehmen“ → `applyChangesAsNewDraft` mit exakt derselben Liste                                                                                                                                                                                                                                                                                          |
| 9                                                                       | Lebensmittel-Liste        | `/foods`                          | Suchen/Verwalten             | `FoodRepository.search`                                       | Suche; leer → „Eigenes Produkt anlegen“; FAB → `/foods/new`                                                                                                                                                                                                                                                                                                                                                                                                         |
| 10                                                                      | Lebensmittel bearbeiten   | `/foods/new`, `/foods/:id`        | Verpackungsformular          | `createVariant`, `updateVariant`                              | Reihenfolge wie Bildschirm 5; optionales Natrium-Feld rechnet nach Kapitel 8.2 in `salt_g` um; Dichte, Stückgewicht, Portionsgröße; `NutrientValidator`-Warnungen inline gelb, Fehler rot; Speichern trotz Warnung möglich, nicht bei Fehler                                                                                                                                                                                                                        |
| 11                                                                      | Export                    | `/settings/export`                | JSON herausgeben             | `exportVersionAsJsonString`                                   | Auswahl beschränkt auf Versionen mit `state = snapshot`; Teilen-Dialog + „In Zwischenablage kopieren“                                                                                                                                                                                                                                                                                                                                                               |
| 12                                                                      | Import                    | `/settings/import`                | JSON einlesen                | `importJsonString`                                            | Datei wählen oder Text einfügen; Vorschau (Titel, Zutatenzahl, Gesamt-kcal) vor dem Schreiben; Fehlertexte aus `ImportFormatException`/`ImportVersionException`im Klartext                                                                                                                                                                                                                                                                                          |
| 13                                                                      | Einstellungen             | `/settings`                       | Sammelseite                  | —                                                             | Export, Import, „Über unsalted“; darunter alle `settingsEntries` nach `order`                                                                                                                                                                                                                                                                                                                                                                                       |

---

# 23 Testplan

## 23.1 Rechenkern — `test/nutrition/` (44 Tests, Phase 2)

**Einheiten:** UT-01 g · UT-02 kg · UT-03 ml mit Dichte · UT-04 ml ohne Dichte (erwartet: `null`) · UT-05 l mit Dichte · UT-06 tsp · UT-07 tbsp · UT-08 cup · UT-09 pinch · UT-10 piece mit Stückgewicht · UT-11 piece ohne Stückgewicht (erwartet: `null`) · UT-12 unbekannter Code (erwartet: `ArgumentError`) · UT-13 Menge 0 (erwartet: `0 g`, nicht `notCalculable`) · UT-14 negative Menge (erwartet: `ValidationException`)

**`NutrientSet`:** NS-01 Skalierung bekannt · NS-02 Skalierung `null` bleibt `null` · NS-03 Addition bekannt+bekannt · NS-04 bekannt+unbekannt (erwartet: Wert + `incomplete`) · NS-05 unbekannt+unbekannt (erwartet: `null` + `incomplete`) · NS-06 `extra`-Schlüssel addieren · NS-07 `extra`-Schlüssel nur einseitig (erwartet: `incomplete`)

**Engine:** EN-01 keine Zutat · EN-02 eine Zutat · EN-03 mehrere Zutaten · EN-04 Zutat ohne Nährwerte · EN-05 teilweise unbekannte Nährwerte · EN-06 Zutat ohne verknüpfte Variante · EN-07 Backverlust 0 % · EN-08 Backverlust 12,5 % · EN-09 Backverlust 100 % (erwartet: `per100g` alle `null`) · EN-10 `finalWeightOverride`gesetzt (erwartet: Backverlust ignoriert) · EN-11 `finalWeightOverride = 0` (erwartet: nicht erreichbar, `ValidationException` bereits in `RecipeChange.validate()`) · EN-12 `servings = null` (erwartet: `perServing = null`) · EN-13 `servings = 1` · EN-14 `servings = 10` · EN-15 Gramm → kcal · EN-16 kcal → Gramm · EN-17 `gramsForKcal` bei `energyKcal = null` (erwartet: `null`) · EN-18 `gramsForKcal` bei `energyKcal = 0` (erwartet: `null`) · EN-19 Salz wird ungerundet gespeichert · EN-20 alle Zutaten `notCalculable`

**Decimal:** DC-01 `1/3` durchläuft die Pipeline ohne Wurf · DC-02 sehr kleiner Wert `0.000000001` bleibt erhalten · DC-03 sehr großer Wert `999999999999.99` · DC-04 exakter Vergleich ohne Toleranz · DC-05 `0.1 + 0.2 == 0.3` (Gegenbeispiel zu `double`) · DC-06 Roundtrip `Decimal → String → Decimal`

**Validator:** VA-01 negativer Wert (erwartet: Fehler) · VA-02 gesättigte > Fett (Warnung) · VA-03 Zucker > KH (Warnung) · VA-04 Summe > 100 g (Warnung) · VA-05 kcal-Abweichung > 20 % (Warnung) · VA-06 alle Felder `null` (Warnung) · VA-07 plausibles Produkt (keine Warnung)

**Formatter:** FO-01 kcal ganzzahlig mit Tausenderpunkt · FO-02 Gramm eine Nachkommastelle · FO-03 Salz zwei Nachkommastellen · FO-04 `null` → `—` · FO-05 `incomplete` erzeugt `*`

## 23.2 Fachmodelle und `RecipeChange`/`RecipeDiff` — `test/recipe/`

RC-01…RC-13: je ein Roundtrip `toJson`/`fromJson` pro `RecipeChange`-Klasse · RC-14 unbekannter `type`(erwartet: `UnknownChangeException`) · RC-15 `quantity` als JSON-String, nicht als Zahl · RC-16 `validate()` lehnt negative Menge ab · RC-17 `validate()` lehnt `servings = 0` ab · RC-18 `validate()`lehnt Backverlust `> 100` ab

DF-01 identische Snapshots → leere Liste · DF-02 Menge geändert · DF-03 Einheit geändert bei gleicher Grammzahl → dennoch Änderung · DF-04 Zutat hinzugefügt · DF-05 Zutat entfernt · DF-06 Zutat ersetzt · DF-07 nur verschoben → `MoveIngredient` · DF-08 Schritt geändert · DF-09 Backverlust geändert · DF-10 Portionen geändert · DF-12 doppelte Zutaten in `a` und `b` werden positionsweise zugeordnet (Kapitel 15.2) · DF-13 Remove + Move berechnet `from`/`to` auf der virtuellen Liste

Es gibt bewusst kein „DF-11": das dort ursprünglich vorgesehene Rundreise-Szenario (`between(a,b)` → `applyChangesAsNewDraft` → `snapshotVersion` → `between(ergebnis, b)` ist leer) benötigt `applyChangesAsNewDraft` und `snapshotVersion` — beides Repository-Methoden aus Phase 6. Es ist identisch mit IT-06 (Kapitel 23.5) und wird ausschließlich dort geführt, nicht zusätzlich hier.

## 23.3 Snapshot-Format — `test/contract/`

GD-01 Golden-Datei minimal (1 Zutat, 0 Schritte) · GD-02 Golden-Datei voll (alle Felder gesetzt) · GD-03 Golden-Datei mit `null`-Nährwerten · GD-04 Golden-Datei mit `extra` · GD-05 Decodieren + erneutes Encodieren ergibt byteweise identisches JSON · GD-06 unbekanntes Feld wird ignoriert · GD-07 `format_version: 2` → `ImportVersionException` · GD-08 falsches `format` → `ImportFormatException` · GD-09 fehlendes Pflichtfeld → `ImportFormatException` · GD-10 kein Decimal-Fachwert im JSON ist eine JSON-Number; Integer-Felder dürfen JSON-Numbers sein (Textscan) · GD-11 semantisch ungültige Snapshot-Daten werden vor dem Schreiben abgelehnt · GD-12 unbekannte Felder bleiben im gespeicherten Original-JSON für den String-Export erhalten

## 23.4 Daten — `test/data/`

RP-01 `createRecipe` legt Rezept + Draft mit `versionIndex = 1` an · RP-02 `saveDraft` führt das definierte Upsert-/Soft-Delete-Delta transaktional aus · RP-03 `saveDraft` auf Snapshot → `SnapshotImmutableException` · RP-04 `snapshotVersion` setzt `state`, `snapshotJson`, `snapshottedAt` · RP-05 `snapshotVersion` auf Snapshot → `IllegalStateException` · RP-06 `snapshotVersion` ohne Zutaten → `ValidationException` · RP-07 `createDraftFrom` kopiert tief mit neuen IDs und setzt `parentVersionId` · RP-08 `createDraftFrom` vergibt nächsten freien `versionIndex` · RP-09 `applyChangesAsNewDraft` wendet mehrere Änderungen sequenziell an · RP-10 Fehler mitten in der Änderungsliste → nichts wird geschrieben · RP-11 `setMasterVersion` auf Draft → Fehler · RP-12 `softDeleteRecipe` kaskadiert auf alle Versionen · RP-13 `deleteVersion` der letzten verbleibenden Version → Fehler · RP-14 `assignOwner` setzt ausschließlich `null`-Besitzer · RP-15 `updatedAt`wird bei jedem Schreibvorgang neu gesetzt, auch ohne Wertänderung · RP-16 gelöschte Zeilen erscheinen in keinem `watch`-Ergebnis · RP-17 jedes dokumentierte Event wird pro erfolgreichem Aufruf genau einmal ausgelöst, kein Event bei Rollback · RP-18 Löschen der Master-Version wird abgelehnt · RP-19 `setMasterVersion` mit fremder/gelöschter/Draft-Version wird abgelehnt · RP-20 `updateRecipe` unterscheidet Nicht-Ändern und explizites `null` über `PatchField` · RP-21 fehlende aktive Draft-Unterzeilen werden weich gelöscht und IDs nicht wiederverwendet · RP-18 Löschen der Master-Version wird abgelehnt · RP-19 `setMasterVersion` mit fremder/gelöschter/Draft-Version wird abgelehnt · RP-20 `updateRecipe` unterscheidet Nicht-Ändern und explizites `null` über `PatchField` · RP-21 fehlende aktive Draft-Unterzeilen werden weich gelöscht und IDs nicht wiederverwendet

FD-01 `createVariant` · FD-02 `updateVariant` ändert bestehende Snapshots nicht · FD-03 Duplikaterkennung per Barcode beim Import (siehe auch IT-05) · FD-04 `softDeleteVariant`, danach `getById` liefert `null` · FD-05 Validator-Fehler blockiert Speichern

MG-01 Schema-Dump v1 existiert in `drift_schemas/` · MG-02 Migrationstest v1 → v1 (Leerlauf) · MG-03 `CoreDatabase` startet mit übergebenem `QueryExecutor` · MG-04 Decimal-Roundtrip durch SQLite (TEXT) exakt · MG-05 keine Spalte ist `REAL`

## 23.5 Integration — `test/integration/`

IT-01 Rezept anlegen → Zutaten → einfrieren → exportieren → importieren → Nährwerte identisch IT-02 historische Stabilität: Snapshot erstellen → verknüpftes Lebensmittel ändern → Snapshot-Nährwerte unverändert IT-03 Fork-Simulation: Export von Gerät A, Import ohne die zugehörigen Varianten → Varianten werden mit `source = import` neu angelegt, Nährwerte stimmen mit dem Original überein IT-04 Snapshot-Wahrheit: zum Zeitpunkt des Einfrierens liefern Zeilen und `snapshotJson` dasselbe Berechnungsergebnis IT-05 Import desselben JSON zweimal → zwei unabhängige Rezepte, aber (bei Barcode- oder Name+Brand+Nährwert-Treffer) nur ein Satz Lebensmittel-Varianten IT-06 `RecipeDiff` zweier Snapshots → `applyChangesAsNewDraft` → `snapshotVersion` → Diff gegen die Zielversion ist leer

## 23.6 UI — `test/ui/`

UI-01 Rezeptliste zeigt den leeren Zustand · UI-02 Liste zeigt vorhandene Rezepte · UI-03 Editor speichert und zeigt Live-Nährwerte · UI-04 Editor verweigert Bearbeiten einer Snapshot-Version · UI-05 Nährwerttabelle enthält an keiner Stelle den Text „kJ“ · UI-06 Mengenrechner rechnet in beide Richtungen · UI-07 `*` erscheint bei Feldern in `incomplete` · UI-08 Vergleichsbildschirm zeigt die gruppierte Änderungsliste · UI-09 Lebensmittel-Formular zeigt eine Validator-Warnung · UI-10 Import zeigt den Fehlertext bei ungültigem JSON

EX-01 ein Test-Modul mit einer `RecipeDetailSection` erscheint auf der Rezeptseite · EX-02 eine `RecipeAction` erscheint in der AppBar · EX-03 ein `SettingsEntry` erscheint in den Einstellungen · EX-04 die Reihenfolge über `order` stimmt über mehrere Module hinweg · EX-05 ohne registrierte Module bleibt die Seite funktionsfähig

---

# 24 Entwicklungsplan und Arbeitskarten

Phase 0 bis Phase 5 sind abgeschlossen. Der nächste nicht abgeschlossene Entwicklungsschritt ist 6.1. Die globalen technischen Verträge bleiben in Ebene 1 autoritativ; die folgenden Arbeitskarten sind deren ausführbare Arbeitsansicht.

## 24.1 Arbeitskartenstandard

Jeder nicht abgeschlossene Entwicklungsschritt wird exakt nach diesem Schema ausgeführt:

1. **ZIEL** — exakte technische Aufgabe.
2. **VORBEDINGUNGEN** — ausschließlich notwendige abgeschlossene Schritte und Zustände.
3. **BESTEHENDER PROJEKTZUSTAND** — garantierter Bestand bei Start.
4. **VERBINDLICHE CONTRACTS** — vollständige Signaturen oder eindeutige Referenz auf globale Contracts.
5. **BENÖTIGTE TYPEN UND DATEIEN** — alle benötigten Typen und relevanten Dateien.
6. **ERLAUBTER DATEISCOPE** — getrennt nach Erstellen, Ändern und Lesen, aber nicht ändern.
7. **VERBOTENE ÄNDERUNGEN** — explizite No-Go-Regeln.
8. **IMPLEMENTIERUNG** — deterministische technische Anforderungen.
9. **TRANSVERSALE REGELN** — relevante globale Regeln.
10. **TESTS** — Test-ID und nachzuweisendes Verhalten.
11. **FERTIG-KRITERIEN** — objektiv prüfbare Bedingungen.
12. **STOP-BEDINGUNG** — nach Erfüllung keine weiteren Änderungen.
13. **OUTPUT CONTRACT** — Zustand für nachfolgende Schritte.
14. **NICHT TEIL DIESES SCHRITTES** — explizite Abgrenzung.

**Read Broad, Write Narrow:** Bestehende Dateien dürfen gelesen werden, Änderungen erfolgen ausschließlich im Schreib-Scope der aktuellen Arbeitskarte.

## 24.2 Abgeschlossene Phasen

### Phase 0 — Projektgrundlage — abgeschlossen
Siehe Kapitel 4.

### Phase 1 — Architektur — abgeschlossen
Siehe Kapitel 5.

### Phase 2 — Rechenkern — abgeschlossen
Siehe Kapitel 6.

### Phase 3 — Fachmodelle — abgeschlossen
Schritte 3.1–3.3 gemäß den globalen Kapiteln für Fachmodelle, RecipeChange und Fehlerklassen.

### Phase 4 — Snapshot-Format — abgeschlossen
Schritte 4.1–4.3 gemäß den globalen Kapiteln für Snapshot-Format, Codec und Diff.

### Phase 5 — Drift-Datenbank — abgeschlossen
Schritte 5.1–5.5 gemäß Kapitel 11 und 16.8. Das Datenbankschema v1 ist seit Schritt 5.4 eingefroren.

## 24.3 Phase 6 — Repositories und Services

### STEP 6.1 — Verträge und Input-Modelle

**1. ZIEL**  
Definition aller abstrakten Repository-, Service- und Event-Verträge sowie der Input-/Patch-Typen aus Kapitel 16.0.

**2. VORBEDINGUNGEN**  
Phase 5 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Fachmodelle, Snapshot-Modell, `RecipeChange`, `RecipeDiff`, Drift-Tabellen, `CoreDatabase`, DAOs und Mapper sind vorhanden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.0 bis 16.8. Diese Contracts sind die einzige fachliche Grundlage für die Implementierungen der Phase 6.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`Recipe`, `RecipeVersion`, `RecipeIngredient`, `RecipeStep`, `FoodVariant`, `NutrientSet`, `NutritionResult`, `RecipeSnapshotV1`, `RecipeChange`, Fehlerklassen, Input-/Patch-Typen.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `lib/src/contracts/input_models.dart`, `recipe_repository.dart`, `food_repository.dart`, `nutrition_service.dart`, `snapshot_service.dart`, `domain_events.dart`; zugehörige Contract-Tests, sofern im bestehenden Testplan genannt.  
**Ändern:** keine bestehenden Fachmodelle, DAOs oder Provider.  
**Lesen, aber nicht ändern:** alle referenzierten Fachmodelle und globalen Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Drift-Implementierung, keine Provider-Verdrahtung, keine Änderung eingefrorener Phase-5-Verträge.

**8. IMPLEMENTIERUNG**  
Implementiere `PatchField`, `UpdateRecipeCommand`, `NewRecipe`, `RecipeVersionDraft`, `IngredientInput`, `NewFoodVariant` sowie die vollständigen abstrakten Contracts aus Kapitel 16.1–16.5. `RecipeVersionDraft` ist ein eigener Write-Input und nicht durch `RecipeVersion` zu ersetzen.

**9. TRANSVERSALE REGELN**  
`contracts/` importiert weder Drift noch Flutter.

**10. TESTS**  
Compile-Prüfung und AT-04. Öffentliche Signaturen werden gegen Kapitel 16 abgeglichen.

**11. FERTIG-KRITERIEN**  
Alle Contracts und Input-Typen kompilieren. Jede referenzierte Signatur ist vollständig vorhanden.

**12. STOP-BEDINGUNG**  
Nach erfolgreicher Compile- und Architekturprüfung keine Implementierungen hinzufügen.

**13. OUTPUT CONTRACT**  
Die vollständigen Contracts sind für 6.2–6.6 verfügbar. Die Signaturen sind ab diesem Schritt eingefroren.

**14. NICHT TEIL DIESES SCHRITTES**  
Repository-Implementierungen, Provider, UI.

### STEP 6.2 — DomainEventBus

**1. ZIEL**  
In-Memory-Verteilung der Domain Events.

**2. VORBEDINGUNGEN**  
6.1 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
`DomainEvent` und Eventtypen aus Kapitel 16.5 existieren.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.5.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`lib/src/data/domain_event_bus.dart`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `lib/src/data/domain_event_bus.dart`, zugehöriger Test.  
**Ändern:** keine anderen Dateien.  
**Lesen, aber nicht ändern:** `contracts/domain_events.dart`.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Event-Persistenz.

**8. IMPLEMENTIERUNG**  
Broadcast-`StreamController<DomainEvent>`, `add(...)`, `events`; Events sind erst nach erfolgreichem Commit sichtbar.

**9. TRANSVERSALE REGELN**  
Keine UI-Abhängigkeit und keine Datenbankpersistenz der Events.

**10. TESTS**  
RP-17.

**11. FERTIG-KRITERIEN**  
Broadcast-Verhalten ist geprüft.

**12. STOP-BEDINGUNG**  
Nach grünem Test.

**13. OUTPUT CONTRACT**  
`DomainEventBus.instance.events` ist für die nachfolgenden Implementierungen verfügbar.

**14. NICHT TEIL DIESES SCHRITTES**  
Repositorys, Provider, UI.

### STEP 6.3 — DriftRecipeRepository

**1. ZIEL**  
Vollständige Implementierung von `RecipeRepository`.

**2. VORBEDINGUNGEN**  
5.5, 6.1 und 6.2 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
DAOs/Mapper aus Phase 5 und die eingefrorenen Contracts aus 6.1 sind vorhanden.

**4. VERBINDLICHE CONTRACTS**  
`RecipeRepository` Kapitel 16.1, `RecipeDao` Kapitel 16.8, `RecipeVersionDraft`, `UpdateRecipeCommand`, `RecipeChange`, Fehlerklassen sowie Kapitel 10 und 12.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`lib/src/data/drift_recipe_repository.dart` und Repository-Test.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `lib/src/data/drift_recipe_repository.dart`, passender Test.  
**Ändern:** keine DAO-, Provider-, Fachmodell- oder UI-Dateien.  
**Lesen, aber nicht ändern:** alle in den Contracts referenzierten Dateien.

**7. VERBOTENE ÄNDERUNGEN**  
Kein `coreDatabaseProvider`-Import. Keine Riverpod-Abhängigkeit. Keine Provider-Registrierung.

**8. IMPLEMENTIERUNG**  
Konstruktor-Injektion der DAO-Abhängigkeit. Das Repository besitzt die Transaction Boundary. `saveDraft` verwendet das Delta aus Kapitel 10.7. `setMasterVersion` prüft Existenz, Aktivität, Rezeptzugehörigkeit und Snapshot-Status. `deleteVersion` verweigert Master-Version und letzte aktive Version. `applyChangesAsNewDraft` validiert sequenziell und rollt bei Fehlern vollständig zurück. Events erst nach Commit.

**9. TRANSVERSALE REGELN**  
Repository-Pflicht, Snapshot-Immutability, Decimal-Regel und bestehende Architekturtests.

**10. TESTS**  
RP-01 bis RP-21.

**11. FERTIG-KRITERIEN**  
Alle Methoden aus Kapitel 16.1 sind vollständig implementiert. Alle Tests grün.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem Test keine Provider- oder UI-Arbeiten.

**13. OUTPUT CONTRACT**  
Das Repository ist als Blackbox über `RecipeRepository` verwendbar. Provider-Verdrahtung erfolgt später.

**14. NICHT TEIL DIESES SCHRITTES**  
FoodRepository, NutritionService, SnapshotService, Provider, UI.

### STEP 6.4 — DriftFoodRepository

**1. ZIEL**  
Vollständige Implementierung von `FoodRepository`.

**2. VORBEDINGUNGEN**  
5.5, 6.1 und 6.2.

**3. BESTEHENDER PROJEKTZUSTAND**  
`FoodDao`, Mapper und `FoodRepository`-Contract sind vorhanden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.2, 16.0.6, 16.8 sowie Kapitel 8 und 10.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`lib/src/data/drift_food_repository.dart`, Testdatei.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** Repository und Tests.  
**Ändern:** keine DAO- oder Provider-Dateien.  
**Lesen, aber nicht ändern:** Food-Contracts, Mapper und Tabellen.

**7. VERBOTENE ÄNDERUNGEN**  
Keine nachträgliche Änderung bestehender Snapshot-Kopien.

**8. IMPLEMENTIERUNG**  
Watch, Search, Get, Barcode-Suche, Create, Update und Soft Delete gemäß Kapitel 16.2.

**9. TRANSVERSALE REGELN**  
Validator- und Decimal-Regeln.

**10. TESTS**  
FD-01 bis FD-05.

**11. FERTIG-KRITERIEN**  
Alle Tests grün.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem Test keine Zusatzfunktionen.

**13. OUTPUT CONTRACT**  
`DriftFoodRepository` implementiert seinen Contract vollständig.

**14. NICHT TEIL DIESES SCHRITTES**  
Snapshot-Service und UI.

### STEP 6.5 — DriftNutritionService

**1. ZIEL**  
Implementierung von `NutritionService`.

**2. VORBEDINGUNGEN**  
6.3 und Phase 2.

**3. BESTEHENDER PROJEKTZUSTAND**  
Nutrition Engine, Nutrition-Typen und Snapshot-Codec sind vorhanden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.3, `IngredientInput`, Kapitel 10.8 und Kapitel 17.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`lib/src/data/drift_nutrition_service.dart`, Testdatei.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** Service und Test.  
**Ändern:** keine Nutrition-Core- oder UI-Dateien.  
**Lesen, aber nicht ändern:** Nutrition- und Snapshot-Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Keine eigene Nährwertberechnung außerhalb `NutritionEngine`.

**8. IMPLEMENTIERUNG**  
Draft → aktive Datenbankzeilen. Snapshot → ausschließlich `snapshotJson`. `preview` → keine Datenbankabfrage.

**9. TRANSVERSALE REGELN**  
Rundung nur im Formatter.

**10. TESTS**  
Draft/Snapshot-Fallunterscheidung, IT-02, IT-04.

**11. FERTIG-KRITERIEN**  
Tests grün.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem Test.

**13. OUTPUT CONTRACT**  
Der Service liefert für Draft und Snapshot die definierte fachliche Nährwertquelle.

**14. NICHT TEIL DIESES SCHRITTES**  
UI, Provider.

### STEP 6.6 — DriftSnapshotService

**1. ZIEL**  
Implementierung von Export und Import nach Kapitel 13.

**2. VORBEDINGUNGEN**  
4.x, 6.3 und 6.4 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Snapshot-Format und Food-/Recipe-Contracts stehen.

**4. VERBINDLICHE CONTRACTS**  
`SnapshotService`, `RecipeSnapshotV1`, `SnapshotCodec`, Kapitel 13.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`lib/src/data/drift_snapshot_service.dart`, Testdatei.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** Service und Tests.  
**Ändern:** keine Snapshot- oder Domain-Contracts.  
**Lesen, aber nicht ändern:** Import-/Export- und Food-Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Kein Neuentwurf des Snapshot-Formats.

**8. IMPLEMENTIERUNG**  
Strukturelle und semantische Validierung vor dem ersten Schreibzugriff. Import speichert den Original-JSON-String. Export nutzt die gespeicherte Snapshot-Wahrheit. FoodVariant-Duplikaterkennung gemäß Kapitel 13.6. Ganze Operation transaktional.

**9. TRANSVERSALE REGELN**  
Unbekannte Felder werden für die typisierte Dekodierung ignoriert; der gespeicherte Original-String bleibt für `exportVersionAsJsonString` erhalten.

**10. TESTS**  
IT-01, IT-03, IT-05, GD-11, GD-12.

**11. FERTIG-KRITERIEN**  
Import/Export und historische Stabilität bestätigt.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem Test.

**13. OUTPUT CONTRACT**  
`SnapshotService` ist vollständig implementiert und bereit für UI und spätere Teile.

**14. NICHT TEIL DIESES SCHRITTES**  
Social, Sync, Assistant.

## 24.4 Phase 7 — Erweiterungssystem

### STEP 7.1 — Modultypen

**1. ZIEL**  
Definition der verbindlichen Modultypen und Steckplatztypen aus Kapitel 21.

**2. VORBEDINGUNGEN**  
Phase 6 vollständig abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Repositorys, Services, Provider-Verträge und Domain Events sind vorhanden. Das Modul-System ist fachlich noch nicht implementiert.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 21: `UnsaltedModule`, `RecipeContext`, `RecipeDetailSection`, `RecipeAction`, `SettingsEntry`, `SyncTableSpec`.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`BuildContext`, `Widget`, `WidgetRef`, `RouteBase`, `IconData`, `RecipeVersion`, `NutritionResult` sowie die in Kapitel 21 definierten Enum-/Typen.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `lib/src/module/unsalted_module.dart`, `lib/src/module/extension_types.dart`, zugehörige Tests in `test/module/`.  
**Ändern:** keine anderen Core-Dateien.  
**Lesen, aber nicht ändern:** Kapitel-21-Contracts, Repository-/Service-Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Provider-Verdrahtung, keine UI-Bildschirme, keine Datenbankänderung.

**8. IMPLEMENTIERUNG**  
Implementiere die Typen exakt nach Kapitel 21. `lib/src/module/` darf Flutter importieren; Drift bleibt dort verboten. Die `order`-Felder sind `int`. Alle Funktionssignaturen entsprechen dem Contract.

**9. TRANSVERSALE REGELN**  
KI-S2, KI-S3, Public-Door-Regel, Flutter-Ausnahme für `module/`.

**10. TESTS**  
Compile-Test der Modultypen und Architekturprüfung auf zulässige Flutter-/unzulässige Drift-Imports.

**11. FERTIG-KRITERIEN**  
Alle in Kapitel 21 genannten Typen sind vorhanden und kompilieren; keine nicht vorgesehenen Felder oder Methoden.

**12. STOP-BEDINGUNG**  
Nach bestandener Compile- und Architekturprüfung keine weiteren Dateien ändern.

**13. OUTPUT CONTRACT**  
Die vollständigen Modultypen können von `CoreModule` und späteren Modulen implementiert und von der UI konsumiert werden.

**14. NICHT TEIL DIESES SCHRITTES**  
`CoreModule`, Provider, Routing-Verdrahtung, UI-Bildschirme.

### STEP 7.2 — `CoreModule`

**1. ZIEL**  
Implementierung des Core-Moduls als erste konkrete `UnsaltedModule`-Instanz.

**2. VORBEDINGUNGEN**  
7.1 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Modultypen existieren.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 21, insbesondere `UnsaltedModule` und `SyncTableSpec`.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`CoreModule`, Core-Routen und die fünf Core-Sync-Tabellen.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `lib/src/module/core_module.dart`, `test/module/core_module_test.dart`.  
**Ändern:** keine Provider- oder App-Dateien.  
**Lesen, aber nicht ändern:** Repository-/Service-Contracts und Datei-Struktur aus Kapitel 18.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Registrierung in `main.dart`, keine Änderung bestehender Repositorys.

**8. IMPLEMENTIERUNG**  
`id == 'core'`. Liefert Core-Routen und die fünf `SyncTableSpec`-Einträge für `recipes`, `recipe_versions`, `recipe_ingredients`, `recipe_steps`, `food_variants`. Für Zeilen einer eingefrorenen Version wird `immutableAfterCreate = true` gemäß Kapitel 21 verwendet.

**9. TRANSVERSALE REGELN**  
Die fünf Core-Tabellen sind die vollständige Teil-1-Liste für `syncTables`.

**10. TESTS**  
Prüfe `id`, Tabellenliste und `immutableAfterCreate`.

**11. FERTIG-KRITERIEN**  
`CoreModule` implementiert `UnsaltedModule` vollständig.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem Compile-/Unit-Test keine Provider-Verdrahtung.

**13. OUTPUT CONTRACT**  
`CoreModule()` kann in der App-Hülle in die Modulliste aufgenommen werden.

**14. NICHT TEIL DIESES SCHRITTES**  
Provider und `main.dart`.

### STEP 7.3 — Provider

**1. ZIEL**  
Verdrahtung der implementierten Core-Komponenten über Riverpod.

**2. VORBEDINGUNGEN**  
6.2–6.6 und 7.1–7.2 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Repositorys und Services können über Konstruktoren mit ihren Abhängigkeiten instanziiert werden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.7 sowie die konkreten Konstruktoren der Implementierungen.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`CoreDatabase`, `RecipeDao`, `RecipeRepository`, `FoodRepository`, `NutritionService`, `SnapshotService`, `DomainEvent`, `UnsaltedModule`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `lib/src/providers/core_providers.dart`, `test/providers/core_providers_test.dart`.  
**Ändern:** keine Repository-/Service-Implementierungen.  
**Lesen, aber nicht ändern:** Provider-Contracts, Implementierungskonstruktoren, `CoreModule`.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Änderung von Repository-Signaturen. Keine Änderung der App-Hülle.

**8. IMPLEMENTIERUNG**  
Definiere `coreDatabaseProvider`, `modulesProvider`, `recipeDaoProvider`, `recipeRepositoryProvider`, `foodRepositoryProvider`, `nutritionServiceProvider`, `snapshotServiceProvider` und `domainEventsProvider`. `recipeRepositoryProvider` erhält `RecipeDao` über `recipeDaoProvider`; keine Riverpod-Referenz in Repository-Implementierungen.

**9. TRANSVERSALE REGELN**  
Provider sind Verdrahtung, nicht Geschäftslogik. App-Hülle ist der einzige Ort für Overrides.

**10. TESTS**  
Prüfe Provider-Auflösung und Standardzustände von `coreDatabaseProvider`/`modulesProvider`.

**11. FERTIG-KRITERIEN**  
Alle vorgesehenen Provider existieren und kompilieren.

**12. STOP-BEDINGUNG**  
Nach Provider-Tests keine UI- oder App-Dateien ändern.

**13. OUTPUT CONTRACT**  
UI und spätere Module können die eingefrorenen Contracts über Riverpod lesen.

**14. NICHT TEIL DIESES SCHRITTES**  
`main.dart`, UI.

### STEP 7.4 — Öffentliche Tür

**1. ZIEL**  
Schließen und Einfrieren der öffentlichen Package-API von `unsalted_core`.

**2. VORBEDINGUNGEN**  
7.1–7.3 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Alle exportierbaren Typen sind vorhanden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 18.1 und Public-API-Golden.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`lib/unsalted_core.dart`, `test/architecture/public_api_golden.txt`, `test/architecture/public_api_test.dart`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `test/architecture/public_api_golden.txt`, falls noch nicht vorhanden.  
**Ändern:** `lib/unsalted_core.dart`, Public-API-Test.  
**Lesen, aber nicht ändern:** alle exportierbaren Contracts und Fachmodelle.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Änderung der implementierten Fach-/Datenmodelle nur zum Erreichen eines Exports. Tabellen, DAOs und UI-Widgets werden nicht exportiert.

**8. IMPLEMENTIERUNG**  
Exportiere ausschließlich die laut Kapitel 18.1 vorgesehenen Contracts, Fachmodelle, Nährwerttypen, `RecipeChange`, `RecipeDiff`, `RecipeSnapshotV1`, Fehlerklassen, Modultypen, `CoreModule`, Provider und `CoreDatabase`.

**9. TRANSVERSALE REGELN**  
R2, KI-S3 und Kapitel 25.1.

**10. TESTS**  
AT-06, AT-09.

**11. FERTIG-KRITERIEN**  
Public-Door-Golden stimmt exakt.

**12. STOP-BEDINGUNG**  
Nach grünem AT-06/AT-09 keine weitere API-Erweiterung in diesem Schritt.

**13. OUTPUT CONTRACT**  
`lib/unsalted_core.dart` ist eingefrorene externe Einstiegstür von `unsalted_core`.

**14. NICHT TEIL DIESES SCHRITTES**  
Neue Exporttypen.

## 24.5 Phase 8 — Oberfläche

### STEP 8.1 — Lebensmittel-Liste und Lebensmittel-Editor

**1. ZIEL**  
Implementierung der Suche, Liste und Bearbeitung von `FoodVariant`.

**2. VORBEDINGUNGEN**  
7.3 und 7.4 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
`FoodRepository`, `NutritionFormatter`, `NutrientValidator` und Provider sind verfügbar.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.2, 8.6, 22 Bildschirm 9–10.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`FoodVariant`, `NewFoodVariant`, `FoodSource`, `NutrientSet`, `UnitCatalog` soweit benötigt.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/foods/food_list_screen.dart`, `lib/src/ui/foods/food_editor_screen.dart`, `lib/src/ui/foods/package_form.dart`, zugehörige UI-Testdateien.  
**Ändern:** keine Repository-/Service-/Provider-Dateien.  
**Lesen, aber nicht ändern:** Food-Contracts und Formatter/Validator.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Datenbankzugriffe direkt aus Widgets. Keine neue Tabelle. Keine eigene Nährwertberechnung.

**8. IMPLEMENTIERUNG**  
Suche, Leerer-Zustand, Erstellen, Bearbeiten und Validierungsanzeigen. Optionales Natrium-Feld wird ausschließlich innerhalb des Formular-Speichervorgangs nach Kapitel 8.2 in `salt_g` überführt.

**9. TRANSVERSALE REGELN**  
Validator-Warnungen erlauben Speichern; Validator-Fehler verhindern Speichern.

**10. TESTS**  
UI-09 plus Formularfehler- und Warnpfade.

**11. FERTIG-KRITERIEN**  
Food-Liste und Editor funktionieren ausschließlich über den vorgesehenen Contract.

**12. STOP-BEDINGUNG**  
Keine Erweiterung in Rezept-UI oder Persistenz.

**13. OUTPUT CONTRACT**  
Food-UI ist für Rezept-Autocomplete und Einstellungen verfügbar.

**14. NICHT TEIL DIESES SCHRITTES**  
Rezept-UI.

### STEP 8.2 — Rezeptliste und Erstellung

**1. ZIEL**  
Rezeptübersicht und Erstellen eines neuen Rezepts.

**2. VORBEDINGUNGEN**  
7.3, 7.4, 8.1.

**3. BESTEHENDER PROJEKTZUSTAND**  
`RecipeRepository.watchRecipes()` und `createRecipe()` stehen als Provider zur Verfügung.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.1, Bildschirm 1–2.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`Recipe`, `NewRecipe`, Router-Route.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/recipe_list/recipe_list_screen.dart`, `lib/src/ui/recipe_editor/recipe_create_screen.dart`, zugehörige UI-Testdateien.  
**Ändern:** keine Repository-/Provider-Dateien.  
**Lesen, aber nicht ändern:** `RecipeRepository`, Router-Konfiguration.

**7. VERBOTENE ÄNDERUNGEN**  
Keine direkte DB-Abfrage.

**8. IMPLEMENTIERUNG**  
Watch-Stream, Titel-Suche, Leerzustand, FAB, Create-Formular, Weiterleitung zum neuen Draft.

**9. TRANSVERSALE REGELN**  
Titel 1–200 Zeichen. Fehlertexte gemäß Exception-Contract.

**10. TESTS**  
UI-01, UI-02.

**11. FERTIG-KRITERIEN**  
Liste und Erstellungsfluss funktionieren.

**12. STOP-BEDINGUNG**  
Keine Editor-Logik außer dem Erstellungsbildschirm.

**13. OUTPUT CONTRACT**  
Ein neu angelegtes Rezept führt auf seinen Draft-Editor.

**14. NICHT TEIL DIESES SCHRITTES**  
Rezeptbearbeitung nach dem Erstellen.

### STEP 8.3 — Rezept-Editor

**1. ZIEL**  
Bearbeitung einer Draft-Version mit Live-Vorschau.

**2. VORBEDINGUNGEN**  
8.1, 8.2 und Provider.

**3. BESTEHENDER PROJEKTZUSTAND**  
Recipe-/Food-/Nutrition-Contracts sind verfügbar.

**4. VERBINDLICHE CONTRACTS**  
`RecipeRepository`, `FoodRepository.search`, `NutritionService.preview`, `UnitCatalog`.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`RecipeVersion`, `RecipeIngredient`, `RecipeStep`, `RecipeVersionDraft`, `IngredientInput`, `RecipeChange`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/recipe_editor/recipe_editor_screen.dart`, `lib/src/ui/recipe_editor/ingredient_row.dart`, `lib/src/ui/recipe_editor/recipe_create_screen.dart` soweit für den gemeinsamen Editorfluss erforderlich, zugehörige UI-Tests.  
**Ändern:** keine Repository-/Service-Dateien.  
**Lesen, aber nicht ändern:** Contracts und UnitCatalog.

**7. VERBOTENE ÄNDERUNGEN**  
Keine SQL-/Drift-Operationen. Keine Nährwertberechnung innerhalb des Widgets.

**8. IMPLEMENTIERUNG**  
Lokaler Formularzustand darf im Widget oder in einem UI-Notifier liegen. Speichern konstruiert `RecipeVersionDraft`. Live-Vorschau verwendet `NutritionService.preview`. Snapshot-Editor ist schreibgeschützt und bietet `createDraftFrom`.

**9. TRANSVERSALE REGELN**  
UI-State ist kein Persistenz-State. Decimal-Eingaben werden nicht über `double` erzeugt.

**10. TESTS**  
UI-03, UI-04.

**11. FERTIG-KRITERIEN**  
Draft lässt sich bearbeiten/speichern; Snapshot ist unveränderlich.

**12. STOP-BEDINGUNG**  
Keine Versionsvergleichslogik.

**13. OUTPUT CONTRACT**  
Ein funktionierender Draft-Editor existiert und liefert `RecipeVersionDraft` an das Repository.

**14. NICHT TEIL DIESES SCHRITTES**  
Versionsvergleich, Export-/Import-Bildschirme.

### STEP 8.4 — Nährwertanzeige und Mengenrechner

**1. ZIEL**  
Darstellung von `NutritionResult` und bidirektionaler Mengen-/Energieumrechnung.

**2. VORBEDINGUNGEN**  
8.3.

**3. BESTEHENDER PROJEKTZUSTAND**  
`NutritionResult` und Formatter sind vorhanden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 8.6, 17 und Bildschirm 5–6.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`NutritionResult`, `NutritionFormatter`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/nutrition/nutrition_header.dart`, `nutrition_table.dart`, `amount_calculator.dart`, zugehörige UI-Tests.  
**Ändern:** keine Nutrition-Core-Dateien.  
**Lesen, aber nicht ändern:** Nutrition Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Keine eigene Berechnung der Nährwerte.

**8. IMPLEMENTIERUNG**  
Anzeige von Fertiggewicht, Gesamt-kcal, kcal/Portion und Tabelle. Eingaben des Mengenrechners werden als Text mit `Decimal.parse` verarbeitet; ungültige Eingabe erzeugt einen sichtbaren Eingabefehler ohne Exception.

**9. TRANSVERSALE REGELN**  
`NutritionFormatter` ist einzige Rundungsstelle. Keine andere Energieeinheit.

**10. TESTS**  
UI-05, UI-06, UI-07.

**11. FERTIG-KRITERIEN**  
Beide Rechenrichtungen und `incomplete`-Markierungen funktionieren.

**12. STOP-BEDINGUNG**  
Keine Änderungen am Rechenkern.

**13. OUTPUT CONTRACT**  
Nährwertanzeige ist wiederverwendbar im Rezeptdetail.

**14. NICHT TEIL DIESES SCHRITTES**  
Rezeptdetail oder Versionen.

### STEP 8.5 — Rezeptdetail und Steckplätze

**1. ZIEL**  
Lesende Rezeptansicht mit Modulsystem und Snapshot-Wahrheit.

**2. VORBEDINGUNGEN**  
8.4 und 7.1–7.4.

**3. BESTEHENDER PROJEKTZUSTAND**  
Provider, CoreModule und Nährwertanzeige verfügbar.

**4. VERBINDLICHE CONTRACTS**  
`watchRecipe`, `watchVersions`, `NutritionService.forVersion`, `RecipeContext`, `RecipeDetailSection`, `RecipeAction`.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`RecipeContext`, `NutritionResult`, `RecipeVersion`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/recipe_detail/recipe_detail_screen.dart`, `version_switcher.dart`, zugehörige UI-Tests.  
**Ändern:** keine Module, Provider oder Services.  
**Lesen, aber nicht ändern:** Kapitel 21 und 22.

**7. VERBOTENE ÄNDERUNGEN**  
Keine aktive Timer-Engine. Keine erneute Live-Nährwertauflösung von FoodVariants bei Snapshots.

**8. IMPLEMENTIERUNG**  
Versionen, Zutaten, Schritte, Nährwertanzeige, Sections und Actions werden generisch nach `order` gerendert. Timer-Chips zeigen nur `timerSeconds`.

**9. TRANSVERSALE REGELN**  
Snapshot-Nährwertquelle ist `snapshotJson`.

**10. TESTS**  
EX-01 bis EX-05.

**11. FERTIG-KRITERIEN**  
Core- und leere Modulkonfiguration funktionieren.

**12. STOP-BEDINGUNG**  
Keine Timer-Hintergrundlogik und keine Social-/Sync-Funktionalität.

**13. OUTPUT CONTRACT**  
Rezeptdetail kann zusätzliche Module ohne Core-Änderung aufnehmen.

**14. NICHT TEIL DIESES SCHRITTES**  
Versionen-/Vergleichsseite.

### STEP 8.6 — Versionen und Vergleich

**1. ZIEL**  
Versionsverlauf, Vergleichen und Übernehmen eines Diffs.

**2. VORBEDINGUNGEN**  
8.5 und Phase 6.

**3. BESTEHENDER PROJEKTZUSTAND**  
SnapshotService und RecipeDiff verfügbar.

**4. VERBINDLICHE CONTRACTS**  
`watchVersions`, `SnapshotService.exportVersion`, `RecipeDiff.between`, `applyChangesAsNewDraft`.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`RecipeSnapshotV1`, `RecipeChange`, `RecipeVersion`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/versions/version_list_screen.dart`, `version_compare_screen.dart`, zugehörige UI-Tests.  
**Ändern:** keine Diff-/Repository-Dateien.  
**Lesen, aber nicht ändern:** Version-/Snapshot-Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Keine eigene Diff-Logik in der UI.

**8. IMPLEMENTIERUNG**  
Versionen absteigend, Master-Stern, Snapshot-Zeitpunkt, Kopie, Vergleich, gruppierte Change-Liste, Übernehmen exakt mit derselben Change-Liste.

**9. TRANSVERSALE REGELN**  
Diff-Anwendung läuft über Repository.

**10. TESTS**  
UI-08.

**11. FERTIG-KRITERIEN**  
Anzeige und Übernahme funktionieren.

**12. STOP-BEDINGUNG**  
Keine Änderungen an RecipeDiff.

**13. OUTPUT CONTRACT**  
Versionsvergleich ist ein reiner Consumer der globalen Diff-/Repository-Verträge.

**14. NICHT TEIL DIESES SCHRITTES**  
Import-/Export-Settings.

### STEP 8.7 — Einstellungen, Export und Import

**1. ZIEL**  
Einstellungen sowie JSON-Export/-Import.

**2. VORBEDINGUNGEN**  
8.6.

**3. BESTEHENDER PROJEKTZUSTAND**  
SnapshotService und Module-System stehen.

**4. VERBINDLICHE CONTRACTS**  
`SnapshotService`, `SettingsEntry`, Kapitel 13 und Bildschirm 11–13.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`RecipeSnapshotV1`, `ImportFormatException`, `ImportVersionException`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `lib/src/ui/settings/settings_screen.dart`, `export_screen.dart`, `import_screen.dart`, zugehörige UI-Tests.  
**Ändern:** keine Snapshot-/Repository-Dateien.  
**Lesen, aber nicht ändern:** Snapshot-Contracts und Modul-Settings-Contract.

**7. VERBOTENE ÄNDERUNGEN**  
Keine direkte JSON-Strukturinterpretation über den Contract hinaus.

**8. IMPLEMENTIERUNG**  
Exportauswahl nur für Snapshots. Import mit Vorschau vor dem Schreiben. Fehlertexte aus den vorgesehenen Exceptions. Unbekannte JSON-Felder werden entsprechend dem Snapshot-Contract behandelt.

**9. TRANSVERSALE REGELN**  
Keine andere Energieeinheit.

**10. TESTS**  
UI-10.

**11. FERTIG-KRITERIEN**  
Export, Import-Vorschau und Fehlerdarstellung funktionieren.

**12. STOP-BEDINGUNG**  
Keine Änderungen am Snapshot-Contract.

**13. OUTPUT CONTRACT**  
Einstellungen sind vollständig nutzbar.

**14. NICHT TEIL DIESES SCHRITTES**  
App-Hülle.

### STEP 8.8 — App-Hülle verdrahten

**1. ZIEL**  
Verdrahtung der fertigen Core-Komponenten in `unsalted_app`.

**2. VORBEDINGUNGEN**  
8.1–8.7 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Alle Core-Provider und `CoreModule` sind implementiert.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 16.7, Kapitel 21.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
`CoreDatabase`, `coreDatabaseProvider`, `modulesProvider`, `CoreModule`, Router.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** `apps/unsalted_app/lib/main.dart` sowie notwendige App-Testdatei.  
**Ändern:** keine Core-Provider- oder Moduldateien.  
**Lesen, aber nicht ändern:** Public Door und App-Routing-Contracts.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Änderung an `unsalted_core`, um die App-Verdrahtung zu vereinfachen.

**8. IMPLEMENTIERUNG**  
`ProviderScope(overrides: [...])` erhält Datenbank- und Modullisten-Overrides. `modules = <UnsaltedModule>[CoreModule()]`. Router verbindet die Core-Routen.

**9. TRANSVERSALE REGELN**  
App-Hülle ist alleinige Stelle der Modullistenregistrierung.

**10. TESTS**  
App-Start und manueller Durchlauf.

**11. FERTIG-KRITERIEN**  
Die App startet und die Core-Flows sind erreichbar.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem Start keine Architekturänderungen.

**13. OUTPUT CONTRACT**  
Teil 1 ist als App-Hülle manuell durchlaufbar.

**14. NICHT TEIL DIESES SCHRITTES**  
Integrationstest-Suite und Freeze.

## 24.6 Phase 9 — Integration und Spike

### STEP 9.1 — Integrationstests

**1. ZIEL**  
Vollständige End-to-End-Verifikation der Teil-1-Garantien.

**2. VORBEDINGUNGEN**  
Phase 8 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
App und Core sind integriert.

**4. VERBINDLICHE CONTRACTS**  
Alle Contracts der Kapitel 8–22.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
Integration-Testbereich `test/integration/`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen:** `test/integration/*` gemäß Testplan.  
**Ändern:** keine Produktionsdateien.  
**Lesen, aber nicht ändern:** vollständige Public API und App-Flows.

**7. VERBOTENE ÄNDERUNGEN**  
Produktionscode nicht aufgrund eines einzelnen Integrationstests „mitreparieren“, ohne die zuständige Arbeitskarte zu identifizieren.

**8. IMPLEMENTIERUNG**  
IT-01 bis IT-06 plus ergänzende Edge Cases für Diff/Apply, Snapshot-Import und Master-Integrität aus Kapitel 23.

**9. TRANSVERSALE REGELN**  
Integrationstests prüfen Systemketten, nicht Ersatzimplementierungen.

**10. TESTS**  
Alle Integrationstests müssen grün sein.

**11. FERTIG-KRITERIEN**  
IT-01 bis IT-06 sowie alle ergänzenden Integrationsfälle grün.

**12. STOP-BEDINGUNG**  
Keine Produktionsänderung außerhalb einer gesonderten Fehlerbehebungskarte.

**13. OUTPUT CONTRACT**  
Teil 1 ist integrativ verifiziert.

**14. NICHT TEIL DIESES SCHRITTES**  
Freeze-Tag.

### STEP 9.2 — Manueller Durchlauf

**1. ZIEL**  
Manuelle Verifikation des vollständigen Benutzerflusses.

**2. VORBEDINGUNGEN**  
9.1 grün.

**3. BESTEHENDER PROJEKTZUSTAND**  
Alle Core-Flows funktionieren automatisiert.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 22 und 25.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
App, Testdaten, `docs/status.md`.

**6. ERLAUBTER DATEISCOPE**  
**Ändern:** `docs/status.md`.  
**Lesen:** App und alle relevanten UI-Flows.  
**Produktionsdateien:** nicht ändern.

**7. VERBOTENE ÄNDERUNGEN**  
Keine Implementierungsänderung während des manuellen Durchlaufs.

**8. IMPLEMENTIERUNG**  
Lebensmittel anlegen → Rezept → Zutaten → Nährwerte → einfrieren → Draft kopieren → ändern → vergleichen → exportieren → App neu starten → importieren.

**9. TRANSVERSALE REGELN**  
Kein anderer Energieausdruck.

**10. TESTS**  
Manuelle Abnahmeliste.

**11. FERTIG-KRITERIEN**  
Kompletter Durchlauf ohne Blocker.

**12. STOP-BEDINGUNG**  
Ergebnis in `docs/status.md` dokumentiert.

**13. OUTPUT CONTRACT**  
Teil 1 ist manuell überprüft.

**14. NICHT TEIL DIESES SCHRITTES**  
Freeze-Tag und Release.

### STEP 9.3 — Technischer Spike

**1. ZIEL**  
Verifizieren, ob mehrere Drift-Datenbankklassen denselben `QueryExecutor` teilen können.

**2. VORBEDINGUNGEN**  
9.1 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
`CoreDatabase(QueryExecutor)` ist vorhanden.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 20.1.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
Spike-Testaufbau und `docs/decisions.md`.

**6. ERLAUBTER DATEISCOPE**  
**Erstellen/Ändern:** ausschließlich für den Spike erforderliche Testdatei gemäß Arbeitskarte und `docs/decisions.md`.  
**Produktionscode:** nicht ändern.

**7. VERBOTENE ÄNDERUNGEN**  
Teil 1 darf unabhängig vom Spike-Ergebnis nicht umgebaut werden.

**8. IMPLEMENTIERUNG**  
Lauffähigen Testaufbau erstellen, der das Teilen eines `QueryExecutor` zwischen mehreren Drift-Datenbankklassen demonstriert oder widerlegt.

**9. TRANSVERSALE REGELN**  
Ergebnis muss reproduzierbar dokumentiert sein.

**10. TESTS**  
Spike-Test muss reproduzierbar laufen.

**11. FERTIG-KRITERIEN**  
Ergebnis ist eindeutig: unterstützt oder nicht unterstützt.

**12. STOP-BEDINGUNG**  
Ergebnis in `docs/decisions.md` dokumentiert.

**13. OUTPUT CONTRACT**  
Teil 3 kennt eine dokumentierte technische Grundlage für die Datenbankzusammenführung.

**14. NICHT TEIL DIESES SCHRITTES**  
Änderung der Core-Spezifikation.

## 24.7 Phase 10 — Freeze

### STEP 10.1 — Freeze-Abnahme

**1. ZIEL**  
Alle Freeze-Kriterien aus Kapitel 25 erfüllen.

**2. VORBEDINGUNGEN**  
9.1–9.3 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Alle funktionalen, architektonischen und manuellen Prüfungen liegen vor.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 25.1 und 25.2.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
Freeze-Checkliste und Projektnachweise.

**6. ERLAUBTER DATEISCOPE**  
**Ändern:** nur die für Status-/Nachweisführung vorgesehenen Dateien.  
**Produktionsdateien:** keine fachlichen Änderungen.

**7. VERBOTENE ÄNDERUNGEN**  
Keine neuen fachlichen Entscheidungen.

**8. IMPLEMENTIERUNG**  
Freeze-Kriterien Punkt für Punkt verifizieren.

**9. TRANSVERSALE REGELN**  
Alle Contracts müssen stabil und dokumentiert sein.

**10. TESTS**  
Gesamter Testplan, Architekturtests, Contract-Tests, Integrationstests.

**11. FERTIG-KRITERIEN**  
Alle Freeze-Kriterien sind erfüllt und dokumentiert.

**12. STOP-BEDINGUNG**  
Nach vollständiger Abnahme keine fachlichen Änderungen mehr.

**13. OUTPUT CONTRACT**  
Projekt ist technisch freeze-bereit.

**14. NICHT TEIL DIESES SCHRITTES**  
Release-Tag.

### STEP 10.2 — API-Dokumentation

**1. ZIEL**  
Vollständige API-Dokumentation aller exportierten Klassen und Methoden.

**2. VORBEDINGUNGEN**  
10.1 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Public API ist eingefroren.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 18 und 25.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
Alle exportierten Klassen und Methoden.

**6. ERLAUBTER DATEISCOPE**  
**Ändern:** nur Dateien mit fehlenden `///`-Dokumentationskommentaren und ggf. Dokumentationsnachweis.  
**Lesen:** Public API.

**7. VERBOTENE ÄNDERUNGEN**  
Keine API-Signaturen verändern.

**8. IMPLEMENTIERUNG**  
Alle öffentlichen Klassen und Methoden dokumentieren. `dart doc` ohne Warnungen.

**9. TRANSVERSALE REGELN**  
Dokumentation darf keine neue technische Bedeutung erzeugen.

**10. TESTS**  
`dart doc`.

**11. FERTIG-KRITERIEN**  
Keine Dokumentationswarnungen.

**12. STOP-BEDINGUNG**  
Nach erfolgreichem `dart doc`.

**13. OUTPUT CONTRACT**  
Dokumentierte eingefrorene Public API.

**14. NICHT TEIL DIESES SCHRITTES**  
Neue API.

### STEP 10.3 — Finaler technischer Release-Check

**1. ZIEL**  
Letzte automatisierte Gesamtprüfung und Erstellung des Teil-1-Tags.

**2. VORBEDINGUNGEN**  
10.1 und 10.2 abgeschlossen.

**3. BESTEHENDER PROJEKTZUSTAND**  
Alle Freeze-Kriterien erfüllt.

**4. VERBINDLICHE CONTRACTS**  
Kapitel 25.1 und 25.2.

**5. BENÖTIGTE TYPEN UND DATEIEN**  
Gesamtes Projekt, keine zusätzliche Produktionsdatei.

**6. ERLAUBTER DATEISCOPE**  
**Ändern:** keine Produktionsdateien; nur Release-/Statusnachweis falls erforderlich.  
**Lesen:** gesamtes Projekt.

**7. VERBOTENE ÄNDERUNGEN**  
Keine fachlichen oder architektonischen Änderungen.

**8. IMPLEMENTIERUNG**  
Ausführen:
```bash
dart run tool/check_architecture.dart
flutter test
git tag part1-v1.0.0
```

**9. TRANSVERSALE REGELN**  
Alle Architektur- und Freeze-Kriterien müssen gleichzeitig gelten.

**10. TESTS**  
Architekturtests, vollständige Test-Suite und `dart doc`.

**11. FERTIG-KRITERIEN**  
Alle Prüfungen erfolgreich; Tag `part1-v1.0.0` erstellt.

**12. STOP-BEDINGUNG**  
Nach erfolgreicher Tag-Erstellung keine weitere Änderung am eingefrorenen Teil 1.

**13. OUTPUT CONTRACT**  
Teil 1 ist als eingefrorener Releasezustand vorhanden.

**14. NICHT TEIL DIESES SCHRITTES**  
Teil 2–6.

# 25 Freeze-Kriterien

Teil 1 gilt als fertig, wenn alle Punkte erfüllt sind:

```text
[ ] Alle Tests grün (Ziel: > 140 Tests, Kapitel 23)
[ ] Architekturtests AT-01 bis AT-12 grün
[ ] Kein double in lib/ (AT-07), kein direktes toDecimal außerhalb von decimal_math.dart (AT-08)
[ ] Kein Vorkommen von "kJ" in lib/ und test/ (AT-12)
[ ] Schema-Dump in drift_schemas/ eingecheckt, Migrationstest läuft
[ ] Golden-/Vertragstests GD-01 bis GD-12 grün
[ ] Export → Import → identische Nährwerte (IT-01)
[ ] Snapshot-Sperre getestet (RP-03, RP-05)
[ ] Historische Stabilität getestet (IT-02)
[ ] Snapshot-Wahrheit getestet (IT-04)
[ ] UI-Tests UI-01 bis UI-10 grün
[ ] Erweiterungssystem getestet (EX-01 bis EX-05)
[ ] Öffentliche Tür entspricht der Golden-Liste (AT-06)
[ ] Öffentliche API dokumentiert, dart doc ohne Warnung
[ ] Spike aus Kapitel 20.1 durchgeführt und in docs/decisions.md protokolliert
[ ] docs/status.md zeigt Phase 0 bis Phase 10 als fertig
[ ] Git-Tag part1-v1.0.0

```

## 25.1 Zeitpunkt und Gegenstand jeder Einfrierung

| **Eingefroren abGegenstand** |                                                                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Schritt 4.1                  | Struktur und Typen von `RecipeSnapshotV1`                                                   |
| Schritt 3.2                  | `type`-Strings und Feldmengen aller 13 `RecipeChange`-Klassen                                                            |
| Schritt 5.4                  | Datenbankschema v1: Tabellen- und Spaltennamen, Typen, Standardfelder                                                    |
| Schritt 6.1                  | Signaturen von `RecipeRepository`, `FoodRepository`, `NutritionService`, `SnapshotService`, Domain Events, Fehlerklassen |
| Schritt 7.1                  | `UnsaltedModule`, `RecipeContext`, `RecipeDetailSection`, `RecipeAction`, `SettingsEntry`, `SyncTableSpec`               |
| Schritt 7.4                  | Name und Exportinhalt der öffentlichen Tür                                                                               |
| Kapitel 9                    | Einheiten-Faktoren (in historischen Snapshots eingerechnet)                                                              |
| Kapitel 10                   | Zuordnung jedes Feldes zu Fachmodell oder Persistenzmodell                                                               |

## 25.2 Erlaubte Änderungen nach dem Freeze

- Fehlerbehebungen und Sicherheitskorrekturen ohne Signatur- oder Formatänderung.
- Neue **optionale** JSON-Felder im Snapshot-Format (bestehende Leser ignorieren sie gemäß Kapitel 13.5).
- Neue Tabellen; neue Spalten mit Migration und Standardwert.
- Neue Steckplätze (`RecipeDetailSection`, `RecipeAction`, `SettingsEntry`) über neue Module, ohne Änderung an Teil 1.
- Neue `RecipeChange`-Klassen (additiv; bestehende `type`-Strings bleiben unverändert).

Jede dieser Änderungen ist ein Patch- oder Minor-Release. Vor jeder Schema-Änderung ist zu prüfen, ob `extra_json` (Kapitel 8.1) oder eine neue Tabelle in einem späteren Teil ausreicht; ist das der Fall, unterbleibt die Änderung an Teil 1.

---

# 26 Fehlersuche

| **SymptomErste Stelle**                                                         |                                                                                                 |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Nährwert falsch                                                                 | `src/nutrition/nutrition_engine.dart`, Fall als Test in `test/nutrition/` nachstellen           |
| Wert falsch gerundet/formatiert                                                 | `nutrition_formatter.dart`                                                                      |
| Zutat „nicht berechenbar“                                                       | `unit_catalog.dart`; Dichte/Stückgewicht der verknüpften `FoodVariant` prüfen                   |
| Rundungsabweichung in einer weit hinten liegenden Nachkommastelle               | `decimal_math.dart`, `kInternalScale`                                                           |
| Laufzeitfehler zu `scaleOnInfinitePrecision`                                    | ein `toDecimal()`-Aufruf außerhalb von `decimal_math.dart` — AT-08 hätte dies verhindern müssen |
| Werte nach Neustart verschwunden                                                | `src/data/` (Tabelle, DAO, Mapper)                                                              |
| Snapshot ließ sich ändern                                                       | `drift_recipe_repository.dart` (`saveDraft`), zusätzlich die DAO-Sperre                         |
| Export weicht von der Anzeige ab                                                | Verstoß gegen Kapitel 10.8: ein Leser liest Zeilen statt `snapshotJson` bei `state = snapshot`  |
| Import legt unerwartet Duplikate an                                             | `drift_snapshot_service.dart`, Regel 13.6 Schritt 5                                             |
| Import bricht ohne erkennbaren Grund ab                                         | `snapshot_codec.dart`, Pflichtfelder Kapitel 13.2                                               |
| Button eines späteren Teils fehlt auf der Rezeptseite                           | Modulliste in `apps/unsalted_app/lib/main.dart`                                                 |
| Nährwerte pro 100 g unplausibel hoch                                            | Backverlust prüfen (fachlich korrektes Verhalten) oder `finalWeightOverrideG`                   |
| `updatedAt` ändert sich, obwohl sich fachlich nichts geändert hat               | erwartetes Verhalten nach Kapitel 10.10 — keine No-Op-Erkennung in Teil 1                       |
| Zwei Geräte zeigen unterschiedliche Zutatenreihenfolge nach Offline-Bearbeitung | bekannte Grenze aus Kapitel 20.1, gehört in die Spezifikation von Teil 3                        |

---

# 27 Regeln für die KI

Diese Regeln sind Bestandteil von `PROJECT.md` und gelten für jede Bearbeitung dieses Projekts.

1. **Aktueller Schritt:** Arbeite ausschließlich im aktuellen Schritt und nach dessen Arbeitskarte aus Kapitel 24.
2. **Read Broad, Write Narrow:** Bestehende Projektdateien dürfen für das Verständnis gelesen werden. Erstellt oder verändert werden dürfen ausschließlich Dateien im erlaubten Schreib-Scope der aktuellen Arbeitskarte.
3. **Kein impliziter Contract:** Fehlende Typen oder Signaturen werden nicht erfunden. Ist ein benötigter Contract nicht definiert, stoppt die KI an dieser Stelle.
4. **Kein Vorgriff:** Funktionalität späterer Schritte oder Teile darf nicht vorweggenommen werden.
5. **Paketgrenzen:** Fremde Pakete werden ausschließlich über ihre Public Door verwendet. Kein fremder `src/`-Import.
6. **Datenbank:** Schreibzugriffe laufen ausschließlich über Repositorys. UI und fremde Pakete schreiben nicht direkt in Tabellen.
7. **Fachmodell ≠ Persistenzmodell:** Drift-Zeilentypen werden nicht als Fachmodelle weitergereicht; Mapper bilden die Grenze.
8. **Zahlen:** Fachliche Werte sind `Decimal`; interne Rechenketten verwenden `Rational`; `double`/`num` sind für fachliche Werte verboten. UI-Layoutwerte dürfen `double` verwenden.
9. **Rundung:** Rechenlogik bleibt ungerundet; sichtbare Rundung erfolgt ausschließlich im Formatter.
10. **Energie:** Ausschließlich `energy_kcal`.
11. **Snapshot:** Ein Snapshot wird niemals direkt verändert. Export, Diff und Snapshot-Nährwertberechnung verwenden die gespeicherte Snapshot-Wahrheit.
12. **Transaktionen:** Das Repository besitzt die fachliche Transaction Boundary. DAO-Methoden eröffnen innerhalb dieser Operation keine eigene unabhängige Transaction Boundary.
13. **Public Door:** `lib/unsalted_core.dart` ist die externe Einstiegstür von `unsalted_core`.
14. **Flutter-Ausnahme:** `package:flutter/...` ist in `lib/src/ui/` und `lib/src/module/` zulässig. Drift-Imports außerhalb von `lib/src/data/` bleiben verboten.
15. **Tests:** Die in der Arbeitskarte genannten Tests werden ausgeführt. Ein späterer Integrationstest ersetzt keine lokale Schritt-Abnahme.
16. **Freeze:** Eingefrorene Verträge werden nicht verändert. Erlaubte Erweiterungen richten sich nach Kapitel 25.2.
17. **Versionsnummern:** Paketversionen werden nur über `pub add`/`pub outdated` ermittelt.
18. **Unsicherheit:** Bei nicht dokumentierten oder versionsabhängigen Schnittstellen wird nicht geraten. Die Unsicherheit wird gemeldet.
19. **Keine Scope-Erweiterung:** Sobald die Fertig-Kriterien erfüllt sind, gilt die Stop-Bedingung der Arbeitskarte.
20. **Schrittnachweis:** Nach Abschluss werden `docs/status.md` und der Schrittnachweis gemäß Arbeitskarte aktualisiert.

---

# 28 Nachträge und Klarstellungen zu Teil 1

## 28.0 Geltung

Dieses Kapitel ergänzt Kapitel 1–27. Es hält Nachträge, Klarstellungen und Abweichungen fest, die während der Umsetzung von Teil 1 entschieden wurden; die bestehenden Kapitel bleiben unverändert. Bei Widerspruch zwischen diesem Kapitel und Kapitel 1–27 gilt dieses Kapitel. Kapitel 28 ist Teil des Freeze von `part1-v1.0.0`. Begründungen, Nachweise und verworfene Alternativen stehen in `docs/decisions.md` unter dem jeweils genannten Eintrag.

## 28.1 Werkzeuge und Architekturprüfung

1. **Kapitel 4/5 — CI (Nachtrag 0.1a).** Jeder Push und Pull Request auf `main` führt in GitHub Actions `dart run tool/check_architecture.dart` sowie `flutter analyze` und `flutter test` für `unsalted_core` und `unsalted_app` aus. Die Flutter-Version ist fest eingetragen und wird bei einem lokalen Upgrade mitgezogen. → `decisions.md` „Nachtrag 0.1a“
2. **Kapitel 5.1 — `check_architecture.dart` (Nachtrag 1.1a).** Die Ausnahmeordner werden relativ zu `lib/` geprüft: `package:flutter/` ist in `src/ui/` und `src/module/` erlaubt (Kapitel 27, Regel 14), `package:drift/` in `src/data/`. Das Werkzeug muss mit Exit 0 enden. → „Nachtrag 1.1a“
3. **Kapitel 5.2, AT-05 (Schritt 7.3).** Die Ausnahme erlaubt `src/providers/`, aus `src/data/` zu importieren (`CoreDatabase`, DAO-Interfaces und Drift-Implementierungen), um sie hinter den Verträgen zu verdrahten (Kapitel 16.7). `package:drift` selbst bleibt auf `src/data/` beschränkt; `src/providers/` importiert es nicht. → „Schritt 7.3“
4. **Kapitel 5.2/25, AT-12.** `test/architecture/` ist von AT-12 ausgenommen, weil der Prüftest den gesuchten Begriff selbst enthalten muss. Alle übrigen Testdateien bauen den Begriff zur Laufzeit aus Zeichencodes zusammen; in `lib/` gilt das Verbot ohne Ausnahme. → „Nachtrag 10.1a“, Abschnitt B2
5. **Kapitel 21, AT-09 (Schritt 8.8).** AT-09 gilt auch für `apps/unsalted_app`: Die App importiert ausschließlich die öffentliche Tür und erreicht Bildschirme nur über `UnsaltedModule.routes`. Rang 99 in `architecture.yaml` betrifft nur die Rangregel (AT-01). → „Schritt 8.8“, „Nachtrag 8.7a“

## 28.2 Verträge, öffentliche Tür und Module

1. **Kapitel 18.1 — Importe von `drift_recipe_repository.dart` (Schritt 6.3).** Die Datei importiert `nutrition/*`, weil `snapshotVersion` laut 12.3 `NutritionEngine.calculate` ausführt. → „Schritt 6.3“
2. **Kapitel 16.7/16.8/18.1 — Inhalt der Tür (Schritt 7.4).** `recipeDaoProvider` und `foodDaoProvider` werden nicht exportiert, weil DAOs keine externe Public API sind (16.8). Aus `recipe_snapshot_v1.dart` wird nur `RecipeSnapshotV1`, aus `unit_catalog.dart` nur `UnitCatalog` exportiert. → „Schritt 7.4“
3. **Kapitel 21 — `CoreModule` (Schritt 7.2, Nachtrag 8.7a).** `CoreModule.routes` liefert je einen `GoRoute` für die zwölf Routen aus Kapitel 22. `recipeDetailSections`, `recipeActions` und `settingsEntries` bleiben leer, weil sie Erweiterungspunkte für andere Module sind. `ownerColumn` ist einheitlich `'owner_id'`; für Tabellen ohne eigene Spalte wird der Besitz über die Elternkette aufgelöst (Teil 3). → „Schritt 7.2“, „Nachtrag 8.7a“
4. **Kapitel 21 — App-Hülle (Schritt 8.8).** Die App-Hülle legt eine `ShellRoute` mit `NavigationBar` (Rezepte, Lebensmittel, Einstellungen) um alle Modulrouten. Ihre `pubspec.yaml` nennt `unsalted_core`, `flutter_riverpod`, `go_router` und `drift_flutter` als direkte Abhängigkeiten. → „Schritt 8.8“

## 28.3 Fachliche Klarstellungen

1. **Kapitel 12.4 — Draft-Kopie eines Snapshots (Fehlerbehebung 9.1a, F1).** Zutaten und Schritte kommen aus `snapshotJson`. Die `foodVariantId` jeder Zutat kommt aus der Zeile derselben Snapshot-Version an gleicher Position (Kapitel 10.8), sofern Name, Menge und Einheit übereinstimmen, sonst ist sie `null`. Das Snapshot-Format bekommt bewusst keine Variant-ID. → „Fehlerbehebung 9.1a“
2. **Kapitel 15 — Signatur von `RecipeDiff.between` (9.1a, F3).** Die Signatur lautet `RecipeDiff.between(a, b, {List<RecipeIngredient>? targetRows})`. Mit den Zutatenzeilen der Zielversion (`RecipeRepository.getVersion`) tragen erzeugte `AddIngredient`/`ReplaceIngredient` deren `foodVariantId`; wer eine Änderungsliste anwenden will, muss `targetRows` übergeben, ohne sie bleibt die ID `null`. `recipe_diff.dart` importiert dafür zusätzlich `recipe_ingredient.dart` und `snapshot_row_match.dart`. → „Fehlerbehebung 9.1a“
3. **Kapitel 15.4 — Verschiebungen (9.1a, F2).** `MoveIngredient` entsteht auch neben Hinzufügen und Entfernen. Berechnet wird es auf der virtuellen Liste nach allen Remove- und Add-Änderungen; Ziel ist die vollständige Reihenfolge von b (DF-13). → „Fehlerbehebung 9.1a“
4. **Kapitel 15.1 — Zutaten-Identität (9.1a, F4).** Die Zuordnung erfolgt zweistufig, jeweils greedy in Positionsreihenfolge (15.2): zuerst über gleichen, nicht leeren Barcode, danach über den normalisierten Namen. Gleicher Name mit verschiedenen Barcodes ergibt `ReplaceIngredient`. → „Fehlerbehebung 9.1a“
5. **Kapitel 15.3 — „verknüpfte Variante unterscheidet sich“ (9.1a, F5).** Erkannt wird das über die im Snapshot eingebetteten Variantendaten `barcode`, `brand`, `per100g` (einschließlich `extra`), `densityGPerMl` und `gramsPerPiece`; Zahlen werden als Decimal-Wert verglichen (600 == 600.0). → „Fehlerbehebung 9.1a“
6. **Kapitel 14.1 — bekannte Grenze E2.** Beim Anwenden eines `ReplaceIngredient` geht die Notiz der Zutat verloren, weil die Klasse die Zutat vollständig ersetzt und kein `note`-Feld trägt. Notiz-Änderungen erkennt `RecipeDiff` nicht. → „Fehlerbehebung 9.1a“, Abschnitt E2
7. **Kapitel 13.4 — Schlüsselreihenfolge (Nachtrag 10.1b).** `SnapshotCodec.encode` sortiert die Schlüssel jedes Objekts rekursiv alphabetisch, auch in `recipe`, `version`, `nutrition`, `per100g` und `extra`; Listen behalten ihre Reihenfolge. Snapshots, die vor 10.1b gespeichert wurden, behalten ihre alte Reihenfolge und bleiben gültig, weil `decode` jede Reihenfolge liest und der Export den gespeicherten String unverändert liefert (13.7). → „Nachtrag 10.1b“

## 28.4 Oberfläche (Kapitel 22)

1. **Bildschirm 1 und 4 (Nachtrag 8.8a).** Die Rezeptliste öffnet das Rezeptdetail. Das Rezeptdetail hat zwei feste Core-Aktionen „Versionen“ und „Bearbeiten“, die keine `RecipeAction` sind. Navigiert wird per `Navigator.push`. → „Nachtrag 8.8a“
2. **Bildschirm 3 — Spezifikationslücke (Fehlerbehebung 9.2a, 9.1b).** Je Schritt gibt es ein Feld „Timer (Min.)“ (ganze Minuten > 0 oder leer); ein geladener, nicht angefasster Wert bleibt sekundengenau erhalten. Die Lebensmittel-Verknüpfung einer Zutatenzeile ändert sich nur durch Auswahl oder Umbenennen, auch bei weich gelöschtem Lebensmittel, das dann mit einem Hinweis angezeigt wird. → „Fehlerbehebung 9.2a“, „Fehlerbehebung 9.1b“
3. **Bildschirm 4/6 (9.2a).** Der Mengenrechner steht direkt unter der Nährwerttabelle und nutzt dasselbe `NutritionResult`. → „Fehlerbehebung 9.2a“
4. **Bildschirm 7 — Spezifikationslücke (9.2a).** „Als Master markieren“ gibt es für eingefrorene Versionen, die noch nicht Master sind. Das Löschen der Master-Version zeigt die Meldung des Repositorys. → „Fehlerbehebung 9.2a“
5. **Bildschirm 8 (9.2a).** Die Texte der Änderungsliste nennen Zutatennamen und alte → neue Werte. Sie entstehen, indem die Liste nur für die Anzeige der Reihe nach angewendet wird; die übernommene Liste bleibt unverändert (15.5). → „Fehlerbehebung 9.2a“
6. **Bildschirm 10 (Nachtrag 10.0).** Zurück mit ungespeicherten Änderungen fragt vor dem Verwerfen nach. Als Änderung gilt jede Abweichung eines Feldtextes vom Ausgangszustand (`PackageFormState.hasChanges`). → „Nachtrag 10.0“

## 28.5 Testplan (Kapitel 23)

1. **Neue Tests und Test-IDs.** Hinzugekommen sind GD-05b und GD-13 (23.3), DF-13b und DF-14 bis DF-21 (23.2), RP-22 und RP-23 sowie MG-03b (23.4), UI-08b und UI-11 bis UI-32 (23.6) und die Gruppe „RecipeStep“ in `test/recipe/recipe_ingredient_test.dart` (Testvertrag 18.1). Dazu kommen die ergänzenden Integrationsfälle DA-1 bis DA-8 (mit DA-6b), SI-1 bis SI-6 und MI-1 bis MI-4 in `test/integration/` sowie die Spike-Tests A1 bis C7 in `test/spike/`. → „Fehlerbehebung 9.1a“, „9.1b“, „9.2a“, „Nachtrag 10.0“, „Nachtrag 10.1a“, „Nachtrag 10.1b“, „Spike 20.1“
2. **GD-05.** GD-05 prüft gemäß 23.3 für alle Golden-Dateien die byteidentische Rundreise; GD-05b zusätzlich deterministisches Encodieren (Nachtrag 10.1a). → „Nachtrag 10.1a“, Abschnitt B1
3. **Testorte.** GD-11 und GD-12 liegen in `test/data/snapshot_service_test.dart`, weil sie den `DriftSnapshotService` gegen eine Datenbank prüfen. IT-01 bis IT-05 gibt es zusätzlich zu `test/integration/` auch auf Service-Ebene in `test/data/`; maßgeblich für die Abnahme sind die Tests in `test/integration/`. → „Nachtrag 10.1a“, Abschnitt B4

## 28.6 Hinweis für Teil 3 (Kapitel 20.1, Spike 9.3)

Getrennte Verbindungen auf dieselbe Datenbankdatei werden nicht unterstützt: Das gemeinsame `user_version` kann Teil 1 aussperren, und Schreibzugriffe scheitern mit „database is locked“. Empfohlen ist eine gemeinsame Datenbankklasse mit allen Tabellen als alleinige Eigentümerin von Schema, Migrationen und `user_version`, die vor allen anderen Klassen geöffnet wird; `CoreDatabase` und alle Paketklassen laufen auf derselben `DatabaseConnection`-Instanz. Paketübergreifend atomare Schreibzugriffe laufen ausschließlich über die gemeinsame Klasse, und Schema-Änderungen von Teil 1 werden zu Migrationsschritten dieser Klasse. → „Spike 20.1“

## 28.7 Projekt- und Verzeichnisstruktur (Ergänzung zu Kapitel 2 und zum Baum vor 18.1)

1. **Neue Dateien.** `lib/src/recipe/snapshot_row_match.dart` (nicht über die Tür exportiert), `lib/src/ui/versions/change_descriptions.dart`, `test/integration/` (mit `support/`), `test/spike/` und `.github/workflows/ci.yml` im Projektstamm.
2. **`PROJECT.md` (Kapitel 2, 27).** `PROJECT.md` ist durch `CLAUDE.md` im Projektstamm ersetzt. Die Grundregeln (Kapitel 1) und die Regeln für die KI (Kapitel 27) gelten unverändert aus dieser Spezifikation; `CLAUDE.md` fasst sie zusammen und verweist darauf.
3. **Keine Workspace-`pubspec.yaml`.** Im Projektstamm gibt es keine Workspace-Wurzel; die Pakete sind per Pfad-Abhängigkeit eingebunden (`apps/unsalted_app` → `../../packages/unsalted_core`). Das ist nach Kapitel 2 zulässig.

## 28.8 Bekannte Abweichungen und Grenzen von part1-v1.0.0

1. **Bildschirm 11 ohne Teilen-Dialog.** Der Export bietet nur „In Zwischenablage kopieren“.
2. **Bildschirm 12 ohne Dateiauswahl.** Der Import nimmt nur eingefügten Text. Beides braucht zusätzliche Pakete und Plattform-Berechtigungen und ist für Teil 1.1 vorgesehen.
3. **E2.** Siehe 28.3.6.
4. **Snapshot mit weich gelöschtem Lebensmittel.** Das Einfrieren einer Version, deren Zutat auf ein weich gelöschtes Lebensmittel zeigt, erzeugt ohne Warnung einen Snapshot ohne Nährwerte für diese Zutat; das ist spezifikationskonform nach Kapitel 10.7.
5. **Design- und Komfortpunkte.** Reine Design- und Komfortpunkte stehen in `docs/status.md` unter „Bekannte Grenzen von part1-v1.0.0“.

## 28.9 Teil 1.2 – Design-System

Das Aussehen liegt ausschließlich im Paket `unsalted_design`; Bildschirme legen nur fest, was angezeigt wird und was eine Aktion tut. Plan, Ebenen und Commit-Reihenfolge: `docs/design/plan.md`. → `decisions.md` „Teil 1.2“

1. **Kapitel 2/3, `architecture.yaml`.** Neues Paket `packages/unsalted_design` mit Rang 0: einzige Abhängigkeit `flutter`, keine Fachbegriffe, keine Importe von Core, Riverpod oder Drift. Neue App `apps/unsalted_widgetbook` mit Rang 99 als Komponenten-Katalog. → „Teil 1.2 C01“
2. **Kapitel 4.1/4.2.** `unsalted_core` und `unsalted_app` hängen per Pfad von `unsalted_design` ab. → „Teil 1.2 C01“
3. **Kapitel 5.1, Kapitel 27 Regel 14.** `tool/check_architecture.dart` führt die Ausnahmeordner je Eintrag von `forbidden_in_core`: `package:flutter/` in `src/ui/` und `src/module/`, `package:drift/` in `src/data/`, `package:unsalted_design/` nur in `src/ui/`. Für `unsalted_design` sind nur die Importe aus `allowed_in_design` (`package:flutter/`, das eigene Paket) erlaubt, `dart:io` und `dart:ffi` nicht. → „Teil 1.2 C01“
