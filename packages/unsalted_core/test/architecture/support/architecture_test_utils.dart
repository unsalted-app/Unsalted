// test/architecture/support/architecture_test_utils.dart
//
// Gemeinsame Hilfsfunktionen für alle Architekturtests (AT-01 bis AT-11).
// Bewusst ohne externe YAML-Bibliothek, analog zu tool/check_architecture.dart.

import 'dart:io';

/// Findet architecture.yaml, indem ab dem aktuellen Arbeitsverzeichnis nach
/// oben gesucht wird. Robust unabhängig davon, ob `flutter test` aus dem
/// Paket-Ordner oder dem Projekt-Root gestartet wird.
File findArchitectureYaml() {
  Directory dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    final candidate = File('${dir.path}/architecture.yaml');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'architecture.yaml wurde ausgehend von ${Directory.current.path} nicht gefunden.',
  );
}

/// Findet den lib/-Ordner des aktuellen Pakets (unsalted_core), unabhängig
/// davon, aus welchem Verzeichnis `flutter test` gestartet wurde.
Directory findPackageLibDir() {
  Directory dir = Directory.current;
  for (var i = 0; i < 4; i++) {
    final candidate = Directory('${dir.path}/lib');
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (candidate.existsSync() && pubspec.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'lib/-Ordner des Pakets wurde ausgehend von ${Directory.current.path} nicht gefunden.',
  );
}

Map<String, int> parseRanks(String yamlText) {
  final ranks = <String, int>{};
  final lineRegex = RegExp(
    r'^\s*([a-zA-Z0-9_]+):\s*\{\s*rank:\s*(\d+)\s*\}',
    multiLine: true,
  );
  for (final match in lineRegex.allMatches(yamlText)) {
    ranks[match.group(1)!] = int.parse(match.group(2)!);
  }
  return ranks;
}

List<String> parseForbiddenInCore(String yamlText) {
  final sectionIndex = yamlText.indexOf('forbidden_in_core:');
  if (sectionIndex == -1) return [];
  final section = yamlText.substring(sectionIndex);
  final itemRegex = RegExp('''^\\s*-\\s*["']([^"']+)["']''', multiLine: true);
  final result = <String>[];
  for (final line in section.split('\n')) {
    if (line.isNotEmpty &&
        !line.startsWith(' ') &&
        !line.startsWith('-') &&
        !line.startsWith('forbidden_in_core')) {
      break;
    }
    final m = itemRegex.firstMatch(line);
    if (m != null) result.add(m.group(1)!);
  }
  return result;
}

/// Alle .dart-Dateien unter [dir], rekursiv.
List<File> allDartFiles(Directory dir) {
  if (!dir.existsSync()) return [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

/// Relativer Pfad einer Datei bezogen auf lib/ (z. B. "src/nutrition/decimal_math.dart").
String relativeToLib(File file, Directory libDir) {
  var rel = file.path.substring(libDir.path.length);
  if (rel.startsWith('/') || rel.startsWith('\\')) rel = rel.substring(1);
  return rel.replaceAll('\\', '/');
}

/// Alle import-Zeilen einer Datei, mit Zeilennummer (1-basiert).
List<MapEntry<int, String>> importLines(File file) {
  final lines = file.readAsLinesSync();
  final result = <MapEntry<int, String>>[];
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trimLeft();
    if (trimmed.startsWith('import ')) {
      result.add(MapEntry(i + 1, lines[i]));
    }
  }
  return result;
}

final RegExp importPackageRegex =
    RegExp(r"""import\s+['"]package:([a-zA-Z0-9_]+)/[^'"]*['"]""");

final RegExp importDartRegex =
    RegExp(r"""import\s+['"]dart:([a-zA-Z0-9_]+)['"]""");

/// Verzeichnisnamen, die bei projektweiten Scans übersprungen werden
/// (Build-Artefakte, Plattform-Ordner, IDE-/VCS-Ordner — irrelevant und
/// teils sehr groß).
const Set<String> _skipDirNames = {
  '.git',
  '.dart_tool',
  '.idea',
  '.vscode',
  'build',
  'ios',
  'android',
  'web',
  'windows',
  'macos',
  'linux',
  'node_modules',
};

/// Projekt-Root = Verzeichnis, das architecture.yaml enthält.
Directory findProjectRoot() => findArchitectureYaml().parent;

/// Alle .dart-Dateien unterhalb von [root], mit Überspringen der oben
/// genannten irrelevanten Ordner. Für projektweite Architekturchecks
/// (z. B. AT-09), die über die Grenzen eines einzelnen Pakets hinausgehen.
List<File> allProjectDartFiles(Directory root) {
  final result = <File>[];

  void walk(Directory dir) {
    List<FileSystemEntity> entries;
    try {
      entries = dir.listSync();
    } catch (_) {
      return;
    }
    for (final entity in entries) {
      final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? '';
      if (entity is Directory) {
        if (_skipDirNames.contains(name)) continue;
        walk(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        result.add(entity);
      }
    }
  }

  walk(root);
  return result;
}