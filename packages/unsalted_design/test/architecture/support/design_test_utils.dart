// test/architecture/support/design_test_utils.dart
//
// Gemeinsame Hilfsfunktionen der Architekturtests des Design-Pakets (DS-01
// ff.). Bewusst ohne YAML-Bibliothek, wie tool/check_architecture.dart.

import 'dart:io';

/// Wurzel des Pakets (Ordner mit pubspec.yaml und lib/), unabhängig davon,
/// aus welchem Verzeichnis `flutter test` gestartet wurde.
Directory findPackageRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 4; i++) {
    if (File('${dir.path}/pubspec.yaml').existsSync() && Directory('${dir.path}/lib').existsSync()) {
      return dir;
    }
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  throw StateError('Paketwurzel ausgehend von ${Directory.current.path} nicht gefunden.');
}

/// Alle .dart-Dateien unter [dir], sortiert.
List<File> dartFilesUnder(Directory dir) => dir
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

/// Pfad von [file] relativ zu [root], mit `/`.
String relativePath(File file, Directory root) =>
    file.path.substring(root.path.length + 1).replaceAll(Platform.pathSeparator, '/');

/// Entfernt Kommentare, behält aber Zeilenumbrüche (für Zeilennummern).
String stripComments(String source) {
  final withoutBlocks = source.replaceAllMapped(
    RegExp(r'/\*[\s\S]*?\*/'),
    (m) => '\n' * '\n'.allMatches(m[0]!).length,
  );
  return withoutBlocks.split('\n').map((line) => line.split('//').first).join('\n');
}

/// Ziel jeder import-/export-Direktive in [source] als (Zeile, Ziel).
List<(int, String)> directiveTargets(String source) {
  final regex = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');
  final lines = source.split('\n');
  return [
    for (var i = 0; i < lines.length; i++)
      if (regex.firstMatch(lines[i]) case final m?) (i + 1, m.group(1)!),
  ];
}
