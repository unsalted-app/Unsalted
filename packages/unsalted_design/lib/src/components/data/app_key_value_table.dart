// lib/src/components/data/app_key_value_table.dart
//
// Komponente (Teil 1.2): Tabelle aus Bezeichnung und einer oder mehreren
// Wertspalten mit fetter Kopfzeile (Figma `Data/Key Value Table`). Die
// Bezeichnung nimmt doppelt so viel Breite wie eine Wertspalte. Baut eine
// `Table` (Plan R1).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';
import '../text/app_text.dart';

/// Eine Zeile einer [AppKeyValueTable].
@immutable
class AppTableRow {
  /// Erzeugt die Zeile.
  const AppTableRow(this.label, this.values);

  /// Bezeichnung.
  final String label;

  /// Werte, je Wertspalte einer.
  final List<String> values;
}

/// Tabelle Bezeichnung → Werte.
class AppKeyValueTable extends StatelessWidget {
  /// Erzeugt die Tabelle; jede Zeile hat so viele Werte wie [headers].
  const AppKeyValueTable({super.key, required this.headers, required this.rows});

  /// Köpfe der Wertspalten.
  final List<String> headers;

  /// Zeilen.
  final List<AppTableRow> rows;

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget child) => AppPadding.all(AppSpace.xs, child: child);
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(2),
        for (var i = 1; i <= headers.length; i++) i: const FlexColumnWidth(1),
      },
      children: [
        TableRow(children: [
          const SizedBox.shrink(),
          for (final header in headers) cell(AppText.strong(header)),
        ]),
        for (final row in rows)
          TableRow(children: [
            cell(Text(row.label)),
            for (final value in row.values) cell(Text(value)),
          ]),
      ],
    );
  }
}
