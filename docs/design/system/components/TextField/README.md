# TextField

Eingabefeld mit Beschriftung darüber, weißer Fläche und feiner Kontur; Zahlen rechtsbündig mit Einheit im Feld.

**Figma** `Input/Text Field`, `Input/Search`, `Input/Select` mit `state` = `default` · `focus` · `error` · `disabled`, `helper`, `unit`. **Dart** `AppTextField`, `AppSearchField`, `AppSelect<T>`.

- Beschriftung `space-xs` über dem Feld in `label-small`/`text-secondary` (keine schwebende Beschriftung: deutsche Begriffe sind lang).
- Feld: Mindesthöhe `size-control`, `surface-raised`, Kontur `stroke-hairline` in `line-control`, `radius-s`, seitlicher Innenabstand `space-m`, Symbol `size-icon-small` mit `space-s` Abstand, Text `body`.
- Fokus: Kontur `stroke-focus` in `line-focus`. Fehler: Kontur `stroke-focus` in `text-error`, darunter Symbol `error` (`size-icon-xs`, Abstand `space-xs`) und Text in `caption`/`text-error`. Deaktiviert: `surface-sunken`, `line-hairline`, `text-disabled`.
- Zahlenfelder: `data`, rechtsbündig, Einheit im Feld in `text-secondary`; Komma und Punkt werden angenommen, angezeigt wird das Komma.
- Platzhalter in `text-secondary` (6,1 : 1). Hilfe in `caption`.
