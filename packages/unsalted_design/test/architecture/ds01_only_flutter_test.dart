// test/architecture/ds01_only_flutter_test.dart
//
// DS-01 (Teil 1.2, Kapitel 28.9): unsalted_design hängt nur von Flutter ab.
// lib/ importiert ausschließlich package:flutter/, das eigene Paket, relative
// Dateien und dart:ui, dart:math, dart:async, dart:collection; pubspec.yaml
// nennt unter dependencies nur flutter. Ergänzt tool/check_architecture.dart
// (allowed_in_design).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_utils.dart';

const _allowedDart = {'dart:ui', 'dart:math', 'dart:async', 'dart:collection'};

/// Unzulässige Importziele in [targets].
List<String> forbiddenTargets(Iterable<String> targets) => [
      for (final target in targets)
        if (!(target.startsWith('package:flutter/') ||
            target.startsWith('package:unsalted_design/') ||
            _allowedDart.contains(target) ||
            !target.contains(':')))
          target,
    ];

/// Paketnamen im `dependencies:`-Block von [pubspec].
List<String> dependencyNames(String pubspec) {
  final names = <String>[];
  var inBlock = false;
  for (final line in pubspec.split('\n')) {
    if (line.startsWith('dependencies:')) {
      inBlock = true;
      continue;
    }
    if (!inBlock) continue;
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) break;
    final m = RegExp(r'^  ([a-zA-Z0-9_]+):').firstMatch(line);
    if (m != null) names.add(m.group(1)!);
  }
  return names;
}

void main() {
  final root = findPackageRoot();

  test('DS-01: lib/ importiert nur Flutter und sich selbst', () {
    final violations = <String>[];
    for (final file in dartFilesUnder(Directory('${root.path}/lib'))) {
      for (final (line, target) in directiveTargets(file.readAsStringSync())) {
        if (forbiddenTargets([target]).isNotEmpty) {
          violations.add('${relativePath(file, root)}:$line → $target');
        }
      }
    }
    expect(violations, isEmpty, reason: 'Unzulässige Importe:\n${violations.join('\n')}');
  });

  test('DS-01: pubspec.yaml hängt nur von flutter ab', () {
    final names = dependencyNames(File('${root.path}/pubspec.yaml').readAsStringSync());
    expect(names, ['flutter']);
  });

  test('DS-01: der Detektor erkennt Verstöße', () {
    expect(
      forbiddenTargets([
        'package:flutter_riverpod/flutter_riverpod.dart',
        'package:unsalted_core/unsalted_core.dart',
        'package:drift/drift.dart',
        'dart:io',
        'dart:ffi',
      ]),
      hasLength(5),
    );
    expect(
      forbiddenTargets([
        'package:flutter/material.dart',
        'package:unsalted_design/unsalted_design.dart',
        'src/tokens/color_tokens.dart',
        'dart:ui',
        'dart:math',
      ]),
      isEmpty,
    );
    expect(dependencyNames('name: x\ndependencies:\n  flutter:\n    sdk: flutter\n  intl: ^1.0.0\n\ndev_dependencies:\n  test: any\n'),
        ['flutter', 'intl']);
  });
}
