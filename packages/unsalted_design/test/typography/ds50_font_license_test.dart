// test/typography/ds50_font_license_test.dart
//
// DS-50 (Teil 1.3, D02): Die Schrift ist mit ihrer Lizenz gebündelt, und
// `AppFonts.registerLicenses` registriert die SIL OFL 1.1 unter dem Schlüssel,
// den eine App für Assets dieses Pakets verwendet
// (`packages/unsalted_design/lib/fonts/OFL.txt`). Im Paket-Test ist das Paket
// selbst die Wurzel und trüge den Schlüssel ohne Präfix; deshalb liefert der
// Test die Datei über den Asset-Kanal unter genau dem App-Schlüssel aus.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../architecture/support/design_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = findPackageRoot();

  test('DS-50: Schriftdateien und Lizenz sind deklariert', () {
    final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: ${AppFonts.family}'));
    for (final (file, weight) in [('Regular', 400), ('SemiBold', 600), ('Bold', 700)]) {
      expect(pubspec, contains('asset: lib/fonts/AtkinsonHyperlegibleNext-$file.ttf\n          weight: $weight'));
      expect(File('${root.path}/lib/fonts/AtkinsonHyperlegibleNext-$file.ttf').existsSync(), isTrue);
    }
    expect(pubspec, contains('- lib/fonts/OFL.txt'));
    expect(AppFonts.licenseAsset, 'packages/unsalted_design/lib/fonts/OFL.txt');
    expect(AppFonts.qualifiedFamily, 'packages/unsalted_design/AtkinsonHyperlegibleNext');
  });

  test('DS-50: registerLicenses registriert die OFL', () async {
    final license = File('${root.path}/lib/fonts/OFL.txt').readAsBytesSync();
    final requested = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets',
        (message) async {
      final key = utf8.decode(message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
      requested.add(key);
      return key == AppFonts.licenseAsset ? ByteData.sublistView(Uint8List.fromList(license)) : null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
      LicenseRegistry.reset();
    });

    AppFonts.registerLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    final font = entries.singleWhere((e) => e.packages.contains('Atkinson Hyperlegible Next'));
    final text = font.paragraphs.map((p) => p.text).join('\n');

    expect(requested, [AppFonts.licenseAsset]);
    expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
    expect(text, contains('The Atkinson Hyperlegible Next Project Authors'));
  });
}
