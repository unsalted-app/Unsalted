# Teil 1.2 – Design-System (Grundlage): Plan

Phase A · Stand 2026-10-07 · Branch `design-system` (von `main` @ `25b09d9`) ·
**wartet auf Freigabe**

Dieses Dokument ist nur der Plan, Code gibt es noch keinen. Phase B beginnt
erst nach Freigabe und läuft Commit für Commit nach Abschnitt (e). Offene
Fragen haben Nummern (F1 …), damit sie sich einzeln beantworten lassen.

---

## 0 Ziel und Leitplanken

- **Ziel:** Das Aussehen liegt ausschließlich in `packages/unsalted_design`.
  Bildschirme in `unsalted_core/lib/src/ui` legen nur fest, *was* angezeigt
  wird und *was* eine Aktion tut.
- **Ebenen (Atomic Design):** Tokens → Theme → Layout und Komponenten (Atome,
  Moleküle) → Templates (Seitenraster mit Slots) — alles im Design-Paket.
  In Core: fachliche Bausteine (Organismen, z. B. `NutritionTable`) →
  Abschnitte → Bildschirme.
- **Neutral:** Die Platzhalter-Tokens sind genau die Werte, die `ThemeData()`
  in Flutter 3.47.5 heute erzeugt (Material-3-Standard). Die Umstellung
  ändert das Aussehen der App nicht sichtbar. Das eigentliche Design kommt
  später aus Figma und ändert nur Tokens und Komponenten.
- **Ohne Funktionsänderung:** Alle bestehenden Tests in Core (380) und App (1)
  bleiben während der Umstellung **unverändert** grün. Das ist der Nachweis.
- **Unberührt:** `contracts/`, `data/`, `recipe/`, `nutrition/`, `food/`,
  `module/`, `providers/`, Datenbankschema, Snapshot-Format, Routen und die
  öffentlichen Konstruktoren der Bildschirme (`CoreModule.routes` bindet sie
  unverändert ein).
- **design/1.1** wird weder gemergt noch gelöscht. Übernommen werden nur
  neutrale Dateien, als neue Dateien von Hand (kein Cherry-Pick):

| Quelle auf `design/1.1` | Ziel | Anpassung |
|---|---|---|
| `ui/shared/motion.dart` | Design `tokens/motion_tokens.dart` | Dauer als Token, `AppMotion.durationOf(context)` |
| `ui/shared/notice.dart` | Design `components/feedback/app_notice.dart` | Radius/Abstände aus Tokens, Symbole aus `AppIcons` |
| `ui/shared/empty_state.dart` | Design `components/feedback/app_empty_state.dart` | Abstände aus Tokens |
| `ui/shared/skeleton.dart` | Design `components/feedback/app_skeleton.dart` | auf `AppGrid` umgestellt; vorerst ohne Verwendung (F3) |
| `ui/shared/card_layout.dart` | Design `layout/app_grid.dart`, `layout/responsive.dart` | Grenzen aus `AppBreakpoints` |
| `ui/shared/unit_labels.dart` | Core `ui/shared/unit_labels.dart` | bleibt in Core (braucht `UnitCatalog`); Einsatz nur nach F3 |
| `test/architecture/at13_no_fixed_colors_test.dart` | Core AT-13 | mit Übergangsliste (d2) |
| App `test/theme/contrast_test.dart` | Design DS-05 | prüft Tokens statt App-Farben |

Nicht übernommen: Markenfarben, Inter-Schrift, schwebende Navigation,
Kartenlisten, Hero, Umbau des Rezeptdetails, Vorschaubilder.

---

## (a) Ordnerbaum

`NEU` = neue Datei, `ÄNDERN` = bestehende Datei, `(d1)` = nur nach Freigabe
der UI-Konfiguration.

```text
unsalted/
├─ architecture.yaml                     ÄNDERN  unsalted_design (Rang 0), unsalted_widgetbook (Rang 99), Design-Importregeln
├─ tool/check_architecture.dart          ÄNDERN  Design-Paket nur Flutter; Design-Import in Core nur in src/ui/
├─ .github/workflows/ci.yml              ÄNDERN  analyze + test für unsalted_design und unsalted_widgetbook
├─ docs/
│  ├─ spezifikation.md                   ÄNDERN  Kapitel 28.9 „Teil 1.2 – Design-System“
│  ├─ status.md, decisions.md            ÄNDERN  je Commit
│  └─ design/
│     ├─ plan.md                         dieses Dokument
│     ├─ design_system.md                NEU  Ebenen, Regeln, Benennung = Figma-Namen, Ablauf Figma → Code
│     ├─ components.md                   NEU  Komponente | Figma-Name | Datei | Status
│     └─ screens.md                      NEU  je Bildschirm: Zweck, Daten, Aktionen, Zustände, Abschnitte mit Datei
├─ packages/
│  ├─ unsalted_design/                   NEU  Rang 0, Abhängigkeit nur flutter
│  │  ├─ pubspec.yaml                    version 0.1.0 (design-v0.1.0)
│  │  ├─ analysis_options.yaml
│  │  ├─ README.md
│  │  ├─ CHANGELOG.md
│  │  ├─ lib/
│  │  │  ├─ unsalted_design.dart         öffentliche Tür
│  │  │  └─ src/
│  │  │     ├─ tokens/
│  │  │     │  ├─ color_tokens.dart       AppColorTokens.light / .dark (Material-3-Rollen)
│  │  │     │  ├─ typography_tokens.dart  AppTypography (15 Typo-Rollen, ohne Farbe)
│  │  │     │  ├─ spacing_tokens.dart     AppSpacing
│  │  │     │  ├─ radius_tokens.dart      AppRadius
│  │  │     │  ├─ elevation_tokens.dart   AppElevation (Höhen, Schatten)
│  │  │     │  ├─ motion_tokens.dart      AppMotion (+ „Bewegung reduzieren“)
│  │  │     │  └─ breakpoint_tokens.dart  AppBreakpoints
│  │  │     ├─ theme/
│  │  │     │  ├─ app_theme.dart          AppTheme.light() / .dark(): ThemeData nur aus Tokens
│  │  │     │  ├─ component_themes.dart   Komponenten-Themes, nur soweit Tokens sie festlegen
│  │  │     │  └─ app_tokens.dart         ThemeExtension AppTokens, AppTokens.of(context) mit Rückfall auf Standardwerte
│  │  │     ├─ layout/
│  │  │     │  ├─ app_page.dart
│  │  │     │  ├─ app_section.dart
│  │  │     │  ├─ app_stack.dart          AppStack + AppGap
│  │  │     │  ├─ app_grid.dart
│  │  │     │  └─ responsive.dart         AppWindowSize, Responsive.of, ResponsiveBuilder
│  │  │     ├─ components/
│  │  │     │  ├─ buttons/     app_button.dart, app_icon_button.dart, app_fab.dart
│  │  │     │  ├─ icons/       app_icon.dart, app_icons.dart
│  │  │     │  ├─ text/        app_text.dart                      (Ergänzung zur vorgegebenen Ordnerliste)
│  │  │     │  ├─ cards/       app_card.dart
│  │  │     │  ├─ surfaces/    app_surface.dart, app_divider.dart
│  │  │     │  ├─ inputs/      app_text_field.dart, app_search_field.dart, app_select.dart
│  │  │     │  ├─ lists/       app_list_item.dart, app_swipe_to_delete.dart, app_reorderable_list.dart
│  │  │     │  ├─ chips/       app_choice_chip.dart, app_chip.dart
│  │  │     │  ├─ feedback/    app_notice.dart, app_empty_state.dart, app_error_state.dart, app_loading.dart,
│  │  │     │  │               app_progress_bar.dart, app_skeleton.dart, app_snackbar.dart, app_dialog.dart
│  │  │     │  ├─ navigation/  app_top_bar.dart, app_overflow_menu.dart, app_navigation_bar.dart,
│  │  │     │  │               app_bottom_action_bar.dart
│  │  │     │  ├─ media/       (leer bis Teil 4, F5)
│  │  │     │  └─ data/        app_key_value_table.dart, app_code_block.dart
│  │  │     └─ templates/
│  │  │        ├─ list_page_template.dart
│  │  │        ├─ detail_page_template.dart
│  │  │        └─ form_page_template.dart
│  │  └─ test/
│  │     ├─ architecture/   ds01_only_flutter_test.dart, ds02_colors_only_in_tokens_test.dart,
│  │     │                  ds03_public_api_test.dart + public_api_golden.txt, ds06_no_domain_terms_test.dart
│  │     ├─ tokens/         ds04_tokens_complete_test.dart, ds05_contrast_test.dart
│  │     ├─ theme/          ds07_neutral_theme_test.dart
│  │     ├─ layout/, components/<gruppe>/, templates/   je Quelldatei ein Widget-Test
│  └─ unsalted_core/
│     ├─ pubspec.yaml                    ÄNDERN  + unsalted_design (path)
│     ├─ lib/unsalted_core.dart          ÄNDERN (d1)  + CoreUiOptions, coreUiOptionsProvider
│     ├─ lib/src/ui/
│     │  ├─ config/core_ui_options.dart              NEU (d1)
│     │  ├─ shared/
│     │  │  ├─ undoable_deletion.dart                Logik unverändert; SnackBar/Wischen über Design
│     │  │  └─ unit_labels.dart                      NEU, aus design/1.1 (F3)
│     │  ├─ recipe_list/
│     │  │  ├─ recipe_list_screen.dart
│     │  │  ├─ recipe_card.dart                      NEU
│     │  │  └─ sections/  recipe_list_search_section.dart, recipe_list_empty_section.dart,
│     │  │                recipe_list_results_section.dart
│     │  ├─ recipe_editor/
│     │  │  ├─ recipe_create_screen.dart
│     │  │  ├─ recipe_editor_screen.dart
│     │  │  ├─ ingredient_row.dart
│     │  │  ├─ step_row.dart                         NEU, aus recipe_editor_screen.dart herausgelöst
│     │  │  ├─ food_variant_picker_dialog.dart       NEU, aus ingredient_row.dart herausgelöst
│     │  │  └─ sections/  recipe_create_fields_section.dart,
│     │  │                recipe_editor_preview_section.dart, recipe_editor_frozen_section.dart,
│     │  │                recipe_editor_parameters_section.dart, recipe_editor_ingredients_section.dart,
│     │  │                recipe_editor_steps_section.dart, recipe_editor_actions_section.dart
│     │  ├─ recipe_detail/
│     │  │  ├─ recipe_detail_screen.dart
│     │  │  ├─ version_switcher.dart
│     │  │  └─ sections/  recipe_detail_actions_section.dart, recipe_detail_description_section.dart,
│     │  │                recipe_detail_nutrition_section.dart, recipe_detail_ingredients_section.dart,
│     │  │                recipe_detail_steps_section.dart, recipe_detail_extensions_section.dart
│     │  ├─ nutrition/  nutrition_header.dart, nutrition_table.dart, amount_calculator.dart
│     │  ├─ versions/
│     │  │  ├─ version_list_screen.dart
│     │  │  ├─ version_tile.dart                     NEU
│     │  │  ├─ version_compare_screen.dart
│     │  │  ├─ snapshot_column.dart                  NEU, herausgelöst
│     │  │  ├─ change_list.dart                      NEU, herausgelöst
│     │  │  ├─ change_descriptions.dart              unverändert
│     │  │  └─ sections/  version_list_results_section.dart, version_compare_columns_section.dart,
│     │  │                version_compare_changes_section.dart, version_compare_apply_section.dart
│     │  ├─ foods/
│     │  │  ├─ food_list_screen.dart
│     │  │  ├─ food_tile.dart                        NEU
│     │  │  ├─ food_editor_screen.dart
│     │  │  ├─ package_form.dart
│     │  │  └─ sections/  food_list_search_section.dart, food_list_empty_section.dart,
│     │  │                food_list_results_section.dart, package_identity_section.dart,
│     │  │                package_measures_section.dart, package_nutrients_section.dart,
│     │  │                package_validation_section.dart
│     │  └─ settings/
│     │     ├─ settings_screen.dart, export_screen.dart, import_screen.dart
│     │     └─ sections/  settings_core_entries_section.dart, settings_module_entries_section.dart,
│     │                   export_selection_section.dart, export_result_section.dart,
│     │                   import_input_section.dart, import_preview_section.dart
│     └─ test/architecture/
│        ├─ at01_no_upper_imports_test.dart          ÄNDERN  nur Kopfkommentar
│        ├─ at13_no_fixed_colors_test.dart           NEU
│        ├─ at14_design_components_only_test.dart    NEU
│        └─ at15_design_only_in_ui_test.dart         NEU
└─ apps/
   ├─ unsalted_app/
   │  ├─ pubspec.yaml                    ÄNDERN  + unsalted_design (path)
   │  ├─ lib/main.dart                   ÄNDERN  theme/darkTheme aus AppTheme, Navigationsleiste aus AppNavigationBar
   │  └─ lib/config/ui_options.dart      NEU (d1)  einzige Stelle mit den Schalterwerten
   └─ unsalted_widgetbook/               NEU  Komponenten-Katalog
      ├─ pubspec.yaml                    flutter, widgetbook, unsalted_design (path)
      ├─ lib/main.dart                   Widgetbook.material, Addons: Theme hell/dunkel, Viewport Handy/Tablet
      ├─ lib/catalog/                    tokens.dart, layout.dart, buttons.dart, …, templates.dart (je Ordner eine Datei)
      └─ test/catalog_smoke_test.dart    WB-01
```

---

## (b) Komponentenliste

### Tokens (Figma-Variablen)

Regel: Der Dart-Name ist der Figma-Pfad ohne Gruppe in camelCase
(`color/surface-container-high` → `AppColorTokens.surfaceContainerHigh`).
Die Platzhalterwerte decken alle heute benutzten Abstände ab (4, 8, 12, 16,
32), deshalb geht die Umstellung 1:1.

| Gruppe | Figma-Variablen | Dart | Platzhalter |
|---|---|---|---|
| Farbe (Modi `light`, `dark`) | `color/primary`, `color/on-primary`, `color/surface`, `color/surface-container-low` … `-highest`, `color/error`, `color/error-container`, `color/tertiary-container` … alle Material-3-Rollen | `AppColorTokens.light.primary` | Werte von `ThemeData()` hell/dunkel |
| Typografie | `type/display-large` … `type/label-small` (15 Rollen) | `AppTypography.titleMedium` | Material-3-Typskala, Systemschrift |
| Abstand | `space/xxs` 2, `xs` 4, `s` 8, `m` 12, `l` 16, `xl` 24, `xxl` 32 | `AppSpacing.l` | wie links |
| Radius | `radius/none` 0, `xs` 4, `s` 8, `m` 12, `l` 16, `xl` 28, `full` | `AppRadius.m` | wie links |
| Höhe/Schatten | `elevation/level0` … `level5` (0, 1, 3, 6, 8, 12) | `AppElevation.level1` | Material 3 |
| Bewegung | `motion/duration/short` 150, `medium` 250, `long` 400; `motion/easing/standard`, `emphasized` | `AppMotion.medium` | wie links; 0 bei „Bewegung reduzieren“ |
| Breakpoints | `breakpoint/medium` 600, `expanded` 840, `large` 1200 | `AppBreakpoints.medium` | Material-Fenstergrößen |

### Theme

| Klasse | Datei | Aufgabe |
|---|---|---|
| `AppTheme` | `theme/app_theme.dart` | `light()`/`dark()` bauen `ThemeData` ausschließlich aus Tokens |
| `AppTokens` | `theme/app_tokens.dart` | Abstände, Radien, Bewegung im Theme; `of(context)` fällt ohne Erweiterung auf Standardwerte zurück (Core-Tests pumpen `MaterialApp` ohne Theme) |
| — | `theme/component_themes.dart` | Komponenten-Themes, nur soweit Tokens sie festlegen (neutral: fast leer) |

### Layout, Komponenten, Templates

Pfade relativ zu `packages/unsalted_design/lib/src/`. „Ersetzt“ nennt, was
heute in Core-Bildschirmen steht; die Komponente baut **vorerst genau dieses
Material-Widget** (siehe Risiko R1).

| Komponente | Datei | Kurzbeschreibung | Figma-Name | ersetzt |
|---|---|---|---|---|
| `AppPage` | `layout/app_page.dart` | Seitenrahmen: Kopfleiste, Inhalt, Hauptaktion, Fußleiste | `Layout/Page` | `Scaffold` |
| `AppSection` | `layout/app_section.dart` | Abschnitt mit optionaler Überschrift | `Layout/Section` | fetter `Text` + `Divider` |
| `AppStack`, `AppGap` | `layout/app_stack.dart` | Anordnung mit Token-Abstand; einzelner Abstand | `Layout/Stack`, `Layout/Gap` | `Column` + `SizedBox`, `Padding` |
| `AppGrid` | `layout/app_grid.dart` | 1–3 Spalten nach Fenstergröße | `Layout/Grid` | — (aus design/1.1) |
| `AppWindowSize`, `Responsive` | `layout/responsive.dart` | Fenstergröße kompakt/mittel/erweitert, Builder | Variablen `breakpoint/*` | `MediaQuery`-Abfragen |
| `AppButton` (`.primary`, `.secondary`, `.tertiary`) | `components/buttons/app_button.dart` | Beschriftung, optional Symbol, deaktiviert, lädt | `Button/Primary`, `Button/Secondary`, `Button/Tertiary` | `ElevatedButton`, `OutlinedButton`, `TextButton(.icon)` |
| `AppIconButton` | `components/buttons/app_icon_button.dart` | Symbol mit Pflicht-Tooltip | `Button/Icon` | `IconButton` |
| `AppFab` | `components/buttons/app_fab.dart` | Hauptaktion mit Ladezustand | `Button/FAB` | `FloatingActionButton` (+ Ladekreis in `Colors.white`) |
| `AppIcon` | `components/icons/app_icon.dart` | Symbol in Token-Größe und -Ton | `Icon` | `Icon` |
| `AppIcons` | `components/icons/app_icons.dart` | fachneutrale Symbolnamen (add, search, edit, history, delete, copy, compare, star, dragHandle, info, warning, error, upload, download, check, empty …) | `Icon/<name>` | `Icons.*` |
| `AppText` (`.title`, `.body`, `.label`, `.caption`; Ton normal/muted/error) | `components/text/app_text.dart` | Text in Typo-Rolle | Textstile `Text/<rolle>` | `Text(style: TextStyle(…))` |
| `AppCard` | `components/cards/app_card.dart` | Fläche mit Inhalt, optional antippbar | `Card` | `Card` |
| `AppSurface` (Ton low/high/info/warning/error) | `components/surfaces/app_surface.dart` | getönte Fläche mit Innenabstand | `Surface/<ton>` | `Container(color: Colors.…)` |
| `AppDivider` | `components/surfaces/app_divider.dart` | waagrecht/senkrecht | `Divider` | `Divider`, `VerticalDivider` |
| `AppTextField` | `components/inputs/app_text_field.dart` | Label, Hinweis, Hilfe-/Fehlertext, Präfix/Suffix, mehrzeilig, Zahl, gesperrt; Controller oder Startwert | `Input/Text Field` | `TextField`, `TextFormField` |
| `AppSearchField` | `components/inputs/app_search_field.dart` | Suchfeld mit Symbol | `Input/Search` | `TextField` + `Icons.search` |
| `AppSelect<T>` | `components/inputs/app_select.dart` | Auswahlliste, mit oder ohne Label | `Input/Select` | `DropdownButton`, `DropdownButtonFormField` |
| `AppListItem` | `components/lists/app_list_item.dart` | Titel, Untertitel, vorn/hinten, antippbar, kompakt | `List/Item` | `ListTile` |
| `AppSwipeToDelete` | `components/lists/app_swipe_to_delete.dart` | Wischen nach links mit Lösch-Hintergrund | `List/Swipe to Delete` | `Dismissible` + `DeleteSwipeBackground` |
| `AppReorderableList` | `components/lists/app_reorderable_list.dart` | Umsortieren per Ziehgriff, eingebettet | `List/Reorderable` | `ReorderableListView` |
| `AppChoiceChip` | `components/chips/app_choice_chip.dart` | Auswahl-Chip | `Chip/Choice` | `ChoiceChip` |
| `AppChip` | `components/chips/app_chip.dart` | Info-Chip (z. B. Timer) | `Chip/Info` | `Chip` |
| `AppNotice` (error/warning/info) | `components/feedback/app_notice.dart` | Hinweiszeile, immer mit Symbol, optional Aktion | `Feedback/Notice` | farbige `Container` |
| `AppEmptyState` | `components/feedback/app_empty_state.dart` | Symbol, Satz, Hauptaktion (Kap. 22) | `Feedback/Empty State` | `Column(Icon, Text, ElevatedButton)` |
| `AppErrorState` | `components/feedback/app_error_state.dart` | Klartext, optional „Erneut versuchen“ (Kap. 22) | `Feedback/Error State` | `Column(Text, TextButton)` |
| `AppLoading` | `components/feedback/app_loading.dart` | zentrierter Ladekreis (Kap. 22); klein für Buttons | `Feedback/Loading` | `CircularProgressIndicator` |
| `AppProgressBar` | `components/feedback/app_progress_bar.dart` | Ladebalken | `Feedback/Progress Bar` | `LinearProgressIndicator` |
| `AppSkeleton` | `components/feedback/app_skeleton.dart` | Platzhalter beim Laden | `Feedback/Skeleton` | — (F3) |
| `showAppMessage`, `showAppUndoSnackbar` | `components/feedback/app_snackbar.dart` | Meldung; mit „Rückgängig“ und Frist (`persist: false`) | `Feedback/Snackbar` | `SnackBar`, `SnackBarAction` |
| `AppDialog`, `showAppConfirmDialog`, `showAppChoiceDialog`, `showAppAboutDialog` | `components/feedback/app_dialog.dart` | Rückfrage, Auswahl, freier Inhalt, „Über“ | `Feedback/Dialog` | `showDialog` + `AlertDialog`/`SimpleDialog`, `showAboutDialog` |
| `AppTopBar` | `components/navigation/app_top_bar.dart` | Titel, Aktionen, unterer Slot (Suche, Ladebalken) | `Navigation/Top Bar` | `AppBar` |
| `AppOverflowMenu` | `components/navigation/app_overflow_menu.dart` | Menü „⋮“: Einträge mit Text, aktiv, Aktion | `Navigation/Overflow Menu` | `PopupMenuButton<VoidCallback>` |
| `AppNavigationBar` | `components/navigation/app_navigation_bar.dart` | Hauptnavigation der App-Hülle | `Navigation/Navigation Bar` | `NavigationBar` |
| `AppBottomActionBar` | `components/navigation/app_bottom_action_bar.dart` | Fußleiste mit 1–2 Buttons | `Navigation/Bottom Action Bar` | `SafeArea(Padding(Row(…)))` |
| `AppKeyValueTable` | `components/data/app_key_value_table.dart` | Bezeichnung + 1–n Wertspalten, Kopfzeile mit Slot, Fußnoten | `Data/Key Value Table` | `Table`, `TableRow` |
| `AppCodeBlock` | `components/data/app_code_block.dart` | auswählbarer, scrollbarer Langtext | `Data/Code Block` | `SelectableText` |
| `ListPageTemplate` | `templates/list_page_template.dart` | Kopfleiste + Suche; Zustände laden/Fehler/leer/Inhalt; Einträge als Liste (Raster ab Tablet später zentral umschaltbar); Hauptaktion | `Template/List Page` | — |
| `DetailPageTemplate` | `templates/detail_page_template.dart` | Kopfleiste + Aktionen + Ladebalken; Haupt- und Nebenabschnitte, Erweiterungen, Fußleiste; 1- oder 2-spaltig über **eine** Einstellung im Template (zunächst immer einspaltig = heute) | `Template/Detail Page` | — |
| `FormPageTemplate` | `templates/form_page_template.dart` | Kopfleiste, Meldungen, Formularabschnitte, Hauptaktion oder Fußleiste | `Template/Form Page` | — |

Media: keine Komponente in 1.2 (F5).

### Fachliche Bausteine (bleiben in Core-UI)

| Baustein | Datei (`ui/…`) | aus Design-Komponenten |
|---|---|---|
| `RecipeCard` (neu) | `recipe_list/recipe_card.dart` | `AppListItem` |
| `FoodTile` (neu) | `foods/food_tile.dart` | `AppListItem` |
| `VersionTile` (neu) | `versions/version_tile.dart` | `AppListItem`, `AppIconButton`, `AppIcon` |
| `VersionSwitcher` | `recipe_detail/version_switcher.dart` | `AppChoiceChip` |
| `IngredientRow` | `recipe_editor/ingredient_row.dart` | `AppTextField`, `AppSelect`, `AppIconButton` |
| `StepRow` (herausgelöst) | `recipe_editor/step_row.dart` | `AppTextField`, `AppIconButton` |
| `FoodVariantPickerDialog` (herausgelöst) | `recipe_editor/food_variant_picker_dialog.dart` | `AppDialog`, `AppSearchField`, `AppListItem` |
| `NutritionHeader` | `nutrition/nutrition_header.dart` | `AppText`, `AppNotice` |
| `NutritionTable` | `nutrition/nutrition_table.dart` | `AppKeyValueTable`, `AppSelect`, `AppText` |
| `AmountCalculator` | `nutrition/amount_calculator.dart` | `AppTextField`, `AppStack` |
| `PackageForm` | `foods/package_form.dart` | Abschnitte unter `foods/sections/` |
| `SnapshotColumn`, `ChangeList` (herausgelöst) | `versions/snapshot_column.dart`, `versions/change_list.dart` | `AppText`, `AppListItem`, `AppSection` |

---

## (c) Core-Bildschirme und Abschnitte

**Konvention.** Der Bildschirm hält Zustand, lädt Daten, löst Aktionen aus
(Repositories, Navigation, Dialoge, `PopScope`). Ein Abschnitt ist ein
zustandsloses Widget in eigener Datei unter `<bereich>/sections/`, bekommt
Daten und Callbacks, liest keine Provider und baut nur aus Design-Komponenten
und fachlichen Bausteinen. Name: `<Bildschirm><Abschnitt>Section`. Reine
Template-Slots ohne eigene Darstellung (Meldung, Hauptaktion) bekommen keine
eigene Datei. Die Reihenfolge der Abschnitte entspricht dem heutigen Stand.

| # | Bildschirm (Datei) | Template | Abschnitte (Datei unter `sections/`) | Zustände |
|---|---|---|---|---|
| 1 | Rezeptliste `recipe_list/recipe_list_screen.dart` | List | `recipe_list_search_section` Suchfeld · `recipe_list_empty_section` „Noch keine Rezepte.“ + „Erstes Rezept anlegen“ bzw. „Keine Treffer.“ · `recipe_list_results_section` `RecipeCard`s mit Wischen-Löschen | laden, Fehler + erneut, leer, Treffer |
| 2 | Rezept erstellen `recipe_editor/recipe_create_screen.dart` | Form (FAB) | `recipe_create_fields_section` Titel (Fehlertext 1–200) + Beschreibung | Eingabe, speichert, Speicherfehler; Verwerfen-Rückfrage bleibt im Bildschirm |
| 3 | Rezept-Editor `recipe_editor/recipe_editor_screen.dart` | Form (Fußleiste) | `recipe_editor_preview_section` Live-kcal · `recipe_editor_frozen_section` „Eingefroren — als neuen Entwurf kopieren?“ + Lesansicht · `recipe_editor_parameters_section` Portionen, Backverlust, Fertiggewicht, Notizen · `recipe_editor_ingredients_section` `IngredientRow`s, umsortierbar, „Zutat hinzufügen“ · `recipe_editor_steps_section` `StepRow`s, umsortierbar, „Schritt hinzufügen“ · `recipe_editor_actions_section` Einfrieren · Speichern | laden, Fehler + erneut, nicht gefunden, eingefroren, bearbeitbar, Fehler beim Speichern |
| 4 | Rezeptdetail `recipe_detail/recipe_detail_screen.dart` | Detail | `recipe_detail_actions_section` Versionen, Bearbeiten, Modul-Aktionen, Menü (+ „Rezept löschen“) · `VersionSwitcher` (bestehende Datei) · `recipe_detail_description_section` · `recipe_detail_nutrition_section` `NutritionHeader` + `NutritionTable` + `AmountCalculator` · `recipe_detail_ingredients_section` · `recipe_detail_steps_section` mit Timer-Chips · `recipe_detail_extensions_section` `recipeDetailSections` nach `order` | erstes Laden, Versionswechsel mit Ladebalken nach 300 ms (Logik bleibt), Fehler, Inhalt |
| 5 | Nährwertanzeige (Teil von 4) | — | Baustein `NutritionHeader`, `NutritionTable` | `incomplete`-Fußnoten, `notCalculable`-Hinweis |
| 6 | Mengenrechner (Teil von 5) | — | Baustein `AmountCalculator` | ungültige Eingabe markiert das Feld |
| 7 | Versionen `versions/version_list_screen.dart` | List (ohne Suche, ohne FAB) | `version_list_results_section` `VersionTile`s; Dialoge über `showAppConfirmDialog`/`showAppChoiceDialog`, Meldungen über `showAppMessage` | laden, Fehler, leer, Liste |
| 8 | Versionsvergleich `versions/version_compare_screen.dart` | Detail (geteilt + Fußleiste) | `version_compare_columns_section` A \| B (`SnapshotColumn`) · `version_compare_changes_section` `ChangeList` bzw. „Keine Unterschiede.“ · `version_compare_apply_section` Fehler + „Als neuen Entwurf übernehmen“ | laden, Fehler + erneut, ohne/mit Änderungen |
| 9 | Lebensmittel-Liste `foods/food_list_screen.dart` | List | `food_list_search_section` · `food_list_empty_section` „Keine Lebensmittel gefunden.“ + „Eigenes Produkt anlegen“ · `food_list_results_section` `FoodTile`s mit Wischen-Löschen | laden, Fehler + erneut, leer, Treffer |
| 10 | Lebensmittel bearbeiten `foods/food_editor_screen.dart` + `foods/package_form.dart` | Form (FAB, Menü „Löschen“) | `package_identity_section` Name, Marke, Barcode · `package_measures_section` Dichte, Stückgewicht, Portionsgröße · `package_nutrients_section` 8 Nährwerte (EU-Reihenfolge) + Natrium · `package_validation_section` Warnungen/Fehler (`AppNotice`, Keys `package_form_warning`/`_error` bleiben) | laden, Fehler + erneut, nicht gefunden, Eingabe, speichert, Speicherfehler; `PopScope` (10.0) bleibt im Bildschirm |
| 11 | Export `settings/export_screen.dart` | Form | `export_selection_section` Rezept, Version (nur eingefroren) · `export_result_section` JSON (`AppCodeBlock`) + „In Zwischenablage kopieren“ | keine eingefrorene Version, Fehler, Ergebnis |
| 12 | Import `settings/import_screen.dart` | Form | `import_input_section` JSON einfügen · `import_preview_section` Titel, Zutatenzahl, Gesamt-kcal | ungültiges JSON, Vorschau, Importfehler im Klartext |
| 13 | Einstellungen `settings/settings_screen.dart` | List (ohne Suche) | `settings_core_entries_section` Export, Import, „Über unsalted“ · `settings_module_entries_section` `settingsEntries` nach `order` | — |

Außerdem: `shared/undoable_deletion.dart` behält Fristen und Provider, zeigt
aber über `showAppUndoSnackbar` und `AppSwipeToDelete`; `DeleteSwipeBackground`
entfällt in Core. Die App-Hülle bekommt `AppNavigationBar`.

---

## (d) UI-Konfiguration und Regeländerungen

### d1 Vorschlag UI-Konfiguration — „Schalter statt Code löschen“ (nicht umsetzen)

Eine additive Optionsklasse und ein Provider in Core, über die Tür
exportiert; die App überschreibt den Provider in `main.dart` mit Werten aus
**einer** Datei. Standardwerte = heutiges Verhalten, deshalb bleiben alle
bestehenden Tests unverändert.

```dart
// packages/unsalted_core/lib/src/ui/config/core_ui_options.dart (Vorschlag)
class CoreUiOptions {
  const CoreUiOptions({
    this.hiddenNutrients = const {},   // Feldschlüssel aus Kapitel 8.1, z. B. 'fiber_g'
    this.showBarcodeField = true,
    this.showAdvancedFields = true,
  });
  final Set<String> hiddenNutrients;
  final bool showBarcodeField;
  final bool showAdvancedFields;

  /// kcal ist nie ausblendbar (R7, Kapitel 22) — auch wenn es in der Menge steht.
  bool showsNutrient(String key) => key == 'energy_kcal' || !hiddenNutrients.contains(key);
}

final coreUiOptionsProvider = Provider<CoreUiOptions>((ref) => const CoreUiOptions());
```

```dart
// apps/unsalted_app/lib/config/ui_options.dart — einzige Stelle mit Werten
const uiOptions = CoreUiOptions(hiddenNutrients: {'fiber_g'}, showBarcodeField: false);
// main.dart: coreUiOptionsProvider.overrideWithValue(uiOptions)
```

| Schalter | wirkt in | wirkt nicht auf |
|---|---|---|
| `hiddenNutrients` | `NutritionTable` (Zeile und Fußnote), `PackageForm` (Eingabefeld; mit Salz auch Natrium) | Berechnung, Speicherung, Snapshot, Export/Import |
| `showBarcodeField` | `PackageForm` Barcode | Speicherung, Diff (Barcode-Zuordnung 28.3.4) |
| `showAdvancedFields` | Lebensmittel: Dichte, Stückgewicht, Portionsgröße, Natrium; Rezept-Editor: Backverlust, Fertiggewicht-Override | Berechnung (gespeicherte Werte wirken weiter) |

Grundsatz: **ausgeblendet heißt nicht gelöscht.** Ein ausgeblendetes Feld
behält beim Speichern seinen geladenen Wert; bei neuen Einträgen bleibt es
`null` („nicht angegeben“).

**Warum so:** `ui/config/` statt `providers/` oder `module/`, weil beide
unberührt bleiben sollen und `ui/shared/` schon UI-interne Provider hält.
Verworfen: Parameter von `CoreModule` (Änderung in `module/` und an allen
Bildschirmkonstruktoren); Optionen im Design-Paket (Fachbegriffe verboten);
Tabelle oder Spalte (Schemaänderung). **Später als Einstellung:** Die App
ersetzt `overrideWithValue` durch einen eigenen Provider mit App-Speicher und
einer Einstellungsseite über ein kleines App-Modul (`SettingsEntry`), ohne
weitere Änderung an Core.

Nötige Änderungen nur für d1: Core-Tür + 2 Symbole, AT-06-Golden + 2 Zeilen,
neue Datei in Core-UI, App-Datei + Override in `main.dart`, Tests UC-01 bis
UC-07 (unten), Kapitel 28.9 Punkt 6. `architecture.yaml`, Core-`pubspec.yaml`
und AT-01/`check_architecture.dart` brauchen für d1 nichts.

Tests: UC-01 Standardwerte = heutige Anzeige · UC-02 ausgeblendeter Nährwert
fehlt in Tabelle und Fußnoten · UC-03 `energy_kcal` lässt sich nicht
ausblenden · UC-04 Barcode ausgeblendet, Wert bleibt beim Speichern erhalten ·
UC-05 erweiterte Felder ausgeblendet, Werte bleiben erhalten · UC-06
ausgeblendeter Nährwert im Formular bleibt erhalten · UC-07 App überschreibt
den Provider aus `ui_options.dart`.

### d2 Neue Architekturtests

Neue Test-IDs mit eigenem Präfix (DS, WB, UC), damit sie nicht mit den
UI-Nummern auf `design/1.1` (UI-47 bis UI-57) verwechselt werden.

| ID | Ort | Prüfregel |
|---|---|---|
| AT-13 | Core `test/architecture/` | keine festen Farben in `packages/*/lib/src/ui/` (`Colors.*`, `CupertinoColors.*`, `Color(…)`, `TextStyle` mit Farbe) — aus design/1.1 |
| AT-14 | Core `test/architecture/` | `lib/src/ui/` verwendet nichts, wofür es eine Design-Komponente gibt (Liste unten) |
| AT-15 | Core `test/architecture/` | `package:unsalted_design/` nur in `lib/src/ui/` (Logikschichten bleiben designfrei) |
| DS-01 | Design `test/architecture/` | `lib/` importiert nur `package:flutter/`, das eigene Paket und `dart:ui`/`dart:math`/`dart:async`; `pubspec.yaml` hat als Abhängigkeit nur `flutter` |
| DS-02 | Design | Farbwerte (`Color(…)`, `Colors.*`) nur in `lib/src/tokens/` |
| DS-03 | Design | Tür = `public_api_golden.txt` |
| DS-04 | Design | jede Farbrolle hell und dunkel gesetzt, gleiche Namen |
| DS-05 | Design | Kontrast Text auf Fläche ≥ 4,5:1 je Modus |
| DS-06 | Design | keine Fachbegriffe in `lib/` (Wortliste: Rezept, Recipe, Zutat, Ingredient, Nährwert, Nutrient, kcal, Snapshot, Version …) |
| DS-07 | Design | `AppTheme.light()/dark()` = `ThemeData()` in Farben und Typo (Nachweis „neutral“; wird mit dem Figma-Design ersetzt) |
| DS-1x | Design | je Komponente: baut hell/dunkel, Handy/Tablet, ohne `AppTokens`-Erweiterung; Semantik; Interaktion |
| WB-01 | Widgetbook | jede Katalogansicht baut in hell/dunkel × Handy/Tablet ohne Fehler |

**AT-14-Liste** (Wortgrenze, Kommentare entfernt, Selbsttest des Detektors wie
bei AT-13; `RecipeCard(` zählt nicht als `Card(`):

- Widgets: `Scaffold`, `AppBar`, `SliverAppBar`, `FloatingActionButton`,
  `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`,
  `IconButton`, `PopupMenuButton`, `PopupMenuItem`, `ListTile`, `Card`,
  `Chip`, `ChoiceChip`, `ActionChip`, `FilterChip`, `InputChip`,
  `TextField`, `TextFormField`, `DropdownButton`, `DropdownButtonFormField`,
  `DropdownMenuItem`, `AlertDialog`, `SimpleDialog`, `SimpleDialogOption`,
  `SnackBar`, `SnackBarAction`, `CircularProgressIndicator`,
  `LinearProgressIndicator`, `Divider`, `VerticalDivider`, `Dismissible`,
  `ReorderableListView`, `Table`, `DataTable`, `NavigationBar`,
  `NavigationRail`, `SelectableText`.
- Aufrufe: `showDialog(`, `showAboutDialog(`, `.showSnackBar(`.
- Stil (F1): `TextStyle(`, `FontWeight.`, `Icons.`, `EdgeInsets.`,
  `BorderRadius.`, `SizedBox(` mit Zahl für `width`/`height`, `Theme.of(`.
- Erlaubt bleiben: `Text` ohne Stil, `Column`, `Row`, `Expanded`, `Flexible`,
  `Stack`, `Positioned`, `Builder`, `StreamBuilder`, `FutureBuilder`,
  `PopScope`, `Navigator`, `MaterialPageRoute`, `SizedBox.shrink()`.

**Übergangsliste:** AT-13 und AT-14 starten mit einer Liste der noch nicht
umgestellten Dateien. Jeder Bildschirm-Commit streicht seine Dateien; der
Abschluss-Commit entfernt die Liste. So bleibt jeder Commit grün und der
Fortschritt prüfbar.

### d3 Änderungen an Tür, `architecture.yaml`, pubspec, AT-01/`check_architecture`, Kapitel 28

| Ort | Änderung | Commit |
|---|---|---|
| `architecture.yaml` | `unsalted_design: { rank: 0 }`; `unsalted_widgetbook: { rank: 99 }` (Katalog, wie App); in `forbidden_in_core` zusätzlich `"package:unsalted_design/"  # nur in lib/src/ui/`; neuer Block `allowed_in_design: ["package:flutter/", "package:unsalted_design/"]` | C01 |
| `tool/check_architecture.dart` | Ausnahmeordner je Eintrag aus `forbidden_in_core` (heute fest an `contains('flutter')`/`contains('drift')` gebunden — ein Design-Eintrag würde sonst überall gemeldet); Design-Paket: jeder `package:`-Import muss in `allowed_in_design` stehen, `dart:io`/`dart:ffi` verboten; Gegenprobe | C01 |
| AT-01 | Prüflogik unverändert (Rang 0 < 1 ist erlaubt); nur der Kopfkommentar („praktisch kein Import irgendeines anderen Projektpakets“) wird korrigiert | C13 |
| AT-09 | unverändert; prüft schon projektweit, gilt automatisch für die neuen Pakete | — |
| Core `pubspec.yaml` | `unsalted_design` per `flutter pub add unsalted_design --path ../unsalted_design` | C13 |
| App `pubspec.yaml` | `unsalted_design` (path) | C26 |
| Core-Tür `lib/unsalted_core.dart` + AT-06-Golden | nur d1: `export 'src/ui/config/core_ui_options.dart' show CoreUiOptions, coreUiOptionsProvider;` | C29 |
| `.github/workflows/ci.yml` | Schritte pub get/analyze/test für `unsalted_design` (C02) und `unsalted_widgetbook` (C11) | C02, C11 |
| Kapitel 28 | neues **28.9 „Teil 1.2 – Design-System“** (unten) | C01, ergänzt in C13, C29 |

Kapitel 28.9, geplante Punkte:

1. **Kapitel 2/3, `architecture.yaml`:** Paket `unsalted_design`, Rang 0, nur
   Flutter, keine Fachbegriffe; App `unsalted_widgetbook` (Rang 99) als
   Komponenten-Katalog.
2. **Kapitel 4.1/4.2:** Core und App hängen per Pfad von `unsalted_design` ab.
3. **Kapitel 5.1, Kapitel 27 Regel 14:** `check_architecture.dart` prüft das
   Design-Paket (nur Flutter) und erlaubt `package:unsalted_design/` in Core
   nur unter `lib/src/ui/`.
4. **Kapitel 5.2/19:** AT-13 bis AT-15 neu, DS-01 ff. im Design-Paket.
5. **Kapitel 22, gemeinsame Regeln:** Lade-, Fehler- und Leerzustand über
   `AppLoading`, `AppErrorState`, `AppEmptyState` — Verhalten unverändert.
   Bildschirme bestehen aus Abschnitten (Konvention aus (c)).
6. **Nur d1 — Kapitel 7.4/16.7/18.1:** Die Tür exportiert zusätzlich
   `CoreUiOptions` und `coreUiOptionsProvider` (additiv nach 25.2; Standard =
   bisheriges Verhalten; Override nur in der App-Hülle).

---

## (e) Commit-Reihenfolge

Jeder Commit: `flutter analyze` und `flutter test` in allen betroffenen
Paketen grün, `dart run tool/check_architecture.dart` Exit 0,
`docs/status.md` und `docs/decisions.md` nachgeführt. Präfix
„Teil 1.2 Design-System Cxx: …“. Kein Merge, kein Tag.

| Nr | Inhalt | Abnahme |
|---|---|---|
| C01 | Regeln: Kapitel 28.9 (Punkte 1–3), `architecture.yaml`, `check_architecture.dart`; decisions/status; CLAUDE.md | Exit 0; Gegenproben (verbotener Import im Design-Paket bzw. Design-Import in `src/recipe/` → Exit 1) |
| C02 | Gerüst `packages/unsalted_design` (`flutter create --template=package`), leere Tür, README/CHANGELOG (Gerüst), DS-01, DS-03, DS-06; CI-Schritte | Tests grün; Gegenprobe DS-01 |
| C03 | Tokens (alle sieben Dateien); DS-02, DS-04, DS-05 | Werte aus dem Flutter-SDK abgelesen, nicht geschätzt |
| C04 | Theme: `AppTheme`, `AppTokens` mit Rückfall, `component_themes`; DS-07 | DS-07 grün = neutral |
| C05 | Layout: `AppPage`, `AppSection`, `AppStack`/`AppGap`, `AppGrid`, `Responsive` | Widget-Tests |
| C06 | Komponenten I: buttons, icons, text, cards, surfaces | Widget-Tests |
| C07 | Komponenten II: inputs, lists, chips | Widget-Tests |
| C08 | Komponenten III: feedback (Notice, Empty, Error, Loading, ProgressBar, Skeleton, Snackbar, Dialog) | Widget-Tests |
| C09 | Komponenten IV: navigation, data | Widget-Tests |
| C10 | Templates: List, Detail, Form (Slots; 1/2 Spalten über eine Einstellung) | Widget-Tests Handy/Tablet |
| C11 | `apps/unsalted_widgetbook`: Katalog aller Tokens/Komponenten/Templates, hell/dunkel, Handy/Tablet; WB-01; CI | WB-01 grün; Version per `flutter pub add`, API im Pub-Cache geprüft |
| C12 | Doku: `design_system.md`, `components.md`, `screens.md` (Soll-Abschnitte), README/CHANGELOG `design-v0.1.0` | — |
| C13 | Core-Anbindung: pubspec, AT-13/14/15 mit Übergangsliste, AT-01-Kommentar, Kapitel 28.9 Punkt 4 | alle Core-Tests grün; Gegenproben je AT |
| C14 | Einstellungen (13) | bestehende Tests unverändert grün; Dateien von der Übergangsliste |
| C15 | Lebensmittel-Liste (9) + `shared/undoable_deletion.dart` | dto. |
| C16 | Rezeptliste (1) | dto. |
| C17 | Rezept erstellen (2) | dto. |
| C18 | Export (11) | dto. |
| C19 | Import (12) | dto. |
| C20 | Versionen (7) | dto. |
| C21 | Versionsvergleich (8) | dto. |
| C22 | Nährwertanzeige + Mengenrechner (5, 6) | dto. |
| C23 | Rezeptdetail (4) | dto.; UI-33/34/45/46 (Versionswechsel, Ladebalken) ausdrücklich prüfen |
| C24 | Lebensmittel bearbeiten + `PackageForm` (10) | dto.; UI-29–32 (PopScope) |
| C25 | Rezept-Editor + `IngredientRow`/`StepRow` (3) | dto.; UI-11–15, UI-12 (Umsortieren) |
| C26 | App-Hülle: `theme`/`darkTheme` aus `AppTheme`, `AppNavigationBar` | App-Test grün |
| C27 | Abschluss: Übergangslisten leer und entfernt; Kapitel 28.9 Punkt 5; status/decisions/CLAUDE.md | alle Tests grün, Exit 0 |
| C28 | *optional (F7):* Test-Finder auf Design-Typen umstellen (nur Finder, keine Erwartung) | alle Tests grün |
| C29 | *nur nach eigener Freigabe (d1):* UI-Konfiguration, Tür + Golden, App-Datei, UC-01–07, Kapitel 28.9 Punkt 6 | alle Tests grün |

---

## (f) Risiken und offene Fragen

### Risiken

| Nr | Risiko | Gegenmaßnahme |
|---|---|---|
| R1 | Tests suchen Material-Typen (`FloatingActionButton` 14×, `widgetWithText(ElevatedButton)` 13×, `TextField` 58×, `PopupMenuButton<VoidCallback>`, `DropdownButton<String>`, `ChoiceChip`, `Chip`, `SnackBarAction`, `LinearProgressIndicator` 14×) | Komponenten bauen vorerst genau diese Widgets; Tests bleiben unverändert. Erst C28 löst die Bindung (F7) |
| R2 | Tests pumpen `MaterialApp` ohne Design-Theme | `AppTokens.of` fällt auf Standardwerte zurück; je Komponente getestet |
| R3 | Feinheiten gehen beim Zerlegen verloren: `PopScope` + `addPostFrameCallback`, Versionswechsel-Zähler (1.1a), 300-ms-Balken (1.1c), Rückgängig-Frist (1.1b), stabile `ValueKey(row.id)`, Keys `package_form_warning`/`_error` | Logik bleibt im Bildschirm bzw. Baustein; Abschnitte sind zustandslos; Templates kapseln kein `PopScope`; Keys werden durchgereicht |
| R4 | Umfang: ~40 Design-Bausteine, ~35 Abschnittsdateien, 13 Bildschirme | ein Bildschirm je Commit; Übergangsliste schrumpft sichtbar; nur Komponenten, die Core braucht |
| R5 | `widgetbook` passt nicht zu Flutter 3.47.5 oder die API weicht ab | Version per `flutter pub add`, API im Pub-Cache prüfen; Katalog ohne Generator |
| R6 | Neutrale Tokens weichen von `ThemeData()` ab (sichtbare Änderung) | DS-07 vergleicht mit `ThemeData()` |
| R7 | Dunkelmodus: Mit `darkTheme` folgt die App dem System; auf `main` stehen noch 15 `Colors.*`-Stellen | `darkTheme` erst in C26 nach der letzten Umstellung (F4) |
| R8 | Freeze von Teil 1: Tür (nur d1), pubspec, `architecture.yaml` ändern sich nach `part1-v1.0.0` | nur additiv nach 25.2; Kapitel 28.9 + decisions.md; Tag `part1-v1.0.0` bleibt unberührt |
| R9 | CI läuft nur für `main`, Branch-Commits bleiben ungeprüft | lokal je Commit prüfen; F11 |
| R10 | Figma-Namen ändern sich später | Tür mit Golden (DS-03); Umbenennung nur mit CHANGELOG und Minor-Version des Design-Pakets |
| R11 | AT-14 per Textsuche: Fehlalarme oder Lücken | Wortgrenzen, Kommentare entfernt, Selbsttest des Detektors; Liste mit F1 bestätigen |
| R12 | Teile 2–6 bauen eigene Optik | AT-13/14 gelten für `packages/*/lib/src/ui/`; das Design-Paket (Rang 0) steht allen Paketen offen |

### Offene Fragen (je mit Empfehlung)

- **F1 — Strenge von AT-14:** Neben den Widgets auch `Icons.`, `Theme.of(`,
  `TextStyle(`, `EdgeInsets.`, `BorderRadius.` und `SizedBox` mit Zahl in
  Core-UI verbieten? *Empfehlung:* ja, über die Übergangsliste — sonst bleibt
  „wie“ in den Bildschirmen.
- **F2 — Abschnittsgröße:** Auch Einzeiler (z. B. Suchfeld) als eigene
  Abschnittsdatei? *Empfehlung:* ja wie in (c); nur reine Template-Slots
  (Meldung, Hauptaktion) ohne eigene Datei.
- **F3 — Sichtbare Änderungen aus design/1.1:** deutsche Einheitennamen
  (`unit_labels.dart`) und Skelett statt Ladekreis ändern die Anzeige bzw.
  Kapitel 22. *Empfehlung:* übernehmen, aber erst mit eigener Freigabe
  einsetzen.
- **F4 — Dunkelmodus in der App ab C26?** *Empfehlung:* ja.
- **F5 — Media-Komponente:** jetzt ohne Verwendung bauen oder erst in Teil 4?
  *Empfehlung:* erst Teil 4 (KI-S4); in `components.md` als „geplant“.
- **F6 — Token-Austausch mit Figma:** Variablen-Export als JSON (W3C-Format
  Design Tokens) plus Generator jetzt oder erst, wenn die Figma-Datei steht?
  *Empfehlung:* Namen jetzt festlegen, Generator später.
- **F7 — C28 (Test-Finder auf Design-Typen):** gewünscht? *Empfehlung:* ja,
  als eigener Commit nach C27 — sonst legen die Tests fest, welches
  Material-Widget eine Komponente intern nutzen muss.
- **F8 — Widgetbook:** Plattformen Web + macOS, Katalog von Hand ohne
  `widgetbook_generator`/`build_runner`? *Empfehlung:* ja.
- **F9 — UI-Konfiguration (d1):** so freigeben? Dazu: (a) welche Felder
  „erweitert“ sind (Vorschlag in der Tabelle); (b) Validator-Warnungen zu
  ausgeblendeten Feldern — *Empfehlung:* Warnungen nicht zeigen, Fehler
  weiter blockieren und das Feld dann einblenden; (c) Werte nur in einer
  App-Datei (*Empfehlung*) oder gleich als Einstellung; (d) Ort
  `ui/config/` — erstmals exportiert die Tür etwas aus `src/ui/`.
- **F10 — Präfix `App…`** für Design-Klassen (Alternative `Us…`)?
  *Empfehlung:* `App…`; Kollisionen mit Flutter werden vermieden (`AppBar` →
  `AppTopBar`).
- **F11 — CI für den Branch:** Entwurfs-PR nach `main` (ohne Merge) oder
  `design-system` als CI-Trigger? *Empfehlung:* Entwurfs-PR.
- **F12 — Tags:** `part1-v1.1.0` war für „nach dem Design-Pass“ geplant.
  Teil 1.1a–d jetzt auf `main` taggen und Teil 1.2 später als
  `part1-v1.2.0` + `design-v0.1.0`? *Empfehlung:* ja, beides erst nach
  ausdrücklicher Freigabe.
