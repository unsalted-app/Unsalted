// test/architecture/ds06_no_domain_terms_test.dart
//
// DS-06 (Teil 1.2, Kapitel 28.9): Das Design-Paket kennt keine Fachbegriffe.
// lib/ enthält (auch in Kommentaren) keinen Begriff aus der Wortliste; lib/
// und test/ enthalten die verbotene Energieeinheit nicht (R7, wie AT-12). Der
// Suchbegriff wird aus Zeichencodes gebaut, damit diese Datei sich nicht
// selbst meldet.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/design_test_utils.dart';

final _domainTerms = RegExp(
  r'\b(rezept|recipe|zutat|ingredient|nährwert|naehrwert|nutri|kcal|kalorie|calorie|lebensmittel|food|'
  r'snapshot|portion|serving|barcode|gramm)',
  caseSensitive: false,
);

final _energyUnit = String.fromCharCodes([0x6b, 0x4a]);

/// Zeilen von [source] mit Fachbegriff, als (Zeile, Text).
List<(int, String)> findDomainTerms(String source) {
  final lines = source.split('\n');
  return [
    for (var i = 0; i < lines.length; i++)
      if (_domainTerms.hasMatch(lines[i])) (i + 1, lines[i].trim()),
  ];
}

void main() {
  final root = findPackageRoot();

  test('DS-06: keine Fachbegriffe in lib/', () {
    final violations = <String>[];
    for (final file in dartFilesUnder(Directory('${root.path}/lib'))) {
      for (final (line, text) in findDomainTerms(file.readAsStringSync())) {
        violations.add('${relativePath(file, root)}:$line → $text');
      }
    }
    expect(violations, isEmpty, reason: 'Fachbegriffe gefunden:\n${violations.join('\n')}');
  });

  test('DS-06: keine andere Energieeinheit in lib/ und test/', () {
    final hits = <String>[
      for (final dir in ['lib', 'test'])
        for (final file in dartFilesUnder(Directory('${root.path}/$dir')))
          if (file.readAsStringSync().contains(_energyUnit)) relativePath(file, root),
    ];
    expect(hits, isEmpty);
  });

  test('DS-06: der Detektor erkennt Fachbegriffe', () {
    expect(findDomainTerms('final recipeTitle = 1;\n// Zutaten\nconst x = Nutrients();'), hasLength(3));
    expect(findDomainTerms('class AppButton {}\nfinal spacing = 8;'), isEmpty);
  });
}
