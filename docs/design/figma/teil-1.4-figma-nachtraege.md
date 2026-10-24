# Teil 1.4 – Figma-Nachträge (Stand 21.10.2026)

Bibliothek `5er28Cr7EMMcPzvusWjNyR` · App `5eFqwnCRld6Ibu131541i8`. Werte nur aus Variablen; neu abgeleitete Werte sind markiert (**neu**).

## Bibliothek – neue und geänderte Komponenten

| Name | Knoten | Code |
|---|---|---|
| `Data/Figure Row` (vorher Core/Nutrition Header, Eigenschaft showFigure3) | 142:57 | `AppFigureRow` |
| `Data/Figure` (vorher Core/Nutrition Field) | 142:56 | `AppFigure` |
| `Core/Nutrition Header` (neu: Data/Figure Row + Hinweis, showNotice) | 272:297 | `NutritionHeader` |
| `Feedback/Tooltip` | 273:374 | `AppIconButton(tooltip:)`, TooltipThemeData |
| `Navigation/Menu Item` jetzt Set `state=default|disabled` | 270:284 | `AppMenuEntry(enabled:)` |
| `Input/Text Selection` (`platform=android|ios`) | 276:297 | TextSelectionThemeData |
| `Brand/Logo` | 275:18 | – (noch nicht im Code) |
| `Brand/Symbol` (`style=color|mono`) | 275:34 | – (native Assets) |
| Geändert: `Input/Text Field` (showSuffix + Suffix, Tag entfernt, Kontur nicht im Layout) | 118:30 | `AppTextField(suffix:)` |
| Geändert: `List/Item` (showLeading + leading; Umbruch bei großer Schrift) | 127:29 | `AppListItem(leading:)` |
| Geändert: `Feedback/Notice`, `Feedback/Snackbar` (Aktion bei großer Schrift darunter) | 134:69, 136:50 | `ReflowRow`, Snackbar |
| Geändert: `Core/Version Target` (48 × 48) | 142:18 | VersionMark mit onTap |
| Geändert: `Core/Amount Calculator` („kcal“ ohne Einheit), `Data/Key Value Header` (erste Spalte leer) | 179:392, 140:116 | – |

Variablen (**neu**): `color/selection` (hell marker-400, dunkel marker-500, immer mit `opacity/selection` = 40 %),
`color/selection-handle` (hell neutral-900, dunkel neutral-50) – Griffe und Cursor. Seite Grundlagen: Muster „Textauswahl“ 276:304.

Seite **Marke**: App-Symbol Master 275:35 · iOS hell 275:39 · dunkel 275:43 · getönt 275:47 · Android Vordergrund 275:50 ·
Hintergrund 275:54 · einfarbig 275:55 · Schutzzone 275:58 · Startbild hell 275:75 · dunkel 275:79 · Startbild-Symbole 275:83/87 ·
Android 12 275:91/95.

## App – neue Rahmen und lokale Bausteine

| Rahmen | hell | dunkel |
|---|---|---|
| 00 Startbild / Start (Prototyp-Start, nach 0,8 s → 01) | 230:4748 | 230:4752 |
| 03 Rezept bearbeiten / Zeilenmenü (Menü „Nach oben“ ausgegraut, „Nach unten“, „Entfernen“) | 228:4322 | 228:17214 |
| 03 Rezept bearbeiten / Schritte (gescrollt, Tooltip „Aktionen für Schritt“) | 228:4341 | 228:17224 |
| 03 Rezept bearbeiten / Zeilen (gescrollt) / type 200 | 230:21227 | – |
| 03 Rezept bearbeiten / Eingefroren (neu aufgebaut) | 42:2010 | 217:18576 |
| 09 Lebensmittel-Liste / Keine Treffer | 218:3919 | 218:3980 |
| 01+04 Rezepte / Ohne Auswahl · Tablet hoch / quer | 219:4396 / 219:5018 | – |
| 09+10 Lebensmittel / Ohne Auswahl · Tablet hoch / quer | 219:4706 / 219:5336 | – |

Lokale Bausteine (Seite Inhalte): `_Zeile/Zutat bearbeiten` 7:712 (umgebaut, showUnderline), `_Zeile/Schritt bearbeiten` 227:4142,
`_Inhalt/Editor · Schritte` 227:4190, `_Inhalt/Eingefroren · V3` 217:3883, `_Inhalt/Versionen · Liste` 229:4626,
`_Aktionen/Version · Entwurf | Master | eingefroren` 229:4580 / 229:4595 / 229:4609.

Entfernt: „07 Versionen / Menü“ (hell und dunkel) – der Code zeigt die Aktionen direkt in der Zeile.

## Für den Code (Figma geht hier voran)

1. **Zutatenzeile:** Beschriftung auch für „Einheit“; Abstand zwischen Zeile 1 und Zeile 2 sowie beim Umbruch `space-m` statt `space-xs`
   (Beschriftung zu Feld `space-xs`, Feld zur nächsten Beschriftung `space-m`). Menüknopf `AppIcons.more`, Tooltip „Aktionen für Zutat“,
   `AppOverflowMenu` mit „Nach oben“ (erste Zeile `enabled: false`), „Nach unten“ (letzte Zeile `enabled: false`), „Entfernen“.
2. **Gestrichelte Unterstreichung:** `space-xxs` unter dem Feld zeichnen – auf der Feldkante ist sie hell unsichtbar
   (`state-draft` = `line-control` = neutral-500).
3. **Schrittzeile:** gleicher Aufbau wie die Zutatenzeile – Griff, Nummer und Menü fluchten unten mit dem Anweisungsfeld
   (je `space-m` darunter), darunter eingerückt der Timer; Tooltip „Aktionen für Schritt“, Menü wie oben.
4. **Bildschirm 7 bei 200 %:** Aktionen unter Titel und Datum (Umbruch wie `ReflowRow`), damit Wörter nicht getrennt werden.
5. **Textauswahl:** `TextSelectionThemeData(selectionColor: marker × 0,40, selectionHandleColor und cursorColor: selection-handle)`;
   für iOS zusätzlich `CupertinoThemeData.primaryColor`.
6. **„Keine Treffer.“ Lebensmittel:** `AppEmptyState(icon: AppIcons.emptyPlate, message: 'Keine Treffer.')` ohne Aktion.
7. **Liste/Detail ohne Auswahl:** Detailbereich leer mit Punktraster (wie in `AppSlot`, `DotPatternPainter`), ohne Text.
8. **App-Symbol und Startbild:** Dateien und `pubspec.yaml`-Vorschlag im ZIP `unsalted-app-symbol-startbild.zip` (LIESMICH.md).
