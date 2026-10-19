// test/bundle_language_test.dart
//
// APP-05 (Teil 1.3, D17c): Deutsch ist die Sprache des App-Bundles. Menüs, die
// das System selbst zeichnet (unter iOS „Kopieren“, „Ausschneiden“ in der
// Textauswahl), richten sich nach den Sprachen des Bundles, nicht nach den
// Flutter-Texten (APP-03): `CFBundleLocalizations` nennt „de“,
// `CFBundleDevelopmentRegion` ist „de“ — in iOS und macOS.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String? _string(String plist, String key) =>
    RegExp('<key>$key</key>\\s*<string>([^<]*)</string>').firstMatch(plist)?.group(1);

List<String>? _strings(String plist, String key) {
  final array = RegExp('<key>$key</key>\\s*<array>(.*?)</array>', dotAll: true).firstMatch(plist)?.group(1);
  if (array == null) return null;
  return [for (final match in RegExp('<string>([^<]*)</string>').allMatches(array)) match.group(1)!];
}

void main() {
  for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
    test('APP-05: $path mit Sprache de', () {
      final plist = File(path).readAsStringSync();
      expect(_string(plist, 'CFBundleDevelopmentRegion'), 'de');
      expect(_strings(plist, 'CFBundleLocalizations'), contains('de'));
    });
  }
}
