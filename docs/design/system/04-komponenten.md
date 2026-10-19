# Komponenten-Inventar

Das Inventar kommt aus dem Repository (`docs/design/components.md`, `packages/unsalted_design/lib/src/`). Namen bleiben, damit Figma, Dart und Tests zusammenpassen. Neu sind nur die vier Markenelemente. „Karte“ nennt die Vorschau in diesem System.

## Design-Paket (`unsalted_design`)

| Figma | Dart | Gestalt im Vorschlag | Karte |
|---|---|---|---|
| `Button` · `variant=primary/secondary/tertiary` | `AppButton.primary/.secondary/.tertiary` | Tintenfläche, Tintenkontur, nur Text; Mindesthöhe `size-control`, `radius-s`, `body-strong` | Button |
| `Button/Icon` | `AppIconButton` | `size-target`, Symbol `size-icon`, Pflicht-Tooltip | Button |
| `Button/FAB` | `AppFab` | Marker-Knopf `size-fab` mit Tintenkontur | Fab |
| `Icon`, `Icon/<name>` | `AppIcon`, `AppIcons` | eigenes Linienset (Skizzen), bis dahin Material Symbols 300 | in allen Karten |
| `Text/*` | `AppText` | Rollen auf die elf Stile abbilden | Typografie |
| `Card` | `AppCard` | `surface-raised`, Haarlinie, `radius-m`, kein Schatten | — |
| `Surface/*` | `AppSurface` | Töne `raised`, `sunken`, `inverse`, `info`(neutral), `warning`, `error` | Notice |
| `Divider` | `AppDivider` | `line-hairline`, `stroke-hairline` | Section |
| `Input/Text Field` | `AppTextField` | Beschriftung über dem Feld, weiße Fläche, `line-control`; Fokus `stroke-focus` in `line-focus` | TextField |
| `Input/Search` | `AppSearchField` | wie Textfeld mit `search` | TextField, TopBar |
| `Input/Select` | `AppSelect` | wie Textfeld mit `chevron` | TextField |
| `List/Item`, `List/Items` | `AppListItem`, `AppItemList` | ohne Karte, Haarlinien, Titel `body-strong`; `selected` = Auswahlbalken `stroke-rule` links (Liste und Detail nebeneinander) | ListItem |
| `List/Swipe to Delete` | `AppSwipeToDelete` | `feedback-error-surface` mit `delete` | ListItem |
| `List/Reorderable` | `AppReorderableList` | Ziehgriff `drag-handle`, zusätzlich „Nach oben/unten“ | ScreenRezeptEditor |
| `Chip/Choice` | `AppChoiceChip` | Höhe `size-control-small`, ausgewählt invers mit Häkchen | Chip |
| `Chip/Info` | `AppChip` | als Tag: Höhe `size-mark`, `radius-xs`, `label-small` | Chip |
| `Feedback/Notice` | `AppNotice` | neutral (Info, Erfolg), Orange, Rot – immer mit Symbol | Notice |
| `Feedback/Empty State` | `AppEmptyState` | Leerstelle (gestrichelt, mit Punktraster) mit Satz und Aktion | States |
| `Feedback/Error State` | `AppErrorState` | Symbol, Klartext, „Erneut versuchen“ | States |
| `Feedback/Loading`, `Feedback/Progress Bar` | `AppLoading`, `AppProgressBar` | Ladekreis in Tinte; Ladebalken `stroke-rule` | States |
| `Feedback/Skeleton` | `AppSkeleton` | `surface-sunken`-Blöcke (eingesetzt erst nach Freigabe) | — |
| `Feedback/Snackbar` | `AppMessenger`, `showAppMessage` | invers, „Rückgängig“ in Marker, Restzeitlinie | Snackbar |
| `Feedback/Dialog` | `AppDialog`, `showApp…Dialog` | `surface-raised`, `radius-m`, Aktionen rechts | Snackbar |
| `Navigation/Top Bar` | `AppTopBar` | Titel links, Haarlinie statt Schatten | TopBar |
| `Navigation/Overflow Menu` | `AppOverflowMenu` | `surface-raised`, `shadow-overlay` | — |
| `Navigation/Navigation Bar` | `AppNavigationBar` | Auswahlbalken `stroke-rule` oben statt Pille | NavigationBar |
| `Navigation/Navigation Rail` · `selected=0/1/2` | `AppNavigationBar` ab `breakpoint-medium` | seitliche Leiste links, Breite `size-nav-rail`, Haarlinie rechts, gleiche Ziele und Auswahlbalken | NavigationBar |
| `Navigation/Bottom Action Bar` | `AppBottomActionBar` | Haarlinie oben, Buttons teilen die Breite | ScreenRezeptEditor |
| `Data/Key Value Table` | `AppKeyValueTable` | Deklarationstabelle | KeyValueTable |
| `Data/Code Block` | `AppCodeBlock` | `surface-sunken`, `code` | — |
| `Layout/*` | `AppPage`, `AppSection`, `AppStack`, `AppGap`, `AppPadding`, `AppGrid`, `AppWindowSize`, `ResponsiveBuilder` | Abschnitt mit 3-px-Linie; Inhaltsbreite `size-content-max` | Section |
| `Template/List Page`, `Template/Detail Page`, `Template/Form Page` | `ListPageTemplate`, `DetailPageTemplate`, `FormPageTemplate` | siehe Bildschirm-Muster | Screen… |
| `Media/Image` | — (geplant, Teil 4) | Foto 4:3 mit Fassungsmarke; leer = Leerstelle | Frame |

## Neu (bewusste Ergänzungen)

| Figma | Dart (Vorschlag, fachneutral wegen DS-06) | Zweck | Karte |
|---|---|---|---|
| `Mark` · `state=provisional/fixed/highlighted` | `AppMark` | Zustandsmarke; in Core als `VersionMark` | Mark |
| `Frame` · `state=provisional/fixed`, `Slot` | `AppFrame`, `AppSlot` | Zustandsrahmen; Leerstelle mit Punktraster | Frame |
| `Highlight`, `Change` | `AppHighlight`, `AppChangeText` | Marker-Hinterlegung, alt → neu | Highlight |
| `Value` · `certainty=known/unknown/incomplete` | `AppValue` | Zahl, Einheit, ehrlicher Zustand | Value |

Das Design-Paket darf keine Fachbegriffe enthalten (Test DS-06: Rezept, Version, Zutat, Nährwert, kcal …). Darum heißen die neuen Komponenten fachneutral; die fachlichen Bausteine entstehen in `unsalted_core/lib/src/ui/`.

## Fachliche Bausteine (`unsalted_core/lib/src/ui/`)

| Baustein | Im Vorschlag |
|---|---|
| `RecipeCard` | Titel, Untertitel „· N Versionen“, rechts `VersionMark` der Master- oder neuesten Fassung |
| `VersionSwitcher` → Fassungsleiste | Marken nebeneinander, Auswahl mit 3-px-Balken |
| `VersionTile` | Marke, Bezeichnung, Zustand als Wort, Datum, Aktionen |
| `NutritionHeader` | Kennzahlenleiste (Fertiggewicht, Gesamt, pro Portion) |
| `NutritionTable` | Deklarationstabelle, „davon“-Zeilen eingerückt |
| `AmountCalculator` | zwei Zahlenfelder mit `swap` dazwischen |
| `IngredientRow` | am Handy zweizeilig; nicht verknüpft = gestrichelte Unterstreichung |
| `StepRow` | Nummer, Anweisung, Timer als Tag |
| `ChangeList` | `AppChangeText` je Änderung, Abschnitte mit 3-px-Linie |
| `SnapshotColumn` | Kopf mit Marke und Datum |
| `PackageForm` | Nährwertfelder als Deklaration: Einheit im Feld, ab Tablet zweispaltig |
| `FoodTile`, `FoodVariantPickerDialog` | Name, Marke/Quelle als Untertitel |
