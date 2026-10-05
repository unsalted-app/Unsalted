// lib/src/ui/recipe_editor/recipe_editor_screen.dart
//
// Bildschirm 3 (Kapitel 22, Schritt 8.3): Draft-Editor mit Live-Vorschau.
// Zutaten/Schritte/Parameter werden ausschließlich lokal im Widget-State
// gehalten (UI-State ist kein Persistenz-State, Arbeitskarte §9) und erst
// beim Speichern als RecipeVersionDraft an RecipeRepository.saveDraft
// übergeben. Live-Nährwerte über NutritionService.preview (reine, lokale
// Berechnung ohne DB-Zugriff) -- keine eigene Nährwertberechnung im
// Widget. Bei state = snapshot ist der Editor schreibgeschützt; einzige
// Aktion ist createDraftFrom.
//
// Die volle formatierte Nährwerttabelle (Bildschirm 5) ist erst Schritt
// 8.4 (eigene Dateien nutrition_header.dart/nutrition_table.dart) -- hier
// nur eine knappe Vorschauzeile über NutritionFormatter.formatKcal.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../contracts/core_exceptions.dart';
import '../../contracts/input_models.dart';
import '../../food/food_variant.dart';
import '../../nutrition/nutrition_formatter.dart';
import '../../nutrition/nutrition_result.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe_ingredient.dart';
import '../../recipe/recipe_step.dart';
import '../../recipe/recipe_version.dart';
import 'ingredient_row.dart';

/// Anzeige eines gespeicherten Timers im Eingabefeld: ganze Minuten als
/// Zahl, sonst m:ss (z. B. importierte 90 s → "1:30").
String _timerInputText(int? seconds) {
  if (seconds == null) return '';
  if (seconds % 60 == 0) return '${seconds ~/ 60}';
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// Fehlerbehebung 9.2a, Befund 1: [timerSeconds] wird nur durch eine
/// Eingabe überschrieben. Steht im Feld wieder der Ausgangstext, gilt der
/// geladene Wert sekundengenau.
class _StepRowData {
  final String id;
  final String instruction;
  final int? timerSeconds;
  final int? loadedTimerSeconds;
  final bool timerInvalid;

  const _StepRowData({
    required this.id,
    required this.instruction,
    this.timerSeconds,
    this.loadedTimerSeconds,
    this.timerInvalid = false,
  });

  _StepRowData copyWith({String? instruction}) => _StepRowData(
        id: id,
        instruction: instruction ?? this.instruction,
        timerSeconds: timerSeconds,
        loadedTimerSeconds: loadedTimerSeconds,
        timerInvalid: timerInvalid,
      );

  /// Ganze Minuten > 0 → Minuten × 60; leer → kein Timer; sonst ungültig.
  _StepRowData withTimerInput(String input) {
    final text = input.trim();
    int? seconds;
    var invalid = false;
    if (text == _timerInputText(loadedTimerSeconds)) {
      seconds = loadedTimerSeconds;
    } else if (text.isNotEmpty) {
      final minutes = int.tryParse(text);
      if (minutes == null || minutes <= 0) {
        invalid = true;
        seconds = timerSeconds;
      } else {
        seconds = minutes * 60;
      }
    }
    return _StepRowData(
      id: id,
      instruction: instruction,
      timerSeconds: seconds,
      loadedTimerSeconds: loadedTimerSeconds,
      timerInvalid: invalid,
    );
  }
}

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final String versionId;

  const RecipeEditorScreen({super.key, required this.recipeId, required this.versionId});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  static const Uuid _uuid = Uuid();

  late Future<RecipeVersion?> _loadFuture;
  RecipeVersion? _version;

  List<IngredientRowData> _ingredients = [];
  List<_StepRowData> _steps = [];
  final _servingsController = TextEditingController();
  final _bakingLossController = TextEditingController();
  final _finalWeightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _saving = false;
  bool _freezing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  @override
  void dispose() {
    _servingsController.dispose();
    _bakingLossController.dispose();
    _finalWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<RecipeVersion?> _load() async {
    final version = await ref.read(recipeRepositoryProvider).getVersion(widget.versionId);
    if (version == null) return null;
    _version = version;
    if (version.state == VersionState.draft) {
      await _seedEditableState(version);
    }
    return version;
  }

  Future<void> _seedEditableState(RecipeVersion version) async {
    final foodRepo = ref.read(foodRepositoryProvider);
    final resolved = <String, FoodVariant>{};
    for (final ingredient in version.ingredients) {
      final id = ingredient.foodVariantId;
      if (id != null && !resolved.containsKey(id)) {
        final variant = await foodRepo.getById(id);
        if (variant != null) resolved[id] = variant;
      }
    }

    _ingredients = version.ingredients
        .map((i) => IngredientRowData(
              id: i.id,
              foodVariantId: i.foodVariantId,
              variant: i.foodVariantId == null ? null : resolved[i.foodVariantId],
              displayName: i.displayName,
              quantity: i.quantity,
              unitCode: i.unitCode,
              note: i.note,
            ))
        .toList();
    _steps = version.steps
        .map((s) => _StepRowData(
              id: s.id,
              instruction: s.instruction,
              timerSeconds: s.timerSeconds,
              loadedTimerSeconds: s.timerSeconds,
            ))
        .toList();
    _servingsController.text = version.servings?.toString() ?? '';
    _bakingLossController.text = version.bakingLossPercent.toString();
    _finalWeightController.text = version.finalWeightOverrideG?.toString() ?? '';
    _notesController.text = version.notes ?? '';
  }

  Decimal get _bakingLossPercent =>
      Decimal.tryParse(_bakingLossController.text.trim().replaceAll(',', '.')) ?? Decimal.zero;

  Decimal? get _finalWeightOverrideG {
    final text = _finalWeightController.text.trim();
    if (text.isEmpty) return null;
    return Decimal.tryParse(text.replaceAll(',', '.'));
  }

  int? get _servings {
    final text = _servingsController.text.trim();
    return text.isEmpty ? null : int.tryParse(text);
  }

  NutritionResult? get _preview {
    if (_ingredients.isEmpty) return null;
    final inputs = _ingredients
        .map((row) => IngredientInput(
              displayName: row.displayName,
              quantity: row.quantity,
              unitCode: row.unitCode,
              variant: row.variant,
            ))
        .toList();
    return ref.read(nutritionServiceProvider).preview(
          ingredients: inputs,
          bakingLossPercent: _bakingLossPercent,
          finalWeightOverrideG: _finalWeightOverrideG,
          servings: _servings,
        );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final ingredients = <RecipeIngredient>[
        for (var i = 0; i < _ingredients.length; i++)
          RecipeIngredient(
            id: _ingredients[i].id,
            versionId: widget.versionId,
            position: i + 1,
            foodVariantId: _ingredients[i].foodVariantId,
            displayName: _ingredients[i].displayName,
            quantity: _ingredients[i].quantity,
            unitCode: _ingredients[i].unitCode,
            note: _ingredients[i].note,
          ),
      ];
      final steps = <RecipeStep>[
        for (var i = 0; i < _steps.length; i++)
          RecipeStep(
            id: _steps[i].id,
            versionId: widget.versionId,
            position: i + 1,
            instruction: _steps[i].instruction,
            timerSeconds: _steps[i].timerSeconds,
          ),
      ];

      final draft = RecipeVersionDraft(
        id: widget.versionId,
        recipeId: widget.recipeId,
        parentVersionId: _version!.parentVersionId,
        versionIndex: _version!.versionIndex,
        label: _version!.label,
        servings: _servings,
        bakingLossPercent: _bakingLossPercent,
        finalWeightOverrideG: _finalWeightOverrideG,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        ingredients: ingredients,
        steps: steps,
      );

      await ref.read(recipeRepositoryProvider).saveDraft(draft);
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } on SnapshotImmutableException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _freeze() async {
    setState(() {
      _freezing = true;
      _error = null;
    });
    try {
      await ref.read(recipeRepositoryProvider).snapshotVersion(widget.versionId);
      if (mounted) setState(() => _loadFuture = _load());
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } on IllegalStateException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _freezing = false);
    }
  }

  Future<void> _createDraftFromSnapshot() async {
    final newVersionId = await ref.read(recipeRepositoryProvider).createDraftFrom(widget.versionId);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => RecipeEditorScreen(recipeId: widget.recipeId, versionId: newVersionId),
    ));
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientRowData(
        id: _uuid.v4(),
        displayName: '',
        quantity: Decimal.zero,
        unitCode: 'g',
      ));
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(_StepRowData(id: _uuid.v4(), instruction: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezept bearbeiten')),
      body: FutureBuilder<RecipeVersion?>(
        future: _loadFuture,
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
                    onPressed: () => setState(() => _loadFuture = _load()),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }
          final version = snapshot.data;
          if (version == null) {
            return const Center(child: Text('Version nicht gefunden.'));
          }
          if (version.state == VersionState.snapshot) {
            return _buildReadOnly(version);
          }
          return _buildEditable();
        },
      ),
    );
  }

  Widget _buildReadOnly(RecipeVersion version) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Expanded(child: Text('Eingefroren — als neuen Entwurf kopieren?')),
              TextButton(
                onPressed: _createDraftFromSnapshot,
                child: const Text('Kopieren'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final ingredient in version.ingredients)
          ListTile(
            title: Text(ingredient.displayName),
            subtitle: Text('${ingredient.quantity} ${ingredient.unitCode}'),
          ),
        const Divider(),
        for (final step in version.steps)
          ListTile(title: Text(step.instruction)),
      ],
    );
  }

  Widget _buildEditable() {
    final preview = _preview;

    return Column(
      children: [
        if (preview != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Text(
              'Gesamt: ${NutritionFormatter.formatKcal(preview.total.energyKcal, isIncomplete: preview.incomplete.contains('energy_kcal'))}',
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Portionen'),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _bakingLossController,
                decoration: const InputDecoration(labelText: 'Backverlust (%)'),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _finalWeightController,
                decoration: const InputDecoration(labelText: 'Fertiggewicht-Override (g)'),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notizen'),
                maxLines: 3,
              ),
              const Divider(height: 32),
              const Text('Zutaten', style: TextStyle(fontWeight: FontWeight.bold)),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final item = _ingredients.removeAt(oldIndex);
                    _ingredients.insert(newIndex, item);
                  });
                },
                children: [
                  for (final row in _ingredients)
                    IngredientRow(
                      key: ValueKey(row.id),
                      data: row,
                      onChanged: (updated) {
                        setState(() {
                          final index = _ingredients.indexWhere((r) => r.id == updated.id);
                          _ingredients[index] = updated;
                        });
                      },
                      onRemove: () {
                        setState(() => _ingredients.removeWhere((r) => r.id == row.id));
                      },
                    ),
                ],
              ),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Zutat hinzufügen'),
              ),
              const Divider(height: 32),
              const Text('Schritte', style: TextStyle(fontWeight: FontWeight.bold)),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final item = _steps.removeAt(oldIndex);
                    _steps.insert(newIndex, item);
                  });
                },
                children: [
                  for (final step in _steps)
                    Padding(
                      key: ValueKey(step.id),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_handle),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: step.instruction,
                              decoration: const InputDecoration(labelText: 'Anweisung'),
                              onChanged: (value) {
                                setState(() {
                                  final index = _steps.indexWhere((s) => s.id == step.id);
                                  _steps[index] = _steps[index].copyWith(instruction: value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              initialValue: _timerInputText(step.loadedTimerSeconds),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Timer (Min.)',
                                errorText: step.timerInvalid ? 'Ganze Minuten > 0' : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  final index = _steps.indexWhere((s) => s.id == step.id);
                                  _steps[index] = _steps[index].withTimerInput(value);
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() => _steps.removeWhere((s) => s.id == step.id));
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: const Text('Schritt hinzufügen'),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _freezing ? null : _freeze,
                    child: const Text('Einfrieren'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving || _steps.any((s) => s.timerInvalid) ? null : _save,
                    child: const Text('Speichern'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
