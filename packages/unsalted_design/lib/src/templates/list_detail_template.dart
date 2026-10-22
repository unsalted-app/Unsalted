// lib/src/templates/list_detail_template.dart
//
// Template (Teil 1.4, T01): Liste und Detail nebeneinander (Figma Tablet
// „01+04“ `147:9746`, „09+10“ `147:9823`; ohne Auswahl `219:4396`,
// `219:4706`). Ab `breakpoint-expanded` (Fenstergröße, wie Material und die
// Seitenleiste) steht die Liste in `size-list-pane`, daneben füllt das Detail
// den Rest, abgesetzt durch eine Haarlinie links (`line-hairline`). Ohne
// Detail zeigt die Fläche nur das Punktraster (`line-dot`) — ohne Text
// (Figma-Nachtrag N3). Darunter nur die Liste; der Bildschirm navigiert dann
// wie bisher. Liste und Detail bringen ihre eigenen Seiten (Kopfleiste,
// Marker-Knopf) mit; beide stehen in einer gemeinsamen Seite, damit eine
// Meldung (z. B. „Rückgängig“) einmal über die ganze Breite erscheint und
// nicht in jeder der beiden Seiten.

import 'package:flutter/widgets.dart';

import '../components/brand/dot_pattern.dart';
import '../layout/app_page.dart';
import '../layout/responsive.dart';
import '../theme/app_colors.dart';
import '../tokens/size_tokens.g.dart';
import '../tokens/stroke_tokens.g.dart';

/// Liste und Detail nebeneinander ab `breakpoint-expanded`.
class ListDetailTemplate extends StatelessWidget {
  /// Erzeugt das Template; ohne [detail] bleibt der Detailbereich leer.
  const ListDetailTemplate({super.key, required this.list, this.detail});

  /// Die Liste (z. B. ein `ListPageTemplate`).
  final Widget list;

  /// Das gewählte Detail; `null` = keine Auswahl (Punktraster).
  final Widget? detail;

  /// `true`: das Fenster ist so breit, dass Liste und Detail nebeneinander
  /// stehen — Tippen in der Liste wählt aus, statt zu navigieren.
  static bool isSplit(BuildContext context) => AppWindowSize.of(context).index >= AppWindowSize.expanded.index;

  @override
  Widget build(BuildContext context) {
    if (!isSplit(context)) return list;
    final c = AppColors.of(context);
    return AppPage(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: AppSize.listPane, child: list),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.surfacePage,
                border: Border(left: BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: AppStroke.hairline),
                child: detail ?? CustomPaint(painter: DotPatternPainter(color: c.lineDot), child: const SizedBox.expand()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
