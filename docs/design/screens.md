# Bildschirme

Stand Teil 1.2. Pfade relativ zu `packages/unsalted_core/lib/src/ui/`.
Grundlage: Spezifikation Kapitel 22 und 28.4. Der Bildschirm hält Zustand,
lädt Daten und löst Aktionen aus; jeder Abschnitt ist ein zustandsloses
Widget in eigener Datei unter `<bereich>/sections/` (Konvention:
`docs/design/plan.md`, Abschnitt c). **Umgestellt** nennt den Commit, mit
dem der Bildschirm auf Design-Komponenten umgestellt wurde.

## 1 Rezeptliste — `recipe_list/recipe_list_screen.dart`

- **Zweck:** Einstieg; Rezepte finden und öffnen.
- **Daten:** `RecipeRepository.watchRecipes()`, ausgeblendet über `pendingRecipeDeletionsProvider`.
- **Aktionen:** Suche über Titel; Rezept öffnen (Detail); neues Rezept (FAB, leerer Zustand); Wischen = Löschen mit 5 s „Rückgängig“.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · leer („Noch keine Rezepte.“ + „Erstes Rezept anlegen“) · keine Treffer · Liste.
- **Template:** `ListPageTemplate`.
- **Abschnitte:** `recipe_list_search_section.dart` · `recipe_list_empty_section.dart` · `recipe_list_results_section.dart`; Baustein `recipe_card.dart`.
- **Umgestellt:** C16.

## 2 Rezept erstellen — `recipe_editor/recipe_create_screen.dart`

- **Zweck:** Titel und Beschreibung eines neuen Rezepts.
- **Daten:** `RecipeRepository.createRecipe`.
- **Aktionen:** Speichern (FAB, nur bei gültigem Titel 1–200 Zeichen) → Editor der neuen Draft-Version; Zurück mit Eingaben fragt nach.
- **Zustände:** Eingabe · speichert · Speicherfehler.
- **Template:** `FormPageTemplate` mit Hauptaktion.
- **Abschnitte:** `recipe_create_fields_section.dart`.
- **Umgestellt:** C17.

## 3 Rezept bearbeiten — `recipe_editor/recipe_editor_screen.dart`

- **Zweck:** Draft bearbeiten: Parameter, Zutaten, Schritte; einfrieren.
- **Daten:** `RecipeRepository.getVersion`, `saveDraft`, `snapshotVersion`, `createDraftFrom`; `NutritionService.preview`; `FoodRepository.search` (Auswahldialog).
- **Aktionen:** Felder ändern, Zutaten/Schritte hinzufügen, entfernen, umsortieren; Lebensmittel verknüpfen; Speichern; Einfrieren; bei Snapshot „Kopieren“ als neuer Entwurf.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · nicht gefunden · eingefroren (schreibgeschützt) · bearbeitbar · Speicherfehler.
- **Template:** `FormPageTemplate` mit Vorschauleiste und Aktionsleiste.
- **Abschnitte:** `recipe_editor_preview_section.dart` · `recipe_editor_frozen_section.dart` · `recipe_editor_parameters_section.dart` · `recipe_editor_ingredients_section.dart` · `recipe_editor_steps_section.dart` · `recipe_editor_actions_section.dart`; Bausteine `ingredient_row.dart`, `step_row.dart`, `food_variant_picker_dialog.dart`.
- **Umgestellt:** offen (C25).

## 4 Rezeptdetail — `recipe_detail/recipe_detail_screen.dart`

- **Zweck:** Rezept lesen, Version wählen.
- **Daten:** `watchRecipe`, `watchVersions`, `getVersion`, `NutritionService.forVersion`; `modulesProvider` (Abschnitte, Aktionen).
- **Aktionen:** Version wählen; „Versionen“, „Bearbeiten“; Modul-Aktionen (Kopfleiste, Menü); „Rezept löschen“ (zurück zur Liste, 5 s „Rückgängig“).
- **Zustände:** erstes Laden · Versionswechsel (alter Inhalt bleibt, Ladebalken nach 300 ms) · Fehler · Inhalt.
- **Template:** `DetailPageTemplate` mit `DetailSections`.
- **Abschnitte:** `recipe_detail_actions_section.dart` · `version_switcher.dart` · `recipe_detail_description_section.dart` · `recipe_detail_nutrition_section.dart` · `recipe_detail_ingredients_section.dart` · `recipe_detail_steps_section.dart` · `recipe_detail_extensions_section.dart`.
- **Umgestellt:** C23.

## 5 Nährwertanzeige — Teil von 4

- **Bausteine:** `nutrition/nutrition_header.dart` (Fertiggewicht, Gesamt-kcal, kcal/Portion, Hinweis „nicht berechenbar“), `nutrition/nutrition_table.dart` (EU-Reihenfolge, Spalte 2 wählbar, `*`-Fußnoten).
- **Daten:** `NutritionResult`; Rundung nur über `NutritionFormatter`.
- **Umgestellt:** C22.

## 6 Mengenrechner — Teil von 5

- **Baustein:** `nutrition/amount_calculator.dart` — Gramm ↔ kcal, beidseitig gekoppelt; ungültige Eingabe markiert das Feld.
- **Umgestellt:** C22.

## 7 Versionen — `versions/version_list_screen.dart`

- **Zweck:** Verlauf der Versionen.
- **Daten:** `watchRecipe` (Master), `watchVersions`.
- **Aktionen:** Kopie als Entwurf; Vergleichen (Auswahldialog); Als Master markieren; Löschen (Rückfrage); Fehler als Meldung.
- **Zustände:** laden · Fehler · leer · Liste.
- **Template:** `ListPageTemplate` ohne Suche und Hauptaktion.
- **Abschnitte:** `version_list_results_section.dart`; Baustein `version_tile.dart`.
- **Umgestellt:** C20.

## 8 Versionsvergleich — `versions/version_compare_screen.dart`

- **Zweck:** zwei eingefrorene Versionen vergleichen, Änderungen übernehmen.
- **Daten:** `SnapshotService.exportVersion` (beide), `RecipeRepository.getVersion` (Zielzeilen), `RecipeDiff.between`; `RecipeRepository.applyChangesAsNewDraft`.
- **Aktionen:** „Als neuen Entwurf übernehmen“ mit exakt derselben Liste.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · keine Unterschiede · Änderungen · Fehler beim Übernehmen.
- **Template:** `DetailPageTemplate` mit `DetailSplit`.
- **Abschnitte:** `version_compare_columns_section.dart` · `version_compare_changes_section.dart` · `version_compare_apply_section.dart`; Bausteine `snapshot_column.dart`, `change_list.dart`, `change_descriptions.dart`.
- **Umgestellt:** C21.

## 9 Lebensmittel-Liste — `foods/food_list_screen.dart`

- **Zweck:** Lebensmittel suchen und verwalten.
- **Daten:** `FoodRepository.search`, ausgeblendet über `pendingFoodDeletionsProvider`.
- **Aktionen:** Suche; öffnen (Editor); neu (FAB, leerer Zustand); Wischen = Löschen mit 5 s „Rückgängig“.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · leer · Liste.
- **Template:** `ListPageTemplate`.
- **Abschnitte:** `food_list_search_section.dart` · `food_list_empty_section.dart` · `food_list_results_section.dart`; Baustein `food_tile.dart`.
- **Umgestellt:** C15.

## 10 Lebensmittel bearbeiten — `foods/food_editor_screen.dart`, `foods/package_form.dart`

- **Zweck:** Verpackungsangaben anlegen oder ändern.
- **Daten:** `FoodRepository.getById`, `createVariant`, `updateVariant`, `softDeleteVariant`; `NutrientValidator.check`.
- **Aktionen:** Speichern (FAB, nicht bei Fehler); Löschen (Menü, 5 s „Rückgängig“); Zurück mit Änderungen fragt nach (10.0).
- **Zustände:** laden · Fehler + „Erneut versuchen“ · nicht gefunden · Eingabe mit Warnungen/Fehlern · speichert · Speicherfehler.
- **Template:** `FormPageTemplate` mit Hauptaktion und Menü.
- **Abschnitte:** `package_identity_section.dart` · `package_measures_section.dart` · `package_nutrients_section.dart` · `package_validation_section.dart`.
- **Umgestellt:** C24.

## 11 Export — `settings/export_screen.dart`

- **Zweck:** eingefrorene Version als JSON ausgeben.
- **Daten:** `watchRecipes`, `watchVersions` (nur Snapshots), `SnapshotService.exportVersionAsJsonString`.
- **Aktionen:** Rezept und Version wählen; Exportieren; In Zwischenablage kopieren.
- **Zustände:** keine Auswahl · keine eingefrorene Version · Fehler · Ergebnis.
- **Template:** `FormPageTemplate` mit `FormSections.fixed`.
- **Abschnitte:** `export_selection_section.dart` · `export_result_section.dart`.
- **Umgestellt:** C18.

## 12 Import — `settings/import_screen.dart`

- **Zweck:** JSON einlesen.
- **Daten:** `SnapshotService.importJsonString`; Vorschau über `SnapshotCodec.decode`.
- **Aktionen:** Text einfügen; Importieren → Rezeptdetail.
- **Zustände:** leer · ungültiges JSON · Vorschau · Importfehler im Klartext.
- **Template:** `FormPageTemplate` mit `FormSections.fixed`.
- **Abschnitte:** `import_input_section.dart` · `import_preview_section.dart`.
- **Umgestellt:** C19.

## 13 Einstellungen — `settings/settings_screen.dart`

- **Zweck:** Sammelseite.
- **Daten:** `modulesProvider` (`settingsEntries`).
- **Aktionen:** Export, Import, „Über unsalted“, Modul-Einträge.
- **Template:** `ListPageTemplate` ohne Suche.
- **Abschnitte:** `settings_core_entries_section.dart` · `settings_module_entries_section.dart`.
- **Umgestellt:** C14.

## Gemeinsam

- `shared/undoable_deletion.dart` — Fristen und Provider bleiben; Meldung über `AppMessenger` (C15), Wischen über `AppSwipeToDelete`. **Umgestellt:** C15 (Meldung), C16 (Wischen).
- App-Hülle `apps/unsalted_app/lib/main.dart` — Theme hell/dunkel aus `AppTheme`, Navigation über `AppNavigationBar`. **Umgestellt:** offen (C26).
