// lib/src/ui/foods/food_list_screen.dart
//
// Bildschirm 9 (Kapitel 22, Schritt 8.1): Lebensmittel-Liste mit Suche.
// Datenquelle ausschließlich FoodRepository.search (Kapitel 16.2).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../food/food_variant.dart';
import '../../providers/core_providers.dart';
import 'food_editor_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lebensmittel'),
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
      body: StreamBuilder<List<FoodVariant>>(
        stream: repo.search(_query),
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

          final variants = snapshot.data ?? const <FoodVariant>[];
          if (variants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_food, size: 48),
                  const SizedBox(height: 8),
                  const Text('Keine Lebensmittel gefunden.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _openEditor(),
                    child: const Text('Eigenes Produkt anlegen'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final variant = variants[index];
              return ListTile(
                title: Text(variant.name),
                subtitle: variant.brand == null ? null : Text(variant.brand!),
                onTap: () => _openEditor(foodId: variant.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
