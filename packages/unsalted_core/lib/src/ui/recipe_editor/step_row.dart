// lib/src/ui/recipe_editor/step_row.dart
//
// Fachlicher Baustein (Teil 1.2, aus recipe_editor_screen.dart
// herausgelöst): ein Schritt im Rezept-Editor — Ziehgriff, Anweisung,
// Timer in ganzen Minuten (Fehlerbehebung 9.2a, Spezifikation 28.4.2),
// Entfernen. Die Schrittdaten und ihre Timer-Regel sind unverändert
// übernommen (vorher privat im Editor).
//
// Seit Teil 1.3 (D16, StepRow im Vorschlag, Figma `Core/Step Row`): Nummer in
// `size-index-column` (`data-strong`, vom Abschnitt übergeben, freigegeben),
// die Anweisung füllt den Rest, das Timer-Feld (schmal, wächst mit der
// Textgröße) steht darunter wie der Timer in der Anzeige; Ziehgriff und
// Entfernen unverändert. Seit D18d Abstand `space-m` zwischen Anweisung und
// Timer (wie D16b; vorher `space-s`).
//
// Seit Teil 1.4 (B01, Figma-Nachtrag N1, `_Zeile/Schritt bearbeiten`
// 227:4142): gleicher Aufbau wie die Zutatenzeile — Zeile 1 unten bündig:
// Ziehgriff und Nummer (je `space-m` darunter), Anweisung, Zeilenmenü „⋮“
// (Tooltip „Aktionen für Schritt“: „Nach oben“, „Nach unten“, „Entfernen“
// statt Papierkorb); Zeile 2 eingerückt unter der Anweisung das Timer-Feld;
// oben `space-s`, unten `space-m` und eine Haarlinie.

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
    this.number,
    required this.onInstructionChanged,
    required this.onTimerChanged,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
  });

  /// Der Schritt.
  final StepRowData data;

  /// Nummer des Schritts (ab 1); `null` = ohne Nummer.
  final int? number;

  /// Meldet eine geänderte Anweisung.
  final ValueChanged<String> onInstructionChanged;

  /// Meldet die Eingabe im Timer-Feld.
  final ValueChanged<String> onTimerChanged;

  /// Entfernt den Schritt.
  final VoidCallback onRemove;

  /// „Nach oben“ im Zeilenmenü; `null` = ausgegraut (erster Schritt).
  final VoidCallback? onMoveUp;

  /// „Nach unten“ im Zeilenmenü; `null` = ausgegraut (letzter Schritt).
  final VoidCallback? onMoveDown;

  static void _none() {}

  @override
  Widget build(BuildContext context) => AppStack(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPadding.only(
            top: AppSpace.s,
            bottom: AppSpace.m,
            child: AppStack(
              gap: AppSpace.m,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppStack(
                  direction: Axis.horizontal,
                  gap: AppSpace.s,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const AppPadding.only(bottom: AppSpace.m, child: AppIcon(AppIcons.dragHandle)),
                    if (number != null)
                      SizedBox(
                        width: AppSize.indexColumn,
                        child: AppPadding.only(bottom: AppSpace.m, child: AppText.dataStrong('$number')),
                      ),
                    Expanded(
                      child: AppTextField(
                        initialValue: data.instruction,
                        label: 'Anweisung',
                        onChanged: onInstructionChanged,
                      ),
                    ),
                    AppOverflowMenu(
                      tooltip: 'Aktionen für Schritt',
                      entries: [
                        AppMenuEntry(label: 'Nach oben', enabled: onMoveUp != null, onSelected: onMoveUp ?? _none),
                        AppMenuEntry(label: 'Nach unten', enabled: onMoveDown != null, onSelected: onMoveDown ?? _none),
                        AppMenuEntry(label: 'Entfernen', onSelected: onRemove),
                      ],
                    ),
                  ],
                ),
                AppStack(
                  direction: Axis.horizontal,
                  gap: AppSpace.s,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(width: AppSize.icon),
                    if (number != null) const SizedBox(width: AppSize.indexColumn),
                    Flexible(
                      child: AppTextField(
                        initialValue: timerInputText(data.loadedTimerSeconds),
                        keyboardType: TextInputType.number,
                        label: 'Timer (Min.)',
                        error: data.timerInvalid ? 'Ganze Minuten > 0' : null,
                        width: AppFieldWidth.narrow,
                        onChanged: onTimerChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const AppDivider.flush(),
        ],
      );
}
