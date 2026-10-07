// lib/src/templates/form_page_template.dart
//
// Template (Teil 1.2): Formularseite (Figma `Template/Form Page`) —
// Kopfleiste, optional eine Leiste über dem Inhalt, Meldungen, Inhalt und
// Aktionsleiste oder Hauptaktion. Der Inhalt steht immer an derselben Stelle
// (fester Key), damit Meldungen ihn beim Erscheinen nicht neu aufbauen und
// Eingaben erhalten bleiben.
//
// Inhalt-Layout: `FormSections` (scrollend) oder `FormSections.fixed` (fest,
// für Inhalte mit `Expanded`).

import 'package:flutter/widgets.dart';

import '../components/navigation/app_top_bar.dart';
import '../layout/app_page.dart';
import '../layout/app_stack.dart';
import '../tokens/spacing_tokens.dart';

/// Formularseite.
class FormPageTemplate extends StatelessWidget {
  /// Erzeugt die Seite.
  const FormPageTemplate({
    super.key,
    required this.title,
    this.actions = const [],
    this.header,
    this.messages = const [],
    required this.body,
    this.bottomBar,
    this.primaryAction,
  });

  /// Titel der Kopfleiste.
  final String title;

  /// Aktionen der Kopfleiste.
  final List<Widget> actions;

  /// Leiste über dem Inhalt in voller Breite, z. B. eine Vorschau.
  final Widget? header;

  /// Meldungen über dem Inhalt, z. B. `AppText` mit Fehlerton.
  final List<Widget> messages;

  /// Inhalt im aktuellen Zustand, in der Regel `FormSections`.
  final Widget body;

  /// Aktionsleiste unten, in der Regel `AppBottomActionBar`.
  final Widget? bottomBar;

  /// Hauptaktion, in der Regel `AppFab`.
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) => AppPage(
        topBar: AppTopBar(title: title, actions: actions),
        primaryAction: primaryAction,
        body: AppStack(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?header,
            for (final message in messages) AppPadding.all(AppSpace.s, child: message),
            Expanded(key: const ValueKey('form-page-body'), child: body),
            ?bottomBar,
          ],
        ),
      );
}

/// Abschnitte einer Formularseite mit Innenabstand `space/l`.
class FormSections extends StatelessWidget {
  /// Scrollend.
  const FormSections({super.key, required this.children}) : scrolls = true;

  /// Fest, volle Breite; Kinder dürfen `Expanded` sein.
  const FormSections.fixed({super.key, required this.children}) : scrolls = false;

  /// Abschnitte.
  final List<Widget> children;

  /// `true`: scrollt.
  final bool scrolls;

  @override
  Widget build(BuildContext context) => scrolls
      ? ListView(padding: EdgeInsets.all(AppSpace.l.value), children: children)
      : AppPadding.all(
          AppSpace.l,
          child: AppStack(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        );
}
