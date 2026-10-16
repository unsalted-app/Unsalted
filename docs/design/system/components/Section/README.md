# Section

Abschnitt mit 3-px-Tintenlinie, fetter Überschrift und Inhalt – die Deklarationslogik der Lese- und Formularseiten.

**Figma** `Layout/Section` mit `rule` = `strong` · `hairline` · `none`, `meta`. **Dart** `AppSection(title:, divider:, children:)` (heute Trennlinie mit `space-xxl` + fette Überschrift).

- `space-xxl` vor dem Abschnitt, `stroke-rule` in `line-strong`, `space-m`, `heading`, `space-s`, Inhalt.
- Rechts neben der Überschrift optional Metadaten in `caption`/`text-secondary` („für 4 Portionen“, „4 Änderungen“).
- Zutaten: Menge in fester, rechtsbündiger Spalte `size-value-column` (`data`), Abstand `space-m`, Name in `body-strong`, Notiz darunter in `body-small`; Zeile mit `space-xs` oben und unten, Haarlinie darunter.
- Schritte: Nummer in der Spalte `size-index-column` (`data-strong`), Abstand `space-s`, Anweisung in `body`, Timer als Tag `space-s` darunter; Zeile mit `space-s` oben und unten, Haarlinie darunter.
