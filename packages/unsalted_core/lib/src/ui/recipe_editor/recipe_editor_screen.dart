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
//
// Seit Teil 1.2 (C25) aus Design-Komponenten: FormPageTemplate mit
// Vorschauleiste und Aktionsleiste, Abschnitte unter sections/, Bausteine
// IngredientRow, StepRow (mit den bisher hier privaten Schrittdaten) und
// FoodVariantPickerDialog.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:uuid/uuid.dart';

import '../../contracts/core_exceptions.dart';
import '../../contracts/input_models.dart';
import '../../food/food_variant.dart';
import '../../nutrition/nutrition_result.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe_ingredient.dart';
import '../../recipe/recipe_step.dart';
import '../../recipe/recipe_version.dart';
import '../config/core_ui_options.dart';
import '../shared/unit_labels.dart';
import 'ingredient_row.dart';
import 'sections/recipe_editor_actions_section.dart';
import 'sections/recipe_editor_frozen_section.dart';
import 'sections/recipe_editor_ingredients_section.dart';
import 'sections/recipe_editor_parameters_section.dart';
import 'sections/recipe_editor_preview_section.dart';
import 'sections/recipe_editor_steps_section.dart';
import 'step_row.dart';

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
  List<StepRowData> _steps = [];
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
        .map((s) => StepRowData(
              id: s.id,
              instruction: s.instruction,
              timerSeconds: s.timerSeconds,
              loadedTimerSeconds: s.timerSeconds,
            ))
        .toList();
    _servingsController.text = version.servings?.toString() ?? '';
    _bakingLossController.text = formatQuantity(version.bakingLossPercent);
    _finalWeightController.text =
        version.finalWeightOverrideG == null ? '' : formatQuantity(version.finalWeightOverrideG!);
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
      _steps.add(StepRowData(id: _uuid.v4(), instruction: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Rezept bearbeiten';
    return FutureBuilder<RecipeVersion?>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const FormPageTemplate(title: title, body: AppLoading());
        }
        if (snapshot.hasError) {
          return FormPageTemplate(
            title: title,
            body: AppErrorState(
              message: snapshot.error.toString(),
              retryLabel: 'Erneut versuchen',
              onRetry: () => setState(() => _loadFuture = _load()),
            ),
          );
        }
        final version = snapshot.data;
        if (version == null) {
          return const FormPageTemplate(title: title, body: AppEmptyState(message: 'Version nicht gefunden.'));
        }
        if (version.state == VersionState.snapshot) {
          return FormPageTemplate(
            title: title,
            body: FormSections(
              children: [RecipeEditorFrozenSection(version: version, onCopy: _createDraftFromSnapshot)],
            ),
          );
        }
        return _buildEditable(title);
      },
    );
  }

  Widget _buildEditable(String title) {
    final preview = _preview;

    return FormPageTemplate(
      title: title,
      header: preview == null ? null : RecipeEditorPreviewSection(preview: preview),
      messages: [if (_error != null) AppText(_error!, tone: AppTone.error)],
      body: FormSections(
        children: [
          RecipeEditorParametersSection(
            servings: _servingsController,
            bakingLoss: _bakingLossController,
            finalWeight: _finalWeightController,
            notes: _notesController,
            onChanged: () => setState(() {}),
            showAdvanced: ref.watch(coreUiOptionsProvider).showAdvancedFields,
          ),
          RecipeEditorIngredientsSection(
            rows: _ingredients,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final item = _ingredients.removeAt(oldIndex);
                _ingredients.insert(newIndex, item);
              });
            },
            onRowChanged: (updated) {
              setState(() {
                final index = _ingredients.indexWhere((r) => r.id == updated.id);
                _ingredients[index] = updated;
              });
            },
            onRowRemoved: (id) => setState(() => _ingredients.removeWhere((r) => r.id == id)),
            onAdd: _addIngredient,
          ),
          RecipeEditorStepsSection(
            steps: _steps,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final item = _steps.removeAt(oldIndex);
                _steps.insert(newIndex, item);
              });
            },
            onInstructionChanged: (id, value) {
              setState(() {
                final index = _steps.indexWhere((s) => s.id == id);
                _steps[index] = _steps[index].copyWith(instruction: value);
              });
            },
            onTimerChanged: (id, value) {
              setState(() {
                final index = _steps.indexWhere((s) => s.id == id);
                _steps[index] = _steps[index].withTimerInput(value);
              });
            },
            onRemoved: (id) => setState(() => _steps.removeWhere((s) => s.id == id)),
            onAdd: _addStep,
          ),
        ],
      ),
      bottomBar: RecipeEditorActionsSection(
        onFreeze: _freezing ? null : _freeze,
        onSave: _saving || _steps.any((s) => s.timerInvalid) ? null : _save,
      ),
    );
  }
}
