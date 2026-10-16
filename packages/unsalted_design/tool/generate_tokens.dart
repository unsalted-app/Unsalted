// tool/generate_tokens.dart
//
// Token-Generator (Teil 1.3, D03): liest `tokens/unsalted.tokens.json` (die
// Übergabe aus Figma, gleich `docs/design/system/tokens.json`) und schreibt
// alle Dateien unter `lib/src/tokens/`. Diese Dateien entstehen nur hier —
// nie von Hand ändern; DS-04 prüft, dass sie dem Generat entsprechen.
//
//   dart run tool/generate_tokens.dart
//
// Namensregel (docs/design/system/05-figma-und-code.md): `color/text-secondary`
// → `AppColorTokens.light.textSecondary`, `space/l` → `AppSpacing.l`,
// `size/control` → `AppSize.control`, `type/data-strong` →
// `AppTypography.dataStrong` usw. Werte und Namen kommen ausschließlich aus
// der JSON-Datei; der Generator kennt nur die Umrechnung (px, ms,
// cubic-bezier, CSS-Schatten, Schriftstapel) und die festen Vorlagen für die
// Hilfslogik (`AppSpace`, `AppMotion.durationOf`). Bewusst ohne Pakete, damit
// das Design-Paket nur von Flutter abhängt.

import 'dart:convert';
import 'dart:io';

/// Pfad der Token-Datei relativ zur Paketwurzel.
const tokenFile = 'tokens/unsalted.tokens.json';

/// Zielordner relativ zur Paketwurzel.
const outputDir = 'lib/src/tokens';

void main() {
  final json = File(tokenFile).readAsStringSync();
  final files = generateTokenFiles(json);
  final dir = Directory(outputDir);
  for (final old in dir.listSync().whereType<File>()) {
    if (!files.containsKey(old.uri.pathSegments.last)) old.deleteSync();
  }
  files.forEach((name, content) => File('$outputDir/$name').writeAsStringSync(content));
  stdout.writeln('${files.length} Dateien nach $outputDir geschrieben.');
}

/// Erzeugt alle Token-Dateien aus dem Inhalt der Token-Datei: Dateiname →
/// Inhalt, in fester Reihenfolge.
Map<String, String> generateTokenFiles(String json) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  return {
    'breakpoint_tokens.g.dart': _numbers(data, 'breakpoint', 'AppBreakpoints', 'breakpoint',
        'Fensterbreiten-Grenzen (untere Grenzen der Material-Fenstergrößen).'),
    'color_tokens.g.dart': _colors(data),
    'motion_tokens.g.dart': _motion(data),
    'opacity_tokens.g.dart': _numbers(data, 'opacity', 'AppOpacity', 'opacity',
        'Deckkraft der Zustandsebenen (0 bis 1; in Figma in Prozent).'),
    'radius_tokens.g.dart': _numbers(data, 'radius', 'AppRadius', 'radius', 'Eckenradien.'),
    'shadow_tokens.g.dart': _shadows(data),
    'size_tokens.g.dart': _sizes(data),
    'spacing_tokens.g.dart': _spacing(data),
    'stroke_tokens.g.dart': _numbers(data, 'stroke', 'AppStroke', 'stroke', 'Linienstärken und Strichmuster.'),
    'typography_tokens.g.dart': _typography(data),
  };
}

// ---------------------------------------------------------------------------
// Hilfen

String _header(String file, String what) => '''
// lib/src/tokens/$file
//
// GENERIERT aus $tokenFile durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). $what
''';

/// `text-secondary` → `textSecondary`.
String _camel(String name) {
  final parts = name.split('-');
  return parts.first + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

/// `16px` → `16`, `1.5px` → `1.5`, `0.06` → `0.06`.
String _number(String value) {
  final n = num.parse(value.replaceAll('px', '').trim());
  return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}

/// `#f9f7f1` → `0xFFF9F7F1`, `#0c101929` (CSS RGBA) → `0x290C1019`.
String _color(String hex) {
  final h = hex.replaceFirst('#', '').toUpperCase();
  if (h.length == 6) return '0xFF$h';
  if (h.length == 8) return '0x${h.substring(6)}${h.substring(0, 6)}';
  throw FormatException('Farbe nicht lesbar: $hex');
}

/// Verwendungshinweise der Token-Datei kommen nicht in den Code: Sie nennen
/// Fachbegriffe (DS-06). Wo ein Wert eingesetzt wird, steht in
/// docs/design/system/ (01-farbe, 02-typografie, 07).
String _doc(Object? usage) => '';

/// Bricht [text] für Doku-Kommentare nach etwa 100 Zeichen um.
String _wrap(String text, String prefix) {
  final lines = <String>[];
  var line = StringBuffer();
  for (final word in text.split(' ')) {
    if (line.length + word.length > 96 && line.isNotEmpty) {
      lines.add(line.toString().trimRight());
      line = StringBuffer();
    }
    line.write('$word ');
  }
  lines.add(line.toString().trimRight());
  return lines.join('\n$prefix');
}

List<Map<String, dynamic>> _tokens(Map<String, dynamic> data, String group) =>
    (data[group]['tokens'] as List).cast<Map<String, dynamic>>();

// ---------------------------------------------------------------------------
// Einfache Zahlengruppen

String _numbers(Map<String, dynamic> data, String group, String className, String figma, String what) {
  final tokens = _tokens(data, group);
  final prefix = '$figma-';
  final b = StringBuffer(_header('${group}_tokens.g.dart', 'Gruppe `$group`.'))
    ..writeln()
    ..writeln('/// $what')
    ..writeln('///')
    ..writeln('/// ${_wrap(data[group]['note'] as String, '/// ')}')
    ..writeln('abstract final class $className {');
  for (final t in tokens) {
    final name = (t['name'] as String).substring(prefix.length);
    b
      ..writeln('  /// `$figma/$name`${_doc(t['usage'])}')
      ..writeln('  static const double ${_camel(name)} = ${_number(t['value'] as String)};')
      ..writeln();
  }
  b.writeln('  /// Alle Werte mit ihrem Figma-Namen.');
  b.writeln('  static const byFigmaName = <String, double>{');
  for (final t in tokens) {
    final name = (t['name'] as String).substring(prefix.length);
    b.writeln("    '$figma/$name': ${_camel(name)},");
  }
  b
    ..writeln('  };')
    ..writeln('}');
  return b.toString();
}

String _spacing(Map<String, dynamic> data) {
  final tokens = _tokens(data, 'spacing');
  final names = [for (final t in tokens) (t['name'] as String).substring('space-'.length)];
  final b = StringBuffer(_numbers(data, 'spacing', 'AppSpacing', 'space', 'Abstände (4-px-Raster).'))
    ..writeln()
    ..writeln('/// Abstandsstufe als Parameter für Layout und Komponenten. Bildschirme geben')
    ..writeln('/// Abstände nur als Stufe an, nie als Zahl (AT-14).')
    ..writeln('enum AppSpace {');
  for (var i = 0; i < names.length; i++) {
    b
      ..writeln('  /// `space/${names[i]}`')
      ..writeln('  ${_camel(names[i])}(AppSpacing.${_camel(names[i])})${i == names.length - 1 ? ';' : ','}');
    if (i < names.length - 1) b.writeln();
  }
  b
    ..writeln()
    ..writeln('  const AppSpace(this.value);')
    ..writeln()
    ..writeln('  /// Wert in logischen Pixeln.')
    ..writeln('  final double value;')
    ..writeln('}');
  return b.toString();
}

String _sizes(Map<String, dynamic> data) {
  final tokens = _tokens(data, 'size');
  final sizes = [for (final t in tokens) if ((t['name'] as String).startsWith('size-')) t];
  final reflow = [for (final t in tokens) if ((t['name'] as String).startsWith('reflow-')) t];
  final b = StringBuffer(_header('size_tokens.g.dart', 'Gruppe `size`: feste Maße und Grundwerte der\n// mitwachsenden Maße (`reflow-*`).'))
    ..writeln()
    ..writeln('/// Feste Maße der Komponenten: Tippziele, Höhen, Breiten, Spalten.')
    ..writeln('///')
    ..writeln('/// ${_wrap(data['size']['note'] as String, '/// ')}')
    ..writeln('abstract final class AppSize {');
  void field(Map<String, dynamic> t, String prefix, String figma) {
    final name = (t['name'] as String).substring(prefix.length);
    b
      ..writeln('  /// `$figma/$name`${_doc(t['usage'])}')
      ..writeln('  static const double ${_camel(name)} = ${_number(t['value'] as String)};')
      ..writeln();
  }

  void map(List<Map<String, dynamic>> list, String prefix, String figma) {
    b.writeln('  /// Alle Werte mit ihrem Figma-Namen.');
    b.writeln('  static const byFigmaName = <String, double>{');
    for (final t in list) {
      final name = (t['name'] as String).substring(prefix.length);
      b.writeln("    '$figma/$name': ${_camel(name)},");
    }
    b.writeln('  };');
  }

  for (final t in sizes) {
    field(t, 'size-', 'size');
  }
  map(sizes, 'size-', 'size');
  b
    ..writeln('}')
    ..writeln()
    ..writeln('/// Maße neben Text, die mit der Textgröße wachsen: Grundwerte bei 100 %.')
    ..writeln('/// In Figma liegen sie in der Sammlung `type` (Modi `100`/`200`).')
    ..writeln('abstract final class AppReflow {');
  for (final t in reflow) {
    field(t, 'reflow-', 'reflow');
  }
  map(reflow, 'reflow-', 'reflow');
  b.writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// Farben

String _colors(Map<String, dynamic> data) {
  final tokens = _tokens(data, 'color');
  final primitives = [for (final t in tokens) if (!(t['value'] as Map).containsKey('dark')) t];
  final roles = [for (final t in tokens) if ((t['value'] as Map).containsKey('dark')) t];
  final primitiveNames = {for (final p in primitives) p['name'] as String};

  String ref(String alias) {
    final name = alias.replaceAll(RegExp(r'[{}]'), '');
    if (!primitiveNames.contains(name)) throw FormatException('Unbekanntes Primitiv: $alias');
    return 'AppColorPrimitives.${_camel(name)}';
  }

  final b = StringBuffer(_header('color_tokens.g.dart',
      'Farben: Primitive (Markenpalette, nur hier und\n// in der Material-Zuordnung von AppTheme) und semantische Rollen je Modus.'))
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('/// Markenpalette (Figma-Sammlung `primitives`). Komponenten verwenden nie')
    ..writeln('/// Primitive, sondern Rollen aus [AppColorTokens]; Ausnahme ist die')
    ..writeln('/// Material-Zuordnung in `AppTheme` (docs/design/system/01-farbe.md).')
    ..writeln('abstract final class AppColorPrimitives {');
  for (final p in primitives) {
    final name = p['name'] as String;
    final dash = name.lastIndexOf('-');
    b
      ..writeln('  /// `primitives/${name.substring(0, dash)}/${name.substring(dash + 1)}`${_doc(p['usage'])}')
      ..writeln('  static const ${_camel(name)} = Color(${_color((p['value'] as Map)['light'] as String)});')
      ..writeln();
  }
  b
    ..writeln('  /// Alle Primitive mit ihrem Figma-Namen.')
    ..writeln('  static const byFigmaName = <String, Color>{');
  for (final p in primitives) {
    final name = p['name'] as String;
    final dash = name.lastIndexOf('-');
    b.writeln("    'primitives/${name.substring(0, dash)}/${name.substring(dash + 1)}': ${_camel(name)},");
  }
  b
    ..writeln('  };')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Semantische Farbrollen eines Modus (Figma-Sammlung `color`, Modi `light`')
    ..writeln('/// und `dark`). Jede Rolle verweist auf ein Primitiv.')
    ..writeln('@immutable')
    ..writeln('class AppColorTokens {')
    ..writeln('  /// Erzeugt einen vollständigen Satz Rollen.')
    ..writeln('  const AppColorTokens({')
    ..writeln('    required this.brightness,');
  for (final r in roles) {
    b.writeln('    required this.${_camel(r['name'] as String)},');
  }
  b
    ..writeln('  });')
    ..writeln()
    ..writeln('  /// Helligkeit des Modus.')
    ..writeln('  final Brightness brightness;')
    ..writeln();
  for (final r in roles) {
    b
      ..writeln('  /// `color/${r['name']}`${_doc(r['usage'])}')
      ..writeln('  final Color ${_camel(r['name'] as String)};')
      ..writeln();
  }
  for (final mode in ['light', 'dark']) {
    b
      ..writeln('  /// Modus `$mode`.')
      ..writeln('  static const $mode = AppColorTokens(')
      ..writeln('    brightness: Brightness.$mode,');
    for (final r in roles) {
      b.writeln('    ${_camel(r['name'] as String)}: ${ref((r['value'] as Map)[mode] as String)},');
    }
    b
      ..writeln('  );')
      ..writeln();
  }
  b
    ..writeln('  /// Alle Rollen mit ihrem Figma-Namen, in der Reihenfolge der Token-Datei.')
    ..writeln('  Map<String, Color> get byFigmaName => {');
  for (final r in roles) {
    b.writeln("        'color/${r['name']}': ${_camel(r['name'] as String)},");
  }
  b
    ..writeln('      };')
    ..writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// Schatten

/// CSS `0 4px 16px #0c101929, 0 1px 3px #0c10191f` → `BoxShadow`-Liste. CSS
/// zeichnet den ersten Schatten oben, Flutter den letzten; die Reihenfolge
/// wird deshalb umgekehrt.
String _boxShadows(String css) {
  final shadows = [
    for (final part in css.split(RegExp(r',\s*')))
      () {
        final f = part.trim().split(RegExp(r'\s+'));
        final x = _number(f[0]), y = _number(f[1]), blur = _number(f[2]);
        final spread = f.length == 5 ? _number(f[3]) : '0';
        return 'BoxShadow(offset: Offset($x, $y), blurRadius: $blur, spreadRadius: $spread, '
            'color: Color(${_color(f.last)}))';
      }(),
  ].reversed;
  return '[\n${shadows.map((s) => '    $s,').join('\n')}\n  ]';
}

String _shadows(Map<String, dynamic> data) {
  final tokens = _tokens(data, 'shadow');
  final b = StringBuffer(_header('shadow_tokens.g.dart', 'Gruppe `shadow`: Überlagerung und Fokusring je\n// Modus.'))
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('/// Schatten. ${_wrap(data['shadow']['note'] as String, '/// ')}')
    ..writeln('abstract final class AppShadow {');
  for (final t in tokens) {
    final name = (t['name'] as String).substring('shadow-'.length);
    for (final mode in ['light', 'dark']) {
      b
        ..writeln('  /// `shadow/$name`, Modus `$mode`.${_doc(t['usage'])}')
        ..writeln(
            '  static const ${_camel(name)}${mode[0].toUpperCase()}${mode.substring(1)} = <BoxShadow>${_boxShadows((t['value'] as Map)[mode] as String)};')
        ..writeln();
    }
    b
      ..writeln('  /// `shadow/$name` für [brightness].')
      ..writeln('  static List<BoxShadow> ${_camel(name)}(Brightness brightness) =>')
      ..writeln('      brightness == Brightness.dark ? ${_camel(name)}Dark : ${_camel(name)}Light;')
      ..writeln();
  }
  b
    ..writeln('  /// Alle Schatten mit ihrem Figma-Namen, je Modus.')
    ..writeln('  static const byFigmaName = <String, ({List<BoxShadow> light, List<BoxShadow> dark})>{');
  for (final t in tokens) {
    final name = (t['name'] as String).substring('shadow-'.length);
    b.writeln("    'shadow/$name': (light: ${_camel(name)}Light, dark: ${_camel(name)}Dark),");
  }
  b
    ..writeln('  };')
    ..writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// Bewegung

String _motion(Map<String, dynamic> data) {
  final durations = _tokens(data, 'duration');
  final easings = _tokens(data, 'easing');
  final b = StringBuffer(_header('motion_tokens.g.dart',
      'Gruppen `duration` und `easing`; dazu die feste\n// Vorlage für „Bewegung reduzieren“ (`durationOf`).'))
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('/// Dauern und Kurven für Animationen. ${_wrap(data['duration']['note'] as String, '/// ')}')
    ..writeln('abstract final class AppMotion {');
  for (final t in durations) {
    final name = (t['name'] as String).substring('duration-'.length);
    final ms = int.parse((t['value'] as String).replaceAll('ms', '').trim());
    b
      ..writeln('  /// `motion/duration/$name`${_doc(t['usage'])}')
      ..writeln('  static const $name = Duration(milliseconds: $ms);')
      ..writeln();
  }
  for (final t in easings) {
    final name = (t['name'] as String).substring('easing-'.length);
    final args = RegExp(r'cubic-bezier\(([^)]*)\)').firstMatch(t['value'] as String)!.group(1)!;
    b
      ..writeln('  /// `motion/easing/$name`${_doc(t['usage'])}')
      ..writeln('  static const Curve $name = Cubic(${args.split(',').map((a) => _number(a)).join(', ')});')
      ..writeln();
  }
  b
    ..writeln('  /// `motion/easing/emphasized` — laut Token-Datei (Hinweis zu `easing`)')
    ..writeln('  /// nur im Code und bis zur ersten Verwendung behalten.')
    ..writeln('  static const Curve emphasized = Curves.easeInOutCubicEmphasized;')
    ..writeln()
    ..writeln('  /// `true`, wenn das System „Bewegung reduzieren“ verlangt.')
    ..writeln('  static bool reduceMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);')
    ..writeln()
    ..writeln('  /// [duration] oder 0, wenn das System „Bewegung reduzieren“ verlangt.')
    ..writeln('  static Duration durationOf(BuildContext context, [Duration duration = medium]) =>')
    ..writeln('      reduceMotion(context) ? Duration.zero : duration;')
    ..writeln()
    ..writeln('  /// Alle Dauern mit ihrem Figma-Namen.')
    ..writeln('  static const byFigmaName = <String, Duration>{');
  for (final t in durations) {
    final name = (t['name'] as String).substring('duration-'.length);
    b.writeln("    'motion/duration/$name': $name,");
  }
  b
    ..writeln('  };')
    ..writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// Typografie

/// Stile mit tabellarischen Ziffern: die Gruppe „Daten“ und jeder Stil, dessen
/// Hinweis in der Token-Datei `tnum` nennt (02-typografie: display,
/// label-small, data, data-strong).
bool _tabular(Map<String, dynamic> group, Map<String, dynamic> style) =>
    (group['note'] as String).contains('tabellarischen Ziffern') || (style['usage'] as String).contains('tnum');

/// CSS-Schriftstapel → (Familie, Rückfall); Anführungszeichen entfernt.
(String, List<String>) _stack(String css) {
  final names = [for (final n in css.split(',')) n.trim().replaceAll('"', '')];
  return (names.first, names.skip(1).where((n) => !const {'system-ui', 'sans-serif'}.contains(n)).toList());
}

String _typography(Map<String, dynamic> data) {
  final type = data['type'] as Map<String, dynamic>;
  final families = type['families'] as Map<String, dynamic>;
  final groups = (type['groups'] as List).cast<Map<String, dynamic>>();
  final b = StringBuffer(_header('typography_tokens.g.dart',
      'Gruppe `type`: die elf Textstile (ohne Farbe).\n// `sans` ist die gebündelte Schrift (AppFonts), `mono` die Systemschrift aus dem\n// Stapel der Token-Datei.'))
    ..writeln()
    ..writeln("import 'package:flutter/painting.dart';")
    ..writeln()
    ..writeln("import '../theme/app_fonts.dart';")
    ..writeln()
    ..writeln('/// Textstile. Laufweite überall 0, Zeilenhöhen auf dem 4-px-Raster.')
    ..writeln('abstract final class AppTypography {');
  final names = <String>[];
  for (final group in groups) {
    final (family, fallback) = _stack(families[group['family']] as String);
    final bundled = group['family'] == 'sans';
    for (final style in (group['styles'] as List).cast<Map<String, dynamic>>()) {
      final name = style['name'] as String;
      names.add(name);
      final size = _number(style['fontSize'] as String);
      final line = num.parse(_number(style['lineHeight'] as String));
      final height = (line / num.parse(size)).toString();
      final weight = 'FontWeight.w${style['fontWeight']}';
      final family0 = bundled ? 'AppFonts.family' : "'$family'";
      b
        ..writeln('  /// `type/$name`: ${style['fontSize']} / ${style['lineHeight']}, ${style['fontWeight']}.${_doc(style['usage'])}')
        ..writeln('  static const ${_camel(name)} = TextStyle(')
        ..writeln('    fontFamily: $family0,');
      if (bundled) b.writeln('    package: AppFonts.package,');
      if (fallback.isNotEmpty) b.writeln("    fontFamilyFallback: [${fallback.map((f) => "'$f'").join(', ')}],");
      b
        ..writeln('    fontSize: $size,')
        ..writeln('    height: $height,')
        ..writeln('    fontWeight: $weight,')
        ..writeln('    letterSpacing: ${_number(style['letterSpacing'] as String)},');
      if (_tabular(group, style)) b.writeln('    fontFeatures: [FontFeature.tabularFigures()],');
      b
        ..writeln('  );')
        ..writeln();
    }
  }
  b
    ..writeln('  /// Alle Stile mit ihrem Figma-Namen, in der Reihenfolge der Token-Datei.')
    ..writeln('  static const byFigmaName = <String, TextStyle>{');
  for (final n in names) {
    b.writeln("    'type/$n': ${_camel(n)},");
  }
  b
    ..writeln('  };')
    ..writeln('}');
  return b.toString();
}
