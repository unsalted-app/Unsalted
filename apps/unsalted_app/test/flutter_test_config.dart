// test/flutter_test_config.dart
//
// Teil 1.4 S02 (F12): Zeitlimit 2 min je Widget-Test. `testWidgets` setzt sein
// Limit selbst (`timeout ?? binding.defaultTestTimeout`, Standard 10 min);
// `flutter test --timeout` und `dart_test.yaml` greifen dort nicht (S01). Ein
// hängender Test wird so nach 2 min mit Namen rot statt nach 10 min.
//
// Nur das Zeitlimit — hier keine Schriften laden oder anderes globales
// Verhalten setzen (Golden-Tests laden ihre Schriften selbst, Teil 1.3 D01).

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is AutomatedTestWidgetsFlutterBinding) {
    binding.defaultTestTimeout = const Timeout(Duration(minutes: 2));
  }
  await testMain();
}
