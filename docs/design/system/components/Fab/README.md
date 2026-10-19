# Fab

Der Marker-Knopf ist die eine Hauptaktion einer Seite – gelb, kantig, mit Tintenkontur.

**Figma** `Button/FAB` mit `icon`, `state` = `default` · `focus` · `loading`. **Dart** `AppFab(icon:, tooltip:, onPressed:, loading:)`.

- `size-fab` × `size-fab`, `radius-s`, Fläche `marker`, Kontur `stroke-frame` in `text-on-marker`, Symbol `size-icon` in `text-on-marker`, flach (kein Schatten). Lage: `space-l` vom rechten Rand, `space-l` über der Navigationsleiste (`size-nav-bar`).
- Die Tintenkontur ist nötig: Marker auf `surface-page` erreicht hell nur 1,2 : 1.
- Für die Hauptaktion einer Seite: „Neues …“ in Listen, „Speichern“ in Formularen ohne Fußleiste. Höchstens ein Marker-Knopf je Seite.
- Laden: Ladekreis in `text-on-marker`, Knopf deaktiviert. Tooltip ist Pflicht und zugleich Screenreader-Text.
