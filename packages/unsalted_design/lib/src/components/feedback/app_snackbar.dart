// lib/src/components/feedback/app_snackbar.dart
//
// Komponente (Teil 1.2): kurze Meldungen am unteren Rand (Figma
// `Feedback/Snackbar`). `AppMessenger` kapselt den `ScaffoldMessenger`; man
// holt ihn mit `AppMessenger.of(context)`, solange der Kontext noch gültig ist
// (z. B. vor dem Schließen einer Seite). Eine Meldung mit Aktion schließt
// nach [duration] von selbst (`persist: false`, CLAUDE.md Abschnitt 4).
//
// Seit Teil 1.3 (D09b, Snackbar-Karte, Figma `Feedback/Snackbar`): Die
// Meldung mit Aktion baut ihren Inhalt selbst — Innenabstand `space-l` links
// und `space-xs` sonst, Abstand Text–Aktion `space-m`, Aktion mit `space-m`
// seitlich, Tippziel `size-target`, `body-strong` in `action-inverse` — und
// zeigt die Restzeit: eine Linie `stroke-rule` in `action-inverse` am unteren
// Rand, die ab dem Erscheinen in [duration] abläuft (so lange, wie der
// Messenger die Meldung zeigt). Bei „Bewegung reduzieren“ steht die Linie
// still in voller Breite. Die Aktion bleibt eine `SnackBarAction` (schließt
// die Meldung mit Grund `action`); die Meldung selbst hat dann keine eigene
// Aktion mehr, ihr Ablauf hängt wie bisher nur an `persist: false`. Bliebe
// dem Text neben der Aktion weniger als `reflow-label-min` (große Schrift),
// steht die Aktion rechtsbündig unter dem Text (28.10.11).

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_reflow.dart';
import '../../tokens/motion_tokens.g.dart';
import '../../tokens/size_tokens.g.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';

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
    final visible = ValueNotifier(false);
    final controller = _messenger.showSnackBar(SnackBar(
      padding: EdgeInsets.zero,
      content: _TimedMessage(
        message: message,
        actionLabel: actionLabel,
        action: SnackBarAction(label: actionLabel, onPressed: onAction),
        duration: duration,
        visible: visible,
      ),
      duration: duration,
      // Mit Aktion bliebe die SnackBar sonst stehen, bis jemand tippt.
      persist: false,
      onVisible: () => visible.value = true,
    ));
    controller.closed.whenComplete(visible.dispose);
    return AppSnackbarHandle._(controller);
  }
}

/// Inhalt einer Meldung mit Aktion und ablaufender Restzeit.
class _TimedMessage extends StatefulWidget {
  const _TimedMessage({
    required this.message,
    required this.actionLabel,
    required this.action,
    required this.duration,
    required this.visible,
  });

  final String message;

  /// Beschriftung von [action], für die Breite.
  final String actionLabel;

  final Widget action;
  final Duration duration;

  /// Wird `true`, sobald die Meldung ganz erschienen ist; dann beginnt der
  /// Messenger seine Frist und die Linie ihren Ablauf.
  final ValueNotifier<bool> visible;

  @override
  State<_TimedMessage> createState() => _TimedMessageState();
}

class _TimedMessageState extends State<_TimedMessage> with SingleTickerProviderStateMixin {
  late final AnimationController _remaining = AnimationController(vsync: this, duration: widget.duration, value: 1);

  @override
  void initState() {
    super.initState();
    widget.visible.addListener(_start);
  }

  void _start() {
    if (widget.visible.value && mounted && !AppMotion.reduceMotion(context)) _remaining.reverse();
  }

  @override
  void dispose() {
    widget.visible.removeListener(_start);
    _remaining.dispose();
    super.dispose();
  }

  /// Breite der Aktion: Beschriftung in `body-strong` bei der Textgröße
  /// des Kontexts, dazu `space-m` auf beiden Seiten.
  double _actionWidth(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: widget.actionLabel, style: AppTypography.bodyStrong),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width + 2 * AppSpacing.m;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final action = TextButtonTheme(
      data: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
          minimumSize: const Size(0, AppSize.target),
          textStyle: AppTypography.bodyStrong,
        ),
      ),
      child: widget.action,
    );
    return Stack(
      children: [
        AppPadding.only(
          left: AppSpace.l,
          top: AppSpace.xs,
          right: AppSpace.xs,
          bottom: AppSpace.xs,
          child: LayoutBuilder(builder: (context, constraints) {
            final textWidth = constraints.maxWidth - AppSpacing.m - _actionWidth(context);
            if (textWidth < AppReflowMetric.labelMin.of(context)) {
              return AppStack(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPadding.only(top: AppSpace.s, child: Text(widget.message)),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              );
            }
            return AppStack(
              direction: Axis.horizontal,
              gap: AppSpace.m,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [Expanded(child: Text(widget.message)), action],
            );
          }),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _remaining,
            builder: (context, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _remaining.value,
                child: SizedBox(height: AppStroke.rule, child: ColoredBox(color: c.actionInverse)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kurzform: zeigt [message] über den Messenger von [context].
void showAppMessage(BuildContext context, String message) => AppMessenger.of(context).showMessage(message);
