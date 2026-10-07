// lib/src/ui/recipe_editor/step_row.dart
//
// Fachlicher Baustein (Teil 1.2, aus recipe_editor_screen.dart
// herausgelöst): ein Schritt im Rezept-Editor — Ziehgriff, Anweisung,
// Timer in ganzen Minuten (Fehlerbehebung 9.2a, Spezifikation 28.4.2),
// Entfernen. Die Schrittdaten und ihre Timer-Regel sind unverändert
// übernommen (vorher privat im Editor).

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Anzeige eines gespeicherten Timers im Eingabefeld: ganze Minuten als
/// Zahl, sonst m:ss (z. B. importierte 90 s → "1:30").
String timerInputText(int? seconds) {
  if (seconds == null) return '';
  if (seconds % 60 == 0) return '${seconds ~/ 60}';
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// Fehlerbehebung 9.2a, Befund 1: [timerSeconds] wird nur durch eine
/// Eingabe überschrieben. Steht im Feld wieder der Ausgangstext, gilt der
/// geladene Wert sekundengenau.
class StepRowData {
  final String id;
  final String instruction;
  final int? timerSeconds;
  final int? loadedTimerSeconds;
  final bool timerInvalid;

  const StepRowData({
    required this.id,
    required this.instruction,
    this.timerSeconds,
    this.loadedTimerSeconds,
    this.timerInvalid = false,
  });

  StepRowData copyWith({String? instruction}) => StepRowData(
        id: id,
        instruction: instruction ?? this.instruction,
        timerSeconds: timerSeconds,
        loadedTimerSeconds: loadedTimerSeconds,
        timerInvalid: timerInvalid,
      );

  /// Ganze Minuten > 0 → Minuten × 60; leer → kein Timer; sonst ungültig.
  StepRowData withTimerInput(String input) {
    final text = input.trim();
    int? seconds;
    var invalid = false;
    if (text == timerInputText(loadedTimerSeconds)) {
      seconds = loadedTimerSeconds;
    } else if (text.isNotEmpty) {
      final minutes = int.tryParse(text);
      if (minutes == null || minutes <= 0) {
        invalid = true;
        seconds = timerSeconds;
      } else {
        seconds = minutes * 60;
      }
    }
    return StepRowData(
      id: id,
      instruction: instruction,
      timerSeconds: seconds,
      loadedTimerSeconds: loadedTimerSeconds,
      timerInvalid: invalid,
    );
  }
}

/// Eine Schrittzeile.
class StepRow extends StatelessWidget {
  /// Erzeugt die Zeile; der Key muss den Schritt eindeutig kennzeichnen
  /// (Umsortieren).
  const StepRow({
    super.key,
    required this.data,
    required this.onInstructionChanged,
    required this.onTimerChanged,
    required this.onRemove,
  });

  /// Der Schritt.
  final StepRowData data;

  /// Meldet eine geänderte Anweisung.
  final ValueChanged<String> onInstructionChanged;

  /// Meldet die Eingabe im Timer-Feld.
  final ValueChanged<String> onTimerChanged;

  /// Entfernt den Schritt.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AppPadding.symmetric(
        vertical: AppSpace.xs,
        child: AppStack(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const AppIcon(AppIcons.dragHandle),
            const AppGap(AppSpace.s),
            Expanded(
              child: AppTextField(
                initialValue: data.instruction,
                label: 'Anweisung',
                onChanged: onInstructionChanged,
              ),
            ),
            const AppGap(AppSpace.s),
            AppTextField(
              initialValue: timerInputText(data.loadedTimerSeconds),
              keyboardType: TextInputType.number,
              label: 'Timer (Min.)',
              error: data.timerInvalid ? 'Ganze Minuten > 0' : null,
              width: AppFieldWidth.narrow,
              onChanged: onTimerChanged,
            ),
            AppIconButton(icon: AppIcons.deleteOutline, tooltip: 'Schritt entfernen', onPressed: onRemove),
          ],
        ),
      );
}
