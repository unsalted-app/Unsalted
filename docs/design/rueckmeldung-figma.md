# Rückmeldung an Figma — Stand nach Teil 1.3, nachgeführt in Teil 1.4

Teil 1.3 hat das Design-System aus der Figma-Übergabe in den Code übernommen
(`docs/design/plan-1.3.md`, Entscheidungen in `docs/decisions.md`, „Teil
1.3“). An den folgenden Stellen weicht der Code **bewusst** von Figma ab. Damit
Figma und Code wieder übereinstimmen, sollte Figma diese Punkte nachziehen
(Abschnitt A). Abschnitt B nennt der Vollständigkeit halber, was Figma zeigt,
der Code aber noch nicht umsetzt — dort ist in Figma nichts zu tun.

Figma-Dateien: Bibliothek `5er28Cr7EMMcPzvusWjNyR`, App `5eFqwnCRld6Ibu131541i8`
(IDs in `docs/design/figma/figma-ids.json`).

Teil 1.4 (M00c, 2026-10-24): Abschnitt A gegen die Figma-Nachträge
(`docs/design/figma/teil-1.4-figma-nachtraege.md`) und die Dateien selbst
geprüft (nur gelesen); was Figma inzwischen nachgezogen hat, steht unter C.

## A. Bewusste Abweichungen — Figma nachziehen

### A1 Texte bleiben nach Kapitel 22

Die Spezifikation legt die Texte der Bildschirme fest; Teil 1.3 ändert nur das
Aussehen. Figma verwendet an diesen Stellen andere Wörter.

| Ort | Figma | Code (Kapitel 22) | Commit |
|---|---|---|---|
| Versionsvergleich, Hinzufügen/Entfernen | „neu“ + markiert, „entfernt“ + gestrichen | übernommen; vorgelesen wird der Text aus 28.4.5 („Salz hinzugefügt (5 g)“) | D14 |

### A2 Symbole

| Ort | Figma | Code | Commit |
|---|---|---|---|
| `Icon/delete` und `Icon/delete-outline` | zwei Namen, gleiche Vektoren | beide Namen bleiben (Bericht D06) | D06 |

### A3 Komponenten

| Thema | Figma | Code | Commit |
|---|---|---|---|
| Auswahldialog (Lebensmittel verknüpfen) | Breite `size-dialog` | feste Inhaltsgröße `size-dialog` × `size-dialog` (es gibt kein Höhen-Token) | D09 |
| Meldung, Restzeit | Restzeitlinie läuft in 5 s ab | läuft ab dem vollständigen Erscheinen in der Frist ab; bei „Bewegung reduzieren“ still in voller Breite | D09b |
| Hinweis mit Aktion, Tippziel | Aktion 32 hoch (`size-control-small`), oben bündig (Instanz `42:2034`) | Tippziel mindestens `size-target` (48) und ragt dafür in den oberen Innenabstand; die Beschriftung fluchtet wie in Figma mit der ersten Textzeile | Teil 1.4 M00b |

### A4 Tokens und Regeln, die der Code ergänzt hat

- `reflow-*` tragen Werte für 100 und 200 % (Format `{"100": …, "200": …}`);
  dazwischen linear, darüber der Wert bei 200 % (F5, D12a). Die drei Werte
  `reflow-rule-inline`, `reflow-rule-stacked`, `reflow-inset-inline` gelten
  je nach Anordnung (nebeneinander/untereinander), nicht stufenlos.
- Umbruch bei großer Schrift, wo Figma nur 200 % zeigt: Deklarationstabelle
  (Bezeichnung oben, Werte darunter), Aktionsleiste (untereinander), Zutatenzeile
  (Menge, Einheit, Notiz untereinander), Versionsvergleich (A über B),
  Mengenrechner (zweites Feld darunter). (Hinweis und Meldung mit Aktion
  darunter zeigt Figma seit Teil 1.4, `134:69`/`136:50`.)
- Die Kopfleiste und die Navigation folgen der Textgröße nicht (UEBERGABE 3);
  Ziele zeigen beim langen Drücken einen Tooltip (in Figma seit Teil 1.4
  `Feedback/Tooltip` `273:374`).
- Untereinander stehende Formularfelder haben einheitlich `space-m` (12)
  Abstand. Figma zeigt 16 (Bildschirm 10 Kennung und Maße, Bildschirm 11
  Auswahl), 32 (Bildschirm 2) und 12 (Bildschirm 3 Parameter); die
  Editor-Schrittzeile zeigt Figma seit Teil 1.4 (`227:4142`). Zutatenzeile (`xs`) und
  Mengenrechner bei großer Schrift (`space-s`) folgen Figma. (D16b, D18b–D18d)

## B. Figma zeigt mehr — der Code folgt später (in Figma nichts zu tun)

| Thema | Figma | Stand | Wann |
|---|---|---|---|
| Rezeptliste mit Fassungsmarke und Versionszahl je Rezept | `1:421` | braucht die Versionen je Rezept (Daten) | später (Plan 1.4, f) |
| Rezepttitel als `display` im Inhalt, leere Kopfleiste | `1:607` | Bildschirm-Änderung | später |
| Zutaten im Rezeptdetail als `Core/Ingredient Row` (Menge links in der Wertspalte) | `1:607` | Abschnitt außerhalb des Scopes; weiter Listeneinträge | später |
| Kopfzeile mit beiden Marken statt Spalten A/B im Versionsvergleich | `3:595` | Bildschirm-Änderung | später |
| Editor-Vorschau im gestrichelten Rahmen mit Kennzahlen (Gesamt, pro Portion, pro 100 g) | `7:895` | inhaltliche Erweiterung | später |
| Portionen und Backverlust nebeneinander | `7:895` | gestapelt mit Abstand `space-m` (D16b) | später |
| Auswahlfeld als umrandetes Feld (`Input/Select`) auch ohne Beschriftung | Spalte 2 der Nährwerttabelle | ohne Beschriftung weiter die Material-Auswahl mit Unterstrich; die Einheit der Zutatenzeile hat seit Teil 1.4 B01 die Beschriftung „Einheit“ (wie Figma) | später |
| Signaturmomente Einfrieren und Küren | Markenbuch | Zustand im Bildschirm | später |
| Titel von Bildschirm 3 über einer eingefrorenen Fassung | `42:2010`: „Pizzateig · V3“ | „Rezept bearbeiten“ — offene Textfrage: führt über einer schreibgeschützten Fassung in die Irre; braucht eine Änderung in Kapitel 22 (Entscheidung des Projektverantwortlichen). In Teil 1.4 bleibt der Text | später |

## C. Erledigt — Figma und Code stimmen wieder überein

| Thema | vorher (Teil 1.3) | jetzt | Erledigt mit |
|---|---|---|---|
| Nicht verknüpfte Zutat | Figma: Tag „nicht verknüpft“; Code: gestrichelte Unterstreichung (D16) | Figma zeigt die gestrichelte Unterstreichung (`showUnderline`); Code zeichnet sie `space-xxs` unter dem Feld | Figma N1, Teil 1.4 B01 |
| Beschriftungen der Zutatenzeile | Figma ohne Beschriftung | beide mit Beschriftung, auch „Einheit“; Abstand Beschriftung–Feld `space-xs`, Feld–nächste Beschriftung `space-m` | Figma N1, B01 |
| Entfernen in Zutaten- und Schrittzeile | Figma `Icon/close`, Code Papierkorb | beide Zeilenmenü `Icon/more` mit „Nach oben“, „Nach unten“, „Entfernen“ | Figma N1, B01 |
| Schrittzeile im Editor | in Figma nicht abgebildet | `_Zeile/Schritt bearbeiten` (`227:4142`): wie die Zutatenzeile, Timer eingerückt darunter | Figma N1, B01 |
| Master in der Fassungsleiste | Figma: Markerfläche in `Core/Version Switcher`; Code: Leiste kannte den Master nicht | beide mit Markerfläche, „Master“ in der Semantik | Teil 1.4 B02 |
| Suchtreffer in der Rezeptliste | Figma: Treffer im Titel markiert (`List/Item` `showMatch`); Code: ohne Markierung | Treffer mit Markerfläche hinter dem Text, Klartext unverändert | Teil 1.4 B04 |
| Rezeptdetail, Kennzahlenleiste | Figma: „pro Portion“; Code: „kcal/Portion“ (A1) | Figma `1:607`: „kcal/Portion“ (Spaltenkopf der Deklaration weiter „pro Portion“, wie im Code) | Figma (Teil 1.4, geprüft M00c) |
| Mengenrechner, zweites Feld | Figma: Beschriftung „Kalorien“, Einheit „kcal“ im Feld; Code: Beschriftung „kcal“ ohne Einheit (A1) | Figma `Core/Amount Calculator` (`179:392`): „kcal“ ohne Einheit | Figma (Nachtrag 1.4) |
| Deklarationstabelle, erste Kopfspalte | Figma: „Nährwerte“; Code: leer (A1) | Figma `Data/Key Value Header` (`140:116`): erste Spalte leer | Figma (Nachtrag 1.4) |
| Versionsvergleich, Metadaten | Figma: „n Änderungen“ neben der Überschrift; Code: keine (A1) | Figma `3:595` ohne Metadaten | Figma (Teil 1.4, geprüft M00c) |
| Bildschirm 7 Versionen | Figma: Titel „Version n“, Marke rechts, keine Aktionen; Code: Marke links, Zustand als Wort, Datum, „Master“ als Wort, Aktionen (A1) | Figma `20:1042` wie der Code, Aktionen direkt in der Zeile (`_Aktionen/Version · …` `229:4580`/`229:4595`/`229:4609`); „07 Versionen / Menü“ entfernt | Figma (Nachtrag 1.4) |
| Kennzahlenleiste | Figma: `Core/Nutrition Header`/`Field` in der Gruppe Core; Code: fachneutrale `AppFigureRow`/`AppFigure` (A3) | Figma `Data/Figure Row` (`142:57`), `Data/Figure` (`142:56`); `Core/Nutrition Header` (`272:297`) = Kennzahlenleiste + Hinweis | Figma (Nachtrag 1.4) |
| Fassungsleiste, Tippziel | Figma: `Core/Version Target` 48 × 35; Code: 48 × 48 (A3) | Figma 48 × 48 (`142:18`) | Figma (Nachtrag 1.4) |
| Aktion bei großer Schrift | Figma: Aktion von Hinweis und Meldung rechts neben dem Text; Code: darunter, rechtsbündig (A3, D13a) | Figma `Feedback/Notice`, `Feedback/Snackbar` (`134:69`, `136:50`): bei großer Schrift darunter | Figma (Nachtrag 1.4) |
| Unvollständiger Wert | Figma: „*“; Code: „*“ nach der Einheit (A3) | Figma `Value` (`134:179`): „3.500 kcal*“ | Figma (Teil 1.4, geprüft M00c) |
| Liste und Detail nebeneinander ab 840 | Figma: Tablet `147:9746`, quer `148:4381`; Code: nur Seitenleiste ab 600 (B) | Liste in 360, Detail mit Haarlinie, ohne Auswahl Punktraster (N3) | Teil 1.4 T01–T03 |
| Kasten der Marke | Figma: Kasten 52 × 24, Text mittig, links und rechts `space-s` + `stroke-frame` (`107:48`); Code: Kasten so hoch wie der Text (etwa 16), nur der Platz um ihn 24, Innenabstand `space-s` | Kasten selbst mindestens `size-mark`, Inhalt senkrecht mittig, `space-s` + `stroke-frame` (die belegte Höhe bleibt) | Teil 1.4 M00b |
| Kopfzeile und Innenabstand des Rahmens | Figma: Kopfzeile 24 hoch, Zustandswort mittig zur Marke, Innenabstand `space-m`/`space-l` + `stroke-frame` (`135:47`); Code: Zustandswort oben bündig, Innenabstand ohne Kontur | wie Figma, beide Zustände | Teil 1.4 M00b |
| Lage der Hinweis-Aktion | Figma: Aktion oben, Beschriftung auf Höhe der ersten Zeile; Code: Beschriftung mittig im 48 hohen Tippziel, also tiefer | Beschriftung auf Höhe der ersten Textzeile (siehe A3 zum Tippziel) | Teil 1.4 M00b |
| Eingefrorene Ansicht (`42:2010`, dunkel `217:18576`, Inhalt `217:3883`) | Figma: Hinweis „V3 ist eingefroren …“, kein Rahmen; Code: Text aus Kapitel 22, Zustandsrahmen mit Siegel (D16) | Figma neu gebaut nach dem Code: Hinweis mit Kapitel-22-Text und „Kopieren“, `space-l`, Zustandsrahmen mit Siegel und „Eingefroren“, Zutaten, eine Linie, Schritte; Code zeichnet seit M00a nur noch eine Linie (vorher zwei mit Abstand) | Figma, Teil 1.4 M00a |
