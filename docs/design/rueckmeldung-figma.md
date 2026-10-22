# Rückmeldung an Figma — Stand nach Teil 1.3

Teil 1.3 hat das Design-System aus der Figma-Übergabe in den Code übernommen
(`docs/design/plan-1.3.md`, Entscheidungen in `docs/decisions.md`, „Teil
1.3“). An den folgenden Stellen weicht der Code **bewusst** von Figma ab. Damit
Figma und Code wieder übereinstimmen, sollte Figma diese Punkte nachziehen
(Abschnitt A). Abschnitt B nennt der Vollständigkeit halber, was Figma zeigt,
der Code aber noch nicht umsetzt — dort ist in Figma nichts zu tun.

Figma-Dateien: Bibliothek `5er28Cr7EMMcPzvusWjNyR`, App `5eFqwnCRld6Ibu131541i8`
(IDs in `docs/design/figma/figma-ids.json`).

## A. Bewusste Abweichungen — Figma nachziehen

### A1 Texte bleiben nach Kapitel 22

Die Spezifikation legt die Texte der Bildschirme fest; Teil 1.3 ändert nur das
Aussehen. Figma verwendet an diesen Stellen andere Wörter.

| Ort | Figma | Code (Kapitel 22) | Commit |
|---|---|---|---|
| Rezeptdetail, Kennzahlenleiste | „pro Portion“ | „kcal/Portion“ | D15 |
| Mengenrechner, zweites Feld | Beschriftung „Kalorien“, Einheit „kcal“ im Feld | Beschriftung „kcal“, keine Einheit im Feld (sonst stünde „kcal“ doppelt) | D15 |
| Rezept bearbeiten, eingefroren (`42:2010`) | „V3 ist eingefroren und kann nicht bearbeitet werden …“ | „Eingefroren — als neuen Entwurf kopieren?“ (Geviertstrich wie in Kapitel 22) | D16 |
| Versionsvergleich, Abschnitte (`3:595`) | Metadaten „n Änderungen“ neben der Überschrift | keine Metadaten (wäre ein neuer Text) | D14 |
| Versionsvergleich, Hinzufügen/Entfernen | „neu“ + markiert, „entfernt“ + gestrichen | übernommen; vorgelesen wird der Text aus 28.4.5 („Salz hinzugefügt (5 g)“) | D14 |
| Deklarationstabelle, erste Kopfspalte | „Nährwerte“ (bei 200 % „je“) | leer — die Tabelle bekommt nur die Köpfe der Wertspalten | D10 |
| Bildschirm 7 Versionen (`20:1042`) | Titel „Version n“, Datum, Marke rechts, keine Aktionen | Marke links („V{n}“), Zustand als Wort („Entwurf“/„Eingefroren“), Datum; „Master“ als Wort; Aktionen bleiben (28.4.4) | D13 |

### A2 Symbole

| Ort | Figma | Code | Commit |
|---|---|---|---|
| `Icon/delete` und `Icon/delete-outline` | zwei Namen, gleiche Vektoren | beide Namen bleiben (Bericht D06) | D06 |

### A3 Komponenten

| Thema | Figma | Code | Commit |
|---|---|---|---|
| Kennzahlenleiste | `Core/Nutrition Header` (`142:57`) und `Core/Nutrition Field` (`142:56`) in der Gruppe Core | fachneutrale Design-Komponente `AppFigureRow` mit `AppFigure` (Beschriftung + Wert); `NutritionHeader` baut daraus. Vorschlag: in Figma als Design-Komponente führen (z. B. `Data/Figure Row`, `Data/Figure`) | D15a |
| Zustandsrahmen in der eingefrorenen Ansicht | kein Rahmen, nur Hinweis und Abschnitte | Hinweis, darunter der Inhalt in `Frame` (fest) mit `Mark` (Siegel) und dem Wort „Eingefroren“ (Plan 28.10.3) | D16 |
| Auswahldialog (Lebensmittel verknüpfen) | Breite `size-dialog` | feste Inhaltsgröße `size-dialog` × `size-dialog` (es gibt kein Höhen-Token) | D09 |
| Fassungsleiste, Tippziel | `Core/Version Target` 48 × 35 | mindestens `size-target` × `size-target` (48 × 48) | D07 |
| Meldung, Restzeit | Restzeitlinie läuft in 5 s ab | läuft ab dem vollständigen Erscheinen in der Frist ab; bei „Bewegung reduzieren“ still in voller Breite; bei großer Schrift steht „Rückgängig“ unter dem Text | D09b |
| Hinweis mit Aktion | Aktion rechts neben dem Text | bei großer Schrift (Text schmaler als `reflow-label-min`) unter dem Text, rechtsbündig | D13a |
| Unvollständiger Wert | „*“ | „*“ nach der Einheit („2.868 kcal*“, Value-Karte) | D15 |

### A4 Tokens und Regeln, die der Code ergänzt hat

- `reflow-*` tragen Werte für 100 und 200 % (Format `{"100": …, "200": …}`);
  dazwischen linear, darüber der Wert bei 200 % (F5, D12a). Die drei Werte
  `reflow-rule-inline`, `reflow-rule-stacked`, `reflow-inset-inline` gelten
  je nach Anordnung (nebeneinander/untereinander), nicht stufenlos.
- Umbruch bei großer Schrift, wo Figma nur 200 % zeigt: Deklarationstabelle
  (Bezeichnung oben, Werte darunter), Aktionsleiste (untereinander), Zutatenzeile
  (Menge, Einheit, Notiz untereinander), Versionsvergleich (A über B),
  Mengenrechner (zweites Feld darunter), Hinweis und Meldung (Aktion darunter).
- Die Kopfleiste und die Navigation folgen der Textgröße nicht (UEBERGABE 3);
  Ziele zeigen beim langen Drücken einen Tooltip.
- Untereinander stehende Formularfelder haben einheitlich `space-m` (12)
  Abstand. Figma zeigt 16 (Bildschirm 10 Kennung und Maße, Bildschirm 11
  Auswahl), 32 (Bildschirm 2) und 12 (Bildschirm 3 Parameter); die
  Editor-Schrittzeile ist in Figma nicht abgebildet. Zutatenzeile (`xs`) und
  Mengenrechner bei großer Schrift (`space-s`) folgen Figma. (D16b, D18b–D18d)

## B. Figma zeigt mehr — der Code folgt später (in Figma nichts zu tun)

| Thema | Figma | Stand | Wann |
|---|---|---|---|
| Liste und Detail nebeneinander ab 840 | Tablet `147:9746`, quer `148:4381` | Seitenleiste ab 600 ist umgesetzt (D17), Liste/Detail nicht | Teil 1.4 (F4) |
| Rezeptliste mit Fassungsmarke und Versionszahl je Rezept | `1:421` | braucht die Versionen je Rezept (Daten) | später (Plan 1.4, f) |
| Rezepttitel als `display` im Inhalt, leere Kopfleiste | `1:607` | Bildschirm-Änderung | später |
| Zutaten im Rezeptdetail als `Core/Ingredient Row` (Menge links in der Wertspalte) | `1:607` | Abschnitt außerhalb des Scopes; weiter Listeneinträge | später |
| Kopfzeile mit beiden Marken statt Spalten A/B im Versionsvergleich | `3:595` | Bildschirm-Änderung | später |
| Editor-Vorschau im gestrichelten Rahmen mit Kennzahlen (Gesamt, pro Portion, pro 100 g) | `7:895` | inhaltliche Erweiterung | später |
| Portionen und Backverlust nebeneinander | `7:895` | gestapelt mit Abstand `space-m` (D16b) | später |
| Auswahlfeld als umrandetes Feld (`Input/Select`) auch ohne Beschriftung | Spalte 2 der Nährwerttabelle | ohne Beschriftung weiter die Material-Auswahl mit Unterstrich; die Einheit der Zutatenzeile hat seit Teil 1.4 B01 die Beschriftung „Einheit“ (wie Figma) | später |
| Aktion im Hinweis in `size-control-small` | `Feedback/Notice` | Tertiär-Knopf in `size-control` | später |
| Signaturmomente Einfrieren und Küren | Markenbuch | Zustand im Bildschirm | später |

## C. Erledigt — Figma und Code stimmen wieder überein

| Thema | vorher (Teil 1.3) | jetzt | Erledigt mit |
|---|---|---|---|
| Nicht verknüpfte Zutat | Figma: Tag „nicht verknüpft“; Code: gestrichelte Unterstreichung (D16) | Figma zeigt die gestrichelte Unterstreichung (`showUnderline`); Code zeichnet sie `space-xxs` unter dem Feld | Figma N1, Teil 1.4 B01 |
| Beschriftungen der Zutatenzeile | Figma ohne Beschriftung | beide mit Beschriftung, auch „Einheit“; Abstand Beschriftung–Feld `space-xs`, Feld–nächste Beschriftung `space-m` | Figma N1, B01 |
| Entfernen in Zutaten- und Schrittzeile | Figma `Icon/close`, Code Papierkorb | beide Zeilenmenü `Icon/more` mit „Nach oben“, „Nach unten“, „Entfernen“ | Figma N1, B01 |
| Schrittzeile im Editor | in Figma nicht abgebildet | `_Zeile/Schritt bearbeiten` (`227:4142`): wie die Zutatenzeile, Timer eingerückt darunter | Figma N1, B01 |
| Master in der Fassungsleiste | Figma: Markerfläche in `Core/Version Switcher`; Code: Leiste kannte den Master nicht | beide mit Markerfläche, „Master“ in der Semantik | Teil 1.4 B02 |
| Suchtreffer in der Rezeptliste | Figma: Treffer im Titel markiert (`List/Item` `showMatch`); Code: ohne Markierung | Treffer mit Markerfläche hinter dem Text, Klartext unverändert | Teil 1.4 B04 |
