// lib/src/ui/foods/food_list_screen.dart
//
// Bildschirm 9 (Kapitel 22, Schritt 8.1): Lebensmittel-Liste mit Suche.
// Datenquelle ausschließlich FoodRepository.search (Kapitel 16.2).
// Nach links wischen löscht ein Lebensmittel mit 5 s „Rückgängig“
// (Teil 1.1b, shared/undoable_deletion.dart); ausstehende Löschungen sind
// sofort ausgeblendet. Seit Teil 1.2 (C15) aus Design-Komponenten:
// ListPageTemplate, Abschnitte unter sections/, Baustein FoodTile.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../food/food_variant.dart';
import '../../providers/core_providers.dart';
import '../shared/undoable_deletion.dart';
import 'food_editor_screen.dart';
import 'sections/food_list_empty_section.dart';
import 'sections/food_list_results_section.dart';
import 'sections/food_list_search_section.dart';

class FoodListScreen extends ConsumerStatefulWidget {
  const FoodListScreen({super.key});

  @override
  ConsumerState<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends ConsumerState<FoodListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor({String? foodId}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => FoodEditorScreen(foodId: foodId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(foodRepositoryProvider);
    final hidden = ref.watch(pendingFoodDeletionsProvider);

    return ListPageTemplate(
      title: 'Lebensmittel',
      search: FoodListSearchSection(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
      ),
      body: StreamBuilder<List<FoodVariant>>(
        stream: repo.search(_query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const AppLoading();
          }
          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              retryLabel: 'Erneut versuchen',
              onRetry: () => setState(() {}),
            );
          }

          final variants =
              (snapshot.data ?? const <FoodVariant>[]).where((v) => !hidden.contains(v.id)).toList();
          if (variants.isEmpty) {
            return FoodListEmptySection(onCreate: () => _openEditor());
          }

          return FoodListResultsSection(
            variants: variants,
            onOpen: (variant) => _openEditor(foodId: variant.id),
            onDelete: (variant) => deleteFoodWithUndo(context, ref, variant),
          );
        },
      ),
      primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neues Lebensmittel', onPressed: () => _openEditor()),
    );
  }
}
