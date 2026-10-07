// test/ui/settings/import_screen_test.dart
//
// Schritt 8.7, Bildschirm 12: UI-10 (Import zeigt den Fehlertext bei
// ungültigem JSON), Vorschau vor dem Schreiben, erfolgreicher Import.

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_design/unsalted_design.dart';
import 'package:unsalted_core/src/data/core_database.dart' as db;
import 'package:unsalted_core/src/data/daos/drift_recipe_dao.dart';
import 'package:unsalted_core/src/providers/core_providers.dart';
import 'package:unsalted_core/src/ui/recipe_detail/recipe_detail_screen.dart';
import 'package:unsalted_core/src/ui/settings/import_screen.dart';

Future<db.CoreDatabase> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(() async => db.CoreDatabase(NativeDatabase.memory()));
  return database!;
}

Future<void> _settle(WidgetTester tester, {int millis = 150, int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: millis)));
    await tester.pump();
  }
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// Schließt [database] im Teardown, auch wenn der Test vorher scheitert
/// (Teil 1.1d). Nach einem roten Test lässt flutter_test den Widget-Baum stehen,
/// und Drift wartet beim Schließen auf seine Abbestell-Timer in der Fake-Zone,
/// die dann niemand mehr auspumpt -- der Lauf hinge. Deshalb erst den Baum
/// abbauen und auspumpen, dann schließen.
Future<void> _closeDatabase(WidgetTester tester, db.CoreDatabase database) async {
  await _disposeWidgetTree(tester);
  await tester.runAsync(database.close);
}

Map<String, dynamic> _emptyNutrients() => {
      'energy_kcal': null,
      'fat_g': null,
      'saturated_fat_g': null,
      'carbs_g': null,
      'sugars_g': null,
      'fiber_g': null,
      'protein_g': null,
      'salt_g': null,
      'extra': <String, dynamic>{},
    };

String _validSnapshotJson({String title = 'Importiertes Rezept'}) {
  final map = {
    'format': 'unsalted_recipe_snapshot',
    'format_version': 1,
    'recipe': {'id': 'ext-r1', 'title': title, 'description': null},
    'version': {
      'id': 'ext-v1',
      'parent_version_id': null,
      'version_index': 1,
      'label': null,
      'servings': null,
      'baking_loss_percent': '0',
      'final_weight_override_g': null,
      'notes': null,
      'created_at': '2026-01-01T00:00:00.000Z',
      'snapshotted_at': '2026-01-01T00:00:00.000Z',
    },
    'ingredients': [
      {
        'position': 1,
        'name': 'Mehl',
        'brand': null,
        'barcode': null,
        'quantity': '200',
        'unit': 'g',
        'grams': '200',
        'note': null,
        'density_g_per_ml': null,
        'grams_per_piece': null,
        'per100g': {
          'energy_kcal': '300',
          'fat_g': null,
          'saturated_fat_g': null,
          'carbs_g': null,
          'sugars_g': null,
          'fiber_g': null,
          'protein_g': null,
          'salt_g': null,
          'extra': <String, dynamic>{},
        },
      },
    ],
    'steps': <Map<String, dynamic>>[],
    'nutrition': {
      'raw_weight_g': '200',
      'final_weight_g': '200',
      'total': _emptyNutrients(),
      'per100g': _emptyNutrients(),
      'incomplete': <String>[],
      'not_calculable': <String>[],
    },
  };
  return jsonEncode(map);
}

Future<void> _pumpImportScreen(WidgetTester tester, db.CoreDatabase database) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [coreDatabaseProvider.overrideWithValue(database)],
    child: const MaterialApp(home: ImportScreen()),
  ));
  await tester.pump();
}

void main() {
  testWidgets('UI-10: ungültiges JSON zeigt einen Fehlertext statt zu importieren',
      (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpImportScreen(tester, database);

    await tester.enterText(find.byType(AppTextField), '{ das ist kein gültiges JSON');
    await tester.pump();

    expect(find.text('Ungültiges JSON.'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Importieren'));
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('falsches Format zeigt die ImportFormatException-Nachricht', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpImportScreen(tester, database);

    await tester.enterText(
      find.byType(AppTextField),
      jsonEncode({'format': 'etwas_anderes', 'format_version': 1}),
    );
    await tester.pump();

    expect(find.textContaining('unsalted-Rezeptdatei'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('gültiges JSON zeigt die Vorschau vor dem Schreiben', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpImportScreen(tester, database);

    await tester.enterText(find.byType(AppTextField), _validSnapshotJson(title: 'Testbrot'));
    await tester.pump();

    expect(find.text('Vorschau: Testbrot'), findsOneWidget);
    expect(find.textContaining('1 Zutaten'), findsOneWidget);

    final recipeDao = DriftRecipeDao(database);
    final recipesBefore = await tester.runAsync(() => recipeDao.watchRecipes().first);
    expect(recipesBefore, isEmpty, reason: 'Vorschau darf noch nichts schreiben');

    await _disposeWidgetTree(tester);
  });

  testWidgets('Importieren schreibt das Rezept und öffnet das Rezeptdetail', (tester) async {
    final database = await _openDatabase(tester);
    addTearDown(() => _closeDatabase(tester, database));

    await _pumpImportScreen(tester, database);

    await tester.enterText(find.byType(AppTextField), _validSnapshotJson(title: 'Testbrot'));
    await tester.pump();

    await tester.tap(find.widgetWithText(AppButton, 'Importieren'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailScreen), findsOneWidget);

    final recipeDao = DriftRecipeDao(database);
    final recipes = await tester.runAsync(() => recipeDao.watchRecipes().first);
    expect(recipes!.single.title, 'Testbrot');

    await _disposeWidgetTree(tester);
  });
}
