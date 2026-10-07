// lib/src/components/navigation/app_bottom_action_bar.dart
//
// Komponente (Teil 1.2): Leiste mit Aktionen am unteren Seitenrand (Figma
// `Navigation/Bottom Action Bar`). Eine Aktion steht in ihrer eigenen Breite,
// mehrere teilen sich die Breite.

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../tokens/spacing_tokens.dart';

/// Aktionsleiste unten.
class AppBottomActionBar extends StatelessWidget {
  /// Erzeugt die Leiste.
  const AppBottomActionBar({super.key, required this.actions});

  /// Aktionen, z. B. `AppButton.secondary` und `AppButton.primary`.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: AppPadding.all(
          AppSpace.l,
          child: actions.length == 1
              ? actions.single
              : AppStack(
                  direction: Axis.horizontal,
                  gap: AppSpace.l,
                  mainAxisSize: MainAxisSize.max,
                  children: [for (final action in actions) Expanded(child: action)],
                ),
        ),
      );
}
