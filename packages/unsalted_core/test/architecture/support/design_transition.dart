// test/architecture/support/design_transition.dart
//
// Übergangsliste (Teil 1.2): Dateien unter lib/src/ui/, die noch nicht auf
// das Design-System umgestellt sind. AT-13 und AT-14 nehmen sie aus. Jede
// Umstellung (C14–C25) streicht ihre Dateien; steht eine Datei ohne Verstoß
// auf der Liste, schlägt AT-14 fehl. Mit C27 ist die Liste leer und entfällt.
// Pfade relativ zum Projektstamm.

/// Noch nicht umgestellte Dateien.
const designTransitionList = <String>{
  'packages/unsalted_core/lib/src/ui/recipe_editor/ingredient_row.dart',
  'packages/unsalted_core/lib/src/ui/recipe_editor/recipe_editor_screen.dart',
};
