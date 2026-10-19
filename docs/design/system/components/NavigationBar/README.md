# NavigationBar

Hauptnavigation mit drei Zielen; die Auswahl ist ein Tintenbalken an der Oberkante statt einer Pille.

**Figma** `Navigation/Navigation Bar` mit `selected`. **Dart** `AppNavigationBar(destinations:, selectedIndex:, onSelected:)`.

- `surface-page`, Haarlinie oben, Mindesthöhe `size-nav-bar`, Innenabstand `space-m` oben und `space-s` unten, Symbol `size-icon`, Symbol zu Beschriftung `space-xs`, Beschriftung `label-small`; die Ziele teilen die Breite.
- Gewählt: 3-px-Balken (`stroke-rule`, `line-strong`, Breite `size-target`) oben, Symbol und Text in `text-primary`. Nicht gewählt: `text-secondary`.
- Ziele heute: Rezepte, Lebensmittel, Einstellungen.
- **Entschieden (Material 3, adaptive Navigation):** unter `breakpoint-medium` (600) Leiste unten; ab `breakpoint-medium` seitliche Leiste links (`Navigation/Navigation Rail`, Breite `size-nav-rail` 96 wie die eingeklappte Navigation Rail in Material 3 Expressive) mit gleicher Logik: dieselben Ziele, Auswahl als 3-px-Balken oben am Ziel, Haarlinie rechts. Ab `breakpoint-expanded` (840) stehen Rezepte und Lebensmittel als Liste und Detail nebeneinander (Listenspalte `size-list-pane` 360, gewählter Eintrag mit `List/Item` · `selected`); ab `breakpoint-large` (1200) ist das Rezeptdetail zweispaltig (Haupt: Kopf, Nährwerte, Mengenrechner · Neben: Zutaten, Schritte). Handy quer zählt nach der Breite, also mit Leiste links.
- Systemleiste: Die Beschriftung folgt der Textgröße nicht (Modus `100` fest); bei großer Schrift zeigt langes Drücken das Ziel vergrößert (Large Content Viewer, iOS) bzw. als Tooltip.
- Flutter: eigener `indicatorShape` oder eigene Komponente auf der `widgets`-Ebene.
