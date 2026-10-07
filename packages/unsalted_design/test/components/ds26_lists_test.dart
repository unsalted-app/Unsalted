// test/components/ds26_lists_test.dart
//
// DS-26 bis DS-31 (Teil 1.2): AppListItem, AppItemList, AppSwipeToDelete,
// AppReorderableList, AppChoiceChip und AppChip.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-26: AppListItem', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        AppListItem(
          title: 'Titel',
          subtitle: 'Unter',
          leading: const AppIcon(AppIcons.info),
          trailing: const AppChip(label: '1:30'),
          onTap: () => taps++,
        ),
        const AppListItem(title: 'Kompakt', dense: true),
      ]),
    );
    expect(find.ancestor(of: find.text('Titel'), matching: find.byType(ListTile)), findsOneWidget);
    expect(find.text('Unter'), findsOneWidget);
    expect(tester.widget<ListTile>(find.ancestor(of: find.text('Kompakt'), matching: find.byType(ListTile))).dense,
        isTrue);
    await tester.tap(find.text('Titel'));
    expect(taps, 1);
  });

  testVariants('DS-27: AppItemList mit Kindern und Builder', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        const Expanded(child: AppItemList(children: [Text('fest')])),
        Expanded(child: AppItemList.builder(itemCount: 100, itemBuilder: (context, i) => Text('Eintrag $i'))),
      ]),
    );
    expect(find.text('fest'), findsOneWidget);
    expect(find.text('Eintrag 0'), findsOneWidget);
    expect(find.text('Eintrag 99'), findsNothing, reason: 'baut erst beim Sichtbarwerden');
  });

  testVariants('DS-28: AppSwipeToDelete', (tester, variant) async {
    final deleted = <String>[];
    final items = ['a', 'b'];
    await pumpVariant(
      tester,
      variant,
      StatefulBuilder(
        builder: (context, setState) => Column(children: [
          for (final item in items)
            AppSwipeToDelete(
              key: ValueKey(item),
              onDelete: () => setState(() {
                items.remove(item);
                deleted.add(item);
              }),
              child: AppListItem(title: 'Eintrag $item'),
            ),
        ]),
      ),
    );
    await tester.drag(find.text('Eintrag a'), const Offset(-600, 0));
    await tester.pump();
    expect(find.byIcon(AppIcons.delete), findsOneWidget);
    await tester.pumpAndSettle();
    expect(deleted, ['a']);
    expect(find.text('Eintrag a'), findsNothing);
    expect(find.text('Eintrag b'), findsOneWidget);
  });

  testVariants('DS-29: AppReorderableList meldet die Verschiebung', (tester, variant) async {
    final moves = <(int, int)>[];
    await pumpVariant(
      tester,
      variant,
      SingleChildScrollView(
        child: AppReorderableList(
          onReorder: (a, b) => moves.add((a, b)),
          children: [
            for (final name in ['eins', 'zwei', 'drei'])
              AppListItem(key: ValueKey(name), title: name, leading: const AppIcon(AppIcons.dragHandle)),
          ],
        ),
      ),
    );
    final start = tester.getCenter(find.text('eins'));
    final target = tester.getCenter(find.text('drei')) + const Offset(0, 20);
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(seconds: 1));
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(Offset.lerp(start, target, i / 10)!);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(moves, hasLength(1));
    expect(moves.single.$1, 0);
    expect(find.byType(ReorderableListView), findsOneWidget);
  });

  testVariants('DS-30/31: AppChoiceChip und AppChip', (tester, variant) async {
    var selected = 0;
    await pumpVariant(
      tester,
      variant,
      Row(children: [
        AppChoiceChip(label: 'V1', selected: true, onSelected: () => selected++),
        const AppChoiceChip(label: 'V2', selected: false, onSelected: null),
        const AppChip(label: '1:30'),
      ]),
    );
    expect(find.widgetWithText(ChoiceChip, 'V1'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'V1')).selected, isTrue);
    expect(find.widgetWithText(Chip, '1:30'), findsOneWidget);
    await tester.tap(find.text('V1'));
    expect(selected, 1);
  });
}
