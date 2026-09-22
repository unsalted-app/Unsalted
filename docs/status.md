# Status

Diese Datei wird nach **jedem** Schritt aktualisiert (siehe PROJECT.md, Checkliste
und Regel 9). Status ist immer eines von: `offen` · `in Arbeit` · `fertig`.

## Phase 0 — Projektgrundlage
| Schritt | Beschreibung | Status |
|---|---|---|
| 0.1 | Ordner, Git, PROJECT.md | fertig |
| 0.2 | Pakete anlegen | fertig |
| 0.3 | Abhängigkeiten | offen |

## Phase 1 — Architekturtests
| Schritt | Beschreibung | Status |
|---|---|---|
| 1.1 | Prüfwerkzeug (`check_architecture.dart`) | offen |
| 1.2 | Architekturtests AT-01 bis AT-11 | offen |

## Phase 2 — Rechenkern (reines Dart)
| Schritt | Beschreibung | Status |
|---|---|---|
| 2.1 | DecimalMath | offen |
| 2.2 | UnitCatalog | offen |
| 2.3 | NutrientSet | offen |
| 2.4 | NutritionResult | offen |
| 2.5 | NutritionEngine | offen |
| 2.6 | Validator | offen |
| 2.7 | Formatter | offen |

## Phase 3 — Fachmodelle
| Schritt | Beschreibung | Status |
|---|---|---|
| 3.1 | Entitäten (Recipe, RecipeVersion, RecipeIngredient, RecipeStep, FoodVariant) | offen |
| 3.2 | RecipeChange | offen |
| 3.3 | Fehlerklassen | offen |

## Phase 4 — Snapshot-Format
| Schritt | Beschreibung | Status |
|---|---|---|
| 4.1 | RecipeSnapshotV1 | offen |
| 4.2 | SnapshotCodec (⚠️ ab hier Format eingefroren) | offen |
| 4.3 | RecipeDiff | offen |

## Phase 5 — Drift-Datenbank
| Schritt | Beschreibung | Status |
|---|---|---|
| 5.1 | DecimalConverter | offen |
| 5.2 | Tabellen | offen |
| 5.3 | CoreDatabase + Codegen | offen |
| 5.4 | Schema einfrieren (⚠️ ab hier Schema eingefroren) | offen |
| 5.5 | DAOs und Mapper | offen |

## Phase 6 — Repositories
| Schritt | Beschreibung | Status |
|---|---|---|
| 6.1 | Verträge (⚠️ ab Abnahme eingefroren) | offen |
| 6.2 | DomainEventBus | offen |
| 6.3 | DriftRecipeRepository | offen |
| 6.4 | DriftFoodRepository | offen |

## Phase 7 — Nährwerte und Austausch
| Schritt | Beschreibung | Status |
|---|---|---|
| 7.1 | DriftNutritionService | offen |
| 7.2 | DriftSnapshotService | offen |

## Phase 8 — Erweiterungssystem
| Schritt | Beschreibung | Status |
|---|---|---|
| 8.1 | Modultypen | offen |
| 8.2 | CoreModule | offen |
| 8.3 | Provider | offen |
| 8.4 | Öffentliche Tür schließen | offen |

## Phase 9 — Oberfläche
| Schritt | Beschreibung | Status |
|---|---|---|
| 9.1 | Lebensmittel-Liste + Editor | offen |
| 9.2 | Rezeptliste + Erstellen | offen |
| 9.3 | Rezept-Editor | offen |
| 9.4 | Nährwertanzeige + Mengenrechner | offen |
| 9.5 | Rezeptdetail mit Steckplätzen | offen |
| 9.6 | Versionen + Vergleich | offen |
| 9.7 | Einstellungen, Export, Import | offen |
| 9.8 | App-Hülle verdrahten | offen |

## Phase 10 — Integration und Risiko
| Schritt | Beschreibung | Status |
|---|---|---|
| 10.1 | Integrationstests IT-01 bis IT-06 | offen |
| 10.2 | Manueller Durchlauf | offen |
| 10.3 | Spike: mehrere Drift-Klassen auf einer Sync-DB | offen |

## Phase 11 — Freeze
| Schritt | Beschreibung | Status |
|---|---|---|
| 11.1 | Abnahmeliste (Kapitel 21) vollständig abhaken | offen |
| 11.2 | Öffentliche API dokumentieren | offen |
| 11.3 | Tag `part1-v1.0.0` | offen |