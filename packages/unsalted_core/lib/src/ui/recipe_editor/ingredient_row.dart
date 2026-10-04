// lib/src/ui/recipe_editor/ingredient_row.dart
//
// Bildschirm 3 (Kapitel 22, Schritt 8.3): eine Zutatenzeile im Rezept-
// Editor. Name (mit Verknüpfen-Aktion über FoodRepository.search, "Auto-
// complete"), Menge, Einheit-Dropdown aus UnitCatalog, Notiz. Reine
// Formularlogik -- keine eigene Nährwertberechnung, kein Speichern; der
// Aufrufer (recipe_editor_screen.dart) liest den aktuellen Wert über
// [onChanged] und baut daraus RecipeVersionDraft.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/food_repository.dart';
import '../../food/food_variant.dart';
import '../../nutrition/unit_catalog.dart';
import '../../providers/core_providers.dart';

/// Zutatenzeile im UI-State des Editors. `id` ist stabil (Kapitel 10.7:
/// Upsert-/Soft-Delete-Delta braucht stabile IDs über mehrere saveDraft-
/// Aufrufe hinweg) -- neue Zeilen bekommen ihre ID beim Anlegen in
/// recipe_editor_screen.dart, nicht hier.
///
/// [foodVariantId] ist die gespeicherte Verknüpfung, [variant] das dazu
/// aufgelöste Lebensmittel für Vorschau und Anzeige. Ist das Lebensmittel
/// weich gelöscht, bleibt [foodVariantId] erhalten und [variant] ist `null`
/// (Kapitel 10.7; Fehlerbehebung 9.1b).
class IngredientRowData {
  final String id;
  final String? foodVariantId;
  final FoodVariant? variant;
  final String displayName;
  final Decimal quantity;
  final String unitCode;
  final String? note;

  /// Ohne [foodVariantId] gilt die ID von [variant].
  IngredientRowData({
    required this.id,
    String? foodVariantId,
    this.variant,
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    this.note,
  }) : foodVariantId = foodVariantId ?? variant?.id;

  /// Verknüpft, aber das Lebensmittel ist nicht mehr auflösbar (gelöscht).
  bool get hasUnresolvedVariant => foodVariantId != null && variant == null;

  /// [variant] ändert die Verknüpfung: [foodVariantId] folgt immer mit.
  /// Alle anderen Felder lassen die Verknüpfung unverändert.
  IngredientRowData copyWith({
    FoodVariant? Function()? variant,
    String? displayName,
    Decimal? quantity,
    String? unitCode,
    String? Function()? note,
  }) {
    final newVariant = variant != null ? variant() : this.variant;
    return IngredientRowData(
      id: id,
      foodVariantId: variant != null ? newVariant?.id : foodVariantId,
      variant: newVariant,
      displayName: displayName ?? this.displayName,
      quantity: quantity ?? this.quantity,
      unitCode: unitCode ?? this.unitCode,
      note: note != null ? note() : this.note,
    );
  }
}

const deletedVariantHint = 'Verknüpftes Lebensmittel wurde gelöscht – bitte neu auswählen.';

class IngredientRow extends ConsumerStatefulWidget {
  final IngredientRowData data;
  final ValueChanged<IngredientRowData> onChanged;
  final VoidCallback onRemove;
  final bool readOnly;

  const IngredientRow({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onRemove,
    this.readOnly = false,
  });

  @override
  ConsumerState<IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends ConsumerState<IngredientRow> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.displayName);
    _quantityController = TextEditingController(text: widget.data.quantity.toString());
    _noteController = TextEditingController(text: widget.data.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _emit(IngredientRowData Function(IngredientRowData) update) {
    widget.onChanged(update(widget.data));
  }

  Future<void> _pickVariant() async {
    final repo = ref.read(foodRepositoryProvider);
    final selected = await showDialog<FoodVariant>(
      context: context,
      builder: (context) => _FoodVariantPickerDialog(repo: repo),
    );
    if (selected == null) return;
    setState(() {
      _nameController.text = selected.name;
    });
    _emit((d) => d.copyWith(variant: () => selected, displayName: selected.name));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.drag_handle),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameController,
              enabled: !widget.readOnly,
              decoration: InputDecoration(
                labelText: 'Name',
                helperText: widget.data.hasUnresolvedVariant ? deletedVariantHint : null,
                helperMaxLines: 2,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
                suffixIcon: widget.readOnly
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Lebensmittel verknüpfen',
                        onPressed: _pickVariant,
                      ),
              ),
              onChanged: (value) {
                // Freie Texteingabe löst eine zuvor verknüpfte Variante,
                // weil der angezeigte Name nicht mehr zu ihr passt.
                _emit((d) => d.copyWith(displayName: value, variant: () => null));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _quantityController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(labelText: 'Menge'),
              onChanged: (value) {
                try {
                  final parsed = Decimal.parse(value.trim().replaceAll(',', '.'));
                  _emit((d) => d.copyWith(quantity: parsed));
                } on FormatException {
                  // Ungültige Eingabe -- letzter gültiger Wert bleibt
                  // erhalten, bis eine gültige Zahl eingegeben wird.
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: widget.data.unitCode,
            onChanged: widget.readOnly
                ? null
                : (value) {
                    if (value != null) _emit((d) => d.copyWith(unitCode: value));
                  },
            items: [
              for (final unit in UnitCatalog.all)
                DropdownMenuItem(value: unit.code, child: Text(unit.code)),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _noteController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(labelText: 'Notiz'),
              onChanged: (value) {
                _emit((d) => d.copyWith(note: () => value.trim().isEmpty ? null : value));
              },
            ),
          ),
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: widget.onRemove,
            ),
        ],
      ),
    );
  }
}

class _FoodVariantPickerDialog extends StatefulWidget {
  final FoodRepository repo;

  const _FoodVariantPickerDialog({required this.repo});

  @override
  State<_FoodVariantPickerDialog> createState() => _FoodVariantPickerDialogState();
}

class _FoodVariantPickerDialogState extends State<_FoodVariantPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lebensmittel verknüpfen'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Suchen …'),
              onChanged: (value) => setState(() => _query = value),
              autofocus: true,
            ),
            Expanded(
              child: StreamBuilder<List<FoodVariant>>(
                stream: widget.repo.search(_query),
                builder: (context, snapshot) {
                  final variants = snapshot.data ?? const <FoodVariant>[];
                  if (variants.isEmpty) {
                    return const Center(child: Text('Keine Treffer.'));
                  }
                  return ListView.builder(
                    itemCount: variants.length,
                    itemBuilder: (context, index) {
                      final variant = variants[index];
                      return ListTile(
                        title: Text(variant.name),
                        subtitle: variant.brand == null ? null : Text(variant.brand!),
                        onTap: () => Navigator.of(context).pop(variant),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}
