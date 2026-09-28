// test/data/event_bus_test.dart
//
// RP-17 (Kapitel 23, Schritt 6.2): Broadcast-Verhalten des DomainEventBus.
// Prüft ausschließlich die Verteilung selbst — das Auslösen durch
// Repository-/Service-Methoden nach Commit ist Gegenstand der jeweiligen
// Implementierungstests (Schritt 6.3 ff.).

import 'package:test/test.dart';
import 'package:unsalted_core/src/contracts/domain_events.dart';
import 'package:unsalted_core/src/data/domain_event_bus.dart';

void main() {
  test('DomainEventBus.instance liefert stets dieselbe Instanz', () {
    expect(DomainEventBus.instance, same(DomainEventBus.instance));
  });

  test('ein Abonnent empfängt ein über add ausgelöstes Event', () async {
    final bus = DomainEventBus();
    final event = RecipeCreated(
      id: 'evt-1',
      at: DateTime.utc(2026, 1, 1),
      recipeId: 'r1',
      versionId: 'v1',
    );

    final future = bus.events.first;
    bus.add(event);

    expect(await future, same(event));
  });

  test('mehrere Abonnenten empfangen dasselbe Event unabhängig voneinander', () async {
    final bus = DomainEventBus();
    final event = RecipeDeleted(
      id: 'evt-2',
      at: DateTime.utc(2026, 1, 1),
      recipeId: 'r1',
    );

    final firstListener = bus.events.first;
    final secondListener = bus.events.first;
    bus.add(event);

    final results = await Future.wait([firstListener, secondListener]);
    expect(results[0], same(event));
    expect(results[1], same(event));
  });

  test('ein erst nach dem Auslösen abonnierender Listener sieht das Event nicht rückwirkend', () async {
    final bus = DomainEventBus();
    final before = RecipeDeleted(
      id: 'evt-3',
      at: DateTime.utc(2026, 1, 1),
      recipeId: 'r1',
    );
    final after = RecipeDeleted(
      id: 'evt-4',
      at: DateTime.utc(2026, 1, 2),
      recipeId: 'r1',
    );

    bus.add(before);

    final future = bus.events.first;
    bus.add(after);

    expect(await future, same(after));
  });

  test('mehrere Events werden in Reihenfolge an einen Abonnenten geliefert', () async {
    final bus = DomainEventBus();
    final first = RecipeCreated(
      id: 'evt-5',
      at: DateTime.utc(2026, 1, 1),
      recipeId: 'r1',
      versionId: 'v1',
    );
    final second = RecipeUpdated(
      id: 'evt-6',
      at: DateTime.utc(2026, 1, 2),
      recipeId: 'r1',
    );

    final received = <DomainEvent>[];
    final subscription = bus.events.listen(received.add);

    bus.add(first);
    bus.add(second);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(received, [same(first), same(second)]);
  });
}
