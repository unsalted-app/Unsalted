// test/theme/ds52_component_themes_test.dart
//
// DS-52 (Teil 1.3, D04): Die Komponenten-Themes nehmen Fläche, Kontur, Ecke,
// Innenabstand, Mindesthöhe und Schrift aus den Tokens
// (docs/design/system/07, Abschnitt 7, und die Komponentenkarten). Je Modus
// geprüft am `ThemeData` und an einem gebauten Primärbutton.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../support/design_harness.dart';

BorderRadius? _radius(Object? shape) => switch (shape) {
      RoundedRectangleBorder(:final borderRadius) => borderRadius as BorderRadius,
      _ => null,
    };

BorderSide? _side(Object? shape) => switch (shape) {
      RoundedRectangleBorder(:final side) => side,
      _ => null,
    };

void main() {
  for (final (mode, theme, c) in [
    ('hell', AppTheme.light(), AppColorTokens.light),
    ('dunkel', AppTheme.dark(), AppColorTokens.dark),
  ]) {
    test('DS-52: Buttons ($mode)', () {
      final primary = theme.elevatedButtonTheme.style!;
      expect(primary.backgroundColor!.resolve({}), c.actionPrimary);
      expect(primary.backgroundColor!.resolve({WidgetState.disabled}), c.surfaceSunken);
      expect(primary.foregroundColor!.resolve({}), c.actionOnPrimary);
      expect(primary.foregroundColor!.resolve({WidgetState.disabled}), c.textDisabled);
      expect(primary.overlayColor!.resolve({WidgetState.hovered}), c.actionOnPrimary.withValues(alpha: AppOpacity.hover));
      expect(primary.overlayColor!.resolve({WidgetState.pressed}), c.actionOnPrimary.withValues(alpha: AppOpacity.pressed));
      expect(primary.minimumSize!.resolve({})!.height, AppSize.control);
      expect(primary.padding!.resolve({}), const EdgeInsets.symmetric(horizontal: AppSpacing.l));
      expect(_radius(primary.shape!.resolve({})), BorderRadius.circular(AppRadius.s));
      expect(primary.textStyle!.resolve({}), AppTypography.bodyStrong);
      expect(primary.elevation!.resolve({}), 0);

      final secondary = theme.outlinedButtonTheme.style!;
      expect(secondary.side!.resolve({}), BorderSide(color: c.lineStrong, width: AppStroke.frame));
      expect(secondary.side!.resolve({WidgetState.disabled})!.color, c.lineHairline);
      expect(secondary.foregroundColor!.resolve({}), c.textPrimary);

      final tertiary = theme.textButtonTheme.style!;
      expect(tertiary.padding!.resolve({}), const EdgeInsets.symmetric(horizontal: AppSpacing.m));

      final icon = theme.iconButtonTheme.style!;
      expect(icon.minimumSize!.resolve({}), const Size.square(AppSize.target));
      expect(icon.iconSize!.resolve({}), AppSize.icon);
    });

    test('DS-52: Marker-Knopf ($mode)', () {
      final fab = theme.floatingActionButtonTheme;
      expect(fab.backgroundColor, c.marker);
      expect(fab.foregroundColor, c.textOnMarker);
      expect(fab.elevation, 0);
      expect(_side(fab.shape), BorderSide(color: c.textOnMarker, width: AppStroke.frame));
      expect(_radius(fab.shape), BorderRadius.circular(AppRadius.s));
      expect(fab.sizeConstraints, const BoxConstraints.tightFor(width: AppSize.fab, height: AppSize.fab));
    });

    test('DS-52: Eingabe, Chip, Liste, Trenner ($mode)', () {
      final input = theme.inputDecorationTheme;
      expect(input.filled, isTrue);
      expect(input.fillColor, isA<WidgetStateColor>());
      expect((input.fillColor! as WidgetStateColor).resolve({}), c.surfaceRaised);
      expect((input.enabledBorder! as OutlineInputBorder).borderSide, BorderSide(color: c.lineControl, width: AppStroke.hairline));
      expect((input.focusedBorder! as OutlineInputBorder).borderSide, BorderSide(color: c.lineFocus, width: AppStroke.focus));
      expect((input.errorBorder! as OutlineInputBorder).borderSide, BorderSide(color: c.textError, width: AppStroke.focus));
      expect((input.enabledBorder! as OutlineInputBorder).borderRadius, BorderRadius.circular(AppRadius.s));

      final chip = theme.chipTheme;
      expect(chip.backgroundColor, c.surfaceRaised);
      expect(chip.selectedColor, c.surfaceInverse);
      expect(chip.checkmarkColor, c.textInverse);
      expect(_radius(chip.shape), BorderRadius.circular(AppRadius.s));

      final tile = theme.listTileTheme;
      expect(tile.titleTextStyle!.fontSize, AppTypography.bodyStrong.fontSize);
      expect(tile.titleTextStyle!.fontWeight, AppTypography.bodyStrong.fontWeight);
      expect(tile.subtitleTextStyle!.fontSize, AppTypography.bodySmall.fontSize);
      expect(tile.subtitleTextStyle!.color, c.textSecondary);
      expect(tile.minTileHeight, AppSize.listItem);
      expect(tile.textColor, isNull, reason: 'textColor überschriebe die Untertitelfarbe');
      expect(tile.contentPadding, const EdgeInsets.symmetric(horizontal: AppSpacing.l));

      expect(theme.dividerTheme.color, c.lineHairline);
      expect(theme.dividerTheme.thickness, AppStroke.hairline);
      expect(theme.dividerColor, c.lineHairline);
    });

    test('DS-52: Meldung, Dialog, Menü, Karte, Laden, Kopfleiste ($mode)', () {
      final snack = theme.snackBarTheme;
      expect(snack.backgroundColor, c.surfaceInverse);
      expect(snack.actionTextColor, c.actionInverse);
      expect(snack.width, AppSize.dialog);
      expect(_radius(snack.shape), BorderRadius.circular(AppRadius.s));

      final dialog = theme.dialogTheme;
      expect(dialog.backgroundColor, c.surfaceRaised);
      expect(_radius(dialog.shape), BorderRadius.circular(AppRadius.m));
      expect(dialog.barrierColor, c.scrim.withValues(alpha: AppOpacity.scrim));

      expect(theme.popupMenuTheme.color, c.surfaceRaised);
      expect(theme.cardTheme.color, c.surfaceRaised);
      expect(theme.cardTheme.elevation, 0);

      final progress = theme.progressIndicatorTheme;
      expect(progress.color, c.textPrimary);
      expect(progress.linearTrackColor, c.lineHairline);
      expect(progress.linearMinHeight, AppStroke.rule);
      expect(progress.strokeWidth, AppStroke.focus);

      final bar = theme.appBarTheme;
      expect(bar.backgroundColor, c.surfacePage);
      expect(bar.elevation, 0);
      expect(bar.toolbarHeight, AppSize.topBar);
      expect(bar.shape, Border(bottom: BorderSide(color: c.lineHairline, width: AppStroke.hairline)));
    });
  }

  testVariants('DS-52: Listeneintrag mit Untertitel in text-secondary', (tester, variant) async {
    await pumpVariant(tester, variant, const AppListItem(title: 'Titel', subtitle: 'Untertitel'));
    final c = variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
    expect(DefaultTextStyle.of(tester.element(find.text('Untertitel'))).style.color, c.textSecondary);
    expect(DefaultTextStyle.of(tester.element(find.text('Titel'))).style.color, c.textPrimary);
  });

  testVariants('DS-52: Primärbutton baut mit Mindesthöhe und Tintenfläche', (tester, variant) async {
    await pumpVariant(
      tester,
      variant,
      const Align(alignment: Alignment.topLeft, child: AppButton.primary(label: 'Speichern', onPressed: _noop)),
    );
    final c = variant.theme.brightness == Brightness.dark ? AppColorTokens.dark : AppColorTokens.light;
    final material = tester.widget<Material>(
      find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Material)).first,
    );
    expect(material.color, c.actionPrimary);
    expect(tester.getSize(find.byType(ElevatedButton)).height, greaterThanOrEqualTo(AppSize.control));
  });
}

void _noop() {}
