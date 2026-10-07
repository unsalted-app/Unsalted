# Design-System von unsalted

Stand Teil 1.2 (`design-v0.1.0`, unveröffentlicht). Plan und Entscheidungen:
`docs/design/plan.md`, `docs/decisions.md` („Teil 1.2“), Spezifikation 28.9.

## Grundsatz

Das Aussehen liegt ausschließlich im Paket `packages/unsalted_design`.
Bildschirme legen nur fest, **was** angezeigt wird und **was** eine Aktion
tut. Wer etwas am Aussehen ändern will, ändert Tokens oder Komponenten — nie
einen Bildschirm.

## Ebenen

| Ebene | Ort | Inhalt |
|---|---|---|
| Tokens | `unsalted_design/lib/src/tokens/` | Farbe (hell/dunkel), Typografie, Abstand, Radius, Höhe, Bewegung, Breakpoints — die einzigen festen Werte |
| Theme | `…/theme/` | `AppTheme.light()/dark()` nur aus Tokens; `AppTone` (Farbton als Rolle) |
| Layout | `…/layout/` | `AppPage`, `AppSection`, `AppStack`/`AppGap`/`AppPadding`, `AppGrid`, `AppWindowSize`/`ResponsiveBuilder` |
| Komponenten | `…/components/<gruppe>/` | Atome und Moleküle: Buttons, Symbole, Text, Flächen, Eingaben, Listen, Chips, Rückmeldungen, Navigation, Daten |
| Templates | `…/templates/` | Seitenraster mit Slots: Liste, Detail, Formular |
| Fachliche Bausteine | `unsalted_core/lib/src/ui/<bereich>/` | z. B. `NutritionTable`, `IngredientRow` — aus Komponenten zusammengesetzt |
| Abschnitte | `unsalted_core/lib/src/ui/<bereich>/sections/` | ein Teil eines Bildschirms, zustandslos, eine Datei je Abschnitt |
| Bildschirme | `unsalted_core/lib/src/ui/<bereich>/` | Zustand, Daten, Aktionen; Aufbau über ein Template |

## Regeln

1. **Rang 0, nur Flutter.** `unsalted_design` importiert nur `package:flutter/`
   und sich selbst, kein `dart:io`/`dart:ffi` (`check_architecture.dart`,
   DS-01). Keine Fachbegriffe (DS-06), keine UI-Texte — Texte liefert der
   Aufrufer.
2. **Feste Werte nur in Tokens.** Farbwerte nur in `tokens/` (DS-02); Abstände
   als `AppSpace`-Stufe, nie als Zahl.
3. **Tür mit `show`.** Jeder Export nennt seine Symbole; DS-03 vergleicht mit
   `test/architecture/public_api_golden.txt`. Neue oder umbenannte Symbole =
   Golden-Datei und `CHANGELOG.md` bewusst nachführen.
4. **Bildschirme ohne Aussehen.** In `unsalted_core/lib/src/ui/` keine
   Material-Bausteine, für die es eine Komponente gibt, keine festen Farben,
   keine Stile, keine Zahlen für Abstände (AT-13, AT-14). `package:unsalted_design/`
   nur in `lib/src/ui/` (AT-15).
5. **Ohne Funktionsänderung.** Komponenten bauen vorerst genau die bisherigen
   Material-Widgets; die bestehenden Tests bleiben unverändert.
6. **Stabile Struktur.** Templates halten den Inhalt an fester Stelle, damit
   Ladebalken und Meldungen Zustand und Scrollposition nicht verwerfen
   (DS-47, DS-48).
7. **Barrierefreiheit.** Symbol-Schaltflächen und Hauptaktion haben einen
   Pflicht-Tooltip; Text auf Fläche ≥ 4,5:1 (DS-05); Bewegung entfällt bei
   „Bewegung reduzieren“ (`AppMotion.durationOf`).
8. **Katalog vollständig.** Jede Komponente steht in `apps/unsalted_widgetbook`
   (WB-02) und baut dort hell/dunkel × Handy/Tablet (WB-01).

## Benennung = Figma-Namen

| Art | Figma | Dart | Beispiel |
|---|---|---|---|
| Variable | `<gruppe>/<name>` | Klasse der Gruppe, Name in camelCase | `color/surface-container-high` → `AppColorTokens.surfaceContainerHigh` |
| Farbmodus | Modus `light`/`dark` der Sammlung `color` | `AppColorTokens.light`/`.dark` | — |
| Textstil | `type/<rolle>` | `AppTypography.<rolle>` | `type/title-medium` → `AppTypography.titleMedium` |
| Komponente | `<Kategorie>/<Name>` | `App<Name>` | `Button/Primary` → `AppButton.primary` |
| Symbol | `Icon/<name>` | `AppIcons.<name>` | `Icon/drag-handle` → `AppIcons.dragHandle` |
| Template | `Template/<Name> Page` | `<Name>PageTemplate` | `Template/Detail Page` → `DetailPageTemplate` |

Jede Token-Gruppe führt ihre Figma-Namen zusätzlich in `byFigmaName`
(Tests, Katalog). Die vollständige Zuordnung der Komponenten steht in
`docs/design/components.md`.

## Ablauf Figma → Code

1. **Figma ändern.** Variablen (Tokens) oder Komponenten in Figma anpassen;
   Namen nur nach dem Schema oben.
2. **Tokens übernehmen.** Variablen als JSON exportieren (Format „Design
   Tokens“ des W3C) und die Werte in `lib/src/tokens/` nachziehen — vorerst von
   Hand, ein Generator folgt, sobald die Figma-Datei steht (F6).
3. **Komponenten anpassen.** Nur in `lib/src/components/` bzw.
   `lib/src/templates/`; Bildschirme bleiben unberührt. Komponenten-Themes
   kommen in `lib/src/theme/`, sobald Figma sie festlegt.
4. **Prüfen.** `flutter test` im Paket (DS-Tests, Kontrast), Katalog ansehen
   (`apps/unsalted_widgetbook`, hell/dunkel × Handy/Tablet), `flutter test` in
   Core und App.
5. **Versionieren.** `CHANGELOG.md` und Version in `pubspec.yaml` nachführen;
   Tag `design-vX.Y.Z` erst nach Freigabe.

Solange die Tokens Platzhalter sind, weist DS-07 nach, dass das Theme dem
Flutter-Standard entspricht. Mit dem ersten Figma-Design wird DS-07 durch
einen Vergleich mit den Figma-Werten ersetzt.
