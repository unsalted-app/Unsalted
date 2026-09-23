// lib/src/nutrition/nutrition_engine.dart
//
// Die zentrale Berechnungspipeline (Kapitel 13.2). Reines Dart: kein
// Flutter, kein Drift, kein double. Intern wird ausschließlich mit Rational
// gerechnet; Decimal entsteht nur an den Ausgängen von NutritionResult
// (über toFixedDecimal aus decimal_math.dart, AT-08 erzwingt das).
//
// Wichtiger Design-Punkt: Die Randfälle "keine Zutaten" und "alle Zutaten
// nicht berechenbar" brauchen keinen eigenen Sonderpfad. Wenn niemals etwas
// zu total/rawWeight addiert wird (weil die Liste leer ist, oder weil jede
// Zutat wegen fehlender Dichte/Stückgewicht übersprungen wird), bleiben
// total und rawWeight einfach in ihrem Ausgangszustand (alles null bzw. 0) —
// genau das verlangt Kapitel 13.2. Ein Sonder-Return hätte im Gegenteil den
// echten Fall "Zutat mit Menge 0, aber bekannten Nährwerten" kaputtgemacht,
// weil rawWeight dabei ebenfalls 0 wird, total aber korrekt bekannte
// Null-Werte (nicht unbekannte) enthalten muss.

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import '../contracts/core_exceptions.dart';
import 'decimal_math.dart';
import 'nutrient_set.dart';
import 'nutrition_result.dart';
import 'unit_catalog.dart';

/// Eine Zutat als Eingabe für die Engine. Bewusst ohne eigenen Datei-Vertrag
/// (Kapitel 14) — reines Eingabe-Objekt für [NutritionEngine.calculate],
/// kein Fachmodell mit eigenem Lebenszyklus wie RecipeIngredient.
///
/// [displayName] wird nur für [NutritionResult.notCalculable] gebraucht,
/// falls diese Zutat nicht in Gramm umgerechnet werden kann.
class IngredientInput {
  final String displayName;
  final Decimal quantity;
  final String unitCode;

  /// Nährwerte pro 100 g der verknüpften food_variant. null, wenn die Zutat
  /// keine Variante hat (freie Zutat ohne Nährwerte, Kapitel 7.4).
  final NutrientSet? per100g;

  /// Nötig für volume-Einheiten (tsp/tbsp/cup/ml/l). null, wenn unbekannt.
  final Decimal? densityGPerMl;

  /// Nötig für die Einheit `piece`. null, wenn unbekannt.
  final Decimal? gramsPerPiece;

  const IngredientInput({
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    this.per100g,
    this.densityGPerMl,
    this.gramsPerPiece,
  });
}

abstract final class NutritionEngine {
  static NutritionResult calculate({
    required List<IngredientInput> ingredients,
    required Decimal bakingLossPercent,
    Decimal? finalWeightOverrideG,
    int? servings,
  }) {
    if (finalWeightOverrideG != null && finalWeightOverrideG <= Decimal.zero) {
      // EN-11: finalWeightOverride = 0 (oder negativ) -> ValidationException.
      throw ValidationException(
        'final_weight_override_g muss > 0 sein, war: $finalWeightOverrideG',
      );
    }

    Rational rawWeight = Rational.zero;
    // Lazy-Akkumulator: `null` bedeutet "noch keine Zutat verarbeitet" — das
    // ist bewusst etwas anderes als ein NutrientSet, bei dem alle 8 Felder
    // bekannt-unbekannt sind. Würde man stattdessen mit `const NutrientSet()`
    // starten und ab der ersten Zutat total.plus(...) aufrufen, sähe die
    // allererste Zutat für plus() identisch aus wie "ein Feld ist bei einer
    // Zutat unbekannt" — jedes ihrer Felder würde fälschlich als incomplete
    // markiert, selbst wenn es bekannt war. Deshalb: erste Zutat wird direkt
    // übernommen, erst ab der zweiten wird per plus() kombiniert.
    NutrientSet? total;
    final incomplete = <String>{};
    final notCalculable = <String>[];

    for (final ingredient in ingredients) {
      final grams = UnitCatalog.toGrams(
        ingredient.quantity,
        ingredient.unitCode,
        densityGPerMl: ingredient.densityGPerMl,
        gramsPerPiece: ingredient.gramsPerPiece,
      );

      if (grams == null) {
        // Nicht berechenbar: fehlende Dichte oder fehlendes Stückgewicht.
        // Zählt nicht zum Gewicht, erscheint stattdessen in notCalculable
        // (Kapitel 6, Kapitel 13.2 Randfall-Tabelle).
        notCalculable.add(ingredient.displayName);
        continue;
      }

      rawWeight += grams;

      final per100gOfIngredient = ingredient.per100g;
      // Zutat ohne Variante: trägt zum Gewicht bei (oben schon geschehen),
      // aber liefert keinerlei Nährwertinformation -> Beitrag ist ein
      // vollständig unbekanntes NutrientSet (Kapitel 13.2, Randfall
      // "eine Zutat ohne Variante").
      final contribution = per100gOfIngredient == null
          ? const NutrientSet()
          : per100gOfIngredient.scale(grams / Decimal.fromInt(100).r);

      if (total == null) {
        total = contribution;
        // Auch bei genau einer Zutat gilt: ein Feld ist nur vollständig,
        // wenn diese Zutat es kennt (Kapitel 5.2). Das ist keine "Addition"
        // zweier Dinge, sondern eine Eigenschaft dieser einen Zutat.
        if (contribution.energyKcal == null) incomplete.add('energy_kcal');
        if (contribution.fatG == null) incomplete.add('fat_g');
        if (contribution.saturatedFatG == null) incomplete.add('saturated_fat_g');
        if (contribution.carbsG == null) incomplete.add('carbs_g');
        if (contribution.sugarsG == null) incomplete.add('sugars_g');
        if (contribution.fiberG == null) incomplete.add('fiber_g');
        if (contribution.proteinG == null) incomplete.add('protein_g');
        if (contribution.saltG == null) incomplete.add('salt_g');
      } else {
        final result = total.plus(contribution);
        total = result.set;
        incomplete.addAll(result.incomplete);
      }
    }

    final resolvedTotal = total ?? const NutrientSet();

    final rawWeightDecimal = rawWeight.toFixedDecimal();

    final Rational finalWeight;
    if (finalWeightOverrideG != null) {
      // Vorrang vor Backverlust (G17, Kapitel 7.3).
      finalWeight = finalWeightOverrideG.r;
    } else {
      finalWeight = rawWeight * (rHundred - bakingLossPercent.r) / rHundred;
    }
    final finalWeightDecimal = finalWeight.toFixedDecimal();

    final NutrientSet per100g;
    if (finalWeight > rZero) {
      per100g = resolvedTotal.scale(rHundred / finalWeight);
    } else {
      // finalWeight = 0 (Backverlust 100%, oder rawWeight bereits 0):
      // per100g alle null, keine Division durch 0. total bleibt erhalten
      // (Kapitel 13.2, Randfall-Tabelle).
      per100g = const NutrientSet();
    }

    final NutrientSet? perServing;
    if (servings != null) {
      perServing = resolvedTotal.scale(Rational.one / Decimal.fromInt(servings).r);
    } else {
      perServing = null;
    }

    return NutritionResult(
      rawWeightG: rawWeightDecimal,
      finalWeightG: finalWeightDecimal,
      total: resolvedTotal,
      per100g: per100g,
      perServing: perServing,
      incomplete: incomplete,
      notCalculable: notCalculable,
      hasAnyNutrition: !resolvedTotal.isEmpty,
    );
  }
}
