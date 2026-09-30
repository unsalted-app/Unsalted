// lib/src/ui/recipe_list/recipe_list_screen.dart
//
// Bildschirm 1 (Kapitel 22, Schritt 8.2): Rezeptliste, Einstieg. Titel-Suche
// client-seitig, da RecipeRepository.watchRecipes() keinen Suchparameter
// kennt (anders als FoodRepository.search, Kapitel 16.1). Keine
// Steckplätze auf diesem Bildschirm (die rendert erst Bildschirm 4).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipe/recipe.dart';
import '../../providers/core_providers.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../recipe_editor/recipe_create_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezepte'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Suchen …',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: repo.watchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.error.toString()),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          final all = snapshot.data ?? const <Recipe>[];
          final normalizedQuery = _query.trim().toLowerCase();
          final recipes = normalizedQuery.isEmpty
              ? all
              : all.where((r) => r.title.toLowerCase().contains(normalizedQuery)).toList();

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book, size: 48),
                  const SizedBox(height: 8),
                  Text(all.isEmpty ? 'Noch keine Rezepte.' : 'Keine Treffer.'),
                  const SizedBox(height: 8),
                  if (all.isEmpty)
                    ElevatedButton(
                      onPressed: _openCreateScreen,
                      child: const Text('Erstes Rezept anlegen'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.title),
                subtitle: recipe.description == null ? null : Text(recipe.description!),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
                )),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
