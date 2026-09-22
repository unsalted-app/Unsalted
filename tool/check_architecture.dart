// tool/check_architecture.dart
//
// Prüft die Regeln aus PROJECT.md (R1) und architecture.yaml:
//   - Kein Paket importiert ein Paket mit gleichem oder höherem Rang.
//   - unsalted_core importiert nichts aus forbidden_in_core,
//     außer in den erlaubten Ausnahmeordnern (lib/src/ui/, lib/src/data/).
//
// Aufruf:  dart run tool/check_architecture.dart
// Exit-Code 0 = keine Verstöße, 1 = mindestens ein Verstoß gefunden.
//
// Bewusst ohne externe YAML-Bibliothek geschrieben: architecture.yaml hat ein
// sehr einfaches, festes Format, das mit ein paar regulären Ausdrücken robust
// genug geparst werden kann. Das hält dieses Werkzeug abhängigkeitsfrei.

import 'dart:io';

void main() {
  final projectRoot = Directory.current;
  final archFile = File('${projectRoot.path}/architecture.yaml');

  if (!archFile.existsSync()) {
    stderr.writeln('FEHLER: architecture.yaml nicht gefunden in ${projectRoot.path}');
    exit(1);
  }

  final archText = archFile.readAsStringSync();
  final ranks = _parseRanks(archText);
  final forbiddenInCore = _parseForbiddenInCore(archText);

  if (ranks.isEmpty) {
    stderr.writeln('FEHLER: Keine Pakete in architecture.yaml gefunden.');
    exit(1);
  }

  final violations = <String>[];

  // Alle Paket-Ordner einsammeln: packages/<name> und apps/<name>
  final packageDirs = <String, Directory>{};
  for (final base in ['packages', 'apps']) {
    final baseDir = Directory('${projectRoot.path}/$base');
    if (!baseDir.existsSync()) continue;
    for (final entry in baseDir.listSync()) {
      if (entry is Directory) {
        final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
        packageDirs[name] = entry;
      }
    }
  }

  for (final entry in packageDirs.entries) {
    final packageName = entry.key;
    final packageDir = entry.value;
    final ownRank = ranks[packageName];

    if (ownRank == null) {
      violations.add(
        '⚠️  Paket "$packageName" existiert im Dateisystem, aber nicht in '
        'architecture.yaml. Bitte dort ergänzen.',
      );
      continue;
    }

    final libDir = Directory('${packageDir.path}/lib');
    if (!libDir.existsSync()) continue;

    for (final file in libDir.listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;

      final relativePath = file.path.substring(packageDir.path.length + 1);
      final lines = file.readAsLinesSync();

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final importMatch = _importPackageRegex.firstMatch(line);
        if (importMatch == null) continue;

        final importedPackage = importMatch.group(1)!;
        final fullImportPath = importMatch.group(0)!;

        // R1 — Rangprüfung, nur relevant für importierte Projektpakete.
        if (ranks.containsKey(importedPackage) &&
            importedPackage != packageName) {
          final importedRank = ranks[importedPackage]!;
          if (importedRank >= ownRank) {
            violations.add(
              '❌ RANGVERSTOSS: $packageName (Rang $ownRank) importiert '
              '$importedPackage (Rang $importedRank)\n'
              '   in $packageName/$relativePath:${i + 1}\n'
              '   → ${line.trim()}',
            );
          }
        }

        // forbidden_in_core — nur für unsalted_core, mit Ausnahmeordnern.
        if (packageName == 'unsalted_core') {
          final isUiException = relativePath.startsWith('src/ui/');
          final isDataException = relativePath.startsWith('src/data/');

          for (final forbidden in forbiddenInCore) {
            if (!fullImportPath.contains(forbidden)) continue;

            final isFlutterImport = forbidden.contains('flutter');
            final isDriftImport = forbidden.contains('drift');

            if (isFlutterImport && isUiException) continue;
            if (isDriftImport && isDataException) continue;

            violations.add(
              '❌ VERBOTENER IMPORT: unsalted_core/$relativePath:${i + 1} '
              'importiert "$forbidden" außerhalb des erlaubten Ordners\n'
              '   → ${line.trim()}',
            );
          }
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('✅ Architekturprüfung bestanden. Keine Verstöße gefunden.');
    exit(0);
  } else {
    stderr.writeln('Architekturprüfung fehlgeschlagen (${violations.length} '
        'Verstoß/Verstöße):\n');
    for (final v in violations) {
      stderr.writeln(v);
      stderr.writeln();
    }
    exit(1);
  }
}

/// Erfasst z. B. `import 'package:unsalted_core/unsalted_core.dart';`
/// Gruppe 1 = Paketname (unsalted_core).
final RegExp _importPackageRegex =
    RegExp(r"""import\s+['"]package:([a-zA-Z0-9_]+)/[^'"]*['"]""");

/// Parst den `packages:`-Block aus architecture.yaml.
/// Erwartetes Format je Zeile: `  <name>: { rank: <int> }`
Map<String, int> _parseRanks(String yamlText) {
  final ranks = <String, int>{};
  final lineRegex =
      RegExp(r'^\s*([a-zA-Z0-9_]+):\s*\{\s*rank:\s*(\d+)\s*\}', multiLine: true);
  for (final match in lineRegex.allMatches(yamlText)) {
    ranks[match.group(1)!] = int.parse(match.group(2)!);
  }
  return ranks;
}

/// Parst den `forbidden_in_core:`-Block aus architecture.yaml.
/// Erwartetes Format je Zeile: `  - "package:flutter/"`
List<String> _parseForbiddenInCore(String yamlText) {
  final sectionIndex = yamlText.indexOf('forbidden_in_core:');
  if (sectionIndex == -1) return [];

  final section = yamlText.substring(sectionIndex);
  final itemRegex = RegExp(r'''^\s*-\s*["']([^"']+)["']''', multiLine: true);

  final result = <String>[];
  for (final line in section.split('\n')) {
    // Block endet, sobald eine neue Top-Level-Zuordnung beginnt.
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