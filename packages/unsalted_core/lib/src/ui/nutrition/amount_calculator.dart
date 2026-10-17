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
//
// Seit Teil 1.3 (D15, Figma `Core/Amount Calculator`): zwei Zahlenfelder
// (rechtsbündig, tabellarische Ziffern; Gramm mit Einheit „g“ im Feld),
// dazwischen das Symbol `swap` in einem Rahmen `size-target` breit, Abstand
// `space-s`, unten ausgerichtet — nur Darstellung, keine Aktion. Würde ein
// Feld schmaler als `reflow-field-min` (große Schrift), steht das zweite
// Feld in voller Breite darunter (Figma „Schrift 200“).

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';

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
    const numeric = TextInputType.numberWithOptions(decimal: true);
    final grams = AppTextField(
      controller: _gramsController,
      label: 'Gramm',
      unit: 'g',
      keyboardType: numeric,
      error: _gramsError,
      onChanged: _onGramsChanged,
    );
    final kcal = AppTextField(
      controller: _kcalController,
      label: 'kcal',
      keyboardType: numeric,
      error: _kcalError,
      onChanged: _onKcalChanged,
    );
    const swap = SizedBox.square(dimension: AppSize.target, child: Center(child: AppIcon(AppIcons.swap)));
    final fieldMin = AppReflowMetric.fieldMin.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final share = (constraints.maxWidth - AppSize.target - 2 * AppSpacing.s) / 2;
      if (share < fieldMin) {
        return AppStack(
          gap: AppSpace.s,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppStack(
              direction: Axis.horizontal,
              gap: AppSpace.s,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [Expanded(child: grams), swap],
            ),
            kcal,
          ],
        );
      }
      return AppStack(
        direction: Axis.horizontal,
        gap: AppSpace.s,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [Expanded(child: grams), swap, Expanded(child: kcal)],
      );
    });
  }
}
