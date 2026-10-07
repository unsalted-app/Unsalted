// test/layout/ds13_responsive_test.dart
//
// DS-13 (Teil 1.2): Fenstergrößen aus den Breakpoint-Tokens; ResponsiveBuilder
// richtet sich nach der verfügbaren Breite.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  test('DS-13: Grenzen der Fenstergrößen', () {
    expect(AppWindowSize.forWidth(599), AppWindowSize.compact);
    expect(AppWindowSize.forWidth(600), AppWindowSize.medium);
    expect(AppWindowSize.forWidth(839), AppWindowSize.medium);
    expect(AppWindowSize.forWidth(840), AppWindowSize.expanded);
    expect(AppWindowSize.forWidth(1200), AppWindowSize.large);
    expect(AppWindowSize.expanded.isAtLeast(AppWindowSize.medium), isTrue);
    expect(AppWindowSize.compact.isAtLeast(AppWindowSize.medium), isFalse);
  });

  testVariants('DS-13: Fenster und verfügbare Breite', (tester, variant) async {
    late AppWindowSize window;
    late AppWindowSize available;
    await pumpVariant(
      tester,
      variant,
      Builder(builder: (context) {
        window = AppWindowSize.of(context);
        return Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            child: ResponsiveBuilder(builder: (context, size) {
              available = size;
              return const SizedBox.shrink();
            }),
          ),
        );
      }),
    );
    expect(window, AppWindowSize.forWidth(variant.size.width));
    expect(available, AppWindowSize.compact);
  });
}
