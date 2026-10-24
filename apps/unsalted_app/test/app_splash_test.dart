// test/app_splash_test.dart
//
// APP-08 (Teil 1.4 M02b, Figma Seite „Marke“ `275:75`/`275:79`): Das Startbild
// ist Fläche und Symbol — hell Papier `#F9F7F1`, dunkel Tinte `#141925`, das
// Startbild-Symbol (160 × 102) in der Mitte; Android 12 mit dem 288-dp-Symbol
// und denselben Farben; bewusst ohne Punktraster. Erzeugt mit
// `flutter_native_splash` nur als Werkzeug: kein Code in `lib/`.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _ios = 'ios/Runner/Assets.xcassets';
const _res = 'android/app/src/main/res';

/// Breite und Höhe eines PNG.
(int, int) _size(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  return (data.getUint32(16), data.getUint32(20));
}

/// Farbe eines einfarbigen PNG (8 Bit RGB) als „#RRGGBB“.
String _colour(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  expect(bytes[24], 8, reason: '$path: 8 Bit');
  expect(bytes[25], 2, reason: '$path: RGB');
  final idat = BytesBuilder();
  for (var pos = 8; pos + 8 <= bytes.length;) {
    final length = data.getUint32(pos);
    if (String.fromCharCodes(bytes.sublist(pos + 4, pos + 8)) == 'IDAT') {
      idat.add(bytes.sublist(pos + 8, pos + 8 + length));
    }
    pos += 12 + length;
  }
  final raw = ZLibCodec().decode(idat.toBytes());
  final rgb = raw.sublist(1, 4); // Filterbyte, dann das erste Pixel
  return '#${rgb.map((v) => v.toRadixString(16).padLeft(2, '0').toUpperCase()).join()}';
}

void main() {
  test('APP-08: iOS-Startbild — Fläche hell und dunkel, Symbol in der Mitte', () {
    final storyboard = File('ios/Runner/Base.lproj/LaunchScreen.storyboard').readAsStringSync();
    expect(storyboard, contains('image="LaunchBackground"'));
    expect(storyboard, contains('contentMode="center" image="LaunchImage"'), reason: 'Symbol mittig, nicht gestreckt');
    expect(_colour('$_ios/LaunchBackground.imageset/background.png'), '#F9F7F1');
    expect(_colour('$_ios/LaunchBackground.imageset/darkbackground.png'), '#141925');
    expect(File('$_ios/LaunchBackground.imageset/Contents.json').readAsStringSync(), contains('"value" : "dark"'));
    for (final name in ['LaunchImage', 'LaunchImageDark']) {
      expect(_size('$_ios/LaunchImage.imageset/$name.png'), (160, 102), reason: '$name: 160 × 102 pt');
      expect(_size('$_ios/LaunchImage.imageset/$name@3x.png'), (480, 306));
    }
  });

  test('APP-08: Android-Startbild bis 11 und ab 12 mit denselben Farben', () {
    for (final (folder, colour) in [('drawable', '#F9F7F1'), ('drawable-night', '#141925')]) {
      expect(_colour('$_res/$folder/background.png'), colour, reason: folder);
      final layers = File('$_res/$folder/launch_background.xml').readAsStringSync();
      expect(layers, contains('android:src="@drawable/background"'));
      expect(layers, contains('android:gravity="center" android:src="@drawable/splash"'));
    }
    expect(_size('$_res/drawable-mdpi/splash.png'), (160, 102));
    expect(_size('$_res/drawable-night-mdpi/splash.png'), (160, 102));
    for (final (folder, colour) in [('values-v31', '#F9F7F1'), ('values-night-v31', '#141925')]) {
      final styles = File('$_res/$folder/styles.xml').readAsStringSync();
      expect(RegExp(r'windowSplashScreenBackground">([^<]*)<').firstMatch(styles)?.group(1), colour, reason: folder);
      expect(styles, contains('windowSplashScreenAnimatedIcon">@drawable/android12splash<'));
    }
    expect(_size('$_res/drawable-xxxhdpi/android12splash.png'), (1152, 1152), reason: '288 dp');
    expect(_size('$_res/drawable-night-xxxhdpi/android12splash.png'), (1152, 1152));
  });

  test('APP-08: kein Startbild-Code in lib/', () {
    final sources = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final file in sources) {
      expect(file.readAsStringSync(), isNot(contains('flutter_native_splash')), reason: file.path);
    }
  });
}
