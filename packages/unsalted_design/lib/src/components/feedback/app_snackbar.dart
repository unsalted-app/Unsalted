// lib/src/components/feedback/app_snackbar.dart
//
// Komponente (Teil 1.2): kurze Meldungen am unteren Rand (Figma
// `Feedback/Snackbar`). `AppMessenger` kapselt den `ScaffoldMessenger`; man
// holt ihn mit `AppMessenger.of(context)`, solange der Kontext noch gültig ist
// (z. B. vor dem Schließen einer Seite). Eine Meldung mit Aktion schließt
// nach [duration] von selbst (`persist: false`, CLAUDE.md Abschnitt 4).

import 'package:flutter/material.dart';

/// Griff auf eine angezeigte Meldung.
class AppSnackbarHandle {
  AppSnackbarHandle._(this._controller) {
    _controller.closed.then((_) => _closed = true);
  }

  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _controller;
  var _closed = false;

  /// Schließt die Meldung, sofern sie noch offen ist. `close()` des
  /// Controllers setzt voraus, dass die Meldung noch vorn in der Warteschlange
  /// steht — deshalb nur, solange sie nicht geschlossen ist.
  void close() {
    if (!_closed) _controller.close();
  }
}

/// Zeigt Meldungen über den `ScaffoldMessenger` von [of].
class AppMessenger {
  /// Messenger für [context].
  AppMessenger.of(BuildContext context) : _messenger = ScaffoldMessenger.of(context);

  final ScaffoldMessengerState _messenger;

  /// Zeigt [message] (stellt sich hinter eine sichtbare Meldung an).
  void showMessage(String message) {
    _messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Zeigt [message] mit Aktion [actionLabel] für [duration]; eine sichtbare
  /// Meldung weicht sofort.
  AppSnackbarHandle showWithAction({
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    required Duration duration,
  }) {
    _messenger.hideCurrentSnackBar();
    final controller = _messenger.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
      // Mit Aktion bliebe die SnackBar sonst stehen, bis jemand tippt.
      persist: false,
      action: SnackBarAction(label: actionLabel, onPressed: onAction),
    ));
    return AppSnackbarHandle._(controller);
  }
}

/// Kurzform: zeigt [message] über den Messenger von [context].
void showAppMessage(BuildContext context, String message) => AppMessenger.of(context).showMessage(message);
