// lib/src/nutrition/nutrient_validator.dart
//
// Plausibilitätsprüfungen für ein NutrientSet (Kapitel 13.3). Sperrt das
// Speichern nur bei negativen Werten (echter Fehler); alles andere ist eine
// Warnung, die der Nutzer bewusst ignorieren darf (Kapitel 18, Bildschirm 10:
// "Speichern trotz Warnung erlaubt").

import 'package:decimal/decimal.dart';
import '../nutrition/decimal_math.dart';
import '../contracts/core_exceptions.dart';
import 'nutrient_set.dart';

enum NutrientWarningKind {
  saturatedFatExceedsFat,
  sugarsExceedCarbs,
  macrosExceed100g,
  energyMismatch,
  allFieldsEmpty,
}

class NutrientWarning {
  final NutrientWarningKind kind;
  final String message;

  const NutrientWarning(this.kind, this.message);

  @override
  String toString() => message;
}

abstract final class NutrientValidator {
  /// Prüft [per100g] und gibt die gefundenen Warnungen zurück.
  ///
  /// Wirft [ValidationException], wenn mindestens eines der 8 Felder
  /// negativ ist — das ist der einzige Fall, der das Speichern verhindert
  /// (Kapitel 13.3: "nie Sperre, außer bei negativen Werten").
  static List<NutrientWarning> check(NutrientSet per100g) {
    _checkNoNegativeValues(per100g);

    final warnings = <NutrientWarning>[];

    // saturated_fat_g > fat_g -> Warnung
    if (per100g.saturatedFatG != null &&
        per100g.fatG != null &&
        per100g.saturatedFatG! > per100g.fatG!) {
      warnings.add(const NutrientWarning(
        NutrientWarningKind.saturatedFatExceedsFat,
        'Gesättigte Fettsäuren sind größer als der Gesamtfettgehalt.',
      ));
    }

    // sugars_g > carbs_g -> Warnung
    if (per100g.sugarsG != null &&
        per100g.carbsG != null &&
        per100g.sugarsG! > per100g.carbsG!) {
      warnings.add(const NutrientWarning(
        NutrientWarningKind.sugarsExceedCarbs,
        'Zucker ist größer als der Gesamtkohlenhydratgehalt.',
      ));
    }

    // fat_g + carbs_g + protein_g + fiber_g > 100 -> Warnung
    if (per100g.fatG != null &&
        per100g.carbsG != null &&
        per100g.proteinG != null &&
        per100g.fiberG != null) {
      final sum = per100g.fatG! + per100g.carbsG! + per100g.proteinG! + per100g.fiberG!;
      if (sum > Decimal.fromInt(100)) {
        warnings.add(const NutrientWarning(
          NutrientWarningKind.macrosExceed100g,
          'Fett + Kohlenhydrate + Eiweiß + Ballaststoffe ergeben mehr als 100 g.',
        ));
      }
    }

    // energy_kcal weicht > 20% von 9*fat + 4*carbs + 4*protein + 2*fiber ab.
    if (per100g.energyKcal != null &&
        per100g.fatG != null &&
        per100g.carbsG != null &&
        per100g.proteinG != null &&
        per100g.fiberG != null) {
      final computedEnergy = (per100g.fatG! * Decimal.fromInt(9)) +
          (per100g.carbsG! * Decimal.fromInt(4)) +
          (per100g.proteinG! * Decimal.fromInt(4)) +
          (per100g.fiberG! * Decimal.fromInt(2));

      if (computedEnergy > Decimal.zero) {
        final deviation = (per100g.energyKcal! - computedEnergy).abs();
        final rationalDeviation = deviation / computedEnergy;
        final relativeDeviation = rationalDeviation.toFixedDecimal();
        if (relativeDeviation > Decimal.parse('0.2')) {
          warnings.add(const NutrientWarning(
            NutrientWarningKind.energyMismatch,
            'Angegebene Kalorien weichen um mehr als 20% vom errechneten Wert ab.',
          ));
        }
      }
    }

    // alle 8 Felder null -> Warnung "Lebensmittel ohne Nährwerte"
    if (per100g.energyKcal == null &&
        per100g.fatG == null &&
        per100g.saturatedFatG == null &&
        per100g.carbsG == null &&
        per100g.sugarsG == null &&
        per100g.fiberG == null &&
        per100g.proteinG == null &&
        per100g.saltG == null) {
      warnings.add(const NutrientWarning(
        NutrientWarningKind.allFieldsEmpty,
        'Lebensmittel ohne Nährwerte.',
      ));
    }

    return warnings;
  }

  static void _checkNoNegativeValues(NutrientSet per100g) {
    final fields = <String, Decimal?>{
      'energy_kcal': per100g.energyKcal,
      'fat_g': per100g.fatG,
      'saturated_fat_g': per100g.saturatedFatG,
      'carbs_g': per100g.carbsG,
      'sugars_g': per100g.sugarsG,
      'fiber_g': per100g.fiberG,
      'protein_g': per100g.proteinG,
      'salt_g': per100g.saltG,
    };

    for (final entry in fields.entries) {
      final value = entry.value;
      if (value != null && value < Decimal.zero) {
        throw ValidationException('${entry.key} darf nicht negativ sein: $value');
      }
    }

    for (final entry in per100g.extra.entries) {
      if (entry.value < Decimal.zero) {
        throw ValidationException('extra.${entry.key} darf nicht negativ sein: ${entry.value}');
      }
    }
  }
}