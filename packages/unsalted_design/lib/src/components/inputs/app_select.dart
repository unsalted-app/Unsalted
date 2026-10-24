// lib/src/components/inputs/app_select.dart
//
// Komponente (Teil 1.2): Auswahlliste (Figma `Input/Select`). Mit Label
// baut sie ein `DropdownButtonFormField`, ohne Label ein `DropdownButton`
// (Plan R1). Mit Label gilt [AppSelect.value] nur als Startwert.
//
// Seit Teil 1.3 (D08): Beschriftung über dem Feld wie bei `AppTextField`
// (`label-small`/`text-secondary`, Abstand `space-xs`, semantisch am Feld),
// Symbol `chevron`. Seit D16 füllt eine Auswahl ohne Beschriftung mit
// [AppSelect.expand] ihre Breite (lange Einträge werden gekürzt) — für
// Zeilen, die ihr einen Anteil von mindestens `reflow-select-min` geben.
// Seit Teil 1.4 (B01, Figma: „Einheit“ mit Beschriftung) gilt
// [AppSelect.expand] auch mit Beschriftung.

import 'package:flutter/material.dart';

import '../../layout/app_stack.dart';
import '../../theme/app_colors.dart';
import '../../tokens/spacing_tokens.g.dart';
import '../../tokens/typography_tokens.g.dart';
import '../icons/app_icons.dart';

/// Ein Eintrag einer [AppSelect].
@immutable
class AppSelectItem<T> {
  /// Erzeugt den Eintrag.
  const AppSelectItem(this.value, this.label);

  /// Wert.
  final T value;

  /// Anzeigetext.
  final String label;
}

/// Auswahlliste.
class AppSelect<T> extends StatelessWidget {
  /// Erzeugt die Liste.
  const AppSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.expand = false,
  });

  /// Einträge.
  final List<AppSelectItem<T>> items;

  /// Gewählter Wert; `null` = keiner.
  final T? value;

  /// Meldet die Auswahl; `null` = gesperrt.
  final ValueChanged<T>? onChanged;

  /// Bezeichnung; mit Label als Formularfeld.
  final String? label;

  /// `true`: die verfügbare Breite füllen, lange Einträge gekürzt (braucht
  /// eine begrenzte Breite, z. B. in `Expanded`); mit und ohne Beschriftung.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      for (final item in items)
        DropdownMenuItem<T>(
          value: item.value,
          child: Text(item.label, maxLines: expand ? 1 : null, overflow: expand ? TextOverflow.ellipsis : null),
        ),
    ];
    final callback = onChanged;
    final changed = callback == null
        ? null
        : (T? selected) {
            if (selected != null) callback(selected);
          };
    const chevron = Icon(AppIcons.chevron);
    if (label == null) {
      return DropdownButton<T>(value: value, items: menuItems, onChanged: changed, icon: chevron, isExpanded: expand);
    }
    return AppStack(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      gap: AppSpace.xs,
      children: [
        ExcludeSemantics(
          child: Text(label!, style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textSecondary)),
        ),
        Semantics(
          label: label,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: menuItems,
            onChanged: changed,
            icon: chevron,
            isExpanded: expand,
          ),
        ),
      ],
    );
  }
}
