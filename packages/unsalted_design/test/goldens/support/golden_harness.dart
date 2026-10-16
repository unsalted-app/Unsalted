// test/goldens/support/golden_harness.dart
//
// Golden-Varianten (Teil 1.3, D01): hell/dunkel × Handy/Tablet × Text
// 100/200 %, je Motiv acht Bilder unter `test/goldens/images/<motiv>/`.
// Erzeugt und verglichen wird nur unter Linux (`goldens.yml`, `ci.yml`,
// docs/design/plan-1.3.md d4); die Testdateien tragen `@TestOn('linux')`.
//
// Schriften lädt nur diese Harness, nicht global über
// `flutter_test_config.dart`: Sonst änderten sich die Textmaße aller übrigen
// Tests, die mit der Testschrift rechnen. Bis die Schrift des Design-Systems
// im Theme steht, ist es Roboto (Material-Standard) aus dem Flutter-SDK.
//
// Schatten zeichnet flutter_test absichtlich als schwarze Kontur
// (`debugDisableShadows`, Vorgabe des Test-Bindings für stabile Bilder);
// so bleiben sie auch hier.
//
// Überlauf („A RenderFlex overflowed …“) ist hier kein Fehler: Er erscheint im
// Bild als Streifen und gehört zum festgehaltenen Stand. Streng geprüft wird
// Überlauf in WB-01 (100 %) und ab D12 in WB-04 (200 %).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Eine Golden-Variante; [name] ist zugleich der Dateiname des Bildes.
typedef GoldenVariant = ({String name, Brightness brightness, Size size, double textScale});

/// Fenstergrößen wie in `design_harness.dart` (logische Pixel).
const goldenSizes = {'handy': Size(390, 844), 'tablet': Size(1024, 1366)};

/// Alle acht Varianten.
List<GoldenVariant> get goldenVariants => [
      for (final MapEntry(key: device, value: size) in goldenSizes.entries)
        for (final (mode, brightness) in [('hell', Brightness.light), ('dunkel', Brightness.dark)])
          for (final scale in [1.0, 2.0])
            (
              name: '${mode}_${device}_${(scale * 100).round()}',
              brightness: brightness,
              size: size,
              textScale: scale,
            ),
    ];

var _fontsLoaded = false;

/// Lädt die Schriften der Bilder einmal je Testdatei (in `setUpAll`).
Future<void> loadGoldenFonts() async {
  if (_fontsLoaded) return;
  final sdkFonts = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  Future<ByteData> read(String path) async => ByteData.sublistView(await File(path).readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final file in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']) {
    roboto.addFont(read('$sdkFonts/$file'));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')..addFont(read('$sdkFonts/MaterialIcons-Regular.otf'))).load();
  _fontsLoaded = true;
}

/// Theme der [variant] aus dem Design-Paket.
ThemeData goldenTheme(GoldenVariant variant) =>
    variant.brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light();

/// Setzt Fenstergröße und Textgröße der [variant] für den laufenden Test.
void applyGoldenView(WidgetTester tester, GoldenVariant variant) {
  tester.view.physicalSize = variant.size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = variant.textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

bool _isOverflow(FlutterErrorDetails details) => details.exceptionAsString().contains('overflowed');

/// Führt [body] aus und lässt dabei nur Überlauf-Meldungen durch; jede andere
/// Ausnahme bleibt ein Fehler.
Future<void> tolerateOverflow(Future<void> Function() body) async {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (!_isOverflow(details)) previous?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
}

/// Vergleicht den ganzen Bildschirm mit `images/<motif>/<variante>.png`.
Future<void> expectGolden(String motif, GoldenVariant variant) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('images/$motif/${variant.name}.png'));

/// Ein Golden-Test je Variante für das Motiv [motif]: [home] ist die Seite,
/// [after] pumpt bei Bedarf weiter (z. B. eine eingeblendete Meldung).
void testGolden(
  String id,
  String motif,
  Widget Function() home, {
  Future<void> Function(WidgetTester tester)? after,
}) {
  for (final variant in goldenVariants) {
    testWidgets('$id: $motif (${variant.name})', (tester) async {
      applyGoldenView(tester, variant);
      await tolerateOverflow(() async {
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: goldenTheme(variant),
          home: home(),
        ));
        await tester.pump(const Duration(seconds: 1));
        if (after != null) await after(tester);
        await expectGolden(motif, variant);
      });
    }, tags: ['golden']);
  }
}
