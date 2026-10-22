// lib/src/tokens/color_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Farben: Primitive (Markenpalette, nur hier und
// in der Material-Zuordnung von AppTheme) und semantische Rollen je Modus.

import 'package:flutter/widgets.dart';

/// Markenpalette (Figma-Sammlung `primitives`). Komponenten verwenden nie
/// Primitive, sondern Rollen aus [AppColorTokens]; Ausnahme ist die
/// Material-Zuordnung in `AppTheme` (docs/design/system/01-farbe.md).
abstract final class AppColorPrimitives {
  /// `primitives/neutral/0`
  static const neutral0 = Color(0xFFFFFFFF);

  /// `primitives/neutral/50`
  static const neutral50 = Color(0xFFF9F7F1);

  /// `primitives/neutral/100`
  static const neutral100 = Color(0xFFF0EEE9);

  /// `primitives/neutral/150`
  static const neutral150 = Color(0xFFE2DFDA);

  /// `primitives/neutral/400`
  static const neutral400 = Color(0xFF9B9FA3);

  /// `primitives/neutral/500`
  static const neutral500 = Color(0xFF7D8086);

  /// `primitives/neutral/600`
  static const neutral600 = Color(0xFF5E6269);

  /// `primitives/neutral/700`
  static const neutral700 = Color(0xFF434851);

  /// `primitives/neutral/800`
  static const neutral800 = Color(0xFF252A34);

  /// `primitives/neutral/900`
  static const neutral900 = Color(0xFF141925);

  /// `primitives/neutral/950`
  static const neutral950 = Color(0xFF0C1019);

  /// `primitives/marker/400`
  static const marker400 = Color(0xFFFEE545);

  /// `primitives/marker/500`
  static const marker500 = Color(0xFFEDD13D);

  /// `primitives/red/100`
  static const red100 = Color(0xFFFDE9E8);

  /// `primitives/red/300`
  static const red300 = Color(0xFFF4918E);

  /// `primitives/red/600`
  static const red600 = Color(0xFFC32A28);

  /// `primitives/red/800`
  static const red800 = Color(0xFF831A18);

  /// `primitives/red/900`
  static const red900 = Color(0xFF4D1C1A);

  /// `primitives/orange/100`
  static const orange100 = Color(0xFFFEEDD9);

  /// `primitives/orange/300`
  static const orange300 = Color(0xFFF3AD66);

  /// `primitives/orange/700`
  static const orange700 = Color(0xFFA6560A);

  /// `primitives/orange/800`
  static const orange800 = Color(0xFF763A0D);

  /// `primitives/orange/900`
  static const orange900 = Color(0xFF492811);

  /// Alle Primitive mit ihrem Figma-Namen.
  static const byFigmaName = <String, Color>{
    'primitives/neutral/0': neutral0,
    'primitives/neutral/50': neutral50,
    'primitives/neutral/100': neutral100,
    'primitives/neutral/150': neutral150,
    'primitives/neutral/400': neutral400,
    'primitives/neutral/500': neutral500,
    'primitives/neutral/600': neutral600,
    'primitives/neutral/700': neutral700,
    'primitives/neutral/800': neutral800,
    'primitives/neutral/900': neutral900,
    'primitives/neutral/950': neutral950,
    'primitives/marker/400': marker400,
    'primitives/marker/500': marker500,
    'primitives/red/100': red100,
    'primitives/red/300': red300,
    'primitives/red/600': red600,
    'primitives/red/800': red800,
    'primitives/red/900': red900,
    'primitives/orange/100': orange100,
    'primitives/orange/300': orange300,
    'primitives/orange/700': orange700,
    'primitives/orange/800': orange800,
    'primitives/orange/900': orange900,
  };
}

/// Semantische Farbrollen eines Modus (Figma-Sammlung `color`, Modi `light`
/// und `dark`). Jede Rolle verweist auf ein Primitiv.
@immutable
class AppColorTokens {
  /// Erzeugt einen vollständigen Satz Rollen.
  const AppColorTokens({
    required this.brightness,
    required this.surfacePage,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceInverse,
    required this.scrim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textInverse,
    required this.textOnMarker,
    required this.textError,
    required this.textWarning,
    required this.lineHairline,
    required this.lineDot,
    required this.lineControl,
    required this.lineStrong,
    required this.lineFocus,
    required this.actionPrimary,
    required this.actionOnPrimary,
    required this.actionInverse,
    required this.marker,
    required this.selection,
    required this.selectionHandle,
    required this.stateDraft,
    required this.stateFrozen,
    required this.stateMaster,
    required this.feedbackErrorSurface,
    required this.feedbackOnErrorSurface,
    required this.feedbackWarningSurface,
    required this.feedbackOnWarningSurface,
  });

  /// Helligkeit des Modus.
  final Brightness brightness;

  /// `color/surface-page`
  final Color surfacePage;

  /// `color/surface-raised`
  final Color surfaceRaised;

  /// `color/surface-sunken`
  final Color surfaceSunken;

  /// `color/surface-inverse`
  final Color surfaceInverse;

  /// `color/scrim`
  final Color scrim;

  /// `color/text-primary`
  final Color textPrimary;

  /// `color/text-secondary`
  final Color textSecondary;

  /// `color/text-disabled`
  final Color textDisabled;

  /// `color/text-inverse`
  final Color textInverse;

  /// `color/text-on-marker`
  final Color textOnMarker;

  /// `color/text-error`
  final Color textError;

  /// `color/text-warning`
  final Color textWarning;

  /// `color/line-hairline`
  final Color lineHairline;

  /// `color/line-dot`
  final Color lineDot;

  /// `color/line-control`
  final Color lineControl;

  /// `color/line-strong`
  final Color lineStrong;

  /// `color/line-focus`
  final Color lineFocus;

  /// `color/action-primary`
  final Color actionPrimary;

  /// `color/action-on-primary`
  final Color actionOnPrimary;

  /// `color/action-inverse`
  final Color actionInverse;

  /// `color/marker`
  final Color marker;

  /// `color/selection`
  final Color selection;

  /// `color/selection-handle`
  final Color selectionHandle;

  /// `color/state-draft`
  final Color stateDraft;

  /// `color/state-frozen`
  final Color stateFrozen;

  /// `color/state-master`
  final Color stateMaster;

  /// `color/feedback-error-surface`
  final Color feedbackErrorSurface;

  /// `color/feedback-on-error-surface`
  final Color feedbackOnErrorSurface;

  /// `color/feedback-warning-surface`
  final Color feedbackWarningSurface;

  /// `color/feedback-on-warning-surface`
  final Color feedbackOnWarningSurface;

  /// Modus `light`.
  static const light = AppColorTokens(
    brightness: Brightness.light,
    surfacePage: AppColorPrimitives.neutral50,
    surfaceRaised: AppColorPrimitives.neutral0,
    surfaceSunken: AppColorPrimitives.neutral100,
    surfaceInverse: AppColorPrimitives.neutral900,
    scrim: AppColorPrimitives.neutral950,
    textPrimary: AppColorPrimitives.neutral900,
    textSecondary: AppColorPrimitives.neutral600,
    textDisabled: AppColorPrimitives.neutral400,
    textInverse: AppColorPrimitives.neutral50,
    textOnMarker: AppColorPrimitives.neutral900,
    textError: AppColorPrimitives.red600,
    textWarning: AppColorPrimitives.orange700,
    lineHairline: AppColorPrimitives.neutral150,
    lineDot: AppColorPrimitives.neutral150,
    lineControl: AppColorPrimitives.neutral500,
    lineStrong: AppColorPrimitives.neutral900,
    lineFocus: AppColorPrimitives.neutral900,
    actionPrimary: AppColorPrimitives.neutral900,
    actionOnPrimary: AppColorPrimitives.neutral50,
    actionInverse: AppColorPrimitives.marker400,
    marker: AppColorPrimitives.marker400,
    selection: AppColorPrimitives.marker400,
    selectionHandle: AppColorPrimitives.neutral900,
    stateDraft: AppColorPrimitives.neutral500,
    stateFrozen: AppColorPrimitives.neutral900,
    stateMaster: AppColorPrimitives.marker400,
    feedbackErrorSurface: AppColorPrimitives.red100,
    feedbackOnErrorSurface: AppColorPrimitives.red800,
    feedbackWarningSurface: AppColorPrimitives.orange100,
    feedbackOnWarningSurface: AppColorPrimitives.orange800,
  );

  /// Modus `dark`.
  static const dark = AppColorTokens(
    brightness: Brightness.dark,
    surfacePage: AppColorPrimitives.neutral900,
    surfaceRaised: AppColorPrimitives.neutral800,
    surfaceSunken: AppColorPrimitives.neutral950,
    surfaceInverse: AppColorPrimitives.neutral50,
    scrim: AppColorPrimitives.neutral950,
    textPrimary: AppColorPrimitives.neutral50,
    textSecondary: AppColorPrimitives.neutral400,
    textDisabled: AppColorPrimitives.neutral600,
    textInverse: AppColorPrimitives.neutral900,
    textOnMarker: AppColorPrimitives.neutral900,
    textError: AppColorPrimitives.red300,
    textWarning: AppColorPrimitives.orange300,
    lineHairline: AppColorPrimitives.neutral700,
    lineDot: AppColorPrimitives.neutral800,
    lineControl: AppColorPrimitives.neutral500,
    lineStrong: AppColorPrimitives.neutral50,
    lineFocus: AppColorPrimitives.neutral50,
    actionPrimary: AppColorPrimitives.neutral50,
    actionOnPrimary: AppColorPrimitives.neutral900,
    actionInverse: AppColorPrimitives.neutral900,
    marker: AppColorPrimitives.marker500,
    selection: AppColorPrimitives.marker500,
    selectionHandle: AppColorPrimitives.neutral50,
    stateDraft: AppColorPrimitives.neutral400,
    stateFrozen: AppColorPrimitives.neutral50,
    stateMaster: AppColorPrimitives.marker500,
    feedbackErrorSurface: AppColorPrimitives.red900,
    feedbackOnErrorSurface: AppColorPrimitives.red100,
    feedbackWarningSurface: AppColorPrimitives.orange900,
    feedbackOnWarningSurface: AppColorPrimitives.orange100,
  );

  /// Alle Rollen mit ihrem Figma-Namen, in der Reihenfolge der Token-Datei.
  Map<String, Color> get byFigmaName => {
        'color/surface-page': surfacePage,
        'color/surface-raised': surfaceRaised,
        'color/surface-sunken': surfaceSunken,
        'color/surface-inverse': surfaceInverse,
        'color/scrim': scrim,
        'color/text-primary': textPrimary,
        'color/text-secondary': textSecondary,
        'color/text-disabled': textDisabled,
        'color/text-inverse': textInverse,
        'color/text-on-marker': textOnMarker,
        'color/text-error': textError,
        'color/text-warning': textWarning,
        'color/line-hairline': lineHairline,
        'color/line-dot': lineDot,
        'color/line-control': lineControl,
        'color/line-strong': lineStrong,
        'color/line-focus': lineFocus,
        'color/action-primary': actionPrimary,
        'color/action-on-primary': actionOnPrimary,
        'color/action-inverse': actionInverse,
        'color/marker': marker,
        'color/selection': selection,
        'color/selection-handle': selectionHandle,
        'color/state-draft': stateDraft,
        'color/state-frozen': stateFrozen,
        'color/state-master': stateMaster,
        'color/feedback-error-surface': feedbackErrorSurface,
        'color/feedback-on-error-surface': feedbackOnErrorSurface,
        'color/feedback-warning-surface': feedbackWarningSurface,
        'color/feedback-on-warning-surface': feedbackOnWarningSurface,
      };
}
