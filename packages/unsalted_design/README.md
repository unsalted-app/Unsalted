# unsalted_design

Design-System von unsalted (Teil 1.2, `design-v0.1.0`): Das Aussehen der App
liegt ausschließlich hier. Bildschirme in den Fachpaketen legen nur fest,
*was* angezeigt wird und *was* eine Aktion tut.

- **Rang 0** in `architecture.yaml`; einzige Abhängigkeit ist Flutter. Keine
  Fachbegriffe, keine UI-Texte, keine Importe von `unsalted_core`, Riverpod
  oder Drift (DS-01, DS-06, `tool/check_architecture.dart`).
- **Inhalt:** Tokens (`lib/src/tokens/`), Theme, Layout, Komponenten,
  Templates; öffentliche Tür `lib/unsalted_design.dart`, jeder Export mit
  `show` (DS-03).
- **Platzhalter:** Die Tokens tragen den Flutter-Standard (Material 3); das
  echte Design kommt aus Figma (DS-07 weist die Neutralität nach).
- **Katalog:** `apps/unsalted_widgetbook` (hell/dunkel × Handy/Tablet).
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
Ablauf Figma → Code), `docs/design/components.md` (alle Komponenten mit
Figma-Namen), `docs/design/screens.md` (Bildschirme und Abschnitte).
