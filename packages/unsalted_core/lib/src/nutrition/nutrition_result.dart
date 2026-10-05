// lib/src/nutrition/nutrition_result.dart
//
// Ergebnis einer Nährwertberechnung (Kapitel 13.1). Wird von der
// NutritionEngine (Schritt 2.5) erzeugt und ist Teil der öffentlichen API
// des Rechenkerns (Kapitel 14.1: die Tür exportiert NutritionResult).

import 'package:decimal/decimal.dart';

import 'decimal_math.dart';
import 'nutrient_set.dart';

/// Ergebnis einer Nährwertberechnung (Kapitel 8.4); die Form, in der UI und
/// spätere Teile Nährwerte erhalten (Kapitel 17).
class NutritionResult {
  /// Summe der Gewichte aller in Gramm umrechenbaren Zutaten.
  final Decimal rawWeightG;
  /// Fertiggewicht in Gramm: die Übersteuerung, sonst das Rohgewicht abzüglich
  /// des Backverlusts (Kapitel 8.4).
  final Decimal finalWeightG;
  /// Nährwerte des ganzen Rezepts.
  final NutrientSet total;
  /// Nährwerte pro 100 g Fertiggewicht; alle unbekannt, wenn das
  /// Fertiggewicht `0` ist (Kapitel 8.5).
  final NutrientSet per100g;

  /// null, wenn servings == null (Kapitel 8.5, Randfall-Tabelle).
  final NutrientSet? perServing;

  /// Felder, die durch mindestens eine unvollständige Addition entstanden
  /// sind (Kapitel 8.3), z. B. {'sugars_g'}.
  final Set<String> incomplete;

  /// Anzeigenamen der Zutaten, die nicht in Gramm umgerechnet werden
  /// konnten (fehlende Dichte oder fehlendes Stückgewicht, Kapitel 9).
  final List<String> notCalculable;

  /// `true`, wenn [total] mindestens einen bekannten Wert enthält.
  final bool hasAnyNutrition;

  /// Erzeugt ein Ergebnis; im Betrieb über `NutritionService` berechnet.
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
  /// (Kapitel 8.4: `forAmount(g) = per100g * (g / 100)`).
  NutrientSet forAmount(Decimal grams) {
    final factor = grams.r / Decimal.fromInt(100).r;
    return per100g.scale(factor);
  }

  /// Wie viel Gramm dieser Zutat/Mischung ergeben [kcal] Energie.
  /// null, wenn per100g.energy_kcal null oder 0 ist — Division durch 0 wird
  /// so nie versucht (Kapitel 8.4:
  /// `gramsForKcal(k) = per100g.energy_kcal > 0 ? k * 100 / per100g.energy_kcal : null`).
  Decimal? gramsForKcal(Decimal kcal) {
    final energyPer100g = per100g.energyKcal;
    if (energyPer100g == null || energyPer100g <= Decimal.zero) return null;

    final result = kcal.r * Decimal.fromInt(100).r / energyPer100g.r;
    return result.toFixedDecimal();
  }
}