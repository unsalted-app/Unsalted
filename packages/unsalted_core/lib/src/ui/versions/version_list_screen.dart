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
// Seit Teil 1.2 (C20) aus Design-Komponenten: ListPageTemplate, Abschnitt
// sections/version_list_results_section.dart, Baustein VersionTile.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/core_exceptions.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe.dart';
import '../../recipe/recipe_version.dart';
import '../recipe_editor/recipe_editor_screen.dart';
import 'sections/version_list_results_section.dart';
import 'version_compare_screen.dart';

class VersionListScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const VersionListScreen({super.key, required this.recipeId});

  @override
  ConsumerState<VersionListScreen> createState() => _VersionListScreenState();
}

class _VersionListScreenState extends ConsumerState<VersionListScreen> {
  Future<void> _copyAsDraft(RecipeVersion version) async {
    final newVersionId = await ref.read(recipeRepositoryProvider).createDraftFrom(version.id);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RecipeEditorScreen(recipeId: widget.recipeId, versionId: newVersionId),
    ));
  }

  Future<void> _delete(RecipeVersion version) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Version löschen?',
      message: 'V${version.versionIndex} wird unwiderruflich gelöscht.',
      confirmLabel: 'Löschen',
      cancelLabel: 'Abbrechen',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(recipeRepositoryProvider).deleteVersion(version.id);
    } on IllegalStateException catch (e) {
      if (!mounted) return;
      showAppMessage(context, e.message);
    }
  }

  Future<void> _markAsMaster(RecipeVersion version) async {
    try {
      await ref.read(recipeRepositoryProvider).setMasterVersion(widget.recipeId, version.id);
    } on IllegalStateException catch (e) {
      if (!mounted) return;
      showAppMessage(context, e.message);
    }
  }

  Future<void> _compare(RecipeVersion version, List<RecipeVersion> allVersions) async {
    final others = allVersions
        .where((v) => v.id != version.id && v.state == VersionState.snapshot)
        .toList();
    final other = await showAppChoiceDialog<RecipeVersion>(
      context,
      title: 'Mit welcher Version vergleichen?',
      options: [
        for (final candidate in others)
          AppSelectItem(
            candidate,
            'V${candidate.versionIndex}${candidate.label == null ? '' : ' · ${candidate.label}'}',
          ),
      ],
      emptyMessage: 'Keine weitere eingefrorene Version vorhanden.',
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

    return ListPageTemplate(
      title: 'Versionen',
      body: StreamBuilder<Recipe?>(
        stream: repo.watchRecipe(widget.recipeId),
        builder: (context, recipeSnapshot) {
          final masterVersionId = recipeSnapshot.data?.masterVersionId;

          return StreamBuilder<List<RecipeVersion>>(
            stream: repo.watchVersions(widget.recipeId),
            builder: (context, versionsSnapshot) {
              if (versionsSnapshot.connectionState == ConnectionState.waiting &&
                  !versionsSnapshot.hasData) {
                return const AppLoading();
              }
              if (versionsSnapshot.hasError) {
                return AppErrorState(message: versionsSnapshot.error.toString());
              }
              final versions = versionsSnapshot.data ?? const <RecipeVersion>[];
              if (versions.isEmpty) {
                return const AppEmptyState(message: 'Keine Versionen vorhanden.');
              }

              return VersionListResultsSection(
                versions: versions,
                masterVersionId: masterVersionId,
                onMarkMaster: _markAsMaster,
                onCopy: _copyAsDraft,
                onCompare: (version) => _compare(version, versions),
                onDelete: _delete,
              );
            },
          );
        },
      ),
    );
  }
}
