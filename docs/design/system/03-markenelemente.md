# Markenelemente

Sieben wiederkehrende Elemente machen unsalted ohne Logo erkennbar. Jedes hat eine Funktion; keines ist Dekoration.

| Element | Was es zeigt | Gestalt | Wo |
|---|---|---|---|
| **Fassungsmarke** | Nummer und Zustand einer Fassung | „V3“ in `label-small`, 24 hoch, `radius-xs`; gestrichelt (Entwurf), Tintenkontur (eingefroren), Markerfläche (Master) | Rezeptliste, Fassungsleiste, Versionen, Vergleich, Editor, Export, später Experimente, Veröffentlichen, Assistent |
| **Strich- und Tintenlinie** | vorläufig gegenüber fest | 1,5 px, Strich 4 / Lücke 3 in `state-draft` – oder durchgezogen in `state-frozen` | Zustandsrahmen, Leerstellen, nicht verknüpfte Zutaten (gestrichelte Unterstreichung) |
| **Marker** | neu, geändert, gefunden, gekürt | `marker`-Hinterlegung mit `radius-xs`, Text `text-on-marker` | Vergleich, Suche, Master, Marker-Knopf, „Rückgängig“ |
| **Abschnittslinie** | Beginn eines Abschnitts | 3 px `line-strong` über einer `heading` | Detail, Editor, Formulare, Vergleich |
| **Deklaration** | Daten ehrlich und vergleichbar | Tabellen mit Tintenlinie unter dem Kopf, Haarlinien, `tnum` rechtsbündig, „—“ und „*“ | Nährwerte, Mengen, Verpackungsformular, Kennzahlen |
| **Marker-Knopf** | die eine Hauptaktion | 56 × 56, `marker`, Tintenkontur, `radius-s`, Symbol `add` oder `check` | Rezeptliste, Lebensmittel, Erstellen |
| **Punktraster** | hier ist noch Platz | Punkte `size-dot` (2 px) in `line-dot`, Abstand `space-xl` (24 px), an der Inhaltskante ausgerichtet; auf warmem Papier (#F9F7F1) | nur auf leeren Flächen: Leerstellen (leere Listen, leere Fotoplätze), Startbild, Cover, Store-Bilder – nie hinter Inhalt |

## Signaturmoment: Einfrieren

Beim Einfrieren schließt sich die Strichlinie des Arbeitsstands in `duration-long` (400 ms, `easing-standard`) zur Tintenlinie; die Fassungsmarke wechselt von gestrichelt zu durchgezogen, das Siegel (`lock`) erscheint; die Meldung lautet „V4 eingefroren.“ Auf dem Handy begleitet ein leichter haptischer Impuls. Bei „Bewegung reduzieren“ wechselt der Zustand sofort.

## Signaturmoment: Master küren

Die Markerfläche wird in `duration-medium` (250 ms) von links nach rechts in die Marke „gestrichen“, wie mit einem Textmarker. Bei „Bewegung reduzieren“ sofort.

## Wortmarke und App-Symbol

Im Repository gibt es kein Logo und keine Wortmarke; die App-Symbole sind das Flutter-Standardlogo, der Startbildschirm ist leer. Bis zur Gestaltung wird der Name in `display`-Schnitt (700) klein gesetzt: „unsalted“. Für das App-Symbol gelten diese Vorgaben, der Entwurf entsteht in Figma: Papier oder Tinte als Grund, höchstens ein Markerelement, eine geometrische Form aus der Systemsprache (Marke, Linie), keine Lebensmittel-Illustration, lesbar bei 29 × 29 pt.

## Was nicht zur Marke gehört

Erdtöne und Terrakotta, kräftige Creme- und Pergamenttöne (das Papier ist nur ein Hauch warm), Punktraster als Tapete hinter Inhalten, Goldakzente, Verläufe, Glas- und Neoneffekte, Pillenformen, große Radien, Food-Fotos als Dekoration, Illustrationen und Maskottchen, Ampelfarben für Nährwerte, sportliche Kennzahlenringe, Ausrufezeichen.
