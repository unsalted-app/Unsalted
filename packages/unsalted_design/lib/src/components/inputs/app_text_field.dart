// lib/src/components/inputs/app_text_field.dart
//
// Komponente (Teil 1.2): Eingabefeld (Figma `Input/Text Field`). Mit
// Controller baut es ein `TextField`, mit Startwert ein `TextFormField`
// (Plan R1). Varianten: schmal (`width=narrow`) und füllend mehrzeilig mit
// Rahmen (`expands`). Texte liefert der Aufrufer.
//
// Seit Teil 1.3 (D08, TextField-Karte): Beschriftung `space-xs` über dem Feld
// in `label-small`/`text-secondary` statt schwebend (deutsche Begriffe sind
// lang); die Beschriftung hängt semantisch am Feld. Zahlenfelder
// (`TextInputType.number`) in `data`, rechtsbündig; Einheit im Feld in
// `text-secondary` ([AppTextField.unit]). Fehler mit Symbol `error`
// (`size-icon-xs`, Abstand `space-xs`) in `caption`/`text-error`. Schmal =
// `reflow-field-min` (wächst ab D12 mit der Schrift).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tone.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';
import '../icons/app_icons.dart';

/// Breite eines [AppTextField].
enum AppFieldWidth {
  /// so breit wie der verfügbare Platz.
  fill,

  /// schmal, für kurze Zahlen (`reflow-field-min`).
  narrow,
}

/// Eingabefeld.
class AppTextField extends StatelessWidget {
  /// Erzeugt das Feld. Höchstens eins von [controller] und [initialValue].
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helper,
    this.helperTone = AppTone.normal,
    this.error,
    this.suffix,
    this.unit,
    this.maxLines = 1,
    this.expands = false,
    this.keyboardType,
    this.enabled = true,
    this.autofocus = false,
    this.width = AppFieldWidth.fill,
    this.onChanged,
  }) : assert(controller == null || initialValue == null);

  /// Steuert den Text von außen.
  final TextEditingController? controller;

  /// Startwert ohne Controller.
  final String? initialValue;

  /// Bezeichnung über dem Feld.
  final String? label;

  /// Platzhalter im leeren Feld.
  final String? hint;

  /// Hilfetext unter dem Feld.
  final String? helper;

  /// Farbton des Hilfetexts.
  final AppTone helperTone;

  /// Fehlertext; färbt das Feld.
  final String? error;

  /// Element am Ende des Felds, z. B. `AppIconButton`.
  final Widget? suffix;

  /// Einheit im Feld hinter dem Wert, z. B. „g“; `null` = keine.
  final String? unit;

  /// Höchstzahl Zeilen; `null` = unbegrenzt.
  final int? maxLines;

  /// `true`: füllt den verfügbaren Platz, mehrzeilig, oben ausgerichtet, mit Rahmen.
  final bool expands;

  /// Tastatur, z. B. `TextInputType.number`.
  final TextInputType? keyboardType;

  /// `false`: gesperrt.
  final bool enabled;

  /// `true`: erhält beim Öffnen den Fokus.
  final bool autofocus;

  /// Breite.
  final AppFieldWidth width;

  /// Meldet jede Änderung.
  final ValueChanged<String>? onChanged;

  bool get _numeric => keyboardType != null && keyboardType!.index == TextInputType.number.index;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final helperColor = helperTone.colorOf(context);
    final decoration = InputDecoration(
      hintText: hint,
      helperText: helper,
      helperMaxLines: 2,
      helperStyle: helperColor == null ? null : AppTypography.caption.copyWith(color: helperColor),
      error: error == null
          ? null
          : AppStack(
              direction: Axis.horizontal,
              gap: AppSpace.xs,
              children: [
                Icon(AppIcons.error, size: AppSize.iconXs, color: c.textError),
                Flexible(child: Text(error!, style: AppTypography.caption.copyWith(color: c.textError))),
              ],
            ),
      suffixIcon: suffix,
      suffixText: unit,
      suffixStyle: AppTypography.data.copyWith(color: c.textSecondary),
      border: expands ? (Theme.of(context).inputDecorationTheme.border ?? const OutlineInputBorder()) : null,
    );
    final lines = expands ? null : maxLines;
    final vertical = expands ? TextAlignVertical.top : null;
    final style = _numeric ? AppTypography.data : null;
    final align = _numeric ? TextAlign.end : TextAlign.start;
    final Widget field = initialValue != null
        ? TextFormField(
            initialValue: initialValue,
            decoration: decoration,
            maxLines: lines,
            expands: expands,
            textAlignVertical: vertical,
            keyboardType: keyboardType,
            enabled: enabled,
            autofocus: autofocus,
            onChanged: onChanged,
            style: style,
            textAlign: align,
          )
        : TextField(
            controller: controller,
            decoration: decoration,
            maxLines: lines,
            expands: expands,
            textAlignVertical: vertical,
            keyboardType: keyboardType,
            enabled: enabled,
            autofocus: autofocus,
            onChanged: onChanged,
            style: style,
            textAlign: align,
          );
    // Die sichtbare Beschriftung ist von der Semantik ausgenommen und hängt
    // stattdessen am Feld — so liest ein Screenreader sie mit dem Feld, und eine
    // Schaltfläche am Feldende ([suffix]) bleibt ein eigener Knoten.
    final Widget semanticField = label == null ? field : Semantics(label: label, child: field);
    final Widget labelled = label == null
        ? field
        : AppStack(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
            gap: AppSpace.xs,
            children: [
              ExcludeSemantics(child: Text(label!, style: AppTypography.labelSmall.copyWith(color: c.textSecondary))),
              if (expands) Expanded(child: semanticField) else semanticField,
            ],
          );
    return width == AppFieldWidth.narrow ? SizedBox(width: AppReflow.fieldMin, child: labelled) : labelled;
  }
}
