// lib/src/nutrition/decimal_math.dart
//
// Zentraler Helfer für den Übergang zwischen Rational und Decimal.
// Wörtlich nach Kapitel 4.3 des Berichts.
//
// Hintergrund: Im Rechenkern wird intern mit Rational gerechnet (weil
// Division und pow() bei Decimal auf Rational zurückfallen). Nur an den
// Ausgängen der Engine wird zurück zu Decimal konvertiert. Damit diese
// Rückkonvertierung nicht an zwanzig verschiedenen Stellen im Code verstreut
// passiert — jede mit eigener, potenziell unterschiedlicher Scale- und
// Rundungsentscheidung — gibt es genau eine erlaubte Stelle dafür: diese
// Datei. AT-08 erzwingt das automatisiert.
//
// Kein Flutter, kein Drift, kein double — dieser Rechenkern ist reines Dart
// (PROJECT.md, Regel 6; Kapitel 4.1).

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

/// Interne Rechengenauigkeit. Nur hier änderbar.
const int kInternalScale = 12;

extension RationalToDecimalX on Rational {
  /// Einziger erlaubter Weg von Rational zu Decimal im gesamten Projekt.
  ///
  /// Ruft `toDecimal(scaleOnInfinitePrecision: scale)` auf. Ohne diesen
  /// Parameter würde `toDecimal()` werfen, sobald `this` keine endliche
  /// Dezimaldarstellung hat (z. B. 1/3). Die Standard-Rundungsart von
  /// `toDecimal` ist `truncate` (Kürzen, nicht kaufmännisches Runden) —
  /// das ist hier bewusst hingenommen, weil die eigentliche Rundung für die
  /// Anzeige ohnehin ausschließlich im Formatter passiert (Kapitel 13.4).
  Decimal toFixedDecimal([int scale = kInternalScale]) =>
      toDecimal(scaleOnInfinitePrecision: scale);
}

extension DecimalRationalX on Decimal {
  /// Kurzform, um einen Decimal-Wert für eine Rechnung nach Rational zu
  /// heben (z. B. bevor er durch etwas geteilt wird).
  Rational get r => toRational();
}

/// Häufig gebrauchte Konstanten als Rational, um wiederholtes
/// `Decimal.fromInt(100).toRational()` an vielen Stellen zu vermeiden.
final Rational rHundred = Decimal.fromInt(100).toRational();
final Rational rZero = Rational.zero;