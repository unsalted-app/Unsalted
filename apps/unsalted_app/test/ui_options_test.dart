// test/ui_options_test.dart
//
// UC-07 (Teil 1.2, C29): Die App überschreibt coreUiOptionsProvider mit den
// Werten aus lib/config/ui_options.dart (über appOverrides, wie main()); die
// Werte dort sind die Standardwerte, also das Verhalten vor Teil 1.2.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_app/config/ui_options.dart';
import 'package:unsalted_app/main.dart';
import 'package:unsalted_core/unsalted_core.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }
}

Future<CoreUiOptions> _optionsInApp(WidgetTester tester, {CoreUiOptions? options}) async {
  final database = (await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory())))!;
  addTearDown(() => tester.runAsync(database.close));
  final modules = <UnsaltedModule>[CoreModule()];
  await tester.pumpWidget(ProviderScope(
    overrides: options == null
        ? appOverrides(database: database, modules: modules)
        : appOverrides(database: database, modules: modules, options: options),
    child: UnsaltedApp(modules: modules),
  ));
  await _settle(tester);
  final value = ProviderScope.containerOf(tester.element(find.byType(UnsaltedApp))).read(coreUiOptionsProvider);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
  return value;
}

void main() {
  test('UC-07: ui_options.dart enthält die Standardwerte', () {
    expect(uiOptions, const CoreUiOptions());
    expect(uiOptions.hiddenNutrients, isEmpty);
    expect(uiOptions.showBarcodeField, isTrue);
    expect(uiOptions.showAdvancedFields, isTrue);
  });

  testWidgets('UC-07: die App nutzt die Werte aus ui_options.dart', (tester) async {
    expect(identical(await _optionsInApp(tester), uiOptions), isTrue);
  });

  testWidgets('UC-07: der Override in appOverrides wirkt bis in die App', (tester) async {
    const custom = CoreUiOptions(hiddenNutrients: {'fiber_g'}, showBarcodeField: false);
    expect(identical(await _optionsInApp(tester, options: custom), custom), isTrue);
  });
}
