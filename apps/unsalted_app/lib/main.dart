// lib/main.dart
//
// App-Hülle (Kapitel 21, Schritt 8.8). Einzige Stelle im Projekt, die die
// Modulliste registriert und coreDatabaseProvider/modulesProvider
// überschreibt (Kapitel 16.7). Importiert ausschließlich die öffentliche Tür
// von unsalted_core (AT-09); alle Bildschirmrouten stammen aus
// `UnsaltedModule.routes`. Seit Teil 1.2 (C26): Theme hell/dunkel aus
// unsalted_design (folgt der Systemeinstellung), Hauptnavigation über
// AppNavigationBar. Anzeige-Schalter aus config/ui_options.dart (C29).

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:go_router/go_router.dart';
import 'package:unsalted_core/unsalted_core.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'config/ui_options.dart';

void main() {
  final modules = <UnsaltedModule>[CoreModule()];
  runApp(ProviderScope(
    overrides: appOverrides(database: CoreDatabase(driftDatabase(name: 'unsalted')), modules: modules),
    child: UnsaltedApp(modules: modules),
  ));
}

/// Alle Provider-Overrides der App (Kapitel 16.7, 21): Datenbank, Modulliste
/// und Anzeige-Schalter aus `config/ui_options.dart` (Teil 1.2, C29).
List<Override> appOverrides({
  required CoreDatabase database,
  required List<UnsaltedModule> modules,
  CoreUiOptions options = uiOptions,
}) =>
    [
      coreDatabaseProvider.overrideWithValue(database),
      modulesProvider.overrideWithValue(modules),
      coreUiOptionsProvider.overrideWithValue(options),
    ];

class UnsaltedApp extends StatefulWidget {
  const UnsaltedApp({super.key, required this.modules});

  final List<UnsaltedModule> modules;

  @override
  State<UnsaltedApp> createState() => _UnsaltedAppState();
}

class _UnsaltedAppState extends State<UnsaltedApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => _NavigationShell(location: state.uri.path, child: child),
        routes: widget.modules.expand((m) => m.routes).toList(),
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'unsalted',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}

class _NavigationShell extends StatelessWidget {
  const _NavigationShell({required this.location, required this.child});

  final String location;
  final Widget child;

  static const _destinations = ['/', '/foods', '/settings'];

  int get _selectedIndex {
    if (location.startsWith('/foods')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      body: child,
      bottomBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onSelected: (index) => context.go(_destinations[index]),
        destinations: const [
          AppNavigationDestination(icon: AppIcons.book, label: 'Rezepte'),
          AppNavigationDestination(icon: AppIcons.restaurant, label: 'Lebensmittel'),
          AppNavigationDestination(icon: AppIcons.settings, label: 'Einstellungen'),
        ],
      ),
    );
  }
}
