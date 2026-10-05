import 'package:decimal/decimal.dart';

import '../nutrition/nutrient_set.dart';

/// Kapitel 13 der Spezifikation: das eingefrorene Snapshot-Format v1.
/// Reine Datenklassen, kein Verhalten. En-/Dekodierung liegt ausschließlich
/// in `snapshot_codec.dart` (Schritt 4.2).

const String kSnapshotFormat = 'unsalted_recipe_snapshot';
const int kSnapshotFormatVersion = 1;

/// Eingefrorener Inhalt einer Version im Snapshot-Format v1 (Kapitel 13);
/// wird über `SnapshotService` exportiert und importiert.
class RecipeSnapshotV1 {
  /// Formatversion, aktuell `1` (Kapitel 13.5).
  final int formatVersion;
  /// Rezeptdaten zum Zeitpunkt des Einfrierens.
  final RecipeSnapshotRecipe recipe;
  /// Versionsdaten zum Zeitpunkt des Einfrierens.
  final RecipeSnapshotVersion version;
  /// Zutaten mit eingebetteter Kopie der Nährwerte pro 100 g (Kapitel 12.3).
  final List<RecipeSnapshotIngredient> ingredients;
  /// Schritte in Positionsreihenfolge.
  final List<RecipeSnapshotStep> steps;
  /// Berechnungsergebnis zum Zeitpunkt des Einfrierens.
  final RecipeSnapshotNutrition nutrition;

  /// Erzeugt einen Snapshot-Wert; [formatVersion] ist standardmäßig `1`.
  const RecipeSnapshotV1({
    required this.recipe,
    required this.version,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    this.formatVersion = kSnapshotFormatVersion,
  });
}

class RecipeSnapshotRecipe {
  final String id;
  final String title;
  final String? description;

  const RecipeSnapshotRecipe({
    required this.id,
    required this.title,
    this.description,
  });
}

class RecipeSnapshotVersion {
  final String id;
  final String? parentVersionId;
  final int versionIndex;
  final String? label;
  final int? servings;
  final Decimal bakingLossPercent;
  final Decimal? finalWeightOverrideG;
  final String? notes;
  final DateTime createdAt;
  final DateTime snapshottedAt;

  RecipeSnapshotVersion({
    required this.id,
    required this.versionIndex,
    required this.bakingLossPercent,
    required this.createdAt,
    required this.snapshottedAt,
    this.parentVersionId,
    this.label,
    this.servings,
    this.finalWeightOverrideG,
    this.notes,
  });
}

class RecipeSnapshotIngredient {
  final int position;
  final String name;
  final String? brand;
  final String? barcode;
  final Decimal quantity;
  final String unit;

  /// null = zum Zeitpunkt des Einfrierens nicht berechenbar (Kapitel 8.5).
  final Decimal? grams;
  final String? note;
  final Decimal? densityGPerMl;
  final Decimal? gramsPerPiece;

  /// null = Zutat ohne verknüpfte Lebensmittel-Variante.
  final NutrientSet? per100g;

  RecipeSnapshotIngredient({
    required this.position,
    required this.name,
    required this.quantity,
    required this.unit,
    this.brand,
    this.barcode,
    this.grams,
    this.note,
    this.densityGPerMl,
    this.gramsPerPiece,
    this.per100g,
  });
}

class RecipeSnapshotStep {
  final int position;
  final String instruction;
  final int? timerSeconds;

  const RecipeSnapshotStep({
    required this.position,
    required this.instruction,
    this.timerSeconds,
  });
}

class RecipeSnapshotNutrition {
  final Decimal rawWeightG;
  final Decimal finalWeightG;
  final NutrientSet total;
  final NutrientSet per100g;
  final List<String> incomplete;
  final List<String> notCalculable;

  RecipeSnapshotNutrition({
    required this.rawWeightG,
    required this.finalWeightG,
    required this.total,
    required this.per100g,
    required this.incomplete,
    required this.notCalculable,
  });
}