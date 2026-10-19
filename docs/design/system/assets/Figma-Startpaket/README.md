# Figma-Startpaket

Alle Variablen dieses Systems zum Importieren in Figma – im Format der Design Tokens Community Group (DTCG), erzeugt aus `tokens.json`. Ändere die Dateien nicht von Hand; ändert sich `tokens.json`, wird das Paket neu erzeugt. Die ganze Anleitung steht im Abschnitt „Figma Schritt für Schritt“ (07).

## Import in dieser Reihenfolge

Für jede Zeile: in der Variablenansicht eine neue Sammlung anlegen, **exakt** wie in Spalte 2 benennen, die Datei(en) hineinziehen. Figma legt je Datei einen Modus an.

| Nr. | Sammlung | Datei(en) | Modi danach benennen | Variablen |
|---|---|---|---|---|
| 1 | `primitives` | `primitives.tokens.json` | — | 23 |
| 2 | `color` | `color.light.tokens.json` + `color.dark.tokens.json` (zusammen) | `light`, `dark` | 36 |
| 3 | `space` | `space.tokens.json` | — | 7 |
| 4 | `radius` | `radius.tokens.json` | — | 5 |
| 5 | `stroke` | `stroke.tokens.json` | — | 6 |
| 6 | `size` | `size.tokens.json` | — | 16 |
| 7 | `opacity` | `opacity.tokens.json` | — | 3 |
| 8 | `motion` | `motion.tokens.json` | — | 4 |
| 9 | `breakpoint` | `breakpoint.tokens.json` | — | 3 |
| 10 | `type` | `type.100.tokens.json` + `type.200.tokens.json` (zusammen) | `100`, `200` | 27 |

`primitives` muss zuerst importiert sein: Jede Farbrolle in `color` verweist über `com.figma.aliasData` auf ein Primitiv (z. B. `surface-page` → `neutral/50`). Prüfe nach dem Import, dass dort ein Verweis steht und kein fester Wert.

## Gut zu wissen

- `color` enthält neben den 28 Rollen die Gruppe `shadow/…`: die Einzelwerte von `shadow-overlay` (Versatz, Unschärfe, Farbe je Ebene) und vom Fokusring (`focus-gap`, `focus-ring`). Daraus baust du die Effektstile `shadow/overlay` und `shadow/focus`.
- `opacity` steht in Prozent (6, 12, 48), weil Figma die Ebenendeckkraft in Prozent zeigt. Im Code sind es 0.06, 0.12, 0.48.
- `type` enthält Familie, Schnitte und je Textstil Größe und Zeilenhöhe. Modus `200` verdoppelt Größen und Zeilenhöhen – nur zum Prüfen von 200 % Textgröße.
- `family/mono` ist „Roboto Mono“ nur als Platzhalter in Figma; im Code gilt die Monospace-Schrift des Systems.
- `motion` und `breakpoint` bindet Figma an nichts; sie stehen zum Nachschlagen dabei.
- `Punktraster.svg` ist das Punktraster der Leerstelle als ein einziger Vektor (Punkte 2 px, Abstand 24 px, erster Punkt 16 px von der Kante). Binde seine Füllung an `color/line-dot` – so folgt es dem dunklen Modus.
