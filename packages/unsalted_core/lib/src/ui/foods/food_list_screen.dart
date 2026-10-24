// lib/src/ui/foods/food_list_screen.dart
//
// Bildschirm 9 (Kapitel 22, Schritt 8.1): Lebensmittel-Liste mit Suche.
// Datenquelle ausschließlich FoodRepository.search (Kapitel 16.2).
// Nach links wischen löscht ein Lebensmittel mit 5 s „Rückgängig“
// (Teil 1.1b, shared/undoable_deletion.dart); ausstehende Löschungen sind
// sofort ausgeblendet. Seit Teil 1.2 (C15) aus Design-Komponenten:
// ListPageTemplate, Abschnitte unter sections/, Baustein FoodTile.
// Seit Teil 1.4 (T03, Figma Tablet „09+10“): ab `breakpoint-expanded` stehen
// Liste und Editor nebeneinander (`ListDetailTemplate`). Tippen wählt aus,
// „Neues Lebensmittel“ öffnet den Editor im Detailbereich; ohne Auswahl
// bleibt er leer (Punktraster). Speichern lässt den Bereich offen (nach dem
// Anlegen ist das neue Lebensmittel gewählt), Löschen und Verwerfen heben die
// Auswahl auf. Ein Auswahlwechsel mit ungespeicherten Änderungen fragt mit
// der Rückfrage aus 10.0. Darunter wie bisher `Navigator.push`. Routen
// unverändert (F8).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/food_repository.dart';
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

  /// Im Detailbereich geöffnetes Lebensmittel; `null` = keins.
  String? _selectedId;

  /// `true`: im Detailbereich wird ein neues Lebensmittel angelegt.
  bool _creating = false;

  /// Zählt die Abschlüsse im Detailbereich; ein neuer Wert lädt den Editor
  /// frisch (z. B. nach dem Speichern).
  int _round = 0;

  /// Ungespeicherte Änderungen im Editor des Detailbereichs.
  bool _detailDirty = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Nebeneinander: im Detailbereich öffnen (`null` = neues Lebensmittel),
  /// bei ungespeicherten Änderungen erst nachfragen; sonst als eigene Seite.
  Future<void> _openEditor({String? foodId}) async {
    if (!ListDetailTemplate.isSplit(context)) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => FoodEditorScreen(foodId: foodId),
      ));
      return;
    }
    final creating = foodId == null;
    if (creating == _creating && foodId == _selectedId) return;
    if (_detailDirty && !await FoodEditorScreen.confirmDiscard(context)) return;
    if (!mounted) return;
    setState(() {
      _creating = creating;
      _selectedId = foodId;
      _detailDirty = false;
    });
  }

  /// Der Editor im Detailbereich ist fertig: [id] gespeichert (bleibt
  /// gewählt) bzw. `null` nach Löschen oder Verwerfen.
  void _done(String? id) {
    setState(() {
      _creating = false;
      _selectedId = id;
      _round++;
      _detailDirty = false;
    });
  }

  void _delete(FoodVariant variant) {
    if (!_creating && variant.id == _selectedId) {
      setState(() {
        _selectedId = null;
        _detailDirty = false;
      });
    }
    deleteFoodWithUndo(context, ref, variant);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(foodRepositoryProvider);
    final hidden = ref.watch(pendingFoodDeletionsProvider);
    final selectedId = _selectedId;
    final split = ListDetailTemplate.isSplit(context);

    return ListDetailTemplate(
      list: _list(repo, hidden, split && !_creating ? selectedId : null),
      detail: !_creating && selectedId == null
          ? null
          : FoodEditorScreen(
              key: ValueKey('${selectedId ?? 'neu'}-$_round'),
              foodId: _creating ? null : selectedId,
              onDone: _done,
              onDirtyChanged: (dirty) => _detailDirty = dirty,
            ),
    );
  }

  Widget _list(FoodRepository repo, Set<String> hidden, String? selectedId) {
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
            return FoodListEmptySection(searching: _query.trim().isNotEmpty, onCreate: () => _openEditor());
          }

          return FoodListResultsSection(
            variants: variants,
            onOpen: (variant) => _openEditor(foodId: variant.id),
            onDelete: _delete,
            selectedId: selectedId,
          );
        },
      ),
      primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neues Lebensmittel', onPressed: () => _openEditor()),
    );
  }
}
