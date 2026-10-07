// lib/config/ui_options.dart
//
// Teil 1.2 (C29): Anzeige-Schalter der App — die einzige Stelle mit Werten
// („Schalter statt Code löschen“, Kapitel 28.9 Punkt 6). Wirksam über den
// Override von `coreUiOptionsProvider` in `main.dart`. Die Werte unten sind
// die Standardwerte, also das Verhalten vor Teil 1.2. Beispiele:
//   hiddenNutrients: {'fiber_g'}   → Ballaststoffe in Tabelle und Formular aus
//   showBarcodeField: false        → kein Barcode-Feld im Verpackungsformular
//   showAdvancedFields: false      → Dichte, Stückgewicht, Portionsgröße,
//                                    Natrium, Backverlust, Fertiggewicht aus
// `energy_kcal` lässt sich nicht ausblenden; unbekannte Schlüssel werden
// ignoriert. Ausgeblendete Werte bleiben gespeichert und wirken weiter.

import 'package:unsalted_core/unsalted_core.dart';

/// Anzeige-Schalter der App.
const uiOptions = CoreUiOptions(
  hiddenNutrients: <String>{},
  showBarcodeField: true,
  showAdvancedFields: true,
);
