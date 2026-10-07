// lib/src/components/inputs/app_text_field.dart
//
// Komponente (Teil 1.2): Eingabefeld (Figma `Input/Text Field`). Mit
// Controller baut es ein `TextField`, mit Startwert ein `TextFormField`
// (Plan R1). Varianten: schmal (`width=narrow`, 120) und füllend mehrzeilig
// mit Rahmen (`expands`). Texte liefert der Aufrufer.

import 'package:flutter/material.dart';

import '../../theme/app_tone.dart';

/// Breite eines [AppTextField].
enum AppFieldWidth {
  /// so breit wie der verfügbare Platz.
  fill,

  /// schmal, für kurze Zahlen (120).
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

  /// Bezeichnung (schwebendes Label).
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

  @override
  Widget build(BuildContext context) {
    final helperColor = helperTone.colorOf(context);
    final decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      helperMaxLines: 2,
      helperStyle: helperColor == null ? null : Theme.of(context).textTheme.bodySmall?.copyWith(color: helperColor),
      errorText: error,
      suffixIcon: suffix,
      border: expands ? const OutlineInputBorder() : null,
    );
    final lines = expands ? null : maxLines;
    final vertical = expands ? TextAlignVertical.top : null;
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
          );
    return width == AppFieldWidth.narrow ? SizedBox(width: 120, child: field) : field;
  }
}
