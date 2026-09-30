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

## Phase 8 — Oberfläche (Kapitel 24.5)
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

Phase 8 — abgeschlossen.

## Phase 9 — Integration und Spike (Kapitel 24.6)
| Schritt | Beschreibung | Status |
|---|---|---|
| 9.1 | Integrationstests | offen |
| 9.2 | Manueller Durchlauf | offen |
| 9.3 | Technischer Spike (mehrere Drift-Klassen auf einer Sync-DB) | offen |

## Phase 10 — Freeze (Kapitel 24.7)
| Schritt | Beschreibung | Status |
|---|---|---|
| 10.1 | Abnahmeliste vollständig abhaken | offen |
| 10.2 | Öffentliche API dokumentieren | offen |
| 10.3 | Tag `part1-v1.0.0` | offen |

## Bekannte offene Lücken (nicht blockierend)

- **`RecipeListScreen` öffnet beim Tippen auf eine Zeile kein `RecipeDetailScreen`**
  (kein `onTap` auf dem `ListTile`, `lib/src/ui/recipe_list/recipe_list_screen.dart`).
  Die Route `/recipes/:id` existiert seit 8.7a, aber die Liste navigiert
  nicht dorthin. Bildschirm 4, 7 und 8 sind in der App daher nur über den
  Import-Fluss erreichbar. Fix gehört in `recipe_list_screen.dart` und
  braucht eine eigene Arbeitskarte — vermutlich Blocker für Schritt 9.2
  (manueller Durchlauf).
- `tool/check_architecture.dart` (Schritt 1.1) meldet (schon vor Schritt 8.8)
  35 „VERBOTENER IMPORT"-Treffer
  für `package:flutter/`/`package:drift/` innerhalb von `lib/src/ui/` bzw.
  `lib/src/data/` — obwohl der Dateikommentar des Tools genau diese beiden
  Ordner als Ausnahme nennt. Das Tool ist offenbar nie an die tatsächliche
  Ordnerstruktur angepasst worden. Es wird von keinem Test und keiner CI
  aufgerufen (nur manuell über `dart run tool/check_architecture.dart`);
  die tatsächlich verbindliche Prüfung sind AT-01–AT-12 in
  `test/architecture/`, die weiterhin alle grün sind. Die Treffer sind
  bei 8.7a/8.8 unverändert geblieben (keiner aus `apps/unsalted_app`).

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
- `test/recipe/recipe_step_test.dart` fehlt noch (RecipeStep selbst korrekt).
- `food_editor_screen.dart` (Schritt 8.1) hat kein `PopScope` für „Abbrechen
  mit ungespeicherten Änderungen fragt nach" (Kapitel 22, allgemeine
  Bildschirmregel) — bei Schritt 8.1 übersehen, erst bei Schritt 8.2s
  `recipe_create_screen.dart` nachgeholt. Nachziehen, sobald
  `food_editor_screen.dart` wieder im Dateiscope eines Schritts liegt.
  Siehe CLAUDE.md Abschnitt 4 für das PopScope+addPostFrameCallback-Muster.
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