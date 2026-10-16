# Frame

Der Zustandsrahmen fasst einen Arbeitsstand ein: gestrichelt, solange er vorläufig ist, durchgezogen, sobald er eingefroren ist; die Leerstelle ist sein leerer Zwilling.

**Figma** `Frame` mit `state` = `provisional` · `fixed`; `Slot` für Leerstellen. **Dart (Vorschlag)** `AppFrame(state:, child:)`, `AppSlot(icon:, message:, action:)`.

- Rahmen: `stroke-frame`, `radius-s`, Innenabstand `space-m`/`space-l`. Vorläufig: Strichlinie `stroke-dash`/`stroke-gap` in `state-draft`. Fest: durchgezogen in `state-frozen`.
- Kopfzeile: Fassungsmarke, dann mit `space-s` Abstand der Zustand als Wort in `label-small`/`text-secondary` („Entwurf · nicht eingefroren“, „Eingefroren am 09.10.2026“).
- Leerstelle: gestrichelt, innen das Punktraster (`line-dot`, Punkt `size-dot`, Abstand `space-xl`, ab der Innenkante `space-l`), Symbol, ein Satz in `body`, eine Aktion. Für leere Listen, fehlende Fotos (Teil 4), noch nicht verknüpfte Daten. Das Punktraster sagt „hier ist Platz“ – es erscheint nur in leeren Flächen, nie hinter Inhalt.
- Strichlinien gibt es nur hier, in der Entwurfsmarke und als Unterstreichung nicht verknüpfter Zutaten. Nie als Dekor, nie für deaktivierte Elemente.
- Flutter zeichnet gestrichelte Linien nicht von selbst: `AppFrame` braucht einen eigenen `CustomPainter` (Pfad mit Strichmuster aus `stroke-dash`/`stroke-gap`); kein Zusatzpaket, das Design-Paket hängt nur von Flutter ab.
