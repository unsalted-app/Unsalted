// lib/src/components/text/app_text.dart
//
// Komponente (Teil 1.2): Text in einer Typo-Rolle und einem Farbton. Ersetzt
// `Text(style: …)` in Bildschirmen. `body` ohne Ton ist ein schlichter
// `Text` und übernimmt den Stil der Umgebung. Seit Teil 1.3 (D06) alle elf
// Stile der Übergabe (02-typografie); `strong` ist `body-strong` (600) und
// übernimmt Größe und Zeilenhöhe der Umgebung.

import 'package:flutter/material.dart';

import '../../theme/app_tone.dart';
import '../../tokens/typography_tokens.g.dart';

/// Typo-Rolle von [AppText].
enum AppTextRole {
  /// Fließtext der Umgebung (Figma `Text/Body`).
  body,

  /// Fließtext fett, z. B. Abschnittsüberschrift (Figma `Text/Strong`).
  strong,

  /// Titel (`type/title-medium`, Figma `Text/Title`).
  title,

  /// Kleingedrucktes (`type/caption` über die Material-Rolle `bodySmall`,
  /// Figma `Text/Caption`).
  caption,

  /// `type/display`: Titel im Inhalt, Kennzahlen.
  display,

  /// `type/title-page`: Seiten- und Dialogtitel.
  titlePage,

  /// `type/heading`: Abschnittsüberschrift.
  heading,

  /// `type/body-small`: Untertitel, sekundäre Angaben.
  bodySmall,

  /// `type/label-small`: Marken, Tags, Feldbeschriftung.
  labelSmall,

  /// `type/data`: Werte, Mengen.
  data,

  /// `type/data-strong`: hervorgehobene Werte.
  dataStrong,

  /// `type/code`: Codeblock.
  code,
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

  /// `type/display`.
  const AppText.display(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.display;

  /// `type/title-page`.
  const AppText.titlePage(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.titlePage;

  /// `type/heading`.
  const AppText.heading(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.heading;

  /// `type/body-small`.
  const AppText.bodySmall(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.bodySmall;

  /// `type/label-small`.
  const AppText.labelSmall(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.labelSmall;

  /// `type/data`.
  const AppText.data(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.data;

  /// `type/data-strong`.
  const AppText.dataStrong(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.dataStrong;

  /// `type/code`.
  const AppText.code(this.text, {super.key, this.tone = AppTone.normal, this.textAlign, this.maxLines})
      : role = AppTextRole.code;

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
      AppTextRole.strong => TextStyle(fontWeight: AppTypography.bodyStrong.fontWeight),
      AppTextRole.title => textTheme.titleMedium,
      AppTextRole.caption => textTheme.bodySmall,
      AppTextRole.display => AppTypography.display,
      AppTextRole.titlePage => AppTypography.titlePage,
      AppTextRole.heading => AppTypography.heading,
      AppTextRole.bodySmall => AppTypography.bodySmall,
      AppTextRole.labelSmall => AppTypography.labelSmall,
      AppTextRole.data => AppTypography.data,
      AppTextRole.dataStrong => AppTypography.dataStrong,
      AppTextRole.code => AppTypography.code,
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
