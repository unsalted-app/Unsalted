# Design-System von unsalted

Stand Teil 1.3 (`design-v0.2.0`, unveröffentlicht). Teil 1.2 hat das Paket
gebaut (Plan `docs/design/plan.md`, Spezifikation 28.9), Teil 1.3 hat die
Gestaltung aus Figma übernommen (Plan `docs/design/plan-1.3.md`, Übergabe
`docs/design/UEBERGABE.md` und `docs/design/system/`, Spezifikation 28.10).
Entscheidungen: `docs/decisions.md`, „Teil 1.2“ und „Teil 1.3“. Bewusste
Abweichungen von Figma: `docs/design/rueckmeldung-figma.md`.

## Grundsatz

Das Aussehen liegt ausschließlich im Paket `packages/unsalted_design`.
Bildschirme legen nur fest, **was** angezeigt wird und **was** eine Aktion
tut. Wer etwas am Aussehen ändern will, ändert Tokens oder Komponenten — nie
einen Bildschirm.

## Ebenen

| Ebene | Ort | Inhalt |
|---|---|---|
| Token-Datei | `unsalted_design/tokens/unsalted.tokens.json` | einzige Quelle aller Werte (= `docs/design/system/tokens.json`, aus Figma) |
| Tokens | `…/lib/src/tokens/*_tokens.g.dart` | generiert: Farbe (Primitive, 30 Rollen hell/dunkel; `selection`, `selection-handle` seit Teil 1.4), Typografie (11 Stile), Abstand, Radius, Linie, Größe, `reflow` (100/200 %), Deckkraft, Schatten, Bewegung, Breakpoints |
| Theme | `…/lib/src/theme/` | `AppTheme.light()/dark()` (Material-Rollen nach `01-farbe.md`/`02-typografie.md`), `component_themes.dart`, `AppFonts` (Atkinson Hyperlegible Next), `AppTone`, `AppReflowMetric` (Maße je Textgröße); intern `AppColors.of(context)` |
| Layout | `…/lib/src/layout/` | `AppPage` (mit `navigation`), `AppSection`, `AppStack`/`AppGap`/`AppPadding`, `AppGrid`, `AppWindowSize`/`ResponsiveBuilder`; intern `ReflowRow` |
| Komponenten | `…/lib/src/components/<gruppe>/` | Buttons, Symbole, Text, Flächen, Eingaben, Listen, Chips, Rückmeldungen, Navigation, Daten, Markenelemente (`brand/`) |
| Templates | `…/lib/src/templates/` | Seitenraster mit Slots: Liste, Detail, Formular; intern Rahmen „Inhalt“ (`page_content.dart`) |
| Fachliche Bausteine | `unsalted_core/lib/src/ui/<bereich>/` | z. B. `NutritionHeader`, `IngredientRow`, `VersionMark` — aus Komponenten zusammengesetzt |
| Abschnitte | `unsalted_core/lib/src/ui/<bereich>/sections/` | ein Teil eines Bildschirms, zustandslos, eine Datei je Abschnitt |
| Bildschirme | `unsalted_core/lib/src/ui/<bereich>/` | Zustand, Daten, Aktionen; Aufbau über ein Template |

## Regeln

1. **Rang 0, nur Flutter.** `unsalted_design` importiert in `lib/` nur
   `package:flutter/` und sich selbst, kein `dart:io`/`dart:ffi`
   (`check_architecture.dart`, DS-01). Der Generator liegt außerhalb von
   `lib/` (`tool/`) und darf `dart:io` nutzen. Keine Fachbegriffe (DS-06, auch
   in Kommentaren), keine UI-Texte — Texte liefert der Aufrufer.
2. **Werte nur aus der Token-Datei.** Alle Dateien unter `lib/src/tokens/`
   schreibt der Generator; DS-04 prüft Generat = JSON und JSON = Übergabe.
   Komponenten, Layout, Templates und Theme nennen keine Zahlen für Maße,
   Abstände, Radien, Schrift oder Dauern (DS-51, ohne Ausnahme); Farbwerte nur
   in `tokens/` (DS-02).
3. **Tür mit `show`.** Jeder Export nennt seine Symbole; DS-03 vergleicht mit
   `test/architecture/public_api_golden.txt`. Neue oder umbenannte Symbole =
   Golden-Datei und `CHANGELOG.md` bewusst nachführen.
4. **Bildschirme ohne Aussehen.** In `unsalted_core/lib/src/ui/` keine
   Material-Bausteine, für die es eine Komponente gibt, keine festen Farben,
   keine Stile, keine Zahlen für Abstände (AT-13, AT-14). `package:unsalted_design/`
   nur in `lib/src/ui/` (AT-15).
5. **Material bleibt darunter.** Komponenten bauen weiter die bisherigen
   Material-Widgets und gestalten sie über die Komponenten-Themes (C28, d3 im
   Plan 1.3); eigene Komponenten nur, wo Figma etwas anderes verlangt
   (Navigationsleiste, Markenelemente, Kennzahlenleiste). Neue Parameter sind
   additiv.
6. **Stabile Struktur.** Templates halten den Inhalt an fester Stelle, damit
   Ladebalken und Meldungen Zustand und Scrollposition nicht verwerfen
   (DS-47, DS-48). Detail- und Formularseiten stehen im Rahmen „Inhalt“
   (Seitenrand `space-l`, ab `breakpoint-medium` `space-xl`, höchstens
   `size-content-max`), Listen ohne Rand; Detailseiten zweispaltig ab
   `breakpoint-large` (DS-60).
7. **Barrierefreiheit.** Kontraste nach `01-farbe.md` (DS-05); Zustand nie
   nur über Farbe oder Linie (Semantik nennt ihn); Tippziele mindestens
   `size-target`, Tippaktionen auch in der Semantik; Bewegung entfällt bei
   „Bewegung reduzieren“ (`AppMotion.durationOf`, statische Restzeitlinie).
8. **Große Schrift bis 200 %.** Text wird nicht abgeschnitten. Maße neben
   Text wachsen mit (`AppReflowMetric`, zwischen 100 und 200 % linear);
   Nebeneinander wird untereinander, sobald ein Teil schmaler als sein
   `reflow-*`-Minimum würde. Kopfleiste und Navigation folgen der Textgröße
   nicht. WB-04 baut jeden Katalog-Anwendungsfall bei 200 %.
9. **Katalog und Goldens.** Jede Komponente steht in `apps/unsalted_widgetbook`
   (WB-02) und baut dort hell/dunkel × Handy/Tablet (WB-01) und bei 200 %
   (WB-04). Golden-Bilder (GL-01 Katalog, GL-02 Bildschirme; hell/dunkel ×
   Handy/Tablet × 100/200 %) entstehen nur unter Linux (`goldens.yml`) und
   werden in der CI verglichen.

## Benennung = Figma-Namen

| Art | Figma | Dart | Beispiel |
|---|---|---|---|
| Farbrolle | `color/<rolle>`, Modi `light`/`dark` | `AppColorTokens.light`/`.dark`, Rolle in camelCase | `color/text-secondary` → `AppColorTokens.textSecondary` |
| Textstil | `type/<rolle>` | `AppTypography.<rolle>` | `type/label-small` → `AppTypography.labelSmall` |
| Zahl-Token | `<gruppe>/<name>` | Klasse der Gruppe | `space/xl` → `AppSpacing.xl`, `size/value-column` → `AppSize.valueColumn` |
| Maß je Textgröße | `reflow/<name>`, Modi `100`/`200` | `AppReflow.<name>` (100 %), `AppReflowMetric.<name>.of(context)` | `reflow/stat-min` → `AppReflowMetric.statMin` |
| Komponente | `<Kategorie>/<Name>` | `App<Name>` | `Button/Primary` → `AppButton.primary`, `Mark` → `AppMark` |
| Symbol | `Icon/<name>` | `AppIcons.<name>` | `Icon/drag-handle` → `AppIcons.dragHandle` |
| Template | `Template/<Name> Page` | `<Name>PageTemplate` | `Template/Detail Page` → `DetailPageTemplate` |
| Fachbaustein | `Core/<Name>` | Baustein in `unsalted_core` | `Core/Version Switcher` → `VersionSwitcher` |

Jede Token-Gruppe führt ihre Figma-Namen zusätzlich in `byFigmaName`
(`AppReflow.byFigmaNameAt200` für den Modus 200). Die Zuordnung der
Komponenten mit Figma-IDs steht in `docs/design/components.md`.

## Weg der Werte: Figma → Code

1. **Figma ändern.** Variablen oder Komponenten in Figma anpassen; Namen nur
   nach dem Schema oben. Neue Bildschirm-Gestaltung bleibt in den Grenzen von
   Kapitel 22 (Texte, Reihenfolge, Funktion).
2. **Token-Datei übernehmen.** `docs/design/system/tokens.json` aus der
   Übergabe nach `packages/unsalted_design/tokens/unsalted.tokens.json`
   kopieren — beide Dateien im selben Commit, byteweise gleich (DS-04).
3. **Generieren.** Im Paket `dart run tool/generate_tokens.dart`; die
   Dateien unter `lib/src/tokens/` nie von Hand ändern. `flutter test` prüft
   Generat, Kontraste (DS-05) und die Zuordnung der Material-Rollen (DS-07).
4. **Komponenten anpassen.** Nur in `lib/src/components/`,
   `lib/src/templates/` bzw. `lib/src/theme/component_themes.dart`;
   Bildschirme bleiben unberührt. Neue Komponente = Katalog-Eintrag (WB-02)
   und Golden-Motiv.
5. **Prüfen.** `flutter test` in Design, Core, App und Widgetbook;
   Golden-Bilder über den Hilfsbranch `goldens/<schritt>` erzeugen,
   ansehen, in den Commit übernehmen (Ablauf: `docs/design/plan-1.3.md`, d4).
6. **Versionieren.** `CHANGELOG.md` und Version in `pubspec.yaml` nachführen;
   Tag `design-vX.Y.Z` erst nach Freigabe.

**DS-07 (neu seit Teil 1.3):** prüft nicht mehr die Neutralität gegenüber
dem Flutter-Standard, sondern die Zuordnung der Material-Rollen zu den
Tokens: alle 46 `ColorScheme`-Rollen nach der Tabelle in `01-farbe.md`, die
abgeleiteten Flächen (`surface-page`) und die 15 `TextTheme`-Rollen nach
`02-typografie.md` samt Schriftfamilie und tabellarischen Ziffern; eine
Gegenprobe zeigt, dass der Vergleich Abweichungen erkennt
(`test/theme/ds07_theme_mapping_test.dart`).
