// lib/src/ui/recipe_list/recipe_list_screen.dart
//
// Bildschirm 1 (Kapitel 22, Schritt 8.2): Rezeptliste, Einstieg. Titel-Suche
// client-seitig, da RecipeRepository.watchRecipes() keinen Suchparameter
// kennt (anders als FoodRepository.search, Kapitel 16.1). Keine
// Steckplätze auf diesem Bildschirm (die rendert erst Bildschirm 4).
// Nach links wischen löscht ein Rezept samt aller Versionen, mit 5 s
// „Rückgängig“ (Teil 1.1b, shared/undoable_deletion.dart); ausstehende
// Löschungen sind sofort ausgeblendet. Seit Teil 1.2 (C16) aus
// Design-Komponenten: ListPageTemplate, Abschnitte unter sections/, Baustein
// RecipeCard.
// Seit Teil 1.4 (T02, Figma Tablet „01+04“): ab `breakpoint-expanded` stehen
// Liste und Rezeptdetail nebeneinander (`ListDetailTemplate`). Tippen wählt
// dann aus, statt zu navigieren; das gewählte Rezept trägt den
// Auswahlbalken, ohne Auswahl bleibt der Detailbereich leer (Punktraster).
// Darunter wie bisher `Navigator.push`. Die Auswahl bleibt beim Verkleinern
// erhalten und erscheint beim Vergrößern wieder (F6). Gelöscht — per Wischen
// oder über „Rezept löschen“ im Detailbereich — hebt sie auf. Routen
// unverändert (F8).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/recipe_repository.dart';
import '../../recipe/recipe.dart';
import '../../providers/core_providers.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../recipe_editor/recipe_create_screen.dart';
import '../shared/undoable_deletion.dart';
import 'sections/recipe_list_empty_section.dart';
import 'sections/recipe_list_results_section.dart';
import 'sections/recipe_list_search_section.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  /// Im Detailbereich geöffnetes Rezept; `null` = keine Auswahl.
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateScreen() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const RecipeCreateScreen(),
    ));
  }

  /// Nebeneinander: auswählen; sonst das Rezeptdetail als eigene Seite.
  void _open(Recipe recipe) {
    if (ListDetailTemplate.isSplit(context)) {
      setState(() => _selectedId = recipe.id);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
    ));
  }

  void _delete(Recipe recipe) {
    if (recipe.id == _selectedId) setState(() => _selectedId = null);
    deleteRecipeWithUndo(context, ref, recipe);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepositoryProvider);
    final hidden = ref.watch(pendingRecipeDeletionsProvider);
    final selectedId = _selectedId;
    final split = ListDetailTemplate.isSplit(context);

    return ListDetailTemplate(
      list: _list(repo, hidden, split ? selectedId : null),
      detail: selectedId == null
          ? null
          : RecipeDetailScreen(
              key: ValueKey(selectedId),
              recipeId: selectedId,
              onClose: () => setState(() => _selectedId = null),
            ),
    );
  }

  Widget _list(RecipeRepository repo, Set<String> hidden, String? selectedId) {
    return ListPageTemplate(
      title: 'Rezepte',
      search: RecipeListSearchSection(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: repo.watchRecipes(),
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

          final all = (snapshot.data ?? const <Recipe>[]).where((r) => !hidden.contains(r.id)).toList();
          final normalizedQuery = _query.trim().toLowerCase();
          final recipes = normalizedQuery.isEmpty
              ? all
              : all.where((r) => r.title.toLowerCase().contains(normalizedQuery)).toList();

          if (recipes.isEmpty) {
            return RecipeListEmptySection(hasRecipes: all.isNotEmpty, onCreate: _openCreateScreen);
          }

          return RecipeListResultsSection(
            recipes: recipes,
            onOpen: _open,
            onDelete: _delete,
            query: _query,
            selectedId: selectedId,
          );
        },
      ),
      primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neues Rezept', onPressed: _openCreateScreen),
    );
  }
}
