// lib/src/ui/versions/version_compare_screen.dart
//
// Bildschirm 8 (Kapitel 22, Schritt 8.6): Versionsvergleich. Lädt beide
// Snapshot-Versionen über SnapshotService.exportVersion (Kapitel 13.7: nur
// Snapshots sind exportierbar) und vergleicht sie über RecipeDiff.between
// -- keine eigene Diff-Logik in der UI (Arbeitskarte §7). Die
// Änderungsliste wird nach Kategorie gruppiert angezeigt (Kapitel 15.4:
// Parameter, dann Schritte, dann Zutaten -- exakt die Reihenfolge, in der
// RecipeDiff.between sie bereits liefert). „Als neuen Entwurf übernehmen"
// reicht exakt dieselbe Liste an applyChangesAsNewDraft weiter (Kapitel
// 15.5), mit versionAId als Basis. Die Zutatenzeilen von B gehen als
// targetRows mit, sonst verlieren Add/Replace die Lebensmittel-Verknüpfung
// (Fehlerbehebung 9.1a, F3). Die Texte der Liste kommen aus
// change_descriptions.dart (Fehlerbehebung 9.2a) und ändern die Liste nicht.

// Seit Teil 1.2 (C21) aus Design-Komponenten: DetailPageTemplate mit
// DetailSplit, Abschnitte unter sections/, Bausteine SnapshotColumn und
// ChangeList.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../providers/core_providers.dart';
import '../../recipe/recipe_change.dart';
import '../../recipe/recipe_diff.dart';
import '../../recipe/recipe_snapshot_v1.dart';
import '../recipe_editor/recipe_editor_screen.dart';
import 'sections/version_compare_apply_section.dart';
import 'sections/version_compare_changes_section.dart';
import 'sections/version_compare_columns_section.dart';

class VersionCompareScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final String versionAId;
  final String versionBId;

  const VersionCompareScreen({
    super.key,
    required this.recipeId,
    required this.versionAId,
    required this.versionBId,
  });

  @override
  ConsumerState<VersionCompareScreen> createState() => _VersionCompareScreenState();
}

class _VersionCompareScreenState extends ConsumerState<VersionCompareScreen> {
  late Future<(RecipeSnapshotV1, RecipeSnapshotV1, List<RecipeChange>)> _future;
  bool _applying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(RecipeSnapshotV1, RecipeSnapshotV1, List<RecipeChange>)> _load() async {
    final service = ref.read(snapshotServiceProvider);
    final a = await service.exportVersion(widget.versionAId);
    final b = await service.exportVersion(widget.versionBId);
    final targetRows = (await ref.read(recipeRepositoryProvider).getVersion(widget.versionBId))?.ingredients;
    final changes = RecipeDiff.between(a, b, targetRows: targetRows);
    return (a, b, changes);
  }

  Future<void> _apply(List<RecipeChange> changes) async {
    setState(() {
      _applying = true;
      _error = null;
    });
    try {
      final newVersionId =
          await ref.read(recipeRepositoryProvider).applyChangesAsNewDraft(widget.versionAId, changes);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => RecipeEditorScreen(recipeId: widget.recipeId, versionId: newVersionId),
      ));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailPageTemplate(
      title: 'Versionen vergleichen',
      body: FutureBuilder<(RecipeSnapshotV1, RecipeSnapshotV1, List<RecipeChange>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoading();
          }
          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              retryLabel: 'Erneut versuchen',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final (a, b, changes) = snapshot.data!;

          return DetailSplit(
            primary: VersionCompareColumnsSection(a: a, b: b),
            secondary: VersionCompareChangesSection(a: a, changes: changes),
            footer: [
              VersionCompareApplySection(
                error: _error,
                onApply: (_applying || changes.isEmpty) ? null : () => _apply(changes),
              ),
            ],
          );
        },
      ),
    );
  }
}
