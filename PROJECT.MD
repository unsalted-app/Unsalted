# unsalted — Projektregeln

Diese Datei ist verbindlich für jede Person und jede KI, die an diesem Projekt arbeitet.
Sie besteht aus drei Teilen: den Grundregeln (Kapitel 1), der Zahlenregel (Kapitel 4.1)
und der Abschluss-Checkliste, die für **jeden** Entwicklungsschritt gilt.

---

## 1. Grundregeln

**R1 — Abhängigkeit nur nach hinten.**
Ein Paket mit Rang N darf nur Pakete mit Rang < N importieren. Rang steht in
`architecture.yaml`. Der Kern hat Rang 1 und importiert kein anderes Projektpaket.

**R2 — Eine öffentliche Tür.**
Jedes Paket exportiert genau eine Datei `lib/<paketname>.dart`. Alles unter
`lib/src/` ist privat. Fremde Pakete importieren ausschließlich die Tür.

**R3 — Eigene Tabellen pro Teil.**
Ein Teil legt nur neue Tabellen an. Verweise zwischen Teilen sind Text-UUIDs,
niemals Fremdschlüssel.

**R4 — Nur additiv nach dem Freeze.**
Neue Funktion = neue Datei / neue Tabelle / neuer Steckplatz. Bestehende
Signaturen, Spalten und JSON-Felder bleiben unverändert.

**R5 — Alle Schreibzugriffe über Repositories.**
Kein Widget, kein Service und kein fremdes Paket schreibt direkt in Tabellen.

**R6 — Kein double für fachliche Zahlen.**
Siehe Abschnitt 4.1 unten.

**R7 — Kein kJ.**
Energie ist ausschließlich `energy_kcal`.

---

## 4.1 Feste Zahlenregeln (Decimal)

- Alle fachlichen Zahlen sind `Decimal`. Ausnahmen (bewusst `int`): `position`,
  `servings`, `timer_seconds`, `version_index`, `snapshot_format_version`.
- Niemals `double`, niemals `num`, niemals `.toDouble()` in `lib/`. Ausnahme:
  reine Layout-Werte in Flutter (Padding, Größen) — das sind keine fachlichen Zahlen.
- Speicherung in SQLite: `TEXT`, über `DecimalConverter`.
- Serialisierung in JSON: String, z. B. `"quantity": "12.5"` — niemals `12.5`.
- Parsen immer mit `Decimal.parse(...)`, niemals `Decimal.parse(double.toString())`.
- Rational → Decimal nur über `toFixedDecimal()` aus `decimal_math.dart`. Ein
  direkter Aufruf von `toDecimal(...)` außerhalb dieser Datei ist verboten
  (siehe Architekturtest AT-08).

---

## Abschluss-Checkliste für jeden Schritt

- [ ] Dateien erstellt/geändert (nur die genannten)
- [ ] Implementierung fertig
- [ ] Unit-Tests geschrieben
- [ ] Tests erfolgreich (`flutter test`)
- [ ] Keine `double`-Verwendung (AT-07)
- [ ] Keine verbotenen Abhängigkeiten (AT-01..AT-05)
- [ ] Öffentliche API geprüft (AT-06)
- [ ] `docs/status.md` aktualisiert
- [ ] Commit mit Schrittnummer im Text

---

## Regeln für die KI

1. Arbeite nur im aktuellen Schritt. Ändere keine Datei, die nicht im Schritt genannt ist.
2. Ändere niemals ein Paket mit niedrigerem Rang. Wenn du glaubst, du müsstest: stoppen und begründen.
3. Benutze nur die öffentliche Tür anderer Pakete, nie deren `src/`.
4. Zahlentyp `Decimal`, intern `Rational`, niemals `double`. Rational → Decimal nur über `toFixedDecimal` aus `decimal_math.dart`.
5. Energie ist ausschließlich `energy_kcal`. Schreibe nirgends `kJ`.
6. Neue Tabelle = neue Datei, Standardfelder, Text-UUID, keine Fremdschlüssel, kein Auto-Increment.
7. Rechenlogik nur in `src/nutrition/`, ungerundet. Runden nur im Formatter.
8. Nenne vor dem Schreiben die betroffenen Dateien und warum — dann erst schreiben.
9. Nach jeder Änderung: Test ergänzen, `flutter test` laufen lassen, `docs/status.md` aktualisieren, in einfachen Worten erklären, was wo geändert wurde.
10. Unsicher bei einer Paket-Schnittstelle? Sagen, statt raten. Versionsnummern nachschlagen, nicht erfinden.