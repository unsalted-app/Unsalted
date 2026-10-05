import 'package:decimal/decimal.dart';

import '../contracts/core_exceptions.dart';
import '../nutrition/unit_catalog.dart';

/// Unterscheidet „Feld nicht ändern“ (Parameter weggelassen) von
/// „Feld explizit setzen“ (inkl. auf `null`) — nur für SetStep.timerSeconds
/// gebraucht (Kapitel 14.1).
class OptionalValue<T> {
  /// Der zu setzende Wert; darf `null` sein.
  final T value;
  /// Umhüllt [value].
  const OptionalValue(this.value);
}

/// Eine einzelne, unveränderliche Änderung an einer Rezeptversion (Kapitel 14).
///
/// Die 13 Unterklassen und ihre `type`-Strings sind eingefroren (Kapitel 25.1).
/// `RecipeDiff.between` erzeugt und `RecipeRepository.applyChangesAsNewDraft`
/// konsumiert dieselben Listen (Kapitel 15.5).
sealed class RecipeChange {
  const RecipeChange();

  /// JSON-Form mit `type`-String; Dezimalwerte als Strings (Kapitel 14.2).
  Map<String, dynamic> toJson();

  /// Prüft die Feldregeln aus Kapitel 14.3 und wirft [ValidationException] mit
  /// dem Namen des verletzten Feldes.
  void validate();

  /// Erzeugt die passende Unterklasse anhand von `type` (Kapitel 14.2).
  ///
  /// Wirft [UnknownChangeException], wenn `type` keinem der 13 Werte entspricht.
  static RecipeChange fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'add_ingredient' => AddIngredient.fromJson(json),
      'remove_ingredient' => RemoveIngredient.fromJson(json),
      'set_ingredient_quantity' => SetIngredientQuantity.fromJson(json),
      'replace_ingredient' => ReplaceIngredient.fromJson(json),
      'move_ingredient' => MoveIngredient.fromJson(json),
      'add_step' => AddStep.fromJson(json),
      'remove_step' => RemoveStep.fromJson(json),
      'set_step' => SetStep.fromJson(json),
      'set_baking_loss' => SetBakingLoss.fromJson(json),
      'set_final_weight_override' => SetFinalWeightOverride.fromJson(json),
      'set_servings' => SetServings.fromJson(json),
      'set_title' => SetTitle.fromJson(json),
      'set_notes' => SetNotes.fromJson(json),
      _ => throw UnknownChangeException('Unbekannter RecipeChange-Typ: $type'),
    };
  }

  static void _validatePosition(int value, String fieldName) {
    if (value < 1) {
      throw ValidationException('$fieldName muss >= 1 sein');
    }
  }

  static void _validateUnitCode(String code) {
    try {
      UnitCatalog.byCode(code);
    } on ArgumentError {
      throw ValidationException('unitCode "$code" ist unbekannt');
    }
  }

  static void _validateQuantity(Decimal quantity) {
    if (quantity < Decimal.zero) {
      throw ValidationException('quantity muss >= 0 sein');
    }
  }
}

/// Fügt eine Zutat an [position] ein; nachfolgende Zutaten rücken um eins
/// nach hinten (`add_ingredient`, Kapitel 14.1).
class AddIngredient extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;
  /// Anzeigename der neuen Zutat.
  final String displayName;
  /// Verknüpftes Lebensmittel oder `null` für eine Zutat ohne Lebensmittel.
  final String? foodVariantId;
  /// Menge, `>= 0`.
  final Decimal quantity;
  /// Einheitencode aus `UnitCatalog` (Kapitel 9).
  final String unitCode;
  /// Optionale Notiz zur Zutat.
  final String? note;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const AddIngredient({
    required this.position,
    required this.displayName,
    this.foodVariantId,
    required this.quantity,
    required this.unitCode,
    this.note,
  });

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory AddIngredient.fromJson(Map<String, dynamic> json) => AddIngredient(
        position: json['position'] as int,
        displayName: json['display_name'] as String,
        foodVariantId: json['food_variant_id'] as String?,
        quantity: Decimal.parse(json['quantity'] as String),
        unitCode: json['unit'] as String,
        note: json['note'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'add_ingredient',
        'position': position,
        'display_name': displayName,
        'food_variant_id': foodVariantId,
        'quantity': quantity.toString(),
        'unit': unitCode,
        'note': note,
      };

  @override
  void validate() {
    RecipeChange._validatePosition(position, 'position');
    RecipeChange._validateQuantity(quantity);
    RecipeChange._validateUnitCode(unitCode);
  }
}

/// Entfernt die Zutat an [position] und schließt die Lücke
/// (`remove_ingredient`, Kapitel 14.1).
class RemoveIngredient extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const RemoveIngredient({required this.position});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory RemoveIngredient.fromJson(Map<String, dynamic> json) =>
      RemoveIngredient(position: json['position'] as int);

  @override
  Map<String, dynamic> toJson() => {'type': 'remove_ingredient', 'position': position};

  @override
  void validate() => RecipeChange._validatePosition(position, 'position');
}

/// Ändert Menge und optional Einheit der Zutat an [position]
/// (`set_ingredient_quantity`, Kapitel 14.1).
class SetIngredientQuantity extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;
  /// Neue Menge, `>= 0`.
  final Decimal quantity;
  /// Neuer Einheitencode aus `UnitCatalog` oder `null`, wenn die Einheit bleibt.
  final String? unitCode;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetIngredientQuantity({
    required this.position,
    required this.quantity,
    this.unitCode,
  });

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetIngredientQuantity.fromJson(Map<String, dynamic> json) =>
      SetIngredientQuantity(
        position: json['position'] as int,
        quantity: Decimal.parse(json['quantity'] as String),
        unitCode: json['unit'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'set_ingredient_quantity',
        'position': position,
        'quantity': quantity.toString(),
        'unit': unitCode,
      };

  @override
  void validate() {
    RecipeChange._validatePosition(position, 'position');
    RecipeChange._validateQuantity(quantity);
    if (unitCode != null) RecipeChange._validateUnitCode(unitCode!);
  }
}

/// Ersetzt die Zutat an [position] vollständig (`replace_ingredient`,
/// Kapitel 14.1); eine vorhandene Notiz entfällt (Kapitel 28.3.6).
class ReplaceIngredient extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;
  /// Anzeigename der neuen Zutat.
  final String displayName;
  /// Verknüpftes Lebensmittel oder `null` für eine Zutat ohne Lebensmittel.
  final String? foodVariantId;
  /// Menge, `>= 0`.
  final Decimal quantity;
  /// Einheitencode aus `UnitCatalog` (Kapitel 9).
  final String unitCode;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const ReplaceIngredient({
    required this.position,
    required this.displayName,
    this.foodVariantId,
    required this.quantity,
    required this.unitCode,
  });

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory ReplaceIngredient.fromJson(Map<String, dynamic> json) =>
      ReplaceIngredient(
        position: json['position'] as int,
        displayName: json['display_name'] as String,
        foodVariantId: json['food_variant_id'] as String?,
        quantity: Decimal.parse(json['quantity'] as String),
        unitCode: json['unit'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'replace_ingredient',
        'position': position,
        'display_name': displayName,
        'food_variant_id': foodVariantId,
        'quantity': quantity.toString(),
        'unit': unitCode,
      };

  @override
  void validate() {
    RecipeChange._validatePosition(position, 'position');
    RecipeChange._validateQuantity(quantity);
    RecipeChange._validateUnitCode(unitCode);
  }
}

/// Verschiebt die Zutat von [from] nach [to]; die dazwischenliegenden rücken
/// auf (`move_ingredient`, Kapitel 14.1).
class MoveIngredient extends RecipeChange {
  /// 1-basierte Ausgangsposition, bezogen auf die Liste unmittelbar vor dieser
  /// Änderung (Kapitel 14.4).
  final int from;
  /// 1-basierte Zielposition, bezogen auf die Liste unmittelbar vor dieser
  /// Änderung (Kapitel 14.4).
  final int to;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const MoveIngredient({required this.from, required this.to});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory MoveIngredient.fromJson(Map<String, dynamic> json) =>
      MoveIngredient(from: json['from'] as int, to: json['to'] as int);

  @override
  Map<String, dynamic> toJson() => {'type': 'move_ingredient', 'from': from, 'to': to};

  @override
  void validate() {
    RecipeChange._validatePosition(from, 'from');
    RecipeChange._validatePosition(to, 'to');
  }
}

/// Fügt einen Schritt an [position] ein (`add_step`, Kapitel 14.1).
class AddStep extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;
  /// Anweisungstext des Schritts.
  final String instruction;
  /// Timer in Sekunden oder `null`.
  final int? timerSeconds;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const AddStep({required this.position, required this.instruction, this.timerSeconds});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory AddStep.fromJson(Map<String, dynamic> json) => AddStep(
        position: json['position'] as int,
        instruction: json['instruction'] as String,
        timerSeconds: json['timer_seconds'] as int?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'add_step',
        'position': position,
        'instruction': instruction,
        'timer_seconds': timerSeconds,
      };

  @override
  void validate() => RecipeChange._validatePosition(position, 'position');
}

/// Entfernt den Schritt an [position] (`remove_step`, Kapitel 14.1).
class RemoveStep extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const RemoveStep({required this.position});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory RemoveStep.fromJson(Map<String, dynamic> json) =>
      RemoveStep(position: json['position'] as int);

  @override
  Map<String, dynamic> toJson() => {'type': 'remove_step', 'position': position};

  @override
  void validate() => RecipeChange._validatePosition(position, 'position');
}

/// Ändert nur die angegebenen Felder des Schritts an [position]
/// (`set_step`, Kapitel 14.1).
class SetStep extends RecipeChange {
  /// 1-basierte Position, bezogen auf die Liste unmittelbar vor dieser Änderung (Kapitel 14.4).
  final int position;
  /// Neue Anweisung oder `null`, wenn sie bleibt.
  final String? instruction;
  /// `null` = Timer nicht ändern; sonst der neue Timer in Sekunden, der selbst
  /// `null` sein darf (Timer entfernen).
  final OptionalValue<int?>? timerSeconds;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetStep({required this.position, this.instruction, this.timerSeconds});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetStep.fromJson(Map<String, dynamic> json) => SetStep(
        position: json['position'] as int,
        instruction: json['instruction'] as String?,
        timerSeconds: json.containsKey('timer_seconds_set')
            ? OptionalValue<int?>(json['timer_seconds'] as int?)
            : null,
      );

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': 'set_step', 'position': position};
    if (instruction != null) json['instruction'] = instruction;
    if (timerSeconds != null) {
      json['timer_seconds_set'] = true;
      json['timer_seconds'] = timerSeconds!.value;
    }
    return json;
  }

  @override
  void validate() => RecipeChange._validatePosition(position, 'position');
}

/// Ersetzt den Backverlust der Version (`set_baking_loss`, Kapitel 14.1).
class SetBakingLoss extends RecipeChange {
  /// Backverlust in Prozent, `0`–`100`.
  final Decimal percent;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetBakingLoss({required this.percent});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetBakingLoss.fromJson(Map<String, dynamic> json) =>
      SetBakingLoss(percent: Decimal.parse(json['percent'] as String));

  @override
  Map<String, dynamic> toJson() => {'type': 'set_baking_loss', 'percent': percent.toString()};

  @override
  void validate() {
    if (percent < Decimal.zero || percent > Decimal.fromInt(100)) {
      throw ValidationException('percent muss zwischen 0 und 100 liegen');
    }
  }
}

/// Ersetzt die Übersteuerung des Fertiggewichts (`set_final_weight_override`,
/// Kapitel 14.1).
class SetFinalWeightOverride extends RecipeChange {
  /// Fertiggewicht in Gramm (`> 0`) oder `null`, um die Übersteuerung zu entfernen.
  final Decimal? grams;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetFinalWeightOverride({this.grams});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetFinalWeightOverride.fromJson(Map<String, dynamic> json) =>
      SetFinalWeightOverride(
        grams: json['grams'] != null ? Decimal.parse(json['grams'] as String) : null,
      );

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'set_final_weight_override', 'grams': grams?.toString()};

  @override
  void validate() {
    if (grams != null && grams! <= Decimal.zero) {
      throw ValidationException('grams muss > 0 sein oder null');
    }
  }
}

/// Ersetzt die Portionszahl der Version (`set_servings`, Kapitel 14.1).
class SetServings extends RecipeChange {
  /// Portionen (`>= 1`) oder `null`.
  final int? servings;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetServings({this.servings});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetServings.fromJson(Map<String, dynamic> json) =>
      SetServings(servings: json['servings'] as int?);

  @override
  Map<String, dynamic> toJson() => {'type': 'set_servings', 'servings': servings};

  @override
  void validate() {
    if (servings != null && servings! < 1) {
      throw ValidationException('servings muss >= 1 sein oder null');
    }
  }
}

/// Ändert den Rezepttitel (`set_title`, Kapitel 14.1); wirkt auf `Recipe.title`,
/// nicht auf die Version.
class SetTitle extends RecipeChange {
  /// Neuer Titel, 1–200 Zeichen.
  final String title;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetTitle({required this.title});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetTitle.fromJson(Map<String, dynamic> json) => SetTitle(title: json['title'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'set_title', 'title': title};

  @override
  void validate() {
    if (title.isEmpty || title.length > 200) {
      throw ValidationException('title muss 1–200 Zeichen lang sein');
    }
  }
}

/// Ersetzt die Notizen der Version (`set_notes`, Kapitel 14.1).
class SetNotes extends RecipeChange {
  /// Neue Notizen oder `null`.
  final String? notes;

  /// Erzeugt die Änderung; die Werte prüft [validate] (Kapitel 14.3).
  const SetNotes({this.notes});

  /// Liest die JSON-Form aus Kapitel 14.2.
  factory SetNotes.fromJson(Map<String, dynamic> json) => SetNotes(notes: json['notes'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'set_notes', 'notes': notes};

  @override
  void validate() {}
}