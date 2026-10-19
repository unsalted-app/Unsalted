# Figma Schritt für Schritt

So baust du dieses System in Figma nach – so, dass jede Zahl und jede Farbe eine Variable ist und der Code es später ohne Nachdenken übernimmt. Die Figma-Funktionen sind im Oktober 2026 in der Figma-Hilfe und im Figma-Forum geprüft (Quellen am Ende). Wo Figma etwas nicht kann oder wo du selbst kurz prüfen musst, steht es dabei.

## 0 Welche Datei wofür

| Datei | Wofür | Nicht wofür |
|---|---|---|
| **Dieses Design-System** | Die Referenz für Figma und Code: Werte (`tokens.json`), Regeln (README, Abschnitte 01–07), Komponentenkarten mit Aufbau und Maßen | — |
| **Bericht** (Analyse) | Warum etwas so entschieden ist: Befunde aus dem Repository, Begründungen, offene Fragen | Keine Werte daraus abzeichnen. Bei Widerspruch gilt das Design-System. |
| **Figma-Startpaket** (Assets → Figma-Startpaket) | Variablen zum Importieren und das Punktraster | — |

Für eine KI: Gib ihr die Dateien dieses Systems (README, `tokens.json`, die Abschnitte 04, 05 und 07, die `README.md` der Komponenten) und den Auftrag: „Nimm Werte nur aus `tokens.json`, Aufbau und Namen nur aus 04, 05 und 07. Erfinde keine Werte, keine Farben, keine Komponenten.“ Den Bericht nur, wenn sie Begründungen braucht.

## 1 Drei Regeln, die alles einfach machen

1. **Jede Zahl und jede Farbe ist eine Variable.** Du tippst keine Zahl und keinen Farbwert. Erlaubt ohne Variable sind nur: `0`, „Hug“ und „Fill“, 100 % Deckkraft, die Größe der Bildschirmrahmen (das sind Geräte, kein Design) und das wenige, was Figma nicht binden kann (Abschnitt 10).
2. **Was Fläche, Kontur oder Innenabstand hat, ist ein Rahmen mit Auto Layout.** Kein Rechteck hinter Text, keine Leerzeichen oder Leerzeilen als Abstand, keine unsichtbaren Abstandshalter. Eine Textebene hat nur einen Textstil und eine Textfarbe – sonst nichts.
3. **Innenabstand gehört der Komponente, Abstand zwischen Dingen gehört dem Container.** Der Button bringt sein Padding selbst mit. Der Bildschirm legt nur fest, wie weit Dinge auseinanderstehen (Gap) und wie breit der Seitenrand ist – nie das Padding einer Komponente.

So liest der Code später Figma – jede Figma-Eigenschaft hat genau einen Platz:

| In Figma | Im Code (Flutter) | In den Karten (CSS) |
|---|---|---|
| Rahmen mit Auto Layout und Füllung, Ecke, Kontur | die Komponente selbst (`AppButton`, `AppNotice` …); Fläche, Ecke und Kontur stehen einmal im Theme bzw. in der Komponente | ein Element mit `background`, `border-radius`, `border` |
| Padding des Rahmens | Padding im Stil der Komponente (z. B. `ButtonStyle.padding`) – kein `Padding`-Widget um den Text | `padding` |
| Gap | `AppStack(gap: AppSpace.m)` | `gap` |
| Hug · Fill · Fixed | natürliche Größe · `Expanded` · `SizedBox(width: AppSize.…)` | `width: auto` · `flex: 1` · `width: var(--size-…)` |
| Min height | `minimumSize` bzw. `BoxConstraints(minHeight: AppSize.control)` | `min-height` |
| Textebene mit Textstil | `AppText` mit `AppTypography.<stil>` | `font: var(--text-<stil>)` |
| Variante (`variant=secondary`) | benannter Konstruktor (`AppButton.secondary`) | Zusatzklasse (`.us-btn--secondary`) |
| Variable `space/l` | `AppSpacing.l` (Parameter `AppSpace.l`) | `var(--space-l)` |

Die Spalte „Karten“ ist kein Produktcode – sie zeigt nur, dass die Vorschauen dieses Systems genauso gebaut sind (`components/bundle.css`).

## 2 Vorbereiten

- **Plan:** Modi (hell/dunkel, Textgröße 100/200) gibt es in den Plänen Education, Professional, Organization und Enterprise. Ohne Modi kannst du nur hell und nur 100 % anlegen.
- **Schrift:** Atkinson Hyperlegible Next mit 400, 600, 700. Fehlt sie im Schriftmenü, lade sie bei Google Fonts herunter und installiere sie auf dem Rechner; die Desktop-App von Figma liest lokale Schriften, im Browser braucht Figma dafür seinen Font-Installer. Für den Stil `code` nimmt das Startpaket „Roboto Mono“ als Platzhalter – im Code gilt die Monospace-Schrift des Systems.
- **Dateien** wie in Abschnitt 05: `unsalted · Design-System` (Bibliothek), `unsalted · App` (Bildschirme), `unsalted · Werkstatt` (Versuche). Beginne mit der Bibliothek und lege dort die Seiten `Grundlagen`, `Symbole`, `Komponenten`, `Core`, `Templates` an.
- **Startpaket** herunterladen: alle `.tokens.json`-Dateien und `Punktraster.svg`.

## 3 Variablen importieren

1. Klicke auf eine leere Stelle der Arbeitsfläche und öffne rechts im Bereich „Variables“ die Variablenansicht.
2. Lege eine neue Sammlung an und nenne sie **exakt** `primitives`.
3. Ziehe `primitives.tokens.json` in die Variablenansicht. Figma legt je Datei einen Modus an.
4. Wiederhole das für jede Zeile der Tabelle – in dieser Reihenfolge. `primitives` muss zuerst da sein, weil `color` darauf verweist. Bei `color` und `type` ziehst du beide Dateien gemeinsam hinein.
5. Benenne die Modi: in `color` `light` und `dark`, in `type` `100` und `200`. Bleibt ein leerer Modus „Mode 1“ übrig, lösche ihn.
6. Prüfe: In `color` muss `surface-page` im Modus `light` als Verweis auf `neutral/50` erscheinen, nicht als fester Farbwert. Steht dort ein fester Wert, hieß die erste Sammlung beim Import nicht genau `primitives` – dann `color` löschen und neu importieren.

| Reihenfolge | Sammlung (Name exakt) | Datei(en) | Modi | Variablen |
|---|---|---|---|---|
| 1 | `primitives` | `primitives.tokens.json` | einer | 23 |
| 2 | `color` | `color.light.tokens.json`, `color.dark.tokens.json` | `light`, `dark` | 36 (28 Rollen, 8 in `shadow/…`) |
| 3 | `space` | `space.tokens.json` | einer | 7 |
| 4 | `radius` | `radius.tokens.json` | einer | 5 |
| 5 | `stroke` | `stroke.tokens.json` | einer | 6 |
| 6 | `size` | `size.tokens.json` | einer | 16 |
| 7 | `opacity` | `opacity.tokens.json` | einer | 3 |
| 8 | `motion` | `motion.tokens.json` | einer | 4 |
| 9 | `breakpoint` | `breakpoint.tokens.json` | einer | 3 |
| 10 | `type` | `type.100.tokens.json`, `type.200.tokens.json` | `100`, `200` | 27 |

Importiert dein Figma beim Hineinziehen nichts (Figma hat den Import ab Dezember 2025 schrittweise freigeschaltet), legst du die Variablen von Hand an: Namen, Werte und Modi stehen lesbar in den JSON-Dateien.

**Geltungsbereich (Scope)** – damit in jedem Feld nur die passenden Variablen erscheinen. Markiere die Variablen einer Gruppe (erste anklicken, letzte mit Umschalttaste), dann Rechtsklick → „Edit variables“ → Reiter „Scope“:

| Sammlung · Gruppe | Haken bei | Außerdem |
|---|---|---|
| `primitives` | keinem | „Hide from publishing“ |
| `color` (die 28 Rollen) | Fill (Frame, Shape, Text) und Stroke | — |
| `color` · `shadow/…` | Effects | — |
| `space` | Gap (gilt in Auto Layout für Gap und Padding) | — |
| `radius` | Corner radius | — |
| `stroke` | Stroke und Width and height (Linien, die als Fläche gebaut sind: Abschnittslinie, Auswahlbalken, Ladebalken) | — |
| `size` | Width and height | — |
| `opacity` | Layer opacity (und, falls angeboten, die Deckkraft einer Füllung) | — |
| `motion`, `breakpoint` | keinem – nur zum Nachschlagen, Figma bindet sie nirgends | — |
| `type` | `family/…` Font family · `weight/…` Font weight · `…/size` Font size · `…/line-height` Line height | — |

**Kurz prüfen – Deckkraft:** `opacity` steht im Startpaket in Prozent (6, 12, 48), weil Figma die Ebenendeckkraft in Prozent anzeigt. Binde `opacity/hover` testweise an eine Ebene: Figma muss 6 % zeigen. Zeigt es 100 %, erwartet dein Figma Werte zwischen 0 und 1 – trage dann 0.06, 0.12 und 0.48 ein.

## 4 Stile anlegen

**Elf Textstile.** Für jeden Stil: Textebene anlegen, im Bereich „Typography“ Schrift, Schnitt, Größe und Zeilenhöhe an die Variablen binden, Zeichenabstand 0, dann als Stil speichern.

| Textstil | Schrift | Schnitt | Größe · Zeilenhöhe | Ziffern |
|---|---|---|---|---|
| `type/display` | `family/sans` | `weight/bold` | `display/size` · `display/line-height` | tabellarisch |
| `type/title-page` | `family/sans` | `weight/bold` | `title-page/…` | — |
| `type/heading` | `family/sans` | `weight/bold` | `heading/…` | — |
| `type/body` | `family/sans` | `weight/regular` | `body/…` | — |
| `type/body-strong` | `family/sans` | `weight/semibold` | `body-strong/…` | — |
| `type/body-small` | `family/sans` | `weight/regular` | `body-small/…` | — |
| `type/label-small` | `family/sans` | `weight/semibold` | `label-small/…` | tabellarisch |
| `type/caption` | `family/sans` | `weight/regular` | `caption/…` | — |
| `type/data` | `family/sans` | `weight/regular` | `data/…` | tabellarisch |
| `type/data-strong` | `family/sans` | `weight/bold` | `data-strong/…` | tabellarisch |
| `type/code` | `family/mono` | `weight/regular` | `code/…` | — |

Tabellarische Ziffern stellst du im Typo-Menü unter „Details“ ein, bevor du den Stil speicherst. **Kurz prüfen:** Schreib im Stil `type/data` „1111“ und darunter „0000“ – beide müssen gleich breit sein. Behält der Stil die Einstellung nicht, stellst du sie in den Komponenten ein, die Zahlen zeigen (`Value`, `Mark`, `Chip/Info`, Tabellen).

**Zwei Effektstile.**

- `shadow/overlay` (Menüs, Dialoge, Snackbar): zwei Schatten „Drop shadow“, X 0, Spread 0. Schatten 1: Y `shadow/overlay-1-y`, Blur `shadow/overlay-1-blur`, Farbe `shadow/overlay-1-color`. Schatten 2: dasselbe mit `overlay-2`. Im dunklen Modus ist Schatten 2 unsichtbar – so steht es im System.
- `shadow/focus` (Fokusring): zwei Schatten „Drop shadow“, X 0, Y 0, Blur 0. Schatten 1: Spread `shadow/focus-gap`, Farbe `color/surface-page`. Schatten 2: Spread `shadow/focus-ring`, Farbe `color/line-focus`. **Kurz prüfen:** Zwischen Element und Tintenring muss ein Spalt in Papierfarbe zu sehen sein. Siehst du nur Tinte, tausche die Reihenfolge der beiden Schatten.

Farbstile brauchst du nicht – die Variablen sind die Farben.

## 5 Symbole

- Jedes Symbol ist eine Komponente `Icon/<name>`: ein Rahmen, Breite und Höhe an `size/icon` gebunden, darin der Vektor mit Constraint „Scale“. Die Farbe des Vektors bindest du an `color/text-primary` (bei Material Symbols die Füllung, bei Liniensymbolen die Kontur mit Strichstärke `stroke/frame`).
- Namen wie im Code (`AppIcons.byFigmaName`): `add`, `check`, `search`, `edit`, `history`, `delete`, `delete-outline`, `copy`, `compare`, `star`, `star-outline`, `drag-handle`, `info`, `warning`, `error`, `upload`, `download`, `book`, `restaurant`, `empty-plate`, `settings`; neu dazu `timer`, `arrow`, `back`, `lock`, `more`, `close`, `undo`, `chevron`, `link`, `photo`, `swap`.
- Bis das eigene Set steht: Material Symbols Outlined, Gewicht 300, Grade 0, optische Größe 24 – als SVG von der Symbolseite von Google Fonts.
- In Komponenten setzt du die Instanz auf `size/icon-small` oder `size/icon-xs` (Breite und Höhe binden) und überschreibst nur die Farbe.

## 6 Der Button – Schritt für Schritt

Ein Button ist **eine Textebene in einem Auto-Layout-Rahmen**. Den Rahmen ziehst du nicht von Hand auf, und du legst kein Rechteck darunter: Figma baut den Rahmen um den Text, und der Rahmen bekommt Fläche, Ecke und Padding.

1. Textebene „Speichern“ anlegen. Textstil `type/body-strong`, Textfarbe `color/action-on-primary`. Größe der Textebene: „Auto width“.
2. Textebene markieren, **Umschalt + A**: Figma legt einen Auto-Layout-Rahmen um den Text. Nenne ihn `Button`.
3. Auto Layout: horizontal, Ausrichtung mittig. Gap `space/s` (für das Symbol). Padding links und rechts `space/l`, oben und unten 0.
4. Größe: Breite „Hug“, Höhe „Hug“; bei der Höhe „Min height“ hinzufügen und an `size/control` binden. Der Text sitzt dadurch mittig; wird die Schrift größer (Modus `200`), wächst der Button mit, statt abzuschneiden.
5. Fläche `color/action-primary`, Ecke `radius/s`, „Clip content“ an.
6. Symbol: Instanz `Icon/add` vor den Text setzen, Breite und Höhe an `size/icon-small`, Farbe `color/action-on-primary`.
7. Zur Komponente machen (Strg/Cmd + Alt + K) und Eigenschaften anlegen: `variant` (`primary`, `secondary`, `tertiary`), `state` (`default`, `hover`, `pressed`, `focus`, `disabled`, `loading`), `showIcon` (Boolean, schaltet das Symbol), `icon` (Instanztausch), `label` (Text).
8. Varianten:
   - `secondary`: keine Füllung (der Grund scheint durch – Papier, im Dialog Weiß). Kontur `color/line-strong`, Stärke `stroke/frame`, innen. Text und Symbol `color/text-primary`.
   - `tertiary`: keine Füllung, keine Kontur, Padding links und rechts `space/m`. Text und Symbol `color/text-primary`.
9. Zustände (je Variante):
   - `hover`: zweite Füllung über der ersten in der Textfarbe (primär `color/action-on-primary`, sonst `color/text-primary`), Deckkraft dieser Füllung an `opacity/hover` gebunden. Nimmt das Feld keine Variable an, lege stattdessen eine Ebene „State“ als Rahmen mit dieser Füllung über die ganze Fläche (absolut, Constraints links und rechts, oben und unten) und binde deren Ebenendeckkraft.
   - `pressed`: wie `hover` mit `opacity/pressed`.
   - `focus`: wie `hover` plus Effektstil `shadow/focus`. Bei `secondary` und `tertiary` zusätzlich eine Füllung `color/surface-page` mit 1 % – nur in Figma nötig (Abschnitt 10), im Code bleibt die Fläche leer.
   - `disabled`: primär Fläche `color/surface-sunken`; sekundär ohne Fläche mit Kontur `color/line-hairline`; tertiär ohne beides. Text und Symbol `color/text-disabled`.
   - `loading`: Instanz `Feedback/Loading` in `size/icon-small` statt des Symbols, die Beschriftung bleibt – die Breite ändert sich nicht.
10. Volle Breite (z. B. in der Fußleiste) legst du nicht in der Komponente fest: Im Container stellst du die Instanz auf „Fill“.

Was du nicht tust: kein Rechteck unter den Text, kein Leerzeichen vor oder nach dem Wort, keine feste Breite, keine Zahl im Padding.

Im Code entsteht daraus im Bildschirm genau eine Zeile: `AppButton.primary(label: 'Speichern', onPressed: …)`, mit Symbol `AppButton.primary(…, icon: AppIcons.add)`. Padding (`AppSpacing.l`), Mindesthöhe (`AppSize.control`), Ecke (`AppRadius.s`), Schrift (`AppTypography.bodyStrong`) und Farben stehen einmal im Theme bzw. in `AppButton` – aus denselben Variablen. Kein `Padding` um den Text, kein `Container` dahinter.

## 7 Alle Komponenten: Aufbau und Maße

Jede Zeile ist ein Auto-Layout-Rahmen. „Padding“ heißt oben/unten · links/rechts, wenn zwei Werte stehen. Die Karten dieses Systems zeigen dieselben Werte.

| Komponente | Aufbau | Padding | Gap | Größe | Fläche · Kontur · Ecke | Inhalt |
|---|---|---|---|---|---|---|
| `Button` | horizontal, mittig | 0 · `space/l` (tertiär `space/m`) | `space/s` | Min height `size/control` | Abschnitt 6 | `type/body-strong`, Symbol `size/icon-small` |
| `Button/Icon` | mittig | 0 | — | Fixed `size/target` × `size/target` | keine Fläche, `radius/s` | Symbol `size/icon`, `text-primary` (gedämpft `text-secondary`) |
| `Button/FAB` | mittig | 0 | — | Fixed `size/fab` × `size/fab` | `marker`, Kontur `stroke/frame` in `text-on-marker`, `radius/s`, kein Schatten | Symbol `size/icon` in `text-on-marker` |
| `Chip/Choice` | horizontal, mittig | 0 · `space/m` | `space/xs` | Höhe Fixed `size/control-small` | `surface-raised`, Kontur `stroke/hairline` in `line-control`, `radius/s`; gewählt Fläche und Kontur `surface-inverse` | `type/label-small`; gewählt `text-inverse` mit Häkchen `size/icon-xs` |
| `Chip/Info` (Tag) | horizontal, mittig | 0 · `space/s` | `space/xs` | Höhe Fixed `size/mark` | keine Fläche, Kontur `stroke/hairline` in `line-control`, `radius/xs` | `type/label-small`, Symbol `size/icon-xs` |
| `Mark` | horizontal, mittig | 0 · `space/s` | `space/xs` | Höhe Fixed `size/mark` | `fixed`: Kontur `stroke/frame` in `state-frozen`; `provisional`: gestrichelt in `state-draft`; `highlighted`: Fläche `state-master`, Kontur `text-on-marker`; `radius/xs` | `type/label-small`, `lock` in `size/icon-xs` |
| `Input/Text Field` | vertikal: Beschriftung, Feld, Hilfe | — | `space/xs` | Feld: Min height `size/control`, Breite Fill | Feld: `surface-raised`, Kontur `stroke/hairline` in `line-control`, `radius/s`; Fokus `stroke/focus` in `line-focus`; Fehler `stroke/focus` in `text-error`; deaktiviert `surface-sunken`, `line-hairline` | Beschriftung `type/label-small` `text-secondary`; Feld horizontal, Padding 0 · `space/m`, Gap `space/s`, `type/body` (Zahlen `type/data`, rechtsbündig); Hilfe horizontal, Gap `space/xs`, `type/caption`, Symbol `size/icon-xs` |
| `List/Item` | horizontal, mittig | `space/m` · `space/l` | `space/m` | Min height `size/list-item`, Breite Fill | keine Fläche; nur unten Kontur `stroke/hairline` in `line-hairline` | Textblock vertikal, Fill: Titel `type/body-strong`, Untertitel `type/body-small` `text-secondary`; rechts Marke oder Aktionen (Gap `space/s`) |
| `Divider` | — | — | — | Breite Fill; Höhe `stroke/hairline` (oder `stroke/rule`) | Fläche `line-hairline` (oder `line-strong`) | — |
| `Layout/Section` | vertikal | 0 | `space/m`, darin ein vertikaler Rahmen mit `space/s` | Breite Fill | erstes Kind: `Divider` mit `stroke/rule` in `line-strong` | Kopf horizontal, „Space between“, Gap `space/m`: `type/heading` und Meta `type/caption` `text-secondary`; darunter der Inhalt |
| `Core/Ingredient Row` | horizontal, Grundlinie | `space/xs` · 0 | `space/m` | Menge Fixed `size/value-column` | unten Kontur `stroke/hairline` in `line-hairline` | Menge `type/data` rechtsbündig; Name `type/body-strong`, Notiz `type/body-small` |
| `Core/Step Row` | horizontal, oben | `space/s` · 0 | `space/s` | Nummer Fixed `size/index-column` | unten Haarlinie | Nummer `type/data-strong`; Inhalt vertikal, Gap `space/s`: `type/body`, Tag |
| `Data/Key Value Table` | Zeilen vertikal, Zelle horizontal | Zelle `space/xs` oben und unten, `space/m` links (erste Spalte 0) | 0 | erste Spalte Fill, Wertspalten Fixed `size/value-column` | Kopf unten `stroke/frame` in `line-strong`; Zeilen unten Haarlinie | Kopf `type/label-small` `text-secondary`; Werte `type/data` rechtsbündig; kcal-Zeile `type/data-strong`; „davon“ mit Padding links `space/l`, `text-secondary` |
| `Feedback/Notice` | horizontal, oben | `space/m` | `space/m` | Breite Fill | `surface-sunken` (Info, Erfolg), `feedback-warning-surface`, `feedback-error-surface`; `radius/s` | Symbol `size/icon-small` in einem Rahmen mit Padding oben `space/xxs`; Text `type/body`, Fill; Aktion `Button` tertiär mit Min height `size/control-small` |
| `Feedback/Snackbar` | horizontal, mittig | `space/xs`, links `space/l` | `space/m` | Max width `size/dialog` | `surface-inverse`, `radius/s`, Effekt `shadow/overlay` | Text `type/body` `text-inverse`, Fill; Aktion: Padding 0 · `space/m`, Min height `size/target`, `type/body-strong` `action-inverse`; Restzeit absolut unten, Höhe `stroke/rule`, Fläche `action-inverse` |
| `Feedback/Dialog` | vertikal | `space/xl` | `space/xl`, darin vertikal `space/s` | Breite Fixed `size/dialog` | `surface-raised`, Kontur `stroke/hairline` in `line-hairline`, `radius/m`, `shadow/overlay` | Titel `type/title-page`, Text `type/body`; Aktionen horizontal, rechts, Gap `space/s` |
| `Navigation/Top Bar` | horizontal, mittig | 0 · `space/xs` | `space/xxs` | Min height `size/top-bar`, Breite Fill | `surface-page`, unten Haarlinie | Titel als Rahmen (Fill, Padding 0 · `space/m`), `type/title-page`, einzeilig gekürzt; Aktionen `Button/Icon`. Suchbereich: Padding `space/s` oben, `space/l` seitlich, `space/m` unten, unten Haarlinie |
| `Navigation/Navigation Bar` | horizontal, Ziele Fill | 0 | 0 | Breite Fill | `surface-page`, oben Haarlinie | Ziel vertikal, mittig, Padding `space/m` oben, `space/s` unten, Gap `space/xs`, Min height `size/nav-bar`; Symbol `size/icon`, `type/label-small`; gewählt: Balken absolut oben, Breite `size/target`, Höhe `stroke/rule`, Fläche `line-strong` |
| `Navigation/Bottom Action Bar` | horizontal, Buttons Fill | `space/m` · `space/l` | `space/m` | Breite Fill | `surface-page`, oben Haarlinie | Buttons |
| `Frame` | vertikal | `space/m` · `space/l` | `space/s` | Breite Fill | `fixed`: Kontur `stroke/frame` in `state-frozen`; `provisional`: gestrichelt in `state-draft`; `radius/s` | Kopf horizontal, Gap `space/s`: Marke und `type/label-small` `text-secondary` |
| `Slot` (Leerstelle) | vertikal, mittig | `space/xl` · `space/l` | `space/s` | Breite Fill | gestrichelt in `state-draft`, `radius/s`, Clip content; Punktraster als erstes Kind (Abschnitt 9) | Symbol `size/icon` `text-secondary`; Satz `type/body`; eine Aktion |
| `Highlight` | horizontal | 0 · `space/xxs` | — | Hug | `marker`, `radius/xs` | Text `text-on-marker` im Stil der Umgebung |
| `Change` | horizontal, Umbruch | 0 | `space/s` | Breite Fill | — | Gegenstand `type/body-strong` („Butter:“); Alt `type/body` `text-secondary` durchgestrichen; Pfeil `size/icon-xs` `text-secondary`; Neu als `Highlight` |
| `Value` | eine Textebene | — | — | Hug | — | Zahl im Stil `data`, `data-strong` oder `display`; geschütztes Leerzeichen (Mac: Wahltaste + Leertaste); Einheit als Textbereich in `text-secondary`, bei `display` in `type/body-strong` |
| `Feedback/Loading` | vertikal, mittig | 0 | `space/m` | Kreis `size/icon` (im Button `size/icon-small`) | Ellipse mit Bogen, Kontur `stroke/focus` in `text-primary` | — |
| `Feedback/Progress Bar` | — | — | — | Höhe `stroke/rule`, Breite Fill | Fläche `line-hairline`, Balken `line-strong` | — |
| `Core/Version Switcher` (Fassungsleiste) | horizontal, unten | 0 | `space/s` | Ziel Min width `size/target` | Ziel vertikal, Padding oben `space/xs`, Gap `space/xs`; gewählt: Balken Höhe `stroke/rule` in `line-strong` | `Mark` |
| `Core/Nutrition Header` (Kennzahlen) | horizontal, drei Felder Fill | Feld `space/s` · 0, ab dem zweiten links `space/m` | 0 | Breite Fill | oben und unten Haarlinie; ab dem zweiten Feld links Haarlinie | Beschriftung `type/caption` `text-secondary`; Wert `type/data-strong` |
| `Data/Code Block` | vertikal | `space/m` | — | Breite Fill | `surface-sunken`, `radius/s` | `type/code` |
| `Card` | vertikal | `space/l` | nach Inhalt | Breite Fill | `surface-raised`, Haarlinie, `radius/m`, kein Schatten | — |
| Scrim | Rahmen über dem ganzen Bildschirm | — | — | Fill | Fläche `scrim`, Ebenendeckkraft `opacity/scrim` | Dialog darüber |

Farben in der Tabelle sind Variablen der Sammlung `color` (`surface-raised` heißt `color/surface-raised`).

## 8 Layout: Seite, Abschnitt, Stapel, Raster, Spalten

Das Layout gibt es im Code schon – Figma bildet es mit Auto Layout nach. Ein 12-Spalten-Raster gibt es nicht, und du brauchst keins: Am Handy ist alles einspaltig, Lesetext ist höchstens `size/content-max` breit, und mehr Spalten gibt es nur an zwei genau benannten Stellen.

| Im Code | In Figma | Regel |
|---|---|---|
| `AppPage` und die Templates `ListPageTemplate`, `DetailPageTemplate`, `FormPageTemplate` | Komponenten `Template/List Page`, `Template/Detail Page`, `Template/Form Page`: vertikal – Kopfleiste, Inhalt (Fill), Leiste | Fläche `color/surface-page` |
| Inhalt mit Seitenrand (`ListView` mit Padding in Detail- und Formularseiten) | Rahmen `Inhalt`: vertikal, Padding `space/l` am Handy, `space/xl` ab medium; Gap `space/xxl` zwischen Abschnitten | Im Code heute überall `space-l`; ab medium `space-xl` ist eine Änderung in den Templates. Listenseiten haben keinen Seitenrand: `List/Item` bringt `space/l` selbst mit und läuft bis an den Rand (`AppItemList`). |
| `AppSection` | `Layout/Section` (Abschnitt 7) | Abstand davor kommt vom Gap des Inhalts, nicht aus der Section |
| `AppStack`, `AppGap` | jeder Auto-Layout-Rahmen mit Gap | Ein Rahmen hat ein Gap. Brauchst du zwei verschiedene Abstände, verschachtelst du zwei Rahmen – genau wie `AppStack` im Code. |
| `AppPadding` | Padding eines Rahmens | nur Stufen aus `space` |
| `AppSurface`, `AppCard` („Box“) | `Surface/…`, `Card` | Fläche, Ecke, Padding aus Variablen |
| `AppGrid` | Rahmen mit Auto Layout „Grid“: 1, 2 oder 3 gleich breite Spalten, Spalten- und Zeilenabstand `space/m` | compact 1, medium 2, ab expanded 3 Spalten; im Code heute nur im Katalog benutzt |
| Detailseite zweispaltig (`DetailSections`, `twoColumnsFromExpanded`) | horizontaler Rahmen mit zwei Spalten auf Fill | im Code heute aus (`oneColumn`); in Figma erst ab expanded zeichnen |
| `AppWindowSize`, `AppBreakpoints` | ein Bildschirmrahmen je Größe; `breakpoint/…` zum Nachschlagen | compact < 600, medium < 840, expanded < 1200, large ab 1200 |
| Inhaltsbreite | Rahmen `Inhalt`: „Max width“ `size/content-max`, zentriert | Lesetext höchstens 720 |

Layout-Hilfslinien (früher „Layout grids“) sind nur eine Sichthilfe und kommen nicht in den Code. Seitenrand und Spalten entstehen aus Auto Layout – so übernimmt sie der Code.

So sind zwei Bildschirme aufgebaut – eine Listenseite und eine Detailseite:

```
01 Rezeptliste / Inhalt / light / compact   Rahmen 390 × 844, Fläche color/surface-page, vertikal, Clip content
├─ Navigation/Top Bar                       Instanz mit Suchbereich, Breite Fill
├─ Body                                     Fill × Fill, vertikal, Clip content
│  ├─ List/Item                             Instanzen, Breite Fill – kein Seitenrand: der Eintrag bringt space/l selbst mit
│  ├─ List/Item
│  └─ FAB-Platz                             absolut unten rechts (Abstand 0), Padding rechts und unten space/l, darin Button/FAB
└─ Navigation/Navigation Bar                Instanz, Breite Fill

04 Rezeptdetail / Inhalt / light / compact
├─ Navigation/Top Bar                       Instanz, Breite Fill
└─ Body                                     Fill × Fill, vertikal, oben mittig, Clip content
   └─ Inhalt                                vertikal, Breite Fill, Max width size/content-max, Padding space/l, Gap space/xxl
      ├─ Kopf                               vertikal, Gap space/m: Titel type/display, Fassungsleiste, Kennzahlen
      ├─ Layout/Section „Zutaten“           Instanz
      └─ Layout/Section „Zubereitung“       Instanz
```

`Body` entspricht dem Inhalt von `AppPage`, `Inhalt` dem `ListView` mit Padding, der FAB-Platz der Hauptaktion (`primaryAction`), die im Code über der Leiste schwebt.

## 9 Bildschirme bauen

- **Rahmen:** Handy 390 × 844, enges Handy 360 × 640, Tablet 1024 × 1366, Katalog 1440 × 900 (wie in den Tests des Repositorys). Fläche `color/surface-page`, Auto Layout vertikal.
- **Modus** am Rahmen wählen: `color` `light` oder `dark`, `type` `100` oder `200`. Alles darin folgt automatisch. Jeden Inhaltsbildschirm einmal in `200` prüfen.
- **Nur Instanzen.** Überschreibe nur Texte, Booleans und Instanztausch. Löse (detach) nie eine Instanz – sonst gibt es im Code keine Komponente dafür.
- **Namen** wie in Abschnitt 05: `<Nr> <Name> / <Zustand> / <Modus> / <Größe>`.
- **Lange Texte:** Titel „Fill“ in der Breite, „Auto height“, höchstens zwei Zeilen, dann „Truncate text“. Zahlen, Einheiten und Fehlermeldungen kürzt du nie.
- **Punktraster** (nur in der Leerstelle `Slot`, im Startbild und auf dem Cover):
  1. `Punktraster.svg` in die Bibliotheksdatei ziehen. Es ist ein einziger Vektor: Punkte `size-dot` im Abstand `space-xl`, der erste Punkt `space-l` von der Kante.
  2. Füllung des Vektors an `color/line-dot` binden, zur Komponente `Pattern/Dots` machen.
  3. In `Slot` als erstes Kind einsetzen, „Absolute position“, X und Y 0. Am `Slot` „Clip content“ einschalten.
  4. **Kurz prüfen:** Im Modus `dark` müssen die Punkte dunkel werden (#252A34 auf #141925).

  Nimm dafür keine Musterfüllung (Pattern fill): Figma übernimmt dort den Modus nicht.

## 10 Was Figma nicht binden kann

| Was | Warum | So machst du es |
|---|---|---|
| Strich und Lücke der Strichlinie (`stroke/dash` 4, `stroke/gap` 3) | Figma kann Strich und Lücke nicht an Variablen binden. | Einmal in `Mark`, `Frame`, `Slot` und der Unterstreichung nicht verknüpfter Zutaten eintragen – nur dort, nie im Bildschirm. Strichstärke `stroke/frame` und Farbe `state-draft` sind gebunden. |
| Fokusring an Elementen ohne Fläche | Figma zeichnet einen Schatten mit Spread nur bei sichtbarer Füllung (mindestens 1 %) und „Clip content“. | Im Zustand `focus` von `Button` `secondary`/`tertiary` und `Button/Icon`: Füllung `color/surface-page` mit 1 %. Nur in Figma; im Code keine Fläche. |
| Musterfüllung (Pattern fill) | Folgt dem Modus nicht. | Punktraster als Vektor (Abschnitt 9). |
| Lage absolut gesetzter Ebenen (X, Y) | Positionen sind keine Variablen. | Immer 0 und den Abstand über das Padding eines Rahmens geben (FAB-Platz, Restzeitlinie). |

Bietet dir Figma in einem anderen Feld keine Variable an, prüfe zuerst den Scope (Abschnitt 3). Bleibt es dabei, trägst du den Wert aus `tokens.json` ein – nur in der Komponente – und schreibst den Token-Namen in die Komponentenbeschreibung.

## 11 Von Figma in den Code

- **Fläche, Kontur, Ecke, Padding, Mindesthöhe einer Komponente** → einmal im Theme (`AppTheme`, Komponenten-Themes) oder in `App<Name>`. `AppTheme` hat heute noch keine Komponenten-Themes – sie entstehen genau aus diesem Figma-Stand.
- **Gap zwischen Komponenten, Seitenrand** → `AppStack`/`AppGap` im Bildschirm bzw. im Template.
- **Textstil** → `AppTypography.<stil>`; **Farbe** → `AppColorTokens` über das Theme.
- **Variante** → benannter Konstruktor; **Boolean** `show<Teil>` → optionaler Parameter; **Instanztausch** `icon` → Parameter `icon:`.
- **Variablen** → Token-Klassen nach der Namensregel in Abschnitt 05 (`size/control` → `AppSize.control`). Exportiert Figma `opacity` in Prozent, teilt der Generator durch 100.

## 12 Prüfliste vor der Freigabe

- Keine Zahl und kein Farbwert ohne Variable (außer den Ausnahmen in Abschnitt 1 und 10).
- Kein Rechteck hinter Text, keine Leerzeichen als Abstand, keine Abstandshalter.
- Jede Komponente in `light` und `dark` und in `200` ohne abgeschnittenen Text.
- Fokusring mit Spalt in Papierfarbe sichtbar.
- Punktraster wird im dunklen Modus dunkel.
- Jedes Tippziel mindestens `size/target`.
- Bildschirme bestehen nur aus Instanzen; nichts gelöst.
- Namen wie in Abschnitt 05, damit Figma und Dart zusammenpassen.

## Quellen

- Figma-Hilfe: [Modes for variables](https://help.figma.com/hc/en-us/articles/15343816063383-Modes-for-variables) – Pläne mit Modi, Export und Import (DTCG), Verweise in andere Sammlungen.
- Figma-Hilfe: [Guide to variables in Figma](https://help.figma.com/hc/en-us/articles/15145852043927-Guide-to-variables-in-Figma) – wo Zahlenvariablen wirken, Scope, mehrere Variablen gemeinsam bearbeiten, Hide from publishing.
- Figma-Forum: [Variables can now be bound to new fields](https://forum.figma.com/product-updates-3/variables-can-now-be-bound-to-new-fields-in-figma-13940) – Schatten, Konturstärke, Ebenendeckkraft.
- Figma-Forum: [Gap gilt auch für Padding](https://forum.figma.com/suggest-a-feature-11/variables-distinguish-between-auto-layout-gap-and-padding-29182).
- Figma-Forum: [Spread nur mit Füllung](https://forum.figma.com/ask-the-community-7/why-figma-not-supporting-spread-function-for-without-fill-component-and-frames-22505) (Antwort des Figma-Supports, Juni 2024).
- Figma-Forum: [Musterfüllung folgt dem Modus nicht](https://forum.figma.com/report-a-problem-6/pattern-fill-doesn-t-respect-mode-46041) (Oktober 2025).
- Figma-Forum: [Keine Variablen für Strich und Lücke](https://forum.figma.com/suggest-a-feature-11/variable-support-for-stroke-dash-and-gap-37446) (Februar 2025).
- Figma-Forum: [Auto Layout „Grid“](https://forum.figma.com/share-your-feedback-26/config-2025-grid-auto-layout-flow-let-s-hear-what-you-think-40316) – Abstände zwischen Spalten und Zeilen lassen sich an Variablen binden.
- Figma-Forum: [Import schrittweise freigeschaltet](https://forum.figma.com/ask-the-community-7/native-variable-export-feature-47831) (Dezember 2025).
