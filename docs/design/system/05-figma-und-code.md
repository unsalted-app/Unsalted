# Figma und Code

Figma ist das Werkzeug zum Gestalten und Freigeben. Die Quelle der Werte für den Code ist danach eine exportierte Token-Datei im Repository. Namen übersetzen sich mechanisch – so steht es schon in `docs/design/design_system.md`, und so bleibt es. Klassennamen bleiben, wie sie im Code heißen (`AppColorTokens`, `AppSpacing`, `AppRadius`, `AppTypography`, `AppMotion`, `AppBreakpoints`); neu sind nur `AppStroke`, `AppSize`, `AppOpacity` und `AppShadow`.

Wie du das in Figma Schritt für Schritt baust, steht in Abschnitt 07; die Variablen zum Importieren liegen unter Assets → Figma-Startpaket.

## Dateien

- `unsalted · Design-System` – Bibliothek: Variablen, Stile, Komponenten, Muster, Core-Bausteine. Veröffentlicht nur nach Freigabe.
- `unsalted · App` – 13 Bildschirme mit allen Zuständen, Abläufe, Prototyp.
- `unsalted · Werkstatt` – Erkundung und Tests; nie Quelle für Code.

## Sammlungen

| Sammlung | Modi | Inhalt |
|---|---|---|
| `primitives` | einer | 23 Farbwerte; beim Veröffentlichen verborgen |
| `color` | `light`, `dark` | 28 Rollen, jede ein Alias auf ein Primitiv (darunter `line-dot` für das Punktraster); dazu die Gruppe `shadow/…` mit den Einzelwerten der Schatten (Versatz, Unschärfe, Farbe, Fokus-Ausdehnung) |
| `space`, `radius`, `stroke`, `size`, `opacity`, `motion`, `breakpoint` | einer | Zahlen, je mit Geltungsbereich. `size` enthält auch `dot` und die festen Maße der Komponenten (Höhen, Breiten, Spalten); `opacity` steht in Figma in Prozent |
| `type` | `100`, `200` | Familie, Schnitte, Größen und Zeilenhöhen der elf Textstile; `200` nur zum Prüfen doppelter Textgröße (Größen und Zeilenhöhen verdoppelt). Dazu die Gruppe `reflow/…`: Maße, die mit der Schrift wachsen (Wertspalte, Mindestbreiten), und die Schalter `rule-inline`, `rule-stacked`, `inset-inline` für Trennlinien nebeneinander bzw. untereinander |

Modi gibt es ab dem Professional-Plan (bis zu 10 je Sammlung; Organization 20, Enterprise unbegrenzt). Das Feld „Code-Syntax“ kennt nur Web, Android und iOS – den Dart-Namen liefert deshalb die Namensregel.

## Namensregeln

| Art | Figma | Dart | Beispiel |
|---|---|---|---|
| Farbrolle | `color/<rolle>`, Modi `light` und `dark` | Feld von `AppColorTokens`, Instanzen `.light` und `.dark` | `color/text-secondary` → `AppColorTokens.light.textSecondary` |
| Primitive | `primitives/<familie>/<stufe>` | privat im Generat | `primitives/neutral/900` |
| Abstand, Radius | `space/l`, `radius/s` | `AppSpacing.l` (als Parameter `AppSpace.l`), `AppRadius.s` | — |
| Linie, Größe, Deckkraft | `stroke/rule`, `size/target`, `opacity/pressed` | `AppStroke.rule`, `AppSize.target`, `AppOpacity.pressed` (neu) | — |
| Bewegung, Breakpoint | `motion/duration/long`, `breakpoint/expanded` | `AppMotion.long`, `AppBreakpoints.expanded` | — |
| Mitwachsendes Maß | `reflow/<name>` in `type`, Modi `100`/`200` | `AppSize.<name>` über `TextScaler.scale`; Umbruch per `Wrap` bzw. `LayoutBuilder` | `reflow/value-column` → 96 px, bei 200 % 160 px |
| Textstil | `type/<stil>` | `AppTypography.<stil>` | `type/data-strong` → `AppTypography.dataStrong` |
| Effekt | `shadow/<name>` | `AppShadow.<name>` (neu) | `shadow/overlay` → `AppShadow.overlay` |
| Komponente | Komponentenset `<Name>`; Eigenschaften in camelCase wie die Dart-Parameter; `variant` ↔ benannter Konstruktor; optionale Teile als `show<Parameter>` plus Instanz-Tausch; Zustände in `state` | `App<Name>` | `Button` · `variant=secondary`, `showIcon=true`, `icon=Icon/copy` → `AppButton.secondary(label: …, onPressed: …, icon: AppIcons.copy)` |
| Symbol | `Icon/<name>` | `AppIcons.<name>` | `Icon/drag-handle` → `AppIcons.dragHandle` |
| Template | `Template/<Name> Page` | `<Name>PageTemplate` | `Template/Form Page` → `FormPageTemplate` |
| Fachbaustein | `Core/<Name>` (eigene Seite) | Klasse in `unsalted_core/lib/src/ui/` | `Core/Version Mark` → `VersionMark` |
| Bildschirm | `<Nr> <Name> / <Zustand> / <Modus> / <Größe>` | Datei aus `docs/design/screens.md` | `04 Rezeptdetail / Inhalt / dark / compact` |

## Weg der Werte

1. Gestalten in Figma mit Variablen (Primitive verborgen, semantische Farben mit Modi `light`/`dark`).
2. Variablen als JSON exportieren. Laut Figma-Hilfe lassen sich Modi als JSON exportieren; der Import verlangt das DTCG-Format (Design Tokens 2025.10). Ob der Export genau diesem Format folgt, prüft der Generator per Schema-Test; `opacity` kommt in Prozent und wird durch 100 geteilt. Die REST-Schnittstelle für Variablen gibt es nur im Enterprise-Plan; als Ausweg bleibt ein Export-Plugin.
3. Datei `packages/unsalted_design/tokens/unsalted.tokens.json` per Pull Request einchecken – sie ist ab dann die Wahrheit für den Code.
4. Ein Dart-Generator in `packages/unsalted_design/tool/` schreibt die Token-Klassen; die CI prüft, dass Generat und JSON übereinstimmen, dazu DS-04, DS-05 und Golden-Tests.
5. Komponenten und Themes ändern sich nur im Design-Paket; Bildschirme nie (AT-13, AT-14).

## Rahmen für Bildschirme

Handy 390 × 844 und Tablet 1024 × 1366 wie in den Tests (`test/support/design_harness.dart`), Katalog 1440 × 900; zusätzlich ein enges Handy mit 360 × 640, Handy quer 844 × 390, Tablet quer 1366 × 1024 und jeder Inhaltsbildschirm einmal im Modus `type/200`.

Anpassung an die Breite (Material 3, nach Breite, nicht nach Ausrichtung): unter `breakpoint-medium` Navigationsleiste unten; ab `breakpoint-medium` seitliche Leiste (`size-nav-rail`); ab `breakpoint-expanded` Liste und Detail nebeneinander (`size-list-pane`, gewählter Eintrag mit `selected`); ab `breakpoint-large` Rezeptdetail zweispaltig (Haupt: Kopf, Nährwerte, Mengenrechner · Neben: Zutaten, Schritte) und `PackageForm` zweispaltig ab Tablet. Systemleisten (Kopfleiste, Navigation) folgen der Textgröße nicht; Inhalte wachsen voll mit.
