// lib/src/nutrition/nutrition_result.dart
//
// Ergebnis einer Nährwertberechnung (Kapitel 13.1). Wird von der
// NutritionEngine (Schritt 2.5) erzeugt und ist Teil der öffentlichen API
// des Rechenkerns (Kapitel 14.1: die Tür exportiert NutritionResult).

import 'package:decimal/decimal.dart';

import 'decimal_math.dart';
import 'nutrient_set.dart';

class NutritionResult {
  final Decimal rawWeightG;
  final Decimal finalWeightG;
  final NutrientSet total;
  final NutrientSet per100g;

  /// null, wenn servings == null (Kapitel 13.2, Randfall-Tabelle).
  final NutrientSet? perServing;

  /// Felder, die durch mindestens eine unvollständige Addition entstanden
  /// sind (Kapitel 5.2 / 13.1), z. B. {'sugars_g'}.
  final Set<String> incomplete;

  /// Anzeigenamen der Zutaten, die nicht in Gramm umgerechnet werden
  /// konnten (fehlende Dichte oder fehlendes Stückgewicht, Kapitel 6).
  final List<String> notCalculable;

  final bool hasAnyNutrition;

  const NutritionResult({
    required this.rawWeightG,
    required this.finalWeightG,
    required this.total,
    required this.per100g,
    required this.perServing,
    required this.incomplete,
    required this.notCalculable,
    required this.hasAnyNutrition,
  });

  /// Nährwerte für eine beliebige Menge in Gramm, hochgerechnet aus per100g
  /// (Kapitel 13.2: `forAmount(g) = per100g * (g / 100)`).
  NutrientSet forAmount(Decimal grams) {
    final factor = grams.r / Decimal.fromInt(100).r;
    return per100g.scale(factor);
  }

  /// Wie viel Gramm dieser Zutat/Mischung ergeben [kcal] Energie.
  /// null, wenn per100g.energy_kcal null oder 0 ist — Division durch 0 wird
  /// so nie versucht (Kapitel 13.2:
  /// `gramsForKcal(k) = per100g.energy_kcal > 0 ? k * 100 / per100g.energy_kcal : null`).
  Decimal? gramsForKcal(Decimal kcal) {
    final energyPer100g = per100g.energyKcal;
    if (energyPer100g == null || energyPer100g <= Decimal.zero) return null;

    final result = kcal.r * Decimal.fromInt(100).r / energyPer100g.r;
    return result.toFixedDecimal();
  }
}