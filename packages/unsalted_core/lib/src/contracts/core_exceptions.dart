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
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;

  /// Erzeugt den Fehler mit [message].
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Wird geworfen, wenn ein angefordertes Rezept, eine Version oder ein
/// Lebensmittel nicht existiert oder gelöscht ist (Kapitel 16.1, 16.2).
class NotFoundException implements Exception {
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;
  /// Erzeugt den Fehler mit [message].
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

/// Wird geworfen, wenn eine eingefrorene Version verändert werden soll, etwa
/// per `saveDraft` (Kapitel 12.2).
class SnapshotImmutableException implements Exception {
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;
  /// Erzeugt den Fehler mit [message].
  const SnapshotImmutableException(this.message);
  @override
  String toString() => 'SnapshotImmutableException: $message';
}

/// Wird geworfen, wenn eine Operation im aktuellen Zustand nicht zulässig ist,
/// z. B. eine eingefrorene Version erneut einfrieren, einen Draft als Master
/// setzen oder die letzte Version löschen (Kapitel 12).
class IllegalStateException implements Exception {
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;
  /// Erzeugt den Fehler mit [message].
  const IllegalStateException(this.message);
  @override
  String toString() => 'IllegalStateException: $message';
}

/// Wird geworfen, wenn ein Snapshot-JSON strukturell oder fachlich ungültig
/// ist (Kapitel 13.5); vor dem Schreiben, nichts wird gespeichert.
class ImportFormatException implements Exception {
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;
  /// Erzeugt den Fehler mit [message].
  const ImportFormatException(this.message);
  @override
  String toString() => 'ImportFormatException: $message';
}

/// Wird geworfen, wenn ein Snapshot aus einer neueren Version von unsalted
/// stammt (`format_version` > 1, Kapitel 13.5).
class ImportVersionException implements Exception {
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;
  /// Erzeugt den Fehler mit [message].
  const ImportVersionException(this.message);
  @override
  String toString() => 'ImportVersionException: $message';
}

/// Wird geworfen, wenn eine `RecipeChange`-JSON einen unbekannten `type`
/// trägt (Kapitel 14.2).
class UnknownChangeException implements Exception {
  /// Klartextnachricht, direkt in der UI anzeigbar (Kapitel 16.6).
  final String message;
  /// Erzeugt den Fehler mit [message].
  const UnknownChangeException(this.message);
  @override
  String toString() => 'UnknownChangeException: $message';
}