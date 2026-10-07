// lib/src/ui/recipe_editor/ingredient_row.dart
//
// Bildschirm 3 (Kapitel 22, Schritt 8.3): eine Zutatenzeile im Rezept-
// Editor. Name (mit Verknüpfen-Aktion über FoodRepository.search, "Auto-
// complete"), Menge, Einheit-Dropdown aus UnitCatalog, Notiz. Reine
// Formularlogik -- keine eigene Nährwertberechnung, kein Speichern; der
// Aufrufer (recipe_editor_screen.dart) liest den aktuellen Wert über
// [onChanged] und baut daraus RecipeVersionDraft. Seit Teil 1.2 (C25) aus
// Design-Komponenten; der Auswahldialog liegt in
// food_variant_picker_dialog.dart.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../food/food_variant.dart';
import '../../nutrition/unit_catalog.dart';
import '../../providers/core_providers.dart';
import 'food_variant_picker_dialog.dart';

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
    final selected = await showAppDialog<FoodVariant>(context, (context) => FoodVariantPickerDialog(repo: repo));
    if (selected == null) return;
    setState(() {
      _nameController.text = selected.name;
    });
    _emit((d) => d.copyWith(variant: () => selected, displayName: selected.name));
  }

  @override
  Widget build(BuildContext context) {
    return AppPadding.symmetric(
      vertical: AppSpace.xs,
      child: AppStack(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const AppIcon(AppIcons.dragHandle),
          const AppGap(AppSpace.s),
          Expanded(
            flex: 3,
            child: AppTextField(
              controller: _nameController,
              enabled: !widget.readOnly,
              label: 'Name',
              helper: widget.data.hasUnresolvedVariant ? deletedVariantHint : null,
              helperTone: AppTone.error,
              suffix: widget.readOnly
                  ? null
                  : AppIconButton(icon: AppIcons.search, tooltip: 'Lebensmittel verknüpfen', onPressed: _pickVariant),
              onChanged: (value) {
                // Freie Texteingabe löst eine zuvor verknüpfte Variante,
                // weil der angezeigte Name nicht mehr zu ihr passt.
                _emit((d) => d.copyWith(displayName: value, variant: () => null));
              },
            ),
          ),
          const AppGap(AppSpace.s),
          Expanded(
            child: AppTextField(
              controller: _quantityController,
              enabled: !widget.readOnly,
              label: 'Menge',
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
          const AppGap(AppSpace.s),
          AppSelect<String>(
            value: widget.data.unitCode,
            onChanged: widget.readOnly ? null : (value) => _emit((d) => d.copyWith(unitCode: value)),
            items: [for (final unit in UnitCatalog.all) AppSelectItem(unit.code, unit.code)],
          ),
          const AppGap(AppSpace.s),
          Expanded(
            child: AppTextField(
              controller: _noteController,
              enabled: !widget.readOnly,
              label: 'Notiz',
              onChanged: (value) {
                _emit((d) => d.copyWith(note: () => value.trim().isEmpty ? null : value));
              },
            ),
          ),
          if (!widget.readOnly)
            AppIconButton(icon: AppIcons.deleteOutline, tooltip: 'Zutat entfernen', onPressed: widget.onRemove),
        ],
      ),
    );
  }
}
