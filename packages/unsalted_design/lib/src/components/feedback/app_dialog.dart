// lib/src/components/feedback/app_dialog.dart
//
// Komponente (Teil 1.2): Dialoge (Figma `Feedback/Dialog`) — Rückfrage
// (Ja/Nein), Auswahl aus einer Liste, Dialog mit freiem Inhalt und der
// „Über“-Dialog. Bauen `AlertDialog`/`SimpleDialog` (Plan R1). Texte liefert
// der Aufrufer.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';
import '../buttons/app_button.dart';
import '../inputs/app_select.dart';

/// Fragt [message] ab; `true` nur bei [confirmLabel], sonst `false`.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppButton.tertiary(label: cancelLabel, onPressed: () => Navigator.of(context).pop(false)),
        AppButton.tertiary(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  return result ?? false;
}

/// Lässt einen Eintrag aus [options] wählen; `null` bei Abbruch. Ohne
/// Einträge steht [emptyMessage] im Dialog.
Future<T?> showAppChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required List<AppSelectItem<T>> options,
  required String emptyMessage,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          if (options.isEmpty) AppPadding.all(AppSpace.l, child: Text(emptyMessage)),
          for (final option in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(option.value),
              child: Text(option.label),
            ),
        ],
      ),
    );

/// Zeigt den Dialog aus [builder]; Ergebnis ist der Wert beim Schließen.
Future<T?> showAppDialog<T>(BuildContext context, WidgetBuilder builder) =>
    showDialog<T>(context: context, builder: builder);

/// Zeigt den „Über“-Dialog der App.
void showAppAboutDialog(BuildContext context, {required String applicationName}) =>
    showAboutDialog(context: context, applicationName: applicationName);

/// Dialog mit Titel, freiem Inhalt und Aktionen.
class AppDialog extends StatelessWidget {
  /// Erzeugt den Dialog.
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.fixedContentSize = false,
  });

  /// Titel.
  final String title;

  /// Inhalt.
  final Widget content;

  /// Aktionen unten, z. B. `AppButton.tertiary`.
  final List<Widget> actions;

  /// `true`: Inhalt in fester Größe (400 × 400), z. B. für Suche mit Liste.
  final bool fixedContentSize;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: fixedContentSize ? SizedBox(width: 400, height: 400, child: content) : content,
        actions: actions,
      );
}
