// lib/src/components/lists/app_list_item.dart
//
// Komponente (Teil 1.2): Listeneintrag mit Titel, Untertitel, Elementen
// vorn und hinten (Figma `List/Item`). Baut ein `ListTile` (Plan R1).
//
// Seit Teil 1.3 (D08, ListItem-Karte): ohne Karte, Haarlinie unten
// (`stroke-hairline` in `line-hairline`); [AppListItem.selected] zeigt einen
// Auswahlbalken `stroke-rule` in `line-strong` links (Liste und Detail
// nebeneinander, Teil 1.4). Höhe und Innenabstand aus dem Theme (D04).
//
// Seit Teil 1.4 (B04, Figma `List/Item` `showMatch`): [AppListItem.match]
// markiert einen Teil des Titels als Treffer — Markerfläche (`marker`,
// `radius-xs`, seitlich `space-xxs` wie `Highlight`) hinter den Zeichen, Text
// darin in `text-on-marker`. Der Titel bleibt ein Text mit unverändertem
// Klartext (Semantik und Suche im Test wie ohne Treffer).
//
// Seit Teil 1.4 (T00a, Figma `List/Item` „Umbruch bei großer Schrift“,
// Hinweis 4): Mit [AppListItem.trailing] stehen der Eintrag (`ListTile` mit
// Element vorn, Titel, Untertitel) und das Element hinten in einer
// `ReflowRow` — nebeneinander mittig, oder, sobald daneben das Element vorn
// und das breiteste Wort von Titel oder Untertitel nicht mehr passen (minimale
// Eigenbreite des `ListTile`), das Element hinten rechtsbündig darunter, über
// die volle Breite, mit `space-m` darunter — damit Wörter nicht getrennt
// werden. Ohne Element hinten unverändert.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../layout/reflow_row.dart';
import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';

/// Listeneintrag.
class AppListItem extends StatelessWidget {
  /// Erzeugt den Eintrag.
  const AppListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
    this.selected = false,
    this.match,
  });

  /// Titel.
  final String title;

  /// Untertitel; `null` = keiner.
  final String? subtitle;

  /// Element vorn, z. B. `AppIcon`.
  final Widget? leading;

  /// Element hinten, z. B. `AppChip` oder Symbol-Schaltflächen.
  final Widget? trailing;

  /// Aktion beim Antippen.
  final VoidCallback? onTap;

  /// `true`: kompakte Höhe.
  final bool dense;

  /// `true`: gewählt (Auswahlbalken links).
  final bool selected;

  /// Treffer im Titel (Zeichenbereich), markiert; `null` oder ungültig = keiner.
  final TextRange? match;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tile = ListTile(
      title: _MatchedTitle(title: title, match: match),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: leading,
      onTap: onTap,
      dense: dense ? true : null,
      selected: selected,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.lineHairline, width: AppStroke.hairline),
          left: selected ? BorderSide(color: c.lineStrong, width: AppStroke.rule) : BorderSide.none,
        ),
      ),
      child: trailing == null
          ? tile
          : ReflowRow(
              main: tile,
              trailing: AppPadding.only(right: AppSpace.l, child: trailing!),
              gap: 0,
              mainMin: 0,
              mainMinIntrinsic: true,
              centered: true,
              stackedEndGap: AppSpacing.m,
            ),
    );
  }
}

/// Titel mit optional markiertem Treffer.
class _MatchedTitle extends StatelessWidget {
  const _MatchedTitle({required this.title, required this.match});

  final String title;
  final TextRange? match;

  @override
  Widget build(BuildContext context) {
    final range = match;
    if (range == null || !range.isValid || range.isCollapsed || range.end > title.length) return Text(title);
    final c = AppColors.of(context);
    final span = TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [
        TextSpan(text: range.textBefore(title)),
        TextSpan(text: range.textInside(title), style: TextStyle(color: c.textOnMarker)),
        TextSpan(text: range.textAfter(title)),
      ],
    );
    return CustomPaint(
      painter: _MatchPainter(
        span: span,
        range: range,
        color: c.marker,
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: Directionality.of(context),
      ),
      child: Text.rich(span),
    );
  }
}

/// Malt die Markerfläche hinter den Zeichen des Treffers.
class _MatchPainter extends CustomPainter {
  _MatchPainter({
    required this.span,
    required this.range,
    required this.color,
    required this.textScaler,
    required this.textDirection,
  });

  final TextSpan span;
  final TextRange range;
  final Color color;
  final TextScaler textScaler;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(text: span, textDirection: textDirection, textScaler: textScaler)
      ..layout(maxWidth: size.width);
    final paint = Paint()..color = color;
    for (final box in painter.getBoxesForSelection(TextSelection(baseOffset: range.start, extentOffset: range.end))) {
      final rect = box.toRect();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(rect.left - AppSpacing.xxs, rect.top, rect.right + AppSpacing.xxs, rect.bottom),
          const Radius.circular(AppRadius.xs),
        ),
        paint,
      );
    }
    painter.dispose();
  }

  @override
  bool shouldRepaint(_MatchPainter old) =>
      old.span != span || old.range != range || old.color != color || old.textScaler != textScaler;
}

