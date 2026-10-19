// lib/src/components/surfaces/app_divider.dart
//
// Komponente (Teil 1.2): Trennlinie (Figma `Divider`). Waagrecht mit
// Gesamthöhe aus einer Abstandsstufe, bündig (eine Haarlinie hoch) oder
// senkrecht. Seit Teil 1.3 (D06): `AppDivider.rule()` ist die Abschnittslinie
// (`stroke-rule` in `line-strong`, ohne Abstand).

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';

/// Trennlinie.
class AppDivider extends StatelessWidget {
  /// Waagrecht; [space] ist die Gesamthöhe, `null` = Standard (16).
  const AppDivider({super.key, this.space})
      : _flush = false,
        _vertical = false,
        _rule = false;

  /// Waagrecht ohne Abstand (eine Haarlinie hoch).
  const AppDivider.flush({super.key})
      : space = null,
        _flush = true,
        _vertical = false,
        _rule = false;

  /// Senkrecht.
  const AppDivider.vertical({super.key})
      : space = null,
        _flush = false,
        _vertical = true,
        _rule = false;

  /// Abschnittslinie: `stroke-rule` in `line-strong`, ohne Abstand.
  const AppDivider.rule({super.key})
      : space = null,
        _flush = true,
        _vertical = false,
        _rule = true;

  /// Gesamthöhe der waagrechten Linie.
  final AppSpace? space;

  final bool _flush;
  final bool _vertical;
  final bool _rule;

  @override
  Widget build(BuildContext context) {
    if (_vertical) return const VerticalDivider();
    if (_rule) {
      return Divider(height: AppStroke.rule, thickness: AppStroke.rule, color: AppColors.of(context).lineStrong);
    }
    return Divider(height: _flush ? AppStroke.hairline : space?.value);
  }
}
