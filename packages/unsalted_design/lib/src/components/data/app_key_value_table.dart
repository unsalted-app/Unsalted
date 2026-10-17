// lib/src/components/data/app_key_value_table.dart
//
// Komponente (Teil 1.2): Tabelle aus Bezeichnung und einer oder mehreren
// Wertspalten (Figma `Data/Key Value Table`). Baut eine `Table` (Plan R1).
//
// Seit Teil 1.3 (D10, KeyValueTable-Karte) als Deklaration: Kopf in
// `label-small`/`text-secondary`, darunter `stroke-frame` in `line-strong`;
// Zeilen in `data` mit Haarlinie darunter, Zellabstand `space-xs` oben und
// unten, Wertspalten fest `size-value-column` mit `space-m` links, Werte
// rechtsbündig mit tabellarischen Ziffern; Bezeichnung füllt den Rest.
// Untergeordnete Zeilen ([AppTableRow.sub]) um `space-l` eingerückt in
// `text-secondary`, hervorgehobene ([AppTableRow.strong]) in `data-strong`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/size_tokens.g.dart';
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
    final c = AppColors.of(context);
    Widget cell(Widget child, {bool value = false, bool indent = false}) => AppPadding.only(
          top: AppSpace.xs,
          bottom: AppSpace.xs,
          left: value ? AppSpace.m : (indent ? AppSpace.l : null),
          child: value ? Align(alignment: Alignment.centerRight, child: child) : child,
        );
    final head = AppTypography.labelSmall.copyWith(color: c.textSecondary);
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(),
        for (var i = 1; i <= headers.length; i++) i: const FixedColumnWidth(AppSpacing.m + AppSize.valueColumn),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TableRow(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineStrong, width: AppStroke.frame))),
          children: [
            const SizedBox.shrink(),
            for (final header in headers) cell(Text(header, style: head, textAlign: TextAlign.end), value: true),
          ],
        ),
        for (final row in rows)
          TableRow(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineHairline, width: AppStroke.hairline))),
            children: [
              cell(
                Text(
                  row.label,
                  style: (row.strong ? AppTypography.dataStrong : AppTypography.data)
                      .copyWith(color: row.sub ? c.textSecondary : c.textPrimary),
                ),
                indent: row.sub,
              ),
              for (final value in row.values)
                cell(
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: (row.strong ? AppTypography.dataStrong : AppTypography.data).copyWith(color: c.textPrimary),
                  ),
                  value: true,
                ),
            ],
          ),
      ],
    );
  }
}
