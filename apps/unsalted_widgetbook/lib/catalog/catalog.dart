// lib/catalog/catalog.dart
//
// Gliederung des Katalogs wie das Design-Paket: Tokens, Layout, Komponenten
// je Ordner, Templates. Komponentenname = Dart-Klasse, Anwendungsfall =
// Figma-Variante (docs/design/components.md).

import 'package:widgetbook/widgetbook.dart';

import 'buttons.dart';
import 'data.dart';
import 'feedback.dart';
import 'inputs.dart';
import 'layout.dart';
import 'lists.dart';
import 'navigation.dart';
import 'surfaces.dart';
import 'templates.dart';
import 'tokens.dart';

/// Alle Einträge des Katalogs.
final List<WidgetbookNode> catalog = [
  tokensFolder,
  layoutFolder,
  WidgetbookCategory(name: 'Komponenten', children: [
    buttonsFolder,
    surfacesFolder,
    inputsFolder,
    listsFolder,
    feedbackFolder,
    navigationFolder,
    dataFolder,
  ]),
  templatesFolder,
];
