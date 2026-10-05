import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Einzige Stelle, an der Nährwerte für die Anzeige gerundet werden
/// (Kapitel 8.6). Unbekannte Werte erscheinen als `—`, Felder aus
/// `NutritionResult.incomplete` mit angehängtem ` *`.
abstract final class NutritionFormatter {
  static final _numberFormat = NumberFormat('#,##0', 'de_DE');

  /// Energie ganzzahlig gerundet, mit Tausenderpunkt (z. B. `1.234`).
  static String formatKcal(Decimal? value, {bool isIncomplete = false}) {
    if (value == null) return '—';
    final intPart = value.round().toBigInt().toInt();
    final str = _numberFormat.format(intPart);
    return isIncomplete ? '$str *' : str;
  }

  /// Gramm auf eine Nachkommastelle gerundet, mit Dezimalkomma und
  /// Tausenderpunkt (z. B. `12,5`).
  static String formatGrams(Decimal? value, {bool isIncomplete = false}) {
    if (value == null) return '—';
    final isNegative = value < Decimal.zero;
    final absValue = value.abs();

    final rounded = (absValue * Decimal.fromInt(10)).round();
    final intPart = (rounded ~/ Decimal.fromInt(10)).toInt();
    final decPart = (rounded % Decimal.fromInt(10)).toBigInt().toInt();

    final sign = isNegative ? '-' : '';
    final str = '$sign${_numberFormat.format(intPart)},$decPart';
    
    return isIncomplete ? '$str *' : str;
  }

  /// Salz auf zwei Nachkommastellen gerundet, mit Dezimalkomma (z. B. `0,13`).
  static String formatSalt(Decimal? value, {bool isIncomplete = false}) {
    if (value == null) return '—';
    final isNegative = value < Decimal.zero;
    final absValue = value.abs();

    final rounded = (absValue * Decimal.fromInt(100)).round();
    final intPart = (rounded ~/ Decimal.fromInt(100)).toInt();
    final decPart = (rounded % Decimal.fromInt(100)).toBigInt().toInt().toString().padLeft(2, '0');

    final sign = isNegative ? '-' : '';
    final str = '$sign${_numberFormat.format(intPart)},$decPart';
    
    return isIncomplete ? '$str *' : str;
  }
}