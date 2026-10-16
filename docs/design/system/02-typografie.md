# Typografie

**Schrift:** Atkinson Hyperlegible Next (Braille Institute mit Applied Design Works, 2025), SIL Open Font License 1.1, Version 2.001. Geprüft in der Schriftdatei: deutsche Zeichen vollständig (ä ö ü ß „ “ ‚ ‘ – — … € · ×), OpenType `tnum`, `pnum`, `frac`, `sups`, `case`; Standardziffern proportional; Null mit Schrägstrich (ohne Alternative). Es fehlen: schmales geschütztes Leerzeichen U+202F, Pfeile (← → ↑ ↓), ✓, ★, µ – diese Zeichen kommen als Symbol (`AppIcons`) oder fallen auf eine Systemschrift zurück.

**Warum diese Schrift:** unsalted rechnet exakt und zeigt Mengen, Nährwerte und Fassungsnummern. Eine Schrift, die verwechselbare Zeichen (1/l/I, 0/O, 5/S) bewusst unterscheidet, schützt genau diese Information und ist auf Armlänge in der Küche lesbar. Sie ist frei, für deutsche Texte vollständig, nicht an eine Plattform gebunden und kein Trend der App- und SaaS-Welt (Inter, DM Sans, Geist). Ihre eigenwilligen Formen machen die App ohne Logo wiedererkennbar.

**Wie viele Stile?** Elf: zehn in der Textschrift, einer für Code. Drei Schnitte (400, 600, 700). Keine Kursive, keine Versalien, kein Sperrsatz.

| Stil (`type/…`) | Dart (Vorschlag) | Größe / Zeile | Schnitt | Ziffern | Einsatz |
|---|---|---|---|---|---|
| `display` | `AppTypography.display` | 28 / 36 | 700 | tnum bei Zahlen | Rezepttitel im Detail; höchstens einmal je Bildschirm |
| `title-page` | `titlePage` | 20 / 28 | 700 | — | Kopfleiste, Dialogtitel |
| `heading` | `heading` | 18 / 24 | 700 | — | Abschnittsüberschrift, immer unter der 3-px-Linie |
| `body` | `body` | 16 / 24 | 400 | — | Fließtext, Schritte, Beschreibung, Eingabetext, Hinweise |
| `body-strong` | `bodyStrong` | 16 / 24 | 600 | — | Listentitel, Button-Beschriftung, Zutatennamen, Hervorhebung |
| `body-small` | `bodySmall` | 14 / 20 | 400 | — | Untertitel in Listen, sekundäre Angaben, Zutatennotiz |
| `label-small` | `labelSmall` | 13 / 16 | 600 | tnum | Fassungsmarke, Tags, Feldbeschriftung über dem Feld, Navigation, Tabellenkopf |
| `caption` | `caption` | 13 / 18 | 400 | — | Hilfe- und Fehlertexte, Fußnoten, Zeitstempel |
| `data` | `data` | 16 / 24 | 400 | tnum | Werte in Tabellen, Mengen, Zahlenfelder |
| `data-strong` | `dataStrong` | 16 / 24 | 700 | tnum | kcal-Zeile, Summen, Kennzahlen, Ergebnis des Mengenrechners |
| `code` | `code` | 13 / 20 | 400 (Monospace) | — | JSON-Export und -Import |

Laufweite überall 0. Zeilenhöhen liegen auf dem 4-px-Raster.

## Regeln

- **Hierarchie über Größe und Schnitt, nicht über Farbe.** Eine Ebene tiefer heißt: kleiner oder leichter, dann erst `text-secondary`.
- **Zahlen sind Tabellen.** Jede Zahl, die man vergleicht, steht mit `tnum`, rechtsbündig, Einheit nach U+00A0 in `text-secondary` und Schnitt 400.
- **Einheit kleiner als der Wert nur bei Kennzahlen:** neben `display` steht die Einheit in 16 / 24, Schnitt 600.
- **Umbruch:** Titel höchstens zwei Zeilen, dann „…“. Button-Beschriftungen einzeilig – sonst kürzeren Text wählen. Zahlen, Einheiten und Fehlermeldungen werden nie gekürzt. Flutter trennt nicht automatisch: lange Komposita („Fertiggewicht-Override“) über Wortwahl oder Layout lösen, nicht über Silbentrennung.
- **Groß- und Kleinschreibung:** Satzschreibung überall; „V3“ mit großem V; „kcal“, „g“, „ml“ klein.
- **Mindestgrößen:** Fließtext 16, sonst 13. Systemweite Textgröße bis 200 % muss das Layout tragen.

## Zuordnung zu Material 3 (`TextTheme`)

Material-Widgets lesen die 15 Material-Rollen. Sie zeigen auf die elf Stile:

| Material-Rolle | Stil |
|---|---|
| `displayLarge`, `displayMedium`, `displaySmall`, `headlineLarge` | `display` |
| `headlineMedium`, `headlineSmall`, `titleLarge` | `title-page` |
| `titleMedium`, `titleSmall`, `labelLarge` | `body-strong` |
| `bodyLarge`, `bodyMedium` | `body` |
| `bodySmall` | `caption` |
| `labelMedium`, `labelSmall` | `label-small` |

Achtung: Material setzt Text ohne Stil in `bodyMedium`. Mit dieser Zuordnung ist Standardtext 16 / 24 statt 14 / 20; Listen-Untertitel brauchen deshalb ausdrücklich `body-small` im `ListTileTheme`.

## Einbindung (später, im Code)

- Schriftdateien (TTF, Schnitte 400/600/700) im Paket `unsalted_design` unter `lib/fonts/` mit `OFL.txt`, in dessen `pubspec.yaml` deklariert und mit `package: 'unsalted_design'` referenziert. Kein Laden zur Laufzeit (`google_fonts`): die App arbeitet offline und soll keine Anfragen an Dritte senden.
- Lizenztext über `LicenseRegistry.addLicense` registrieren, damit er unter „Über unsalted“ erscheint.
- Tabellarische Ziffern über `FontFeature.tabularFigures()` in `data`, `data-strong`, `label-small`.
