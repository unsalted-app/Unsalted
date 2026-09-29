// lib/src/ui/settings/export_screen.dart
//
// Bildschirm 11 (Kapitel 22, Schritt 8.7): JSON-Export. Auswahl
// beschränkt auf Versionen mit state = snapshot (Kapitel 13.7:
// exportVersionAsJsonString wirft IllegalStateException auf Drafts --
// diese Datei filtert die Auswahl deshalb bereits vorher, statt den
// Fehlerfall provozieren zu lassen). "In Zwischenablage kopieren" nutzt
// das eingebaute Clipboard-API; ein nativer Teilen-Dialog bräuchte ein
// zusätzliches Paket (z. B. share_plus), das pubspec.yaml ändern würde --
// außerhalb des Dateiscopes dieses Schritts (nur lib/src/ui/settings/*).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/core_providers.dart';
import '../../recipe/recipe.dart';
import '../../recipe/recipe_version.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _selectedRecipeId;
  String? _selectedVersionId;
  String? _exportedJson;
  String? _error;

  Future<void> _export() async {
    setState(() {
      _error = null;
      _exportedJson = null;
    });
    try {
      final json =
          await ref.read(snapshotServiceProvider).exportVersionAsJsonString(_selectedVersionId!);
      setState(() => _exportedJson = json);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _exportedJson!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('In Zwischenablage kopiert.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<List<Recipe>>(
              stream: repo.watchRecipes(),
              builder: (context, snapshot) {
                final recipes = snapshot.data ?? const <Recipe>[];
                return DropdownButtonFormField<String>(
                  initialValue: _selectedRecipeId,
                  decoration: const InputDecoration(labelText: 'Rezept'),
                  items: [
                    for (final recipe in recipes)
                      DropdownMenuItem(value: recipe.id, child: Text(recipe.title)),
                  ],
                  onChanged: (id) => setState(() {
                    _selectedRecipeId = id;
                    _selectedVersionId = null;
                    _exportedJson = null;
                  }),
                );
              },
            ),
            const SizedBox(height: 8),
            if (_selectedRecipeId != null)
              StreamBuilder<List<RecipeVersion>>(
                stream: repo.watchVersions(_selectedRecipeId!),
                builder: (context, snapshot) {
                  final versions = (snapshot.data ?? const <RecipeVersion>[])
                      .where((v) => v.state == VersionState.snapshot)
                      .toList();
                  if (versions.isEmpty) {
                    return const Text('Keine eingefrorene Version vorhanden.');
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedVersionId,
                    decoration: const InputDecoration(labelText: 'Version'),
                    items: [
                      for (final version in versions)
                        DropdownMenuItem(
                          value: version.id,
                          child: Text('V${version.versionIndex}'),
                        ),
                    ],
                    onChanged: (id) => setState(() {
                      _selectedVersionId = id;
                      _exportedJson = null;
                    }),
                  );
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedVersionId == null ? null : _export,
              child: const Text('Exportieren'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_exportedJson != null) ...[
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(_exportedJson!),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _copyToClipboard,
                child: const Text('In Zwischenablage kopieren'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
