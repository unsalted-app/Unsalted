// lib/src/ui/config/core_ui_options.dart
//
// Teil 1.2 (C29, Kapitel 28.9 Punkt 6): Anzeige-Schalter der Core-Oberfläche —
// „Schalter statt Code löschen“. Eine Konfiguration, kein Widget. Die
// Standardwerte entsprechen dem Verhalten vor Teil 1.2; die App-Hülle
// überschreibt [coreUiOptionsProvider] mit den Werten aus
// `apps/unsalted_app/lib/config/ui_options.dart`. Ausgeblendet heißt nicht
// gelöscht: Berechnung, Speicherung, Snapshot und Export bleiben unberührt,
// ein ausgeblendetes Feld behält beim Speichern seinen Wert.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Anzeige-Schalter der Core-Bildschirme.
@immutable
class CoreUiOptions {
  /// Erzeugt die Schalter; ohne Argumente gilt das Verhalten vor Teil 1.2.
  const CoreUiOptions({
    this.hiddenNutrients = const <String>{},
    this.showBarcodeField = true,
    this.showAdvancedFields = true,
  });

  /// Ausgeblendete Nährwerte als Feldschlüssel nach Kapitel 8.1, z. B.
  /// `'fiber_g'`. Unbekannte Schlüssel werden ignoriert; `energy_kcal` lässt
  /// sich nicht ausblenden. Wirkt auf die Nährwerttabelle (Zeile und
  /// Fußnote) und das Verpackungsformular (Eingabefeld; mit Salz auch
  /// Natrium).
  final Set<String> hiddenNutrients;

  /// `false`: kein Barcode-Feld im Verpackungsformular.
  final bool showBarcodeField;

  /// `false`: keine erweiterten Felder — im Verpackungsformular Dichte,
  /// Stückgewicht, Portionsgröße und Natrium, im Rezept-Editor Backverlust
  /// und Fertiggewicht-Override.
  final bool showAdvancedFields;

  /// `true`, wenn der Nährwert [key] angezeigt wird; `energy_kcal` immer.
  bool showsNutrient(String key) => key == 'energy_kcal' || !hiddenNutrients.contains(key);

  @override
  bool operator ==(Object other) =>
      other is CoreUiOptions &&
      setEquals(other.hiddenNutrients, hiddenNutrients) &&
      other.showBarcodeField == showBarcodeField &&
      other.showAdvancedFields == showAdvancedFields;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(hiddenNutrients), showBarcodeField, showAdvancedFields);
}

/// Anzeige-Schalter der Core-Bildschirme. Standard: Verhalten vor Teil 1.2.
/// Überschrieben wird ausschließlich in der App-Hülle (Kapitel 16.7, 21).
final coreUiOptionsProvider = Provider<CoreUiOptions>((ref) => const CoreUiOptions());
