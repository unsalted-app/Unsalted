// lib/src/ui/versions/version_mark.dart
//
// Fachlicher Baustein (Teil 1.3, D13): Fassungsmarke einer Version aus
// `AppMark` (Mark-Karte) — Entwurf gestrichelt, eingefroren mit Tintenkontur,
// Master mit Markerfläche. Text „V{versionIndex}“ bzw. „V{versionIndex} ·
// label“ wie bisher; die Semantik nennt Nummer, Bezeichnung, Zustand und
// Master („Version 3 · mit Vorteig, eingefroren, Master“), nie nur Farbe oder
// Linie. Mit [onTap] ein Ziel der Fassungsleiste (Auswahl als Balken).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../recipe/recipe_version.dart';

/// Fassungsmarke einer Version.
class VersionMark extends StatelessWidget {
  /// Erzeugt die Marke.
  const VersionMark({
    super.key,
    required this.version,
    required this.isMaster,
    this.seal = false,
    this.selected = false,
    this.onTap,
  });

  /// Die Version.
  final RecipeVersion version;

  /// `true`: Master-Version des Rezepts.
  final bool isMaster;

  /// `true`: mit Siegel (dort, wo nur der Zustand zählt).
  final bool seal;

  /// `true`: in der Fassungsleiste gewählt.
  final bool selected;

  /// Macht die Marke zum Ziel der Fassungsleiste.
  final VoidCallback? onTap;

  /// Sichtbarer Text: „V{versionIndex}“ bzw. „V{versionIndex} · label“.
  static String textOf(RecipeVersion version) =>
      version.label == null ? 'V${version.versionIndex}' : 'V${version.versionIndex} · ${version.label}';

  /// Text für Screenreader.
  static String semanticsOf(RecipeVersion version, {required bool isMaster}) => [
        version.label == null ? 'Version ${version.versionIndex}' : 'Version ${version.versionIndex} · ${version.label}',
        version.state == VersionState.snapshot ? 'eingefroren' : 'Entwurf',
        if (isMaster) 'Master',
      ].join(', ');

  @override
  Widget build(BuildContext context) => AppMark(
        label: textOf(version),
        state: isMaster
            ? AppMarkState.highlighted
            : (version.state == VersionState.snapshot ? AppMarkState.fixed : AppMarkState.provisional),
        seal: seal,
        semanticLabel: semanticsOf(version, isMaster: isMaster),
        selected: selected,
        onTap: onTap,
      );
}
