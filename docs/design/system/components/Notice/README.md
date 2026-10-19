# Notice

Hinweiszeile mit Symbol: neutral für Info und Erfolg, Orange für Warnungen, Rot für Fehler.

**Figma** `Feedback/Notice` mit `kind` = `info` · `success` · `warning` · `error`, `action`. **Dart** `AppNotice(message, kind:, action:)`; `AppSurface` mit Tönen für schlichte Flächen.

- Innenabstand `space-m`, Symbol zu Text `space-m`, `radius-s`, Text `body`, Symbol `size-icon-small` links (um `space-xxs` abgesenkt, damit es mit der ersten Zeile fluchtet), Aktion tertiär rechts mit Höhe `size-control-small`.
- Info: `surface-sunken`, `text-primary`, Symbol `info` in `text-secondary`. Erfolg: dasselbe mit `check`.
- Warnung: `feedback-warning-surface` / `feedback-on-warning-surface` mit `warning`. Fehler: `feedback-error-surface` / `feedback-on-error-surface` mit `error`, als Live-Region.
- Keine farbige Randleiste, kein Marker. Das Symbol ist Pflicht, weil Warn- und Fehlerfarbe kaum in der Helligkeit abweichen.
- Heute zeigen Warn- und Fehlerkästen im Verpackungsformular kein Symbol (`AppSurface`) – mit diesem System wird daraus `AppNotice`.
