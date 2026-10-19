# Farbe

**Wie viele Farben?** Vier Farbfamilien: eine neutrale Reihe (Papier → Graphit → Tinte), ein Marker, Fehler-Rot, Warn-Orange. Info und Erfolg bekommen bewusst keine eigene Farbe. Das ergibt **23 Farbwerte** in der Markenpalette (Primitive) und **28 semantische Rollen** (Tokens), die nur auf Primitive verweisen. Sichtbar als Marke sind vier Farben: **Papier, Graphit, Tinte, Marker**. Das Papier ist ein Hauch warm (#F9F7F1) – wie ein Notizbuch, aber bewusst kein Creme; leere Flächen tragen ein feines Punktraster (`line-dot`).

Regel: Komponenten und Bildschirme verwenden nur semantische Rollen. Primitive werden nie direkt verwendet; ein Farbwert wird an genau einer Stelle gepflegt.

## Markenpalette (Primitive)

| Primitiv | HEX | RGB | OKLCH | Rolle |
|---|---|---|---|---|
| `neutral-0` | `#FFFFFF` | 255, 255, 255 | 1.000 0.000 0 | Primitiv „Weiß“. Nur über `surface-raised` (hell) verwenden, nie direkt in Komponenten. |
| `neutral-50` | `#F9F7F1` | 249, 247, 241 | 0.976 0.008 91 | Primitiv „Papier“ (Markenfarbe), ein Hauch warm – bewusst kein Creme. Seitengrund hell, Text dunkel. Nur über semantische Tokens verwenden. |
| `neutral-100` | `#F0EEE9` | 240, 238, 233 | 0.949 0.007 89 | Primitiv. Vertiefte Flächen hell (`surface-sunken`). |
| `neutral-150` | `#E2DFDA` | 226, 223, 218 | 0.905 0.008 81 | Primitiv. Haarlinien und Punktraster hell (`line-hairline`, `line-dot`). |
| `neutral-400` | `#9B9FA3` | 155, 159, 163 | 0.700 0.008 258 | Primitiv. Sekundärtext und Entwurfslinie dunkel, deaktivierter Text hell. |
| `neutral-500` | `#7D8086` | 125, 128, 134 | 0.600 0.010 258 | Primitiv. Bedienelement-Kontur (`line-control`) in beiden Modi, Entwurfslinie hell. |
| `neutral-600` | `#5E6269` | 94, 98, 105 | 0.495 0.012 260 | Primitiv „Graphit“ (Markenfarbe). Sekundärtext hell, deaktivierter Text dunkel. |
| `neutral-700` | `#434851` | 67, 72, 81 | 0.400 0.016 262 | Primitiv. Haarlinien dunkel. |
| `neutral-800` | `#252A34` | 37, 42, 52 | 0.285 0.020 264 | Primitiv. Erhöhte Flächen und Punktraster dunkel (`surface-raised`, `line-dot`). |
| `neutral-900` | `#141925` | 20, 25, 37 | 0.215 0.024 265 | Primitiv „Tinte“ (Markenfarbe, Blauschwarz). Text und Primäraktion hell, Seitengrund dunkel. |
| `neutral-950` | `#0C1019` | 12, 16, 25 | 0.175 0.020 265 | Primitiv. Vertiefte Flächen dunkel, Scrim. |
| `marker-400` | `#FEE545` | 254, 229, 69 | 0.915 0.170 100 | Primitiv „Marker“ (Markenfarbe, Textmarker-Gelb), heller Modus. Nur über `marker`, `state-master` und `action-inverse` verwenden; niemals als Textfarbe. |
| `marker-500` | `#EDD13D` | 237, 209, 61 | 0.860 0.160 98 | Primitiv „Marker“ für den dunklen Modus: etwas dunkler, damit er auf Tinte nicht blendet (Tinte darauf 11,5 : 1). |
| `red-100` | `#FDE9E8` | 253, 233, 232 | 0.950 0.022 20 | Primitiv. Fehlerfläche hell. |
| `red-300` | `#F4918E` | 244, 145, 142 | 0.760 0.120 22 | Primitiv. Fehlertext dunkel. |
| `red-600` | `#C32A28` | 195, 42, 40 | 0.535 0.190 27 | Primitiv. Fehlertext hell. |
| `red-800` | `#831A18` | 131, 26, 24 | 0.400 0.140 27 | Primitiv. Text auf Fehlerfläche hell. |
| `red-900` | `#4D1C1A` | 77, 28, 26 | 0.300 0.075 25 | Primitiv. Fehlerfläche dunkel. |
| `orange-100` | `#FEEDD9` | 254, 237, 217 | 0.955 0.032 72 | Primitiv. Warnfläche hell. |
| `orange-300` | `#F3AD66` | 243, 173, 102 | 0.800 0.120 65 | Primitiv. Warntext dunkel. |
| `orange-700` | `#A6560A` | 166, 86, 10 | 0.540 0.130 55 | Primitiv. Warntext hell. |
| `orange-800` | `#763A0D` | 118, 58, 13 | 0.420 0.100 52 | Primitiv. Text auf Warnfläche hell. |
| `orange-900` | `#492811` | 73, 40, 17 | 0.315 0.060 55 | Primitiv. Warnfläche dunkel. |

## Semantische Rollen (Tokens)

| Token | Hell | Dunkel | Einsatz |
|---|---|---|---|
| `surface-page` | `neutral-50` #F9F7F1 | `neutral-900` #141925 | Seitengrund jeder Seite, Kopfleiste, Navigationsleiste, Fußleiste. Listen, Tabellen, Leerstellen, Tags sowie Sekundär- und Tertiärbuttons haben keine eigene Fläche und liegen auf diesem Papier. |
| `surface-raised` | `neutral-0` #FFFFFF | `neutral-800` #252A34 | Erhöhte Flächen, hell weiß: Eingabefelder, Auswahl-Chips, Karten, Dialoge, Menüs – sonst nichts. Hebt sich durch Kontur (`line-control`) oder Haarlinie (`line-hairline`) ab, nicht durch Schatten. |
| `surface-sunken` | `neutral-100` #F0EEE9 | `neutral-950` #0C1019 | Vertiefte Flächen: neutrale Hinweise (Info und Erfolg), Codeblock, deaktivierte Primärbuttons und Felder. Tabellenköpfe haben keine Fläche, nur die Tintenlinie. |
| `surface-inverse` | `neutral-900` #141925 | `neutral-50` #F9F7F1 | Umgekehrte Fläche: Snackbar, ausgewählter Chip. Text darauf: `text-inverse`. |
| `scrim` | `neutral-950` #0C1019 | `neutral-950` #0C1019 | Abdunklung hinter Dialogen und Sheets, immer mit `opacity-scrim`. |
| `text-primary` | `neutral-900` #141925 | `neutral-50` #F9F7F1 | Haupttext auf `surface-page`, `surface-raised`, `surface-sunken` (hell 16,4 / 17,6 / 15,1 : 1; dunkel 16,4 / 13,4 / 17,8 : 1). |
| `text-secondary` | `neutral-600` #5E6269 | `neutral-400` #9B9FA3 | Sekundärtext, Metadaten, Einheiten, unbekannte Werte („—“) auf `surface-page`, `surface-raised`, `surface-sunken` (hell 5,7 / 6,1 / 5,3 : 1; dunkel 6,6 / 5,4 / 7,1 : 1). Ab 13 px. |
| `text-disabled` | `neutral-400` #9B9FA3 | `neutral-600` #5E6269 | Text deaktivierter Bedienelemente (von WCAG 1.4.3 ausgenommen, 2,3–3,1 : 1). Nie für lesbare Inhalte. |
| `text-inverse` | `neutral-50` #F9F7F1 | `neutral-900` #141925 | Text und Symbole auf `surface-inverse` und `action-primary` (16,4 : 1 in beiden Modi). |
| `text-on-marker` | `neutral-900` #141925 | `neutral-900` #141925 | Text und Symbole auf `marker` – in beiden Modi Tinte (13,8 : 1). Auch Kontur des Marker-Knopfs. |
| `text-error` | `red-600` #C32A28 | `red-300` #F4918E | Fehlertext und Fehlersymbol auf `surface-page`, `surface-raised`, `surface-sunken` (hell ≥ 4,9 : 1; dunkel ≥ 6,4 : 1). Immer mit Symbol oder Wort. |
| `text-warning` | `orange-700` #A6560A | `orange-300` #F3AD66 | Warntext und Warnsymbol auf `surface-page`, `surface-raised` (hell 5,0 / 5,3 : 1; dunkel 9,2 / 7,5 : 1). Immer mit Symbol oder Wort. |
| `line-hairline` | `neutral-150` #E2DFDA | `neutral-700` #434851 | Dekorative Haarlinien: Listentrenner, Kanten von Karten und Leisten. Nie die einzige Kante eines Bedienelements. |
| `line-dot` | `neutral-150` #E2DFDA | `neutral-800` #252A34 | Punktraster wie im Notizbuch – nur auf leeren Flächen: Leerstellen, Startbild, Cover. Punkt `size-dot` (2 px), Abstand `space-xl`, an der Inhaltskante. Rein dekorativ (1,24 : 1 hell, 1,22 : 1 dunkel); nie hinter Text, Tabellen, Feldern oder Fassungsmarken. |
| `line-control` | `neutral-500` #7D8086 | `neutral-500` #7D8086 | Konturen von Eingabefeldern, Chips, Tags, Checkboxen – mindestens 3 : 1 auf allen Flächen (hell 3,4–4,0; dunkel 3,6–4,8). |
| `line-strong` | `neutral-900` #141925 | `neutral-50` #F9F7F1 | Tintenlinien: 3-px-Abschnittslinie, durchgezogener Rahmen eingefrorener Inhalte, Kontur des Sekundärbuttons, Auswahlbalken. |
| `line-focus` | `neutral-900` #141925 | `neutral-50` #F9F7F1 | Fokusring (2 px, 2 px Abstand) auf allen Flächen ≥ 13 : 1. Alias-Bedeutung: Tinte. |
| `action-primary` | `neutral-900` #141925 | `neutral-50` #F9F7F1 | Fläche des Primärbuttons. Beschriftung: `action-on-primary`. |
| `action-on-primary` | `neutral-50` #F9F7F1 | `neutral-900` #141925 | Beschriftung und Symbol auf `action-primary` (16,4 : 1). |
| `action-inverse` | `marker-400` #FEE545 | `neutral-900` #141925 | Aktion auf inverser Fläche, z. B. „Rückgängig“ in der Snackbar (hell Marker auf Tinte 13,8 : 1; dunkel Tinte auf Papier 16,4 : 1). |
| `marker` | `marker-400` #FEE545 | `marker-500` #EDD13D | Textmarker: hinterlegt Geändertes, Treffer und die Master-Fassung; Fläche des Marker-Knopfs (FAB). Nie als Textfarbe, nie für Warnungen, nie großflächig. Text darauf: `text-on-marker` (13,8 : 1 hell, 11,5 : 1 dunkel). |
| `state-draft` | `neutral-500` #7D8086 | `neutral-400` #9B9FA3 | Entwurf (vorläufig): gestrichelte 1,5-px-Linie, ≥ 3 : 1 auf `surface-page` und `surface-raised`. Bedeutung immer zusätzlich als Wort. |
| `state-frozen` | `neutral-900` #141925 | `neutral-50` #F9F7F1 | Eingefroren (fest): durchgezogene 1,5-px-Linie in Tinte. |
| `state-master` | `marker-400` #FEE545 | `marker-500` #EDD13D | Master (gekürt): Markerfläche mit `text-on-marker`. |
| `feedback-error-surface` | `red-100` #FDE9E8 | `red-900` #4D1C1A | Fläche von Fehlerhinweisen und Wisch-zum-Löschen-Hintergrund. Inhalt: `feedback-on-error-surface`. |
| `feedback-on-error-surface` | `red-800` #831A18 | `red-100` #FDE9E8 | Text und Symbol auf `feedback-error-surface` (hell 8,5 : 1; dunkel 12,0 : 1). |
| `feedback-warning-surface` | `orange-100` #FEEDD9 | `orange-900` #492811 | Fläche von Warnhinweisen (z. B. „Nicht berechenbar“). Inhalt: `feedback-on-warning-surface`. |
| `feedback-on-warning-surface` | `orange-800` #763A0D | `orange-100` #FEEDD9 | Text und Symbol auf `feedback-warning-surface` (hell 7,7 : 1; dunkel 11,5 : 1). |

## Kontraste (WCAG 2.x, berechnet)

| Vordergrund | Hintergrund | Hell | Dunkel | Mindestwert |
|---|---|---|---|---|
| `text-primary` | `surface-page` | 16,40 : 1 | 16,40 : 1 | 4,5 : 1 (Text) |
| `text-primary` | `surface-raised` | 17,57 : 1 | 13,43 : 1 | 4,5 : 1 (Text) |
| `text-primary` | `surface-sunken` | 15,15 : 1 | 17,76 : 1 | 4,5 : 1 (Text) |
| `text-secondary` | `surface-page` | 5,72 : 1 | 6,59 : 1 | 4,5 : 1 (Text) |
| `text-secondary` | `surface-raised` | 6,13 : 1 | 5,40 : 1 | 4,5 : 1 (Text) |
| `text-secondary` | `surface-sunken` | 5,28 : 1 | 7,14 : 1 | 4,5 : 1 (Text) |
| `action-on-primary` | `action-primary` | 16,40 : 1 | 16,40 : 1 | 4,5 : 1 (Text) |
| `text-inverse` | `surface-inverse` | 16,40 : 1 | 16,40 : 1 | 4,5 : 1 (Text) |
| `action-inverse` | `surface-inverse` | 13,81 : 1 | 16,40 : 1 | 4,5 : 1 (Text) |
| `text-on-marker` | `marker` | 13,81 : 1 | 11,53 : 1 | 4,5 : 1 (Text) |
| `text-error` | `surface-page` | 5,32 : 1 | 7,77 : 1 | 4,5 : 1 (Text) |
| `text-error` | `surface-raised` | 5,70 : 1 | 6,36 : 1 | 4,5 : 1 (Text) |
| `text-error` | `surface-sunken` | 4,92 : 1 | 8,41 : 1 | 4,5 : 1 (Text) |
| `text-warning` | `surface-page` | 4,95 : 1 | 9,18 : 1 | 4,5 : 1 (Text) |
| `text-warning` | `surface-raised` | 5,31 : 1 | 7,52 : 1 | 4,5 : 1 (Text) |
| `feedback-on-error-surface` | `feedback-error-surface` | 8,47 : 1 | 12,03 : 1 | 4,5 : 1 (Text) |
| `feedback-on-warning-surface` | `feedback-warning-surface` | 7,70 : 1 | 11,49 : 1 | 4,5 : 1 (Text) |
| `line-control` | `surface-page` | 3,70 : 1 | 4,44 : 1 | 3 : 1 (Kontur) |
| `line-control` | `surface-raised` | 3,96 : 1 | 3,63 : 1 | 3 : 1 (Kontur) |
| `line-control` | `surface-sunken` | 3,41 : 1 | 4,81 : 1 | 3 : 1 (Kontur) |
| `state-draft` | `surface-page` | 3,70 : 1 | 6,59 : 1 | 3 : 1 (Kontur) |
| `state-draft` | `surface-raised` | 3,96 : 1 | 5,40 : 1 | 3 : 1 (Kontur) |
| `line-focus` | `surface-page` | 16,40 : 1 | 16,40 : 1 | 3 : 1 (Kontur) |
| `line-focus` | `surface-raised` | 17,57 : 1 | 13,43 : 1 | 3 : 1 (Kontur) |
| `marker` | `surface-page` | 1,19 : 1 | 11,53 : 1 | 3 : 1 (Kontur) – hell unter 3 : 1, deshalb trägt der Marker-Knopf eine Tintenkontur (`text-on-marker`) |
| `line-dot` | `surface-page` | 1,24 : 1 | 1,22 : 1 | – (rein dekorativ, absichtlich leise) |

## Abbildung auf Material 3 (Flutter `ColorScheme`)

Die App rendert weiter mit Material-Widgets. Damit kein Widget unbemerkt Platzhalter-Lila zeigt, bekommt jede der 46 Rollen einen Token. Komponenten-Themes setzen danach die eigentliche Gestalt.

| Material-Rolle | Hell | Dunkel |
|---|---|---|
| `primary` / `onPrimary` | `action-primary` / `action-on-primary` | wie hell |
| `primaryContainer` / `onPrimaryContainer` | `marker` / `text-on-marker` (Marker-Knopf) | wie hell |
| `primaryFixed`, `primaryFixedDim` / `onPrimaryFixed`, `onPrimaryFixedVariant` | `marker` / `text-on-marker` | wie hell |
| `secondary` / `onSecondary` | `text-secondary` / `text-inverse` | wie hell |
| `secondaryContainer` / `onSecondaryContainer` | `surface-sunken` / `text-primary` (Info) | `surface-raised` / `text-primary` |
| `secondaryFixed`, `secondaryFixedDim` / `onSecondaryFixed`, `onSecondaryFixedVariant` | `neutral-100`, `neutral-150` / `neutral-900`, `neutral-600` | wie hell |
| `tertiary` / `onTertiary` | `text-warning` / `text-inverse` | `text-warning` / `neutral-900` |
| `tertiaryContainer` / `onTertiaryContainer` | `feedback-warning-surface` / `feedback-on-warning-surface` | wie hell |
| `tertiaryFixed`, `tertiaryFixedDim` / `onTertiaryFixed`, `onTertiaryFixedVariant` | `orange-100`, `orange-300` / `orange-800`, `orange-700` | wie hell |
| `error` / `onError` | `text-error` / `text-inverse` | `text-error` / `neutral-900` |
| `errorContainer` / `onErrorContainer` | `feedback-error-surface` / `feedback-on-error-surface` | wie hell |
| `surface`, `surfaceBright`, `surfaceDim` | `surface-page`, `neutral-0`, `surface-sunken` | `surface-page`, `surface-raised`, `surface-sunken` |
| `surfaceContainerLowest` … `surfaceContainerHigh` | `surface-raised` | `surface-raised` (Lowest: `surface-sunken`) |
| `surfaceContainerHighest` | `surface-sunken` | `surface-raised` |
| `onSurface` / `onSurfaceVariant` | `text-primary` / `text-secondary` | wie hell |
| `outline` / `outlineVariant` | `line-control` / `line-hairline` | wie hell |
| `inverseSurface` / `onInverseSurface` / `inversePrimary` | `surface-inverse` / `text-inverse` / `action-inverse` | wie hell |
| `shadow`, `scrim` | `scrim` | wie hell |
| `surfaceTint` | `surface-page` (keine Tönung durch Höhe) | wie hell |

Mit dieser Zuordnung erfüllen alle 45 Paare des bestehenden Tests DS-05 die 4,5 : 1 in beiden Modi (nachgerechnet: kleinster Wert 4,92 : 1 hell, 5,40 : 1 dunkel). DS-05 wird trotzdem auf die semantischen Paare oben umgestellt.

## Richtig und falsch

| Farbe | Richtig | Falsch |
|---|---|---|
| Marker | Hinter „390 g“ als neuer Wert im Vergleich; Fläche der Master-Marke; Marker-Knopf mit Tintenkontur; „Rückgängig“ in der Snackbar | Gelbe Schrift; gelber Warnhinweis; gelbe Karte oder Kopfzeile; mehrere gelbe Flächen im Ruhezustand |
| Tinte | Text, Primärbutton, 3-px-Abschnittslinie, durchgezogener Rahmen einer eingefrorenen Fassung | Tinte als Ersatz für Fehlerrot; Tinte für deaktivierte Elemente |
| Graphit | Untertitel, Einheiten, „—“, Entwurfslinie | Schritttexte oder Zutaten in Graphit; Graphit als einziger Hinweis auf einen Fehler |
| Rot | Fehlertext mit Symbol `error`, Fehlerfläche | „Entfernt“ im Vergleich; Löschen-Button; Nährwert „zu hoch“ |
| Orange | Warnung mit Symbol `warning` („Nicht berechenbar“) | Orange als Akzent oder Markenfarbe |

## Eine Farbe ändern – kontrolliert

Beispiel: Der Marker soll etwas wärmer werden.

1. In Figma nur das Primitiv `marker/400` (und für dunkel `marker/500`) ändern. Die semantischen Variablen `color/marker`, `color/state-master`, `color/action-inverse` folgen als Alias, ebenso jede Komponente, die sie bindet.
2. Kontrastbericht in Figma prüfen (Text auf Marker ≥ 4,5 : 1, Abgrenzung zu `feedback-warning-surface`).
3. Variablen als DTCG-JSON exportieren, als Pull Request in `packages/unsalted_design/tokens/` einchecken.
4. Der Generator schreibt die Dart-Tokens; DS-04 (Vollständigkeit), DS-05 (Kontrast) und die Golden-Tests im Katalog zeigen jede betroffene Komponente als Bilddifferenz.
5. Review, Freigabe, Tag `design-vX.Y.Z`. Kein Bildschirm wird angefasst.
