// lib/src/components/text/app_text.dart
//
// Komponente (Teil 1.2): Text in einer Typo-Rolle und einem Farbton. Ersetzt
// `Text(style: …)` in Bildschirmen. `body` ohne Ton ist ein schlichter
// `Text` und übernimmt den Stil der Umgebung.

import 'package:flutter/material.dart';

import '../../theme/app_tone.dart';

/// Typo-Rolle von [AppText].
enum AppTextRole {
  /// Fließtext der Umgebung (Figma `Text/Body`).
  body,

  /// Fließtext fett, z. B. Abschnittsüberschrift (Figma `Text/Strong`).
  strong,

  /// Titel (`type/title-medium`, Figma `Text/Title`).
  title,

  /// Kleingedrucktes (`type/body-small`, Figma `Text/Caption`).
  caption,
}

/// Text in Rolle [role] und Farbton [tone].
class AppText extends StatelessWidget {
  /// Fließtext.
  const AppText(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.body;

  /// Fließtext fett.
  const AppText.strong(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.strong;

  /// Titel.
  const AppText.title(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.title;

  /// Kleingedrucktes.
  const AppText.caption(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.caption;

  /// Inhalt.
  final String text;

  /// Typo-Rolle.
  final AppTextRole role;

  /// Farbton.
  final AppTone tone;

  /// Ausrichtung.
  final TextAlign? textAlign;

  /// Höchstzahl Zeilen; `null` = unbegrenzt.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var style = switch (role) {
      AppTextRole.body => null,
      AppTextRole.strong => const TextStyle(fontWeight: FontWeight.bold),
      AppTextRole.title => textTheme.titleMedium,
      AppTextRole.caption => textTheme.bodySmall,
    };
    final color = tone.colorOf(context);
    if (color != null) style = (style ?? const TextStyle()).copyWith(color: color);
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
