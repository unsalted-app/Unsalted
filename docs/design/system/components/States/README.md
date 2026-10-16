# States

Leer-, Fehler- und Ladezustand einer Seite: Leerstelle mit Satz und Aktion, Klartext mit „Erneut versuchen“, Ladekreis.

**Figma** `Feedback/Empty State`, `Feedback/Error State`, `Feedback/Loading`, `Feedback/Progress Bar`. **Dart** `AppEmptyState`, `AppErrorState`, `AppLoading`, `AppProgressBar`.

- Leer: gestrichelte Leerstelle mit Punktraster (`line-dot`), Symbol `size-icon`, ein Satz in `body`, eine Primäraktion („Erstes Rezept anlegen“). „Keine Treffer.“ ohne Aktion und ohne Punktraster – die Liste ist dann nicht leer, nur gefiltert.
- Fehler: Symbol `error`, Klartext der Ausnahme, tertiär „Erneut versuchen“.
- Laden: zentrierter Ladekreis `size-icon`, Strich `stroke-focus` in `text-primary`. Beim Fassungswechsel bleibt der alte Inhalt stehen, der Ladebalken (`stroke-rule`) erscheint erst nach 300 ms (heutiges Verhalten).
