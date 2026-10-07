// lib/catalog/feedback.dart
//
// Komponenten: Hinweise, Zustände, Meldungen, Dialoge.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „feedback“.
final feedbackFolder = WidgetbookFolder(name: 'feedback', children: [
  component('AppNotice', [
    useCase('Feedback/Notice', (_) => const AppStack(gap: AppSpace.s, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppNotice('Speichern fehlgeschlagen.', kind: AppNoticeKind.error),
          AppNotice('Wert ungewöhnlich hoch.', kind: AppNoticeKind.warning),
          AppNotice('Eingefroren — als neuen Entwurf kopieren?',
              action: AppButton.tertiary(label: 'Kopieren', onPressed: noop)),
        ])),
  ]),
  component('AppEmptyState', [
    pageUseCase('Feedback/Empty State', (_) => const Scaffold(
          body: AppEmptyState(
            icon: AppIcons.book,
            message: 'Noch keine Einträge.',
            action: AppButton.primary(label: 'Ersten Eintrag anlegen', onPressed: noop),
          ),
        )),
    pageUseCase('nur Satz', (_) => const Scaffold(body: AppEmptyState(message: 'Keine Treffer.'))),
  ]),
  component('AppErrorState', [
    pageUseCase('Feedback/Error State', (_) => const Scaffold(
          body: AppErrorState(message: 'Verbindung verloren.', retryLabel: 'Erneut versuchen', onRetry: noop),
        )),
  ]),
  component('AppLoading', [
    pageUseCase('Feedback/Loading', (_) => const Scaffold(body: AppLoading())),
  ]),
  component('AppProgressBar', [
    useCase('Feedback/Progress Bar', (_) => const AppProgressBar()),
  ]),
  component('AppSkeleton', [
    useCase('Feedback/Skeleton', (_) => const AppSkeleton(semanticLabel: 'Wird geladen', count: 3)),
  ]),
  component('AppMessenger', [
    useCase('Feedback/Snackbar', (context) => AppStack(gap: AppSpace.s, children: [
          AppButton.secondary(label: 'Meldung', onPressed: () => showAppMessage(context, 'Gespeichert.')),
          AppButton.secondary(
            label: 'Meldung mit Rückgängig',
            onPressed: () => AppMessenger.of(context).showWithAction(
              message: '„Eintrag“ gelöscht',
              actionLabel: 'Rückgängig',
              onAction: noop,
              duration: const Duration(seconds: 5),
            ),
          ),
        ])),
  ]),
  component('AppDialog', [
    useCase('Feedback/Dialog', (_) => const AppDialog(
          title: 'Auswählen',
          content: Text('Freier Inhalt'),
          actions: [AppButton.tertiary(label: 'Abbrechen', onPressed: noop)],
        )),
    useCase('Rückfrage und Auswahl', (context) => AppStack(gap: AppSpace.s, children: [
          AppButton.secondary(
            label: 'Rückfrage',
            onPressed: () => showAppConfirmDialog(context,
                title: 'Änderungen verwerfen?',
                message: 'Deine Eingaben sind noch nicht gespeichert.',
                confirmLabel: 'Verwerfen',
                cancelLabel: 'Abbrechen'),
          ),
          AppButton.secondary(
            label: 'Auswahl',
            onPressed: () => showAppChoiceDialog<int>(context,
                title: 'Welche?',
                options: const [AppSelectItem(1, 'V1'), AppSelectItem(2, 'V2')],
                emptyMessage: 'Nichts zur Auswahl.'),
          ),
          AppButton.secondary(
            label: 'Über',
            onPressed: () => showAppAboutDialog(context, applicationName: 'Katalog'),
          ),
        ])),
  ]),
]);
