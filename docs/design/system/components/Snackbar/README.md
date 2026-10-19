# Snackbar

Kurze Meldungen auf inverser Fläche mit „Rückgängig“ in Marker und sichtbarer Restzeit; Rückfragen als Dialog.

**Figma** `Feedback/Snackbar` mit `action`, `timer`; `Feedback/Dialog`. **Dart** `AppMessenger`, `showAppMessage`, `AppDialog`, `showAppConfirmDialog`, `showAppChoiceDialog`.

- Snackbar: höchstens `size-dialog` breit, `surface-inverse`, Text `text-inverse` in `body`, Innenabstand `space-l` links und `space-xs` sonst, Abstand Text–Aktion `space-m`, `radius-s`, `shadow-overlay`; Aktion in `body-strong`/`action-inverse` mit `space-m` seitlich und Tippziel `size-target`.
- Restzeit (Vorschlag): Linie `stroke-rule` in `action-inverse` am unteren Rand, die über 5 s abläuft. Bei „Bewegung reduzieren“ statisch.
- Dialog: Breite `size-dialog`, `surface-raised`, Haarlinie, `radius-m`, `shadow-overlay`, Innenabstand `space-xl`, Titel `title-page` mit `space-s` darunter, Text `body`, Aktionen `space-xl` darunter rechts mit `space-s` Abstand: tertiär „Abbrechen“, primär das Verb.
- Scrim `scrim` mit `opacity-scrim`.
