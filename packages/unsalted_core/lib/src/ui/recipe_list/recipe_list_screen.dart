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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

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

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepositoryProvider);
    final hidden = ref.watch(pendingRecipeDeletionsProvider);

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
            onOpen: (recipe) => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
            )),
            onDelete: (recipe) => deleteRecipeWithUndo(context, ref, recipe),
          );
        },
      ),
      primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neues Rezept', onPressed: _openCreateScreen),
    );
  }
}
