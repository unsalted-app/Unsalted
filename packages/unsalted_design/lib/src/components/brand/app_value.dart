// lib/src/components/brand/app_value.dart
//
// Markenelement (Teil 1.3, D07): Messwert (Figma `Value` ·
// `certainty=known/unknown/incomplete`, `size=data/strong/display`;
// Value-Karte). Zahl plus Einheit mit ehrlichem Zustand: bekannt, unbekannt
// („—“ in `text-secondary`, nie „0“) oder unvollständig (Wert, dann „*“ fett;
// die Fußnote setzt der Aufrufer). Zahl mit tabellarischen Ziffern, Einheit
// nach geschütztem Leerzeichen (U+00A0) in `text-secondary`, Schnitt 400;
// neben `display` in `body-strong`. Zahl und Rundung liefert der Aufrufer.

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../tokens/typography_tokens.g.dart';

/// Zustand eines [AppValue].
enum AppCertainty {
  /// bekannt.
  known,

  /// unbekannt: „—“.
  unknown,

  /// unvollständig: Wert mit „*“.
  incomplete,
}

/// Messwert: Zahl, Einheit, Zustand.
class AppValue extends StatelessWidget {
  /// Wert im Stil `data`.
  const AppValue({super.key, required this.value, this.unit, this.certainty = AppCertainty.known})
      : _style = _Size.data;

  /// Wert im Stil `data-strong`.
  const AppValue.strong({super.key, required this.value, this.unit, this.certainty = AppCertainty.known})
      : _style = _Size.strong;

  /// Wert im Stil `display` (Kennzahl).
  const AppValue.display({super.key, required this.value, this.unit, this.certainty = AppCertainty.known})
      : _style = _Size.display;

  /// Zahl als Text, gerundet und formatiert vom Aufrufer.
  final String value;

  /// Einheit; `null` = keine.
  final String? unit;

  /// Zustand.
  final AppCertainty certainty;

  final _Size _style;

  /// Text ohne Hervorhebung, wie ihn ein Screenreader liest.
  String get plainText => switch (certainty) {
        AppCertainty.unknown => '—',
        AppCertainty.known => unit == null ? value : '$value $unit',
        AppCertainty.incomplete => unit == null ? '$value*' : '$value $unit*',
      };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final number = switch (_style) {
      _Size.data => AppTypography.data,
      _Size.strong => AppTypography.dataStrong,
      _Size.display => AppTypography.display,
    };
    final unitStyle = (_style == _Size.display ? AppTypography.bodyStrong : AppTypography.data)
        .copyWith(color: c.textSecondary, fontWeight: _style == _Size.display ? null : AppTypography.body.fontWeight);
    if (certainty == AppCertainty.unknown) {
      return Text('—', style: number.copyWith(color: c.textSecondary));
    }
    return Text.rich(
      TextSpan(
        style: number.copyWith(color: c.textPrimary),
        children: [
          TextSpan(text: value),
          if (unit != null) TextSpan(text: ' $unit', style: unitStyle),
          if (certainty == AppCertainty.incomplete)
            TextSpan(text: '*', style: TextStyle(fontWeight: AppTypography.dataStrong.fontWeight)),
        ],
      ),
      semanticsLabel: plainText,
    );
  }
}

enum _Size { data, strong, display }
