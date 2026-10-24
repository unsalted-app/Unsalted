# unsalted_design

Design-System von unsalted (Teil 1.2 gebaut, Teil 1.3 aus Figma gestaltet,
Teil 1.4 ergänzt; `design-v0.3.0`, unveröffentlicht): Das Aussehen der App liegt ausschließlich
hier. Bildschirme in den Fachpaketen legen nur fest, *was* angezeigt wird und
*was* eine Aktion tut.

- **Rang 0** in `architecture.yaml`; einzige Abhängigkeit ist Flutter. Keine
  Fachbegriffe, keine UI-Texte, keine Importe von `unsalted_core`, Riverpod
  oder Drift (DS-01, DS-06, `tool/check_architecture.dart`).
- **Werte:** nur aus `tokens/unsalted.tokens.json` (gleich
  `docs/design/system/tokens.json` aus Figma). `dart run tool/generate_tokens.dart`
  schreibt alle Dateien unter `lib/src/tokens/`; nie von Hand ändern (DS-04,
  DS-51).
- **Schrift:** Atkinson Hyperlegible Next 400/600/700 (`lib/fonts/`, SIL OFL
  1.1); die App registriert die Lizenz mit `AppFonts.registerLicenses()`.
- **Inhalt:** Tokens, Theme (Material-Rollen und Komponenten-Themes aus
  Tokens), Layout, Komponenten (inkl. Markenelemente unter
  `components/brand/`), Templates (Liste, Detail, Formular, ab Teil 1.4
  Liste und Detail nebeneinander); öffentliche Tür `lib/unsalted_design.dart`,
  jeder Export mit `show` (DS-03).
- **Große Schrift:** Maße neben Text wachsen bis 200 % mit
  (`AppReflowMetric`); Komponenten brechen um, statt abzuschneiden.
- **Katalog:** `apps/unsalted_widgetbook` (hell/dunkel × Handy/Tablet,
  Textgröße 100–200 %).
- **Goldens:** GL-01 (`test/goldens/`), nur unter Linux erzeugt und verglichen.
- **Version:** eigene Tags `design-vX.Y.Z`, siehe `CHANGELOG.md`.

```dart
import 'package:unsalted_design/unsalted_design.dart';

MaterialApp(theme: AppTheme.light(), darkTheme: AppTheme.dark(), …);

ListPageTemplate(
  title: 'Liste',
  search: AppSearchField(hint: 'Suchen …', onChanged: …),
  body: AppItemList.builder(itemCount: n, itemBuilder: …),
  primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: …),
);
```

Dokumentation: `docs/design/design_system.md` (Ebenen, Regeln, Benennung,
Weg der Werte Figma → Code), `docs/design/components.md` (alle Komponenten mit
Figma-Namen und -IDs), `docs/design/screens.md` (Bildschirme, Abschnitte,
Figma-Abgleich), `docs/design/rueckmeldung-figma.md` (bewusste Abweichungen
von Figma).
