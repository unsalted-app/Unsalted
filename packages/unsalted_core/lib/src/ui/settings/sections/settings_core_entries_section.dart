// lib/src/ui/settings/sections/settings_core_entries_section.dart
//
// Bildschirm 13, Abschnitt „feste Einträge“ (Teil 1.2): Export, Import,
// „Über unsalted“.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Die festen Einträge der Einstellungen.
class SettingsCoreEntriesSection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const SettingsCoreEntriesSection({super.key, required this.onExport, required this.onImport, required this.onAbout});

  /// Öffnet den Export.
  final VoidCallback onExport;

  /// Öffnet den Import.
  final VoidCallback onImport;

  /// Zeigt „Über unsalted“.
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppListItem(leading: const AppIcon(AppIcons.upload), title: 'Export', onTap: onExport),
          AppListItem(leading: const AppIcon(AppIcons.download), title: 'Import', onTap: onImport),
          AppListItem(leading: const AppIcon(AppIcons.info), title: 'Über unsalted', onTap: onAbout),
        ],
      );
}
