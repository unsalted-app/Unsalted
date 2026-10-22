# Komponenten

Stand Teil 1.3 (`design-v0.2.0`). Pfade relativ zu
`packages/unsalted_design/lib/src/`. Figma-IDs aus der Bibliothek
`5er28Cr7EMMcPzvusWjNyR` (`docs/design/figma/figma-ids.json`); Gestaltung nach
den Komponentenkarten in `docs/design/system/components/`. Alle Komponenten
sind im Paket, getestet und im Katalog (`apps/unsalted_widgetbook`, WB-01/02/04)
und in den Golden-Motiven (GL-01). Regeln und Benennung:
`docs/design/design_system.md`; bewusste Abweichungen von Figma:
`docs/design/rueckmeldung-figma.md`.

## Tokens und Theme

Alle Token-Dateien (`*_tokens.g.dart`) erzeugt `tool/generate_tokens.dart`
aus `tokens/unsalted.tokens.json` (DS-04).

| Symbol | Figma | Datei | Test |
|---|---|---|---|
| `AppColorTokens` (`light`, `dark`; 30 Rollen, seit Teil 1.4 mit `selection`, `selection-handle`) | Sammlung `color`, Modi `light`/`dark` | `tokens/color_tokens.g.dart` | DS-02, DS-04, DS-05 |
| `AppTypography` (11 Stile, tnum für `display`, `label-small`, `data`, `data-strong`) | `type/*` | `tokens/typography_tokens.g.dart` | DS-04 |
| `AppSpacing`, `AppSpace` | `space/*` | `tokens/spacing_tokens.g.dart` | DS-04, DS-10 |
| `AppRadius` | `radius/*` | `tokens/radius_tokens.g.dart` | DS-04 |
| `AppStroke` | `stroke/*` | `tokens/stroke_tokens.g.dart` | DS-04 |
| `AppSize` | `size/*` | `tokens/size_tokens.g.dart` | DS-04 |
| `AppReflow` (100 %, `byFigmaNameAt200`) | `reflow/*`, Modi `100`/`200` | `tokens/size_tokens.g.dart` | DS-04 |
| `AppOpacity` | `opacity/*` | `tokens/opacity_tokens.g.dart` | DS-04 |
| `AppShadow` (`overlay`, `focus` je Modus) | `shadow/*` | `tokens/shadow_tokens.g.dart` | DS-04 |
| `AppMotion` | `motion/duration/*`, `motion/easing/*` | `tokens/motion_tokens.g.dart` | DS-04 |
| `AppBreakpoints` | `breakpoint/*` | `tokens/breakpoint_tokens.g.dart` | DS-04, DS-13 |
| `AppTheme` | Tabellen in `01-farbe.md`, `02-typografie.md` | `theme/app_theme.dart`, `theme/component_themes.dart` | DS-07, DS-52 |
| `AppFonts` | `family/sans` (Atkinson Hyperlegible Next 400/600/700) | `theme/app_fonts.dart`, `lib/fonts/` | DS-49, DS-50 |
| `AppReflowMetric` | `reflow/*` | `theme/app_reflow.dart` | DS-04b |
| `AppTone` | Farbton als Rolle | `theme/app_tone.dart` | DS-18 |
| intern: `AppColors.of(context)` | Rollen außerhalb des `ColorScheme` | `theme/app_colors.dart` | — |

`AppElevation` ist entfallen (ersetzt durch `AppShadow`, D03).

## Layout

| Komponente | Figma | ID | Datei | Test |
|---|---|---|---|---|
| `AppPage` (Slot `navigation`: unten bzw. links ab `breakpoint-medium`) | `Template/*` | — | `layout/app_page.dart` | DS-11, DS-59 |
| `AppSection` (Abschnittslinie, `heading`, `meta`) | `Layout/Section` | `133:55` | `layout/app_section.dart` | DS-22, DS-22b |
| `AppStack`, `AppGap`, `AppPadding` | — | — | `layout/app_stack.dart` | DS-10 |
| `AppGrid` | — | — | `layout/app_grid.dart` | DS-12 |
| `AppWindowSize` (mit `pageMargin`), `ResponsiveBuilder` | `breakpoint/*` | — | `layout/responsive.dart` | DS-13, DS-60 |
| intern: `ReflowRow` (Aktion daneben oder darunter) | — | — | `layout/reflow_row.dart` | DS-32c |

## Komponenten

| Komponente | Figma | ID | Datei | Test |
|---|---|---|---|---|
| `AppButton` (`primary`, `secondary`, `tertiary`) | `Button` | `42:13` | `components/buttons/app_button.dart` | DS-14 |
| `AppIconButton` | `Button/Icon` | `67:62` | `components/buttons/app_icon_button.dart` | DS-15 |
| `AppFab` (Marker-Knopf) | `Button/FAB` | `143:155` | `components/buttons/app_fab.dart` | DS-16 |
| `AppIcon`, `AppIconSize` | `Icon` | — | `components/icons/app_icon.dart` | DS-17 |
| `AppIcons` (32 Namen, Outlined) | `Icon/<name>` | siehe `figma-ids.json` | `components/icons/app_icons.dart` | DS-17 |
| `AppText` (11 Stile) | `type/*` | — | `components/text/app_text.dart` | DS-18, DS-18b |
| `AppCard` | `Card` | `135:56` | `components/cards/app_card.dart` | DS-19 |
| `AppSurface` | `Surface` | `151:205` | `components/surfaces/app_surface.dart` | DS-20, DS-20b |
| `AppDivider` (`flush`, `vertical`, `rule`) | `Divider` | `82:39` | `components/surfaces/app_divider.dart` | DS-21 |
| `AppTextField` (Beschriftung oben, `unit`, schmal = `reflow-field-min`) | `Input/Text Field` | `118:30` | `components/inputs/app_text_field.dart` | DS-23, DS-23b, DS-23c |
| `AppSearchField` | `Input/Search` | `138:50` | `components/inputs/app_search_field.dart` | DS-24 |
| `AppSelect` (`expand`) | `Input/Select` | `149:200` | `components/inputs/app_select.dart` | DS-25, DS-25b, DS-25c |
| `AppListItem` (`selected`, `match`) | `List/Item` | `127:29` | `components/lists/app_list_item.dart` | DS-26, DS-26b, DS-66 |
| `AppItemList` | `List/Items` | `151:297` | `components/lists/app_item_list.dart` | DS-27 |
| `AppSwipeToDelete` | `List/Swipe to Delete` | `150:163` | `components/lists/app_swipe_to_delete.dart` | DS-28 |
| `AppReorderableList` | — | — | `components/lists/app_reorderable_list.dart` | DS-29, DS-29b |
| `AppChoiceChip` | `Chip/Choice` | `104:38` | `components/chips/app_choice_chip.dart` | DS-30 |
| `AppChip` (Tag, `icon`) | `Chip/Info` | `106:65` | `components/chips/app_chip.dart` | DS-31, DS-31b |
| `AppNotice` (`error`, `warning`, `info`, `success`) | `Feedback/Notice` | `134:69` | `components/feedback/app_notice.dart` | DS-32, DS-32b, DS-32c |
| `AppEmptyState` (mit Aktion als Leerstelle) | `Feedback/Empty State` | `184:219` | `components/feedback/app_empty_state.dart` | DS-33, DS-33b |
| `AppErrorState` | `Feedback/Error State` | `144:162` | `components/feedback/app_error_state.dart` | DS-34, DS-34b |
| `AppLoading` | `Feedback/Loading` | `62:253` | `components/feedback/app_loading.dart` | DS-35 |
| `AppProgressBar` | `Feedback/Progress Bar` | `91:72` | `components/feedback/app_loading.dart` | DS-36 |
| `AppSkeleton` | `Feedback/Skeleton` | `150:175` | `components/feedback/app_skeleton.dart` | DS-37 |
| `AppMessenger`, `AppSnackbarHandle`, `showAppMessage` (Restzeitlinie) | `Feedback/Snackbar` | `136:50` | `components/feedback/app_snackbar.dart` | DS-38, DS-38b |
| `AppDialog`, `showAppConfirmDialog`, `showAppChoiceDialog`, `showAppDialog`, `showAppAboutDialog` | `Feedback/Dialog`, `Scrim` | `136:55`, `135:62` | `components/feedback/app_dialog.dart` | DS-39, DS-39b |
| `AppTopBar` | `Navigation/Top Bar` | `138:55` | `components/navigation/app_top_bar.dart` | DS-40, DS-40b |
| `AppOverflowMenu`, `AppMenuEntry` | `Navigation/Overflow Menu`, `Navigation/Menu Item` | `150:168`, `150:166` | `components/navigation/app_overflow_menu.dart` | DS-41 |
| `AppNavigationBar` (`.rail()`), `AppNavigationDestination` | `Navigation/Navigation Bar`, `Navigation/Navigation Rail`, `Navigation/Destination` | `139:119`, `231:272`, `139:67` | `components/navigation/app_navigation_bar.dart` | DS-42, DS-59, DS-59b |
| `AppBottomActionBar` | `Navigation/Bottom Action Bar` | `139:120` | `components/navigation/app_bottom_action_bar.dart` | DS-43, DS-43b, DS-43c |
| `AppKeyValueTable`, `AppTableRow` (`sub`, `strong`) | `Data/Key Value Table`, `Data/Key Value Row`, `Data/Key Value Header` | `140:123`, `140:115`, `140:116` | `components/data/app_key_value_table.dart` | DS-44, DS-44b, DS-44c |
| `AppFigureRow`, `AppFigure` (Kennzahlenleiste, D15a) | `Core/Nutrition Header`, `Core/Nutrition Field` | `142:57`, `142:56` | `components/data/app_figure_row.dart` | DS-61 |
| `AppCodeBlock` | `Data/Code Block` | `135:60` | `components/data/app_code_block.dart` | DS-45, DS-45b |
| `AppMark`, `AppMarkState` (auch als Auswahlziel) | `Mark`, `Core/Version Target` | `114:68`, `142:18` | `components/brand/app_mark.dart` | DS-53, DS-53b |
| `AppFrame` (`provisional`, `fixed`) | `Frame` | `135:55` | `components/brand/app_frame.dart` | DS-54 |
| `AppSlot` (Leerstelle mit Punktraster) | `Slot`, `Pattern/Dots` | `144:152`, `144:150` | `components/brand/app_frame.dart` | DS-55 |
| `AppDashedUnderline` | — (in Figma nicht abbildbar) | — | `components/brand/app_frame.dart` | GL-01 `marken`, UI-72 |
| `AppHighlight` | `Highlight` | `134:152` | `components/brand/app_highlight.dart` | DS-56 |
| `AppChangeText` | `Change` | `134:154` | `components/brand/app_highlight.dart` | DS-57 |
| `AppValue`, `AppCertainty` | `Value` | `134:179` | `components/brand/app_value.dart` | DS-58 |
| Bild mit Platzhalter | `Media/Image` | `151:186` | — | geplant, Teil 4 |

## Templates

| Komponente | Figma | ID | Datei | Test |
|---|---|---|---|---|
| `ListPageTemplate` | `Template/List Page` | `151:341` | `templates/list_page_template.dart` | DS-46, DS-60 |
| `DetailPageTemplate`, `DetailSections`, `DetailSplit`, `DetailLayout` (zweispaltig ab `breakpoint-large`) | `Template/Detail Page` | `151:410` | `templates/detail_page_template.dart` | DS-47, DS-60 |
| `FormPageTemplate`, `FormSections` | `Template/Form Page` | `151:433` | `templates/form_page_template.dart` | DS-48, DS-60 |
| intern: Rahmen „Inhalt“ | Rahmen `Inhalt` der Templates | — | `templates/page_content.dart` | DS-60 |

## Fachliche Bausteine (in `unsalted_core/lib/src/ui/`)

Aus Design-Komponenten zusammengesetzt; Abschnitte je Bildschirm in
`docs/design/screens.md`.

| Baustein | Figma | Datei | aus | Test |
|---|---|---|---|---|
| `RecipeCard` (Suchtreffer markiert) | `List/Item` `showMatch` | `recipe_list/recipe_card.dart` | `AppListItem` (`match`) | UI-01 ff., UI-89 |
| `FoodTile` | — | `foods/food_tile.dart` | `AppListItem` | — |
| `VersionMark` (Teil 1.3) | `Mark` | `versions/version_mark.dart` | `AppMark` | UI-67, UI-68 |
| `VersionTile` | Bildschirm 07 | `versions/version_tile.dart` | `AppListItem`, `VersionMark`, `AppText`, `AppIconButton` | UI-68 |
| `VersionSwitcher` (Fassungsleiste, Master markiert) | `Core/Version Switcher` `142:19` | `recipe_detail/version_switcher.dart` | `VersionMark` als Ziele (`isMaster` über `masterVersionId`), `Wrap` | UI-67, UI-87 |
| `IngredientRow` (zweizeilig, Zeilenmenü) | Bildschirm 03, `_Zeile/Zutat bearbeiten` `7:712` (App), `Core/Ingredient Row` `141:4` (Anzeige) | `recipe_editor/ingredient_row.dart` | `AppTextField`, `AppSelect` (`label`, `expand`), `AppDashedUnderline`, `AppOverflowMenu` (`tooltip`), `AppIcon`, `AppDivider.flush` | UI-72, UI-84, UI-86 |
| `StepRow` (Nummer, Timer darunter, Zeilenmenü) | `_Zeile/Schritt bearbeiten` `227:4142` (App), `Core/Step Row` `141:10` (Anzeige) | `recipe_editor/step_row.dart` | `AppTextField` (schmal, `space-m` unter der Anweisung), `AppText.dataStrong`, `AppOverflowMenu` (`tooltip`), `AppDivider.flush` | UI-74, UI-82, UI-85 |
| `FoodVariantPickerDialog` | — | `recipe_editor/food_variant_picker_dialog.dart` | `AppDialog`, `AppTextField`, `AppItemList`, `AppListItem`, `AppEmptyState` | — |
| `NutritionHeader` (Kennzahlenleiste) | `Core/Nutrition Header` `142:57` | `nutrition/nutrition_header.dart` | `AppFigureRow`, `AppValue.strong`, `AppNotice` (Warnung) | UI-70 |
| `NutritionTable` (Deklaration) | `Data/Key Value Table` | `nutrition/nutrition_table.dart` | `AppKeyValueTable` (`sub`, `strong`), `AppSelect`, `AppText` | UI-71 |
| `AmountCalculator` | `Core/Amount Calculator` `179:392` | `nutrition/amount_calculator.dart` | `AppTextField` (Zahl, Einheit), `AppIcon` (`swap`) | UI-71 |
| `PackageForm` | Bildschirm 10 | `foods/package_form.dart` | Abschnitte unter `foods/sections/` (`AppTextField` als Zahlenfelder im `AppGrid`, `AppSection`, `AppNotice`) | UI-73, UI-78, UI-80–82 |
| `SnapshotColumn` | — | `versions/snapshot_column.dart` | `AppText`, `AppPadding`, `AppStack` | — |
| `ChangeList` | Bildschirm 08, `Change` | `versions/change_list.dart` | `AppItemList`, `AppSection`, `AppChangeText` | UI-69 |

In Core nicht eingesetzt: `AppSkeleton` (Kapitel 22 verlangt den Ladekreis,
F3 aus Teil 1.2), `AppCard`, `AppSurface` nur noch für die Editor-Vorschau.
