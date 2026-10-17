// lib/src/components/data/app_code_block.dart
//
// Komponente (Teil 1.2): langer, auswählbarer Text, z. B. ein Datenexport
// (Figma `Data/Code Block`). Scrollt selbst. Seit Teil 1.3 (D10):
// `surface-sunken`, `radius-s`, Innenabstand `space-m`, Stil `code`.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/radius_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

/// Auswählbarer Langtext.
class AppCodeBlock extends StatelessWidget {
  /// Erzeugt den Block.
  const AppCodeBlock(this.text, {super.key});

  /// Inhalt.
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.s)),
      child: SingleChildScrollView(
        child: AppPadding.all(
          AppSpace.m,
          child: SelectableText(text, style: AppTypography.code.copyWith(color: c.textPrimary)),
        ),
      ),
    );
  }
}
