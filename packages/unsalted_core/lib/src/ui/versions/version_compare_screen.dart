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
// 15.5), mit versionAId als Basis.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/core_providers.dart';
import '../../recipe/recipe_change.dart';
import '../../recipe/recipe_diff.dart';
import '../../recipe/recipe_snapshot_v1.dart';
import '../recipe_editor/recipe_editor_screen.dart';

enum _ChangeCategory { parameter, steps, ingredients }

_ChangeCategory _categoryOf(RecipeChange change) {
  return switch (change) {
    SetTitle() || SetNotes() || SetBakingLoss() || SetFinalWeightOverride() || SetServings() =>
      _ChangeCategory.parameter,
    SetStep() || AddStep() || RemoveStep() => _ChangeCategory.steps,
    SetIngredientQuantity() ||
    ReplaceIngredient() ||
    RemoveIngredient() ||
    AddIngredient() ||
    MoveIngredient() =>
      _ChangeCategory.ingredients,
  };
}

String _categoryLabel(_ChangeCategory category) => switch (category) {
      _ChangeCategory.parameter => 'Parameter',
      _ChangeCategory.steps => 'Schritte',
      _ChangeCategory.ingredients => 'Zutaten',
    };

String _describe(RecipeChange change) {
  return switch (change) {
    AddIngredient c => 'Zutat "${c.displayName}" hinzugefügt (Position ${c.position})',
    RemoveIngredient c => 'Zutat an Position ${c.position} entfernt',
    SetIngredientQuantity c => 'Menge an Position ${c.position} geändert: ${c.quantity} ${c.unitCode ?? ''}',
    ReplaceIngredient c => 'Zutat an Position ${c.position} ersetzt durch "${c.displayName}"',
    MoveIngredient c => 'Zutat von Position ${c.from} nach ${c.to} verschoben',
    AddStep c => 'Schritt hinzugefügt (Position ${c.position})',
    RemoveStep c => 'Schritt an Position ${c.position} entfernt',
    SetStep c => 'Schritt an Position ${c.position} geändert',
    SetBakingLoss c => 'Backverlust geändert auf ${c.percent} %',
    SetFinalWeightOverride c => c.grams == null
        ? 'Fertiggewicht-Override entfernt'
        : 'Fertiggewicht-Override geändert auf ${c.grams} g',
    SetServings c => 'Portionen geändert auf ${c.servings?.toString() ?? '—'}',
    SetTitle c => 'Titel geändert auf "${c.title}"',
    SetNotes() => 'Notizen geändert',
  };
}

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
    final changes = RecipeDiff.between(a, b);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Versionen vergleichen')),
      body: FutureBuilder<(RecipeSnapshotV1, RecipeSnapshotV1, List<RecipeChange>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.error.toString()),
                  TextButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }
          final (a, b, changes) = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _SnapshotColumn(title: 'A', snapshot: a)),
                    const VerticalDivider(),
                    Expanded(child: _SnapshotColumn(title: 'B', snapshot: b)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: changes.isEmpty
                    ? const Center(child: Text('Keine Unterschiede.'))
                    : _ChangeList(changes: changes),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: (_applying || changes.isEmpty) ? null : () => _apply(changes),
                    child: const Text('Als neuen Entwurf übernehmen'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SnapshotColumn extends StatelessWidget {
  final String title;
  final RecipeSnapshotV1 snapshot;

  const _SnapshotColumn({required this.title, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(snapshot.recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final ingredient in snapshot.ingredients)
            Text('${ingredient.name}: ${ingredient.quantity} ${ingredient.unit}'),
          const SizedBox(height: 8),
          for (final step in snapshot.steps) Text('${step.position}. ${step.instruction}'),
        ],
      ),
    );
  }
}

class _ChangeList extends StatelessWidget {
  final List<RecipeChange> changes;

  const _ChangeList({required this.changes});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    _ChangeCategory? currentCategory;
    for (final change in changes) {
      final category = _categoryOf(change);
      if (category != currentCategory) {
        currentCategory = category;
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(_categoryLabel(category), style: const TextStyle(fontWeight: FontWeight.bold)),
        ));
      }
      items.add(ListTile(dense: true, title: Text(_describe(change))));
    }
    return ListView(children: items);
  }
}
