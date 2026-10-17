// lib/src/components/navigation/app_bottom_action_bar.dart
//
// Komponente (Teil 1.2): Leiste mit Aktionen am unteren Seitenrand (Figma
// `Navigation/Bottom Action Bar`). Eine Aktion steht in ihrer eigenen Breite,
// mehrere teilen sich die Breite. Seit Teil 1.3 (D10, Figma `Navigation/Bottom
// Action Bar`): `surface-page`, Haarlinie oben, Innenabstand `space-m` oben
// und unten, `space-l` seitlich, Abstand `space-m`.

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/stroke_tokens.g.dart';

/// Aktionsleiste unten.
class AppBottomActionBar extends StatelessWidget {
  /// Erzeugt die Leiste.
  const AppBottomActionBar({super.key, required this.actions});

  /// Aktionen, z. B. `AppButton.secondary` und `AppButton.primary`.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfacePage,
        border: Border(top: BorderSide(color: c.lineHairline, width: AppStroke.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: AppPadding.symmetric(
          vertical: AppSpace.m,
          horizontal: AppSpace.l,
          child: actions.length == 1
              ? actions.single
              : AppStack(
                  direction: Axis.horizontal,
                  gap: AppSpace.m,
                  mainAxisSize: MainAxisSize.max,
                  children: [for (final action in actions) Expanded(child: action)],
                ),
        ),
      ),
    );
  }
}
