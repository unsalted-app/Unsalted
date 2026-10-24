// test/components/ds67_text_selection_test.dart
//
// DS-67 (Teil 1.4 B05, Figma `Input/Text Selection`, Hinweis 5): Das Theme
// markiert Text mit `selection` × `opacity-selection`, Griffe und Cursor in
// `selection-handle` (iOS: `CupertinoThemeData.primaryColor`).
// `AppSelectableArea` macht Text markierbar: langes Drücken markiert ein Wort
// und öffnet das Kontextmenü der Plattform.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

void main() {
  for (final (name, theme, c) in [
    ('hell', AppTheme.light(), AppColorTokens.light),
    ('dunkel', AppTheme.dark(), AppColorTokens.dark),
  ]) {
    test('DS-67: Textauswahl im Theme ($name)', () {
      final selection = theme.textSelectionTheme;
      expect(selection.selectionColor, c.selection.withValues(alpha: AppOpacity.selection));
      expect(selection.selectionHandleColor, c.selectionHandle);
      expect(selection.cursorColor, c.selectionHandle);
      expect(theme.cupertinoOverrideTheme!.primaryColor, c.selectionHandle);
    });
  }

  testVariants('DS-67: AppSelectableArea macht Text markierbar', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const AppSelectableArea(child: Text('Hefeteig für Zopf')),
    );
    expect(find.byType(SelectionArea), findsOneWidget);
    await tester.longPress(find.text('Hefeteig für Zopf'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(AppSelectableArea));
    expect(find.text(MaterialLocalizations.of(context).copyButtonLabel), findsOneWidget, reason: 'Kontextmenü');
  });
}
