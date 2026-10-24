> **Status: freigegeben (design-v0.3.0).** Dieses System beschreibt die visuelle Identität von unsalted. Es ist mit Teil 1.3 im Code umgesetzt und in Teil 1.4 ergänzt (`packages/unsalted_design` 0.3.0); bewusste Abweichungen des Codes von Figma stehen in `docs/design/rueckmeldung-figma.md`.

Für Figma: Schritt-für-Schritt-Anleitung in Abschnitt 07, Variablen zum Importieren unter Assets → Figma-Startpaket.

## Grundidee: Bleistift · Tinte · Marker

unsalted ist ein Werkzeug, um Rezepte in Fassungen zu entwickeln: Entwürfe bearbeiten, Stände einfrieren, Fassungen vergleichen, die beste zum Master küren – mit exakter, ehrlicher Nährwertrechnung. Die Oberfläche macht diesen Lebenszyklus sichtbar. Jedes Element zeigt, wie fest es ist.

- **Bleistift = vorläufig.** Entwürfe, Leerstellen, offene Angaben: Graphit (`text-secondary`, `state-draft`) und die gestrichelte Linie (`stroke-frame`, `stroke-dash` 4 / `stroke-gap` 3).
- **Tinte = fest.** Eingefrorene Fassungen, bestätigte Werte, Text, Primäraktionen: Tinte (`text-primary`, `state-frozen`, `action-primary`) und die durchgezogene Linie.
- **Marker = markiert.** Was neu, geändert, gefunden oder gekürt ist: `marker` als Hinterlegung hinter Tinte (`text-on-marker`).

Gestrichelt heißt immer „noch offen“, durchgezogen immer „fest“. Verwende die Strichlinie für nichts anderes.

Der Grund ist **Papier**: ein Hauch warm (#F9F7F1), wie eine Notizbuchseite, aber bewusst kein Creme. Wo eine Fläche noch leer ist, zeigt sie das **Punktraster** des Notizbuchs – „hier ist noch Platz“. Auf Flächen mit Inhalt bleibt das Papier glatt.

## Inhalt und Sprache

- Sprich die Person mit „du“ an, wie die App es heute tut („Deine Eingaben sind noch nicht gespeichert.“).
- Schreibe kurze Aussagesätze mit Punkt: „Noch keine Rezepte.“ „Keine Treffer.“ Keine Ausrufezeichen, keine Emojis, keine Superlative.
- Beschrifte Buttons mit Verben: „Speichern“, „Einfrieren“, „Kopieren“, „Als neuen Entwurf übernehmen“. Tooltips sind Substantivgruppen: „Neues Rezept“.
- Schreibe Zahlen deutsch: Dezimalkomma, Tausenderpunkt bei kcal („2.221 kcal“), Gramm mit einer Stelle („2,5 g“), Salz mit zwei („1,80 g“). Unbekanntes ist „—“, Unvollständiges trägt „*“ mit Fußnote. Rundung entsteht nur im `NutritionFormatter`.
- Trenne Zahl und Einheit mit geschütztem Leerzeichen (U+00A0). Die Schrift enthält kein schmales geschütztes Leerzeichen (U+202F).
- Nutze den Halbgeviertstrich mit Leerzeichen als Gedankenstrich („gelöscht – bitte neu auswählen“) und ohne Leerzeichen für Spannen („1–200“). Die App mischt heute Geviert- und Halbgeviertstrich; vereinheitliche auf den Halbgeviertstrich.
- Schreibe den Namen klein: „unsalted“ (so in allen Produkttexten). Die Schreibweise der Wortmarke ist noch offen.
- Bewerte keine Nährwerte. Keine Ampel, keine Worte wie „gesund“ oder „zu viel“.

## Farbe

- Setze Seiten, Kopf-, Navigations- und Fußleisten auf `surface-page` (Papier). Listen, Tabellen, Leerstellen, Tags sowie Sekundär- und Tertiärbuttons haben keine eigene Fläche – sie zeigen das Papier. Weiß (`surface-raised`) tragen nur Eingabefelder, Auswahl-Chips, Karten, Dialoge und Menüs; `surface-sunken` nur Hinweise, Codeblöcke sowie deaktivierte Primärbuttons und Felder. Trenne Flächen mit `line-hairline`, nicht mit Schatten.
- Setze Text in `text-primary`; Metadaten, Einheiten und „—“ in `text-secondary` (ab 13 px). Beide lesen auf allen drei Flächen in beiden Modi mit mindestens 4,5 : 1.
- Fülle Primärbuttons mit `action-primary`, beschriftet in `action-on-primary`. Primäraktionen sind Tinte, nicht farbig.
- Verwende `marker` nur für: geänderte und neue Werte im Vergleich, Suchtreffer, die Master-Fassung (`state-master`), den Marker-Knopf und „Rückgängig“ (`action-inverse`). Text darauf ist immer `text-on-marker`.
- Verwende `marker` nie als Textfarbe, nie für Warnungen, nie als große Fläche (Karten, Kopfzeilen, Hintergründe). Im Ruhezustand höchstens ein Marker-Element je Bildschirm, dazu Treffer und Änderungen.
- Zeige Fehler in `text-error` bzw. auf `feedback-error-surface`, Warnungen in `text-warning` bzw. auf `feedback-warning-surface` – immer mit Symbol und Wort, denn Fehler- und Warnfarbe haben fast gleiche Helligkeit.
- Info und Erfolg haben keine eigene Farbe: `surface-sunken`, `text-primary`, Symbol `info` bzw. `check`.
- Das Punktraster (`line-dot`) ist rein dekorativ und absichtlich leise (1,24 : 1 hell, 1,22 : 1 dunkel). Es trägt nie eine Bedeutung allein.
- Zeige Änderungen ohne Rot und Grün: Altes in `text-secondary` durchgestrichen, Neues mit `marker` hinterlegt.
- Konturen von Eingaben, Chips und Tags sind `line-control` (≥ 3 : 1). Den Fokus zeigt `shadow-focus`: 2 px Abstand in Seitenfarbe, dann 2 px `line-focus`.

## Typografie

- Setze alles in Atkinson Hyperlegible Next (`sans`, SIL OFL 1.1) mit drei Schnitten: 400, 600, 700. Sie unterscheidet verwechselbare Zeichen (1/l/I, 0/O, die Null trägt einen Schrägstrich) – bei Mengen und Nährwerten zählt das.
- Nutze die Stile: `display` (Rezepttitel, höchstens einmal je Bildschirm), `title-page` (Kopfleiste, Dialoge), `heading` (Abschnitt, immer unter der 3-px-Linie), `body` (Fließtext, Schritte, Eingaben), `body-strong` (Listentitel, Buttons, Zutatennamen), `body-small` (Untertitel), `label-small` (Fassungsmarke, Tags, Feldbeschriftung, Navigation), `caption` (Hilfe, Fußnoten), `data` und `data-strong` (Werte), `code` (JSON).
- Schalte für `data`, `data-strong`, `label-small` und Kennzahlen immer tabellarische Ziffern ein (OpenType `tnum`). Die Schrift hat proportionale Standardziffern.
- Fließtext nie unter 16 px, nichts unter 13 px. Satzschreibung, keine Versalien, kein Sperrsatz.
- Brich Titel höchstens zweizeilig um, dann Auslassungspunkte. Kürze nie Zahlen, Einheiten oder Fehlermeldungen.

## Form, Linie, Raum

- Abstände nur in Stufen: `space-xxs` 2 bis `space-xxl` 32 (4-px-Raster). Seitenrand `space-l` am Handy, `space-xl` ab `breakpoint-medium`. Lesetext höchstens `size-content-max` breit.
- Radien klein: `radius-xs` für Marken, Tags und Markierungen, `radius-s` für Buttons, Felder, Chips und Hinweise, `radius-m` für Karten und Dialoge. Pillen und Kreise nur für Schalter und spätere Avatare.
- Linien: `stroke-hairline` für Trenner und Konturen, `stroke-frame` für Zustandsrahmen und Sekundärbuttons, `stroke-focus` für Fokus, `stroke-rule` (3 px) für Abschnittslinien und Auswahlbalken.
- Beginne jeden Abschnitt einer Lese- oder Formularseite mit `stroke-rule` in `line-strong`, `space-m`, `heading`, `space-s`, Inhalt; zwischen Abschnitten `space-xxl`.
- Punktraster: Punkte `size-dot` (2 px) in `line-dot`, Abstand `space-xl`, an der Inhaltskante ausgerichtet; es scrollt mit. Nur in Leerstellen (leere Listen, leere Fotoplätze), im Startbild, auf dem Cover und den Store-Bildern – nie hinter Text, Tabellen, Feldern oder Fassungsmarken. „Keine Treffer.“ bekommt kein Punktraster.
- Schatten (`shadow-overlay`) nur für Menüs, Dialoge und Snackbar.
- Tippziele mindestens `size-target` (48 × 48), auch wenn das Element kleiner aussieht.
- Feste Maße von Komponenten – Höhen, Breiten, Spalten – sind `size-…`-Tokens (`size-control`, `size-list-item`, `size-value-column` …). Komponenten und Bildschirme nennen nie Zahlen.

## Zustände und Bewegung

- Hover und Fokus: Überlagerung in `text-primary` mit `opacity-hover`; Drücken mit `opacity-pressed`. Deaktiviert: `surface-sunken` mit `text-disabled`.
- Auswahl ist ein 3-px-Balken in `line-strong` (Navigation, Fassungsleiste) oder eine inverse Fläche (`surface-inverse`, Chips mit Häkchen) – nie nur eine Farbe.
- Laden: zentrierter Ladekreis in `text-primary`; Ladebalken (`stroke-rule`) erst nach 300 ms.
- Bewegung: `duration-short` 150 ms für Zustände, `duration-medium` 250 ms für Ein- und Ausblenden und den Marker-Strich beim Küren, `duration-long` 400 ms für das Einfrieren (die Strichlinie schließt sich zur Tintenlinie). Kurve `easing-standard`, keine Federn. Bei „Bewegung reduzieren“ entfällt jede Animation.

## Symbole und Bilder

- Symbole: eigenes, linienbasiertes Set auf 24-px-Raster mit 1,5-px-Strich, eckigen Enden und Ecken mit 1 px Radius; Namen wie in `AppIcons.byFigmaName` (`add`, `check`, `search`, `edit`, `history`, `delete`, `delete-outline`, `copy`, `compare`, `star`, `star-outline`, `drag-handle`, `info`, `warning`, `error`, `upload`, `download`, `book`, `restaurant`, `empty-plate`, `settings`), neu dazu `timer`, `arrow`, `back`, `lock`, `more`, `close`, `undo`, `chevron`, `link`, `photo`, `swap`. Die Vorschauen zeigen Skizzen dieses Stils; heute nutzt der Code Material Icons.
- Bis das Set steht: in Figma Material Symbols Outlined, Gewicht 300, Grade 0, optische Größe 24 – einheitlich, nie gemischt mit gefüllten Varianten. Im Code bleiben bis dahin die mitgelieferten Material Icons, bevorzugt ihre Outlined-Varianten; Material Symbols bräuchten eine eigene gebündelte Schriftdatei.
- Keine Illustrationen, keine Maskottchen. Leere Zustände sind Leerstellen (gestrichelt, mit Punktraster) mit Satz und Aktion.
- Fotos (ab Teil 4) dokumentieren das Ergebnis einer Fassung: Tageslicht, ruhiger Grund, 4:3, keine Requisiten; jedes Foto trägt seine Fassungsmarke. Kein Vollbild-Hero in Listen.

## Barrierefreiheit

- Ziel: WCAG 2.2 AA. Text ≥ 4,5 : 1, große Schrift und Bedienelemente ≥ 3 : 1 – in beiden Modi geprüft (Werte in den Token-Hinweisen).
- Zustand nie nur über Farbe oder Linienart: Fassungen tragen ihr Wort („Entwurf“, „Eingefroren“, „Master“) im Text oder in der Semantik.
- Alles, was gezogen wird, hat eine Alternative ohne Ziehen (Umsortieren über „Nach oben“/„Nach unten“, WCAG 2.5.7); Wischen zum Löschen hat den Menüpunkt „Löschen“.
- Textgröße bis 200 % ohne abgeschnittene Inhalte; Fokus immer sichtbar.

## Bewusste Ergänzungen gegenüber dem Repository

- `Mark` (Fassungsmarke), `Frame` (Zustandsrahmen, Leerstelle), `Highlight` (Marker, Änderung), `Value` (Messwert): Sie tragen die Identität und kommen in vielen Bildschirmen vor; im Code gibt es sie noch nicht.
- Die vier Bildschirm-Muster zeigen dieselbe Sprache in Liste, Lesen, Vergleichen und Bearbeiten.

## Nicht aus dem Code übernommen

- Farbwerte: Der Code trägt die Material-3-Standardfarben (u. a. `primary` #6750A4) als Platzhalter; sie wurden bewusst nicht übernommen. Die 46 Material-Rollen werden auf die neuen Tokens abgebildet (Abschnitt „Farbe“).
- Typografie: Der Code nutzt die Material-3-Skala (15 Rollen) mit Systemschrift; ersetzt durch 11 eigene Stile.
- Radien und Höhen: Material-Skala ersetzt.
- Schriftdateien, Logos, Symbole: Im Repository gibt es keine (App-Symbole sind das Flutter-Standardlogo). Die Schrift ist neu gewählt und als WOFF2 beigelegt; eine Wortmarke ist nicht gestaltet.
- Komponenten: Flutter-Widgets lassen sich hier nicht ausführen. Die Vorschauen sind statische HTML-Nachbildungen des Vorschlags, kein Produktcode.

---

## Consuming this system (generated — do not edit)

Every path named below is under `project/` in this design system: read `project/api/tokens.md`, not `api/tokens.md`.

20 components are documented without a runnable `components/bundle.js`: read each component’s card, and its README where it has one (`components/<Comp>/README.md`), and build to those guidelines. Tokens: the values are on `api/tokens.md`; a Slides deck or Design canvas also takes `tokens.json` by file path.

Fonts: `tokens.css` loads each font from its file, by path.

- **Design canvas:** copy `tokens.css`, `fonts/AtkinsonHyperlegibleNext-Regular.woff2`, `fonts/AtkinsonHyperlegibleNext-SemiBold.woff2` and `fonts/AtkinsonHyperlegibleNext-Bold.woff2` to the same paths under the canvas’s `project/ds/<folder>/` (`<folder>` is the folder you install this system under; `fonts/AtkinsonHyperlegibleNext-Regular.woff2` lands on `project/ds/<folder>/fonts/AtkinsonHyperlegibleNext-Regular.woff2`), in the same call that installs this system. Link that copy of `tokens.css` in the artboard’s `<head>` as `ds/<folder>/tokens.css`, or as Design’s instructions say for an artboard in a folder. If the install’s reply leaves a font out, bring that font in as for any other page.
- **Slides deck:** for each family you use in the deck (`faces` holds at most the number of typefaces Slides’ `deck-files.md` gives), install its file with the system and name the path it lands on as that family’s `src` in `project/deck.json` `faces`, under the key in the Slides column. A deck takes a font as a file only under the rule in Slides’ `fonts.md` (no space or leading underscore in its path, for two): any other font, or one kept by id, is uploaded as `fonts.md` says.
- **Any other page:** one file per family is enough (below: the upright face nearest regular weight; bold and italic synthesize). Fetch it as the fetch column says (Artifact tool `read`, that id or path as `path`), upload it as an asset (`publish`, `file_path`, `asset:true`) and declare it with an `@font-face { font-family: "<family>"; src: url(<uploaded>) }` rule.

| family | file | fetch | CSS | Slides `faces` key |
| --- | --- | --- | --- | --- |
| Atkinson Hyperlegible Next | `fonts/AtkinsonHyperlegibleNext-Regular.woff2` (weight 400) | `read` the file with `project/` in front | `var(--font-sans)` | `atkinson-hyperlegible-next` |

**Read, per thing:** a component’s props, parts and examples: `api/components/<Comp>.md`; token values: `api/tokens.md`. After this README, fetch the cards and fonts you need in ONE message as parallel calls — none depends on another.

**Two rules.** Before you use a thing — a component, a token group, an icon, an asset — read its card from the index below; a value you did not read from a card is a guess. `tokens.json`, `manifest.json` and `design-system.json` are sources for tools: hand them over. `components/<Comp>/README.md` is the long-form second read a card links to; `SKILL.md` and `artifact-type/` beside them are authoring guidance, not needed to consume the system.

## Index (generated — do not edit)

**Tokens**

- `api/tokens.md` — Every token: surface, text, palette, type, spacing, radius, shadow, stroke, size, opacity, breakpoint, duration, easing. (17.3k)

**Components** (`api/components/<Comp>.md`, 20)

- **Aktionen**: `Button` — Drei Gewichte – Tintenfläche, Tintenkontur, nur Text – und höchstens eine Primäraktion je Bereich · `Fab` — Der Marker-Knopf ist die eine Hauptaktion einer Seite – gelb, kantig, mit Tintenkontur
- **Auswahl**: `Chip` — Auswahl-Chips wählen zwischen wenigen Ansichten; Tags kennzeichnen Werte wie Timer oder Herkunft
- **Markenelemente**: `Frame` — Der Zustandsrahmen fasst einen Arbeitsstand ein: gestrichelt, solange er vorläufig ist, durchgezogen, sobald er eingefroren ist; die Leerstelle ist sein leerer… · `Highlight` — Der Marker hinterlegt, was neu, geändert oder gefunden ist – wie ein Textmarker auf Papier; Altes wird in Graphit gestrichen · `Mark` — Die Fassungsmarke zeigt Nummer und Zustand einer Fassung: gestrichelt heißt Entwurf, Tintenkontur heißt eingefroren, Markerfläche heißt Master · `Value` — Ein Messwert ist Zahl plus Einheit mit ehrlichem Zustand: bekannt, unbekannt („—“) oder unvollständig („*“ mit Fußnote)
- **Daten**: `KeyValueTable` — Die Deklarationstabelle zeigt Nährwerte wie ein Etikett: Tintenlinien, Haarlinien, rechtsbündige tabellarische Ziffern
- **Listen**: `ListItem` — Listeneintrag ohne Karte: Titel, Untertitel, rechts Fassungsmarke oder Aktionen; Haarlinien trennen
- **Navigation**: `NavigationBar` — Hauptnavigation mit drei Zielen; die Auswahl ist ein Tintenbalken an der Oberkante statt einer Pille · `TopBar` — Kopfleiste mit linksbündigem Titel, Aktionen rechts und optionalem Suchfeld darunter; eine Haarlinie statt Schatten
- **Rückmeldung**: `Notice` — Hinweiszeile mit Symbol: neutral für Info und Erfolg, Orange für Warnungen, Rot für Fehler · `Snackbar` — Kurze Meldungen auf inverser Fläche mit „Rückgängig“ in Marker und sichtbarer Restzeit; Rückfragen als Dialog · `States` — Leer-, Fehler- und Ladezustand einer Seite: Leerstelle mit Satz und Aktion, Klartext mit „Erneut versuchen“, Ladekreis
- **Bildschirme**: `ScreenRezeptEditor` — Muster für Bildschirm 3 (Rezept bearbeiten): Entwurf im gestrichelten Rahmen, zweizeilige Zutatenzeilen, Einfrieren als Markenmoment · `ScreenRezeptdetail` — Muster für Bildschirm 4–6 (Rezeptdetail mit Nährwerten und Mengenrechner): Lesen auf Armlänge in der Küche · `ScreenRezeptliste` — Muster für Bildschirm 1 (Rezeptliste): Suche mit Marker-Treffern, Fassungsmarke je Rezept, Marker-Knopf · `ScreenVersionsvergleich` — Muster für Bildschirm 8 (Versionsvergleich): Änderungen als gestrichen → markiert, Folge vor dem Übernehmen sichtbar
- **Layout**: `Section` — Abschnitt mit 3-px-Tintenlinie, fetter Überschrift und Inhalt – die Deklarationslogik der Lese- und Formularseiten
- **Eingaben**: `TextField` — Eingabefeld mit Beschriftung darüber, weißer Fläche und feiner Kontur; Zahlen rechtsbündig mit Einheit im Feld
