// lib/src/theme/app_fonts.dart
//
// Schrift des Design-Systems (Teil 1.3, D02): Atkinson Hyperlegible Next in
// den Schnitten 400, 600 und 700, gebündelt unter lib/fonts/ und in
// pubspec.yaml deklariert; kein Laden zur Laufzeit. Die Lizenz (SIL OFL 1.1)
// liegt als lib/fonts/OFL.txt bei und erscheint über [AppFonts.registerLicenses]
// unter „Über unsalted“ → Lizenzen.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Schriftfamilie und Lizenz des Design-Systems.
abstract final class AppFonts {
  /// Familienname aus `pubspec.yaml`; in `TextStyle` immer zusammen mit
  /// [package] angeben.
  static const String family = 'AtkinsonHyperlegibleNext';

  /// Paket, das die Schriftdateien bündelt.
  static const String package = 'unsalted_design';

  /// Name, unter dem Flutter die Familie in einer App führt
  /// (`packages/<paket>/<familie>`).
  static const String qualifiedFamily = 'packages/$package/$family';

  /// Schlüssel des Lizenztexts im Asset-Bundle einer App.
  static const String licenseAsset = 'packages/$package/lib/fonts/OFL.txt';

  /// Registriert die Schriftlizenz bei [LicenseRegistry]; einmal beim
  /// Start der App aufrufen. Der Text wird erst gelesen, wenn die
  /// Lizenzseite ihn braucht.
  static void registerLicenses() {
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString(licenseAsset);
      yield LicenseEntryWithLineBreaks(const ['Atkinson Hyperlegible Next'], text);
    });
  }
}
