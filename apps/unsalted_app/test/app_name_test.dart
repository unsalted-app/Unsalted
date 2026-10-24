// test/app_name_test.dart
//
// APP-06 (Teil 1.4 M01, F9): Der sichtbare Name der App ist auf allen
// Plattformen „unsalted“ (klein, Markenbuch) — iOS `CFBundleDisplayName` und
// `CFBundleName`, macOS ebenso, Android `android:label`. Produktname,
// Bundle-Kennungen und `applicationId` bleiben, sonst wäre es für das System
// eine neue App (neue Installation statt Update, andere Build-Pfade).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String? _string(String plist, String key) =>
    RegExp('<key>$key</key>\\s*<string>([^<]*)</string>').firstMatch(plist)?.group(1);

void main() {
  for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
    test('APP-06: $path zeigt „unsalted“', () {
      final plist = File(path).readAsStringSync();
      expect(_string(plist, 'CFBundleDisplayName'), 'unsalted');
      expect(_string(plist, 'CFBundleName'), 'unsalted');
    });
  }

  test('APP-06: Android zeigt „unsalted“', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(RegExp(r'android:label="([^"]*)"').firstMatch(manifest)?.group(1), 'unsalted');
  });

  test('APP-06: Produktname, Bundle-Kennungen und applicationId bleiben', () {
    final macos = File('macos/Runner/Configs/AppInfo.xcconfig').readAsStringSync();
    expect(RegExp(r'^PRODUCT_NAME = (.*)$', multiLine: true).firstMatch(macos)?.group(1), 'unsalted_app');
    expect(RegExp(r'^PRODUCT_BUNDLE_IDENTIFIER = (.*)$', multiLine: true).firstMatch(macos)?.group(1),
        'de.unsalted.unsaltedApp');
    final ios = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final iosIds = {for (final m in RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]*);').allMatches(ios)) m.group(1)};
    expect(iosIds, {'de.unsalted.unsaltedApp', 'de.unsalted.unsaltedApp.RunnerTests'});
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(RegExp(r'applicationId = "([^"]*)"').firstMatch(gradle)?.group(1), 'de.unsalted.unsalted_app');
  });
}
