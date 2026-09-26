import 'package:decimal/decimal.dart';

import '../contracts/core_exceptions.dart';
import '../nutrition/nutrient_set.dart';
import 'recipe_snapshot_v1.dart';

/// Handgeschriebener JSON-Codec für das Snapshot-Format v1 (Kapitel 13).
/// Kein Code-Generator, weil das Format ein eingefrorener Vertrag ist.
///
/// Annahme (bitte prüfen): `NutrientSet` besitzt bereits `toJsonMap()` und
/// `NutrientSet.fromJsonMap(Map<String, dynamic>)` aus Schritt 2.3. Falls
/// diese Methoden bei dir anders heißen, hier anpassen.
class SnapshotCodec {
  const SnapshotCodec._();

  // ---------------------------------------------------------------------
  // encode
  // ---------------------------------------------------------------------

  static Map<String, dynamic> encode(RecipeSnapshotV1 s) {
    return {
      'format': kSnapshotFormat,
      'format_version': s.formatVersion,
      'recipe': _encodeRecipe(s.recipe),
      'version': _encodeVersion(s.version),
      'ingredients': s.ingredients.map(_encodeIngredient).toList(),
      'steps': s.steps.map(_encodeStep).toList(),
      'nutrition': _encodeNutrition(s.nutrition),
    };
  }

  static Map<String, dynamic> _encodeRecipe(RecipeSnapshotRecipe r) => {
        'id': r.id,
        'title': r.title,
        'description': r.description,
      };

  static Map<String, dynamic> _encodeVersion(RecipeSnapshotVersion v) => {
        'id': v.id,
        'parent_version_id': v.parentVersionId,
        'version_index': v.versionIndex,
        'label': v.label,
        'servings': v.servings,
        'baking_loss_percent': v.bakingLossPercent.toString(),
        'final_weight_override_g': v.finalWeightOverrideG?.toString(),
        'notes': v.notes,
        'created_at': v.createdAt.toIso8601String(),
        'snapshotted_at': v.snapshottedAt.toIso8601String(),
      };

  static Map<String, dynamic> _encodeIngredient(RecipeSnapshotIngredient i) => {
        'position': i.position,
        'name': i.name,
        'brand': i.brand,
        'barcode': i.barcode,
        'quantity': i.quantity.toString(),
        'unit': i.unit,
        'grams': i.grams?.toString(),
        'note': i.note,
        'density_g_per_ml': i.densityGPerMl?.toString(),
        'grams_per_piece': i.gramsPerPiece?.toString(),
        'per100g': i.per100g?.toJsonMap(),
      };

  static Map<String, dynamic> _encodeStep(RecipeSnapshotStep s) => {
        'position': s.position,
        'instruction': s.instruction,
        'timer_seconds': s.timerSeconds,
      };

  static Map<String, dynamic> _encodeNutrition(RecipeSnapshotNutrition n) => {
        'raw_weight_g': n.rawWeightG.toString(),
        'final_weight_g': n.finalWeightG.toString(),
        'total': n.total.toJsonMap(),
        'per100g': n.per100g.toJsonMap(),
        'incomplete': n.incomplete,
        'not_calculable': n.notCalculable,
      };

  // ---------------------------------------------------------------------
  // decode
  // ---------------------------------------------------------------------

  static RecipeSnapshotV1 decode(Map<String, dynamic> json) {
    _checkFormat(json);

    final ingredientsRaw = _requireList(json, 'ingredients');
    if (ingredientsRaw.isEmpty) {
      throw const ImportFormatException('Snapshot ohne Zutaten ist ungültig.');
    }

    return RecipeSnapshotV1(
      formatVersion: json['format_version'] as int,
      recipe: _decodeRecipe(_requireMap(json, 'recipe')),
      version: _decodeVersion(_requireMap(json, 'version')),
      ingredients: ingredientsRaw
          .map((e) => _decodeIngredient(e as Map<String, dynamic>))
          .toList(),
      steps: _requireList(json, 'steps')
          .map((e) => _decodeStep(e as Map<String, dynamic>))
          .toList(),
      nutrition: _decodeNutrition(_requireMap(json, 'nutrition')),
    );
  }

  static void _checkFormat(Map<String, dynamic> json) {
    final format = json['format'];
    if (format != kSnapshotFormat) {
      throw const ImportFormatException(
        'Unbekanntes Format — dies ist keine unsalted-Rezeptdatei.',
      );
    }
    final version = json['format_version'];
    if (version is! int || version < 1) {
      throw const ImportFormatException(
        'Fehlende oder ungültige format_version.',
      );
    }
    if (version > kSnapshotFormatVersion) {
      throw const ImportVersionException(
        'Dieses Rezept stammt aus einer neueren Version von unsalted.',
      );
    }
  }

  static RecipeSnapshotRecipe _decodeRecipe(Map<String, dynamic> j) {
    return RecipeSnapshotRecipe(
      id: _requireString(j, 'id'),
      title: _requireString(j, 'title'),
      description: _optionalString(j, 'description'),
    );
  }

  static RecipeSnapshotVersion _decodeVersion(Map<String, dynamic> j) {
    return RecipeSnapshotVersion(
      id: _requireString(j, 'id'),
      parentVersionId: _optionalString(j, 'parent_version_id'),
      versionIndex: _requireInt(j, 'version_index'),
      label: _optionalString(j, 'label'),
      servings: _optionalInt(j, 'servings'),
      bakingLossPercent: Decimal.parse(_requireString(j, 'baking_loss_percent')),
      finalWeightOverrideG: _optionalDecimal(j, 'final_weight_override_g'),
      notes: _optionalString(j, 'notes'),
      createdAt: DateTime.parse(_requireString(j, 'created_at')),
      snapshottedAt: DateTime.parse(_requireString(j, 'snapshotted_at')),
    );
  }

  static RecipeSnapshotIngredient _decodeIngredient(Map<String, dynamic> j) {
    final per100gRaw = _requireKeyPresent(j, 'per100g');
    return RecipeSnapshotIngredient(
      position: _requireInt(j, 'position'),
      name: _requireString(j, 'name'),
      brand: _optionalString(j, 'brand'),
      barcode: _optionalString(j, 'barcode'),
      quantity: Decimal.parse(_requireString(j, 'quantity')),
      unit: _requireString(j, 'unit'),
      grams: _optionalDecimal(j, 'grams'),
      note: _optionalString(j, 'note'),
      densityGPerMl: _optionalDecimal(j, 'density_g_per_ml'),
      gramsPerPiece: _optionalDecimal(j, 'grams_per_piece'),
      per100g: per100gRaw == null
          ? null
          : NutrientSet.fromJsonMap(per100gRaw as Map<String, dynamic>),
    );
  }

  static RecipeSnapshotStep _decodeStep(Map<String, dynamic> j) {
    return RecipeSnapshotStep(
      position: _requireInt(j, 'position'),
      instruction: _requireString(j, 'instruction'),
      timerSeconds: _optionalInt(j, 'timer_seconds'),
    );
  }

  static RecipeSnapshotNutrition _decodeNutrition(Map<String, dynamic> j) {
    return RecipeSnapshotNutrition(
      rawWeightG: Decimal.parse(_requireString(j, 'raw_weight_g')),
      finalWeightG: Decimal.parse(_requireString(j, 'final_weight_g')),
      total: NutrientSet.fromJsonMap(_requireMap(j, 'total')),
      per100g: NutrientSet.fromJsonMap(_requireMap(j, 'per100g')),
      incomplete: _requireList(j, 'incomplete').cast<String>(),
      notCalculable: _requireList(j, 'not_calculable').cast<String>(),
    );
  }

  // ---------------------------------------------------------------------
  // Hilfsfunktionen — jede prüft, dass der Schlüssel vorhanden ist
  // (Kapitel 13.2, Spalte "Pflicht"), unabhängig davon, ob der Wert null
  // sein darf.
  // ---------------------------------------------------------------------

  static dynamic _requireKeyPresent(Map<String, dynamic> j, String key) {
    if (!j.containsKey(key)) {
      throw ImportFormatException('Pflichtfeld "$key" fehlt.');
    }
    return j[key];
  }

  static String _requireString(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v is! String) {
      throw ImportFormatException('Pflichtfeld "$key" fehlt oder ist ungültig.');
    }
    return v;
  }

  static int _requireInt(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v is! int) {
      throw ImportFormatException('Pflichtfeld "$key" fehlt oder ist ungültig.');
    }
    return v;
  }

  static Map<String, dynamic> _requireMap(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v is! Map<String, dynamic>) {
      throw ImportFormatException('Pflichtfeld "$key" fehlt oder ist ungültig.');
    }
    return v;
  }

  static List<dynamic> _requireList(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v is! List) {
      throw ImportFormatException('Pflichtfeld "$key" fehlt oder ist ungültig.');
    }
    return v;
  }

  static String? _optionalString(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v == null) return null;
    if (v is! String) {
      throw ImportFormatException('Feld "$key" ist ungültig.');
    }
    return v;
  }

  static int? _optionalInt(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v == null) return null;
    if (v is! int) {
      throw ImportFormatException('Feld "$key" ist ungültig.');
    }
    return v;
  }

  static Decimal? _optionalDecimal(Map<String, dynamic> j, String key) {
    final v = _requireKeyPresent(j, key);
    if (v == null) return null;
    if (v is! String) {
      throw ImportFormatException('Feld "$key" ist ungültig.');
    }
    return Decimal.parse(v);
  }
}