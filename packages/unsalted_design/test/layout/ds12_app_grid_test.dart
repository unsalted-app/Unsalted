// test/layout/ds12_app_grid_test.dart
//
// DS-12 (Teil 1.2): AppGrid ordnet nach verfügbarer Breite 1, 2 oder 3
// Spalten an; Elemente einer Zeile sind gleich hoch.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-12: Spalten nach Breite, Zeilen gleich hoch', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      SingleChildScrollView(
        child: AppGrid(
          itemCount: 5,
          itemBuilder: (context, index) => SizedBox(key: Key('i$index'), height: index == 0 ? 80 : 40),
        ),
      ),
    );
    final columns = AppWindowSize.forWidth(variant.size.width).gridColumns;
    final first = tester.getRect(find.byKey(const Key('i0')));
    final second = tester.getRect(find.byKey(const Key('i1')));
    if (columns == 1) {
      expect(second.top, greaterThan(first.bottom));
    } else {
      expect(second.top, first.top);
      expect(second.height, first.height, reason: 'gleich hohe Zeile');
    }
    expect(find.byKey(const Key('i4')), findsOneWidget);
  });

  test('DS-12: Spaltenzahl je Fenstergröße', () {
    expect(AppWindowSize.compact.gridColumns, 1);
    expect(AppWindowSize.medium.gridColumns, 2);
    expect(AppWindowSize.expanded.gridColumns, 3);
    expect(AppWindowSize.large.gridColumns, 3);
  });
}
