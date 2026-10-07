// test/templates/ds46_templates_test.dart
//
// DS-46 bis DS-48 (Teil 1.2): ListPageTemplate, DetailPageTemplate (mit
// DetailSections/DetailSplit) und FormPageTemplate (mit FormSections). Die
// Templates halten den Inhalt stabil: Ladebalken und Meldungen bauen ihn nicht
// neu auf.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

/// Inhalt mit eigenem Zustand: zählt, wie oft sein State neu entsteht.
class _Probe extends StatefulWidget {
  const _Probe(this.created);

  final List<int> created;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.created.add(1);
  }

  @override
  Widget build(BuildContext context) => const Text('Sonde');
}

void main() {
  testVariants('DS-46: ListPageTemplate', (tester, variant) async {
    var taps = 0;
    await pumpVariant(
      tester,
      variant,
      ListPageTemplate(
        title: 'Liste',
        search: const AppSearchField(hint: 'Suchen …'),
        body: const AppItemList(children: [AppListItem(title: 'Eintrag')]),
        primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: () => taps++),
      ),
      wrapInPage: false,
    );
    expect(find.widgetWithText(AppBar, 'Liste'), findsOneWidget);
    expect(find.descendant(of: find.byType(AppBar), matching: find.byType(TextField)), findsOneWidget);
    expect(find.text('Eintrag'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    expect(taps, 1);
  });

  testVariants('DS-47: Ladebalken baut den Inhalt nicht neu auf', (tester, variant) async {
    final created = <int>[];
    var progress = false;
    late StateSetter setState;
    await pumpVariant(
      tester,
      variant,
      StatefulBuilder(builder: (context, set) {
        setState = set;
        return DetailPageTemplate(
          title: 'Detail',
          actions: [AppIconButton(icon: AppIcons.edit, tooltip: 'Bearbeiten', onPressed: () {})],
          showProgress: progress,
          body: DetailSections(sections: [_Probe(created), for (var i = 0; i < 120; i++) Text('Zeile $i')]),
        );
      }),
      wrapInPage: false,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    final offset = tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
    expect(offset, greaterThan(0));
    setState(() => progress = true);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    setState(() => progress = false);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels, offset);
    expect(created, hasLength(1));
    expect(find.byTooltip('Bearbeiten'), findsOneWidget);
  });

  testVariants('DS-47: DetailSections ein- und zweispaltig', (tester, variant) async {
    Future<void> pump(DetailLayout layout) => pumpVariant(
          tester,
          variant,
          DetailSections(layout: layout, sections: const [Text('Haupt')], secondary: const [Text('Neben')]),
        );
    await pump(DetailLayout.standard);
    expect(DetailLayout.standard, DetailLayout.oneColumn);
    expect(tester.getTopLeft(find.text('Neben')).dy, greaterThan(tester.getTopLeft(find.text('Haupt')).dy));
    expect(tester.getTopLeft(find.text('Haupt')), const Offset(AppSpacing.l, AppSpacing.l));

    await pump(DetailLayout.twoColumnsFromExpanded);
    final wide = AppWindowSize.forWidth(variant.size.width).isAtLeast(AppWindowSize.expanded);
    if (wide) {
      expect(tester.getTopLeft(find.text('Neben')).dy, tester.getTopLeft(find.text('Haupt')).dy);
      expect(tester.getTopLeft(find.text('Neben')).dx, greaterThan(variant.size.width / 2));
    } else {
      expect(tester.getTopLeft(find.text('Neben')).dy, greaterThan(tester.getTopLeft(find.text('Haupt')).dy));
    }
  });

  testVariants('DS-47: DetailSplit mit Fußzeile', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      DetailPageTemplate(
        title: 'Vergleich',
        body: DetailSplit(
          primary: const Text('Oben'),
          secondary: const Text('Unten'),
          footer: [AppBottomActionBar(actions: [AppButton.primary(label: 'Übernehmen', onPressed: () {})])],
        ),
      ),
      wrapInPage: false,
    );
    final top = tester.getTopLeft(find.text('Oben')).dy;
    final bottom = tester.getTopLeft(find.text('Unten')).dy;
    final button = tester.getTopLeft(find.text('Übernehmen')).dy;
    expect(top, lessThan(bottom));
    expect(bottom, lessThan(button));
    expect(find.byType(Divider), findsOneWidget);
  });

  testVariants('DS-48: Meldungen bauen den Formularinhalt nicht neu auf', (tester, variant) async {
    final created = <int>[];
    var messages = <Widget>[];
    late StateSetter setState;
    await pumpVariant(
      tester,
      variant,
      StatefulBuilder(builder: (context, set) {
        setState = set;
        return FormPageTemplate(
          title: 'Formular',
          header: const AppSurface(fullWidth: true, child: Text('Vorschau')),
          messages: messages,
          body: FormSections(children: [_Probe(created), const AppTextField(label: 'Name')]),
          bottomBar: AppBottomActionBar(actions: [AppButton.primary(label: 'Speichern', onPressed: () {})]),
        );
      }),
      wrapInPage: false,
    );
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Brot');
    setState(() => messages = [const AppText('Fehler', tone: AppTone.error)]);
    await tester.pump();
    expect(find.text('Fehler'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Fehler')).dy, greaterThan(tester.getTopLeft(find.text('Vorschau')).dy));
    expect(tester.getTopLeft(find.text('Fehler')).dx, AppSpacing.s);
    expect(find.text('Brot'), findsOneWidget);
    expect(created, hasLength(1));
    expect(tester.getTopLeft(find.text('Speichern')).dy, greaterThan(tester.getTopLeft(find.text('Name')).dy));
  });

  testVariants('DS-48: FormSections.fixed mit Expanded', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const FormPageTemplate(
        title: 'Import',
        primaryAction: null,
        body: FormSections.fixed(children: [
          Expanded(child: AppTextField(label: 'Text', expands: true)),
          AppText('Unten'),
        ]),
      ),
      wrapInPage: false,
    );
    final field = tester.getRect(find.byType(TextField));
    expect(field.left, AppSpacing.l);
    expect(field.width, variant.size.width - 2 * AppSpacing.l);
    expect(tester.getTopLeft(find.text('Unten')).dy, greaterThanOrEqualTo(field.bottom));
  });
}
