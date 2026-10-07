// lib/main.dart
//
// Komponenten-Katalog von unsalted (Teil 1.2): alle Tokens, Komponenten und
// Templates aus `unsalted_design`, je hell/dunkel (Theme-Addon) und
// Handy/Tablet (Viewport-Addon). Start: `flutter run -d macos` in diesem
// Ordner (Web erst nach `flutter config --enable-web` und
// `flutter create --platforms=web .`, docs/decisions.md C11).

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'catalog/catalog.dart';

void main() => runApp(const CatalogApp());

/// Der Katalog.
class CatalogApp extends StatelessWidget {
  /// Erzeugt den Katalog.
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
        directories: catalog,
        addons: [
          MaterialThemeAddon(themes: [
            WidgetbookTheme(name: 'Hell', data: AppTheme.light()),
            WidgetbookTheme(name: 'Dunkel', data: AppTheme.dark()),
          ]),
          ViewportAddon([IosViewports.iPhone13, IosViewports.iPadPro11Inches]),
        ],
      );
}
