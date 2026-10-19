// lib/src/theme/component_themes.dart
//
// Komponenten-Themes (Teil 1.3, D04): Fläche, Kontur, Ecke, Innenabstand,
// Mindesthöhe und Zustände der Material-Widgets, die die Komponenten bauen —
// nur aus Tokens (docs/design/system/07-figma-schritt-fuer-schritt.md,
// Abschnitt 7, und die Karten unter docs/design/system/components/). Die
// Komponenten bauen weiter dieselben Material-Widgets; ihre Gestalt kommt von
// hier. Nicht exportiert; `AppTheme` setzt sie in `ThemeData`. Was sich mit
// Material-Themes nicht ausdrücken lässt (Beschriftung über dem Feld,
// Auswahlbalken der Navigation, Schatten `shadow-overlay` an Menüs und
// Dialogen, Strichlinien), entsteht in den Komponenten (D06–D10).

import 'package:flutter/material.dart';

import '../tokens/color_tokens.g.dart';
import '../tokens/opacity_tokens.g.dart';
import '../tokens/radius_tokens.g.dart';
import '../tokens/size_tokens.g.dart';
import '../tokens/spacing_tokens.g.dart';
import '../tokens/stroke_tokens.g.dart';
import '../tokens/typography_tokens.g.dart';

/// Komponenten-Themes für einen Satz Farbrollen.
class AppComponentThemes {
  /// Themes für die Rollen [c].
  const AppComponentThemes(this.c);

  /// Farbrollen des Modus.
  final AppColorTokens c;

  static RoundedRectangleBorder _rounded(double radius, [BorderSide side = BorderSide.none]) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: side);

  /// Überlagerung bei Hover/Fokus (`opacity-hover`) und Drücken
  /// (`opacity-pressed`) in der Farbe des Inhalts.
  static WidgetStateProperty<Color?> overlay(Color content) => WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return content.withValues(alpha: AppOpacity.pressed);
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return content.withValues(alpha: AppOpacity.hover);
        }
        return null;
      });

  WidgetStateProperty<Color?> _content(Color enabled) =>
      WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.disabled) ? c.textDisabled : enabled);

  ButtonStyle _button({required Color content, required double horizontal}) => ButtonStyle(
        foregroundColor: _content(content),
        iconColor: _content(content),
        overlayColor: overlay(content),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(_rounded(AppRadius.s)),
        minimumSize: const WidgetStatePropertyAll(Size(0, AppSize.control)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: horizontal)),
        textStyle: const WidgetStatePropertyAll(AppTypography.bodyStrong),
        iconSize: const WidgetStatePropertyAll(AppSize.iconSmall),
      );

  /// Primärbutton: Tintenfläche (Button-Karte).
  ElevatedButtonThemeData get elevatedButton => ElevatedButtonThemeData(
        style: _button(content: c.actionOnPrimary, horizontal: AppSpacing.l).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? c.surfaceSunken : c.actionPrimary,
          ),
        ),
      );

  /// Sekundärbutton: Tintenkontur, ohne Fläche.
  OutlinedButtonThemeData get outlinedButton => OutlinedButtonThemeData(
        style: _button(content: c.textPrimary, horizontal: AppSpacing.l).copyWith(
          side: WidgetStateProperty.resolveWith((states) => BorderSide(
                color: states.contains(WidgetState.disabled) ? c.lineHairline : c.lineStrong,
                width: AppStroke.frame,
              )),
        ),
      );

  /// Tertiärbutton: nur Text.
  TextButtonThemeData get textButton =>
      TextButtonThemeData(style: _button(content: c.textPrimary, horizontal: AppSpacing.m));

  /// Symbol-Schaltfläche: Tippziel `size-target`, Symbol `size-icon`.
  IconButtonThemeData get iconButton => IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: _content(c.textPrimary),
          overlayColor: overlay(c.textPrimary),
          minimumSize: const WidgetStatePropertyAll(Size.square(AppSize.target)),
          iconSize: const WidgetStatePropertyAll(AppSize.icon),
          shape: WidgetStatePropertyAll(_rounded(AppRadius.s)),
        ),
      );

  /// Marker-Knopf: Markerfläche, Tintenkontur, flach (Fab-Karte).
  FloatingActionButtonThemeData get fab => FloatingActionButtonThemeData(
        backgroundColor: c.marker,
        foregroundColor: c.textOnMarker,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        hoverColor: c.textOnMarker.withValues(alpha: AppOpacity.hover),
        focusColor: c.textOnMarker.withValues(alpha: AppOpacity.hover),
        splashColor: c.textOnMarker.withValues(alpha: AppOpacity.pressed),
        shape: _rounded(AppRadius.s, BorderSide(color: c.textOnMarker, width: AppStroke.frame)),
        sizeConstraints: const BoxConstraints.tightFor(width: AppSize.fab, height: AppSize.fab),
        iconSize: AppSize.icon,
      );

  OutlineInputBorder _field(Color color, double width) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.s), borderSide: BorderSide(color: color, width: width));

  /// Eingabefeld: weiße Fläche, feine Kontur, Fokus und Fehler in
  /// `stroke-focus` (TextField-Karte).
  InputDecorationThemeData get input => InputDecorationThemeData(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? c.surfaceSunken : c.surfaceRaised,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
        border: _field(c.lineControl, AppStroke.hairline),
        enabledBorder: _field(c.lineControl, AppStroke.hairline),
        focusedBorder: _field(c.lineFocus, AppStroke.focus),
        errorBorder: _field(c.textError, AppStroke.focus),
        focusedErrorBorder: _field(c.textError, AppStroke.focus),
        disabledBorder: _field(c.lineHairline, AppStroke.hairline),
        hintStyle: AppTypography.body.copyWith(color: c.textSecondary),
        helperStyle: AppTypography.caption.copyWith(color: c.textSecondary),
        errorStyle: AppTypography.caption.copyWith(color: c.textError),
      );

  /// Auswahl-Chip und Tag: Kontur `line-control`, gewählt invers mit Häkchen
  /// (Chip-Karte).
  ChipThemeData get chip => ChipThemeData(
        backgroundColor: c.surfaceRaised,
        selectedColor: c.surfaceInverse,
        disabledColor: c.surfaceSunken,
        checkmarkColor: c.textInverse,
        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
              color: states.contains(WidgetState.selected) ? c.surfaceInverse : c.lineControl,
              width: AppStroke.hairline,
            )),
        shape: _rounded(AppRadius.s),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? c.textInverse : c.textPrimary,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        iconTheme: IconThemeData(size: AppSize.iconXs, color: c.textPrimary),
      );

  /// Listeneintrag ohne Karte: Titel `body-strong`, Untertitel `body-small`
  /// in `text-secondary` (ListItem-Karte; 02: Untertitel ausdrücklich).
  ListTileThemeData get listTile => ListTileThemeData(
        titleTextStyle: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        minVerticalPadding: AppSpacing.m,
        minTileHeight: AppSize.listItem,
        iconColor: c.textPrimary,
        // Kein `textColor`: ListTile färbt damit auch den Untertitel; die
        // Stile oben tragen ihre Farbe selbst.
      );

  /// Trenner: Haarlinie.
  DividerThemeData get divider => DividerThemeData(color: c.lineHairline, thickness: AppStroke.hairline);

  /// Meldung: inverse Fläche, „Rückgängig“ in `action-inverse`, höchstens
  /// `size-dialog` breit (Snackbar-Karte).
  SnackBarThemeData get snackBar => SnackBarThemeData(
        backgroundColor: c.surfaceInverse,
        contentTextStyle: AppTypography.body.copyWith(color: c.textInverse),
        actionTextColor: c.actionInverse,
        shape: _rounded(AppRadius.s),
        behavior: SnackBarBehavior.floating,
        width: AppSize.dialog,
        elevation: 0,
      );

  /// Dialog: weiße Fläche, Haarlinie, `radius-m`; Scrim mit `opacity-scrim`.
  DialogThemeData get dialog => DialogThemeData(
        backgroundColor: c.surfaceRaised,
        elevation: 0,
        shape: _rounded(AppRadius.m, BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
        titleTextStyle: AppTypography.titlePage.copyWith(color: c.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: c.textPrimary),
        barrierColor: c.scrim.withValues(alpha: AppOpacity.scrim),
      );

  /// Menü: weiße Fläche, Haarlinie, `radius-m`.
  PopupMenuThemeData get popupMenu => PopupMenuThemeData(
        color: c.surfaceRaised,
        elevation: 0,
        shape: _rounded(AppRadius.m, BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
        textStyle: AppTypography.body.copyWith(color: c.textPrimary),
      );

  /// Karte: weiße Fläche, Haarlinie, `radius-m`, kein Schatten.
  CardThemeData get card => CardThemeData(
        color: c.surfaceRaised,
        elevation: 0,
        shape: _rounded(AppRadius.m, BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
      );

  /// Ladekreis und Ladebalken in Tinte (States-Karte).
  ProgressIndicatorThemeData get progress => ProgressIndicatorThemeData(
        color: c.textPrimary,
        linearTrackColor: c.lineHairline,
        linearMinHeight: AppStroke.rule,
        strokeWidth: AppStroke.focus,
      );

  /// Kopfleiste: Papier, Titel links in `title-page`, Haarlinie statt Schatten
  /// (TopBar-Karte).
  AppBarThemeData get appBar => AppBarThemeData(
        backgroundColor: c.surfacePage,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppSize.topBar,
        titleTextStyle: AppTypography.titlePage.copyWith(color: c.textPrimary),
        shape: Border(bottom: BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
      );

  /// Navigationsleiste: Papier, ohne Pille (Auswahlbalken folgt in D10).
  NavigationBarThemeData get navigationBar => NavigationBarThemeData(
        backgroundColor: c.surfacePage,
        elevation: 0,
        height: AppSize.navBar,
        indicatorColor: c.surfacePage,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => AppTypography.labelSmall.copyWith(
              color: states.contains(WidgetState.selected) ? c.textPrimary : c.textSecondary,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: AppSize.icon,
              color: states.contains(WidgetState.selected) ? c.textPrimary : c.textSecondary,
            )),
      );

  /// Tooltip: inverse Fläche, `label-small`.
  TooltipThemeData get tooltip => TooltipThemeData(
        textStyle: AppTypography.labelSmall.copyWith(color: c.textInverse),
        decoration: BoxDecoration(color: c.surfaceInverse, borderRadius: BorderRadius.circular(AppRadius.xs)),
      );
}
