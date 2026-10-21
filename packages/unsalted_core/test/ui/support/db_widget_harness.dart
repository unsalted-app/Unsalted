// test/ui/support/db_widget_harness.dart
//
// Teil 1.4 S02: schließt die Datenbank eines Widget-Tests robust.
//
// Hintergrund (Teil 1.1d, Teil 1.4 S01, docs/decisions.md): Drift wartet in
// `close()` auf seine Abbestell-Timer und auf das Schließen der Listener. Wer
// diese Arbeit in der Fake-Zone des Widget-Tests geplant hat, kommt erst
// weiter, wenn die Fake-Zone gepumpt wird — während `tester.runAsync(close)`
// tut das niemand, und der Test stand bis zum Zeitlimit. Lokal trat das selten
// und nicht nachstellbar auf (S01: 2 von 120 Läufen).
//
// Deshalb: Widget-Baum abbauen wie bisher, `close()` in der Fake-Zone starten
// und abwechselnd die Fake-Zone pumpen (Microtasks und Timer, auch
// zeitversetzte) und in der echten Zone warten, bis geschlossen ist. Schließt
// die Datenbank in der Grenze nicht, schlägt der Test mit klarer Meldung fehl,
// statt zu hängen.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/data/core_database.dart';

/// Höchstzahl der Runden aus Pumpen (50 ms Fake-Zeit) und echtem Warten
/// (20 ms) — rund 10 s Fake-Zeit, rund 4 s echte Zeit.
const int _maxRounds = 200;

/// Baut den Widget-Baum ab, pumpt aus und schließt [database]
/// (Teardown jedes Widget-Tests mit Datenbank).
Future<void> closeTestDatabase(WidgetTester tester, CoreDatabase database) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
  await closeDatabasePumping(tester, database);
}

/// Schließt [database]: `close()` startet in der Fake-Zone, danach abwechselnd
/// pumpen und echt warten, bis geschlossen ist; nach [_maxRounds] Runden
/// schlägt der Test fehl.
Future<void> closeDatabasePumping(WidgetTester tester, CoreDatabase database) async {
  var done = false;
  Object? error;
  StackTrace? stackTrace;
  unawaited(database.close().then(
    (_) => done = true,
    onError: (Object e, StackTrace s) {
      error = e;
      stackTrace = s;
      done = true;
    },
  ));
  for (var round = 0; round < _maxRounds && !done; round++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (done) break;
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  }
  if (error != null) Error.throwWithStackTrace(error!, stackTrace!);
  if (!done) {
    fail('CoreDatabase schließt nicht: nach $_maxRounds Runden aus Pumpen und echtem Warten '
        'steht `close()` noch aus (Teil 1.4 S02).');
  }
}
