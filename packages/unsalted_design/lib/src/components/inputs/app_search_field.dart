// lib/src/components/inputs/app_search_field.dart
//
// Komponente (Teil 1.2): Suchfeld mit Lupe (Figma `Input/Search`). Baut ein
// `TextField`.

import 'package:flutter/material.dart';

import '../icons/app_icons.dart';

/// Suchfeld.
class AppSearchField extends StatelessWidget {
  /// Erzeugt das Feld.
  const AppSearchField({super.key, required this.hint, this.controller, this.autofocus = false, this.onChanged});

  /// Platzhalter, z. B. „Suchen …“.
  final String hint;

  /// Steuert den Text von außen.
  final TextEditingController? controller;

  /// `true`: erhält beim Öffnen den Fokus.
  final bool autofocus;

  /// Meldet jede Änderung.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: autofocus,
        decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(AppIcons.search)),
        onChanged: onChanged,
      );
}
