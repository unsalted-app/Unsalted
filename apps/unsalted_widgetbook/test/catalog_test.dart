// test/catalog_test.dart
//
// WB-01 (Teil 1.2): Jeder Anwendungsfall des Katalogs baut in hell/dunkel ×
// Handy/Tablet ohne Fehler (auch ohne Überlauf).
// WB-03: Die Katalog-App startet mit Theme- und Viewport-Addon.
// WB-02: Jedes Symbol der Tür von unsalted_design steht als Komponente im
// Katalog oder ist ausdrücklich als Nicht-Widget bzw. Teil eines anderen
// Eintrags ausgenommen — eine neue Komponente fällt so auf.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:unsalted_widgetbook/catalog/catalog.dart';
import 'package:unsalted_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

/// Symbole ohne eigenen Katalogeintrag.
const _notCatalogued = {
  // Tokens (Ordner „Tokens“) und Theme (Theme-Addon).
  'AppBreakpoints', 'AppColorTokens', 'AppElevation', 'AppMotion', 'AppRadius', 'AppSpace', 'AppSpacing',
  'AppTypography', 'AppTheme', 'AppTone', 'AppIcons',
  // Parameter- und Datentypen.
  'AppButtonVariant', 'AppIconSize', 'AppTextRole', 'AppSurfaceTone', 'AppFieldWidth', 'AppSelectItem',
  'AppNoticeKind', 'AppSnackbarHandle', 'AppMenuEntry', 'AppNavigationDestination', 'AppTableRow',
  'AppWindowSize', 'DetailLayout',
  // Teil eines anderen Eintrags.
  'AppGap', 'AppPadding', 'DetailSections', 'DetailSplit', 'FormSections',
  'showAppMessage', 'showAppConfirmDialog', 'showAppChoiceDialog', 'showAppDialog', 'showAppAboutDialog',
};

Iterable<WidgetbookNode> _walk(List<WidgetbookNode> nodes) sync* {
  for (final node in nodes) {
    yield node;
    yield* _walk(node.children ?? const []);
  }
}

Set<String> _doorSymbols() {
  final golden = File('../../packages/unsalted_design/test/architecture/public_api_golden.txt').readAsLinesSync();
  return {
    for (final line in golden)
      if (!line.startsWith('#') && line.contains(' show '))
        ...line.split(' show ').last.split(',').map((s) => s.trim()),
  };
}

void main() {
  final useCases = _walk(catalog).whereType<WidgetbookUseCase>().toList();
  final components = _walk(catalog).whereType<WidgetbookComponent>().map((c) => c.name).toSet();

  test('WB-02: jede Komponente der Tür steht im Katalog', () {
    final symbols = _doorSymbols();
    expect(symbols, isNotEmpty);
    final missing = symbols.difference(components).difference(_notCatalogued);
    expect(missing, isEmpty, reason: 'Ohne Katalogeintrag: $missing');
    final stale = _notCatalogued.difference(symbols);
    expect(stale, isEmpty, reason: 'Ausnahme ohne Symbol in der Tür: $stale');
  });

  const sizes = {'Handy': Size(390, 844), 'Tablet': Size(1024, 1366)};
  for (final MapEntry(key: device, value: size) in sizes.entries) {
    for (final (mode, theme) in [('hell', AppTheme.light()), ('dunkel', AppTheme.dark())]) {
      testWidgets('WB-01: alle ${useCases.length} Anwendungsfälle ($mode, $device)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final useCase in useCases) {
          await tester.pumpWidget(MaterialApp(theme: theme, home: Builder(builder: useCase.builder)));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: useCase.name);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('WB-03: die Katalog-App startet', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CatalogApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.text('Tokens'), findsWidgets);
    expect(find.byType(Widgetbook), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
