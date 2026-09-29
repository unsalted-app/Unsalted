// lib/src/ui/nutrition/nutrition_table.dart
//
// Bildschirm 5 (Kapitel 22, Schritt 8.4): Nährwerttabelle in EU-Reihenfolge
// -- Kalorien, Fett, davon gesättigte, Kohlenhydrate, davon Zucker,
// Ballaststoffe, Eiweiß, Salz (AT-12: ausschließlich energy_kcal, keine
// andere Energieeinheit). Spalte 1 ist immer "pro 100 g". Spalte 2 ist frei
// wählbar zwischen "pro 100 g" und "pro Portion" (Standard: pro Portion,
// falls servings gesetzt war -- erkennbar an result.perServing != null --
// sonst pro 100 g, da dann keine Alternative existiert). Werte aus
// incomplete bekommen ein `*` plus Fußnote. NutritionFormatter ist die
// einzige Rundungsstelle.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../nutrition/nutrition_formatter.dart';
import '../../nutrition/nutrition_result.dart';
import '../../nutrition/nutrient_set.dart';

enum NutritionTableColumn2 { per100g, perServing }

class _NutrientRowSpec {
  final String label;
  final String fieldKey;
  final Decimal? Function(NutrientSet) value;
  final bool isSalt;

  const _NutrientRowSpec(this.label, this.fieldKey, this.value, {this.isSalt = false});
}

const List<_NutrientRowSpec> _rows = [
  _NutrientRowSpec('Kalorien (kcal)', 'energy_kcal', _energyKcal),
  _NutrientRowSpec('Fett (g)', 'fat_g', _fatG),
  _NutrientRowSpec('davon gesättigte Fettsäuren (g)', 'saturated_fat_g', _saturatedFatG),
  _NutrientRowSpec('Kohlenhydrate (g)', 'carbs_g', _carbsG),
  _NutrientRowSpec('davon Zucker (g)', 'sugars_g', _sugarsG),
  _NutrientRowSpec('Ballaststoffe (g)', 'fiber_g', _fiberG),
  _NutrientRowSpec('Eiweiß (g)', 'protein_g', _proteinG),
  _NutrientRowSpec('Salz (g)', 'salt_g', _saltG, isSalt: true),
];

Decimal? _energyKcal(NutrientSet n) => n.energyKcal;
Decimal? _fatG(NutrientSet n) => n.fatG;
Decimal? _saturatedFatG(NutrientSet n) => n.saturatedFatG;
Decimal? _carbsG(NutrientSet n) => n.carbsG;
Decimal? _sugarsG(NutrientSet n) => n.sugarsG;
Decimal? _fiberG(NutrientSet n) => n.fiberG;
Decimal? _proteinG(NutrientSet n) => n.proteinG;
Decimal? _saltG(NutrientSet n) => n.saltG;

class NutritionTable extends StatefulWidget {
  final NutritionResult result;

  const NutritionTable({super.key, required this.result});

  @override
  State<NutritionTable> createState() => _NutritionTableState();
}

class _NutritionTableState extends State<NutritionTable> {
  late NutritionTableColumn2 _column2;

  @override
  void initState() {
    super.initState();
    _column2 = widget.result.perServing != null
        ? NutritionTableColumn2.perServing
        : NutritionTableColumn2.per100g;
  }

  @override
  void didUpdateWidget(covariant NutritionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_column2 == NutritionTableColumn2.perServing && widget.result.perServing == null) {
      _column2 = NutritionTableColumn2.per100g;
    }
  }

  String _format(_NutrientRowSpec spec, NutrientSet from, Set<String> incomplete) {
    final value = spec.value(from);
    final isIncomplete = incomplete.contains(spec.fieldKey);
    return spec.isSalt
        ? NutritionFormatter.formatSalt(value, isIncomplete: isIncomplete)
        : spec.fieldKey == 'energy_kcal'
            ? NutritionFormatter.formatKcal(value, isIncomplete: isIncomplete)
            : NutritionFormatter.formatGrams(value, isIncomplete: isIncomplete);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final column2Set =
        _column2 == NutritionTableColumn2.perServing ? (result.perServing ?? result.per100g) : result.per100g;
    final column2Label = _column2 == NutritionTableColumn2.perServing ? 'pro Portion' : 'pro 100 g';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.perServing != null)
          Row(
            children: [
              const Text('Spalte 2: '),
              DropdownButton<NutritionTableColumn2>(
                value: _column2,
                onChanged: (value) {
                  if (value != null) setState(() => _column2 = value);
                },
                items: const [
                  DropdownMenuItem(
                    value: NutritionTableColumn2.per100g,
                    child: Text('pro 100 g'),
                  ),
                  DropdownMenuItem(
                    value: NutritionTableColumn2.perServing,
                    child: Text('pro Portion'),
                  ),
                ],
              ),
            ],
          ),
        Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
          children: [
            TableRow(children: [
              const SizedBox.shrink(),
              const Padding(
                padding: EdgeInsets.all(4),
                child: Text('pro 100 g', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(column2Label, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
            for (final spec in _rows)
              TableRow(children: [
                Padding(padding: const EdgeInsets.all(4), child: Text(spec.label)),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(_format(spec, result.per100g, result.incomplete)),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(_format(spec, column2Set, result.incomplete)),
                ),
              ]),
          ],
        ),
        if (result.incomplete.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final spec in _rows)
                  if (result.incomplete.contains(spec.fieldKey))
                    Text(
                      '* ${spec.label}: unvollständig berechnet (mindestens eine Zutat ohne Angabe)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              ],
            ),
          ),
      ],
    );
  }
}
