// lib/main.dart
//
// App-Hülle (Kapitel 21, Schritt 8.8). Einzige Stelle im Projekt, die die
// Modulliste registriert und coreDatabaseProvider/modulesProvider
// überschreibt (Kapitel 16.7). Importiert ausschließlich die öffentliche Tür
// von unsalted_core (AT-09); alle Bildschirmrouten stammen aus
// `UnsaltedModule.routes`.

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unsalted_core/unsalted_core.dart';

void main() {
  final modules = <UnsaltedModule>[CoreModule()];
  runApp(ProviderScope(
    overrides: [
      coreDatabaseProvider.overrideWithValue(CoreDatabase(driftDatabase(name: 'unsalted'))),
      modulesProvider.overrideWithValue(modules),
    ],
    child: UnsaltedApp(modules: modules),
  ));
}

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
    return MaterialApp.router(title: 'unsalted', routerConfig: _router);
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
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => context.go(_destinations[index]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Rezepte'),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Lebensmittel'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}
