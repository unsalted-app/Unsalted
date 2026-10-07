// lib/src/ui/recipe_detail/sections/recipe_detail_description_section.dart
//
// Bildschirm 4, Abschnitt „Beschreibung“ (Teil 1.2): optionale Beschreibung
// unter der Versionsleiste.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Beschreibung des Rezepts; ohne Beschreibung nur der Abstand.
class RecipeDetailDescriptionSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const RecipeDetailDescriptionSection({super.key, required this.description});

  /// Beschreibung; `null` = keine.
  final String? description;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppGap(AppSpace.s),
          if (description != null) AppText(description!),
          const AppGap(AppSpace.l),
        ],
      );
}
