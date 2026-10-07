# Bildschirme

Stand Teil 1.2 nach C27 (alle Bildschirme umgestellt). Pfade relativ zu
`packages/unsalted_core/lib/src/ui/`. Grundlage: Spezifikation Kapitel 22 und
28.4. Der Bildschirm hält Zustand, lädt Daten und löst Aktionen aus; jeder
Abschnitt ist ein zustandsloses Widget in eigener Datei unter
`<bereich>/sections/`, liest keine Provider und baut nur aus
Design-Komponenten und fachlichen Bausteinen. Abschnitte stehen hier in
Anzeigereihenfolge. **Umgestellt** nennt den Commit.

## 1 Rezeptliste — `recipe_list/recipe_list_screen.dart`

- **Zweck:** Einstieg; Rezepte finden und öffnen.
- **Daten:** `RecipeRepository.watchRecipes()`, ausgeblendet über `pendingRecipeDeletionsProvider`.
- **Aktionen:** Suche über Titel; Rezept öffnen (Detail); neues Rezept (FAB „Neues Rezept“, leerer Zustand); Wischen = Löschen mit 5 s „Rückgängig“.
- **Zustände:** laden (`AppLoading`) · Fehler + „Erneut versuchen“ (`AppErrorState`) · leer · keine Treffer · Liste.
- **Template:** `ListPageTemplate`.
- **Abschnitte:**
  1. `recipe_list/sections/recipe_list_search_section.dart` — Suchfeld (Slot `search`)
  2. `recipe_list/sections/recipe_list_empty_section.dart` — „Noch keine Rezepte.“ + „Erstes Rezept anlegen“ bzw. „Keine Treffer.“
  3. `recipe_list/sections/recipe_list_results_section.dart` — Liste mit Wischen-Löschen
- **Bausteine:** `recipe_list/recipe_card.dart` (`RecipeCard`).
- **Umgestellt:** C16.

## 2 Rezept erstellen — `recipe_editor/recipe_create_screen.dart`

- **Zweck:** Titel und Beschreibung eines neuen Rezepts.
- **Daten:** `RecipeRepository.createRecipe`.
- **Aktionen:** Speichern (FAB „Rezept speichern“, nur bei gültigem Titel 1–200 Zeichen) → Editor der neuen Draft-Version; Zurück mit Eingaben fragt nach (`showAppConfirmDialog`, `PopScope` im Bildschirm).
- **Zustände:** Eingabe · speichert · Speicherfehler (unter den Feldern).
- **Template:** `FormPageTemplate` mit `FormSections` und Hauptaktion.
- **Abschnitte:**
  1. `recipe_editor/sections/recipe_create_fields_section.dart` — Titel (mit Fehlertext) und Beschreibung
- **Umgestellt:** C17.

## 3 Rezept bearbeiten — `recipe_editor/recipe_editor_screen.dart`

- **Zweck:** Draft bearbeiten: Parameter, Zutaten, Schritte; einfrieren.
- **Daten:** `RecipeRepository.getVersion`, `saveDraft`, `snapshotVersion`, `createDraftFrom`; `NutritionService.preview`; `FoodRepository.getById`, `search` (Auswahldialog).
- **Aktionen:** Felder ändern; Zutaten/Schritte hinzufügen, entfernen, umsortieren; Lebensmittel verknüpfen; Speichern; Einfrieren; bei Snapshot „Kopieren“ als neuer Entwurf.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · nicht gefunden · eingefroren (schreibgeschützt) · bearbeitbar · Speicherfehler.
- **Template:** `FormPageTemplate` — bearbeitbar mit `header` (Vorschau), `messages` (Speicherfehler), `FormSections` und `bottomBar`.
- **Abschnitte (bearbeitbar):**
  1. `recipe_editor/sections/recipe_editor_preview_section.dart` — Gesamt-kcal live (Slot `header`)
  2. `recipe_editor/sections/recipe_editor_parameters_section.dart` — Portionen, Backverlust, Fertiggewicht-Override, Notizen
  3. `recipe_editor/sections/recipe_editor_ingredients_section.dart` — umsortierbare Zutatenzeilen, „Zutat hinzufügen“
  4. `recipe_editor/sections/recipe_editor_steps_section.dart` — umsortierbare Schritte mit Timer, „Schritt hinzufügen“
  5. `recipe_editor/sections/recipe_editor_actions_section.dart` — Einfrieren · Speichern (Slot `bottomBar`)
- **Abschnitt (eingefroren):** `recipe_editor/sections/recipe_editor_frozen_section.dart` — Hinweis + „Kopieren“, Zutaten und Schritte schreibgeschützt.
- **Bausteine:** `recipe_editor/ingredient_row.dart` (`IngredientRow`, `IngredientRowData`), `recipe_editor/step_row.dart` (`StepRow`, `StepRowData`, `timerInputText`), `recipe_editor/food_variant_picker_dialog.dart` (`FoodVariantPickerDialog`).
- **Umgestellt:** C25.

## 4 Rezeptdetail — `recipe_detail/recipe_detail_screen.dart`

- **Zweck:** Rezept lesen, Version wählen.
- **Daten:** `watchRecipe`, `watchVersions`, `getVersion`, `NutritionService.forVersion`; `modulesProvider` (Abschnitte, Aktionen).
- **Aktionen:** Version wählen; „Versionen“, „Bearbeiten“; Modul-Aktionen (Kopfleiste, Menü); „Rezept löschen“ (zurück zur Liste, 5 s „Rückgängig“).
- **Zustände:** Rezept lädt / Fehler / nicht gefunden (`AppPage` ohne Kopfleiste) · Versionen laden / Fehler / keine Version · erstes Laden · Versionswechsel (alter Inhalt bleibt, Ladebalken nach 300 ms, `_VersionLoader`) · Inhalt.
- **Template:** `DetailPageTemplate` mit `DetailSections` (einspaltig über `DetailLayout.standard`).
- **Abschnitte:**
  - Kopfleiste: `recipe_detail/sections/recipe_detail_actions_section.dart` — Versionen, Bearbeiten, Modul-Aktionen, Menü mit „Rezept löschen“
  - Haupt: `recipe_detail/version_switcher.dart` (`VersionSwitcher`) · `recipe_detail/sections/recipe_detail_description_section.dart` · `recipe_detail/sections/recipe_detail_nutrition_section.dart` (Kopf, Tabelle, Mengenrechner)
  - Neben: `recipe_detail/sections/recipe_detail_ingredients_section.dart` · `recipe_detail/sections/recipe_detail_steps_section.dart` (Timer-Chips) · `recipe_detail/sections/recipe_detail_extensions_section.dart` (`recipeDetailSections` nach `order`, im Bildschirm gebaut)
- **Umgestellt:** C23 (Test UI-58 für Menü-Aktionen).

## 5 Nährwertanzeige — Teil von 4

- **Bausteine:** `nutrition/nutrition_header.dart` (`NutritionHeader`: Fertiggewicht, Gesamt-kcal, kcal/Portion, Hinweis „nicht berechenbar“ als `AppSurface` warning), `nutrition/nutrition_table.dart` (`NutritionTable`: `AppKeyValueTable` in EU-Reihenfolge, Spalte 2 über `AppSelect`, `*`-Fußnoten als `AppText.caption`).
- **Daten:** `NutritionResult`; Rundung nur über `NutritionFormatter`.
- **Umgestellt:** C22.

## 6 Mengenrechner — Teil von 5

- **Baustein:** `nutrition/amount_calculator.dart` (`AmountCalculator`) — Gramm ↔ kcal, beidseitig gekoppelt; ungültige Eingabe markiert das Feld.
- **Umgestellt:** C22.

## 7 Versionen — `versions/version_list_screen.dart`

- **Zweck:** Verlauf der Versionen.
- **Daten:** `watchRecipe` (Master), `watchVersions`.
- **Aktionen:** Als Master markieren; Kopie als Entwurf; Vergleichen (`showAppChoiceDialog`); Löschen (`showAppConfirmDialog`); Fehler des Repositorys über `showAppMessage`.
- **Zustände:** laden · Fehler · leer („Keine Versionen vorhanden.“) · Liste.
- **Template:** `ListPageTemplate` ohne Suche und Hauptaktion.
- **Abschnitte:**
  1. `versions/sections/version_list_results_section.dart` — Liste der Versionen
- **Bausteine:** `versions/version_tile.dart` (`VersionTile`).
- **Umgestellt:** C20.

## 8 Versionsvergleich — `versions/version_compare_screen.dart`

- **Zweck:** zwei eingefrorene Versionen vergleichen, Änderungen übernehmen.
- **Daten:** `SnapshotService.exportVersion` (beide), `RecipeRepository.getVersion` (Zielzeilen), `RecipeDiff.between`; `RecipeRepository.applyChangesAsNewDraft`.
- **Aktionen:** „Als neuen Entwurf übernehmen“ mit exakt derselben Liste.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · keine Unterschiede · Änderungen · Fehler beim Übernehmen.
- **Template:** `DetailPageTemplate` mit `DetailSplit`.
- **Abschnitte:**
  1. `versions/sections/version_compare_columns_section.dart` — A | B (oben)
  2. `versions/sections/version_compare_changes_section.dart` — Änderungsliste oder „Keine Unterschiede.“ (unten)
  3. `versions/sections/version_compare_apply_section.dart` — Fehler + „Als neuen Entwurf übernehmen“ (Fußzeile)
- **Bausteine:** `versions/snapshot_column.dart` (`SnapshotColumn`), `versions/change_list.dart` (`ChangeList`), `versions/change_descriptions.dart` (`describeChanges`, unverändert).
- **Umgestellt:** C21.

## 9 Lebensmittel-Liste — `foods/food_list_screen.dart`

- **Zweck:** Lebensmittel suchen und verwalten.
- **Daten:** `FoodRepository.search`, ausgeblendet über `pendingFoodDeletionsProvider`.
- **Aktionen:** Suche; öffnen (Editor); neu (FAB „Neues Lebensmittel“, leerer Zustand); Wischen = Löschen mit 5 s „Rückgängig“.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · leer · Liste.
- **Template:** `ListPageTemplate`.
- **Abschnitte:**
  1. `foods/sections/food_list_search_section.dart` — Suchfeld (Slot `search`)
  2. `foods/sections/food_list_empty_section.dart` — „Keine Lebensmittel gefunden.“ + „Eigenes Produkt anlegen“
  3. `foods/sections/food_list_results_section.dart` — Liste mit Wischen-Löschen
- **Bausteine:** `foods/food_tile.dart` (`FoodTile`).
- **Umgestellt:** C15.

## 10 Lebensmittel bearbeiten — `foods/food_editor_screen.dart`, `foods/package_form.dart`

- **Zweck:** Verpackungsangaben anlegen oder ändern.
- **Daten:** `FoodRepository.getById`, `createVariant`, `updateVariant`, `softDeleteVariant`; `NutrientValidator.check`.
- **Aktionen:** Speichern (FAB „Lebensmittel speichern“, nicht bei Fehler); Löschen (Menü, 5 s „Rückgängig“); Zurück mit Änderungen fragt nach (10.0, `PopScope` im Bildschirm).
- **Zustände:** laden · Fehler + „Erneut versuchen“ · nicht gefunden · Eingabe mit Warnungen/Fehlern · speichert · Speicherfehler (`messages`).
- **Template:** `FormPageTemplate` mit Hauptaktion und `AppOverflowMenu`; Inhalt `PackageForm` (`FormSections`).
- **Abschnitte (in `PackageForm`):**
  1. `foods/sections/package_identity_section.dart` — Name, Marke, Barcode
  2. `foods/sections/package_measures_section.dart` — Dichte, Stückgewicht, Portionsgröße
  3. `foods/sections/package_nutrients_section.dart` — 8 Nährwerte (EU-Reihenfolge) + Natrium (`PackageNumberField`)
  4. `foods/sections/package_validation_section.dart` — Warnungen und Fehler (`AppSurface` warning/error, Keys `package_form_warning`/`package_form_error`)
- **Bausteine:** `foods/package_form.dart` (`PackageForm`: Zustand, Prüfung, Natrium-Umrechnung).
- **Umgestellt:** C24.

## 11 Export — `settings/export_screen.dart`

- **Zweck:** eingefrorene Version als JSON ausgeben.
- **Daten:** `watchRecipes`, `watchVersions` (nur Snapshots), `SnapshotService.exportVersionAsJsonString`.
- **Aktionen:** Rezept und Version wählen; Exportieren; In Zwischenablage kopieren (`showAppMessage`).
- **Zustände:** keine Auswahl · keine eingefrorene Version · Fehler · Ergebnis.
- **Template:** `FormPageTemplate` mit `FormSections.fixed`.
- **Abschnitte:**
  1. `settings/sections/export_selection_section.dart` — Rezept, Version (bekommt die Streams als Daten)
  2. „Exportieren“ und Fehler (Slot im Bildschirm, keine eigene Darstellung)
  3. `settings/sections/export_result_section.dart` — JSON (`AppCodeBlock`), „In Zwischenablage kopieren“
- **Umgestellt:** C18.

## 12 Import — `settings/import_screen.dart`

- **Zweck:** JSON einlesen.
- **Daten:** `SnapshotService.importJsonString`; Vorschau über `SnapshotCodec.decode`.
- **Aktionen:** Text einfügen; Importieren → Rezeptdetail.
- **Zustände:** leer · ungültiges JSON · Vorschau · Importfehler im Klartext.
- **Template:** `FormPageTemplate` mit `FormSections.fixed`.
- **Abschnitte:**
  1. `settings/sections/import_input_section.dart` — JSON einfügen (füllend)
  2. `settings/sections/import_preview_section.dart` — Titel, Zutatenzahl, Gesamt-kcal
  3. Fehler und „Importieren“ (Slot im Bildschirm, keine eigene Darstellung)
- **Umgestellt:** C19.

## 13 Einstellungen — `settings/settings_screen.dart`

- **Zweck:** Sammelseite.
- **Daten:** `modulesProvider` (`settingsEntries`).
- **Aktionen:** Export, Import, „Über unsalted“ (`showAppAboutDialog`), Modul-Einträge (mit dem Kontext des Bildschirms).
- **Template:** `ListPageTemplate` ohne Suche, Inhalt `AppItemList`.
- **Abschnitte:**
  1. `settings/sections/settings_core_entries_section.dart` — Export, Import, „Über unsalted“
  2. `settings/sections/settings_module_entries_section.dart` — Trennlinie + `settingsEntries` nach `order`
- **Umgestellt:** C14.

## Gemeinsam

- `shared/undoable_deletion.dart` — Fristen und Provider bleiben; Meldung über `AppMessenger` (C15), Wischen über `AppSwipeToDelete` (C16).
- `shared/unit_labels.dart` — Einheiten deutsch, Mengen mit Dezimalkomma (C27b); eingesetzt in Bildschirm 3 (Zutatenzeile, eingefrorene Ansicht), 4 (Zutaten) und 8 (Vergleichsspalten).
- App-Hülle `apps/unsalted_app/lib/main.dart` — Theme hell/dunkel aus `AppTheme` (folgt dem System), Navigation über `AppNavigationBar` (C26).
