# Komponenten

Stand Teil 1.2. Pfade relativ zu `packages/unsalted_design/lib/src/`. Status:
**fertig** = im Paket, getestet und im Katalog; **geplant** = noch nicht
gebaut; „(neu)“ = im Plan nicht vorgesehen, in Etappe 1 hinzugekommen
(`docs/decisions.md`, C05–C08). Regeln und Benennung:
`docs/design/design_system.md`.

## Tokens und Theme

| Komponente | Figma-Name | Datei | Status | Test |
|---|---|---|---|---|
| `AppColorTokens` (`light`, `dark`) | Sammlung `color`, Modi `light`/`dark` | `tokens/color_tokens.dart` | fertig | DS-02, DS-04, DS-05, DS-07 |
| `AppTypography` | `type/*` | `tokens/typography_tokens.dart` | fertig | DS-04, DS-07 |
| `AppSpacing` | `space/*` | `tokens/spacing_tokens.dart` | fertig | DS-04 |
| `AppSpace` (Stufe als Parameter, neu) | `space/*` | `tokens/spacing_tokens.dart` | fertig | DS-10 |
| `AppRadius` | `radius/*` | `tokens/radius_tokens.dart` | fertig | DS-04 |
| `AppElevation` | `elevation/*` | `tokens/elevation_tokens.dart` | fertig | DS-04 |
| `AppMotion` | `motion/duration/*`, `motion/easing/*` | `tokens/motion_tokens.dart` | fertig | DS-04 |
| `AppBreakpoints` | `breakpoint/*` | `tokens/breakpoint_tokens.dart` | fertig | DS-04, DS-13 |
| `AppTheme` | — | `theme/app_theme.dart` | fertig | DS-07 |
| `AppTone` (neu) | Farbton aus `color/on-surface-variant`, `color/primary`, `color/error` | `theme/app_tone.dart` | fertig | DS-17, DS-18 |

## Layout

| Komponente | Figma-Name | Datei | Status | Test |
|---|---|---|---|---|
| `AppPage` | `Layout/Page` | `layout/app_page.dart` | fertig | DS-11 |
| `AppSection` | `Layout/Section` | `layout/app_section.dart` | fertig | DS-22 |
| `AppStack`, `AppGap` | `Layout/Stack`, `Layout/Gap` | `layout/app_stack.dart` | fertig | DS-10 |
| `AppPadding` (neu) | `Layout/Padding` | `layout/app_stack.dart` | fertig | DS-10 |
| `AppGrid` | `Layout/Grid` | `layout/app_grid.dart` | fertig | DS-12 |
| `AppWindowSize` (neu, statt `Responsive.of`) | `breakpoint/*` | `layout/responsive.dart` | fertig | DS-13 |
| `ResponsiveBuilder` | `breakpoint/*` | `layout/responsive.dart` | fertig | DS-13 |

## Komponenten

| Komponente | Figma-Name | Datei | Status | Test |
|---|---|---|---|---|
| `AppButton` | `Button/Primary`, `Button/Secondary`, `Button/Tertiary` | `components/buttons/app_button.dart` | fertig | DS-14 |
| `AppIconButton` | `Button/Icon` | `components/buttons/app_icon_button.dart` | fertig | DS-15 |
| `AppFab` | `Button/FAB` | `components/buttons/app_fab.dart` | fertig | DS-16 |
| `AppIcon` | `Icon` | `components/icons/app_icon.dart` | fertig | DS-17 |
| `AppIcons` | `Icon/<name>` | `components/icons/app_icons.dart` | fertig | DS-17 |
| `AppText` | `Text/Body`, `Text/Strong`, `Text/Title`, `Text/Caption` | `components/text/app_text.dart` | fertig | DS-18 |
| `AppCard` | `Card` | `components/cards/app_card.dart` | fertig | DS-19 |
| `AppSurface` | `Surface/low`, `Surface/medium`, `Surface/high`, `Surface/info`, `Surface/warning`, `Surface/error` | `components/surfaces/app_surface.dart` | fertig (Hinweistöne seit C22) | DS-20, DS-20b |
| `AppDivider` | `Divider` | `components/surfaces/app_divider.dart` | fertig | DS-21 |
| `AppTextField` | `Input/Text Field` | `components/inputs/app_text_field.dart` | fertig | DS-23 |
| `AppSearchField` | `Input/Search` | `components/inputs/app_search_field.dart` | fertig | DS-24 |
| `AppSelect` | `Input/Select` | `components/inputs/app_select.dart` | fertig | DS-25 |
| `AppListItem` | `List/Item` | `components/lists/app_list_item.dart` | fertig | DS-26 |
| `AppItemList` (neu) | `List/Items` | `components/lists/app_item_list.dart` | fertig | DS-27 |
| `AppSwipeToDelete` | `List/Swipe to Delete` | `components/lists/app_swipe_to_delete.dart` | fertig | DS-28 |
| `AppReorderableList` | `List/Reorderable` | `components/lists/app_reorderable_list.dart` | fertig | DS-29 |
| `AppChoiceChip` | `Chip/Choice` | `components/chips/app_choice_chip.dart` | fertig | DS-30 |
| `AppChip` | `Chip/Info` | `components/chips/app_chip.dart` | fertig | DS-31 |
| `AppNotice` | `Feedback/Notice` | `components/feedback/app_notice.dart` | fertig, in Core noch nicht eingesetzt (Symbol und runde Ecken wären eine sichtbare Änderung) | DS-32 |
| `AppEmptyState` | `Feedback/Empty State` | `components/feedback/app_empty_state.dart` | fertig | DS-33 |
| `AppErrorState` | `Feedback/Error State` | `components/feedback/app_error_state.dart` | fertig | DS-34 |
| `AppLoading` | `Feedback/Loading` | `components/feedback/app_loading.dart` | fertig | DS-35 |
| `AppProgressBar` | `Feedback/Progress Bar` | `components/feedback/app_loading.dart` | fertig | DS-36 |
| `AppSkeleton` | `Feedback/Skeleton` | `components/feedback/app_skeleton.dart` | fertig, nicht eingesetzt (F3) | DS-37 |
| `AppMessenger` (neu, statt `showAppUndoSnackbar`), `AppSnackbarHandle` | `Feedback/Snackbar` | `components/feedback/app_snackbar.dart` | fertig | DS-38 |
| `showAppMessage` | `Feedback/Snackbar` | `components/feedback/app_snackbar.dart` | fertig | DS-38 |
| `AppDialog`, `showAppConfirmDialog`, `showAppChoiceDialog`, `showAppDialog`, `showAppAboutDialog` | `Feedback/Dialog` | `components/feedback/app_dialog.dart` | fertig | DS-39 |
| `AppTopBar` | `Navigation/Top Bar` | `components/navigation/app_top_bar.dart` | fertig | DS-40 |
| `AppOverflowMenu` | `Navigation/Overflow Menu` | `components/navigation/app_overflow_menu.dart` | fertig | DS-41 |
| `AppNavigationBar` | `Navigation/Navigation Bar` | `components/navigation/app_navigation_bar.dart` | fertig | DS-42 |
| `AppBottomActionBar` | `Navigation/Bottom Action Bar` | `components/navigation/app_bottom_action_bar.dart` | fertig | DS-43 |
| `AppKeyValueTable` | `Data/Key Value Table` | `components/data/app_key_value_table.dart` | fertig | DS-44 |
| `AppCodeBlock` | `Data/Code Block` | `components/data/app_code_block.dart` | fertig | DS-45 |
| Bild mit Platzhalter | `Media/Image` | `components/media/` | geplant, Teil 4 (F5) | — |

## Templates

| Komponente | Figma-Name | Datei | Status | Test |
|---|---|---|---|---|
| `ListPageTemplate` | `Template/List Page` | `templates/list_page_template.dart` | fertig | DS-46 |
| `DetailPageTemplate`, `DetailSections`, `DetailSplit`, `DetailLayout` | `Template/Detail Page` | `templates/detail_page_template.dart` | fertig | DS-47 |
| `FormPageTemplate`, `FormSections` | `Template/Form Page` | `templates/form_page_template.dart` | fertig | DS-48 |

## Fachliche Bausteine (in `unsalted_core/lib/src/ui/`)

Aus Design-Komponenten zusammengesetzt (Stand C27); Abschnitte je
Bildschirm in `docs/design/screens.md`.

| Baustein | Datei | aus |
|---|---|---|
| `RecipeCard` | `recipe_list/recipe_card.dart` | `AppListItem` |
| `FoodTile` | `foods/food_tile.dart` | `AppListItem` |
| `VersionTile` | `versions/version_tile.dart` | `AppListItem`, `AppIconButton`, `AppIcon`, `AppStack` |
| `VersionSwitcher` | `recipe_detail/version_switcher.dart` | `AppChoiceChip`, `AppStack`, `AppPadding` |
| `IngredientRow` | `recipe_editor/ingredient_row.dart` | `AppTextField`, `AppSelect`, `AppIconButton`, `AppIcon`, `AppStack` |
| `StepRow` | `recipe_editor/step_row.dart` | `AppTextField` (Startwert, schmal), `AppIconButton`, `AppIcon`, `AppStack` |
| `FoodVariantPickerDialog` | `recipe_editor/food_variant_picker_dialog.dart` | `AppDialog`, `AppTextField` (ohne Lupe, wie bisher), `AppItemList`, `AppListItem`, `AppEmptyState` |
| `NutritionHeader` | `nutrition/nutrition_header.dart` | `AppText`, `AppSurface` (warning) |
| `NutritionTable` | `nutrition/nutrition_table.dart` | `AppKeyValueTable`, `AppSelect`, `AppText` |
| `AmountCalculator` | `nutrition/amount_calculator.dart` | `AppTextField`, `AppStack` |
| `PackageForm` | `foods/package_form.dart` | Abschnitte unter `foods/sections/` (`AppTextField`, `AppSection`, `AppSurface` warning/error) |
| `SnapshotColumn` | `versions/snapshot_column.dart` | `AppText`, `AppPadding`, `AppStack` |
| `ChangeList` | `versions/change_list.dart` | `AppItemList`, `AppListItem`, `AppText`, `AppPadding` |

In Core noch nicht eingesetzt: `AppNotice` (Symbol und runde Ecken wären
eine sichtbare Änderung; Hinweiskästen nutzen `AppSurface`), `AppSkeleton`
(F3), `AppCard`, `AppGrid` (vorbereitet für Karten bzw. Raster ab Tablet).
