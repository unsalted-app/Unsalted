// lib/src/ui/recipe_detail/recipe_detail_screen.dart
//
// Bildschirm 4 (Kapitel 22, Schritt 8.5): lesende Rezeptansicht.
// Versionsumschalter, Zutaten/Schritte (aus getVersion -- Kapitel 16.1
// liefert dort "inklusive Zutaten und Schritte", watchVersions selbst
// nicht), Nährwertanzeige über NutritionService.forVersion (Draft-/
// Snapshot-Weiche bereits in Schritt 6.5 gelöst -- hier keine erneute
// Live-Auflösung von FoodVariants, auch nicht für Snapshots), darunter
// recipeDetailSections und in der AppBar recipeActions aus allen
// registrierten Modulen (Kapitel 21), generisch nach `order` sortiert.
// Davor zwei feste Core-Aktionen (Nachtrag 8.8a): "Versionen" und
// "Bearbeiten" (Editor der gewählten Version) -- CoreModule.recipeActions
// bleibt bewusst leer (Entscheidung aus 7.2). Im AppBar-Menü nach den
// Modul-Aktionen fest „Rezept löschen“ (Teil 1.1b): zurück zur Liste, dort
// 5 s „Rückgängig“, erst dann softDeleteRecipe.
// Timer-Chips zeigen nur den gespeicherten timerSeconds-Wert, keine aktive
// Timer-Engine. Unter der Nährwerttabelle der Mengenrechner (Bildschirm 6),
// mit demselben NutritionResult wie die Tabelle (Fehlerbehebung 9.2a).
//
// RecipeContext.ref (Kapitel 21) braucht ein echtes WidgetRef -- das gibt
// es nur innerhalb eines ConsumerWidget/ConsumerState. Deshalb wird der
// AppBar- und Sections-Teil (der RecipeContext baut) erst gerendert,
// sobald Version + Nährwerte geladen sind (_DetailScaffold, ein eigenes
// ConsumerWidget), statt zu versuchen, WidgetRef künstlich nachzubilden.
//
// Versionswechsel (Teil 1.1a): Der zuletzt geladene Inhalt bleibt samt
// AppBar und Versionsleiste stehen, bis die gewählte Version geladen ist;
// die Versionsleiste markiert schon die neue Wahl. Dauert das Laden länger
// als 300 ms, zeigt ein LinearProgressIndicator unter der AppBar das Laden
// (Verzögerung seit Teil 1.1c, damit er bei schnellem Laden nicht
// aufblitzt). Der zentrierte Ladekreis erscheint nur beim allerersten Laden.
// Antworten älterer Ladevorgänge werden verworfen (Zähler `_request`), damit
// bei V1 → V3 → V2 eine späte Antwort für V3 nicht V2 überschreibt.

// Seit Teil 1.2 (C23) aus Design-Komponenten: DetailPageTemplate mit
// DetailSections, Abschnitte unter sections/. Modul-Aktionen im Menü erhalten
// wie die in der Kopfleiste den Kontext dieser Seite (vorher den des
// Menüknopfs, ebenfalls darunter; UI-58). Lade- und Wechsellogik (1.1a,
// 1.1c) unverändert.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../module/extension_types.dart';
import '../../module/unsalted_module.dart';
import '../../nutrition/nutrition_result.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe.dart';
import '../../recipe/recipe_version.dart';
import '../recipe_editor/recipe_editor_screen.dart';
import '../shared/undoable_deletion.dart';
import '../versions/version_list_screen.dart';
import 'sections/recipe_detail_actions_section.dart';
import 'sections/recipe_detail_description_section.dart';
import 'sections/recipe_detail_extensions_section.dart';
import 'sections/recipe_detail_ingredients_section.dart';
import 'sections/recipe_detail_nutrition_section.dart';
import 'sections/recipe_detail_steps_section.dart';
import 'version_switcher.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  String? _selectedVersionId;

  void _ensureSelection(List<RecipeVersion> versions, Recipe recipe) {
    if (versions.isEmpty) {
      _selectedVersionId = null;
      return;
    }
    if (_selectedVersionId != null && versions.any((v) => v.id == _selectedVersionId)) {
      return;
    }
    final masterId = recipe.masterVersionId;
    if (masterId != null && versions.any((v) => v.id == masterId)) {
      _selectedVersionId = masterId;
    } else {
      _selectedVersionId = versions.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepositoryProvider);
    final modules = ref.watch(modulesProvider);

    return StreamBuilder<Recipe?>(
      stream: repo.watchRecipe(widget.recipeId),
      builder: (context, recipeSnapshot) {
        if (recipeSnapshot.connectionState == ConnectionState.waiting && !recipeSnapshot.hasData) {
          return const AppPage(body: AppLoading());
        }
        if (recipeSnapshot.hasError) {
          return AppPage(body: AppErrorState(message: recipeSnapshot.error.toString()));
        }
        final recipe = recipeSnapshot.data;
        if (recipe == null) {
          return const AppPage(body: AppEmptyState(message: 'Rezept nicht gefunden.'));
        }

        return StreamBuilder<List<RecipeVersion>>(
          stream: repo.watchVersions(widget.recipeId),
          builder: (context, versionsSnapshot) {
            if (versionsSnapshot.connectionState == ConnectionState.waiting &&
                !versionsSnapshot.hasData) {
              return DetailPageTemplate(title: recipe.title, body: const AppLoading());
            }
            if (versionsSnapshot.hasError) {
              return DetailPageTemplate(
                title: recipe.title,
                body: AppErrorState(message: versionsSnapshot.error.toString()),
              );
            }
            final versions = versionsSnapshot.data ?? const <RecipeVersion>[];
            _ensureSelection(versions, recipe);

            if (versions.isEmpty) {
              return DetailPageTemplate(
                title: recipe.title,
                body: const AppEmptyState(message: 'Keine Version vorhanden.'),
              );
            }

            return _VersionLoader(
              recipe: recipe,
              versions: versions,
              selectedVersionId: _selectedVersionId!,
              modules: modules,
              onVersionSelected: (id) => setState(() => _selectedVersionId = id),
            );
          },
        );
      },
    );
  }
}

class _VersionLoader extends ConsumerStatefulWidget {
  final Recipe recipe;
  final List<RecipeVersion> versions;
  final String selectedVersionId;
  final List<UnsaltedModule> modules;
  final ValueChanged<String> onVersionSelected;

  const _VersionLoader({
    required this.recipe,
    required this.versions,
    required this.selectedVersionId,
    required this.modules,
    required this.onVersionSelected,
  });

  @override
  ConsumerState<_VersionLoader> createState() => _VersionLoaderState();
}

class _VersionLoaderState extends ConsumerState<_VersionLoader> {
  /// Zuletzt geladener Inhalt; bleibt während eines Versionswechsels stehen.
  (RecipeVersion, NutritionResult)? _shown;
  Object? _error;
  bool _loading = false;

  /// Ladebalken erst zeigen, wenn das Laden länger dauert -- sonst blitzt er
  /// bei jedem schnellen Wechsel kurz auf (Teil 1.1c).
  static const _progressDelay = Duration(milliseconds: 300);
  Timer? _progressTimer;
  bool _showProgress = false;

  /// Zählt die Ladevorgänge; nur die Antwort des jüngsten wird übernommen.
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _start(widget.selectedVersionId);
  }

  @override
  void didUpdateWidget(covariant _VersionLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedVersionId != widget.selectedVersionId) {
      _start(widget.selectedVersionId);
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  /// Wird aus initState/didUpdateWidget aufgerufen, also vor dem nächsten
  /// build -- deshalb ohne setState.
  void _start(String versionId) {
    final request = ++_request;
    // Nur beim Übergang von „ruhend“ zu „lädt“ die Verzögerung starten; ein
    // Wechsel während des Ladens lässt einen schon sichtbaren Ladebalken
    // stehen, statt ihn kurz aus- und wieder einzublenden.
    if (!_loading) {
      _progressTimer = Timer(_progressDelay, () {
        if (mounted) setState(() => _showProgress = true);
      });
    }
    _loading = true;
    _load(versionId).then<void>(
      (result) {
        if (!mounted || request != _request) return;
        setState(() {
          _shown = result;
          _error = null;
          _finishLoading();
        });
      },
      onError: (Object error) {
        if (!mounted || request != _request) return;
        setState(() {
          _error = error;
          _finishLoading();
        });
      },
    );
  }

  void _finishLoading() {
    _loading = false;
    _progressTimer?.cancel();
    _progressTimer = null;
    _showProgress = false;
  }

  Future<(RecipeVersion, NutritionResult)> _load(String versionId) async {
    final repo = ref.read(recipeRepositoryProvider);
    final nutritionService = ref.read(nutritionServiceProvider);
    final version = await repo.getVersion(versionId);
    final nutrition = await nutritionService.forVersion(versionId);
    if (version == null) {
      throw StateError('Version "$versionId" nicht gefunden.');
    }
    return (version, nutrition);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    if (_error != null && !_loading) {
      return DetailPageTemplate(title: widget.recipe.title, body: AppErrorState(message: _error.toString()));
    }
    if (shown == null) {
      return DetailPageTemplate(title: widget.recipe.title, body: const AppLoading());
    }
    final (version, nutrition) = shown;
    return _DetailScaffold(
      recipe: widget.recipe,
      versions: widget.versions,
      version: version,
      nutrition: nutrition,
      selectedVersionId: widget.selectedVersionId,
      showProgress: _showProgress,
      modules: widget.modules,
      onVersionSelected: widget.onVersionSelected,
    );
  }
}

class _DetailScaffold extends ConsumerWidget {
  final Recipe recipe;
  final List<RecipeVersion> versions;
  final RecipeVersion version;
  final NutritionResult nutrition;

  /// Gewählte Version; weicht während eines Wechsels von [version] ab.
  final String selectedVersionId;

  /// `true`, wenn die gewählte Version länger als 300 ms lädt; dann zeigt der
  /// Body den Ladebalken.
  final bool showProgress;
  final List<UnsaltedModule> modules;
  final ValueChanged<String> onVersionSelected;

  const _DetailScaffold({
    required this.recipe,
    required this.versions,
    required this.version,
    required this.nutrition,
    required this.selectedVersionId,
    required this.showProgress,
    required this.modules,
    required this.onVersionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeContext = RecipeContext(
      recipeId: recipe.id,
      versionId: version.id,
      version: version,
      nutrition: nutrition,
      ref: ref,
    );

    final sections = <RecipeDetailSection>[
      for (final module in modules) ...module.recipeDetailSections,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final actions = <RecipeAction>[
      for (final module in modules) ...module.recipeActions,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final appBarActions = actions.where((a) => a.placement == RecipeActionPlacement.appBar).toList();
    final menuActions = actions.where((a) => a.placement == RecipeActionPlacement.menu).toList();

    return DetailPageTemplate(
      title: recipe.title,
      showProgress: showProgress,
      actions: [
        RecipeDetailActionsSection(
          appBarActions: appBarActions,
          menuActions: menuActions,
          isEnabled: (action) => action.isEnabled?.call(recipeContext) ?? true,
          onAction: (action) => action.onPressed(context, recipeContext),
          onVersions: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => VersionListScreen(recipeId: recipe.id),
          )),
          onEdit: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => RecipeEditorScreen(recipeId: recipe.id, versionId: version.id),
          )),
          onDelete: () => _deleteRecipe(context, ref),
        ),
      ],
      body: DetailSections(
        sections: [
          VersionSwitcher(
            versions: versions,
            selectedVersionId: selectedVersionId,
            onSelected: onVersionSelected,
          ),
          RecipeDetailDescriptionSection(description: recipe.description),
          RecipeDetailNutritionSection(versionId: version.id, nutrition: nutrition),
        ],
        secondary: [
          RecipeDetailIngredientsSection(ingredients: version.ingredients),
          RecipeDetailStepsSection(steps: version.steps),
          RecipeDetailExtensionsSection(
            children: [for (final section in sections) section.build(context, recipeContext)],
          ),
        ],
      ),
    );
  }

  /// Teil 1.1b: zurück zur Rezeptliste, dort Löschen mit „Rückgängig“.
  void _deleteRecipe(BuildContext context, WidgetRef ref) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    deleteRecipeWithUndo(context, ref, recipe);
  }
}
