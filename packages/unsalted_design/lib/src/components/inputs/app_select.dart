// lib/src/components/inputs/app_select.dart
//
// Komponente (Teil 1.2): Auswahlliste (Figma `Input/Select`). Mit Label
// baut sie ein `DropdownButtonFormField`, ohne Label ein `DropdownButton`
// (Plan R1). Mit Label gilt [AppSelect.value] nur als Startwert.

import 'package:flutter/material.dart';

/// Ein Eintrag einer [AppSelect].
@immutable
class AppSelectItem<T> {
  /// Erzeugt den Eintrag.
  const AppSelectItem(this.value, this.label);

  /// Wert.
  final T value;

  /// Anzeigetext.
  final String label;
}

/// Auswahlliste.
class AppSelect<T> extends StatelessWidget {
  /// Erzeugt die Liste.
  const AppSelect({super.key, required this.items, required this.value, required this.onChanged, this.label});

  /// Einträge.
  final List<AppSelectItem<T>> items;

  /// Gewählter Wert; `null` = keiner.
  final T? value;

  /// Meldet die Auswahl; `null` = gesperrt.
  final ValueChanged<T>? onChanged;

  /// Bezeichnung; mit Label als Formularfeld.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      for (final item in items) DropdownMenuItem<T>(value: item.value, child: Text(item.label)),
    ];
    final callback = onChanged;
    final changed = callback == null
        ? null
        : (T? selected) {
            if (selected != null) callback(selected);
          };
    if (label == null) {
      return DropdownButton<T>(value: value, items: menuItems, onChanged: changed);
    }
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: menuItems,
      onChanged: changed,
    );
  }
}
