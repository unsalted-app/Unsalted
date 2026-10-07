// lib/catalog/lists.dart
//
// Komponenten: Listen und Chips.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „lists, chips“.
final listsFolder = WidgetbookFolder(name: 'lists, chips', children: [
  component('AppListItem', [
    useCase('List/Item', (_) => const AppStack(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppListItem(title: 'Titel', onTap: noop),
          AppListItem(title: 'Titel', subtitle: 'Untertitel', onTap: noop),
          AppListItem(
            title: 'Mit Elementen',
            leading: AppIcon(AppIcons.star, tone: AppTone.primary),
            trailing: AppChip(label: '1:30'),
          ),
          AppListItem(title: 'Kompakt', dense: true),
        ])),
  ]),
  component('AppItemList', [
    pageUseCase('List/Items', (_) => Scaffold(
          body: AppItemList.builder(itemCount: 50, itemBuilder: (context, i) => AppListItem(title: 'Eintrag ${i + 1}')),
        )),
  ]),
  component('AppSwipeToDelete', [
    useCase('List/Swipe to Delete', (_) => AppSwipeToDelete(
          key: const ValueKey('beispiel'),
          onDelete: noop,
          child: const AppListItem(title: 'Nach links wischen'),
        )),
  ]),
  component('AppReorderableList', [
    useCase('List/Reorderable', (_) => _ReorderDemo()),
  ]),
  component('AppChoiceChip', [
    useCase('Chip/Choice', (_) => const AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
          AppChoiceChip(label: 'V2', selected: true, onSelected: noop),
          AppChoiceChip(label: 'V1 · Basis', selected: false, onSelected: noop),
        ])),
  ]),
  component('AppChip', [
    useCase('Chip/Info', (_) => const AppChip(label: '12:00')),
  ]),
]);

class _ReorderDemo extends StatefulWidget {
  @override
  State<_ReorderDemo> createState() => _ReorderDemoState();
}

class _ReorderDemoState extends State<_ReorderDemo> {
  final _items = ['Eins', 'Zwei', 'Drei', 'Vier'];

  @override
  Widget build(BuildContext context) => AppReorderableList(
        onReorder: (from, to) => setState(() => _items.insert(to, _items.removeAt(from))),
        children: [
          for (final item in _items)
            AppListItem(key: ValueKey(item), title: item, leading: const AppIcon(AppIcons.dragHandle)),
        ],
      );
}
