# Ist-Zustand im Repository

Stand `unsalted-app/Unsalted`, Branch `main`, Commit `1022185` (7. Oktober 2026). Nur Fakten aus dem Code.

| Bereich | Befund | Fundstelle |
|---|---|---|
| Technik | Flutter 3.47.5, Dart-SDK ^3.13.4, Riverpod 3.4, go_router 18, Drift; Plattformordner iOS, Android, macOS | `.github/workflows/ci.yml`, `apps/unsalted_app/pubspec.yaml` |
| Design-Paket | `packages/unsalted_design` 0.1.0, Rang 0, nur Abhängigkeit `flutter`, Tür mit `show` | `architecture.yaml`, `packages/unsalted_design/pubspec.yaml` |
| Farben | 46 Material-3-Rollen hell/dunkel, Werte = Flutter-Standard (`primary` #6750A4) | `lib/src/tokens/color_tokens.dart` |
| Typografie | 15 Material-3-Rollen, Systemschrift | `lib/src/tokens/typography_tokens.dart` |
| Abstände | 2, 4, 8, 12, 16, 24, 32 (`space/xxs` … `space/xxl`) | `lib/src/tokens/spacing_tokens.dart` |
| Radien | 0, 4, 8, 12, 16, 28, voll | `lib/src/tokens/radius_tokens.dart` |
| Höhen | 0, 1, 3, 6, 8, 12 | `lib/src/tokens/elevation_tokens.dart` |
| Bewegung | 150 / 250 / 400 ms, `Easing.standard`, „Bewegung reduzieren“ = 0 | `lib/src/tokens/motion_tokens.dart` |
| Breakpoints | 600, 840, 1200 | `lib/src/tokens/breakpoint_tokens.dart` |
| Symbole | 21 Material Icons unter fachneutralen Namen | `lib/src/components/icons/app_icons.dart` |
| Komponenten | 31 Komponentendateien, 5 Layout-Dateien, 3 Templates; Widgetbook mit 63 Anwendungsfällen (hell/dunkel × Handy/Tablet, nur macOS) | `lib/src/`, `test/architecture/public_api_golden.txt`, `apps/unsalted_widgetbook/`, `docs/decisions.md` (C11) |
| Regeln | Aussehen nur im Design-Paket; Bildschirme ohne feste Farben, Stile, Abstandszahlen | AT-13, AT-14, AT-15, DS-01 … DS-07 |
| Marke | kein Logo, keine Wortmarke, keine Schrift; App-Symbole = Flutter-Logo; Startbild 1 × 1 px | `ios/Runner/Assets.xcassets/`, `android/app/src/main/res/` |
| Name | „unsalted“ in allen UI-Texten; iOS „Unsalted App“, Android „unsalted_app“ | `settings_screen.dart`, `Info.plist`, `AndroidManifest.xml` |
