// lib/src/components/navigation/app_bottom_action_bar.dart
//
// Komponente (Teil 1.2): Leiste mit Aktionen am unteren Seitenrand (Figma
// `Navigation/Bottom Action Bar`). Seit Teil 1.3 (D10, Figma `Navigation/Bottom
// Action Bar`): `surface-page`, Haarlinie oben, Innenabstand `space-m` oben
// und unten, `space-l` seitlich, Abstand `space-m`. Seit D12 teilen sich die
// Aktionen immer die volle Breite, auch eine einzelne (Karte „Buttons teilen
// die Breite“, Bildschirm 08); würde eine schmaler als `reflow-field-min`
// (wächst mit der Textgröße), stehen sie untereinander in der gegebenen
// Reihenfolge, jede in voller Breite (Figma „Bildschirme · Schrift 200“).

import 'package:flutter/widgets.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_reflow.dart';
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
          child: LayoutBuilder(builder: (context, constraints) {
            final share = (constraints.maxWidth - (actions.length - 1) * AppSpacing.m) / actions.length;
            if (actions.length > 1 && share < AppReflowMetric.fieldMin.of(context)) {
              return AppStack(gap: AppSpace.m, crossAxisAlignment: CrossAxisAlignment.stretch, children: actions);
            }
            return AppStack(
              direction: Axis.horizontal,
              gap: AppSpace.m,
              mainAxisSize: MainAxisSize.max,
              children: [for (final action in actions) Expanded(child: action)],
            );
          }),
        ),
      ),
    );
  }
}
