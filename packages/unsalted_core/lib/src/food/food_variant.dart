// lib/src/food/food_variant.dart
//
// Fachmodell für ein Lebensmittel/eine Verpackungsvariante (Kapitel 10.6 der
// neuen Spezifikation). Trägt `id`. KEIN `ownerId` — reines Sync-Feld, aus
// demselben Grund wie Recipe.ownerId (siehe docs/decisions.md).
//
// DESIGN-ENTSCHEIDUNG (unverändert): Die 8 Nährwertfelder + extra werden
// als eingebettetes NutrientSet abgebildet (Kapitel 10.6: "nutrients ...
// als eingebettetes NutrientSet"), nicht als 9 einzelne Felder dupliziert.

import 'package:decimal/decimal.dart';

import '../nutrition/nutrient_set.dart';

const Object _unset = Object();

enum FoodSource {
  custom,
  imported,
  usda;

  /// Der DB-/JSON-Code ist "import", nicht "imported" — "import" ist zwar
  /// ein gültiger Dart-Bezeichner (built-in identifier), wird hier aber aus
  /// Lesbarkeitsgründen vermieden und stattdessen über diese Zuordnung
  /// abgebildet (Kapitel 11.6: "source TEXT nein custom | import | usda").
  String get code => switch (this) {
        FoodSource.custom => 'custom',
        FoodSource.imported => 'import',
        FoodSource.usda => 'usda',
      };

  static FoodSource fromCode(String code) => switch (code) {
        'custom' => FoodSource.custom,
        'import' => FoodSource.imported,
        'usda' => FoodSource.usda,
        _ => throw ArgumentError('Unbekannter source-Code: "$code"'),
      };
}

class FoodVariant {
  final String id;
  final String name;
  final String? brand;

  /// EAN, für Duplikaterkennung (Kapitel 11.6, Kapitel 13.6).
  final String? barcode;

  final FoodSource source;

  /// Fremd-ID der Quelle (Kapitel 11.6).
  final String? sourceRef;

  /// Für Volumeneinheiten (Kapitel 9).
  final Decimal? densityGPerMl;

  /// Für die Einheit `piece` (Kapitel 9).
  final Decimal? gramsPerPiece;

  /// "Portion laut Packung" (Kapitel 11.6).
  final Decimal? servingSizeG;

  /// Die 8 Nährwertfelder + extra, alle pro 100 g (Kapitel 8, 11.6).
  final NutrientSet nutrients;

  const FoodVariant({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.source,
    this.sourceRef,
    this.densityGPerMl,
    this.gramsPerPiece,
    this.servingSizeG,
    this.nutrients = const NutrientSet(),
  });

  FoodVariant copyWith({
    String? id,
    String? name,
    Object? brand = _unset,
    Object? barcode = _unset,
    FoodSource? source,
    Object? sourceRef = _unset,
    Object? densityGPerMl = _unset,
    Object? gramsPerPiece = _unset,
    Object? servingSizeG = _unset,
    NutrientSet? nutrients,
  }) {
    return FoodVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: identical(brand, _unset) ? this.brand : brand as String?,
      barcode: identical(barcode, _unset) ? this.barcode : barcode as String?,
      source: source ?? this.source,
      sourceRef: identical(sourceRef, _unset) ? this.sourceRef : sourceRef as String?,
      densityGPerMl:
          identical(densityGPerMl, _unset) ? this.densityGPerMl : densityGPerMl as Decimal?,
      gramsPerPiece:
          identical(gramsPerPiece, _unset) ? this.gramsPerPiece : gramsPerPiece as Decimal?,
      servingSizeG:
          identical(servingSizeG, _unset) ? this.servingSizeG : servingSizeG as Decimal?,
      nutrients: nutrients ?? this.nutrients,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodVariant &&
        id == other.id &&
        name == other.name &&
        brand == other.brand &&
        barcode == other.barcode &&
        source == other.source &&
        sourceRef == other.sourceRef &&
        densityGPerMl == other.densityGPerMl &&
        gramsPerPiece == other.gramsPerPiece &&
        servingSizeG == other.servingSizeG &&
        nutrients == other.nutrients;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        brand,
        barcode,
        source,
        sourceRef,
        densityGPerMl,
        gramsPerPiece,
        servingSizeG,
        nutrients,
      );

  @override
  String toString() => 'FoodVariant(id: $id, name: $name, brand: $brand)';
}