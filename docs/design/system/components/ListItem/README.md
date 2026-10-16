# ListItem

Listeneintrag ohne Karte: Titel, Untertitel, rechts Fassungsmarke oder Aktionen; Haarlinien trennen.

**Figma** `List/Item` mit `subtitle`, `leading`, `trailing`, `dense`; `List/Swipe to Delete`. **Dart** `AppListItem`, `AppItemList`, `AppSwipeToDelete`.

- Mindesthöhe `size-list-item`, Innenabstand `space-m` oben und unten, `space-l` seitlich, Abstand zwischen Text und Marke `space-m`, Titel `body-strong`, Untertitel `body-small`/`text-secondary`, Trenner `stroke-hairline` in `line-hairline`.
- Rezepte: rechts die Fassungsmarke (Master, sonst neueste). Lebensmittel: Untertitel nennt Herkunft und kcal/100 g.
- Wischen nach links zeigt `feedback-error-surface` mit `delete`; danach 5 s „Rückgängig“. Es gibt immer einen Menüweg zum Löschen (WCAG 2.5.1).
- Ab Tablet bleibt es eine Liste; ein Raster ist eine eigene Entscheidung.
