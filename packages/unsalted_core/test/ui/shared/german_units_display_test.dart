// test/ui/shared/german_units_display_test.dart
//
// UI-60 bis UI-63 (Teil 1.2, C27b): Die Bildschirme zeigen Einheiten deutsch
// und Mengen mit Dezimalkomma — Rezeptdetail (Zutaten), eingefrorene
// Editor-Ansicht, Vergleichsspalten und Zutatenzeile (Auswahlliste,
// Mengenfeld). Gespeichert bleibt der Code.

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unsalted_design/unsalted_design.dart';

import 'package:unsalted_core/src/recipe/recipe_ingredient.dart';
import 'package:unsalted_core/src/recipe/recipe_version.dart';
import 'package:unsalted_core/src/recipe/snapshot_codec.dart';
import 'package:unsalted_core/src/ui/recipe_detail/sections/recipe_detail_ingredients_section.dart';
import 'package:unsalted_core/src/ui/recipe_editor/ingredient_row.dart';
import 'package:unsalted_core/src/ui/recipe_editor/sections/recipe_editor_frozen_section.dart';
import 'package:unsalted_core/src/ui/versions/snapshot_column.dart';

final _ingredients = [
  RecipeIngredient(id: 'a', versionId: 'v', position: 1, displayName: 'Milch', quantity: Decimal.parse('0.5'), unitCode: 'l'),
  RecipeIngredient(
    id: 'b',
    versionId: 'v',
    position: 2,
    displayName: 'Ei',
    quantity: Decimal.fromInt(2),
    unitCode: 'piece',
    note: 'Größe M',
  ),
  RecipeIngredient(id: 'c', versionId: 'v', position: 3, displayName: 'Salz', quantity: Decimal.fromInt(3), unitCode: 'pinch'),
];

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)))));

void main() {
  testWidgets('UI-60: Rezeptdetail zeigt Zutaten mit deutschen Einheiten', (tester) async {
    await _pump(tester, RecipeDetailIngredientsSection(ingredients: _ingredients));
    expect(find.text('0,5 l'), findsOneWidget);
    expect(find.text('2 Stück · Größe M'), findsOneWidget);
    expect(find.text('3 Prisen'), findsOneWidget);
    expect(find.textContaining('piece'), findsNothing);
    expect(find.textContaining('pinch'), findsNothing);
  });

  testWidgets('UI-61: eingefrorene Editor-Ansicht zeigt deutsche Einheiten', (tester) async {
    final version = RecipeVersion(
      id: 'v',
      recipeId: 'r',
      versionIndex: 1,
      state: VersionState.snapshot,
      bakingLossPercent: Decimal.zero,
      ingredients: _ingredients,
    );
    await _pump(tester, RecipeEditorFrozenSection(version: version, onCopy: () {}));
    expect(find.text('0,5 l'), findsOneWidget);
    expect(find.text('2 Stück'), findsOneWidget);
    expect(find.text('3 Prisen'), findsOneWidget);
  });

  testWidgets('UI-62: Vergleichsspalte zeigt deutsche Einheiten', (tester) async {
    final json = jsonDecode(File('test/contract/golden/gd01_minimal.json').readAsStringSync()) as Map<String, dynamic>;
    final template = (json['ingredients'] as List).first as Map<String, dynamic>;
    json['ingredients'] = [
      {...template, 'position': 1, 'name': 'Milch', 'quantity': '0.5', 'unit': 'l'},
      {...template, 'position': 2, 'name': 'Ei', 'quantity': '2', 'unit': 'piece'},
    ];
    await _pump(tester, SnapshotColumn(title: 'A', snapshot: SnapshotCodec.decode(json)));
    expect(find.text('Milch: 0,5 l'), findsOneWidget);
    expect(find.text('Ei: 2 Stück'), findsOneWidget);
  });

  testWidgets('UI-63: Zutatenzeile — Auswahlliste deutsch, Menge mit Komma, gespeichert bleibt der Code',
      (tester) async {
    IngredientRowData? latest;
    await _pump(
      tester,
      IngredientRow(
        data: IngredientRowData(id: 'i', displayName: 'Milch', quantity: Decimal.parse('0.5'), unitCode: 'g'),
        onChanged: (data) => latest = data,
        onRemove: () {},
      ),
    );
    expect(find.widgetWithText(AppTextField, '0,5'), findsOneWidget);

    await tester.tap(find.byType(AppSelect<String>));
    await tester.pumpAndSettle();
    expect(find.text('Stück'), findsWidgets);
    expect(find.text('piece'), findsNothing);
    await tester.tap(find.text('Stück').last);
    await tester.pumpAndSettle();
    expect(latest!.unitCode, 'piece');

    await tester.enterText(find.widgetWithText(AppTextField, '0,5'), '1,25');
    expect(latest!.quantity, Decimal.parse('1.25'));
  });
}
