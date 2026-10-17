// lib/src/components/data/app_figure_row.dart
//
// Komponente (Teil 1.3, D15a): Kennzahlenleiste (Figma-Bibliothek `142:57`
// und `142:56`, fachneutral wegen DS-06). Felder teilen
// die Breite; oben und unten eine Haarlinie, ab dem zweiten Feld links eine
// Haarlinie (`reflow-rule-inline`) und `reflow-inset-inline` Einzug. Feld:
// `space-s` oben und unten, Beschriftung `caption` in `text-secondary`,
// darunter der Wert (in der Regel `AppValue.strong`). Würde ein Feld
// schmaler als `reflow-stat-min` (wächst mit der Textgröße), stehen die
// Felder untereinander, getrennt durch eine Haarlinie (`reflow-rule-stacked`),
// ohne Einzug (28.10.11). Beschriftung und Wert werden zusammen vorgelesen.

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_reflow.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

/// Eine Kennzahl: Beschriftung und Wert.
@immutable
class AppFigure {
  /// Erzeugt die Kennzahl.
  const AppFigure({required this.label, required this.value});

  /// Beschriftung, z. B. „Gesamt“.
  final String label;

  /// Wert, in der Regel `AppValue.strong`.
  final Widget value;
}

/// Kennzahlenleiste.
class AppFigureRow extends StatelessWidget {
  /// Erzeugt die Leiste.
  const AppFigureRow({super.key, required this.figures});

  /// Kennzahlen in Reihenfolge.
  final List<AppFigure> figures;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final statMin = AppReflowMetric.statMin.of(context);
    BorderSide line(double width) =>
        width == 0 ? BorderSide.none : BorderSide(color: c.lineHairline, width: width);
    Widget cell(AppFigure figure) => MergeSemantics(
          child: AppPadding.symmetric(
            vertical: AppSpace.s,
            child: AppStack(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(figure.label, style: AppTypography.caption.copyWith(color: c.textSecondary)),
                figure.value,
              ],
            ),
          ),
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: line(AppStroke.hairline), bottom: line(AppStroke.hairline)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final stacked = constraints.maxWidth / figures.length < statMin;
        final rule = line(stacked
            ? AppReflowMetric.ruleStacked.arranged(stacked: true)
            : AppReflowMetric.ruleInline.arranged(stacked: false));
        final inset = AppReflowMetric.insetInline.arranged(stacked: stacked);
        final cells = [
          for (var i = 0; i < figures.length; i++)
            i == 0
                ? cell(figures[i])
                : DecoratedBox(
                    decoration: BoxDecoration(border: stacked ? Border(top: rule) : Border(left: rule)),
                    child: Padding(padding: EdgeInsets.only(left: inset), child: cell(figures[i])),
                  ),
        ];
        if (stacked) {
          return AppStack(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells);
        }
        return IntrinsicHeight(
          child: AppStack(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [for (final c in cells) Expanded(child: c)],
          ),
        );
      }),
    );
  }
}
