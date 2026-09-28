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

## Phase 6 — Repositories und Services (Kapitel 24.3)
| Schritt | Beschreibung | Status |
|---|---|---|
| 6.1 | Verträge und Input-Modelle (`input_models.dart`, `domain_events.dart`, `recipe_repository.dart`, `food_repository.dart`, `nutrition_service.dart`, `snapshot_service.dart`) | fertig |
| 6.2 | DomainEventBus | offen |
| 6.3 | DriftRecipeRepository | offen |
| 6.4 | DriftFoodRepository | offen |
| 6.5 | DriftNutritionService | offen |
| 6.6 | DriftSnapshotService | offen |

**Vor 6.3/6.4:** Mapper (`lib/src/data/mappers/*.dart`) gegen die
DAO-Signaturen aus Kapitel 16.8 prüfen — siehe CLAUDE.md Abschnitt 3
(`food_mapper.dart` liefert noch `FoodVariantsCompanion`, `FoodDao`
verlangt aber `FoodVariantRow`).

## Phase 7 — Erweiterungssystem (Kapitel 24.4)
| Schritt | Beschreibung | Status |
|---|---|---|
| 7.1 | Modultypen | offen |
| 7.2 | CoreModule | offen |
| 7.3 | Provider | offen |
| 7.4 | Öffentliche Tür schließen | offen |

## Phase 8 — Oberfläche (Kapitel 24.5)
| Schritt | Beschreibung | Status |
|---|---|---|
| 8.1 | Lebensmittel-Liste + Editor | offen |
| 8.2 | Rezeptliste + Erstellen | offen |
| 8.3 | Rezept-Editor | offen |
| 8.4 | Nährwertanzeige + Mengenrechner | offen |
| 8.5 | Rezeptdetail mit Steckplätzen | offen |
| 8.6 | Versionen + Vergleich | offen |
| 8.7 | Einstellungen, Export, Import | offen |
| 8.8 | App-Hülle verdrahten | offen |

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

- `test/recipe/recipe_step_test.dart` fehlt noch (RecipeStep selbst korrekt).
- `lib/unsalted_core.dart` (öffentliche Tür) ist noch leer — wird erst in
  Schritt 7.4 geschlossen.
- Zwei kosmetische Analyzer-`info`-Hinweise akzeptiert, bewusst nicht
  behoben: `use_super_parameters` in `core_database.dart`.

## Umgestellte Grundlage

Ab dem konsolidierten Bericht (`docs/spezifikation.md`) gilt dieser als
alleinige Spezifikation. Die DAO-Schicht aus Schritt 5.5 wurde entsprechend
Kapitel 16.8 umgebaut: `recipe_dao.dart`/`food_dao.dart` sind jetzt
abstrakte Interfaces, `drift_recipe_dao.dart`/`drift_food_dao.dart` die
konkreten Implementierungen (vorher: eine einzige konkrete Klasse je DAO).