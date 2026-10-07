// lib/src/ui/recipe_editor/food_variant_picker_dialog.dart
//
// Fachlicher Baustein (Teil 1.2, aus ingredient_row.dart herausgelöst):
// Dialog „Lebensmittel verknüpfen“ — Suche über FoodRepository.search,
// Auswahl schließt den Dialog mit dem Lebensmittel, „Abbrechen“ mit `null`.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/food_repository.dart';
import '../../food/food_variant.dart';

/// Auswahldialog für ein Lebensmittel.
class FoodVariantPickerDialog extends StatefulWidget {
  /// Erzeugt den Dialog.
  const FoodVariantPickerDialog({super.key, required this.repo});

  /// Quelle der Suche.
  final FoodRepository repo;

  @override
  State<FoodVariantPickerDialog> createState() => _FoodVariantPickerDialogState();
}

class _FoodVariantPickerDialogState extends State<FoodVariantPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Lebensmittel verknüpfen',
      fixedContentSize: true,
      content: AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Ohne Lupe wie vor Teil 1.2 (kein AppSearchField).
          AppTextField(hint: 'Suchen …', autofocus: true, onChanged: (value) => setState(() => _query = value)),
          Expanded(
            child: StreamBuilder<List<FoodVariant>>(
              stream: widget.repo.search(_query),
              builder: (context, snapshot) {
                final variants = snapshot.data ?? const <FoodVariant>[];
                if (variants.isEmpty) {
                  return const AppEmptyState(message: 'Keine Treffer.');
                }
                return AppItemList.builder(
                  itemCount: variants.length,
                  itemBuilder: (context, index) {
                    final variant = variants[index];
                    return AppListItem(
                      title: variant.name,
                      subtitle: variant.brand,
                      onTap: () => Navigator.of(context).pop(variant),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        AppButton.tertiary(label: 'Abbrechen', onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
