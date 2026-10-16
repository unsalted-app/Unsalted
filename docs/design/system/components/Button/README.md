# Button

Drei Gewichte – Tintenfläche, Tintenkontur, nur Text – und höchstens eine Primäraktion je Bereich.

**Figma** `Button` mit `variant` = `primary` · `secondary` · `tertiary`, `icon` (Instanz oder keins), `state` = `default` · `hover` · `pressed` · `focus` · `disabled` · `loading`; `Button/Icon`. **Dart** `AppButton.primary/.secondary/.tertiary(label:, icon:, onPressed:)`, `AppIconButton(icon:, tooltip:, onPressed:)` (Tooltip Pflicht).

- Mindesthöhe `size-control`, seitlicher Innenabstand `space-l` (tertiär `space-m`), oben und unten keiner – die Mindesthöhe zentriert die Zeile; `radius-s`, Beschriftung `body-strong`, Symbol `size-icon-small` mit `space-s` Abstand.
- Primär: `action-primary` / `action-on-primary`. Sekundär: keine Füllung, Kontur `stroke-frame` in `line-strong` – der Grund scheint durch (Papier, im Dialog Weiß); in Figma bleibt die Füllung leer. Tertiär: nur Text in `text-primary`, ebenfalls ohne Füllung.
- Im Editor ist „Einfrieren“ sekundär und „Speichern“ primär. Gelb ist nur der Marker-Knopf (`Fab`).
- Hover/Fokus: Überlagerung `opacity-hover`; Drücken `opacity-pressed`; Fokusring `shadow-focus`; deaktiviert `surface-sunken` mit `text-disabled`; lädt: Ladekreis `size-icon-small` vor der Beschriftung, Breite bleibt.
- Verben auf die Beschriftung, einzeilig. Destruktive Bestätigung im Dialog ist primär, aber nie rot.
- Symbol-Schaltflächen: `size-target` × `size-target`, Symbol `size-icon`, `text-primary` (sekundär `text-secondary`).
