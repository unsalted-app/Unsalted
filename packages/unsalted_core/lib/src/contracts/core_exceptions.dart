// lib/src/contracts/core_exceptions.dart
//
// Fehlerklassen für unsalted_core (Kapitel 12.6). Alle mit Klartextnachricht.
//
// STATUS: Vorgezogen aus Schritt 3.3, weil UnitCatalog (Schritt 2.2) bereits
// ValidationException werfen muss. Die übrigen sechs Fehlerklassen aus
// Kapitel 12.6 (NotFoundException, SnapshotImmutableException,
// IllegalStateException, ImportFormatException, ImportVersionException,
// UnknownChangeException) werden additiv in Schritt 3.3 ergänzt — das ist
// vor dem Freeze ausdrücklich erlaubt (PROJECT.md, R4).

/// Wird geworfen, wenn eine fachliche Regel verletzt ist, bevor überhaupt
/// versucht wird, etwas zu speichern oder zu berechnen — z. B. eine negative
/// Menge, ein leerer Titel, ein unzulässiger Wertebereich.
class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}