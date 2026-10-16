# Chip

Auswahl-Chips wählen zwischen wenigen Ansichten; Tags kennzeichnen Werte wie Timer oder Herkunft.

**Figma** `Chip/Choice` mit `selected`; `Chip/Info` als Tag mit `icon`. **Dart** `AppChoiceChip(label:, selected:, onSelected:)`, `AppChip(label:)`.

- Auswahl-Chip: Höhe `size-control-small` (Tippziel `size-target`), seitlicher Innenabstand `space-m`, Symbol zu Text `space-xs`, `radius-s`, Fläche `surface-raised`, Kontur `stroke-hairline` in `line-control`, Text `label-small`. Ausgewählt: `surface-inverse` mit `text-inverse` und Häkchen (`size-icon-xs`). Zwischen Chips `space-s`.
- Tag: Höhe `size-mark`, seitlicher Innenabstand `space-s`, Symbol `size-icon-xs` mit `space-xs` Abstand, `radius-xs`, keine Fläche, Kontur `stroke-hairline` in `line-control`, `label-small` mit `tnum`.
- Timer stehen als Tag unter dem Schritt (`timer` + „10:00“).
- Keine farbigen Chips, keine Pillen.
