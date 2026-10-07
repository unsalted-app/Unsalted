// lib/catalog/templates.dart
//
// Templates: Listen-, Detail- und Formularseite mit Beispielinhalt.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „Templates“.
final templatesFolder = WidgetbookFolder(name: 'Templates', children: [
  component('ListPageTemplate', [
    pageUseCase('Template/List Page', (_) => ListPageTemplate(
          title: 'Liste',
          search: const AppSearchField(hint: 'Suchen …'),
          body: AppItemList.builder(
            itemCount: 30,
            itemBuilder: (context, i) => AppListItem(title: 'Eintrag ${i + 1}', subtitle: 'Beschreibung', onTap: noop),
          ),
          primaryAction: const AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: noop),
        )),
    pageUseCase('leer', (_) => const ListPageTemplate(
          title: 'Liste',
          search: AppSearchField(hint: 'Suchen …'),
          body: AppEmptyState(
            icon: AppIcons.book,
            message: 'Noch keine Einträge.',
            action: AppButton.primary(label: 'Ersten Eintrag anlegen', onPressed: noop),
          ),
          primaryAction: AppFab(icon: AppIcons.add, tooltip: 'Neu', onPressed: noop),
        )),
  ]),
  component('DetailPageTemplate', [
    pageUseCase('Template/Detail Page', (_) => DetailPageTemplate(
          title: 'Detail',
          actions: [
            const AppIconButton(icon: AppIcons.history, tooltip: 'Verlauf', onPressed: noop),
            const AppOverflowMenu(entries: [AppMenuEntry(label: 'Löschen', onSelected: noop)]),
          ],
          showProgress: true,
          body: DetailSections(
            sections: [
              const AppStack(direction: Axis.horizontal, gap: AppSpace.s, children: [
                AppChoiceChip(label: 'V2', selected: true, onSelected: noop),
                AppChoiceChip(label: 'V1', selected: false, onSelected: noop),
              ]),
              const AppText('Beschreibung des Eintrags.'),
              const AppKeyValueTable(headers: ['A', 'B'], rows: [AppTableRow('Wert', ['1', '2'])]),
            ],
            secondary: [
              AppSection(title: 'Teile', children: [for (var i = 1; i <= 5; i++) AppListItem(title: 'Teil $i')]),
              AppSection(title: 'Schritte', children: [
                for (var i = 1; i <= 5; i++) AppListItem(title: 'Schritt $i', trailing: const AppChip(label: '5:00')),
              ]),
            ],
          ),
        )),
    pageUseCase('geteilt (DetailSplit)', (_) => const DetailPageTemplate(
          title: 'Vergleich',
          body: DetailSplit(
            primary: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: AppPadding.all(AppSpace.s, child: AppText.title('A'))),
              AppDivider.vertical(),
              Expanded(child: AppPadding.all(AppSpace.s, child: AppText.title('B'))),
            ]),
            secondary: AppEmptyState(message: 'Keine Unterschiede.'),
            footer: [AppBottomActionBar(actions: [AppButton.primary(label: 'Übernehmen', onPressed: null)])],
          ),
        )),
  ]),
  component('FormPageTemplate', [
    pageUseCase('Template/Form Page', (_) => const FormPageTemplate(
          title: 'Bearbeiten',
          header: AppSurface(fullWidth: true, child: AppText('Vorschau: 1234')),
          messages: [AppText('Speichern fehlgeschlagen.', tone: AppTone.error)],
          body: FormSections(children: [
            AppTextField(label: 'Titel'),
            AppTextField(label: 'Beschreibung', maxLines: 4),
            AppSection(title: 'Teile', children: [AppTextField(label: 'Name')]),
          ]),
          bottomBar: AppBottomActionBar(actions: [
            AppButton.secondary(label: 'Einfrieren', onPressed: noop),
            AppButton.primary(label: 'Speichern', onPressed: noop),
          ]),
        )),
    pageUseCase('mit Hauptaktion', (_) => const FormPageTemplate(
          title: 'Anlegen',
          body: FormSections(children: [AppTextField(label: 'Titel')]),
          primaryAction: AppFab(icon: AppIcons.check, tooltip: 'Speichern', onPressed: noop),
        )),
  ]),
]);
