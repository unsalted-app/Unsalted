// lib/src/ui/settings/settings_screen.dart
//
// Bildschirm 13 (Kapitel 22, Schritt 8.7): Sammelseite. Export, Import,
// "Über unsalted" als feste Einträge; darunter alle settingsEntries aus
// den registrierten Modulen (Kapitel 21), generisch nach order sortiert.
// Seit Teil 1.2 (C14) aus Design-Komponenten: ListPageTemplate, Abschnitte
// unter sections/.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../module/extension_types.dart';
import '../../providers/core_providers.dart';
import 'export_screen.dart';
import 'import_screen.dart';
import 'sections/settings_core_entries_section.dart';
import 'sections/settings_module_entries_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);
    final entries = <SettingsEntry>[
      for (final module in modules) ...module.settingsEntries,
    ]..sort((a, b) => a.order.compareTo(b.order));

    return ListPageTemplate(
      title: 'Einstellungen',
      body: AppItemList(
        children: [
          SettingsCoreEntriesSection(
            onExport: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ExportScreen(),
            )),
            onImport: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ImportScreen(),
            )),
            onAbout: () => showAppAboutDialog(context, applicationName: 'unsalted'),
          ),
          SettingsModuleEntriesSection(entries: entries, onSelected: (entry) => entry.onTap(context)),
        ],
      ),
    );
  }
}
