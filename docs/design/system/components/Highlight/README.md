# Highlight

Der Marker hinterlegt, was neu, geändert oder gefunden ist – wie ein Textmarker auf Papier; Altes wird in Graphit gestrichen.

**Figma** `Highlight` (Textspanne), `Change` mit `before`, `after`. **Dart (Vorschlag)** `AppHighlight(text)`, `AppChangeText(subject:, before:, after:)`.

- Hinterlegung `marker`, Text `text-on-marker`, Ecke `radius-xs`, seitlich `space-xxs`; über Zeilenumbrüche fortgesetzt.
- Alt: `text-secondary`, durchgestrichen mit `stroke-frame`. Dazwischen das Symbol `arrow` (`size-icon-xs`) mit `space-s` Abstand – die Schrift hat keinen Pfeil.
- Hinzugefügt: nur Marker. Entfernt: nur Strich. Verknüpfung geändert: Klartext („Butter: anderes Lebensmittel verknüpft“).
- Kein Rot und Grün im Vergleich: ruhig und für Farbfehlsichtige lesbar. Die Bedeutung trägt die Struktur (alt → neu), nicht die Farbe.
- Suchtreffer hinterlegen nur den gefundenen Teil des Titels.
