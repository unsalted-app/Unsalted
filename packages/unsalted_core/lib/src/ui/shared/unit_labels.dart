// lib/src/ui/shared/unit_labels.dart
//
// Teil 1.2 (C27b, übernommen aus dem Design-Pass `design/1.1`): Einheiten in
// der Anzeige auf Deutsch. Symbole für g, kg, ml und l, sonst der deutsche
// Name aus dem UnitCatalog (Kapitel 9), z. B. „Stück“ statt `piece`. Mengen
// erscheinen mit Dezimalkomma; gerundet wird hier nichts (Rundung nur im
// NutritionFormatter). Gespeichert und exportiert werden weiter die Codes.

import 'package:decimal/decimal.dart';

import '../../nutrition/unit_catalog.dart';

const _symbolUnits = {'g', 'kg', 'ml', 'l'};

/// Mehrzahl, wo der Katalogname sie nicht schon abdeckt.
const _plurals = {'pinch': 'Prisen'};

/// Anzeigename der Einheit [code]; mit [quantity] ungleich 1 in der Mehrzahl.
/// Unbekannte Codes erscheinen unverändert.
String unitLabel(String code, {Decimal? quantity}) {
  if (_symbolUnits.contains(code)) return code;
  if (quantity != null && quantity != Decimal.one && _plurals.containsKey(code)) return _plurals[code]!;
  try {
    return UnitCatalog.byCode(code).name;
  } on ArgumentError {
    return code;
  }
}

/// [value] mit Dezimalkomma, ohne Rundung.
String formatQuantity(Decimal value) => value.toString().replaceAll('.', ',');

/// Menge mit Einheit, z. B. „0,5 l“ oder „2 Stück“.
String formatAmount(Decimal quantity, String unitCode) =>
    '${formatQuantity(quantity)} ${unitLabel(unitCode, quantity: quantity)}';
