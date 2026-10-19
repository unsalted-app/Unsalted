// test/components/ds53_brand_test.dart
//
// DS-53 bis DS-58 (Teil 1.3, D07): Markenelemente nach den Karten in
// docs/design/system/components/ — Zustandsmarke (DS-53), Zustandsrahmen
// (DS-54), Leerstelle mit Punktraster (DS-55), Marker (DS-56), Änderung
// (DS-57), Messwert (DS-58). Je in hell/dunkel × Handy/Tablet.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

AppColorTokens _colors(Variant variant) =>
    variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;

/// Painter der Strichlinie unter [finder] (privater Typ, über den Namen).
CustomPainter? _dashed(WidgetTester tester, Finder finder) {
  for (final paint in tester.widgetList<CustomPaint>(find.descendant(of: finder, matching: find.byType(CustomPaint)))) {
    for (final painter in [paint.painter, paint.foregroundPainter]) {
      if (painter != null && painter.runtimeType.toString() == 'DashedPainter') return painter;
    }
  }
  return null;
}

void main() {
  testVariants('DS-53: AppMark in drei Zuständen', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppMark(key: Key('p'), label: 'V3', state: AppMarkState.provisional, semanticLabel: 'Fassung 3, vorläufig'),
        AppMark(key: Key('f'), label: 'V2', state: AppMarkState.fixed, seal: true),
        AppMark(key: Key('h'), label: 'V1', state: AppMarkState.highlighted),
      ]),
    );
    final c = _colors(variant);
    Color textColor(String label) => tester.widget<Text>(find.text(label)).style!.color!;

    expect(_dashed(tester, find.byKey(const Key('p'))), isNotNull, reason: 'vorläufig = Strichlinie');
    expect(textColor('V3'), c.textSecondary);
    expect(find.bySemanticsLabel('Fassung 3, vorläufig'), findsOneWidget);

    final fixed = tester.widget<DecoratedBox>(
      find.descendant(of: find.byKey(const Key('f')), matching: find.byType(DecoratedBox)).first,
    );
    final fixedBorder = (fixed.decoration as BoxDecoration).border! as Border;
    expect(fixedBorder.top, BorderSide(color: c.stateFrozen, width: AppStroke.frame));
    expect(textColor('V2'), c.textPrimary);
    expect(find.descendant(of: find.byKey(const Key('f')), matching: find.byIcon(AppIcons.lock)), findsOneWidget);

    final highlighted = tester.widget<DecoratedBox>(
      find.descendant(of: find.byKey(const Key('h')), matching: find.byType(DecoratedBox)).first,
    );
    expect((highlighted.decoration as BoxDecoration).color, c.stateMaster);
    expect(textColor('V1'), c.textOnMarker);

    for (final key in ['p', 'f', 'h']) {
      expect(tester.getSize(find.byKey(Key(key))).height, greaterThanOrEqualTo(AppSize.mark));
    }
  });

  testVariants('DS-53: AppMark als Auswahlziel mit Balken', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      Row(children: [
        AppMark(key: const Key('a'), label: 'V2', state: AppMarkState.fixed, selected: true, onTap: () => taps++),
        AppMark(key: const Key('b'), label: 'V1', state: AppMarkState.fixed, onTap: () => taps++),
      ]),
    );
    final c = _colors(variant);
    final target = tester.getSize(find.byKey(const Key('a')));
    expect(target.width, greaterThanOrEqualTo(AppSize.target));
    expect(target.height, greaterThanOrEqualTo(AppSize.target));
    final bars = tester.widgetList<ColoredBox>(
      find.descendant(of: find.byKey(const Key('a')), matching: find.byType(ColoredBox)),
    );
    expect(bars.map((b) => b.color), contains(c.lineStrong));
    expect(find.descendant(of: find.byKey(const Key('b')), matching: find.byType(ColoredBox)), findsNothing);
    await tester.tap(find.text('V1'));
    expect(taps, 1);
    expect(tester.getSemantics(find.byKey(const Key('a'))), isSemantics(isSelected: true, isButton: true));
  });

  testVariants('DS-54: AppFrame vorläufig und fest', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(children: [
        AppFrame.provisional(
          key: Key('p'),
          mark: AppMark(label: 'V4', state: AppMarkState.provisional),
          caption: 'offen',
          child: Text('Inhalt'),
        ),
        AppFrame.fixed(key: Key('f'), caption: 'fest', child: Text('Fest')),
      ]),
    );
    final c = _colors(variant);
    final dashed = _dashed(tester, find.byKey(const Key('p')));
    expect(dashed, isNotNull);
    final fixed = tester.widget<DecoratedBox>(
      find.descendant(of: find.byKey(const Key('f')), matching: find.byType(DecoratedBox)).first,
    );
    expect(((fixed.decoration as BoxDecoration).border! as Border).top.color, c.stateFrozen);
    expect(tester.widget<Text>(find.text('offen')).style!.color, c.textSecondary);
    expect(tester.getTopLeft(find.text('Inhalt')).dy, greaterThan(tester.getTopLeft(find.text('offen')).dy));
  });

  testVariants('DS-55: AppSlot mit Punktraster und Aktion', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      Column(children: [
        AppSlot(
          key: const Key('slot'),
          icon: AppIcons.book,
          message: 'Noch leer.',
          action: AppButton.primary(label: 'Anlegen', onPressed: () => taps++),
        ),
        const AppSlot(key: Key('plain'), message: 'Keine Treffer.', pattern: false),
      ]),
    );
    final c = _colors(variant);
    final paints = tester.widgetList<CustomPaint>(
      find.descendant(of: find.byKey(const Key('slot')), matching: find.byType(CustomPaint)),
    );
    final dots = paints.map((p) => p.painter).whereType<CustomPainter>().where(
          (p) => p.runtimeType.toString() == 'DotPatternPainter',
        );
    expect(dots, hasLength(1));
    // Punkte im dunklen Modus dunkel (#252A34 auf #141925), hell #E2DFDA.
    expect((dots.single as dynamic).color, c.lineDot);
    expect(_dashed(tester, find.byKey(const Key('slot'))), isNotNull);
    expect(tester.getSize(find.byIcon(AppIcons.book)), const Size.square(AppSize.icon));
    await tester.tap(find.text('Anlegen'));
    expect(taps, 1);
    final plain = tester.widgetList<CustomPaint>(
      find.descendant(of: find.byKey(const Key('plain')), matching: find.byType(CustomPaint)),
    );
    expect(plain.where((p) => p.painter?.runtimeType.toString() == 'DotPatternPainter'), isEmpty);
  });

  testVariants('DS-56: AppHighlight', (tester, variant) async {
    await pumpVariant(tester, variant, const Align(alignment: Alignment.topLeft, child: AppHighlight('390 g')));
    final c = _colors(variant);
    final box = tester.widget<DecoratedBox>(
      find.ancestor(of: find.text('390 g'), matching: find.byType(DecoratedBox)).first,
    );
    expect((box.decoration as BoxDecoration).color, c.marker);
    expect((box.decoration as BoxDecoration).borderRadius, BorderRadius.circular(AppRadius.xs));
    expect(tester.widget<Text>(find.text('390 g')).style!.color, c.textOnMarker);
  });

  testVariants('DS-57: AppChangeText alt → neu, hinzugefügt, Klartext', (tester, variant) async {
    final handle = tester.ensureSemantics();
    await pumpVariant(
      tester,
      variant,
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppChangeText(semanticLabel: 'Mehl: 500 g → 550 g', subject: 'Mehl:', before: '500 g', after: '550 g'),
        AppChangeText(semanticLabel: 'Salz hinzugefügt (5 g)', subject: 'Salz', after: '5 g'),
        AppChangeText(semanticLabel: 'Butter: anderes verknüpft', subject: 'Butter:', note: 'anderes verknüpft'),
      ]),
    );
    final c = _colors(variant);
    final old = tester.widget<Text>(find.text('500 g')).style!;
    expect(old.decoration, TextDecoration.lineThrough);
    expect(old.color, c.textSecondary);
    expect(find.byIcon(AppIcons.arrow), findsOneWidget, reason: 'Pfeil nur bei alt → neu');
    expect(find.ancestor(of: find.text('550 g'), matching: find.byType(AppHighlight)), findsOneWidget);
    expect(find.ancestor(of: find.text('5 g'), matching: find.byType(AppHighlight)), findsOneWidget);
    expect(find.bySemanticsLabel('Mehl: 500 g → 550 g'), findsOneWidget);
    expect(find.bySemanticsLabel('Salz hinzugefügt (5 g)'), findsOneWidget);
    expect(find.text('anderes verknüpft'), findsOneWidget);
    handle.dispose();
  });

  testVariants('DS-58: AppValue bekannt, unbekannt, unvollständig', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppValue(key: Key('k'), value: '1,80', unit: 'g'),
        AppValue(key: Key('u'), value: '0', unit: 'g', certainty: AppCertainty.unknown),
        AppValue.strong(key: Key('i'), value: '343', unit: 'ml'),
        AppValue.display(key: Key('d'), value: '3.500', unit: 'x'),
      ]),
    );
    final c = _colors(variant);
    RichText rich(String key) =>
        tester.widget<RichText>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(RichText)));
    // Text.rich legt den eigenen Span unter einen Span mit dem Umgebungsstil.
    TextSpan inner(String key) => (rich(key).text as TextSpan).children!.single as TextSpan;

    final known = inner('k');
    expect(known.toPlainText(), '1,80 g');
    expect(known.style!.fontFeatures, AppTypography.data.fontFeatures);
    final unit = known.children![1] as TextSpan;
    expect(unit.style!.color, c.textSecondary);
    expect(unit.style!.fontWeight, AppTypography.body.fontWeight);

    expect(rich('u').text.toPlainText(), '—', reason: 'unbekannt nie „0“');
    expect(rich('u').text.style!.color, c.textSecondary);

    final display = inner('d');
    expect(display.style!.fontSize, AppTypography.display.fontSize);
    expect((display.children![1] as TextSpan).style!.fontWeight, AppTypography.bodyStrong.fontWeight);
  });

  testVariants('DS-58: AppValue unvollständig mit Stern', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const AppValue.strong(value: '343', unit: 'g', certainty: AppCertainty.incomplete),
    );
    final span = (tester.widget<RichText>(find.byType(RichText).last).text as TextSpan).children!.single as TextSpan;
    expect(span.toPlainText(), '343 g*');
    expect((span.children!.last as TextSpan).style!.fontWeight, AppTypography.dataStrong.fontWeight);
  });
}
