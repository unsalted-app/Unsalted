// lib/src/components/surfaces/app_divider.dart
//
// Komponente (Teil 1.2): Trennlinie (Figma `Divider`). Waagrecht mit
// Gesamthöhe aus einer Abstandsstufe, bündig (1 px hoch) oder senkrecht.

import 'package:flutter/material.dart';

import '../../tokens/spacing_tokens.dart';

/// Trennlinie.
class AppDivider extends StatelessWidget {
  /// Waagrecht; [space] ist die Gesamthöhe, `null` = Standard (16).
  const AppDivider({super.key, this.space})
      : _flush = false,
        _vertical = false;

  /// Waagrecht ohne Abstand (1 px hoch).
  const AppDivider.flush({super.key})
      : space = null,
        _flush = true,
        _vertical = false;

  /// Senkrecht.
  const AppDivider.vertical({super.key})
      : space = null,
        _flush = false,
        _vertical = true;

  /// Gesamthöhe der waagrechten Linie.
  final AppSpace? space;

  final bool _flush;
  final bool _vertical;

  @override
  Widget build(BuildContext context) {
    if (_vertical) return const VerticalDivider();
    return Divider(height: _flush ? 1 : space?.value);
  }
}
