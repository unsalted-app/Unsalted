// lib/src/ui/recipe_editor/recipe_create_screen.dart
//
// Bildschirm 2 (Kapitel 22, Schritt 8.2): Rezept erstellen (Titel +
// Beschreibung). Speichert ausschließlich über
// RecipeRepository.createRecipe (Kapitel 16.1); keine direkte DB-Abfrage.
//
// WEITERLEITUNG ZUM DRAFT-EDITOR (Arbeitskarte 8.2 §13, jetzt eingelöst
// durch recipe_editor_screen.dart aus Schritt 8.3): ohne expliziten
// `onCreated`-Callback ersetzt dieser Screen sich selbst durch
// RecipeEditorScreen für die neu angelegte Draft-Version. Der Callback
// bleibt als Erweiterungspunkt bestehen (z. B. für Tests, die recipeId/
// versionId ohne echtes Editor-Rendering prüfen wollen), ohne dass
// `recipe_list_screen.dart` (außerhalb des Dateiscopes von Schritt 8.3)
// angefasst werden muss.
//
// Seit Teil 1.2 (C17) aus Design-Komponenten: FormPageTemplate, Abschnitt
// sections/recipe_create_fields_section.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/core_exceptions.dart';
import '../../contracts/input_models.dart';
import '../../providers/core_providers.dart';
import 'recipe_editor_screen.dart';
import 'sections/recipe_create_fields_section.dart';

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
    return showAppConfirmDialog(
      context,
      title: 'Änderungen verwerfen?',
      message: 'Deine Eingaben sind noch nicht gespeichert.',
      confirmLabel: 'Verwerfen',
      cancelLabel: 'Abbrechen',
    );
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
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder: (_) => RecipeEditorScreen(recipeId: recipeId, versionId: versionId),
          ));
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
      child: FormPageTemplate(
        title: 'Rezept erstellen',
        body: FormSections(
          children: [
            RecipeCreateFieldsSection(
              titleController: _titleController,
              descriptionController: _descriptionController,
              titleError: _titleController.text.isEmpty || _isTitleValid ? null : 'Titel muss 1–200 Zeichen lang sein',
            ),
            if (_saveError != null)
              AppPadding.only(top: AppSpace.l, child: AppText(_saveError!, tone: AppTone.error)),
          ],
        ),
        primaryAction: AppFab(
          icon: AppIcons.check,
          tooltip: 'Rezept speichern',
          loading: _saving,
          onPressed: _isTitleValid ? _save : null,
        ),
      ),
    );
  }
}
