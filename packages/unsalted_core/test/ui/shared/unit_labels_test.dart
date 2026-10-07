// test/ui/shared/unit_labels_test.dart
//
// UI-59 (Teil 1.2, C27b; aus UI-53 auf `design/1.1`): Einheiten in der Anzeige
// auf Deutsch, Mengen mit Dezimalkomma und ohne Rundung.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'package:unsalted_core/src/nutrition/unit_catalog.dart';
import 'package:unsalted_core/src/ui/shared/unit_labels.dart';

Decimal d(String value) => Decimal.parse(value);

void main() {
  group('UI-59: deutsche Einheiten', () {
    test('g, kg, ml und l bleiben Symbole', () {
      expect(['g', 'kg', 'ml', 'l'].map(unitLabel), ['g', 'kg', 'ml', 'l']);
    });

    test('übrige Einheiten mit deutschem Namen aus dem Katalog', () {
      expect(unitLabel('piece'), 'Stück');
      expect(unitLabel('tsp'), 'Teelöffel');
      expect(unitLabel('tbsp'), 'Esslöffel');
      expect(unitLabel('cup'), 'Cup');
    });

    test('kein Katalog-Code erscheint als englischer Code', () {
      for (final unit in UnitCatalog.all) {
        final label = unitLabel(unit.code);
        expect(label == unit.code || label == unit.name, isTrue, reason: unit.code);
      }
      expect(['piece', 'pinch', 'tsp', 'tbsp'].map(unitLabel).toSet().intersection({'piece', 'pinch', 'tsp', 'tbsp'}),
          isEmpty);
    });

    test('Prise in der Mehrzahl nur bei Menge ungleich 1', () {
      expect(unitLabel('pinch'), 'Prise');
      expect(unitLabel('pinch', quantity: Decimal.one), 'Prise');
      expect(unitLabel('pinch', quantity: d('2')), 'Prisen');
    });

    test('unbekannter Code erscheint unverändert', () {
      expect(unitLabel('xyz'), 'xyz');
    });

    test('Menge mit Dezimalkomma, ohne Rundung', () {
      expect(formatQuantity(d('0.5')), '0,5');
      expect(formatQuantity(d('1.23456')), '1,23456');
      expect(formatQuantity(d('1000')), '1000');
      expect(formatAmount(d('0.5'), 'l'), '0,5 l');
      expect(formatAmount(d('2'), 'piece'), '2 Stück');
      expect(formatAmount(d('3'), 'pinch'), '3 Prisen');
    });
  });
}
