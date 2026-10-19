# Mark

Die Fassungsmarke zeigt Nummer und Zustand einer Fassung: gestrichelt heißt Entwurf, Tintenkontur heißt eingefroren, Markerfläche heißt Master.

**Figma** `Mark` mit `state` = `provisional` · `fixed` · `highlighted`, `label` (Text), `seal` (Boolean). **Dart (Vorschlag)** `AppMark(label: 'V3', state: AppMarkState.fixed, seal: false)` im Design-Paket; in Core baut `VersionMark(version:, isMaster:)` daraus die fachliche Marke.

Der Aufrufer liefert den Text („V3“, optional „V3 · mit Vorteig“), den Zustand und die Semantik für Screenreader („Version 3, eingefroren, Master“).

- Höhe `size-mark`, seitlicher Innenabstand `space-s`, Symbol zu Text `space-xs`, `label-small` mit `tnum`, Ecke `radius-xs`, Linie `stroke-frame`.
- Entwurf: Strichlinie `stroke-dash`/`stroke-gap` in `state-draft`, Text `text-secondary`. Eingefroren: `state-frozen`, Text `text-primary`; mit `seal` das Symbol `lock` (`size-icon-xs`) dort, wo nur der Zustand zählt (Editor, Export). Master: Fläche `state-master`, Text und Kontur `text-on-marker`.
- Auswahl zeigt die umgebende Fassungsleiste mit einem 3-px-Balken (`stroke-rule`, `line-strong`) – nie über die Füllung der Marke.
- Nicht als Pille, nicht farbig außer Marker, nicht als Schaltfläche ohne Tippziel `size-target`.
