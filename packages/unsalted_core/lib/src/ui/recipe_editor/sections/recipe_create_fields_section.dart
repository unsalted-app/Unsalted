// lib/src/ui/recipe_editor/sections/recipe_create_fields_section.dart
//
// Bildschirm 2, Abschnitt „Felder“ (Teil 1.2): Titel (1–200 Zeichen) und
// Beschreibung.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Eingabefelder für ein neues Rezept.
class RecipeCreateFieldsSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeCreateFieldsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.titleError,
  });

  /// Titel.
  final TextEditingController titleController;

  /// Beschreibung.
  final TextEditingController descriptionController;

  /// Fehlertext zum Titel; `null` = keiner.
  final String? titleError;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(controller: titleController, label: 'Titel', error: titleError),
          AppTextField(controller: descriptionController, label: 'Beschreibung', maxLines: 4),
        ],
      );
}
