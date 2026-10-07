/// Öffentliche Tür des Design-Systems von unsalted (Teil 1.2).
///
/// Enthält ausschließlich Aussehen: Tokens, Theme, Layout, Komponenten und
/// Templates. Keine Fachbegriffe, keine Abhängigkeit außer Flutter
/// (`architecture.yaml`, Rang 0). Jeder Export nennt seine Symbole mit
/// `show`; die Liste prüft DS-03 gegen `test/architecture/public_api_golden.txt`.
library;

// Tokens
export 'src/tokens/breakpoint_tokens.dart' show AppBreakpoints;
export 'src/tokens/color_tokens.dart' show AppColorTokens;
export 'src/tokens/elevation_tokens.dart' show AppElevation;
export 'src/tokens/motion_tokens.dart' show AppMotion;
export 'src/tokens/radius_tokens.dart' show AppRadius;
export 'src/tokens/spacing_tokens.dart' show AppSpace, AppSpacing;
export 'src/tokens/typography_tokens.dart' show AppTypography;

// Theme
export 'src/theme/app_theme.dart' show AppTheme;
export 'src/theme/app_tone.dart' show AppTone;

// Layout
export 'src/layout/app_grid.dart' show AppGrid;
export 'src/layout/app_page.dart' show AppPage;
export 'src/layout/app_section.dart' show AppSection;
export 'src/layout/app_stack.dart' show AppGap, AppPadding, AppStack;
export 'src/layout/responsive.dart' show AppWindowSize, ResponsiveBuilder;

// Komponenten
export 'src/components/buttons/app_button.dart' show AppButton, AppButtonVariant;
export 'src/components/buttons/app_fab.dart' show AppFab;
export 'src/components/buttons/app_icon_button.dart' show AppIconButton;
export 'src/components/cards/app_card.dart' show AppCard;
export 'src/components/icons/app_icon.dart' show AppIcon, AppIconSize;
export 'src/components/icons/app_icons.dart' show AppIcons;
export 'src/components/surfaces/app_divider.dart' show AppDivider;
export 'src/components/surfaces/app_surface.dart' show AppSurface, AppSurfaceTone;
export 'src/components/text/app_text.dart' show AppText, AppTextRole;
export 'src/components/chips/app_chip.dart' show AppChip;
export 'src/components/chips/app_choice_chip.dart' show AppChoiceChip;
export 'src/components/inputs/app_search_field.dart' show AppSearchField;
export 'src/components/inputs/app_select.dart' show AppSelect, AppSelectItem;
export 'src/components/inputs/app_text_field.dart' show AppFieldWidth, AppTextField;
export 'src/components/lists/app_item_list.dart' show AppItemList;
export 'src/components/lists/app_list_item.dart' show AppListItem;
export 'src/components/lists/app_reorderable_list.dart' show AppReorderableList;
export 'src/components/lists/app_swipe_to_delete.dart' show AppSwipeToDelete;
export 'src/components/feedback/app_dialog.dart' show AppDialog, showAppAboutDialog, showAppChoiceDialog, showAppConfirmDialog, showAppDialog;
export 'src/components/feedback/app_empty_state.dart' show AppEmptyState;
export 'src/components/feedback/app_error_state.dart' show AppErrorState;
export 'src/components/feedback/app_loading.dart' show AppLoading, AppProgressBar;
export 'src/components/feedback/app_notice.dart' show AppNotice, AppNoticeKind;
export 'src/components/feedback/app_skeleton.dart' show AppSkeleton;
export 'src/components/feedback/app_snackbar.dart' show AppMessenger, AppSnackbarHandle, showAppMessage;
export 'src/components/data/app_code_block.dart' show AppCodeBlock;
export 'src/components/data/app_key_value_table.dart' show AppKeyValueTable, AppTableRow;
export 'src/components/navigation/app_bottom_action_bar.dart' show AppBottomActionBar;
export 'src/components/navigation/app_navigation_bar.dart' show AppNavigationBar, AppNavigationDestination;
export 'src/components/navigation/app_overflow_menu.dart' show AppMenuEntry, AppOverflowMenu;
export 'src/components/navigation/app_top_bar.dart' show AppTopBar;
