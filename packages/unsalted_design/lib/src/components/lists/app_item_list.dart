// lib/src/components/lists/app_item_list.dart
//
// Komponente (Teil 1.2): scrollende Liste der Einträge einer Seite (Figma
// `List/Items`). Zentrale Stelle, an der später z. B. ab Tablet-Breite ein
// Raster statt einer Liste entstehen kann. Baut vorerst ein `ListView`.

import 'package:flutter/widgets.dart';

/// Scrollende Liste.
class AppItemList extends StatelessWidget {
  /// Liste aus festen Kindern.
  const AppItemList({super.key, required List<Widget> this.children})
      : itemCount = null,
        itemBuilder = null;

  /// Liste, die ihre Einträge erst beim Sichtbarwerden baut.
  const AppItemList.builder({super.key, required int this.itemCount, required IndexedWidgetBuilder this.itemBuilder})
      : children = null;

  /// Feste Kinder.
  final List<Widget>? children;

  /// Anzahl der Einträge (Builder).
  final int? itemCount;

  /// Baut den Eintrag an Position `index` (Builder).
  final IndexedWidgetBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) => children != null
      ? ListView(children: children!)
      : ListView.builder(itemCount: itemCount, itemBuilder: itemBuilder!);
}
