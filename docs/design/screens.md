# Bildschirme

Stand Teil 1.3 (Gestaltung aus Figma; Teil 1.2 hat alle Bildschirme auf
Templates und Abschnitte umgestellt, C14–C27). Pfade relativ zu
`packages/unsalted_core/lib/src/ui/`. Grundlage: Spezifikation Kapitel 22 und
28.4. Der Bildschirm hält Zustand, lädt Daten und löst Aktionen aus; jeder
Abschnitt ist ein zustandsloses Widget in eigener Datei unter
`<bereich>/sections/`, liest keine Provider und baut nur aus
Design-Komponenten und fachlichen Bausteinen. Abschnitte stehen hier in
Anzeigereihenfolge. **Umgestellt** nennt den Commit aus Teil 1.2, **Figma**
den Abgleich mit der App-Datei `5eFqwnCRld6Ibu131541i8` (Handy, nur gelesen;
IDs in `docs/design/figma/figma-ids.json`): was übereinstimmt, was bewusst
abweicht (`docs/design/rueckmeldung-figma.md`, Abschnitt A) und was offen ist
(ebd., Abschnitt B). Golden-Bilder: GL-02 (`packages/unsalted_core/test/goldens/`).

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
- **Figma `1:421`:** übereinstimmend Kopfleiste mit Suche (folgt der Textgröße nicht), Einträge mit Haarlinie, Marker-Knopf, Navigation mit Auswahlbalken (ab 600 links), Leerstelle bei leerer Liste, „Keine Treffer.“ ohne Leerstelle (D16), Meldung mit Restzeitlinie (D09b). Offen: Fassungsmarke und Versionszahl je Rezept, Suchtreffer im Marker, Liste und Detail ab 840 (Teil 1.4). Golden `01_rezeptliste`.
- **Umgestellt:** C16.

## 2 Rezept erstellen — `recipe_editor/recipe_create_screen.dart`

- **Zweck:** Titel und Beschreibung eines neuen Rezepts.
- **Daten:** `RecipeRepository.createRecipe`.
- **Aktionen:** Speichern (FAB „Rezept speichern“, nur bei gültigem Titel 1–200 Zeichen) → Editor der neuen Draft-Version; Zurück mit Eingaben fragt nach (`showAppConfirmDialog`, `PopScope` im Bildschirm).
- **Zustände:** Eingabe · speichert · Speicherfehler (unter den Feldern).
- **Template:** `FormPageTemplate` mit `FormSections` und Hauptaktion.
- **Abschnitte:**
  1. `recipe_editor/sections/recipe_create_fields_section.dart` — Titel (mit Fehlertext) und Beschreibung
- **Figma `20:978`:** übereinstimmend Rahmen „Inhalt“, Beschriftungen über dem Feld, Abstand zwischen Titel und Beschreibung (D18b), Marker-Knopf. Kein Golden-Motiv.
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
  4. `recipe_editor/sections/recipe_editor_steps_section.dart` — umsortierbare Schritte mit Nummer und Timer, „Schritt hinzufügen“
  5. `recipe_editor/sections/recipe_editor_actions_section.dart` — Einfrieren · Speichern (Slot `bottomBar`)
- **Abschnitt (eingefroren):** `recipe_editor/sections/recipe_editor_frozen_section.dart` — Hinweis (`AppNotice`) + „Kopieren“, darunter Zutaten und Schritte schreibgeschützt im Zustandsrahmen (`AppFrame.fixed`) mit `VersionMark` samt Siegel (D16).
- **Bausteine:** `recipe_editor/ingredient_row.dart` (`IngredientRow`, `IngredientRowData`), `recipe_editor/step_row.dart` (`StepRow`, `StepRowData`, `timerInputText`), `recipe_editor/food_variant_picker_dialog.dart` (`FoodVariantPickerDialog`).
- **Figma `7:895` (Entwurf), `42:2010` (eingefroren):** übereinstimmend zweizeilige Zutatenzeile (Menge in `reflow-value-column`, Einheit und Notiz teilen den Rest), Abschnitte mit Linie, Abstand zwischen den Parameter-Feldern (D16b), Portionen, Backverlust und Fertiggewicht-Override als Zahlenfelder (D18b), Aktionsleiste (bei großer Schrift untereinander), eingefrorene Ansicht mit Hinweis und „Kopieren“. Seit Teil 1.4 B01 übereinstimmend mit `_Zeile/Zutat bearbeiten` und `_Zeile/Schritt bearbeiten` (Figma N1): Zeilenmenü „⋮“ mit „Nach oben“, „Nach unten“, „Entfernen“, Beschriftungen über den Feldern (auch „Einheit“), gestrichelte Unterstreichung unter dem Feld, Haarlinie je Zeile. Bewusst anders: Zustandsrahmen mit Siegel in der eingefrorenen Ansicht, Hinweistext nach Kapitel 22. Offen: Vorschau im gestrichelten Rahmen mit Kennzahlen, Portionen und Backverlust nebeneinander, Einheit als umrandetes Feld. Golden `03_rezept_bearbeiten`.
- **Umgestellt:** C25.

## 4 Rezeptdetail — `recipe_detail/recipe_detail_screen.dart`

- **Zweck:** Rezept lesen, Version wählen.
- **Daten:** `watchRecipe`, `watchVersions`, `getVersion`, `NutritionService.forVersion`; `modulesProvider` (Abschnitte, Aktionen).
- **Aktionen:** Version wählen; „Versionen“, „Bearbeiten“; Modul-Aktionen (Kopfleiste, Menü); „Rezept löschen“ (zurück zur Liste, 5 s „Rückgängig“).
- **Zustände:** Rezept lädt / Fehler / nicht gefunden (`AppPage` ohne Kopfleiste) · Versionen laden / Fehler / keine Version · erstes Laden · Versionswechsel (alter Inhalt bleibt, Ladebalken nach 300 ms, `_VersionLoader`) · Inhalt.
- **Template:** `DetailPageTemplate` mit `DetailSections` (zweispaltig ab `breakpoint-large` über `DetailLayout.standard`, D11).
- **Abschnitte:**
  - Kopfleiste: `recipe_detail/sections/recipe_detail_actions_section.dart` — Versionen, Bearbeiten, Modul-Aktionen, Menü mit „Rezept löschen“
  - Haupt: `recipe_detail/version_switcher.dart` (`VersionSwitcher`, Fassungsleiste) · `recipe_detail/sections/recipe_detail_description_section.dart` · `recipe_detail/sections/recipe_detail_nutrition_section.dart` (Kopf, Tabelle, Mengenrechner)
  - Neben: `recipe_detail/sections/recipe_detail_ingredients_section.dart` · `recipe_detail/sections/recipe_detail_steps_section.dart` (Nummer, Timer als Tag) · `recipe_detail/sections/recipe_detail_extensions_section.dart` (`recipeDetailSections` nach `order`, im Bildschirm gebaut)
- **Figma `1:607`, Tablet quer `148:4381`:** übereinstimmend Fassungsleiste mit Auswahlbalken (bricht bei großer Schrift um), Kennzahlenleiste, Warnhinweis mit Symbol, Deklaration, Mengenrechner, Schritte mit Nummer und Timer-Tag, zweispaltig ab 1200. Bewusst anders: „kcal/Portion“ statt „pro Portion“, erste Kopfspalte der Tabelle leer. Seit Teil 1.4 B02 übereinstimmend: Master in der Fassungsleiste mit Markerfläche. Offen: Titel als `display` im Inhalt mit leerer Kopfleiste, Zutaten als `Core/Ingredient Row`. Golden `04_rezeptdetail`.
- **Umgestellt:** C23 (Test UI-58 für Menü-Aktionen).

## 5 Nährwertanzeige — Teil von 4

- **Bausteine:** `nutrition/nutrition_header.dart` (`NutritionHeader`: Kennzahlenleiste `AppFigureRow` mit Fertiggewicht, Gesamt, kcal/Portion; Hinweis „nicht berechenbar“ als `AppNotice` Warnung, D15), `nutrition/nutrition_table.dart` (`NutritionTable`: Deklaration `AppKeyValueTable` in EU-Reihenfolge, „davon“ eingerückt, Kalorien hervorgehoben, Spalte 2 über `AppSelect`, `*`-Fußnoten als `AppText.caption`).
- **Daten:** `NutritionResult`; Rundung nur über `NutritionFormatter`.
- **Umgestellt:** C22.

## 6 Mengenrechner — Teil von 5

- **Baustein:** `nutrition/amount_calculator.dart` (`AmountCalculator`) — Gramm ↔ kcal, beidseitig gekoppelt; ungültige Eingabe markiert das Feld. Seit D15 zwei Zahlenfelder (Gramm mit Einheit im Feld) mit Tausch-Symbol dazwischen, bei großer Schrift das zweite Feld darunter.
- **Umgestellt:** C22.

## 7 Versionen — `versions/version_list_screen.dart`

- **Zweck:** Verlauf der Versionen.
- **Daten:** `watchRecipe` (Master), `watchVersions`.
- **Aktionen:** Als Master markieren; Kopie als Entwurf; Vergleichen (`showAppChoiceDialog`); Löschen (`showAppConfirmDialog`); Fehler des Repositorys über `showAppMessage`.
- **Zustände:** laden · Fehler · leer („Keine Versionen vorhanden.“) · Liste.
- **Template:** `ListPageTemplate` ohne Suche und Hauptaktion.
- **Abschnitte:**
  1. `versions/sections/version_list_results_section.dart` — Liste der Versionen
- **Bausteine:** `versions/version_tile.dart` (`VersionTile`: `VersionMark`, Zustand als Wort, Datum, „Master“ als Wort, Aktionen; D13), `versions/version_mark.dart` (`VersionMark`).
- **Figma `20:1042`:** übereinstimmend Fassungsmarken (Entwurf gestrichelt, eingefroren mit Kontur, Master mit Markerfläche). Bewusst anders: Figma zeigt eine vereinfachte Liste (Titel „Version n“, Datum, Marke rechts, keine Aktionen); der Code behält Aktionen und Tooltips (28.4.4) und zeigt Marke, Zustand als Wort, Datum und „Master“ als Wort. Kein Golden-Motiv.
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
- **Bausteine:** `versions/snapshot_column.dart` (`SnapshotColumn`), `versions/change_list.dart` (`ChangeList`: Abschnitte mit Linie, je Änderung `AppChangeText`, Semantik = bisheriger Text; D14), `versions/change_descriptions.dart` (`describeChanges` mit denselben Texten, dazu sichtbare Teile `ChangePart`).
- **Figma `3:595`:** übereinstimmend Änderungen in Abschnitten mit Linie, „alt durchgestrichen → neu markiert“ mit Pfeil-Symbol, „neu“/„entfernt“, Aktion füllt die Leiste; dazu oberer Bereich scrollt (D11) und bei großer Schrift A über B (D14). Bewusst anders: keine Metadaten „n Änderungen“. Offen: Kopfzeile mit beiden Marken statt Spalten A/B. Golden `08_versionsvergleich`.
- **Umgestellt:** C21.

## 9 Lebensmittel-Liste — `foods/food_list_screen.dart`

- **Zweck:** Lebensmittel suchen und verwalten.
- **Daten:** `FoodRepository.search`, ausgeblendet über `pendingFoodDeletionsProvider`.
- **Aktionen:** Suche; öffnen (Editor); neu (FAB „Neues Lebensmittel“, leerer Zustand); Wischen = Löschen mit 5 s „Rückgängig“.
- **Zustände:** laden · Fehler + „Erneut versuchen“ · leer · Liste.
- **Template:** `ListPageTemplate`.
- **Abschnitte:**
  1. `foods/sections/food_list_search_section.dart` — Suchfeld (Slot `search`)
  2. `foods/sections/food_list_empty_section.dart` — „Keine Lebensmittel gefunden.“ + „Eigenes Produkt anlegen“; mit Suchbegriff „Keine Treffer.“ ohne Aktion (B03)
  3. `foods/sections/food_list_results_section.dart` — Liste mit Wischen-Löschen
- **Bausteine:** `foods/food_tile.dart` (`FoodTile`).
- **Figma `20:1130`:** übereinstimmend wie Bildschirm 1 (Liste, Marker-Knopf, Leerstelle mit Aktion, Meldung). Seit Teil 1.4 B03 übereinstimmend mit `09 / Keine Treffer` (`218:3919`): mit Suchbegriff „Keine Treffer.“ mit Symbol, ohne Aktion und ohne Leerstelle. Offen: Liste und Detail ab 840 (Teil 1.4, Etappe 3). Kein Golden-Motiv.
- **Umgestellt:** C15.

## 10 Lebensmittel bearbeiten — `foods/food_editor_screen.dart`, `foods/package_form.dart`

- **Zweck:** Verpackungsangaben anlegen oder ändern.
- **Daten:** `FoodRepository.getById`, `createVariant`, `updateVariant`, `softDeleteVariant`; `NutrientValidator.check`.
- **Aktionen:** Speichern (FAB „Lebensmittel speichern“, nicht bei Fehler); Löschen (Menü, 5 s „Rückgängig“); Zurück mit Änderungen fragt nach (10.0, `PopScope` im Bildschirm).
- **Zustände:** laden · Fehler + „Erneut versuchen“ · nicht gefunden · Eingabe mit Warnungen/Fehlern · speichert · Speicherfehler (`messages`).
- **Template:** `FormPageTemplate` mit Hauptaktion und `AppOverflowMenu`; Inhalt `PackageForm` (`FormSections`).
- **Abschnitte (in `PackageForm`):**
  1. `foods/sections/package_identity_section.dart` — Name, Marke, Barcode (Abstand `space-m`; D18d)
  2. `foods/sections/package_measures_section.dart` — Dichte, Stückgewicht, Portionsgröße (Zahlenfelder mit Abstand `space-m`; D18b, D18c)
  3. `foods/sections/package_nutrients_section.dart` — 8 Nährwerte (EU-Reihenfolge) + Natrium (`PackageNumberField`), als Zahlenfelder im `AppGrid` (ab 600 zweispaltig; D16, D16c)
  4. `foods/sections/package_validation_section.dart` — Warnungen und Fehler (`AppNotice` Warnung/Fehler, Keys `package_form_warning`/`package_form_error`; D16)
- **Bausteine:** `foods/package_form.dart` (`PackageForm`: Zustand, Prüfung, Natrium-Umrechnung).
- **Figma `23:1492`:** übereinstimmend Beschriftungen über dem Feld, Abschnitte mit Linie, Warnung und Fehler als Hinweise mit Symbol, Nährwert- und Maßfelder als Zahlenfelder (rechtsbündig; D16c, D18b) mit Abstand zwischen den Feldern (D16, D18c), Nährwertfelder ab 600 zweispaltig. Golden `10_lebensmittel_bearbeiten`.
- **Umgestellt:** C24.

## 11 Export — `settings/export_screen.dart`

- **Zweck:** eingefrorene Version als JSON ausgeben.
- **Daten:** `watchRecipes`, `watchVersions` (nur Snapshots), `SnapshotService.exportVersionAsJsonString`.
- **Aktionen:** Rezept und Version wählen; Exportieren; In Zwischenablage kopieren (`showAppMessage`).
- **Zustände:** keine Auswahl · keine eingefrorene Version · Fehler · Ergebnis.
- **Template:** `FormPageTemplate` mit `FormSections.fixed`.
- **Abschnitte:**
  1. `settings/sections/export_selection_section.dart` — Rezept, Version (bekommt die Streams als Daten; Abstand `space-m`, D18d)
  2. „Exportieren“ und Fehler (Slot im Bildschirm, keine eigene Darstellung)
  3. `settings/sections/export_result_section.dart` — JSON (`AppCodeBlock`), „In Zwischenablage kopieren“
- **Figma `23:1818`:** übereinstimmend Rahmen „Inhalt“, Auswahl mit Beschriftung oben, JSON im Codeblock auf `surface-sunken`. Bewusst anders: Abstand zwischen den Auswahlfeldern `space-m` statt 16 (einheitlich, D18d). Kein Golden-Motiv.
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
- **Figma `23:1895`:** übereinstimmend Rahmen „Inhalt“, Eingabe füllend, Vorschau. Kein Golden-Motiv.
- **Umgestellt:** C19.

## 13 Einstellungen — `settings/settings_screen.dart`

- **Zweck:** Sammelseite.
- **Daten:** `modulesProvider` (`settingsEntries`).
- **Aktionen:** Export, Import, „Über unsalted“ (`showAppAboutDialog`), Modul-Einträge (mit dem Kontext des Bildschirms).
- **Template:** `ListPageTemplate` ohne Suche, Inhalt `AppItemList`.
- **Abschnitte:**
  1. `settings/sections/settings_core_entries_section.dart` — Export, Import, „Über unsalted“
  2. `settings/sections/settings_module_entries_section.dart` — Trennlinie + `settingsEntries` nach `order`
- **Figma `20:1231`:** übereinstimmend Liste ohne Seitenrand mit Haarlinien, Navigation mit Auswahlbalken. Kein Golden-Motiv.
- **Umgestellt:** C14.

## Gemeinsam

- `shared/undoable_deletion.dart` — Fristen und Provider bleiben; Meldung über `AppMessenger` (C15), Wischen über `AppSwipeToDelete` (C16).
- `shared/unit_labels.dart` — Einheiten deutsch, Mengen mit Dezimalkomma (C27b); eingesetzt in Bildschirm 3 (Zutatenzeile, eingefrorene Ansicht), 4 (Zutaten) und 8 (Vergleichsspalten).
- App-Hülle `apps/unsalted_app/lib/main.dart` — Theme hell/dunkel aus `AppTheme` (folgt dem System), Navigation über `AppNavigationBar` in `AppPage.navigation`: unter 600 unten, ab 600 als seitliche Leiste links (C26, D17); Systemtexte deutsch (D17b).
- Große Schrift (28.10.11): Kopfleiste und Navigation folgen der Textgröße nicht; Inhalte wachsen bis 200 % und brechen um (Tabelle, Kennzahlen, Mengenrechner, Zutatenzeile, Aktionsleiste, Vergleich, Hinweis, Meldung).
