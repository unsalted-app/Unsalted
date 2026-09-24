import 'package:decimal/decimal.dart';

import '../contracts/core_exceptions.dart';
import '../nutrition/unit_catalog.dart';

/// Unterscheidet „Feld nicht ändern“ (Parameter weggelassen) von
/// „Feld explizit setzen“ (inkl. auf `null`) — nur für SetStep.timerSeconds
/// gebraucht (Kapitel 14.1).
class OptionalValue<T> {
  final T value;
  const OptionalValue(this.value);
}

sealed class RecipeChange {
  const RecipeChange();

  Map<String, dynamic> toJson();

  void validate();

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

class AddIngredient extends RecipeChange {
  final int position;
  final String displayName;
  final String? foodVariantId;
  final Decimal quantity;
  final String unitCode;
  final String? note;

  const AddIngredient({
    required this.position,
    required this.displayName,
    this.foodVariantId,
    required this.quantity,
    required this.unitCode,
    this.note,
  });

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

class RemoveIngredient extends RecipeChange {
  final int position;

  const RemoveIngredient({required this.position});

  factory RemoveIngredient.fromJson(Map<String, dynamic> json) =>
      RemoveIngredient(position: json['position'] as int);

  @override
  Map<String, dynamic> toJson() => {'type': 'remove_ingredient', 'position': position};

  @override
  void validate() => RecipeChange._validatePosition(position, 'position');
}

class SetIngredientQuantity extends RecipeChange {
  final int position;
  final Decimal quantity;
  final String? unitCode;

  const SetIngredientQuantity({
    required this.position,
    required this.quantity,
    this.unitCode,
  });

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

class ReplaceIngredient extends RecipeChange {
  final int position;
  final String displayName;
  final String? foodVariantId;
  final Decimal quantity;
  final String unitCode;

  const ReplaceIngredient({
    required this.position,
    required this.displayName,
    this.foodVariantId,
    required this.quantity,
    required this.unitCode,
  });

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

class MoveIngredient extends RecipeChange {
  final int from;
  final int to;

  const MoveIngredient({required this.from, required this.to});

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

class AddStep extends RecipeChange {
  final int position;
  final String instruction;
  final int? timerSeconds;

  const AddStep({required this.position, required this.instruction, this.timerSeconds});

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

class RemoveStep extends RecipeChange {
  final int position;

  const RemoveStep({required this.position});

  factory RemoveStep.fromJson(Map<String, dynamic> json) =>
      RemoveStep(position: json['position'] as int);

  @override
  Map<String, dynamic> toJson() => {'type': 'remove_step', 'position': position};

  @override
  void validate() => RecipeChange._validatePosition(position, 'position');
}

class SetStep extends RecipeChange {
  final int position;
  final String? instruction;
  final OptionalValue<int?>? timerSeconds;

  const SetStep({required this.position, this.instruction, this.timerSeconds});

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

class SetBakingLoss extends RecipeChange {
  final Decimal percent;

  const SetBakingLoss({required this.percent});

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

class SetFinalWeightOverride extends RecipeChange {
  final Decimal? grams;

  const SetFinalWeightOverride({this.grams});

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

class SetServings extends RecipeChange {
  final int? servings;

  const SetServings({this.servings});

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

class SetTitle extends RecipeChange {
  final String title;

  const SetTitle({required this.title});

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

class SetNotes extends RecipeChange {
  final String? notes;

  const SetNotes({this.notes});

  factory SetNotes.fromJson(Map<String, dynamic> json) => SetNotes(notes: json['notes'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'set_notes', 'notes': notes};

  @override
  void validate() {}
}