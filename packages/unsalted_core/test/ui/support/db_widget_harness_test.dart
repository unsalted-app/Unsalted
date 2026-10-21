// test/ui/support/db_widget_harness_test.dart
//
// UI-83 (Teil 1.4 S02): Der Helfer schließt die Datenbank, auch wenn Drift
// noch Arbeit in der Fake-Zone hat; das Zeitlimit je Widget-Test ist 2 min.
// (a) Ausstehender Abbestell-Timer von Drift in der Fake-Zone (Abfrage in der
//     Fake-Zone abonniert und ohne Pumpen abbestellt) — mit
//     `tester.runAsync(database.close)` hinge das (Teil 1.1d).
// (b) Offener Listener in der Fake-Zone.
// (c) `test/flutter_test_config.dart` setzt das Zeitlimit wirksam.
// Die ursprüngliche Ursache der Hänger ist nicht nachgestellt (S01).

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_core/src/data/core_database.dart';

import 'db_widget_harness.dart';

Future<CoreDatabase> _openDatabase(WidgetTester tester) async =>
    (await tester.runAsync(() async => CoreDatabase(NativeDatabase.memory())))!;

void main() {
  testWidgets('UI-83 (a): schließt bei ausstehendem Abbestell-Timer in der Fake-Zone', (tester) async {
    final database = await _openDatabase(tester);
    final subscription = database.select(database.recipes).watch().listen((_) {});
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    // Abbestellen ohne `await`: Drift plant den Abbestell-Timer dabei synchron
    // in der Fake-Zone; die Fortsetzung eines `await` hier hinge selbst an der
    // Fake-Zone.
    unawaited(subscription.cancel());

    await closeDatabasePumping(tester, database);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('UI-83 (b): schließt bei offenem Listener in der Fake-Zone', (tester) async {
    final database = await _openDatabase(tester);
    final subscription = database.select(database.recipes).watch().listen((_) {});
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    await closeTestDatabase(tester, database);
    unawaited(subscription.cancel());
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('UI-83 (c): Zeitlimit je Widget-Test 2 min', () {
    final binding = TestWidgetsFlutterBinding.ensureInitialized() as AutomatedTestWidgetsFlutterBinding;
    expect(binding.defaultTestTimeout.duration, const Duration(minutes: 2));
  });
}
