// test/ui/foods/package_form_test.dart
//
// Schritt 8.1: PackageForm als eigenständiges Formular-Widget -- EU-
// Reihenfolge, Natrium/Salz-Alternative (Kapitel 8.2), Validator-Warn-
// und Fehlerpfade (UI-09, Arbeitskarte §10).

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unsalted_core/src/nutrition/nutrient_set.dart';
import 'package:unsalted_core/src/ui/foods/package_form.dart';

Future<GlobalKey<PackageFormState>> _pump(
  WidgetTester tester, {
  PackageFormValue? initial,
}) async {
  // Das Formular hat mehr Felder, als in die Standard-Testfläche (800x600)
  // passen; ohne Vergrößerung würde ListView untere Felder gar nicht erst
  // aufbauen (SliverList realisiert nur, was Viewport + Cache-Extent
  // abdecken). Eine große, feste Fläche macht Scroll-Gymnastik in jedem
  // einzelnen Test unnötig.
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<PackageFormState>();
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: PackageForm(key: key, initial: initial)),
  ));
  return key;
}

void main() {
  testWidgets('leeres Formular: value ist null (Name fehlt)', (tester) async {
    final key = await _pump(tester);
    expect(key.currentState!.value, isNull);
  });

  testWidgets('Name ausgefüllt -> value liefert die eingegebenen Daten', (tester) async {
    final key = await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Mehl');
    await tester.pump();

    final value = key.currentState!.value;
    expect(value, isNotNull);
    expect(value!.name, 'Mehl');
    expect(value.nutrients.isEmpty, isTrue);
  });

  testWidgets('Felder erscheinen in EU-Reihenfolge (Bildschirm 5)', (tester) async {
    await _pump(tester);

    final labels = [
      'Kalorien (kcal)',
      'Fett (g)',
      'davon gesättigte Fettsäuren (g)',
      'Kohlenhydrate (g)',
      'davon Zucker (g)',
      'Ballaststoffe (g)',
      'Eiweiß (g)',
      'Salz (g)',
    ];

    final positions = labels.map((l) => tester.getTopLeft(find.text(l)).dy).toList();
    for (var i = 1; i < positions.length; i++) {
      expect(positions[i], greaterThan(positions[i - 1]),
          reason: '"${labels[i]}" sollte unter "${labels[i - 1]}" stehen');
    }
  });

  testWidgets('UI-09: Validator-Warnung wird inline angezeigt, Speichern bleibt möglich',
      (tester) async {
    final key = await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Testprodukt');
    // gesättigte Fettsäuren > Fett -> Warnung (VA-02), kein Fehler.
    await tester.enterText(find.widgetWithText(TextField, 'Fett (g)'), '5');
    await tester.enterText(
      find.widgetWithText(TextField, 'davon gesättigte Fettsäuren (g)'),
      '10',
    );
    await tester.pump();

    expect(find.byKey(const Key('package_form_warning')), findsOneWidget);
    expect(find.byKey(const Key('package_form_error')), findsNothing);
    expect(key.currentState!.value, isNotNull, reason: 'Warnung blockiert Speichern nicht');
  });

  testWidgets('Formularfehlerpfad: negativer Wert blockiert Speichern (rot)', (tester) async {
    final key = await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Testprodukt');
    await tester.enterText(find.widgetWithText(TextField, 'Fett (g)'), '-1');
    await tester.pump();

    expect(find.byKey(const Key('package_form_error')), findsOneWidget);
    expect(key.currentState!.value, isNull, reason: 'Fehler blockiert Speichern');
  });

  testWidgets('Natrium-Eingabe ersetzt Salz (Kapitel 8.2)', (tester) async {
    final key = await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Testprodukt');
    await tester.enterText(find.widgetWithText(TextField, 'Salz (g)'), '1');
    await tester.enterText(find.widgetWithText(TextField, 'oder: Natrium (mg)'), '400');
    await tester.pump();

    // salt_g = 400 / 1000 * 2.5 = 1.0 -- überschreibt die manuelle 1-g-Eingabe
    // nur formal identisch hier, daher zusätzlich mit einem abweichenden Wert
    // geprüft:
    final value = key.currentState!.value;
    expect(value!.nutrients.saltG, Decimal.parse('1'));

    final saltField = tester.widget<TextField>(find.widgetWithText(TextField, 'Salz (g)'));
    expect(saltField.enabled, isFalse);
  });

  testWidgets('Natrium-Wert weicht vom manuellen Salz-Wert ab -> Natrium gewinnt',
      (tester) async {
    final key = await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Testprodukt');
    await tester.enterText(find.widgetWithText(TextField, 'Salz (g)'), '5');
    await tester.enterText(find.widgetWithText(TextField, 'oder: Natrium (mg)'), '800');
    await tester.pump();

    // salt_g = 800 / 1000 * 2.5 = 2.0, nicht 5.
    final value = key.currentState!.value;
    expect(value!.nutrients.saltG, Decimal.parse('2.0'));
  });

  testWidgets('initial füllt alle Felder vor (Bearbeiten-Modus)', (tester) async {
    final initial = (
      name: 'Zucker',
      brand: 'Beispielmarke',
      barcode: '123',
      densityGPerMl: null,
      gramsPerPiece: null,
      servingSizeG: null,
      nutrients: NutrientSet(energyKcal: Decimal.fromInt(400)),
    );

    await _pump(tester, initial: initial);

    expect(find.text('Zucker'), findsOneWidget);
    expect(find.text('Beispielmarke'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);
  });
}
