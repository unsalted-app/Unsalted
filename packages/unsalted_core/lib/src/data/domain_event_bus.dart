// lib/src/data/domain_event_bus.dart
//
// Kapitel 16.5, Schritt 6.2: In-Memory-Verteilung der Domain Events.
// Reiner Broadcast für die Laufzeit des App-Prozesses — keine Persistenz,
// keine UI-/Datenbankabhängigkeit. Aufrufer rufen `add(...)` erst nach
// erfolgreichem Transaktions-Commit auf, nie bei Rollback (Kapitel 16.5).

import 'dart:async';

import '../contracts/domain_events.dart';

class DomainEventBus {
  static final DomainEventBus instance = DomainEventBus();

  final StreamController<DomainEvent> _controller =
      StreamController<DomainEvent>.broadcast();

  Stream<DomainEvent> get events => _controller.stream;

  void add(DomainEvent event) => _controller.add(event);
}
