// test/components/ds14_buttons_test.dart
//
// DS-14 bis DS-16 (Teil 1.2): AppButton, AppIconButton und AppFab bauen die
// bisherigen Material-Widgets (Plan R1), lösen ihre Aktion aus und lassen
// sich deaktivieren.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  testVariants('DS-14: AppButton je Variante', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        AppButton.primary(label: 'Eins', onPressed: () => taps++),
        AppButton.secondary(label: 'Zwei', onPressed: () => taps++),
        AppButton.tertiary(label: 'Drei', onPressed: () => taps++),
        AppButton.tertiary(label: 'Vier', icon: AppIcons.add, onPressed: () => taps++),
        const AppButton.primary(label: 'Aus', onPressed: null),
      ]),
    );
    expect(find.widgetWithText(ElevatedButton, 'Eins'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Zwei'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Drei'), findsOneWidget);
    expect(find.widgetWithIcon(TextButton, AppIcons.add), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Vier'), findsOneWidget);
    for (final label in ['Eins', 'Zwei', 'Drei', 'Vier', 'Aus']) {
      await tester.tap(find.text(label));
    }
    expect(taps, 4);
    expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Aus')).onPressed, isNull);
  });

  testVariants('DS-15: AppIconButton mit Tooltip', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      AppIconButton(icon: AppIcons.edit, tooltip: 'Bearbeiten', onPressed: () => taps++),
    );
    expect(find.widgetWithIcon(IconButton, AppIcons.edit), findsOneWidget);
    expect(find.byTooltip('Bearbeiten'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(taps, 1);
  });

  testVariants('DS-16: AppFab normal und ladend', (tester, variant) async {
    var taps = 0;
    var loading = false;
    late StateSetter setState;
    await pumpVariant(
      tester,
      variant,
      StatefulBuilder(builder: (context, set) {
        setState = set;
        return Center(
          child: AppFab(icon: AppIcons.check, tooltip: 'Speichern', loading: loading, onPressed: () => taps++),
        );
      }),
    );
    await tester.tap(find.byType(FloatingActionButton));
    expect(taps, 1);
    expect(find.byTooltip('Speichern'), findsOneWidget);
    setState(() => loading = true);
    await tester.pump();
    expect(tester.widget<FloatingActionButton>(find.byType(FloatingActionButton)).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(AppIcons.check), findsNothing);
  });
}
