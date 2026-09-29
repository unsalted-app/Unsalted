// lib/src/ui/settings/settings_screen.dart
//
// Bildschirm 13 (Kapitel 22, Schritt 8.7): Sammelseite. Export, Import,
// "Über unsalted" als feste Einträge; darunter alle settingsEntries aus
// den registrierten Modulen (Kapitel 21), generisch nach order sortiert.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../module/extension_types.dart';
import '../../providers/core_providers.dart';
import 'export_screen.dart';
import 'import_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);
    final entries = <SettingsEntry>[
      for (final module in modules) ...module.settingsEntries,
    ]..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ExportScreen(),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ImportScreen(),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Über unsalted'),
            onTap: () => showAboutDialog(context: context, applicationName: 'unsalted'),
          ),
          if (entries.isNotEmpty) const Divider(),
          for (final entry in entries)
            ListTile(
              title: Text(entry.title),
              subtitle: entry.subtitle == null ? null : Text(entry.subtitle!),
              onTap: () => entry.onTap(context),
            ),
        ],
      ),
    );
  }
}
