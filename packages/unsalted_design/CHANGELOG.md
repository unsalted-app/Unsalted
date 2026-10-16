# Changelog — unsalted_design

Versionen des Design-Pakets tragen eigene Tags `design-vX.Y.Z`.

## design-v0.2.0 — unveröffentlicht (Teil 1.3, Gestaltung aus Figma)

- Komponenten-Themes aus Tokens (`lib/src/theme/component_themes.dart`): Buttons (Tintenfläche, Tintenkontur, nur Text; Mindesthöhe `size-control`, `radius-s`), Marker-Knopf (Markerfläche, Tintenkontur, flach, `size-fab`), Symbol-Schaltfläche (`size-target`), Eingabefeld (weiße Fläche, Kontur `line-control`, Fokus/Fehler `stroke-focus`), Chips (gewählt invers), Listeneintrag, Trenner (Haarlinie), Meldung (invers, „Rückgängig“ in `action-inverse`, schwebend, höchstens `size-dialog`), Dialog, Menü, Karte, Ladekreis/-balken in Tinte, Kopfleiste (Haarlinie statt Schatten), Navigationsleiste (ohne Pille), Tooltip; Dichte `standard`, Tippziele `padded`. Test DS-52 (D04).
- Tokens aus der Figma-Übergabe: `tokens/unsalted.tokens.json`, Generator `tool/generate_tokens.dart`, alle Dateien unter `lib/src/tokens/` generiert (`*.g.dart`). `AppColorTokens` mit den 28 semantischen Rollen (statt 46 Material-Rollen), `AppTypography` mit elf Stilen (statt 15), `AppRadius` none/xs/s/m/full; neu `AppStroke`, `AppSize`, `AppReflow`, `AppOpacity`, `AppShadow`; `AppElevation` entfällt. `AppTheme` bildet Material-Rollen nach 01-farbe/02-typografie ab, Schrift Atkinson. DS-04/05/07 neu gefasst, DS-51 neu (D03).
- Schrift Atkinson Hyperlegible Next 400/600/700 (TTF, verlustfrei aus den WOFF2 der Übergabe) mit `OFL.txt` unter `lib/fonts/`; `AppFonts` (Familie, Lizenz-Registrierung); Tests DS-49 (Glyphenabdeckung), DS-50 (Lizenz) (D02).

## design-v0.1.0 — unveröffentlicht

- Paket-Gerüst: öffentliche Tür, Architekturtests DS-01, DS-03, DS-06 (C02).
- Tokens: Farbe (hell/dunkel, 46 Material-3-Rollen), Typografie, Abstand, Radius, Höhe, Bewegung, Breakpoints; Werte = Flutter-Standard (C03).
- Theme: `AppTheme.light()`/`.dark()` nur aus Tokens, entspricht dem Flutter-Standard (C04).
- Layout: `AppSpace`, `AppGap`, `AppStack`, `AppPadding`, `AppPage`, `AppGrid`, `AppWindowSize`, `ResponsiveBuilder` (C05).
- Komponenten I: `AppButton`, `AppIconButton`, `AppFab`, `AppIcon`, `AppIcons`, `AppText`, `AppTone`, `AppCard`, `AppSurface`, `AppDivider`; Layout `AppSection` (C06).
- Komponenten II: `AppTextField`, `AppSearchField`, `AppSelect`, `AppListItem`, `AppItemList`, `AppSwipeToDelete`, `AppReorderableList`, `AppChoiceChip`, `AppChip` (C07).
- Komponenten III: `AppNotice`, `AppEmptyState`, `AppErrorState`, `AppLoading`, `AppProgressBar`, `AppSkeleton`, `AppMessenger`/`showAppMessage`, Dialoge (C08).
- Komponenten IV: `AppTopBar`, `AppOverflowMenu`, `AppNavigationBar`, `AppBottomActionBar`, `AppKeyValueTable`, `AppCodeBlock` (C09).
- Templates: `ListPageTemplate`, `DetailPageTemplate` mit `DetailSections`/`DetailSplit`/`DetailLayout`, `FormPageTemplate` mit `FormSections` (C10).
- Katalog `apps/unsalted_widgetbook` (widgetbook 3.25.0) mit allen Komponenten (C11).
- Dokumentation: README, `docs/design/design_system.md`, `components.md`, `screens.md` (C12).
- `AppSurface`: Hinweistöne `info`, `warning`, `error` (Fläche und Inhalt in den container-Rollen), Test DS-20b (C22).
