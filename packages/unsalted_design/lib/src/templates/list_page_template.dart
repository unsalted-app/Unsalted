// lib/src/templates/list_page_template.dart
//
// Template (Teil 1.2): Seite mit einer Liste (Figma `Template/List Page`) —
// Kopfleiste mit optionaler Suche, Inhalt je Zustand (der Bildschirm reicht
// `AppLoading`, `AppErrorState`, einen leeren Zustand oder eine `AppItemList`
// herein) und optionale Hauptaktion.

import 'package:flutter/widgets.dart';

import '../components/navigation/app_top_bar.dart';
import '../layout/app_page.dart';

/// Listen-Seite.
class ListPageTemplate extends StatelessWidget {
  /// Erzeugt die Seite.
  const ListPageTemplate({
    super.key,
    required this.title,
    this.actions = const [],
    this.search,
    required this.body,
    this.primaryAction,
  });

  /// Titel der Kopfleiste.
  final String title;

  /// Aktionen der Kopfleiste.
  final List<Widget> actions;

  /// Suchfeld unter dem Titel, in der Regel `AppSearchField`.
  final Widget? search;

  /// Inhalt im aktuellen Zustand.
  final Widget body;

  /// Hauptaktion, in der Regel `AppFab`.
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) => AppPage(
        topBar: AppTopBar(title: title, actions: actions, bottom: search),
        body: body,
        primaryAction: primaryAction,
      );
}
