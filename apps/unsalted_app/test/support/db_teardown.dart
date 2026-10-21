// test/support/db_teardown.dart
//
// Teil 1.4 S02 (F13): schließt die Datenbank eines App-Widget-Tests robust —
// gleiche Logik wie `packages/unsalted_core/test/ui/support/db_widget_harness.dart`,
// nur über die öffentliche Tür von unsalted_core (AT-09). Hintergrund dort.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/unsalted_core.dart';

/// Höchstzahl der Runden aus Pumpen (50 ms Fake-Zeit) und echtem Warten
/// (20 ms).
const int _maxRounds = 200;

/// Baut den Widget-Baum ab, pumpt aus und schließt [database]: `close()`
/// startet in der Fake-Zone, danach abwechselnd pumpen und echt warten, bis
/// geschlossen ist; nach [_maxRounds] Runden schlägt der Test fehl.
Future<void> closeTestDatabase(WidgetTester tester, CoreDatabase database) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
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
