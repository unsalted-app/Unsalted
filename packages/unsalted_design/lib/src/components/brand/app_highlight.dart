// lib/src/components/brand/app_highlight.dart
//
// Markenelement (Teil 1.3, D07): Marker und Änderung (Figma `Highlight`,
// `Change`; Highlight-Karte). Der Marker hinterlegt, was neu, geändert oder
// gefunden ist (`marker`, Text `text-on-marker`, `radius-xs`, seitlich
// `space-xxs`). Eine Änderung zeigt „Gegenstand: alt → neu“: alt in
// `text-secondary` durchgestrichen, dazwischen das Symbol `arrow` (die
// Schrift hat keinen Pfeil), neu markiert; hinzugefügt nur Marker, entfernt nur
// Strich. Kein Rot und Grün — die Struktur trägt die Bedeutung. Der Aufrufer
// liefert den Screenreader-Text (z. B. den bisherigen Klartext).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';
import '../icons/app_icons.dart';

/// Marker-Hinterlegung eines kurzen Texts.
class AppHighlight extends StatelessWidget {
  /// Hinterlegt [text]; [style] = Stil der Umgebung, sonst `body`.
  const AppHighlight(this.text, {super.key, this.style});

  /// Markierter Text.
  final String text;

  /// Textstil, z. B. `AppTypography.data`; `null` = `body`.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.marker, borderRadius: BorderRadius.circular(AppRadius.xs)),
      child: AppPadding.symmetric(
        horizontal: AppSpace.xxs,
        child: Text(text, style: (style ?? AppTypography.body).copyWith(color: c.textOnMarker)),
      ),
    );
  }
}

/// Eine Änderung: Gegenstand, alt (gestrichen) → neu (markiert).
class AppChangeText extends StatelessWidget {
  /// Erzeugt die Zeile. Fehlt [before], gilt sie als hinzugefügt (nur
  /// Marker); fehlt [after], als entfernt (nur Strich); [note] ist ein
  /// Klartext ohne alt/neu.
  const AppChangeText({
    super.key,
    required this.semanticLabel,
    this.subject,
    this.before,
    this.after,
    this.note,
  });

  /// Screenreader-Text der ganzen Änderung.
  final String semanticLabel;

  /// Gegenstand, z. B. ein Name; `null` = keiner.
  final String? subject;

  /// alter Wert.
  final String? before;

  /// neuer Wert.
  final String? after;

  /// Klartext, z. B. „anderer Eintrag verknüpft“.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final muted = AppTypography.body.copyWith(color: c.textSecondary);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (subject != null) Text(subject!, style: AppTypography.bodyStrong.copyWith(color: c.textPrimary)),
            if (before != null)
              Text(
                before!,
                style: muted.copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: c.textSecondary,
                  decorationThickness: AppStroke.frame,
                ),
              ),
            if (before != null && after != null) Icon(AppIcons.arrow, size: AppSize.iconXs, color: c.textSecondary),
            if (after != null) AppHighlight(after!),
            if (note != null) Text(note!, style: AppTypography.body.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    );
  }
}
