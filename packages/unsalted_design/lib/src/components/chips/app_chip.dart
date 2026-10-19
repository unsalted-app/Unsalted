// lib/src/components/chips/app_chip.dart
//
// Komponente (Teil 1.2): Info-Chip, z. B. eine Zeitangabe (Figma
// `Chip/Info`). Baut einen `Chip`. Seit Teil 1.3 (D06) als Tag nach der
// Chip-Karte: Höhe `size-mark` (kleinste Dichte), `radius-xs`, keine Fläche,
// Kontur `line-control` in `stroke-hairline`, `label-small` mit tabellarischen
// Ziffern, optional ein Symbol in `size-icon-xs` mit Abstand `space-xs`.

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

/// Info-Chip (Tag).
class AppChip extends StatelessWidget {
  /// Erzeugt den Chip.
  const AppChip({super.key, required this.label, this.icon});

  /// Beschriftung.
  final String label;

  /// Optionales Symbol vor der Beschriftung, in der Regel aus `AppIcons`.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(AppRadius.xs);
    // Kontur als Vordergrund um den Chip: Über `side` rechnet Flutter sie als
    // Innenabstand hinzu (26 statt 24 hoch), und ein `side: none` löscht auch
    // eine Kontur aus `shape` (Fehler aus D06, in D08 behoben).
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.lineControl, width: AppStroke.hairline),
      ),
      child: Chip(
        avatar: icon == null ? null : Icon(icon, size: AppSize.iconXs, color: colors.textPrimary),
        label: Text(label),
        labelStyle: AppTypography.labelSmall.copyWith(color: colors.textPrimary),
        labelPadding: icon == null ? EdgeInsets.zero : const EdgeInsets.only(left: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        backgroundColor: colors.surfacePage.withValues(alpha: 0),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: radius),
        visualDensity: const VisualDensity(vertical: VisualDensity.minimumDensity),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
