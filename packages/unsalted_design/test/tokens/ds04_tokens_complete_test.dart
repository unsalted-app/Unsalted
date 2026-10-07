// test/tokens/ds04_tokens_complete_test.dart
//
// DS-04 (Teil 1.2): Beide Farbmodi haben dieselben Rollen mit denselben
// Figma-Namen, und das daraus gebaute ColorScheme trägt jede Rolle. Die
// übrigen Token-Gruppen haben eindeutige Figma-Namen im erwarteten Format.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

void main() {
  test('DS-04: hell und dunkel haben dieselben 46 Rollen', () {
    final light = AppColorTokens.light.byFigmaName;
    final dark = AppColorTokens.dark.byFigmaName;
    expect(light.keys.toList(), dark.keys.toList());
    expect(light, hasLength(46));
    expect(light.keys.every((k) => RegExp(r'^color/[a-z]+(-[a-z]+)*$').hasMatch(k)), isTrue);
    expect(AppColorTokens.light.brightness, Brightness.light);
    expect(AppColorTokens.dark.brightness, Brightness.dark);
  });

  test('DS-04: toColorScheme übernimmt jede Rolle', () {
    for (final tokens in [AppColorTokens.light, AppColorTokens.dark]) {
      final scheme = tokens.toColorScheme();
      expect(scheme.brightness, tokens.brightness);
      expect(scheme.primary, tokens.primary);
      expect(scheme.onSurfaceVariant, tokens.onSurfaceVariant);
      expect(scheme.surfaceContainerHighest, tokens.surfaceContainerHighest);
      expect(scheme.onTertiaryFixedVariant, tokens.onTertiaryFixedVariant);
      expect(scheme.surfaceTint, tokens.surfaceTint);
    }
  });

  test('DS-04: Figma-Namen der übrigen Gruppen', () {
    final groups = <String, Map<String, Object>>{
      'type': AppTypography.byFigmaName,
      'space': AppSpacing.byFigmaName,
      'radius': AppRadius.byFigmaName,
      'elevation': AppElevation.byFigmaName,
      'breakpoint': AppBreakpoints.byFigmaName,
    };
    for (final MapEntry(key: group, value: tokens) in groups.entries) {
      expect(tokens.keys.every((k) => RegExp('^$group/[a-z0-9]+(-[a-z0-9]+)*\$').hasMatch(k)), isTrue,
          reason: group);
    }
    expect(AppTypography.byFigmaName, hasLength(15));
  });

  test('DS-04: Typo-Tokens entsprechen der Material-3-Typskala von Flutter', () {
    final reference = Typography.englishLike2021;
    final tokens = AppTypography.textTheme;
    final pairs = {
      'displayLarge': (tokens.displayLarge, reference.displayLarge),
      'displayMedium': (tokens.displayMedium, reference.displayMedium),
      'displaySmall': (tokens.displaySmall, reference.displaySmall),
      'headlineLarge': (tokens.headlineLarge, reference.headlineLarge),
      'headlineMedium': (tokens.headlineMedium, reference.headlineMedium),
      'headlineSmall': (tokens.headlineSmall, reference.headlineSmall),
      'titleLarge': (tokens.titleLarge, reference.titleLarge),
      'titleMedium': (tokens.titleMedium, reference.titleMedium),
      'titleSmall': (tokens.titleSmall, reference.titleSmall),
      'labelLarge': (tokens.labelLarge, reference.labelLarge),
      'labelMedium': (tokens.labelMedium, reference.labelMedium),
      'labelSmall': (tokens.labelSmall, reference.labelSmall),
      'bodyLarge': (tokens.bodyLarge, reference.bodyLarge),
      'bodyMedium': (tokens.bodyMedium, reference.bodyMedium),
      'bodySmall': (tokens.bodySmall, reference.bodySmall),
    };
    for (final MapEntry(key: role, value: (token, ref)) in pairs.entries) {
      expect(token!.fontSize, ref!.fontSize, reason: role);
      expect(token.fontWeight, ref.fontWeight, reason: role);
      expect(token.height, ref.height, reason: role);
      expect(token.letterSpacing, ref.letterSpacing, reason: role);
      expect(token.color, isNull, reason: '$role: Typo-Tokens tragen keine Farbe');
    }
  });

  testWidgets('DS-04: Bewegung entfällt bei „Bewegung reduzieren“', (tester) async {
    late Duration normal;
    late Duration reduced;
    await tester.pumpWidget(Builder(builder: (context) {
      normal = AppMotion.durationOf(context);
      return MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(builder: (context) {
          reduced = AppMotion.durationOf(context, AppMotion.long);
          return const SizedBox.shrink();
        }),
      );
    }));
    expect(normal, AppMotion.medium);
    expect(reduced, Duration.zero);
  });
}
