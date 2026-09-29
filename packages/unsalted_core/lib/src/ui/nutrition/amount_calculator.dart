// lib/src/ui/nutrition/amount_calculator.dart
//
// Bildschirm 6 (Kapitel 22, Schritt 8.4): Mengenrechner. Zwei beidseitig
// gekoppelte Eingabefelder (Gramm <-> kcal) über
// NutritionResult.forAmount/.gramsForKcal (Kapitel 17: reine
// Rechenkern-Konsumierung, keine eigene Nährwertberechnung). Eingabe als
// Text, geparst mit Decimal.parse; ungültige Eingabe färbt nur das Feld
// (errorText), löst keine Exception aus.
//
// Die beiden Textfelder sind gleichzeitig Ein- UND Ausgabe (bidirektional
// gekoppelt) -- ihr Inhalt muss mit Decimal.parse rücklesbar bleiben.
// Deshalb läuft die Rundung des jeweils berechneten Gegenfelds über
// Decimal.round() (dieselbe Rundungsoperation, die NutritionFormatter
// intern für kcal/Gramm verwendet), nicht über NutritionFormatters
// String-Ausgabe mit Tausenderpunkt -- die wäre für ein editierbares Feld
// nicht mehr geparst werden können.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../nutrition/nutrition_result.dart';

class AmountCalculator extends StatefulWidget {
  final NutritionResult result;

  const AmountCalculator({super.key, required this.result});

  @override
  State<AmountCalculator> createState() => _AmountCalculatorState();
}

class _AmountCalculatorState extends State<AmountCalculator> {
  final _gramsController = TextEditingController();
  final _kcalController = TextEditingController();
  String? _gramsError;
  String? _kcalError;

  @override
  void dispose() {
    _gramsController.dispose();
    _kcalController.dispose();
    super.dispose();
  }

  Decimal? _tryParse(String text) {
    final trimmed = text.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    try {
      return Decimal.parse(trimmed);
    } on FormatException {
      return null;
    }
  }

  void _onGramsChanged(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _gramsError = null;
        _kcalController.clear();
        _kcalError = null;
      });
      return;
    }
    final grams = _tryParse(text);
    if (grams == null) {
      setState(() => _gramsError = 'Ungültige Zahl');
      return;
    }
    final kcal = widget.result.forAmount(grams).energyKcal;
    setState(() {
      _gramsError = null;
      _kcalError = null;
      _kcalController.text = kcal == null ? '' : kcal.round().toString();
    });
  }

  void _onKcalChanged(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _kcalError = null;
        _gramsController.clear();
        _gramsError = null;
      });
      return;
    }
    final kcal = _tryParse(text);
    if (kcal == null) {
      setState(() => _kcalError = 'Ungültige Zahl');
      return;
    }
    final grams = widget.result.gramsForKcal(kcal);
    setState(() {
      _kcalError = null;
      _gramsError = null;
      _gramsController.text = grams == null ? '' : grams.round().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _gramsController,
            decoration: InputDecoration(labelText: 'Gramm', errorText: _gramsError),
            onChanged: _onGramsChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _kcalController,
            decoration: InputDecoration(labelText: 'kcal', errorText: _kcalError),
            onChanged: _onKcalChanged,
          ),
        ),
      ],
    );
  }
}
