# KeyValueTable

Die Deklarationstabelle zeigt Nährwerte wie ein Etikett: Tintenlinien, Haarlinien, rechtsbündige tabellarische Ziffern.

**Figma** `Data/Key Value Table` mit Spalten und Zeilenarten `key` · `sub` · `default`. **Dart** `AppKeyValueTable(headers:, rows:)`; in Core `NutritionTable`.

- Kopf in `label-small`/`text-secondary`, darunter `stroke-frame` in `line-strong`. Zeilen `data`, Haarlinien `line-hairline`, Zellabstand `space-xs`.
- Bezeichnung links, Werte rechts mit `tnum`. „davon“-Zeilen um `space-l` eingerückt und in `text-secondary`. kcal-Zeile fett.
- Reihenfolge wie das EU-Etikett: Kalorien, Fett, davon gesättigte Fettsäuren, Kohlenhydrate, davon Zucker, Ballaststoffe, Eiweiß, Salz. Nur kcal.
- „*“ und Fußnote für unvollständige Werte, „—“ für unbekannte. Keine Ampel.
