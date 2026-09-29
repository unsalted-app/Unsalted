// lib/src/ui/foods/food_editor_screen.dart
//
// Bildschirm 10 (Kapitel 22, Schritt 8.1): Verpackungsformular, Erstellen
// und Bearbeiten. Liest/schreibt ausschließlich über FoodRepository
// (Kapitel 16.2) -- kein Datenbankzugriff, keine eigene Nährwertberechnung.
// Natrium -> Salz-Umrechnung (Kapitel 8.2) geschieht bereits in
// package_form.dart; hier wird nur der fertige Wert übernommen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/core_exceptions.dart';
import '../../contracts/input_models.dart';
import '../../food/food_variant.dart';
import '../../providers/core_providers.dart';
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
  String? _saveError;

  bool get _isEditing => widget.foodId != null;

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
      if (mounted) Navigator.of(context).pop();
    } on ValidationException catch (e) {
      setState(() => _saveError = e.message);
    } on NotFoundException catch (e) {
      setState(() => _saveError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Lebensmittel bearbeiten' : 'Lebensmittel anlegen')),
      body: FutureBuilder<FoodVariant?>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _loadFuture = _load()),
            );
          }
          if (_isEditing && _existing == null) {
            return const _ErrorState(message: 'Lebensmittel nicht gefunden.');
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

          return Column(
            children: [
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_saveError!, style: const TextStyle(color: Colors.red)),
                ),
              Expanded(
                child: PackageForm(
                  key: _formKey,
                  initial: initial,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_saving || _formKey.currentState?.value == null) ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.check),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Erneut versuchen')),
        ],
      ),
    );
  }
}
