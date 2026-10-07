// lib/catalog/navigation.dart
//
// Komponenten: Navigation.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „navigation“.
final navigationFolder = WidgetbookFolder(name: 'navigation', children: [
  component('AppTopBar', [
    pageUseCase('Navigation/Top Bar', (_) => const Scaffold(
          appBar: AppTopBar(
            title: 'Titel',
            actions: [
              AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: noop),
              AppIconButton(icon: AppIcons.edit, tooltip: 'Bearbeiten', onPressed: noop),
            ],
          ),
        )),
    pageUseCase('mit Suche', (_) => const Scaffold(
          appBar: AppTopBar(title: 'Liste', bottom: AppSearchField(hint: 'Suchen …')),
        )),
  ]),
  component('AppOverflowMenu', [
    useCase('Navigation/Overflow Menu', (_) => const Align(
          alignment: Alignment.topRight,
          child: AppOverflowMenu(entries: [
            AppMenuEntry(label: 'Teilen', onSelected: noop),
            AppMenuEntry(label: 'Gesperrt', onSelected: noop, enabled: false),
            AppMenuEntry(label: 'Löschen', onSelected: noop),
          ]),
        )),
  ]),
  component('AppNavigationBar', [
    pageUseCase('Navigation/Navigation Bar', (_) => Scaffold(
          bottomNavigationBar: AppNavigationBar(
            selectedIndex: 0,
            onSelected: (_) {},
            destinations: const [
              AppNavigationDestination(icon: AppIcons.book, label: 'Eins'),
              AppNavigationDestination(icon: AppIcons.restaurant, label: 'Zwei'),
              AppNavigationDestination(icon: AppIcons.settings, label: 'Einstellungen'),
            ],
          ),
        )),
  ]),
  component('AppBottomActionBar', [
    pageUseCase('Navigation/Bottom Action Bar', (_) => const Scaffold(
          bottomNavigationBar: AppBottomActionBar(actions: [
            AppButton.secondary(label: 'Einfrieren', onPressed: noop),
            AppButton.primary(label: 'Speichern', onPressed: noop),
          ]),
        )),
    pageUseCase('eine Aktion', (_) => const Scaffold(
          bottomNavigationBar: AppBottomActionBar(actions: [
            AppButton.primary(label: 'Als neuen Entwurf übernehmen', onPressed: noop),
          ]),
        )),
  ]),
]);
