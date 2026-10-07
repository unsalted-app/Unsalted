// lib/src/layout/app_grid.dart
//
// Layout (Teil 1.2): Raster mit 1–3 Spalten nach verfügbarer Breite
// (`AppWindowSize.gridColumns`); die Elemente einer Zeile sind gleich hoch.
// Übernommen aus `ui/shared/card_layout.dart` auf `design/1.1`, ohne Sliver
// und mit Abständen aus Tokens. Scrollt nicht selbst.

import 'package:flutter/widgets.dart';

import '../tokens/spacing_tokens.dart';
import 'app_stack.dart';
import 'responsive.dart';

/// Raster aus [itemCount] Elementen.
class AppGrid extends StatelessWidget {
  /// Erzeugt das Raster.
  const AppGrid({super.key, required this.itemCount, required this.itemBuilder, this.gap = AppSpace.m});

  /// Anzahl der Elemente.
  final int itemCount;

  /// Baut das Element an Position `index`.
  final IndexedWidgetBuilder itemBuilder;

  /// Abstand zwischen Zeilen und Spalten.
  final AppSpace gap;

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(builder: (context, size) {
        final columns = size.gridColumns;
        final rows = (itemCount + columns - 1) ~/ columns;
        return AppStack(
          gap: gap,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var row = 0; row < rows; row++)
              if (columns == 1)
                itemBuilder(context, row)
              else
                IntrinsicHeight(
                  child: AppStack(
                    direction: Axis.horizontal,
                    gap: gap,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      for (var c = 0; c < columns; c++)
                        Expanded(
                          child: row * columns + c < itemCount
                              ? itemBuilder(context, row * columns + c)
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
          ],
        );
      });
}
