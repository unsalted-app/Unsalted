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
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: AppSize.iconXs, color: colors.textPrimary),
      label: Text(label),
      labelStyle: AppTypography.labelSmall.copyWith(color: colors.textPrimary),
      labelPadding: icon == null ? EdgeInsets.zero : const EdgeInsets.only(left: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      backgroundColor: colors.surfacePage.withValues(alpha: 0),
      // Kontur über `shape`, nicht `side`: `side` rechnet Flutter als
      // Innenabstand hinzu, der Tag würde 2 px höher als `size-mark`.
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        side: BorderSide(color: colors.lineControl, width: AppStroke.hairline),
      ),
      visualDensity: const VisualDensity(vertical: VisualDensity.minimumDensity),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
