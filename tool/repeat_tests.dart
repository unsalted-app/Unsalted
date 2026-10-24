// tool/repeat_tests.dart
//
// Teil 1.4 S01: führt `flutter test` in einem Paket mehrmals hintereinander
// aus und hält je Lauf Dauer, Ergebnis, rote Tests und Zeitüberschreitungen
// fest — für die Diagnose seltener Hänger (docs/plan-1.4.md, Abschnitt b).
//
// Aufruf (vom Projektstamm):
//   dart run tool/repeat_tests.dart --package packages/unsalted_core \
//     [--runs 20] [--concurrency 1] [--timeout 60s] [--max-minutes 10] \
//     [--load 15] [--randomize] [--log-dir <ordner>] [-- <weitere Argumente>]
//
//   --runs N         Zahl der Läufe (Standard 1)
//   --concurrency N  an `flutter test --concurrency` (Standard: wie flutter)
//   --timeout D      an `flutter test --timeout` (z. B. 60s). Achtung: gilt
//                    nicht für `testWidgets` — das setzt sein Limit selbst
//                    (`binding.defaultTestTimeout`, 10 min); dafür das Limit
//                    über `flutter_test_config.dart` setzen
//   --max-minutes M  ein Lauf, der nach M Minuten nicht fertig ist, wird
//                    beendet — samt aller Kindprozesse (`flutter_tester`).
//                    Ein `perl alarm` beendete nur das Startskript (Teil 1.1d).
//   --load K         K Belastungsprozesse (Endlosschleife der Shell) für die
//                    Dauer jedes Laufs
//   --randomize      `--test-randomize-ordering-seed random`
//   --log-dir P      Protokolle je Lauf und `runs.csv` (Standard: Temp-Ordner)
//   -- …             alles danach geht unverändert an `flutter test`
//                    (z. B. eine einzelne Testdatei)
//
// Exit-Code 0 = alle Läufe grün, 1 = mindestens ein Lauf rot, beendet oder
// mit Zeitüberschreitung, 2 = Aufruf fehlerhaft.
//
// Bewusst nur dart:io (wie check_architecture.dart): kein pubspec im
// Projektstamm (Spezifikation 28.7.3).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final options = _Options.parse(arguments);
  if (options == null) {
    stderr.writeln('Aufruf: dart run tool/repeat_tests.dart --package <pfad> [Optionen] [-- <flutter-test-Argumente>]');
    exitCode = 2;
    return;
  }
  final logDir = options.logDir ?? (await Directory.systemTemp.createTemp('repeat_tests_')).path;
  await Directory(logDir).create(recursive: true);
  stdout.writeln('Paket: ${options.package} · Läufe: ${options.runs} · '
      'flutter ${options.flutterArguments.join(' ')}');
  stdout.writeln('Protokolle: $logDir');

  final results = <_RunResult>[];
  for (var run = 1; run <= options.runs; run++) {
    final result = await _runOnce(options, run, logDir);
    results.add(result);
    stdout.writeln(result.line);
  }

  final csv = StringBuffer('lauf,beginn,dauer_s,exit,ergebnis,gruen,rot,zeitueberschreitungen,beendet,'
      'restprozesse_vorher,rote_tests\n');
  for (final r in results) {
    csv.writeln([
      r.run,
      r.start.toIso8601String(),
      r.duration.inMilliseconds / 1000,
      r.exitCode,
      r.outcome,
      r.passed,
      r.failed,
      r.timeouts.length,
      r.killed,
      r.leftoverBefore,
      '"${r.failedTests.join(' | ').replaceAll('"', "'")}"',
    ].join(','));
  }
  await File('$logDir/runs.csv').writeAsString(csv.toString());

  final durations = [for (final r in results) r.duration.inMilliseconds / 1000]..sort();
  final bad = results.where((r) => r.outcome != 'grün').length;
  stdout.writeln('—' * 60);
  stdout.writeln('Läufe: ${results.length} · grün: ${results.length - bad} · nicht grün: $bad · '
      'Dauer min/median/max: ${durations.first.toStringAsFixed(0)} / '
      '${durations[durations.length ~/ 2].toStringAsFixed(0)} / ${durations.last.toStringAsFixed(0)} s');
  for (final r in results.where((r) => r.outcome != 'grün')) {
    stdout.writeln('  Lauf ${r.run}: ${r.outcome}${r.timeouts.isEmpty ? '' : ' · Zeitüberschreitung: ${r.timeouts.join(' | ')}'}'
        '${r.failedTests.isEmpty ? '' : ' · rot: ${r.failedTests.join(' | ')}'}');
  }
  exitCode = bad == 0 ? 0 : 1;
}

class _Options {
  _Options({
    required this.package,
    required this.runs,
    required this.maxMinutes,
    required this.load,
    required this.logDir,
    required this.flutterArguments,
  });

  final String package;
  final int runs;
  final int maxMinutes;
  final int load;
  final String? logDir;
  final List<String> flutterArguments;

  static _Options? parse(List<String> arguments) {
    String? package;
    var runs = 1;
    var maxMinutes = 10;
    var load = 0;
    String? logDir;
    final flutterArguments = <String>['test', '--reporter', 'expanded'];
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      String value() => ++i < arguments.length ? arguments[i] : throw const FormatException();
      try {
        switch (argument) {
          case '--package':
            package = value();
          case '--runs':
            runs = int.parse(value());
          case '--concurrency':
            flutterArguments.addAll(['--concurrency', value()]);
          case '--timeout':
            flutterArguments.addAll(['--timeout', value()]);
          case '--max-minutes':
            maxMinutes = int.parse(value());
          case '--load':
            load = int.parse(value());
          case '--randomize':
            flutterArguments.addAll(['--test-randomize-ordering-seed', 'random']);
          case '--log-dir':
            logDir = value();
          case '--':
            flutterArguments.addAll(arguments.sublist(i + 1));
            i = arguments.length;
          default:
            return null;
        }
      } on FormatException {
        return null;
      }
    }
    if (package == null || runs < 1 || maxMinutes < 1 || load < 0) return null;
    return _Options(
      package: package,
      runs: runs,
      maxMinutes: maxMinutes,
      load: load,
      logDir: logDir,
      flutterArguments: flutterArguments,
    );
  }
}

class _RunResult {
  _RunResult({
    required this.run,
    required this.start,
    required this.duration,
    required this.exitCode,
    required this.killed,
    required this.passed,
    required this.failed,
    required this.failedTests,
    required this.timeouts,
    required this.leftoverBefore,
  });

  final int run;
  final DateTime start;
  final Duration duration;
  final int exitCode;
  final bool killed;
  final int passed;
  final int failed;
  final List<String> failedTests;
  final List<String> timeouts;
  final int leftoverBefore;

  String get outcome {
    if (killed) return 'beendet (Zeitgrenze des Laufs)';
    if (timeouts.isNotEmpty) return 'Zeitüberschreitung';
    if (exitCode != 0) return 'rot';
    return 'grün';
  }

  String get line => 'Lauf $run: $outcome · ${(duration.inMilliseconds / 1000).toStringAsFixed(1)} s · '
      '+$passed -$failed${leftoverBefore > 0 ? ' · Restprozesse vorher: $leftoverBefore' : ''}';
}

/// Ein `flutter test`-Lauf mit Zeitgrenze, Last und Auswertung der Ausgabe
/// des Reporters `expanded` (eine Zeile je Ereignis, rote Tests mit `[E]`).
Future<_RunResult> _runOnce(_Options options, int run, String logDir) async {
  final leftoverBefore = (await _testerProcesses()).length;
  final loaders = [
    for (var i = 0; i < options.load; i++) await Process.start('/bin/sh', ['-c', 'while :; do :; done']),
  ];
  final log = File('$logDir/lauf_${run.toString().padLeft(2, '0')}.txt').openWrite();
  final start = DateTime.now();
  final process = await Process.start('flutter', options.flutterArguments, workingDirectory: options.package);
  var killed = false;
  final watchdog = Timer(Duration(minutes: options.maxMinutes), () async {
    killed = true;
    await _killTree(process.pid);
  });

  final lines = <String>[];
  Future<void> collect(Stream<List<int>> stream) => stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) {
        lines.add(line);
        log.writeln(line);
      });
  await Future.wait([collect(process.stdout), collect(process.stderr)]);
  final code = await process.exitCode;
  watchdog.cancel();
  final duration = DateTime.now().difference(start);
  for (final loader in loaders) {
    loader.kill(ProcessSignal.sigkill);
  }
  await log.close();
  // Waisen aus einem beendeten Lauf aufräumen, damit der nächste Lauf sauber startet.
  if (killed) {
    for (final pid in await _testerProcesses()) {
      Process.killPid(pid, ProcessSignal.sigkill);
    }
  }

  final progress = RegExp(r'^\d+:\d+ \+(\d+)(?: ~\d+)?(?: -(\d+))?: (.*)$');
  var passed = 0;
  var failed = 0;
  final failedTests = <String>[];
  final timeouts = <String>[];
  String? current;
  for (final line in lines) {
    final match = progress.firstMatch(line);
    if (match != null) {
      passed = int.parse(match.group(1)!);
      failed = int.tryParse(match.group(2) ?? '') ?? 0;
      final description = match.group(3)!;
      if (description.endsWith(' [E]')) {
        current = _shortName(description.substring(0, description.length - 4));
        if (!failedTests.contains(current)) failedTests.add(current);
      } else {
        current = null;
      }
    } else if (current != null &&
        (line.contains('TimeoutException') || line.contains('Test timed out')) &&
        !timeouts.contains(current)) {
      timeouts.add(current);
    }
  }
  return _RunResult(
    run: run,
    start: start,
    duration: duration,
    exitCode: code,
    killed: killed,
    passed: passed,
    failed: failed,
    failedTests: failedTests,
    timeouts: timeouts,
    leftoverBefore: leftoverBefore,
  );
}

/// `…/test/ui/foods/food_list_screen_test.dart: UI-44: …` → Pfad ab `test/`.
String _shortName(String description) {
  final index = description.indexOf('/test/');
  return index < 0 ? description : description.substring(index + 1);
}

/// Prozess-IDs aller laufenden `flutter_tester`.
Future<List<int>> _testerProcesses() async {
  final result = await Process.run('ps', ['-A', '-o', 'pid=', '-o', 'command=']);
  return [
    for (final line in (result.stdout as String).split('\n'))
      if (line.contains('flutter_tester') && !line.contains('grep')) int.parse(line.trim().split(RegExp(r'\s+')).first),
  ];
}

/// Beendet [root] und alle Nachkommen (erst TERM, nach 5 s KILL).
Future<void> _killTree(int root) async {
  final result = await Process.run('ps', ['-A', '-o', 'pid=', '-o', 'ppid=']);
  final children = <int, List<int>>{};
  for (final line in (result.stdout as String).split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) continue;
    children.putIfAbsent(int.parse(parts[1]), () => []).add(int.parse(parts[0]));
  }
  final tree = <int>[];
  void visit(int pid) {
    tree.add(pid);
    for (final child in children[pid] ?? const <int>[]) {
      visit(child);
    }
  }

  visit(root);
  for (final pid in tree.reversed) {
    Process.killPid(pid, ProcessSignal.sigterm);
  }
  await Future<void>.delayed(const Duration(seconds: 5));
  for (final pid in tree.reversed) {
    Process.killPid(pid, ProcessSignal.sigkill);
  }
}
