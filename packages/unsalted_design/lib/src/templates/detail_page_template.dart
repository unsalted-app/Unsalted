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
//
// Seit Teil 1.3 (D11, Figma `Template/Detail Page`): Inhalt im Rahmen
// „Inhalt“ (Seitenrand `space-l`, ab `breakpoint-medium` `space-xl`, höchstens
// `size-content-max`, mittig); zweispaltig ab `breakpoint-large`, je Spalte
// ein eigener Rahmen (Figma Tablet quer, `Spalten`/`Haupt`/`Neben`); der obere
// Bereich von `DetailSplit` scrollt, wenn er höher ist als seine Hälfte.

import 'package:flutter/widgets.dart';

import '../components/feedback/app_loading.dart';
import '../components/navigation/app_top_bar.dart';
import '../components/surfaces/app_divider.dart';
import '../layout/app_page.dart';
import '../layout/app_stack.dart';
import '../layout/responsive.dart';
import '../tokens/size_tokens.g.dart';
import '../tokens/spacing_tokens.g.dart';
import 'page_content.dart';

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

/// Anordnung der Abschnitte einer Detailseite. Maßgeblich ist die
/// Fenstergröße (Material 3), nicht die Breite des Inhalts.
enum DetailLayout {
  /// immer eine Spalte.
  oneColumn,

  /// ab `AppWindowSize.expanded` Haupt- und Nebenabschnitte nebeneinander.
  twoColumnsFromExpanded,

  /// ab `AppWindowSize.large` Haupt- und Nebenabschnitte nebeneinander.
  twoColumnsFromLarge;

  /// Zentrale Einstellung für alle Detailseiten: seit Teil 1.3 zweispaltig ab
  /// `breakpoint-large` (UEBERGABE Punkt 2).
  static const standard = DetailLayout.twoColumnsFromLarge;

  /// `true`: bei Fenstergröße [size] zweispaltig.
  bool twoColumnsAt(AppWindowSize size) => switch (this) {
        oneColumn => false,
        twoColumnsFromExpanded => size.isAtLeast(AppWindowSize.expanded),
        twoColumnsFromLarge => size.isAtLeast(AppWindowSize.large),
      };
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
  Widget build(BuildContext context) {
    final size = AppWindowSize.of(context);
    if (secondary.isEmpty || !layout.twoColumnsAt(size)) {
      return PageContent(
        builder: (context, padding) => ListView(padding: padding, children: [...sections, ...secondary]),
      );
    }
    final margin = size.pageMargin.value;
    final padding = EdgeInsets.fromLTRB(margin, AppSpacing.l, margin, AppSpacing.l);
    Widget column(List<Widget> children) => Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSize.contentMax),
            child: ListView(padding: padding, children: children),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [column(sections), column(secondary)],
    );
  }
}

/// Zwei Bereiche übereinander, getrennt durch eine Linie, darunter die
/// [footer]-Elemente (z. B. Meldung und Aktionsleiste). Der obere Bereich
/// steht im Rahmen „Inhalt“ und scrollt (er darf selbst nicht scrollen); der
/// untere ist höchstens `size-content-max` breit und scrollt selbst, z. B. als
/// Liste. Die Fußzeile steht in voller Breite.
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageContent(builder: (context, padding) => SingleChildScrollView(padding: padding, child: primary)),
          ),
          const AppDivider.flush(),
          Expanded(
            child: Center(
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppSize.contentMax), child: secondary),
            ),
          ),
          ...footer,
        ],
      );
}
