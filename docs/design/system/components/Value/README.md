# Value

Ein Messwert ist Zahl plus Einheit mit ehrlichem Zustand: bekannt, unbekannt („—“) oder unvollständig („*“ mit Fußnote).

**Figma** `Value` mit `certainty` = `known` · `unknown` · `incomplete`, `size` = `data` · `strong` · `display`. **Dart (Vorschlag)** `AppValue(value: '1,80', unit: 'g', certainty: AppCertainty.known)`; Zahl und Rundung liefert der Aufrufer (in Core nur über `NutritionFormatter`).

- Zahl in `data`/`data-strong`/`display` mit `tnum`, Einheit nach U+00A0 in `text-secondary`, Schnitt 400; bei `display` steht die Einheit in `body-strong`.
- Unbekannt: „—“ in `text-secondary`, nie „0“. Unvollständig: Wert, dann „*“ fett, Fußnote in `caption` unter der Tabelle.
- In Spalten rechtsbündig; Kommata stehen bei gleicher Stellenzahl untereinander.
- Keine Bewertung durch Farbe.
