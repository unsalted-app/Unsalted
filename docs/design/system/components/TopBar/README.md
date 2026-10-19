# TopBar

Kopfleiste mit linksbündigem Titel, Aktionen rechts und optionalem Suchfeld darunter; eine Haarlinie statt Schatten.

**Figma** `Navigation/Top Bar` mit `back`, `actions`, `search`. **Dart** `AppTopBar(title:, actions:, bottom:)`.

- Mindesthöhe `size-top-bar`, seitlicher Innenabstand `space-xs`, `surface-page`, Titel `title-page` linksbündig mit `space-m` seitlich, Aktionen als Symbol-Schaltflächen (`size-target`) mit `space-xxs` Abstand, Haarlinie unten (`stroke-hairline`, `line-hairline`).
- Suchfeld als unterer Bereich: Innenabstand `space-s` oben, `space-l` seitlich, `space-m` unten; darunter Haarlinie.
- Auf der Detailseite bleibt der Titel in der Kopfleiste leer; der Rezepttitel steht als `display` im Inhalt.
