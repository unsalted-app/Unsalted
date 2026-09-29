// lib/src/ui/recipe_editor/recipe_create_screen.dart
//
// Bildschirm 2 (Kapitel 22, Schritt 8.2): Rezept erstellen (Titel +
// Beschreibung). Speichert ausschließlich über
// RecipeRepository.createRecipe (Kapitel 16.1); keine direkte DB-Abfrage.
//
// WEITERLEITUNG ZUM DRAFT-EDITOR: Der Editor selbst (`recipe_editor_screen.dart`)
// ist erst Schritt 8.3 -- Arbeitskarte 8.2 §7/§12 verbieten Editor-Logik
// in diesem Schritt ausdrücklich ("keine Editor-Logik außer dem
// Erstellungsbildschirm"). Damit "ein neu angelegtes Rezept führt auf
// seinen Draft-Editor" (Arbeitskarte 8.2 §13) trotzdem erfüllbar bleibt,
// sobald 8.3 existiert, nimmt dieser Screen einen optionalen `onCreated`-
// Callback entgegen. Ohne Callback (Standardfall in diesem Schritt) wird
// nach dem Speichern einfach zurücknavigiert; ein späterer Schritt kann
// beim Aufruf dieses Screens einen Callback übergeben, der stattdessen zum
// Editor der neuen Draft-Version weiterleitet, ohne diese Datei zu ändern.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/core_exceptions.dart';
import '../../contracts/input_models.dart';
import '../../providers/core_providers.dart';

class RecipeCreateScreen extends ConsumerStatefulWidget {
  /// Wird nach erfolgreichem Anlegen mit (recipeId, versionId der neuen
  /// Draft-Version) aufgerufen, statt einfach zurückzunavigieren.
  final void Function(BuildContext context, String recipeId, String versionId)? onCreated;

  const RecipeCreateScreen({super.key, this.onCreated});

  @override
  ConsumerState<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends ConsumerState<RecipeCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;
  bool _saved = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isTitleValid {
    final length = _titleController.text.trim().length;
    return length >= 1 && length <= 200;
  }

  bool get _hasUnsavedInput =>
      !_saved &&
      (_titleController.text.trim().isNotEmpty || _descriptionController.text.trim().isNotEmpty);

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedInput) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Änderungen verwerfen?'),
        content: const Text('Deine Eingaben sind noch nicht gespeichert.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwerfen'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    if (!_isTitleValid) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      final repo = ref.read(recipeRepositoryProvider);
      final description = _descriptionController.text.trim();
      final recipeId = await repo.createRecipe(NewRecipe(
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
      ));
      final versions = await repo.watchVersions(recipeId).first;
      final versionId = versions.first.id;

      if (!mounted) return;
      // PopScope.canPop wird aus dem `canPop:`-Parameter des zuletzt
      // GEBAUTEN PopScope-Widgets gelesen, nicht live aus _hasUnsavedInput
      // -- setState allein reicht nicht, weil Flutter Rebuilds erst zum
      // nächsten Frame anwendet. addPostFrameCallback wartet, bis der
      // Frame mit _saved = true tatsächlich gebaut wurde, bevor gepoppt
      // wird; sonst blockiert die eigene Verwerfen-Sperre den Pop, den wir
      // hier selbst auslösen.
      setState(() => _saved = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.onCreated != null) {
          widget.onCreated!(context, recipeId, versionId);
        } else {
          Navigator.of(context).pop(recipeId);
        }
      });
    } on ValidationException catch (e) {
      setState(() => _saveError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return PopScope(
      canPop: !_hasUnsavedInput,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _confirmDiscard();
        if (!mounted) return;
        if (shouldDiscard) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Rezept erstellen')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titel',
                errorText: _titleController.text.isEmpty || _isTitleValid
                    ? null
                    : 'Titel muss 1–200 Zeichen lang sein',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
              maxLines: 4,
            ),
            if (_saveError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_saveError!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (_saving || !_isTitleValid) ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check),
        ),
      ),
    );
  }
}
