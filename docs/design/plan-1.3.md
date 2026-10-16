# Teil 1.3 – Gestaltung aus Figma: Plan

Phase A · Stand 2026-10-17 · Branch `design-1.3` (von `main` @ `1022185`) ·
**zur Freigabe** — offene Fragen F1–F14 in Abschnitt (f)

Dieses Dokument ist nur der Plan, Code gibt es noch keinen. Phase B beginnt
erst nach Freigabe und läuft Commit für Commit nach Abschnitt (e), in vier
Etappen mit Stopp. Offene Fragen haben Nummern (F1 …), damit sie sich einzeln
beantworten lassen.

Grundlage: `docs/design/UEBERGABE.md` und `docs/design/system/` (Commit
`c8bdfe3`), Figma-Bibliothek `5er28Cr7EMMcPzvusWjNyR`, App-Datei
`5eFqwnCRld6Ibu131541i8` (`docs/design/figma/figma-ids.json`).

---

## 0 Ziel und Leitplanken

- **Ziel:** Das neutrale Material-Aussehen aus Teil 1.2 wird durch das
  Design-System aus Figma ersetzt („Bleistift · Tinte · Marker“: Papier,
  Graphit, Tinte, Marker; Atkinson Hyperlegible Next; Strich- und Tintenlinie;
  Fassungsmarke). Bildschirme legen weiterhin nur fest, *was* angezeigt wird.
- **Werte nur aus der Token-Datei.** `packages/unsalted_design/tokens/unsalted.tokens.json`
  ist die Wahrheit für den Code; ein Generator in `packages/unsalted_design/tool/`
  schreibt die Token-Klassen. Keine Farbe und keine Zahl von Hand — weder in
  Komponenten noch in Themes noch in Core. Ausnahmen wie in Figma (07,
  Abschnitt 1): `0`, volle Breite, Deckkraft 1. DS-04 prüft Generat = JSON,
  DS-51 prüft „keine Zahlen in Komponenten“ (mit Übergangsliste wie C13).
- **Core-Logik unberührt.** `contracts/`, `data/`, `recipe/`, `nutrition/`,
  `food/`, `module/`, `providers/`, Schema, Snapshot-Format, Routen bleiben.
  Die **Core-Tür** (`lib/unsalted_core.dart`, AT-06-Golden) bleibt unverändert.
- **Bildschirm-Dateien unverändert** (lesen, nicht ändern):
  `recipe_list_screen.dart`, `recipe_create_screen.dart`,
  `recipe_editor_screen.dart`, `recipe_detail_screen.dart`,
  `version_list_screen.dart`, `version_compare_screen.dart`,
  `food_list_screen.dart`, `food_editor_screen.dart`, `settings_screen.dart`,
  `export_screen.dart`, `import_screen.dart`. Änderungen in Core nur an
  fachlichen Bausteinen und Abschnitten unter `lib/src/ui/`, jede Datei in
  (c) und (e) benannt. Was nur mit einer Bildschirm-Änderung ginge, ist
  „Nicht Teil von 1.3“ (Ende von (c)).
- **Alle bestehenden Tests bleiben grün.** Jede Testzeile, die sich ändern
  muss, steht einzeln in (d2) mit Commit und Grund. Die übrigen Zeilen —
  besonders die bewusst unveränderten Material-Prüfungen aus C28 — bleiben,
  weil die Komponenten weiter dieselben Material-Widgets bauen und nur über
  Themes gestaltet werden (d3).
- **Sichtbare Abweichungen von Kapitel 22** bekommen je einen Nachtrag im
  neuen Kapitel **28.10** (Liste in (d5)).
- **Golden-Tests** hell/dunkel × Handy/Tablet × Text 100/200 % werden **nur
  unter Linux** erzeugt und verglichen (CI-Runner, gleiche Flutter-Version);
  auf dem Mac sind sie übersprungen (d4).
- **Schrift:** Atkinson Hyperlegible Next, statische TTF 400/600/700, mit
  `OFL.txt` im Design-Paket; kein Laden zur Laufzeit. Fehlende Zeichen
  (→ ✓ ★ µ) erscheinen nie als Text (d4, F6).
- **Design-Paket bleibt Rang 0, nur Flutter** (DS-01, `allowed_in_design`).
  Der Generator liegt in `tool/` außerhalb von `lib/` und darf `dart:io`
  nutzen (DS-01 und `check_architecture.dart` prüfen nur `lib/`).
- Tags (`part1-v1.0.0` … `design-v0.1.0`) bleiben unberührt; neue Tags nur
  nach Freigabe (F14).

---

## Figma-Abgleich (nur gelesen, 2026-10-17)

Variablen der Bibliothek (10 Sammlungen, 140 Variablen) gegen
`docs/design/system/tokens.json`, Namensregel aus 05. **158 Werte stimmen**
(alle 23 Primitive, alle 28 Farbrollen hell und dunkel als Alias auf das
richtige Primitiv, Abstände, Radien, Linien, 18 Größen, Deckkraft,
Bewegung, Breakpoints, Familie, Schnitte, Größe und Zeilenhöhe aller elf
Textstile; Modus `200` verdoppelt überall). Abweichungen:

| Nr | Was | Figma | `tokens.json` | Folge |
|---|---|---|---|---|
| A1 | `reflow/value-column`, `label-min`, `stat-min`, `field-min`, `select-min` bei 200 % | 160, 200, 240, 240, 208 | nur Grundwert (96, 120, 96, 120, 104) | Werte bei 200 % fehlen im Code → F5 |
| A2 | `reflow/rule-inline`, `rule-stacked`, `inset-inline` | 1/0, 0/1, 12/0 (Modi 100/200) | fehlen | → F5 |
| A3 | `family/mono` | „Roboto Mono“ (Platzhalter, laut 07 gewollt) | `ui-monospace, "SF Mono", Menlo, Consolas, monospace` | Code folgt `tokens.json` → F7 |
| A4 | `shadow-overlay` dunkel | 2 Ebenen, die zweite unsichtbar (y 0, blur 0, `#00000000`) | 1 Ebene | sichtbar gleich; Generator liest die JSON |

Nur Formatunterschiede, keine Abweichung: `opacity` in Prozent (6/12/48 ↔
0.06/0.12/0.48), Dauer in Sekunden (0,15 s ↔ 150 ms), Fokus-Schatten in Figma
als Abstände an `color/surface-page`/`color/line-focus` gebunden. Die
App-Datei hat keine eigenen Variablen. Komponenten und Textstile in Figma
waren nicht Teil des Abgleichs; sie werden je Etappe per `get_screenshot`
gegen die Goldens gelesen.

Hinweise zur Übergabe: Das Figma-Startpaket ist laut UEBERGABE älter als
`tokens.json` (ohne `size-nav-rail`, `size-list-pane`, `reflow-*`); der Code
liest es nicht. `system/README.md` endet mit einem generierten Abschnitt
(„Consuming this system“), der auf nicht übergebene Dateien verweist
(`api/tokens.md`, `tokens.css`); für den Code ohne Bedeutung.

---

## (a) Ordnerbaum

`NEU` = neue Datei, `ÄNDERN` = bestehende Datei, `GEN` = vom Generator
geschrieben (nie von Hand), `WEG` = gelöscht. Commit in Klammern.

```text
unsalted/
├─ .github/workflows/
│  ├─ ci.yml                              ÄNDERN  runs-on fest auf ubuntu-24.04 (D01)
│  └─ goldens.yml                         NEU     workflow_dispatch: Goldens unter Linux erzeugen, als Artefakt (D01)
├─ docs/
│  ├─ spezifikation.md                    ÄNDERN  Kapitel 28.10 (D03, ergänzt bis D18)
│  ├─ status.md, decisions.md             ÄNDERN  je Commit
│  └─ design/
│     ├─ plan-1.3.md                      dieses Dokument
│     ├─ design_system.md, components.md, screens.md   ÄNDERN (D18)
│     └─ system/README.md                 ÄNDERN  nur Status „freigegeben“, nach Freigabe (D18, F14)
├─ packages/unsalted_design/
│  ├─ pubspec.yaml                        ÄNDERN  fonts + assets (D02), Version 0.2.0 (D18)
│  ├─ dart_test.yaml                      NEU     Tag `golden` (D01)
│  ├─ tokens/unsalted.tokens.json         NEU     Kopie von docs/design/system/tokens.json (D03)
│  ├─ tool/generate_tokens.dart           NEU     Generator, nur dart:convert/dart:io (D03)
│  ├─ lib/
│  │  ├─ fonts/                           NEU     AtkinsonHyperlegibleNext-{Regular,SemiBold,Bold}.ttf, OFL.txt (D02)
│  │  ├─ unsalted_design.dart             ÄNDERN  Tür (D02, D03, D07, D10)
│  │  └─ src/
│  │     ├─ tokens/
│  │     │  ├─ color_tokens.g.dart        GEN     AppColorTokens.light/.dark: 28 Rollen; Primitive privat (D03)
│  │     │  ├─ typography_tokens.g.dart   GEN     AppTypography: 11 Stile, Familie + Rückfall, tnum (D03)
│  │     │  ├─ spacing_tokens.g.dart      GEN     AppSpacing (Werte unverändert) (D03)
│  │     │  ├─ radius_tokens.g.dart       GEN     AppRadius none/xs/s/m/full (D03)
│  │     │  ├─ stroke_tokens.g.dart       GEN     AppStroke (neu) (D03)
│  │     │  ├─ size_tokens.g.dart         GEN     AppSize inkl. reflow-Grundwerte (neu) (D03, D12)
│  │     │  ├─ opacity_tokens.g.dart      GEN     AppOpacity (neu) (D03)
│  │     │  ├─ shadow_tokens.g.dart       GEN     AppShadow overlay/focus je Modus (neu) (D03)
│  │     │  ├─ motion_tokens.g.dart       GEN     Dauern, Kurve (D03)
│  │     │  ├─ breakpoint_tokens.g.dart   GEN     AppBreakpoints (Werte unverändert) (D03)
│  │     │  ├─ spacing_tokens.dart, motion_tokens.dart, …   ÄNDERN  nur noch Hand-Logik (AppSpace, durationOf) über dem Generat (D03)
│  │     │  └─ elevation_tokens.dart      WEG     ersetzt durch AppShadow (D03)
│  │     ├─ theme/
│  │     │  ├─ app_theme.dart             ÄNDERN  Zuordnung Material-Rollen → Tokens (01-farbe, 02-typografie) (D03)
│  │     │  ├─ component_themes.dart      NEU     Komponenten-Themes nur aus Tokens (D04)
│  │     │  ├─ app_fonts.dart             NEU     Familienname, Lizenz-Registrierung (D02)
│  │     │  └─ app_reflow.dart            NEU     mitwachsende Maße, Interpolation 100/200 (D12)
│  │     ├─ layout/                       ÄNDERN  AppPage (Navigation unten/links), AppSection (3-px-Linie) (D06, D10, D11)
│  │     ├─ components/
│  │     │  ├─ brand/                     NEU     app_mark.dart, app_frame.dart (AppFrame, AppSlot), app_highlight.dart
│  │     │  │                                     (AppHighlight, AppChangeText), app_value.dart, dashed_painter.dart, dot_pattern.dart (D07)
│  │     │  ├─ navigation/app_navigation_bar.dart   ÄNDERN  eigene Komponente: Balken oben, Seitenleiste ab 600 (D10)
│  │     │  └─ …                          ÄNDERN  je Gruppe (D05b, D06, D08–D10)
│  │     └─ templates/                    ÄNDERN  Seitenrand ab 600, Inhaltsbreite, zweispaltig ab 1200 (D11)
│  └─ test/
│     ├─ goldens/                         NEU     support/golden_harness.dart, gl01_catalog_golden_test.dart, Bilder (D01, je Commit)
│     ├─ typography/                      NEU     ds49_glyph_coverage_test.dart, ds50_font_license_test.dart, support/cmap.dart (D02)
│     ├─ tokens/ds04_…, ds05_…            ÄNDERN  auf die Token-Datei umgestellt (D03)
│     ├─ theme/ds07_neutral_theme_test.dart   WEG → ds07_theme_mapping_test.dart NEU (D03)
│     ├─ architecture/ds51_no_numbers_in_components_test.dart   NEU, mit Übergangsliste (D03, leer in D12)
│     └─ components/, layout/, templates/ ÄNDERN/NEU  je Commit (Zeilen in d2)
├─ packages/unsalted_core/
│  ├─ dart_test.yaml                      NEU     Tag `golden` (D01)
│  ├─ lib/src/ui/                         ÄNDERN  nur die Bausteine/Abschnitte aus (c)
│  │  └─ versions/version_mark.dart       NEU     VersionMark aus AppMark (D13)
│  └─ test/
│     ├─ goldens/                         NEU     support/screen_fixtures.dart, gl02_screens_golden_test.dart, Bilder (D01)
│     └─ ui/…                             ÄNDERN  nur die Zeilen aus (d2); neue Tests UI-67 ff.
└─ apps/
   ├─ unsalted_app/
   │  ├─ pubspec.yaml                     ÄNDERN  flutter_localizations (D17, nur nach F2)
   │  ├─ lib/main.dart                    ÄNDERN  Schriftlizenz (D02), Navigation über AppPage (D10/D17), Deutsch (D17, F2)
   │  └─ test/                            ÄNDERN  Zeilen aus (d2); APP-03 neu (D17)
   └─ unsalted_widgetbook/
      ├─ lib/catalog/*.dart               ÄNDERN  neue Tokens, Markenelemente, Text 200 %
      └─ test/catalog_test.dart           ÄNDERN  Z. 22–23 (Ausnahmeliste), WB-04 neu (D12)
```

---

## (b) Tokens, Theme, Schrift, Komponenten

### b1 Token-Datei und Generator

- **Ort:** `packages/unsalted_design/tokens/unsalted.tokens.json` (Format der
  Übergabe: `color.tokens[]` mit `value.light/.dark` bzw. `{alias}`, `type.groups[].styles[]`,
  übrige Gruppen `tokens[]`). `docs/design/system/tokens.json` bleibt als
  Übergabe-Archiv; DS-04 prüft, dass beide Dateien byteweise gleich sind (F8).
- **Generator** `dart run tool/generate_tokens.dart` (ohne Pakete): liest die
  JSON, löst Aliase auf, schreibt die `*.g.dart` mit Kopfzeile „GENERIERT —
  nicht von Hand ändern“, sortiert und deterministisch (zweimal laufen →
  identisch). Jeder Wert trägt seinen Figma-Namen im Doku-Kommentar und in
  `byFigmaName` (wie bisher).
- **Namensregel (05):** `color/text-secondary` → `AppColorTokens.light.textSecondary`;
  Primitive privat; `space/l` → `AppSpacing.l` (Parameter `AppSpace.l`);
  `radius/s` → `AppRadius.s`; `stroke/rule` → `AppStroke.rule`;
  `size/control` → `AppSize.control`; `opacity/pressed` → `AppOpacity.pressed`;
  `shadow/overlay` → `AppShadow.overlay(brightness)`; `motion/duration/long`
  → `AppMotion.long`; `breakpoint/expanded` → `AppBreakpoints.expanded`;
  `type/data-strong` → `AppTypography.dataStrong`.
- **Umrechnung:** `px` → `double`; `ms` → `Duration`; `cubic-bezier(…)` →
  `Cubic`; CSS-Schatten → `List<BoxShadow>`; Schriftstapel `families.mono`
  → `fontFamily` + `fontFamilyFallback` (erster Eintrag ohne Anführungszeichen
  bzw. Rest); `fontWeight` → `FontWeight.wNNN`; Zeilenhöhe → `height` =
  lineHeight / fontSize. Tabellarische Ziffern (`FontFeature.tabularFigures()`)
  für `data`, `data-strong`, `label-small` und `display` — die Liste steht in
  den Stil-Hinweisen der JSON (`usage`/`note`), der Generator liest sie aus
  einer festen Zuordnung Stilname → tnum, die DS-04 gegen 02-typografie prüft.
- **Unverändert gegenüber Teil 1.2:** Abstandsskala, Breakpoints, Dauern
  (Werte gleich, nur generiert). **Neu:** `AppStroke`, `AppSize`,
  `AppOpacity`, `AppShadow`. **Entfällt:** `AppElevation` (Schatten nur noch
  `shadow-overlay`, sonst flach). `AppRadius` bekommt die neue Skala
  (none 0, xs 2, s 4, m 8, full); `l`/`xl` entfallen.

### b2 Theme

- `AppTheme.light()/.dark()` bauen das `ColorScheme` aus den 28 Rollen nach
  der Tabelle „Abbildung auf Material 3“ (01-farbe) — alle 46 Material-Rollen
  belegt, kein Platzhalter-Lila mehr — und das `TextTheme` nach der Tabelle in
  02-typografie (15 Rollen → 11 Stile). Familie `AtkinsonHyperlegibleNext`
  aus dem Paket (`package: 'unsalted_design'`). `ListTileTheme` setzt den
  Untertitel ausdrücklich auf `body-small` (Hinweis in 02).
- `component_themes.dart` (D04): Buttons, FAB, Symbol-Schaltfläche,
  Eingabefeld, Chips, Listeneintrag, Trenner, Snackbar, Dialog, Menü,
  Tooltip, Fortschritt, Kopfleiste — Fläche, Kontur, Ecke, Innenabstand,
  Mindesthöhe nur aus Tokens (Tabelle 07, Abschnitt 7). Zustände:
  Überlagerung `text-primary` mit `opacity-hover`/`opacity-pressed`, Fokus
  als `shadow-focus` (2 px Papier, 2 px Tinte).
- Dunkelmodus folgt weiter dem System (F4 aus 1.2).

### b3 Schrift

- Quelle: vollständige statische TTF aus der Originalquelle der Schrift, nicht
  die WOFF2 der Übergabe (F6). Version, Herkunft und SHA-256 je Datei in
  `decisions.md`. Ablage `packages/unsalted_design/lib/fonts/` mit `OFL.txt`
  (aus `docs/design/system/assets/Lizenzen/OFL-Atkinson-Hyperlegible-Next.txt`).
- `pubspec.yaml`: `flutter: fonts:` (Familie `AtkinsonHyperlegibleNext`,
  Schnitte 400/600/700) und `assets: [lib/fonts/OFL.txt]`.
- `AppFonts.registerLicenses()` registriert die OFL über `LicenseRegistry`
  (Text per `rootBundle`); aufgerufen einmal in `apps/unsalted_app/lib/main.dart`,
  damit sie unter „Über unsalted“ → Lizenzen erscheint.
- `code`: Systemschrift aus dem Stapel der JSON (F7), keine weitere Datei.

### b4 Komponenten

Die Komponenten behalten Namen, Tür und — wo Tests sie prüfen — das
Material-Widget, das sie bauen; die Gestalt kommt aus den Themes und den
Token-Klassen. Abweichend davon bekommen eine eigene Darstellung:
`AppNavigationBar` (Auswahlbalken oben statt Pille; Seitenleiste ab 600),
`AppTextField` (Beschriftung über dem Feld statt schwebend), `AppEmptyState`
(Leerstelle mit Strichlinie und Punktraster), `AppSection` (3-px-Linie,
`heading`), `AppKeyValueTable` (Deklaration).

Neu (fachneutral wegen DS-06, Karten in `system/components/`):

| Figma | Dart | Datei | Zweck |
|---|---|---|---|
| `Mark` · `state=provisional/fixed/highlighted`, `seal` | `AppMark`, `AppMarkState` | `components/brand/app_mark.dart` | Zustandsmarke, Höhe `size-mark`, Strichlinie/Tinte/Marker |
| `Frame` · `state`, `Slot` | `AppFrame`, `AppSlot` | `components/brand/app_frame.dart` | Zustandsrahmen; Leerstelle mit Punktraster |
| `Highlight`, `Change` | `AppHighlight`, `AppChangeText` | `components/brand/app_highlight.dart` | Marker-Hinterlegung; alt gestrichen → neu markiert, Pfeil als Symbol |
| `Value` · `certainty` | `AppValue`, `AppCertainty` | `components/brand/app_value.dart` | Zahl + Einheit (U+00A0), „—“, „*“ |
| — | (privat) | `components/brand/dashed_painter.dart`, `dot_pattern.dart` | Strichlinie aus `stroke-dash`/`stroke-gap`, Punktraster aus `size-dot`/`space-xl`/`line-dot` |
| `Navigation/Navigation Rail` | `AppNavigationBar` ab `breakpoint-medium` | `components/navigation/app_navigation_bar.dart` | gleiche Ziele, Balken oben am Ziel, Breite `size-nav-rail` |

`AppIcons` (D05b): Outlined-Varianten der Material Icons, dazu `timer`,
`arrow`, `back`, `lock`, `more`, `close`, `undo`, `chevron`, `link`,
`photo`, `swap`; `star` bleibt gefüllt (Gegenstück zu `star-outline`).
`AppIconSize` nur noch Token-Größen (`xs` 16, `s` 20, `m` 24); `l` (48)
entfällt mit der Leerstelle (D09).

---

## (c) Core-Bausteine und Abschnitte

Pfade relativ zu `packages/unsalted_core/lib/src/ui/`. Nur diese Dateien
ändern sich in Core; Bildschirm-Dateien, Logik, Keys (`ValueKey(id)`,
`package_form_warning`/`_error`) und Texte bleiben.

| Commit | Datei | Änderung | Bildschirm |
|---|---|---|---|
| D13 | `versions/version_mark.dart` **NEU** | `VersionMark(version:, isMaster:)` aus `AppMark`; Text „V{n}“ bzw. „V{n} · label“, Semantik „Version n, Entwurf/eingefroren[, Master]“ | 4, 7, 3 |
| D13 | `recipe_detail/version_switcher.dart` | Fassungsleiste: Marken nebeneinander, Auswahl als 3-px-Balken, Tippziel `size-target`; Rückgabe/Callbacks unverändert | 4 |
| D13 | `versions/version_tile.dart` | Marke statt Titeltext (genau ein „V{n}“ je Eintrag), Zustand als Wort, Master: Markerfläche + Wort „Master“ statt Stern; Aktionen und Tooltips unverändert | 7 |
| D14 | `versions/change_descriptions.dart` | zusätzlich strukturierte Teile (Gegenstand, alt, neu); `describeChanges` liefert **dieselben Strings** wie heute (Tests unverändert) | 8 |
| D14 | `versions/change_list.dart` | je Änderung `AppChangeText` (alt gestrichen, Pfeil-Symbol, neu markiert), Semantik = bisheriger Text | 8 |
| D15 | `nutrition/nutrition_header.dart` | Kennzahlenleiste (Fertiggewicht, Gesamt, pro Portion), Hinweis „Nicht berechenbar“ als `AppNotice` warning | 5 |
| D15 | `nutrition/nutrition_table.dart` | Deklaration: Tintenlinie unter dem Kopf, Haarlinien, `data` tnum rechtsbündig, „davon“ eingerückt, kcal-Zeile `data-strong`; Zeilen und Fußnoten unverändert | 5 |
| D15 | `nutrition/amount_calculator.dart` | zwei Zahlenfelder mit Einheit im Feld, `swap` dazwischen (nur Darstellung) | 6 |
| D16 | `recipe_editor/ingredient_row.dart` | am Handy zweizeilig (Menge in `reflow-value-column`, Name; darunter Einheit, Notiz); nicht verknüpft = gestrichelte Unterstreichung | 3 |
| D16 | `recipe_editor/step_row.dart` | Nummer in `size-index-column` (`data-strong`), Timer als Tag | 3 |
| D16 | `recipe_editor/sections/recipe_editor_frozen_section.dart` | `AppFrame(fixed)` mit `VersionMark(seal)`; Hinweistext unverändert | 3 |
| D16 | `foods/sections/package_validation_section.dart` | `AppNotice` warning/error statt `AppSurface` (mit Symbol), Keys unverändert | 10 |
| D16 | `foods/sections/package_nutrients_section.dart` | Nährwertfelder zweispaltig ab `breakpoint-medium` (`AppGrid`), Reihenfolge unverändert | 10 |
| D16 | `recipe_detail/sections/recipe_detail_steps_section.dart` | Schrittnummer und Timer-Tag wie `StepRow` | 4 |

Alle übrigen Abschnitte und Bausteine ändern sich nur mittelbar über die
Komponenten (keine Datei-Änderung).

**Nicht Teil von 1.3** (bräuchte eine Bildschirm-Änderung, neue Daten oder
eine Textänderung nach Kapitel 22): Rezepttitel als `display` im Inhalt und
leere Kopfleiste im Rezeptdetail; Fassungsmarke und Versionszahl je Rezept in
der Liste (Daten aus `watchVersions`); Suchtreffer mit Marker (die Liste
kennt den Suchbegriff nicht); Reihenfolge der Detail-Abschnitte; Kopfzeile
mit beiden Marken statt Spalten im Vergleich; Signaturmomente Einfrieren und
Küren (Zustand im Bildschirm); Liste und Detail nebeneinander (F4);
Halbgeviertstrich statt Geviertstrich in „Eingefroren — als neuen Entwurf
kopieren?“ (Text aus Kapitel 22); pro Portion und pro 100 g in der
Editor-Vorschau (ohne Bildschirm-Änderung möglich, aber eine inhaltliche
Erweiterung — eigene Freigabe).

---

## (d) Tests, Regeln, Kapitel 28

### d1 Neue Tests

| ID | Ort | Prüfregel | Commit |
|---|---|---|---|
| GL-01 | Design `test/goldens/` | Katalogbilder je Komponentengruppe × 8 Varianten | D01 ff. |
| GL-02 | Core `test/goldens/` | fünf Musterbildschirme (1, 3, 4, 8, 10) im Inhaltszustand × 8 Varianten | D01 ff. |
| DS-04 (neu gefasst) | Design | Generat = Generator(JSON); JSON = `docs/design/system/tokens.json`; 28 Rollen hell/dunkel; 11 Stile; Namensregel 05; tnum-Zuordnung = 02 | D03 |
| DS-05 (neu gefasst) | Design | Kontrastpaare aus 01-farbe (Text ≥ 4,5 : 1, Kontur ≥ 3 : 1; `line-dot` und `marker`/`surface-page` ausdrücklich ausgenommen) | D03 |
| DS-07 (neu gefasst) | Design | Theme = Zuordnungstabellen 01/02 (46 Farbrollen, 15 Typo-Rollen), ersetzt „neutral“ | D03 |
| DS-49 | Design | Glyphenabdeckung: Zeichen in String-Literalen unter `packages/unsalted_design/lib/` und `packages/unsalted_core/lib/src/ui/` stehen in der `cmap` der TTF (Kommentare ignoriert; Ausnahme nur `change_descriptions.dart` für den Pfeil, der nie gezeichnet wird, D14) | D02 |
| DS-50 | Design | `AppFonts.registerLicenses` registriert die OFL | D02 |
| DS-51 | Design | keine Zahlen in `components/`, `layout/`, `templates/`, `theme/` (`EdgeInsets(…Zahl)`, `SizedBox` mit Zahl, `BorderRadius.circular(Zahl)`, `fontSize:`, `Size(…)`, `Duration(…)`); Übergangsliste schrumpft je Commit | D03–D12 |
| DS-52 | Design | Komponenten-Themes aus Tokens (z. B. Button-Mindesthöhe = `AppSize.control`, Ecke = `AppRadius.s`, Fokusring = `AppShadow.focus`) | D04 |
| DS-53–58 | Design | `AppMark`, `AppFrame`/`AppSlot`, `AppHighlight`, `AppChangeText`, `AppValue`, Strichlinie/Punktraster (dunkel = `line-dot` dunkel) | D07 |
| DS-59 | Design | Navigation: unter 600 unten, ab 600 links (`size-nav-rail`); Systemleisten ohne Textskalierung, Tooltip bei langem Drücken | D10 |
| DS-60 | Design | Templates: Seitenrand `space-l`/`space-xl`, Inhalt ≤ `size-content-max`, zweispaltig ab `breakpoint-large` | D11 |
| WB-04 | Widgetbook | alle Anwendungsfälle bei Textgröße 200 % ohne Überlauf | D12 |
| UI-67–74 | Core | Fassungsleiste (Auswahl, Semantik), Master-Marke mit Wort, `AppChangeText`-Semantik = bisheriger Text, Unterstreichung nicht verknüpfter Zutaten, `AppNotice` im Verpackungsformular mit Keys, Kennzahlenleiste, zweispaltige Nährwertfelder ab 600 | D13–D16 |
| APP-03 | App | Systemtexte deutsch (`MaterialLocalizations` → „Zurück“) | D17 (F2) |

### d2 Testzeilen, die sich ändern (einzeln)

Pfade ab Repository-Wurzel; Zeilennummern Stand `c8bdfe3`. Jede Änderung nur
wie angegeben; Ablauf, Testdaten und übrige Erwartungen bleiben.

**D03 — Tokens und Theme-Zuordnung**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_design/test/tokens/ds04_tokens_complete_test.dart:12–76` | 46 Material-Rollen, 15 Typo-Rollen = Flutter-Skala | DS-04 neu (d1) | Werte kommen aus der Token-Datei, nicht mehr aus `ThemeData()`; Z. 78–92 (Bewegung reduzieren) bleiben |
| `packages/unsalted_design/test/tokens/ds05_contrast_test.dart:20–49, 52–60` | 45 Paare Material-Rollen | Paare aus 01-farbe mit Schwelle je Art | neue Rollen; Formeltest Z. 62–65 bleibt |
| `packages/unsalted_design/test/theme/ds07_neutral_theme_test.dart` (ganze Datei) | Theme = `ThemeData()` | `ds07_theme_mapping_test.dart` | „neutral“ war laut `design_system.md` ausdrücklich bis zum Figma-Design befristet |
| `packages/unsalted_design/test/architecture/public_api_golden.txt` | `AppElevation` | + `AppStroke`, `AppSize`, `AppOpacity`, `AppShadow`, `AppFonts`; − `AppElevation` | Tür ändert sich bewusst (DS-03, CHANGELOG) |
| `apps/unsalted_widgetbook/test/catalog_test.dart:22–23` | Ausnahmeliste mit `AppElevation` | neue Token-Klassen statt `AppElevation` | WB-02 nimmt Token-Klassen aus |
| `apps/unsalted_app/test/theme_test.dart:48` | `expected.surface` | `expected.surfacePage` | `AppColorTokens` führt die 28 Rollen, `ColorScheme.surface` zeigt laut 01 auf `surface-page` |

**D05a — Symbol-Finder (nur Finder, wie C28; vor der Umstellung auf Outlined)**

| Datei:Zeile | heute | künftig |
|---|---|---|
| `packages/unsalted_core/test/ui/versions/version_list_screen_test.dart:133` | `Icons.copy` | `AppIcons.copy` |
| `…/version_list_screen_test.dart:166` | `Icons.delete_outline` | `AppIcons.deleteOutline` |
| `…/version_list_screen_test.dart:198` | `Icons.compare_arrows` | `AppIcons.compare` (Typ `IconButton` bleibt) |
| `packages/unsalted_core/test/ui/recipe_editor/ingredient_row_test.dart:120` | `Icons.search` | `AppIcons.search` |
| `packages/unsalted_core/test/ui/recipe_editor/recipe_editor_screen_test.dart:176` | `Icons.delete_outline` | `AppIcons.deleteOutline` |
| `…/recipe_editor_screen_test.dart:348, 349` | `Icons.drag_handle` | `AppIcons.dragHandle` |
| `…/recipe_editor_screen_test.dart:396` | `Icons.search` | `AppIcons.search` |
| `apps/unsalted_app/test/widget_test.dart:38, 43, 49` | `Icons.restaurant`, `Icons.settings`, `Icons.menu_book` | `AppIcons.restaurant`, `.settings`, `.book` (+ Import der Design-Tür) |

Grund: Mit D05b zeigen die Symbole auf Outlined-Varianten (andere
`IconData`); über `AppIcons` bleibt der Test unabhängig davon. Vor und nach
D05a grün, weil `AppIcons.x == Icons.x` bis D05b gilt.
`recipe_detail_menu_context_test.dart:78, 90` (`icon: Icons.info`) sind
Eingaben an eine Modul-Aktion, keine Finder — bleiben.

**D06 — Komponenten I**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_design/test/components/ds18_text_test.dart:30` | `FontWeight.bold` | `FontWeight.w600` | `AppText.strong` = `body-strong` (600) laut 02 |

**D08 — Eingaben und Listen**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_core/test/ui/nutrition/amount_calculator_test.dart:38, 50, 76` | `tester.widget<TextField>(find.widgetWithText(TextField, '…'))` | `tester.widget<TextField>(find.descendant(of: find.widgetWithText(AppTextField, '…'), matching: find.byType(TextField)))` | Beschriftung steht über dem Feld, nicht mehr im Material-`TextField` (TextField-Karte); geprüft wird weiter das gerenderte `TextField` |
| `packages/unsalted_core/test/ui/foods/package_form_test.dart:118` | dto. `'Salz (g)'` | dto. | dto. |
| `packages/unsalted_core/test/ui/recipe_detail/recipe_detail_screen_test.dart:512, 513` | `find.widgetWithText(TextField, 'Gramm'/'kcal')` | `find.descendant(of: find.widgetWithText(AppTextField, …), matching: find.byType(TextField))` | dto.; Z. 516, 519 bleiben |
| `packages/unsalted_design/test/components/ds23_inputs_test.dart:37` | `find.widgetWithText(TextField, 'Aus')` | `find.descendant(of: find.widgetWithText(AppTextField, 'Aus'), matching: find.byType(TextField))` | dto. |

**D09 — Rückmeldung**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_design/test/components/ds17_icons_test.dart:24, 29` | `AppIconSize.l`, `Size(48, 48)` | `AppIconSize.m`, `Size(AppSize.icon, AppSize.icon)` | `l` (48) ist kein Token; Größen nur `size-icon*` |
| `packages/unsalted_design/test/components/ds32_feedback_test.dart:54` | `Size(48, 48)` | `Size(AppSize.icon, AppSize.icon)` | Leerstelle mit Symbol `size-icon` (States-Karte) |

**D10 — Navigation**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_design/test/components/ds40_navigation_test.dart:75` | `find.byType(NavigationBar)` | `find.byType(AppNavigationBar)` + Auswahlbalken (DS-59) | eigene Komponente (Balken oben statt Pille, NavigationBar-Karte) |
| `apps/unsalted_app/test/theme_test.dart:52` | `find.descendant(of: find.byType(NavigationBar), …)` | `of: find.byType(AppNavigationBar)` | dto.; die Testfläche ist 800 breit, also ab D17 Seitenleiste |
| `packages/unsalted_design/test/components/ds40_navigation_test.dart:29` | `kToolbarHeight + AppTopBar.bottomHeight` | `AppSize.topBar + AppTopBar.bottomHeight` — nur falls sich die Höhe des Suchbereichs ändert (TopBar-Karte: Innenabstand `s`/`l`/`m`) | Werte aus Tokens |

**D11 — Templates**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_design/test/templates/ds46_templates_test.dart:177` | `field.left == AppSpacing.l` | Seitenrand `l` unter 600, sonst `xl`, Inhalt ≤ 720 zentriert | Seitenrand ab 600 und Inhaltsbreite (UEBERGABE 2) |
| `…/ds46_templates_test.dart:178` | `width == size.width - 2 * AppSpacing.l` | dto. | dto. |

**D13 — Fassungsmarke und Master**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_core/test/ui/recipe_detail/recipe_detail_screen_test.dart:229–230` | `widgetList<ChoiceChip>(…).singleWhere((c) => c.selected)`, `label as Text` | gewähltes Ziel der Fassungsleiste (`AppMark` mit `selected`) | Fassungsleiste statt Auswahl-Chips (Nachtrag 28.10, Bildschirm 4) |
| `…/recipe_detail_screen_test.dart:237, 718, 761, 772` | `find.widgetWithText(AppChoiceChip, …)` | `find.widgetWithText(VersionMark, …)` | dto.; nur der Typ des Finders |
| `packages/unsalted_core/test/ui/versions/version_list_screen_test.dart:96` | `find.byIcon(Icons.star)`, `findsOneWidget` | `find.text('Master')`, `findsOneWidget` | Master als Marke + Wort statt Stern (Nachtrag 28.10, Bildschirm 7) |
| `…/version_list_screen_test.dart:249` | `find.byIcon(Icons.star)`, `findsNothing` | `find.text('Master')`, `findsNothing` | dto. |
| `…/version_list_screen_test.dart:254, 281` | `find.descendant(of: tileOf(…), matching: find.byIcon(Icons.star))` | `… matching: find.text('Master')` | dto. |

**D14 — Änderungsliste**

| Datei:Zeile | heute | künftig | Grund |
|---|---|---|---|
| `packages/unsalted_core/test/ui/versions/version_compare_screen_test.dart:152` | `find.textContaining('Mehl: 100 g → 200 g')` | `find.bySemanticsLabel('Mehl: 100 g → 200 g')` | Der Pfeil ist ein Symbol, alt und neu sind getrennte Textteile; der bisherige Text bleibt als Semantik |

`change_descriptions_test.dart` (Z. 77–160) und `decimal_comma_test.dart:86–88`
bleiben, weil `describeChanges` dieselben Strings liefert.

### d3 Bewusst unverändert (C28) — bleiben so

Die Komponenten bauen weiter das jeweilige Material-Widget; nur das Theme
gestaltet es. Deshalb ändern sich diese Zeilen nicht:
`import_screen_test.dart:134`, `version_compare_screen_test.dart:249`,
`recipe_editor_screen_test.dart:524` (`widget<ElevatedButton>`);
`recipe_create_screen_test.dart:54, 60, 79`, `food_editor_screen_test.dart:78, 84, 143`
(`widget<FloatingActionButton>` — der Marker-Knopf bleibt ein FAB);
`version_list_screen_test.dart:198` (`widget<IconButton>`, nur der Symbol-Finder
ändert sich in D05a); `recipe_detail_screen_test.dart:681`,
`recipe_list_screen_test.dart:229`, `food_list_screen_test.dart:212`
(`SnackBarAction` — „Rückgängig“ bleibt eine `SnackBarAction`, Farbe über
`SnackBarThemeData.actionTextColor = action-inverse`). Geändert werden aus der
C28-Liste nur: `amount_calculator_test.dart:38, 50, 76`,
`package_form_test.dart:118`, `recipe_detail_screen_test.dart:512, 513`
(D08, Beschriftung über dem Feld) und `recipe_detail_screen_test.dart:229`
(D13, Fassungsleiste).

Ebenso bleiben die Design-Tests, die Material-Typen prüfen: DS-14
(`ElevatedButton`, `TextButton`, `IconButton`, `FloatingActionButton`,
`CircularProgressIndicator`), DS-11 (`Scaffold`), DS-19/DS-20b/DS-32
(Farbrollen `surfaceContainerHigh`, `secondaryContainer`, `tertiaryContainer`,
`errorContainer` — die Zuordnung in 01 belegt sie mit den neuen Tokens),
DS-23 übrige Zeilen, DS-26 (`ListTile`, `ReorderableListView`, `ChoiceChip`),
DS-38 (`AlertDialog`), DS-40:30, 46, 113, 124, DS-46 übrige Zeilen.

### d4 Goldens, Schrift im Test, Glyphen

- **Wo erzeugt:** nur unter Linux, im Workflow `.github/workflows/goldens.yml`
  (manuell, Eingabe Branch; `ubuntu-24.04`, Flutter 3.47.5 wie `ci.yml`):
  `flutter test --tags golden --update-goldens` in Design und Core, Bilder
  als Artefakt. Bilder werden heruntergeladen, durchgesehen und mit dem Commit
  eingecheckt, der sie verursacht. Verglichen wird in `ci.yml` (gleicher
  Runner, fest auf `ubuntu-24.04` statt `ubuntu-latest`). Lokal gibt es kein
  Docker; ein Mac erzeugt andere Bilder.
- **Auf dem Mac:** Golden-Dateien tragen `@TestOn('linux')` und
  `@Tags(['golden'])` — `flutter test` bleibt grün und überspringt sie.
- **Varianten:** hell/dunkel × Handy 390 × 844 / Tablet 1024 × 1366 ×
  `TextScaler.linear(1.0/2.0)` = 8 je Motiv. Umfang (F11): GL-01 etwa
  12 Gruppen, GL-02 fünf Bildschirme → rund 136 Bilder.
- **Schrift im Test:** `flutter_test` lädt gebündelte Schriften nicht
  (geprüft: Testlauf in `flutter_tools` liest kein `FontManifest`); die
  Golden-Harness lädt Atkinson (`lib/fonts/*.ttf`) und `MaterialIcons`
  (`$FLUTTER_ROOT/bin/cache/artifacts/material_fonts/`) per `FontLoader` —
  **nur in Golden-Tests**, nicht global über `flutter_test_config.dart`, damit
  sich die Textmaße der übrigen 600+ Tests nicht ändern. Für den
  Grundstand (D01) zusätzlich Roboto aus demselben Ordner.
- **Glyphen:** Laut 02 fehlen → ✓ ★ µ. ✓ und ★ kommen nur als Symbol vor
  (`AppIcons.check`, `.star`), µ gar nicht (keine Mikro-Einheit im
  `UnitCatalog`). → steht heute nur in den Texten der Änderungsliste
  (`change_descriptions.dart:84–143`) und wird ab D14 als Symbol `arrow`
  gezeichnet; der Text mit → bleibt Semantik und Testgrundlage. DS-49 hält
  das fest. Was Nutzer eintippen (Rezepttitel mit Sonderzeichen), fällt auf
  dem Gerät auf die Systemschrift zurück; in Goldens kommt es nicht vor.

### d5 Nachträge Kapitel 28 (neues 28.10 „Teil 1.3 – Gestaltung aus Figma“)

1. **28.9.5 / Kapitel 22, gemeinsame Regeln.** Der Satz „sichtbar anders sind
   nur Farben aus dem Theme …“ gilt ab 1.3 nicht mehr: Das Aussehen folgt
   `docs/design/system/` (Papier, Tinte, Marker; Atkinson Hyperlegible Next;
   Linien statt Schatten). Reihenfolge, Texte und Funktion bleiben. Ladezustand
   = Ladekreis in Tinte; leerer Zustand = Leerstelle (gestrichelt, Punktraster)
   mit Symbol, Satz, Aktion; „Keine Treffer.“ ohne Punktraster. (D03/D09)
2. **Kapitel 22, Bildschirm 1, 2, 9, 10 — Hauptaktion.** Der FAB ist der
   Marker-Knopf (Markerfläche, Tintenkontur), Funktion unverändert. (D06)
3. **Bildschirm 3.** Zutatenzeile am Handy zweizeilig; nicht verknüpfte Zutat
   gestrichelt unterstrichen; Umsortieren zusätzlich über die
   Bedienhilfe-Aktionen „Nach oben“/„Nach unten“ (WCAG 2.5.7); eingefrorene
   Ansicht im Zustandsrahmen mit Fassungsmarke und Siegel. (D08, D16)
4. **Bildschirm 4.** Der Versionsumschalter ist eine Fassungsleiste aus
   Fassungsmarken mit Auswahlbalken; Beschriftung „V{versionIndex}“ +
   optionales `label` unverändert. Ab 1200 zweispaltig (Haupt: Versionen,
   Beschreibung, Nährwerte · Neben: Zutaten, Schritte, Erweiterungen). (D11, D13)
5. **Bildschirm 5/6.** Kopf als Kennzahlenleiste, Tabelle als Deklaration
   (Tintenlinie, Haarlinien, tabellarische Ziffern); Inhalt, Reihenfolge,
   `*`/Fußnoten und `notCalculable`-Hinweis unverändert; Mengenrechner mit
   Einheit im Feld. (D15)
6. **Bildschirm 7.** Statt Badge „Entwurf“/„Eingefroren“ eine Fassungsmarke
   (gestrichelt = Entwurf, Tinte = eingefroren) mit dem Zustandswort; die
   Master-Version trägt die Markerfläche und das Wort „Master“ statt eines
   Sterns. Aktion „Als Master markieren“ unverändert (28.4.4). (D13)
7. **Bildschirm 8.** Änderungen erscheinen als „alt durchgestrichen → neu
   markiert“, der Pfeil ist ein Symbol; der Text aus 28.4.5 bleibt als
   Semantik. Zwei-Spalten-Ansicht und Übernahme unverändert. (D14)
8. **Bildschirm 10.** Warnungen orange mit Symbol (statt „gelb“), Fehler rot
   mit Symbol, je als Hinweiszeile; Speichern-Regel unverändert. Nährwertfelder
   ab 600 zweispaltig. (D16)
9. **Teil 1.1b — Rückgängig.** Die Meldung steht auf inverser Fläche, „Rückgängig“
   in Marker, mit ablaufender Restzeitlinie (bei „Bewegung reduzieren“
   statisch); Frist und Ablauf unverändert 5 s. (D09)
10. **28.2.4 — App-Hülle.** Unter 600 Navigationsleiste unten, ab 600 seitliche
    Leiste (gleiche Ziele). Kopfleiste und Navigation folgen der Textgröße
    nicht; langes Drücken zeigt das Ziel als Tooltip. (D10, D17 — nur nach F4)
11. **Barrierefreiheit — große Schrift.** Inhalte wachsen bis 200 % mit, ohne
    abgeschnittenen Text; Nebeneinander wird untereinander (`reflow-*`). (D12)
12. **28.9.1 / Kapitel 4.1 — Design-Paket.** Enthält Token-Datei, Generator
    (`tool/`) und die Schrift mit OFL; Abhängigkeit weiter nur `flutter`. Die
    App registriert die Schriftlizenz („Über unsalted“ → Lizenzen). (D02, D03)
13. **Kapitel 23 / 28.5 — Tests.** Neue IDs GL-01/02, DS-49–60, WB-04,
    UI-67–74, APP-03; DS-04/05/07 neu gefasst. Golden-Bilder werden nur unter
    Linux erzeugt und verglichen, auf anderen Systemen übersprungen. (D01–D18)
14. **Nur nach F2 — Sprache.** Die App setzt Deutsch für die Systemtexte der
    Bedienelemente (`GlobalMaterialLocalizations`). (D17)
15. **Texte und Zeichen.** UI-Texte verwenden nur Zeichen der Schrift (DS-49);
    Pfeil, Häkchen und Stern erscheinen als Symbol. (D02, D14)

---

## (e) Commit-Reihenfolge

Jeder Commit: `flutter analyze` und `flutter test` in allen betroffenen
Paketen grün (Mac: ohne Goldens; CI: mit Goldens), `dart run
tool/check_architecture.dart` Exit 0, `docs/status.md` und
`docs/decisions.md` nachgeführt; Präfix „Teil 1.3 Dxx: …“. Wo sich Bilder
ändern: neue Goldens aus `goldens.yml` im selben Commit, Abweichung im PR
sichtbar. Kein Merge, kein Tag.

### Etappe 1 — Grundlage (Stopp nach D05b)

**D01 — Golden-Grundlage und Grundstand (F3).**
Neu: `.github/workflows/goldens.yml`; `packages/unsalted_design/dart_test.yaml`,
`test/goldens/support/golden_harness.dart`, `test/goldens/gl01_catalog_golden_test.dart`
+ Bilder; `packages/unsalted_core/dart_test.yaml`,
`test/goldens/support/screen_fixtures.dart`, `test/goldens/gl02_screens_golden_test.dart`
+ Bilder. Ändern: `.github/workflows/ci.yml` (`runs-on: ubuntu-24.04`).
Tests/Abnahme: GL-01/02 grün in CI gegen die Bilder aus `goldens.yml`;
Mac-Lauf grün mit übersprungenen Goldens; Gegenprobe: eine Farbe
vorübergehend geändert → GL-01 rot in CI. Bilder zeigen das heutige neutrale
Aussehen.

**D02 — Schrift und Lizenz.**
Neu: `packages/unsalted_design/lib/fonts/*.ttf`, `lib/fonts/OFL.txt`,
`lib/src/theme/app_fonts.dart`, `test/typography/ds49_glyph_coverage_test.dart`,
`ds50_font_license_test.dart`, `support/cmap.dart`. Ändern: Design
`pubspec.yaml` (fonts, assets), Tür + `public_api_golden.txt` (`AppFonts`),
`CHANGELOG.md`, `test/goldens/support/golden_harness.dart` (Atkinson laden);
`apps/unsalted_app/lib/main.dart` (`AppFonts.registerLicenses()`).
Tests/Abnahme: DS-49, DS-50; Goldens unverändert (Theme nutzt die Schrift
noch nicht); `decisions.md` mit Quelle, Version, SHA-256 und gemessener
Glyphenliste (welche von → ✓ ★ µ wirklich fehlen); Gegenprobe DS-49: ein
„★“ vorübergehend in einem Core-Text → rot.

**D03 — Token-Datei, Generator, Theme-Zuordnung.**
Neu: `packages/unsalted_design/tokens/unsalted.tokens.json`,
`tool/generate_tokens.dart`, `lib/src/tokens/*_tokens.g.dart` (10 Dateien),
`test/theme/ds07_theme_mapping_test.dart`,
`test/architecture/ds51_no_numbers_in_components_test.dart` (mit
Übergangsliste aller heutigen Fundstellen). Ändern: `lib/src/tokens/*.dart`
(nur Hand-Logik), `lib/src/theme/app_theme.dart`, `lib/src/theme/app_tone.dart`
(nur falls eine benutzte Material-Rolle die Bedeutung wechselt), Komponenten nur dort, wo `AppRadius.l/xl` oder `AppElevation`
vorkommen (auf neue Namen), Tür + `public_api_golden.txt`, `CHANGELOG.md`;
`apps/unsalted_widgetbook/lib/catalog/tokens.dart`; Tests aus (d2) D03;
`docs/spezifikation.md` (28.10 Punkte 1, 12, 13), `CLAUDE.md`. Weg:
`lib/src/tokens/elevation_tokens.dart`, `test/theme/ds07_neutral_theme_test.dart`.
Tests/Abnahme: DS-04/05/07 neu grün; Generator zweimal → `git diff` leer;
Gegenprobe: ein Wert in der JSON geändert, nicht neu generiert → DS-04 rot;
alle Core-, App- und Widgetbook-Tests grün; Goldens neu (Farben, Schrift,
Radien), Abgleich mit Figma `get_screenshot` der Grundlagen-Seite (`0:1`).

**D04 — Komponenten-Themes.**
Neu: `packages/unsalted_design/lib/src/theme/component_themes.dart`,
`test/theme/ds52_component_themes_test.dart`. Ändern: `app_theme.dart`.
Tests/Abnahme: DS-52; alle bestehenden Tests grün; Goldens neu.

**D05a — Symbol-Finder in Tests.** Nur die Zeilen aus (d2) D05a.
Tests/Abnahme: vorher und nachher grün; maschinell geprüft, dass sich je
Zeile nur der Symbolname ändert.

**D05b — Symbole.**
Ändern: `packages/unsalted_design/lib/src/components/icons/app_icons.dart`
(Outlined, elf neue Namen, `byFigmaName` = Liste aus 03/07),
`test/components/ds17_icons_test.dart` (nur neue Fälle), Widgetbook
`catalog/icons…`. Tests/Abnahme: DS-17 (alle 32 Figma-Namen), Core/App
unverändert grün; Goldens neu; Abgleich Figma-Seite „Symbole“ (`21:388`).

### Etappe 2 — Komponenten (Stopp nach D12)

**D06 — Komponenten I: Aktionen, Text, Flächen.**
Ändern (Design): `components/buttons/*`, `components/chips/*`,
`components/text/app_text.dart` (11 Stile), `components/surfaces/*`,
`components/cards/app_card.dart`, `layout/app_section.dart`; Widgetbook-Katalog;
Test `ds18_text_test.dart:30`. Abnahme: DS-14–22 grün; DS-51-Liste ohne diese
Dateien; Figma `Button` (`42:13`), `Button/FAB` (`143:155`), `Chip/*`,
`Layout/Section` (`133:55`).

**D07 — Markenelemente.**
Neu: `components/brand/*` (b4), Tests DS-53–58, Katalog `catalog/brand.dart`.
Ändern: Tür + Golden, `CHANGELOG.md`, Widgetbook `main.dart`/WB-02.
Abnahme: DS-53–58, WB-01/02; Strichlinie und Punktraster im Dunkelmodus
(`#252A34` auf `#141925`); Figma `Mark` (`114:68`), `Frame` (`135:55`),
`Highlight` (`134:152`), `Change` (`134:154`), `Value` (`134:179`).

**D08 — Eingaben und Listen.**
Ändern (Design): `components/inputs/*` (Beschriftung über dem Feld, Einheit
im Feld, Zahlen rechtsbündig, Fokusring, Fehler mit Symbol),
`components/lists/*` (Haarlinien, `selected`-Balken vorbereitet,
Bedienhilfe-Aktionen „Nach oben/unten“ in `AppReorderableList`). Tests aus
(d2) D08. Abnahme: DS-23–31; UI-11–15 und UI-12 (Umsortieren) unverändert
grün; Figma `Input/*`, `List/*`.

**D09 — Rückmeldung.**
Ändern (Design): `components/feedback/*` (Notice mit Symbol, Leerstelle aus
`AppSlot`, Ladekreis Tinte, Ladebalken `stroke-rule`, Meldung mit
Restzeitlinie und Marker-Aktion, Dialog), `components/icons/app_icon.dart`
(`AppIconSize`). Tests aus (d2) D09. Abnahme: DS-32–39; UI-35–46 (Rückgängig,
Ladebalken nach 300 ms) unverändert grün; Figma `Feedback/*`.

**D10 — Navigation und Daten.**
Ändern (Design): `components/navigation/*` (eigene `AppNavigationBar` mit
Seitenleiste ab 600; Kopfleiste und Navigation mit
`MediaQuery.withNoTextScaling`, Tooltips), `layout/app_page.dart` (Slot
`navigation`: unten bzw. links), `components/data/*` (Deklaration, `code`).
Neu: Test DS-59. Tests aus (d2) D10. Ändern (App): `lib/main.dart` nur
`bottomBar:` → `navigation:` (ohne F4: Seitenleiste abgeschaltet). Abnahme:
DS-40–45, DS-59, APP-02 und App-Rauchtest (`widget_test.dart`); Figma
`Navigation/*`, `Data/*`.

**D11 — Templates und Layout.**
Ändern (Design): `templates/*`, `layout/responsive.dart`
(`DetailLayout.standard` = zweispaltig ab `breakpoint-large`). Neu: DS-60.
Tests aus (d2) D11. Abnahme: DS-46–48 (Stabilität 1.1a/1.1c), DS-60;
UI-33/34/45/46 unverändert grün; Figma `Template/*`, Tablet-Seiten.

**D12 — Große Schrift (nur nach F5).**
Ändern: `tokens/unsalted.tokens.json` + `docs/design/system/tokens.json`
(Nachtrag aus F5), Generator (Werte je Textgröße), `size_tokens.g.dart`;
Neu: `lib/src/theme/app_reflow.dart`; Komponenten mit `Wrap`/`LayoutBuilder`
(Nährwert-Kopf, Mengenrechner, Zutatenzeile, untere Leiste); Mindesthöhen
statt fester Höhen. Widgetbook: Textgröße als Addon, WB-04. DS-51
Übergangsliste leer und entfernt. Abnahme: WB-04 grün; Goldens 200 % ohne
Abschneiden; Figma „Bildschirme · Schrift 200“ (`73:3778`).

### Etappe 3 — Core-Bausteine (Stopp nach D16)

**D13 — Fassungsmarke, Fassungsleiste, Master.** Dateien aus (c) D13, Tests
aus (d2) D13, neue UI-67/68. Abnahme: alle Core-Tests grün, AT-13/14/15,
GL-02; 28.10 Punkte 4, 6. Figma `Core/Version Switcher` (`142:19`),
Bildschirm 07 (`20:1042`).

**D14 — Änderungsliste.** Dateien aus (c) D14, Test aus (d2) D14, neu UI-69
(Semantik = bisheriger Text). DS-49-Ausnahme für `change_descriptions.dart`.
Abnahme: UI-22–24, UI-64 unverändert; 28.10 Punkte 7, 15; Bildschirm 08
(`3:595`).

**D15 — Nährwerte.** Dateien aus (c) D15, neu UI-70/71. Abnahme: UI-05–07,
UC-01–06, Rundung nur über `NutritionFormatter`; 28.10 Punkt 5; Bildschirm 04
(`1:607`).

**D16 — Editor und Lebensmittel.** Dateien aus (c) D16, neu UI-72–74.
Abnahme: UI-09, UI-11–15, UI-29–32, UI-65/66, Keys unverändert; 28.10
Punkte 3, 8; Bildschirme 03 (`7:895`), 10 (`23:1492`).

### Etappe 4 — App-Hülle und Abschluss

**D17 — App-Hülle.** Nur nach F4: Seitenleiste ab 600 einschalten. Nur nach
F2: `apps/unsalted_app/pubspec.yaml` (+ `flutter_localizations`),
`lib/main.dart` (Delegates, `Locale('de')`), APP-03. Abnahme: App-Tests grün;
28.10 Punkte 10, 14; Figma Tablet (`147:9746`) und quer (`148:3817`).

**D18 — Abschluss.** `docs/design/design_system.md` (Weg der Werte mit
Generator, DS-07 neu), `components.md` (neue Komponenten, Figma-IDs),
`screens.md` (Stand 1.3), README/CHANGELOG `unsalted_design` 0.2.0,
`docs/spezifikation.md` 28.10 vollständig, `status.md`, `decisions.md`,
`CLAUDE.md`; nach Freigabe `docs/design/system/README.md` Status
„freigegeben“ (F14). Abnahme: alle Tests aller vier Pakete grün (CI mit
Goldens), Exit 0, Figma-Abgleich je Hauptbildschirm dokumentiert.

---

## (f) Risiken und offene Fragen

### Risiken

| Nr | Risiko | Gegenmaßnahme |
|---|---|---|
| R1 | Tests prüfen Material-Widgets (C28) | Komponenten bauen weiter dieselben Widgets, gestaltet über Themes; Änderungen nur in den Zeilen aus (d2) |
| R2 | Goldens sind plattformabhängig (Mac ≠ Linux) | erzeugt und verglichen nur auf `ubuntu-24.04` mit fester Flutter-Version; `@TestOn('linux')`; Schriften ausdrücklich geladen |
| R3 | Geladene Schriften ändern Textmaße in allen Tests | Laden nur in der Golden-Harness, nie global |
| R4 | `reflow`-Werte bei 200 % fehlen in `tokens.json` (A1, A2) | D12 wartet auf F5; bis dahin keine Handwerte |
| R5 | Schrift ohne → ✓ ★ µ | Pfeil als Symbol, ✓/★ nur als Symbol, DS-49; Nutzertexte über Systemrückfall |
| R6 | WOFF2 der Übergabe sind vermutlich ein Teilsatz (ungepackt rund 65 KB, 17 Tabellen) und tragen im Kopf „2.66“, 02 nennt Version 2.001 | vollständige TTF aus der Originalquelle (F6), Version und Glyphen messen und protokollieren |
| R7 | Seitenleiste ab 600: die Testfläche ist 800 × 600 | betrifft nur App-Tests (`theme_test.dart:52`); Core-Bildschirme enthalten keine Navigation |
| R8 | Seitenrand und Inhaltsbreite ab 600 ändern das Layout der Core-Tests (800 breit) | Positionen werden in Core-Tests relativ ermittelt (`getCenter`); volle Läufe je Commit |
| R9 | Umfang: ~19 Commits, ~136 Golden-Bilder, Repo-Größe wächst je Bildänderung | Etappen mit Stopp; Bildumfang nach F11 begrenzbar |
| R10 | Figma und `tokens.json` laufen auseinander | DS-04 gegen JSON; Figma-Abgleich je Etappe, nur lesend |
| R11 | `material_ui` löst später `flutter/material.dart` ab (Fix-Daten vom 2026-07-08 vorhanden, noch nicht veraltet) | Themes und Komponenten nutzen nur API, die beide Bibliotheken gleich haben; Umstieg als eigener Schritt (F1) |
| R12 | Freeze Teil 1 | Core-Tür, Logik, Schema unverändert; nur `lib/src/ui/`-Bausteine; Kapitel 28.10 + decisions.md |
| R13 | Eigene Navigationskomponente verliert Material-Semantik | Semantik je Ziel (`selected`, Tab-Rolle), DS-59 mit `SemanticsHandle` |
| R14 | Strichlinie per `CustomPainter` bei Textgröße 200 % und Rundungen | Pfad entlang der abgerundeten Kontur, Goldens 200 % |

### Offene Fragen (je mit Empfehlung)

- **F1 — (a) Umstieg auf `material_ui` vorher** (`dart fix --apply
  --code=migrate_design_widgets`, ohne sichtbare Änderung)? Lage in Flutter
  3.47.5: Fix-Daten liegen bei, `flutter/material.dart` ist noch nicht
  veraltet. `material_ui` 1.5.0 bringt `flutter_localizations`, `intl`,
  `cupertino_ui`, `material_color_utilities` u. a. mit — das Design-Paket
  hinge dann nicht mehr nur von Flutter ab (DS-01, `allowed_in_design`,
  `check_architecture.dart`, Kapitel 28.9.1/3), und Widgetbook bräuchte die
  `MaterialUiCompatibilityBridge`. *Empfehlung:* **nicht vorher**, sondern
  als eigener kleiner Teil nach 1.3 (bzw. mit der Veraltung in einer späteren
  Flutter-Version). Der Umstieg ist mechanisch und von der Gestaltung
  unabhängig; vorher gemacht, vermischt er zwei Änderungen und ändert die
  Architekturregeln ohne Not.
- **F2 — (b) Deutsche Systemtexte gleich mit?** Heute fehlt jede
  Lokalisierung: Tooltips wie „Back“, das Textauswahlmenü („Copy“, „Paste“)
  und die Lizenzseite sind englisch. *Empfehlung:* **ja, als eigener Commit
  in der App-Hülle (D17)** mit `flutter_localizations` aus dem SDK und
  `Locale('de')`. Core und Design bleiben unberührt (Core-Tests pumpen ohne
  Lokalisierung weiter). Mit F1 später auf die Klassen aus `material_ui`
  umstellen.
- **F3 — (c) Golden-Grundstand mit dem heutigen Aussehen?** *Empfehlung:*
  **ja (D01).** Dann zeigt jeder folgende Commit seine Wirkung als
  Bilddifferenz im PR, und die Golden-Technik (Schriften laden, Linux-Runner)
  ist geprüft, bevor sich etwas ändert.
- **F4 — (d) Seitenleiste ab 600 und Liste/Detail ab 840.** *Empfehlung:*
  **Seitenleiste in 1.3** (nur Design-Komponente und App-Hülle, keine
  Bildschirm-Datei; Nachtrag 28.10.10). **Liste/Detail nebeneinander als
  eigener Teil 1.4**: braucht Änderungen an Rezept- und Lebensmittel-Liste
  und -Detail (Auswahlzustand, `Navigator.push` → Bereich, Zurück-Verhalten,
  28.4.1) und damit Bildschirm-Dateien und Routen — gegen die Leitplanke
  dieses Teils. Das Rezeptdetail zweispaltig ab 1200 bleibt in 1.3 (nur
  `DetailLayout` im Template, die Abschnitte sind schon in Haupt/Neben
  geteilt).
- **F5 — Werte bei 200 % für `reflow-*` fehlen in `tokens.json`.**
  *Empfehlung:* Nachtrag der Token-Datei durch die Gestaltung (Format
  `"value": {"100": "96px", "200": "160px"}` für die fünf Maße, dazu
  `reflow-rule-inline`, `reflow-rule-stacked`, `reflow-inset-inline`) mit den
  Werten aus Figma (A1, A2), vom Projektverantwortlichen bestätigt, als
  eigener Commit vor D12. Zwischenstufen linear zwischen 100 und 200 %,
  oberhalb von 200 % (iOS erlaubt mehr) der 200-%-Wert. Bis dahin ist D12
  gesperrt; Etappe 3 hängt nicht davon ab.
- **F6 — Herkunft der TTF.** *Empfehlung:* vollständige statische TTF aus der
  Originalquelle der Schrift (Release mit Versionsnummer), nicht die
  Umwandlung der WOFF2 aus der Übergabe (vermutlich Teilsatz, R6). Herkunft,
  Version, SHA-256 und Glyphenliste in `decisions.md`.
- **F7 — Schrift für `code`.** *Empfehlung:* Systemschrift über den Stapel aus
  `tokens.json` (`ui-monospace`, `SF Mono`, `Menlo`, `Consolas`, `monospace`),
  keine weitere Datei. Folge: In den Linux-Goldens erscheint der Codeblock in
  der Ersatzschrift. Alternative: eine Monospace-Schrift (OFL) bündeln.
- **F8 — Token-Datei an zwei Orten.** *Empfehlung:* DS-04 erzwingt, dass
  `docs/design/system/tokens.json` und `packages/unsalted_design/tokens/unsalted.tokens.json`
  gleich sind; eine neue Übergabe ändert beide im selben Commit.
- **F9 — Master sichtbar.** *Empfehlung:* Markerfläche der Marke **und** das
  Wort „Master“ im Untertitel (nicht nur Semantik), damit Farbe nie allein
  trägt (README, Barrierefreiheit).
- **F10 — Pfeil in der Änderungsliste.** *Empfehlung:* als Symbol in
  `AppChangeText`, Text mit → nur als Semantik; `describeChanges` bleibt
  unverändert (keine Testzeile in `change_descriptions_test.dart`).
- **F11 — Umfang der Goldens.** *Empfehlung:* GL-01 je Komponentengruppe,
  GL-02 fünf Musterbildschirme (1, 3, 4, 8, 10), je 8 Varianten (~136
  Bilder). Weitere Bildschirme nur bei Bedarf.
- **F12 — Symbole Outlined.** *Empfehlung:* ja, mit vorgezogenem
  Finder-Commit D05a, damit die Umstellung keinen Test berührt.
- **F13 — CI für den Branch.** *Empfehlung:* Entwurfs-PR `design-1.3` → `main`
  (CI läuft für PRs nach `main`), Runner fest `ubuntu-24.04`, Goldens per
  `goldens.yml`.
- **F14 — Versionen und Status.** *Empfehlung:* `unsalted_design` 0.2.0;
  nach Freigabe Tags `part1-v1.3.0` und `design-v0.2.0`; erst dann der Status
  „freigegeben“ in `docs/design/system/README.md`.
