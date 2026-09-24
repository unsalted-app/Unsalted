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

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

class SnapshotImmutableException implements Exception {
  final String message;
  const SnapshotImmutableException(this.message);
  @override
  String toString() => 'SnapshotImmutableException: $message';
}

class IllegalStateException implements Exception {
  final String message;
  const IllegalStateException(this.message);
  @override
  String toString() => 'IllegalStateException: $message';
}

class ImportFormatException implements Exception {
  final String message;
  const ImportFormatException(this.message);
  @override
  String toString() => 'ImportFormatException: $message';
}

class ImportVersionException implements Exception {
  final String message;
  const ImportVersionException(this.message);
  @override
  String toString() => 'ImportVersionException: $message';
}

class UnknownChangeException implements Exception {
  final String message;
  const UnknownChangeException(this.message);
  @override
  String toString() => 'UnknownChangeException: $message';
}