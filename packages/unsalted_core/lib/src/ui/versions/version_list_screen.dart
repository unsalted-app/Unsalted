// lib/src/ui/versions/version_list_screen.dart
//
// Bildschirm 7 (Kapitel 22, Schritt 8.6): Versionsverlauf. Liste
// absteigend nach versionIndex (bereits von watchVersions sortiert),
// Badge Entwurf/Eingefroren, Stern markiert masterVersionId,
// snapshottedAt sofern vorhanden. Aktionen: Kopie als Entwurf
// (createDraftFrom), Vergleichen (öffnet version_compare_screen.dart für
// zwei Snapshot-Versionen -- Kapitel 13.7: nur Snapshots sind exportierbar,
// daher auch nur diese vergleichbar), Löschen (deleteVersion, mit
// Rückfrage, da destruktiv). „Als Master markieren“ für eingefrorene
// Versionen (Fehlerbehebung 9.2a: Kapitel 22 nennt die Aktion nicht, obwohl
// Kapitel 12.1 eine vom Nutzer gekürte Master-Version vorsieht).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../contracts/core_exceptions.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe.dart';
import '../../recipe/recipe_version.dart';
import '../recipe_editor/recipe_editor_screen.dart';
import 'version_compare_screen.dart';

class VersionListScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const VersionListScreen({super.key, required this.recipeId});

  @override
  ConsumerState<VersionListScreen> createState() => _VersionListScreenState();
}

class _VersionListScreenState extends ConsumerState<VersionListScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  Future<void> _copyAsDraft(RecipeVersion version) async {
    final newVersionId = await ref.read(recipeRepositoryProvider).createDraftFrom(version.id);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RecipeEditorScreen(recipeId: widget.recipeId, versionId: newVersionId),
    ));
  }

  Future<void> _delete(RecipeVersion version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version löschen?'),
        content: Text('V${version.versionIndex} wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(recipeRepositoryProvider).deleteVersion(version.id);
    } on IllegalStateException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _markAsMaster(RecipeVersion version) async {
    try {
      await ref.read(recipeRepositoryProvider).setMasterVersion(widget.recipeId, version.id);
    } on IllegalStateException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _compare(RecipeVersion version, List<RecipeVersion> allVersions) async {
    final others = allVersions
        .where((v) => v.id != version.id && v.state == VersionState.snapshot)
        .toList();
    final other = await showDialog<RecipeVersion>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Mit welcher Version vergleichen?'),
        children: [
          if (others.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Keine weitere eingefrorene Version vorhanden.'),
            ),
          for (final candidate in others)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(candidate),
              child: Text('V${candidate.versionIndex}${candidate.label == null ? '' : ' · ${candidate.label}'}'),
            ),
        ],
      ),
    );
    if (other == null || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => VersionCompareScreen(
        recipeId: widget.recipeId,
        versionAId: version.id,
        versionBId: other.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Versionen')),
      body: StreamBuilder<Recipe?>(
        stream: repo.watchRecipe(widget.recipeId),
        builder: (context, recipeSnapshot) {
          final masterVersionId = recipeSnapshot.data?.masterVersionId;

          return StreamBuilder<List<RecipeVersion>>(
            stream: repo.watchVersions(widget.recipeId),
            builder: (context, versionsSnapshot) {
              if (versionsSnapshot.connectionState == ConnectionState.waiting &&
                  !versionsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (versionsSnapshot.hasError) {
                return Center(child: Text(versionsSnapshot.error.toString()));
              }
              final versions = versionsSnapshot.data ?? const <RecipeVersion>[];
              if (versions.isEmpty) {
                return const Center(child: Text('Keine Versionen vorhanden.'));
              }

              return ListView.builder(
                itemCount: versions.length,
                itemBuilder: (context, index) {
                  final version = versions[index];
                  final isMaster = version.id == masterVersionId;
                  final isSnapshot = version.state == VersionState.snapshot;

                  return ListTile(
                    leading: isMaster
                        ? Icon(Icons.star, color: Theme.of(context).colorScheme.primary, semanticLabel: 'Master')
                        : null,
                    title: Text(
                      version.label == null ? 'V${version.versionIndex}' : 'V${version.versionIndex} · ${version.label}',
                    ),
                    subtitle: Text([
                      isSnapshot ? 'Eingefroren' : 'Entwurf',
                      if (version.snapshottedAt != null) _dateFormat.format(version.snapshottedAt!),
                    ].join(' · ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSnapshot && !isMaster)
                          IconButton(
                            icon: const Icon(Icons.star_outline),
                            tooltip: 'Als Master markieren',
                            onPressed: () => _markAsMaster(version),
                          ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Kopie als Entwurf',
                          onPressed: () => _copyAsDraft(version),
                        ),
                        IconButton(
                          icon: const Icon(Icons.compare_arrows),
                          tooltip: 'Vergleichen',
                          onPressed: isSnapshot ? () => _compare(version, versions) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Löschen',
                          onPressed: () => _delete(version),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
