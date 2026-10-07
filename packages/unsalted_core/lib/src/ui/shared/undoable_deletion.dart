// lib/src/ui/shared/undoable_deletion.dart
//
// Teil 1.1b: Rezepte und Lebensmittel löschen mit „Rückgängig“ statt
// Bestätigungsdialog. Der Eintrag verschwindet sofort aus der Liste, eine
// SnackBar bietet 5 s lang „Rückgängig“ an, erst danach ruft ein Timer
// softDeleteRecipe bzw. softDeleteVariant auf (Kapitel 16.1, 16.2). Eine
// Wiederherstellen-Methode gibt es nicht und braucht es nicht: Bis zum Ablauf
// ist nichts gelöscht.
//
// Seit Teil 1.2 zeigt `AppMessenger` die Meldung, den Wisch-Hintergrund
// liefert `AppSwipeToDelete` (unsalted_design).
//
// Die ausstehenden Löschungen liegen in einem UI-internen Provider (nicht über
// die Tür exportiert), damit sie das Schließen eines Bildschirms überleben --
// das Rezeptdetail startet die Löschung und kehrt zur Liste zurück, die den
// Eintrag dann schon ausblendet. Jede Löschung hat ihren eigenen Timer; eine
// neue SnackBar ersetzt eine noch sichtbare, deren Timer läuft weiter. Wird
// die App innerhalb der 5 s beendet, verwirft der ProviderScope die Timer:
// nichts wird gelöscht.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/core_exceptions.dart';
import '../../food/food_variant.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe.dart';

/// Zeit zwischen Wischen bzw. Menüpunkt und dem tatsächlichen Löschen.
const undoableDeletionDelay = Duration(seconds: 5);

/// IDs, die ausgeblendet sind: ausstehend oder bereits gelöscht. Gelöschte IDs
/// bleiben im Satz, damit der Eintrag nicht kurz wieder auftaucht, bevor der
/// Stream der Liste die Löschung meldet (IDs werden nie wiederverwendet).
class PendingDeletions extends Notifier<Set<String>> {
  final _timers = <String, Timer>{};

  @override
  Set<String> build() {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    });
    return const <String>{};
  }

  /// Blendet [id] sofort aus und ruft [delete] nach [undoableDeletionDelay]
  /// auf; [onExpired] läuft unmittelbar davor.
  void schedule(String id, Future<void> Function() delete, {VoidCallback? onExpired}) {
    _timers.remove(id)?.cancel();
    state = {...state, id};
    _timers[id] = Timer(undoableDeletionDelay, () async {
      _timers.remove(id);
      onExpired?.call();
      try {
        await delete();
      } on NotFoundException {
        // Bereits gelöscht -- Ziel erreicht.
      } catch (_) {
        // Löschen fehlgeschlagen: Eintrag wieder zeigen, Fehler nicht verschlucken.
        if (ref.mounted) state = {...state}..remove(id);
        rethrow;
      }
    });
  }

  /// Bricht die ausstehende Löschung von [id] ab und blendet den Eintrag
  /// wieder ein. `false`, wenn nichts mehr aussteht.
  bool undo(String id) {
    final timer = _timers.remove(id);
    if (timer == null) return false;
    timer.cancel();
    state = {...state}..remove(id);
    return true;
  }
}

/// Ausgeblendete Rezept-IDs (Rezeptliste).
final pendingRecipeDeletionsProvider =
    NotifierProvider<PendingDeletions, Set<String>>(PendingDeletions.new);

/// Ausgeblendete Lebensmittel-IDs (Lebensmittel-Liste).
final pendingFoodDeletionsProvider =
    NotifierProvider<PendingDeletions, Set<String>>(PendingDeletions.new);

/// Löscht [recipe] samt aller Versionen nach Ablauf der Frist, sofern nicht
/// „Rückgängig“ gewählt wird.
void deleteRecipeWithUndo(BuildContext context, WidgetRef ref, Recipe recipe) {
  final repo = ref.read(recipeRepositoryProvider);
  _scheduleWithUndo(
    messenger: AppMessenger.of(context),
    pending: ref.read(pendingRecipeDeletionsProvider.notifier),
    id: recipe.id,
    message: '„${recipe.title}“ gelöscht',
    delete: () => repo.softDeleteRecipe(recipe.id),
  );
}

/// Löscht [variant] nach Ablauf der Frist, sofern nicht „Rückgängig“ gewählt
/// wird. Snapshots behalten ihre eingebetteten Nährwerte (Kapitel 12.3),
/// Entwürfe zeigen den Hinweis aus 9.1b.
void deleteFoodWithUndo(BuildContext context, WidgetRef ref, FoodVariant variant) {
  final repo = ref.read(foodRepositoryProvider);
  _scheduleWithUndo(
    messenger: AppMessenger.of(context),
    pending: ref.read(pendingFoodDeletionsProvider.notifier),
    id: variant.id,
    message: '„${variant.name}“ gelöscht. Eingefrorene Versionen behalten ihre Nährwerte.',
    delete: () => repo.softDeleteVariant(variant.id),
  );
}

void _scheduleWithUndo({
  required AppMessenger messenger,
  required PendingDeletions pending,
  required String id,
  required String message,
  required Future<void> Function() delete,
}) {
  // Eine noch sichtbare Meldung weicht sofort; ihre Löschung läuft weiter.
  final snackbar = messenger.showWithAction(
    message: message,
    actionLabel: 'Rückgängig',
    onAction: () => pending.undo(id),
    duration: undoableDeletionDelay,
  );
  // Mit Ablauf der Frist verschwindet auch „Rückgängig“ -- danach wäre es
  // wirkungslos.
  pending.schedule(id, delete, onExpired: snackbar.close);
}
