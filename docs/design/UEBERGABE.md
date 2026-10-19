# Übergabe Design → Code (unsalted)

Stand 16.10.2026. Dieses Paket gehört ins Repository unter `docs/design/`. Es ist die Grundlage, mit der Claude Code das Design im Flutter-Code umsetzt.

## Was drin ist

| Pfad | Inhalt |
|---|---|
| `system/README.md` | Markenbuch: Grundsätze, Farbe, Schrift, Symbole, Regeln |
| `system/01-…07-*.md` | Farbe, Typografie, Markenelemente, Komponenten-Inventar, Figma und Code (Namensregeln, Weg der Werte), Ist-Zustand, Figma Schritt für Schritt |
| `system/tokens.json` | **Alle Werte** (Farben hell/dunkel, Schrift, Abstände, Radien, Linien, Größen, Deckkraft, Breakpoints, Bewegung, Schatten) |
| `system/components/<Name>/README.md` | Gestaltungsregeln je Komponente |
| `system/assets/Figma-Startpaket/` | dieselben Variablen im DTCG-Format (Figma-Import) |
| `system/assets/Lizenzen/` | OFL-Lizenz der Schrift |
| `system/fonts/*.woff2` | Atkinson Hyperlegible Next 400/600/700 |
| `figma/figma-ids.json` | Datei-Schlüssel, Seiten- und Node-IDs aller Komponenten und Bildschirme für den Figma-MCP-Server |

## Figma-Dateien

- Bibliothek: https://www.figma.com/design/5er28Cr7EMMcPzvusWjNyR – Variablen (`color` light/dark, `type` 100/200 …), 53 Komponenten und 32 Symbole. Jede hat in der Beschreibung eine Zeile `Code: …` mit der Dart-Klasse.
- App: https://www.figma.com/design/5eFqwnCRld6Ibu131541i8 – 13 Bildschirme aus `docs/design/screens.md` mit allen Zuständen; Seiten für dark, Schrift 200, eng (360 × 640), Tablet, Handy quer und Tablet quer; Klick-Prototyp.

## Entscheidungen (verbindlich)

1. **Werte:** nur aus `tokens.json`. Bildschirme enthalten keine Farben, Zahlen oder Stile (AT-13, AT-14, DS-01 … DS-07).
2. **Anpassung an die Breite** (Material 3, nach Breite, nicht Ausrichtung):
   - < 600: Navigationsleiste unten (`AppNavigationBar`).
   - ≥ 600: seitliche Leiste links, Breite `size-nav-rail` (96), gleiche Ziele und Auswahlbalken.
   - ≥ 840: Rezepte und Lebensmittel als Liste und Detail nebeneinander; Listenspalte `size-list-pane` (360); gewählter Eintrag `AppListItem(selected: true)` mit Auswahlbalken links; Detail ohne Zurück-Pfeil.
   - ≥ 1200: Rezeptdetail zweispaltig (Haupt: Kopf, Nährwerte, Mengenrechner · Neben: Zutaten, Schritte). `PackageForm`: Nährwertfelder zweispaltig ab Tablet.
   - Seitenrand ab 600: `space-xl` (24); Inhalt höchstens `size-content-max` (720), zentriert.
3. **Große Schrift (bis 200 %)**, nach Apple- und Android-Vorgaben:
   - Inhalte wachsen voll mit, Text wird nie abgeschnitten, Wörter werden nie getrennt (Flutter trennt nicht automatisch).
   - Systemleisten (Kopfleiste, Navigation unten und links) folgen der Textgröße nicht: `MediaQuery.withClampedTextScaling` bzw. fester Scaler; langes Drücken zeigt das Ziel als Tooltip.
   - Nebeneinander wird untereinander: Nährwert-Kopf, Mengenrechner, Zutatenzeile im Editor und die Knöpfe der unteren Leiste stehen untereinander (`Wrap` oder `LayoutBuilder`).
   - Maße neben Text wachsen mit (`reflow-*` in `tokens.json`, z. B. Wertspalte 96 → 160 bei 200 %): `MediaQuery.textScalerOf(context).scale(...)`.
   - Mindesthöhen statt fester Höhen (Chips, Marken, Buttons, Listeneinträge).
4. **Symbole:** Material Symbols Outlined, Gewicht 300, Grade 0, optische Größe 24, nie gefüllt. Im Code bis zum eigenen Set die mitgelieferten Material Icons (Outlined), Namen über `AppIcons` (`Icon/<name>` ↔ `AppIcons.<name>`). Lebensmittel in der Navigation: `restaurant`.
5. **Dark Mode:** alle 28 Farbrollen haben dunkle Werte; der Marker-Knopf behält in beiden Modi Tinte als Symbolfarbe (`text-on-marker`).

## Abweichungen und offene Punkte

- **Schriftdateien:** Flutter lädt keine WOFF2. Die TTF-Dateien (400/600/700) von der Quelle der Schrift holen oder umwandeln (`pip install fonttools brotli`, dann `fonttools ttLib.woff2 decompress <datei>.woff2`), nach `packages/unsalted_design/lib/fonts/` legen, `OFL.txt` dazu.
- **Figma-Startpaket:** wurde aus einem älteren Stand von `tokens.json` erzeugt; `size-nav-rail`, `size-list-pane` und `reflow-*` fehlen dort. Quelle für den Code ist `tokens.json`.
- **Gestrichelte Unterstreichung** („nicht verknüpft“) lässt sich in Figma nicht zeichnen; im Code als gestrichelte Linie unter dem Namen umsetzen (siehe `04-komponenten.md`, `IngredientRow`).
- **Code Connect** ist im Figma-Professional-Plan nicht verfügbar; die Zuordnung steht stattdessen in den Komponentenbeschreibungen (`Code: …`) und in `04-komponenten.md`.
- **Freigabe:** Das Design-System steht auf „Entwurf zur Freigabe“. Nach dem ersten Durchlauf im Code den Status anpassen.

## Reihenfolge im Code (Abschnitt 05, „Weg der Werte“)

1. `system/tokens.json` → `packages/unsalted_design/tokens/unsalted.tokens.json`; Dart-Generator in `packages/unsalted_design/tool/` schreibt `AppColorTokens`, `AppSpacing`, `AppRadius`, `AppStroke`, `AppSize`, `AppOpacity`, `AppShadow`, `AppTypography`, `AppMotion`, `AppBreakpoints`. CI prüft Generat = JSON (DS-04), Kontraste (DS-05).
2. Theme: Material-Rollen auf die Tokens abbilden (Tabellen in `01-farbe.md` und `02-typografie.md`), Schrift einbinden.
3. Komponenten in `unsalted_design` nach `04-komponenten.md`, je mit Golden-Tests: hell/dunkel × Handy/Tablet × Text 100/200.
4. Fachbausteine in `unsalted_core/lib/src/ui/` (`NutritionHeader`, `IngredientRow` …).
5. Adaptive Navigation und Liste/Detail in der App-Hülle und den Templates.
6. Bildschirme nur über Templates und Abschnitte; zum Abgleich `get_screenshot` der Figma-Bildschirme aus `figma/figma-ids.json`.

## Start in Claude Code (VS Code)

Figma verbinden (einmalig): `claude plugin install figma@claude-plugins-official` oder `claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp`, dann in Claude Code `/mcp` → figma → Authenticate.

Erster Auftrag:

```
Lies docs/design/UEBERGABE.md, docs/design/system/05-figma-und-code.md und
docs/design/screens.md. Schritt 1: Lege docs/design/system/tokens.json als
packages/unsalted_design/tokens/unsalted.tokens.json an und schreibe den
Dart-Generator für die Token-Klassen nach den Namensregeln in 05, mit Test,
dass Generat und JSON übereinstimmen. Noch keine Komponenten. Zeig mir den
Plan, bevor du Dateien änderst.
```
