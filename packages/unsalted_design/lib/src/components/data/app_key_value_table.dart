// lib/src/components/data/app_key_value_table.dart
//
// Komponente (Teil 1.2): Tabelle aus Bezeichnung und einer oder mehreren
// Wertspalten (Figma `Data/Key Value Table`). Baut eine `Table` (Plan R1).
//
// Seit Teil 1.3 (D10, KeyValueTable-Karte) als Deklaration: Kopf in
// `label-small`/`text-secondary`, darunter `stroke-frame` in `line-strong`;
// Zeilen in `data` mit Haarlinie darunter, Zellabstand `space-xs` oben und
// unten, Wertzellen fest `reflow-value-column` breit mit `space-m` links
// innerhalb der Zelle (D12; vorher zusätzlich), Werte rechtsbündig mit
// tabellarischen Ziffern; Bezeichnung füllt den Rest. Untergeordnete Zeilen
// ([AppTableRow.sub]) um `space-l` eingerückt in `text-secondary`,
// hervorgehobene ([AppTableRow.strong]) in `data-strong`.
//
// Große Schrift (D12): Die Wertspalte wächst mit der Textgröße
// (`reflow-value-column`). Bliebe der Bezeichnung weniger als
// `reflow-label-min`, bricht jede Zeile um: Bezeichnung oben in voller
// Breite, Werte darunter rechtsbündig (Figma „Bildschirme · Schrift 200“).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_reflow.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

/// Eine Zeile einer [AppKeyValueTable].
@immutable
class AppTableRow {
  /// Erzeugt die Zeile.
  const AppTableRow(this.label, this.values, {this.sub = false, this.strong = false});

  /// Bezeichnung.
  final String label;

  /// Werte, je Wertspalte einer.
  final List<String> values;

  /// `true`: untergeordnete Zeile („davon“), eingerückt und zurückgenommen.
  final bool sub;

  /// `true`: hervorgehobene Zeile in `data-strong`.
  final bool strong;
}

/// Deklarationstabelle.
class AppKeyValueTable extends StatelessWidget {
  /// Erzeugt die Tabelle; jede Zeile hat so viele Werte wie [headers].
  const AppKeyValueTable({super.key, required this.headers, required this.rows});

  /// Köpfe der Wertspalten.
  final List<String> headers;

  /// Zeilen.
  final List<AppTableRow> rows;

  @override
  Widget build(BuildContext context) {
    final column = AppReflowMetric.valueColumn.of(context);
    final labelMin = AppReflowMetric.labelMin.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth - headers.length * column < labelMin
          ? _stacked(context, column)
          : _inline(context, column),
    );
  }

  /// Bezeichnung und Werte nebeneinander.
  Widget _inline(BuildContext context, double column) {
    final c = AppColors.of(context);
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(),
        for (var i = 1; i <= headers.length; i++) i: FixedColumnWidth(column),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TableRow(
          decoration: _rule(c.lineStrong, AppStroke.frame),
          children: [const SizedBox.shrink(), for (final header in headers) _value(_header(context, header))],
        ),
        for (final row in rows)
          TableRow(
            decoration: _rule(c.lineHairline, AppStroke.hairline),
            children: [_label(context, row), for (final value in row.values) _value(_cell(context, row, value))],
          ),
      ],
    );
  }

  /// Je Zeile Bezeichnung oben, Werte darunter rechtsbündig.
  Widget _stacked(BuildContext context, double column) {
    final c = AppColors.of(context);
    Widget values(List<Widget> cells) => Wrap(
          alignment: WrapAlignment.end,
          children: [for (final cell in cells) SizedBox(width: column, child: _value(cell))],
        );
    return AppStack(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: _rule(c.lineStrong, AppStroke.frame),
          child: values([for (final header in headers) _header(context, header)]),
        ),
        for (final row in rows)
          DecoratedBox(
            decoration: _rule(c.lineHairline, AppStroke.hairline),
            child: AppStack(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_label(context, row), values([for (final value in row.values) _cell(context, row, value)])],
            ),
          ),
      ],
    );
  }

  static BoxDecoration _rule(Color color, double width) =>
      BoxDecoration(border: Border(bottom: BorderSide(color: color, width: width)));

  static Widget _value(Widget child) => AppPadding.only(
        top: AppSpace.xs,
        bottom: AppSpace.xs,
        left: AppSpace.m,
        child: Align(alignment: Alignment.centerRight, child: child),
      );

  static Widget _header(BuildContext context, String text) => Text(
        text,
        textAlign: TextAlign.end,
        style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textSecondary),
      );

  static TextStyle _style(AppTableRow row) => row.strong ? AppTypography.dataStrong : AppTypography.data;

  static Widget _label(BuildContext context, AppTableRow row) {
    final c = AppColors.of(context);
    return AppPadding.only(
      top: AppSpace.xs,
      bottom: AppSpace.xs,
      left: row.sub ? AppSpace.l : null,
      child: Text(row.label, style: _style(row).copyWith(color: row.sub ? c.textSecondary : c.textPrimary)),
    );
  }

  static Widget _cell(BuildContext context, AppTableRow row, String value) => Text(
        value,
        textAlign: TextAlign.end,
        style: _style(row).copyWith(color: AppColors.of(context).textPrimary),
      );
}
