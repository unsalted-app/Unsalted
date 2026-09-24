// lib/src/nutrition/nutrient_set.dart
//
// Wertebehälter für die 8 festen Nährwertfelder (Kapitel 5.1) plus beliebige
// Zusatzwerte in `extra` (Kapitel 5.1). null = unbekannt, niemals mit 0
// verwechselt (Kapitel 5.1: "Decimal.zero = tatsächlich null" — d.h. null und
// 0 sind fachlich unterschiedliche Aussagen und bleiben es durch jede
// Operation hindurch).
//
// Keine Kilojoule — nur energy_kcal (R7).

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'decimal_math.dart';

/// Sentinel für copyWith, um "Parameter nicht übergeben" von
/// "Parameter bewusst auf null gesetzt" unterscheiden zu können.
const Object _unset = Object();

class NutrientSet {
  final Decimal? energyKcal;
  final Decimal? fatG;
  final Decimal? saturatedFatG;
  final Decimal? carbsG;
  final Decimal? sugarsG;
  final Decimal? fiberG;
  final Decimal? proteinG;
  final Decimal? saltG;

  /// Zusätzliche Werte, Schlüssel im Format `<name>_<einheit>`,
  /// z. B. `sodium_mg`, `vitamin_c_mg` (Kapitel 5.1).
  final Map<String, Decimal> extra;

  const NutrientSet({
    this.energyKcal,
    this.fatG,
    this.saturatedFatG,
    this.carbsG,
    this.sugarsG,
    this.fiberG,
    this.proteinG,
    this.saltG,
    this.extra = const {},
  });

  /// Schlüssel der 8 festen Felder, in der Reihenfolge aus Kapitel 5.1.
  static const List<String> keys = [
    'energy_kcal',
    'fat_g',
    'saturated_fat_g',
    'carbs_g',
    'sugars_g',
    'fiber_g',
    'protein_g',
    'salt_g',
  ];

  /// true, wenn alle 8 Felder null sind UND extra leer ist
  /// (VA-06: "Lebensmittel ohne Nährwerte").
  bool get isEmpty =>
      energyKcal == null &&
      fatG == null &&
      saturatedFatG == null &&
      carbsG == null &&
      sugarsG == null &&
      fiberG == null &&
      proteinG == null &&
      saltG == null &&
      extra.isEmpty;

  /// Skaliert jedes bekannte Feld mit [factor]. null bleibt null
  /// (Kapitel 5.2: "Skalierung: null bleibt null").
  NutrientSet scale(Rational factor) {
    Decimal? scaleOne(Decimal? value) =>
        value == null ? null : (value.r * factor).toFixedDecimal();

    final scaledExtra = <String, Decimal>{
      for (final entry in extra.entries) entry.key: (entry.value.r * factor).toFixedDecimal(),
    };

    return NutrientSet(
      energyKcal: scaleOne(energyKcal),
      fatG: scaleOne(fatG),
      saturatedFatG: scaleOne(saturatedFatG),
      carbsG: scaleOne(carbsG),
      sugarsG: scaleOne(sugarsG),
      fiberG: scaleOne(fiberG),
      proteinG: scaleOne(proteinG),
      saltG: scaleOne(saltG),
      extra: scaledExtra,
    );
  }

  /// Addiert `this` und [other] nach der Regel aus Kapitel 5.2:
  ///   bekannt + bekannt  = Summe
  ///   bekannt + unbekannt = bekannt, aber Feld wird als "incomplete" gemeldet
  ///   unbekannt + unbekannt = unbekannt (und "incomplete")
  ///
  /// Gibt sowohl das Ergebnis als auch die Menge der dabei unvollständig
  /// gewordenen Feld-/extra-Schlüssel zurück — die Engine sammelt daraus
  /// NutritionResult.incomplete (Kapitel 13.1).
  ({NutrientSet set, Set<String> incomplete}) plus(NutrientSet other) {
    final incomplete = <String>{};

    Decimal? addOne(Decimal? a, Decimal? b, String key) {
      if (a != null && b != null) return a + b;
      if (a == null && b == null) {
        incomplete.add(key);
        return null;
      }
      incomplete.add(key);
      return a ?? b;
    }

    final mergedExtra = <String, Decimal>{};
    final allExtraKeys = {...extra.keys, ...other.extra.keys};
    for (final key in allExtraKeys) {
      final a = extra[key];
      final b = other.extra[key];
      if (a != null && b != null) {
        mergedExtra[key] = a + b;
      } else {
        // Mindestens einer der beiden ist nicht null (key kommt aus der
        // Vereinigung beider Schlüsselmengen), also gilt dieselbe Regel:
        // bekannt + unbekannt = bekannt, aber incomplete.
        mergedExtra[key] = (a ?? b)!;
        incomplete.add(key);
      }
    }

    final result = NutrientSet(
      energyKcal: addOne(energyKcal, other.energyKcal, 'energy_kcal'),
      fatG: addOne(fatG, other.fatG, 'fat_g'),
      saturatedFatG: addOne(saturatedFatG, other.saturatedFatG, 'saturated_fat_g'),
      carbsG: addOne(carbsG, other.carbsG, 'carbs_g'),
      sugarsG: addOne(sugarsG, other.sugarsG, 'sugars_g'),
      fiberG: addOne(fiberG, other.fiberG, 'fiber_g'),
      proteinG: addOne(proteinG, other.proteinG, 'protein_g'),
      saltG: addOne(saltG, other.saltG, 'salt_g'),
      extra: mergedExtra,
    );

    return (set: result, incomplete: incomplete);
  }

  NutrientSet copyWith({
    Object? energyKcal = _unset,
    Object? fatG = _unset,
    Object? saturatedFatG = _unset,
    Object? carbsG = _unset,
    Object? sugarsG = _unset,
    Object? fiberG = _unset,
    Object? proteinG = _unset,
    Object? saltG = _unset,
    Map<String, Decimal>? extra,
  }) {
    return NutrientSet(
      energyKcal: identical(energyKcal, _unset) ? this.energyKcal : energyKcal as Decimal?,
      fatG: identical(fatG, _unset) ? this.fatG : fatG as Decimal?,
      saturatedFatG:
          identical(saturatedFatG, _unset) ? this.saturatedFatG : saturatedFatG as Decimal?,
      carbsG: identical(carbsG, _unset) ? this.carbsG : carbsG as Decimal?,
      sugarsG: identical(sugarsG, _unset) ? this.sugarsG : sugarsG as Decimal?,
      fiberG: identical(fiberG, _unset) ? this.fiberG : fiberG as Decimal?,
      proteinG: identical(proteinG, _unset) ? this.proteinG : proteinG as Decimal?,
      saltG: identical(saltG, _unset) ? this.saltG : saltG as Decimal?,
      extra: extra ?? this.extra,
    );
  }

  /// JSON-Darstellung: alle Zahlen als String, null bleibt null
  /// (Kapitel 4.1, Kapitel 9).
  Map<String, dynamic> toJsonMap() {
    return {
      'energy_kcal': energyKcal?.toString(),
      'fat_g': fatG?.toString(),
      'saturated_fat_g': saturatedFatG?.toString(),
      'carbs_g': carbsG?.toString(),
      'sugars_g': sugarsG?.toString(),
      'fiber_g': fiberG?.toString(),
      'protein_g': proteinG?.toString(),
      'salt_g': saltG?.toString(),
      'extra': {
        for (final entry in extra.entries) entry.key: entry.value.toString(),
      },
    };
  }

  factory NutrientSet.fromJsonMap(Map<String, dynamic> json) {
    Decimal? parseField(String key) {
      final raw = json[key];
      if (raw == null) return null;
      return Decimal.parse(raw as String);
    }

    final rawExtra = json['extra'] as Map<String, dynamic>?;
    final extra = <String, Decimal>{
      if (rawExtra != null)
        for (final entry in rawExtra.entries) entry.key: Decimal.parse(entry.value as String),
    };

    return NutrientSet(
      energyKcal: parseField('energy_kcal'),
      fatG: parseField('fat_g'),
      saturatedFatG: parseField('saturated_fat_g'),
      carbsG: parseField('carbs_g'),
      sugarsG: parseField('sugars_g'),
      fiberG: parseField('fiber_g'),
      proteinG: parseField('protein_g'),
      saltG: parseField('salt_g'),
      extra: extra,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NutrientSet) return false;
    return energyKcal == other.energyKcal &&
        fatG == other.fatG &&
        saturatedFatG == other.saturatedFatG &&
        carbsG == other.carbsG &&
        sugarsG == other.sugarsG &&
        fiberG == other.fiberG &&
        proteinG == other.proteinG &&
        saltG == other.saltG &&
        _extraEquals(extra, other.extra);
  }

  @override
  int get hashCode {
    // extra-Map order-unabhängig kombinieren (XOR statt Object.hashAll,
    // weil die Reihenfolge der Einträge nicht garantiert ist).
    var extraHash = 0;
    for (final entry in extra.entries) {
      extraHash ^= Object.hash(entry.key, entry.value);
    }
    return Object.hash(
      energyKcal,
      fatG,
      saturatedFatG,
      carbsG,
      sugarsG,
      fiberG,
      proteinG,
      saltG,
      extraHash,
    );
  }

  static bool _extraEquals(Map<String, Decimal> a, Map<String, Decimal> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  String toString() => 'NutrientSet(${toJsonMap()})';
}