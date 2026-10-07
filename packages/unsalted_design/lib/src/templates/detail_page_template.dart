// lib/src/templates/detail_page_template.dart
//
// Template (Teil 1.2): Detailseite (Figma `Template/Detail Page`) —
// Kopfleiste mit Aktionen, Inhalt, optional Ladebalken oben und Leiste unten.
// Der Inhalt liegt immer in einem `Stack`, damit das Ein- und Ausblenden des
// Ladebalkens den Inhalt (z. B. die Scrollposition) nicht neu aufbaut.
//
// Inhalt-Layouts: `DetailSections` (scrollende Abschnitte; ein- oder
// zweispaltig über die zentrale Einstellung `DetailLayout.standard`) und
// `DetailSplit` (zwei Bereiche übereinander mit Fußzeile).

import 'package:flutter/widgets.dart';

import '../components/feedback/app_loading.dart';
import '../components/navigation/app_top_bar.dart';
import '../components/surfaces/app_divider.dart';
import '../layout/app_page.dart';
import '../layout/app_stack.dart';
import '../layout/responsive.dart';
import '../tokens/spacing_tokens.dart';

/// Detailseite.
class DetailPageTemplate extends StatelessWidget {
  /// Erzeugt die Seite.
  const DetailPageTemplate({
    super.key,
    required this.title,
    this.actions = const [],
    required this.body,
    this.showProgress = false,
    this.bottomBar,
  });

  /// Titel der Kopfleiste.
  final String title;

  /// Aktionen der Kopfleiste.
  final List<Widget> actions;

  /// Inhalt im aktuellen Zustand, in der Regel `DetailSections` oder `DetailSplit`.
  final Widget body;

  /// `true`: Ladebalken über dem Inhalt.
  final bool showProgress;

  /// Leiste am unteren Rand.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) => AppPage(
        topBar: AppTopBar(title: title, actions: actions),
        body: Stack(
          fit: StackFit.expand,
          children: [
            body,
            if (showProgress) const Positioned(top: 0, left: 0, right: 0, child: AppProgressBar()),
          ],
        ),
        bottomBar: bottomBar,
      );
}

/// Anordnung der Abschnitte einer Detailseite.
enum DetailLayout {
  /// immer eine Spalte.
  oneColumn,

  /// ab `AppWindowSize.expanded` Haupt- und Nebenabschnitte nebeneinander.
  twoColumnsFromExpanded;

  /// Zentrale Einstellung für alle Detailseiten. Zunächst einspaltig wie vor
  /// Teil 1.2; die Umstellung auf zwei Spalten ist eine Änderung hier.
  static const standard = DetailLayout.oneColumn;
}

/// Scrollende Abschnitte einer Detailseite. Einspaltig stehen die
/// [secondary]-Abschnitte unter den [sections].
class DetailSections extends StatelessWidget {
  /// Erzeugt die Abschnitte. [layout] geben Bildschirme nicht an — es gilt die
  /// zentrale Einstellung `DetailLayout.standard`.
  const DetailSections({
    super.key,
    required this.sections,
    this.secondary = const [],
    this.layout = DetailLayout.standard,
  });

  /// Hauptabschnitte.
  final List<Widget> sections;

  /// Nebenabschnitte.
  final List<Widget> secondary;

  /// Anordnung.
  final DetailLayout layout;

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(builder: (context, size) {
        final twoColumns = layout == DetailLayout.twoColumnsFromExpanded &&
            secondary.isNotEmpty &&
            size.isAtLeast(AppWindowSize.expanded);
        if (!twoColumns) return _column([...sections, ...secondary]);
        return AppStack(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [Expanded(child: _column(sections)), Expanded(child: _column(secondary))],
        );
      });

  static Widget _column(List<Widget> children) =>
      ListView(padding: EdgeInsets.all(AppSpace.l.value), children: children);
}

/// Zwei Bereiche übereinander, getrennt durch eine Linie, darunter die
/// [footer]-Elemente (z. B. Meldung und Aktionsleiste).
class DetailSplit extends StatelessWidget {
  /// Erzeugt die Aufteilung.
  const DetailSplit({super.key, required this.primary, required this.secondary, this.footer = const []});

  /// oberer Bereich.
  final Widget primary;

  /// unterer Bereich.
  final Widget secondary;

  /// Elemente unter beiden Bereichen.
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) => AppStack(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: primary),
          const AppDivider.flush(),
          Expanded(child: secondary),
          ...footer,
        ],
      );
}
