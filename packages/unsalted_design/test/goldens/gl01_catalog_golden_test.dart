// test/goldens/gl01_catalog_golden_test.dart
//
// GL-01 (Teil 1.3, D01; Motiv „marken“ seit D07): Katalogbilder je
// Komponentengruppe, je acht
// Varianten (support/golden_harness.dart). Die Motive entsprechen den
// Ordnern des Widgetbook-Katalogs; Inhalte sind Beispieltexte ohne
// Fachbegriffe. Nur unter Linux (docs/design/plan-1.3.md, d4).
@TestOn('linux')
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'support/golden_harness.dart';

void _noop() {}

/// Inhalt auf einer Seite mit Rand, scrollbar wie im Katalog.
Widget _sheet(List<Widget> children) => Scaffold(
      body: SingleChildScrollView(
        child: AppPadding.all(
          AppSpace.l,
          child: AppStack(gap: AppSpace.m, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );

Widget _colors() => Builder(builder: (context) {
      final tokens = Theme.of(context).brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
      return _sheet([
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final MapEntry(key: name, value: color) in tokens.byFigmaName.entries)
            SizedBox(
              width: 170,
              child: Row(children: [
                SizedBox.square(dimension: 24, child: ColoredBox(color: color)),
                const SizedBox(width: 8),
                Expanded(child: Text(name.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
        ]),
      ]);
    });

Widget _type() => _sheet([
      for (final MapEntry(key: name, value: style) in AppTypography.byFigmaName.entries)
        Text(name.split('/').last, style: style),
    ]);

Widget _buttons() => _sheet(const [
      AppButton.primary(label: 'Speichern', onPressed: _noop),
      AppButton.secondary(label: 'Einfrieren', onPressed: _noop),
      AppButton.tertiary(label: 'Abbrechen', onPressed: _noop),
      AppButton.primary(label: 'Hinzufügen', icon: AppIcons.add, onPressed: _noop),
      AppButton.secondary(label: 'Kopieren', icon: AppIcons.copy, onPressed: _noop),
      AppButton.primary(label: 'Gesperrt', onPressed: null),
      AppButton.secondary(label: 'Gesperrt', onPressed: null),
      Row(children: [
        AppIconButton(icon: AppIcons.edit, tooltip: 'Bearbeiten', onPressed: _noop),
        AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: _noop),
        AppIconButton(icon: AppIcons.deleteOutline, tooltip: 'Entfernen', onPressed: null),
      ]),
      Row(children: [
        AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: _noop),
        SizedBox(width: 16),
        AppFab(icon: AppIcons.check, tooltip: 'Speichern', loading: true, onPressed: _noop),
      ]),
    ]);

Widget _brand() => _sheet(const [
      Wrap(spacing: 8, runSpacing: 8, children: [
        AppMark(label: 'V3', state: AppMarkState.provisional),
        AppMark(label: 'V2', state: AppMarkState.fixed, seal: true),
        AppMark(label: 'V1 · Basis', state: AppMarkState.highlighted),
      ]),
      Row(children: [
        AppMark(label: 'V3', state: AppMarkState.provisional, onTap: _noop),
        AppMark(label: 'V2', state: AppMarkState.fixed, selected: true, onTap: _noop),
        AppMark(label: 'V1', state: AppMarkState.highlighted, onTap: _noop),
      ]),
      AppFrame.provisional(
        mark: AppMark(label: 'V4', state: AppMarkState.provisional),
        caption: 'Entwurf · offen',
        child: Text('Inhalt des Arbeitsstands'),
      ),
      AppFrame.fixed(
        mark: AppMark(label: 'V3', state: AppMarkState.fixed, seal: true),
        caption: 'fest',
        child: Text('Inhalt des festen Stands'),
      ),
      AppSlot(icon: AppIcons.photo, message: 'Noch kein Bild.', action: AppButton.secondary(label: 'Hinzufügen', onPressed: _noop)),
      AppDashedUnderline(child: Text('Eintrag ohne Verknüpfung')),
      AppChangeText(semanticLabel: 'Eins: 500 g → 550 g', subject: 'Eins:', before: '500 g', after: '550 g'),
      AppChangeText(semanticLabel: 'Zwei hinzugefügt', subject: 'Zwei', after: '5 g'),
      Wrap(spacing: 16, children: [
        AppValue(value: '1,80', unit: 'g'),
        AppValue(value: '0', unit: 'g', certainty: AppCertainty.unknown),
        AppValue.strong(value: '343', unit: 'g', certainty: AppCertainty.incomplete),
        AppValue.display(value: '3.500', unit: 'x'),
      ]),
    ]);

Widget _textAndIcons() => _sheet([
      const AppText('Fließtext in der Grundrolle.'),
      const AppText.strong('Hervorgehobener Text'),
      const AppText.title('Titel'),
      const AppText.caption('Kleingedrucktes', tone: AppTone.muted),
      const AppText('Fehlertext', tone: AppTone.error),
      const AppText('Ein langer Text, der auf eine Zeile gekürzt wird, damit nichts umbricht.', maxLines: 1),
      Wrap(spacing: 16, runSpacing: 16, children: [
        for (final icon in AppIcons.byFigmaName.values) AppIcon(icon),
      ]),
    ]);

Widget _surfaces() => _sheet(const [
      AppCard(onTap: _noop, child: AppText('Antippbare Karte')),
      AppSurface(tone: AppSurfaceTone.low, child: Text('Fläche low')),
      AppSurface(child: Text('Fläche medium')),
      AppSurface(tone: AppSurfaceTone.high, fullWidth: true, child: Text('Fläche high, volle Breite')),
      AppSurface(tone: AppSurfaceTone.info, child: Text('Hinweis ohne Symbol')),
      AppSurface(tone: AppSurfaceTone.warning, child: Text('Warnung ohne Symbol')),
      AppSurface(tone: AppSurfaceTone.error, child: Text('Fehler ohne Symbol')),
      AppDivider(),
      AppSection(title: 'Abschnitt', children: [Text('Inhalt des Abschnitts.')]),
    ]);

Widget _inputs() => _sheet([
      const AppTextField(label: 'Titel'),
      const AppTextField(label: 'Mit Startwert', initialValue: 'Wert'),
      const AppTextField(label: 'Menge', error: 'Ungültige Zahl'),
      const AppTextField(label: 'Name', helper: 'Hilfetext unter dem Feld.'),
      const AppTextField(label: 'Gesperrt', initialValue: 'fest', enabled: false),
      const AppSearchField(hint: 'Suchen …'),
      AppSelect<String>(
        label: 'Auswahl',
        items: const [AppSelectItem('a', 'Eins'), AppSelectItem('b', 'Zwei')],
        value: 'a',
        onChanged: (_) {},
      ),
      AppSelect<String>(
        items: const [AppSelectItem('g', 'g'), AppSelectItem('ml', 'ml')],
        value: 'g',
        onChanged: (_) {},
      ),
    ]);

Widget _listsAndChips() => Scaffold(
      body: AppItemList(children: [
        const AppListItem(title: 'Titel', onTap: _noop),
        const AppListItem(title: 'Titel', subtitle: 'Untertitel', onTap: _noop),
        const AppListItem(title: 'Mit Elementen', leading: AppIcon(AppIcons.star), trailing: AppChip(label: '1:30')),
        const AppListItem(title: 'Kompakt', dense: true),
        AppSwipeToDelete(key: const ValueKey('wischen'), onDelete: _noop, child: const AppListItem(title: 'Wischbar')),
        AppPadding.all(
          AppSpace.l,
          child: const AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
            AppChoiceChip(label: 'Gewählt', selected: true, onSelected: _noop),
            AppChoiceChip(label: 'Nicht gewählt', selected: false, onSelected: _noop),
            AppChip(label: '12:00'),
          ]),
        ),
      ]),
    );

Widget _feedback() => _sheet(const [
      AppNotice('Speichern fehlgeschlagen.', kind: AppNoticeKind.error),
      AppNotice('Wert ungewöhnlich hoch.', kind: AppNoticeKind.warning),
      AppNotice('Hinweis mit Aktion.', action: AppButton.tertiary(label: 'Kopieren', onPressed: _noop)),
      SizedBox(
        height: 240,
        child: AppEmptyState(
          icon: AppIcons.book,
          message: 'Noch keine Einträge.',
          action: AppButton.primary(label: 'Ersten Eintrag anlegen', onPressed: _noop),
        ),
      ),
      SizedBox(
        height: 160,
        child: AppErrorState(message: 'Verbindung verloren.', retryLabel: 'Erneut versuchen', onRetry: _noop),
      ),
      SizedBox(height: 64, child: AppLoading()),
      AppProgressBar(),
      AppDialog(
        title: 'Auswählen',
        content: Text('Freier Inhalt des Dialogs.'),
        actions: [AppButton.tertiary(label: 'Abbrechen', onPressed: _noop)],
      ),
    ]);

Widget _navigation() => Scaffold(
      appBar: const AppTopBar(
        title: 'Titel',
        actions: [
          AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: _noop),
          AppOverflowMenu(entries: [AppMenuEntry(label: 'Löschen', onSelected: _noop)]),
        ],
        bottom: AppSearchField(hint: 'Suchen …'),
      ),
      body: const SizedBox.shrink(),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: 0,
        onSelected: (_) {},
        destinations: const [
          AppNavigationDestination(icon: AppIcons.book, label: 'Eins'),
          AppNavigationDestination(icon: AppIcons.restaurant, label: 'Zwei'),
          AppNavigationDestination(icon: AppIcons.settings, label: 'Drei'),
        ],
      ),
    );

Widget _data() => Scaffold(
      body: FormSections.fixed(children: [
        const AppKeyValueTable(
          headers: ['Spalte A', 'Spalte B'],
          rows: [
            AppTableRow('Erste Zeile', ['12', '3,4']),
            AppTableRow('davon Teil', ['5', '0,6']),
            AppTableRow('Letzte Zeile mit langer Bezeichnung', ['1,2', '0,1']),
          ],
        ),
        Expanded(child: AppCodeBlock('{\n  "format": 1,\n  "items": [\n${'    {"a": 1},\n' * 12}  ]\n}')),
      ]),
    );

Widget _listTemplate() => ListPageTemplate(
      title: 'Liste',
      search: const AppSearchField(hint: 'Suchen …'),
      body: AppItemList.builder(
        itemCount: 20,
        itemBuilder: (context, i) => AppListItem(title: 'Eintrag ${i + 1}', subtitle: 'Beschreibung', onTap: _noop),
      ),
      primaryAction: const AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: _noop),
    );

Widget _detailTemplate() => DetailPageTemplate(
      title: 'Detail',
      actions: const [
        AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: _noop),
        AppOverflowMenu(entries: [AppMenuEntry(label: 'Löschen', onSelected: _noop)]),
      ],
      body: DetailSections(
        sections: const [
          AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
            AppChoiceChip(label: 'V2', selected: true, onSelected: _noop),
            AppChoiceChip(label: 'V1', selected: false, onSelected: _noop),
          ]),
          AppText('Beschreibung des Eintrags.'),
          AppKeyValueTable(headers: ['A', 'B'], rows: [AppTableRow('Wert', ['1', '2'])]),
        ],
        secondary: [
          AppSection(title: 'Teile', children: [for (var i = 1; i <= 4; i++) AppListItem(title: 'Teil $i')]),
          AppSection(title: 'Schritte', children: [
            for (var i = 1; i <= 3; i++) AppListItem(title: 'Schritt $i', trailing: const AppChip(label: '5:00')),
          ]),
        ],
      ),
    );

Widget _formTemplate() => const FormPageTemplate(
      title: 'Bearbeiten',
      header: AppSurface(fullWidth: true, child: AppText('Vorschau: 1234')),
      messages: [AppText('Speichern fehlgeschlagen.', tone: AppTone.error)],
      body: FormSections(children: [
        AppTextField(label: 'Titel'),
        AppTextField(label: 'Beschreibung', maxLines: 4),
        AppSection(title: 'Teile', children: [AppTextField(label: 'Name')]),
      ]),
      bottomBar: AppBottomActionBar(actions: [
        AppButton.secondary(label: 'Einfrieren', onPressed: _noop),
        AppButton.primary(label: 'Speichern', onPressed: _noop),
      ]),
    );

/// Zeigt auf der Listenseite eine Meldung mit „Rückgängig“ (Snackbar).
Future<void> _showUndoMessage(WidgetTester tester) async {
  AppMessenger.of(tester.element(find.byType(ListPageTemplate))).showWithAction(
    message: '„Eintrag 3“ gelöscht',
    actionLabel: 'Rückgängig',
    onAction: _noop,
    duration: const Duration(seconds: 5),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(loadGoldenFonts);

  testGolden('GL-01', 'tokens_farbe', _colors);
  testGolden('GL-01', 'tokens_typo', _type);
  testGolden('GL-01', 'aktionen', _buttons);
  testGolden('GL-01', 'text_symbole', _textAndIcons);
  testGolden('GL-01', 'marken', _brand);
  testGolden('GL-01', 'flaechen', _surfaces);
  testGolden('GL-01', 'eingaben', _inputs);
  testGolden('GL-01', 'listen_chips', _listsAndChips);
  testGolden('GL-01', 'rueckmeldung', _feedback);
  testGolden('GL-01', 'navigation', _navigation);
  testGolden('GL-01', 'daten', _data);
  testGolden('GL-01', 'template_liste', _listTemplate, after: _showUndoMessage);
  testGolden('GL-01', 'template_detail', _detailTemplate);
  testGolden('GL-01', 'template_formular', _formTemplate);
}
