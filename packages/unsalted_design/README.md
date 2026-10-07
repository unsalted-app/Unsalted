# unsalted_design

Design-System von unsalted (Teil 1.2): Das Aussehen der App liegt
ausschließlich hier. Bildschirme in den Fachpaketen legen nur fest, *was*
angezeigt wird und *was* eine Aktion tut.

- **Rang 0** in `architecture.yaml`; einzige Abhängigkeit ist Flutter. Keine
  Fachbegriffe, keine Importe von `unsalted_core`, Riverpod oder Drift.
- **Öffentliche Tür:** `lib/unsalted_design.dart`, jeder Export mit `show`.
- **Version:** eigene Tags `design-vX.Y.Z`, siehe `CHANGELOG.md`.

Ebenen, Regeln und Ablauf Figma → Code: `docs/design/design_system.md`;
Plan: `docs/design/plan.md`.
