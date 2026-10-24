// test/app_icon_test.dart
//
// APP-07 (Teil 1.4 M02a, Figma Seite „Marke“ `275:35` ff.): Das App-Symbol ist
// eingebaut. iOS: das Symbol 1024 × 1024 ohne Alphakanal (sonst lehnt der App
// Store es ab), dazu die Fassungen dunkel und getönt (iOS 18). Android: das
// adaptive Symbol (`mipmap-anydpi-v26/ic_launcher.xml`) mit Hintergrund
// (Papier), Vordergrund und einfarbiger Ebene ohne zusätzlichen Rand — die
// Ebenen aus Figma halten die Schutzzone selbst ein.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const _res = 'android/app/src/main/res';

/// Breite, Höhe und ob das PNG einen Alphakanal hat (Farbtyp 4/6 oder `tRNS`).
({int width, int height, bool alpha}) _png(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  expect(bytes.sublist(1, 4), ascii.encode('PNG'), reason: '$path ist kein PNG');
  final colorType = bytes[25];
  var alpha = colorType == 4 || colorType == 6;
  for (var pos = 8; pos + 8 <= bytes.length;) {
    final length = data.getUint32(pos);
    final type = ascii.decode(bytes.sublist(pos + 4, pos + 8));
    if (type == 'tRNS') alpha = true;
    if (type == 'IEND') break;
    pos += 12 + length;
  }
  return (width: data.getUint32(16), height: data.getUint32(20), alpha: alpha);
}

void main() {
  test('APP-07: iOS-Symbol 1024 ohne Alphakanal, dazu dunkel und getönt', () {
    final contents = jsonDecode(File('$_ios/Contents.json').readAsStringSync()) as Map<String, dynamic>;
    final images = (contents['images'] as List).cast<Map<String, dynamic>>();
    String? file1024(String? appearance) => images
        .where((i) =>
            i['size'] == '1024x1024' &&
            i['idiom'] == 'universal' &&
            ((i['appearances'] as List?)?.cast<Map<String, dynamic>>().firstOrNull?['value']) == appearance)
        .firstOrNull?['filename'] as String?;

    final any = file1024(null);
    expect(any, isNotNull);
    final icon = _png('$_ios/$any');
    expect((icon.width, icon.height), (1024, 1024));
    expect(icon.alpha, isFalse, reason: 'App Store verlangt das Symbol ohne Alphakanal');
    for (final appearance in ['dark', 'tinted']) {
      final file = file1024(appearance);
      expect(file, isNotNull, reason: 'Fassung $appearance');
      expect(File('$_ios/$file').existsSync(), isTrue);
    }
  });

  test('APP-07: Android adaptiv mit Vordergrund, Hintergrund und einfarbiger Ebene', () {
    final xml = File('$_res/mipmap-anydpi-v26/ic_launcher.xml').readAsStringSync();
    expect(xml, contains('<adaptive-icon'));
    expect(xml, contains('<background android:drawable="@color/ic_launcher_background"/>'));
    expect(xml, contains('android:drawable="@drawable/ic_launcher_foreground"'));
    expect(xml, contains('<monochrome>'));
    expect(xml, contains('android:drawable="@drawable/ic_launcher_monochrome"'));
    expect(RegExp(r'android:inset="(\d+)%"').allMatches(xml).map((m) => m.group(1)), everyElement('0'),
        reason: 'Ebenen aus Figma halten die Schutzzone selbst ein');
    final colors = File('$_res/values/colors.xml').readAsStringSync();
    expect(RegExp(r'<color name="ic_launcher_background">([^<]*)</color>').firstMatch(colors)?.group(1), '#F9F7F1');
    for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      for (final layer in ['ic_launcher_foreground', 'ic_launcher_monochrome']) {
        final path = '$_res/drawable-$density/$layer.png';
        expect(File(path).existsSync(), isTrue, reason: path);
        expect(_png(path).alpha, isTrue, reason: '$path: Ebene auf transparent');
      }
    }
  });
}
