// lib/src/nutrition/unit_catalog.dart
//
// Einheiten sind eine Code-Konstante, keine Tabelle (G4/G5, Kapitel 6).
// Der Rechenkern darf keine Datenbank kennen; eine neue Einheit ist ein
// Code-Release, kein Datenproblem.
//
// GEÄNDERT (G4, G5) ggü. Ursprungsbericht: Die Faktoren für tsp/tbsp/cup/pinch
// waren dort nicht festgelegt. Ab dem Freeze sind diese Werte unveränderlich,
// weil sie in historische Snapshots eingerechnet werden (Kapitel 21.1).

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import '../contracts/core_exceptions.dart';
import 'decimal_math.dart';

enum UnitKind { mass, volume, count }

class Unit {
  final String code;
  final String name;
  final UnitKind kind;

  /// Umrechnungsfaktor in die Basiseinheit (g für mass, ml für volume).
  /// Für [UnitKind.count] gibt es keinen Faktor — das Stückgewicht kommt
  /// pro Zutat aus der food_variant (grams_per_piece), nicht aus der Einheit.
  final Decimal? factor;

  const Unit({
    required this.code,
    required this.name,
    required this.kind,
    this.factor,
  });
}

/// Die neun Einheiten aus Kapitel 6, wörtlich mit den dort festgelegten
/// Faktoren. Diese Liste ist ab dem Freeze unveränderlich (Kapitel 21.1).
abstract final class UnitCatalog {
  static final List<Unit> all = [
    Unit(code: 'g', name: 'Gramm', kind: UnitKind.mass, factor: Decimal.one),
    Unit(code: 'kg', name: 'Kilogramm', kind: UnitKind.mass, factor: Decimal.fromInt(1000)),
    Unit(code: 'pinch', name: 'Prise', kind: UnitKind.mass, factor: Decimal.parse('0.3')),
    Unit(code: 'ml', name: 'Milliliter', kind: UnitKind.volume, factor: Decimal.one),
    Unit(code: 'l', name: 'Liter', kind: UnitKind.volume, factor: Decimal.fromInt(1000)),
    Unit(code: 'tsp', name: 'Teelöffel', kind: UnitKind.volume, factor: Decimal.fromInt(5)),
    Unit(code: 'tbsp', name: 'Esslöffel', kind: UnitKind.volume, factor: Decimal.fromInt(15)),
    Unit(code: 'cup', name: 'Cup', kind: UnitKind.volume, factor: Decimal.fromInt(240)),
    Unit(code: 'piece', name: 'Stück', kind: UnitKind.count),
  ];

  /// Wirft [ArgumentError], wenn [code] keiner bekannten Einheit entspricht.
  static Unit byCode(String code) {
    for (final unit in all) {
      if (unit.code == code) return unit;
    }
    throw ArgumentError('Unbekannter Einheiten-Code: "$code"');
  }

  /// Rechnet [quantity] in Gramm um. Gibt `null` zurück, wenn die dafür
  /// nötige Zusatzangabe fehlt (Dichte bei volume, Stückgewicht bei count) —
  /// das ist dann "nicht berechenbar", nicht geschätzt und nicht
  /// stillschweigend mit 1,0 gerechnet (Kapitel 6).
  ///
  /// Wirft [ArgumentError] bei unbekanntem [unitCode].
  /// Wirft [ValidationException] bei negativer [quantity].
  static Rational? toGrams(
    Decimal quantity,
    String unitCode, {
    Decimal? densityGPerMl,
    Decimal? gramsPerPiece,
  }) {
    if (quantity < Decimal.zero) {
      throw ValidationException('Menge darf nicht negativ sein: $quantity');
    }

    final unit = byCode(unitCode); // wirft ArgumentError bei unbekanntem Code

    switch (unit.kind) {
      case UnitKind.mass:
        return quantity.r * unit.factor!.r;

      case UnitKind.volume:
        if (densityGPerMl == null) return null;
        return quantity.r * unit.factor!.r * densityGPerMl.r;

      case UnitKind.count:
        if (gramsPerPiece == null) return null;
        return quantity.r * gramsPerPiece.r;
    }
  }
}