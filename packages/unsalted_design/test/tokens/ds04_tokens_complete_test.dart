// test/tokens/ds04_tokens_complete_test.dart
//
// DS-04 (Teil 1.2, neu gefasst in Teil 1.3 D03): Die Token-Klassen unter
// lib/src/tokens/ sind genau das Generat der Token-Datei
// (tool/generate_tokens.dart), die Token-Datei im Paket ist byteweise gleich
// der Übergabe (docs/design/system/tokens.json, F8), und die Werte im Code
// entsprechen der JSON: 28 Farbrollen hell und dunkel, elf Textstile mit
// tabellarischen Ziffern genau für display, label-small, data und
// data-strong (02-typografie), Namen nach der Regel aus 05.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../tool/generate_tokens.dart';
import '../architecture/support/design_test_utils.dart';

Color _hex(String hex) => Color(int.parse('FF${hex.substring(1)}', radix: 16));

void main() {
  final root = findPackageRoot();
  final jsonText = File('${root.path}/$tokenFile').readAsStringSync();
  final json = jsonDecode(jsonText) as Map<String, dynamic>;
  List<Map<String, dynamic>> tokens(String group) => (json[group]['tokens'] as List).cast<Map<String, dynamic>>();

  test('DS-04: Token-Datei gleich der Übergabe (docs/design/system/tokens.json)', () {
    final handoff = File('${root.parent.parent.path}/docs/design/system/tokens.json').readAsBytesSync();
    expect(File('${root.path}/$tokenFile').readAsBytesSync(), handoff);
  });

  test('DS-04: lib/src/tokens/ ist genau das Generat', () {
    final generated = generateTokenFiles(jsonText);
    final onDisk = {
      for (final f in Directory('${root.path}/$outputDir').listSync().whereType<File>())
        f.uri.pathSegments.last: f.readAsStringSync(),
    };
    expect(onDisk.keys.toSet(), generated.keys.toSet(), reason: 'fehlende oder zusätzliche Dateien');
    for (final MapEntry(key: name, value: content) in generated.entries) {
      expect(onDisk[name], content, reason: '$name weicht ab — `dart run tool/generate_tokens.dart` ausführen');
    }
  });

  test('DS-04: Farbrollen hell und dunkel wie in der Token-Datei', () {
    final primitives = {
      for (final t in tokens('color'))
        if (!(t['value'] as Map).containsKey('dark')) t['name'] as String: _hex((t['value'] as Map)['light'] as String),
    };
    final roles = [for (final t in tokens('color')) if ((t['value'] as Map).containsKey('dark')) t];
    expect(primitives, hasLength(23));
    expect(roles, hasLength(28));
    for (final (mode, set) in [('light', AppColorTokens.light), ('dark', AppColorTokens.dark)]) {
      expect(set.brightness, mode == 'light' ? Brightness.light : Brightness.dark);
      final byName = set.byFigmaName;
      expect(byName.keys, [for (final r in roles) 'color/${r['name']}']);
      for (final r in roles) {
        final alias = ((r['value'] as Map)[mode] as String).replaceAll(RegExp(r'[{}]'), '');
        expect(byName['color/${r['name']}'], primitives[alias], reason: '${r['name']} ($mode)');
      }
    }
  });

  test('DS-04: Textstile wie in der Token-Datei', () {
    final styles = [
      for (final g in (json['type']['groups'] as List).cast<Map<String, dynamic>>())
        ...(g['styles'] as List).cast<Map<String, dynamic>>(),
    ];
    expect(styles, hasLength(11));
    expect(AppTypography.byFigmaName.keys, [for (final s in styles) 'type/${s['name']}']);
    for (final s in styles) {
      final style = AppTypography.byFigmaName['type/${s['name']}']!;
      final size = double.parse((s['fontSize'] as String).replaceAll('px', ''));
      final line = double.parse((s['lineHeight'] as String).replaceAll('px', ''));
      expect(style.fontSize, size, reason: s['name'] as String);
      expect(style.fontSize! * style.height!, closeTo(line, 1e-9), reason: s['name'] as String);
      expect(style.fontWeight!.value, int.parse(s['fontWeight'] as String), reason: s['name'] as String);
      expect(style.letterSpacing, 0);
      expect(style.color, isNull, reason: 'Textstile tragen keine Farbe');
    }
    final tabular = {
      for (final MapEntry(key: name, value: style) in AppTypography.byFigmaName.entries)
        if (style.fontFeatures?.contains(const FontFeature.tabularFigures()) ?? false) name,
    };
    expect(tabular, {'type/display', 'type/label-small', 'type/data', 'type/data-strong'});
    expect(AppTypography.body.fontFamily, AppFonts.qualifiedFamily);
    expect(AppTypography.code.fontFamily, isNot(AppFonts.qualifiedFamily), reason: 'code = Systemschrift (F7)');
    expect(AppTypography.code.fontFamilyFallback, contains('Menlo'));
  });

  test('DS-04: Zahlengruppen wie in der Token-Datei, Namen nach 05', () {
    double px(Object v) => double.parse(((v is Map ? v['100'] : v) as String).replaceAll('px', ''));
    void check(String group, String prefix, String figma, Map<String, double> actual) {
      final expected = {
        for (final t in tokens(group))
          if ((t['name'] as String).startsWith(prefix))
            '$figma/${(t['name'] as String).substring(prefix.length)}': px(t['value'] as Object),
      };
      expect(actual, expected, reason: group);
      expect(actual.keys.every((k) => RegExp('^$figma/[a-z]+(-[a-z]+)*\$').hasMatch(k)), isTrue, reason: group);
    }

    check('spacing', 'space-', 'space', AppSpacing.byFigmaName);
    check('radius', 'radius-', 'radius', AppRadius.byFigmaName);
    check('stroke', 'stroke-', 'stroke', AppStroke.byFigmaName);
    check('size', 'size-', 'size', AppSize.byFigmaName);
    check('size', 'reflow-', 'reflow', AppReflow.byFigmaName);
    check('opacity', 'opacity-', 'opacity', AppOpacity.byFigmaName);
    check('breakpoint', 'breakpoint-', 'breakpoint', AppBreakpoints.byFigmaName);
    expect([for (final s in AppSpace.values) s.value], AppSpacing.byFigmaName.values.toList());
    expect(AppMotion.byFigmaName, {
      for (final t in tokens('duration'))
        'motion/duration/${(t['name'] as String).substring('duration-'.length)}':
            Duration(milliseconds: int.parse((t['value'] as String).replaceAll('ms', ''))),
    });
    expect(AppMotion.standard, const Cubic(0.2, 0, 0, 1));
    expect(AppShadow.byFigmaName.keys, ['shadow/overlay', 'shadow/focus']);
    expect(AppShadow.focus(Brightness.light).last.spreadRadius, 2, reason: 'Spalt in Papierfarbe zuletzt (oben)');
    expect(AppShadow.focus(Brightness.light).last.color, AppColorTokens.light.surfacePage);
    expect(AppShadow.focus(Brightness.light).first.color, AppColorTokens.light.lineFocus);
  });

  test('DS-04: reflow-Werte je Textgröße 100 und 200 (D12a)', () {
    final reflow = [for (final t in tokens('size')) if ((t['name'] as String).startsWith('reflow-')) t];
    expect([for (final t in reflow) t['name']], [
      'reflow-value-column',
      'reflow-label-min',
      'reflow-stat-min',
      'reflow-field-min',
      'reflow-select-min',
      'reflow-rule-inline',
      'reflow-rule-stacked',
      'reflow-inset-inline',
    ]);
    for (final t in reflow) {
      final value = t['value'] as Map<String, dynamic>;
      expect(value.keys, ['100', '200'], reason: t['name'] as String);
      for (final v in value.values) {
        expect(v, matches(RegExp(r'^\d+px$')), reason: t['name'] as String);
      }
    }
    for (final t in tokens('size')) {
      if ((t['name'] as String).startsWith('size-')) expect(t['value'], isA<String>(), reason: t['name'] as String);
    }
    double px(String v) => double.parse(v.replaceAll('px', ''));
    expect(AppReflow.byFigmaNameAt200, {
      for (final t in reflow)
        'reflow/${(t['name'] as String).substring('reflow-'.length)}': px((t['value'] as Map)['200'] as String),
    });
  });

  test('DS-04: der Generator ist stabil (zweimal gleich)', () {
    expect(generateTokenFiles(jsonText), generateTokenFiles(jsonText));
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
