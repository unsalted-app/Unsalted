// lib/src/ui/foods/food_editor_screen.dart
//
// Bildschirm 10 (Kapitel 22, Schritt 8.1): Verpackungsformular, Erstellen
// und Bearbeiten. Liest/schreibt ausschließlich über FoodRepository
// (Kapitel 16.2) -- kein Datenbankzugriff, keine eigene Nährwertberechnung.
// Natrium -> Salz-Umrechnung (Kapitel 8.2) geschieht bereits in
// package_form.dart; hier wird nur der fertige Wert übernommen.
// Zurück mit ungespeicherten Änderungen fragt vor dem Verwerfen nach
// (Kapitel 22, allgemeine Regel; Nachtrag 10.0) -- gleiches Muster wie
// recipe_create_screen.dart.
// Beim Bearbeiten im AppBar-Menü „Löschen“ (Teil 1.1b): zurück zur Liste,
// dort 5 s „Rückgängig“, erst dann softDeleteVariant; ungespeicherte
// Änderungen sind damit hinfällig, deshalb ohne Verwerfen-Dialog.
// Seit Teil 1.2 (C24) aus Design-Komponenten: FormPageTemplate; Formular in
// package_form.dart mit Abschnitten unter sections/.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/core_exceptions.dart';
import '../../contracts/input_models.dart';
import '../../food/food_variant.dart';
import '../../providers/core_providers.dart';
import '../shared/undoable_deletion.dart';
import 'package_form.dart';

class FoodEditorScreen extends ConsumerStatefulWidget {
  /// `null` -> Erstellen (Bildschirm `/foods/new`); sonst Bearbeiten
  /// (`/foods/:id`).
  final String? foodId;

  const FoodEditorScreen({super.key, this.foodId});

  @override
  ConsumerState<FoodEditorScreen> createState() => _FoodEditorScreenState();
}

class _FoodEditorScreenState extends ConsumerState<FoodEditorScreen> {
  final _formKey = GlobalKey<PackageFormState>();
  late Future<FoodVariant?> _loadFuture;
  FoodVariant? _existing;
  bool _saving = false;
  bool _leaving = false;
  String? _saveError;

  bool get _isEditing => widget.foodId != null;

  bool get _hasUnsavedChanges => !_leaving && (_formKey.currentState?.hasChanges ?? false);

  Future<bool> _confirmDiscard() async {
    return showAppConfirmDialog(
      context,
      title: 'Änderungen verwerfen?',
      message: 'Deine Eingaben sind noch nicht gespeichert.',
      confirmLabel: 'Verwerfen',
      cancelLabel: 'Abbrechen',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<FoodVariant?> _load() async {
    final id = widget.foodId;
    if (id == null) return null;
    final variant = await ref.read(foodRepositoryProvider).getById(id);
    _existing = variant;
    return variant;
  }

  Future<void> _save() async {
    final value = _formKey.currentState?.value;
    if (value == null) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      final repo = ref.read(foodRepositoryProvider);
      if (_isEditing) {
        final existing = _existing!;
        await repo.updateVariant(existing.copyWith(
          name: value.name,
          brand: value.brand,
          barcode: value.barcode,
          densityGPerMl: value.densityGPerMl,
          gramsPerPiece: value.gramsPerPiece,
          servingSizeG: value.servingSizeG,
          nutrients: value.nutrients,
        ));
      } else {
        await repo.createVariant(NewFoodVariant(
          name: value.name,
          brand: value.brand,
          barcode: value.barcode,
          source: FoodSource.custom,
          sourceRef: null,
          densityGPerMl: value.densityGPerMl,
          gramsPerPiece: value.gramsPerPiece,
          servingSizeG: value.servingSizeG,
          nutrients: value.nutrients,
        ));
      }
      if (!mounted) return;
      // canPop kommt aus dem zuletzt gebauten PopScope: erst den Frame mit
      // _leaving = true bauen, dann schließen (CLAUDE.md Abschnitt 4).
      setState(() => _leaving = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } on ValidationException catch (e) {
      setState(() => _saveError = e.message);
    } on NotFoundException catch (e) {
      setState(() => _saveError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _delete() {
    final existing = _existing;
    if (existing == null) return;
    // Wie beim Speichern: erst den Frame mit _leaving = true bauen, dann
    // schließen (CLAUDE.md Abschnitt 4).
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
      deleteFoodWithUndo(context, ref, existing);
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _confirmDiscard();
        if (!mounted) return;
        if (shouldDiscard) {
          setState(() => _leaving = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop();
          });
        }
      },
      child: _buildScaffold(buildContext),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return FormPageTemplate(
      title: _isEditing ? 'Lebensmittel bearbeiten' : 'Lebensmittel anlegen',
      actions: [
        if (_isEditing)
          AppOverflowMenu(entries: [
            AppMenuEntry(label: 'Löschen', enabled: _existing != null, onSelected: _delete),
          ]),
      ],
      messages: [if (_saveError != null) AppText(_saveError!, tone: AppTone.error)],
      body: FutureBuilder<FoodVariant?>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoading();
          }
          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              retryLabel: 'Erneut versuchen',
              onRetry: () => setState(() => _loadFuture = _load()),
            );
          }
          if (_isEditing && _existing == null) {
            return const AppErrorState(message: 'Lebensmittel nicht gefunden.');
          }

          final PackageFormValue? initial = _existing == null
              ? null
              : (
                  name: _existing!.name,
                  brand: _existing!.brand,
                  barcode: _existing!.barcode,
                  densityGPerMl: _existing!.densityGPerMl,
                  gramsPerPiece: _existing!.gramsPerPiece,
                  servingSizeG: _existing!.servingSizeG,
                  nutrients: _existing!.nutrients,
                );

          return PackageForm(
            key: _formKey,
            initial: initial,
            onChanged: () => setState(() {}),
          );
        },
      ),
      primaryAction: AppFab(
        icon: AppIcons.check,
        tooltip: 'Lebensmittel speichern',
        loading: _saving,
        onPressed: _formKey.currentState?.value == null ? null : _save,
      ),
    );
  }
}
