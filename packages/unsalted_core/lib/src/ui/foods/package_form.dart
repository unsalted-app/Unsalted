// lib/src/ui/foods/package_form.dart
//
// Formular-Widget für ein Verpackungsformular (Bildschirm 10, Kapitel 22,
// Schritt 8.1). Reine Formularlogik -- kein Repository-Zugriff, kein
// Speichern; der Aufrufer (food_editor_screen.dart) liest den aktuellen
// Wert über den GlobalKey<PackageFormState> und ruft
// FoodRepository.createVariant/updateVariant selbst auf.
//
// Reihenfolge der Nährwertfelder wie Bildschirm 5 (EU-Reihenfolge,
// ausschließlich energy_kcal, AT-12): Kalorien, Fett, davon gesättigte,
// Kohlenhydrate, davon Zucker, Ballaststoffe, Eiweiß, Salz. Das
// Natrium-Feld ist eine alternative
// Eingabe für Salz (Kapitel 8.2): sobald es ausgefüllt ist, wird das
// Salz-Feld schreibgeschützt, und `value.nutrients.saltG` liefert bereits
// den daraus berechneten Wert (`salt_g = sodium_mg / 1000 * 2.5`) -- die
// Umrechnung passiert hier (einzige Stelle), nicht im Rechenkern und nicht
// nochmal beim Speichern in food_editor_screen.dart.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../contracts/core_exceptions.dart';
import '../../nutrition/decimal_math.dart';
import '../../nutrition/nutrient_set.dart';
import '../../nutrition/nutrient_validator.dart';

/// Ergebnis eines gültigen Formularzustands -- `null`-Felder bedeuten
/// "nicht angegeben", nicht "0".
typedef PackageFormValue = ({
  String name,
  String? brand,
  String? barcode,
  Decimal? densityGPerMl,
  Decimal? gramsPerPiece,
  Decimal? servingSizeG,
  NutrientSet nutrients,
});

class PackageForm extends StatefulWidget {
  /// `null` = neues, leeres Formular. Sonst Startwerte zum Bearbeiten.
  final PackageFormValue? initial;

  /// Wird bei jeder Änderung aufgerufen, ohne Argumente -- der Aufrufer
  /// liest den aktuellen Stand danach über den GlobalKey.
  final VoidCallback? onChanged;

  const PackageForm({super.key, this.initial, this.onChanged});

  @override
  State<PackageForm> createState() => PackageFormState();
}

class PackageFormState extends State<PackageForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _densityController;
  late final TextEditingController _gramsPerPieceController;
  late final TextEditingController _servingSizeController;

  late final TextEditingController _energyKcalController;
  late final TextEditingController _fatController;
  late final TextEditingController _saturatedFatController;
  late final TextEditingController _carbsController;
  late final TextEditingController _sugarsController;
  late final TextEditingController _fiberController;
  late final TextEditingController _proteinController;
  late final TextEditingController _saltController;
  late final TextEditingController _sodiumController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final n = initial?.nutrients ?? const NutrientSet();

    _nameController = TextEditingController(text: initial?.name ?? '');
    _brandController = TextEditingController(text: initial?.brand ?? '');
    _barcodeController = TextEditingController(text: initial?.barcode ?? '');
    _densityController = TextEditingController(text: _decimalText(initial?.densityGPerMl));
    _gramsPerPieceController = TextEditingController(text: _decimalText(initial?.gramsPerPiece));
    _servingSizeController = TextEditingController(text: _decimalText(initial?.servingSizeG));

    _energyKcalController = TextEditingController(text: _decimalText(n.energyKcal));
    _fatController = TextEditingController(text: _decimalText(n.fatG));
    _saturatedFatController = TextEditingController(text: _decimalText(n.saturatedFatG));
    _carbsController = TextEditingController(text: _decimalText(n.carbsG));
    _sugarsController = TextEditingController(text: _decimalText(n.sugarsG));
    _fiberController = TextEditingController(text: _decimalText(n.fiberG));
    _proteinController = TextEditingController(text: _decimalText(n.proteinG));
    _saltController = TextEditingController(text: _decimalText(n.saltG));
    _sodiumController = TextEditingController();

    for (final controller in _allControllers) {
      controller.addListener(_handleChanged);
    }
  }

  List<TextEditingController> get _allControllers => [
        _nameController,
        _brandController,
        _barcodeController,
        _densityController,
        _gramsPerPieceController,
        _servingSizeController,
        _energyKcalController,
        _fatController,
        _saturatedFatController,
        _carbsController,
        _sugarsController,
        _fiberController,
        _proteinController,
        _saltController,
        _sodiumController,
      ];

  static String _decimalText(Decimal? value) => value == null ? '' : value.toString();

  void _handleChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// `null`, wenn der Text leer ist. Wirft [FormatException] bei
  /// ungültigem, nicht-leerem Text.
  Decimal? _parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return Decimal.parse(trimmed.replaceAll(',', '.'));
  }

  /// Liefert `(wert, fehlertext)` -- bei ungültiger Eingabe ist wert
  /// `null` und fehlertext gesetzt, bei leerer Eingabe sind beide `null`.
  ({Decimal? value, String? error}) _tryParse(String text) {
    try {
      return (value: _parse(text), error: null);
    } on FormatException {
      return (value: null, error: 'Ungültige Zahl');
    }
  }

  bool get _hasFieldErrors => _allNumericResults.any((r) => r.error != null);

  Iterable<({Decimal? value, String? error})> get _allNumericResults sync* {
    yield _tryParse(_densityController.text);
    yield _tryParse(_gramsPerPieceController.text);
    yield _tryParse(_servingSizeController.text);
    yield _tryParse(_energyKcalController.text);
    yield _tryParse(_fatController.text);
    yield _tryParse(_saturatedFatController.text);
    yield _tryParse(_carbsController.text);
    yield _tryParse(_sugarsController.text);
    yield _tryParse(_fiberController.text);
    yield _tryParse(_saltController.text);
    yield _tryParse(_sodiumController.text);
  }

  /// Effektiver Salzwert: Natrium hat Vorrang, sobald ausgefüllt (Kapitel
  /// 8.2). Die eigentliche Umrechnung geschieht hier nur für die
  /// Live-Vorschau/Validierung; food_editor_screen.dart rechnet beim
  /// Speichern identisch.
  Decimal? get _effectiveSaltG {
    final sodium = _tryParse(_sodiumController.text).value;
    if (sodium != null) {
      return (sodium.r / Decimal.fromInt(1000).r * Decimal.parse('2.5').r).toFixedDecimal();
    }
    return _tryParse(_saltController.text).value;
  }

  NutrientSet get _currentNutrients => NutrientSet(
        energyKcal: _tryParse(_energyKcalController.text).value,
        fatG: _tryParse(_fatController.text).value,
        saturatedFatG: _tryParse(_saturatedFatController.text).value,
        carbsG: _tryParse(_carbsController.text).value,
        sugarsG: _tryParse(_sugarsController.text).value,
        fiberG: _tryParse(_fiberController.text).value,
        proteinG: _tryParse(_proteinController.text).value,
        saltG: _effectiveSaltG,
      );

  /// `null`, solange kein blockierender Fehler vorliegt.
  String? get blockingError {
    if (_hasFieldErrors) return 'Bitte ungültige Zahlenfelder korrigieren.';
    try {
      NutrientValidator.check(_currentNutrients);
    } on ValidationException catch (e) {
      return e.message;
    }
    if (_nameController.text.trim().isEmpty) return 'Name ist erforderlich.';
    return null;
  }

  List<NutrientWarning> get warnings {
    if (_hasFieldErrors) return const [];
    try {
      return NutrientValidator.check(_currentNutrients);
    } on ValidationException {
      return const [];
    }
  }

  /// `null`, wenn das Formular gerade nicht speicherbar ist
  /// ([blockingError] != null).
  PackageFormValue? get value {
    if (blockingError != null) return null;
    return (
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      densityGPerMl: _tryParse(_densityController.text).value,
      gramsPerPiece: _tryParse(_gramsPerPieceController.text).value,
      servingSizeG: _tryParse(_servingSizeController.text).value,
      nutrients: _currentNutrients,
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = blockingError;
    final currentWarnings = warnings;
    final sodiumFilled = _sodiumController.text.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _brandController,
          decoration: const InputDecoration(labelText: 'Marke'),
        ),
        TextField(
          controller: _barcodeController,
          decoration: const InputDecoration(labelText: 'Barcode'),
        ),
        const Divider(height: 32),
        TextField(
          controller: _densityController,
          decoration: const InputDecoration(labelText: 'Dichte (g/ml)'),
        ),
        TextField(
          controller: _gramsPerPieceController,
          decoration: const InputDecoration(labelText: 'Stückgewicht (g)'),
        ),
        TextField(
          controller: _servingSizeController,
          decoration: const InputDecoration(labelText: 'Portionsgröße (g)'),
        ),
        const Divider(height: 32),
        const Text('Nährwerte pro 100 g', style: TextStyle(fontWeight: FontWeight.bold)),
        _nutrientField(_energyKcalController, 'Kalorien (kcal)'),
        _nutrientField(_fatController, 'Fett (g)'),
        _nutrientField(_saturatedFatController, 'davon gesättigte Fettsäuren (g)'),
        _nutrientField(_carbsController, 'Kohlenhydrate (g)'),
        _nutrientField(_sugarsController, 'davon Zucker (g)'),
        _nutrientField(_fiberController, 'Ballaststoffe (g)'),
        _nutrientField(_proteinController, 'Eiweiß (g)'),
        _nutrientField(_saltController, 'Salz (g)', enabled: !sodiumFilled),
        _nutrientField(
          _sodiumController,
          'oder: Natrium (mg)',
          helperText: 'Ersetzt die Salz-Eingabe (Kapitel 8.2).',
        ),
        const SizedBox(height: 16),
        for (final warning in currentWarnings)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              key: const Key('package_form_warning'),
              padding: const EdgeInsets.all(8),
              color: Colors.yellow.shade100,
              child: Text(warning.message),
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              key: const Key('package_form_error'),
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
  }

  Widget _nutrientField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
    String? helperText,
  }) {
    final result = _tryParse(controller.text);
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        errorText: result.error,
        helperText: helperText,
      ),
    );
  }
}
