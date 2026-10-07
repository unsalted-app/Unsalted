// lib/src/ui/settings/sections/settings_module_entries_section.dart
//
// Bildschirm 13, Abschnitt „Modul-Einträge“ (Teil 1.2): alle
// `settingsEntries` der registrierten Module, bereits nach `order` sortiert,
// unter einer Trennlinie (Kapitel 21).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../../module/extension_types.dart';

/// Die Einträge der Module; leer = nichts.
class SettingsModuleEntriesSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const SettingsModuleEntriesSection({super.key, required this.entries, required this.onSelected});

  /// Einträge in Anzeigereihenfolge.
  final List<SettingsEntry> entries;

  /// Meldet den angetippten Eintrag.
  final ValueChanged<SettingsEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return AppStack(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDivider(),
        for (final entry in entries)
          AppListItem(title: entry.title, subtitle: entry.subtitle, onTap: () => onSelected(entry)),
      ],
    );
  }
}
