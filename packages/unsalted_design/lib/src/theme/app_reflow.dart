// lib/src/theme/app_reflow.dart
//
// Theme (Teil 1.3, D12): Maße neben Text, die mit der Textgröße wachsen
// (UEBERGABE Punkt 3, Token-Datei `reflow-*`, Figma-Sammlung `type` mit den
// Modi 100/200). Werte nur aus dem Generat (`AppReflow`); zwischen 100 und
// 200 % linear, darüber der Wert bei 200 %, darunter der bei 100 % (F5).
// Die Textgröße wird an `type/body` gemessen, damit auch eine nicht lineare
// Skalierung des Systems einen Faktor ergibt.
//
// Linien und Abstände, die mit dem Umbruch wechseln (`rule-inline`,
// `rule-stacked`, `inset-inline`), richten sich nicht nach der Textgröße,
// sondern danach, ob Zellen nebeneinander oder untereinander stehen
// ([AppReflowMetric.arranged]).

import 'package:flutter/widgets.dart';

import '../tokens/size_tokens.g.dart';
import '../tokens/typography_tokens.g.dart';

/// Ein Maß, das mit der Textgröße wächst.
enum AppReflowMetric {
  /// `reflow/value-column`: Wertspalte in Tabellen.
  valueColumn('reflow/value-column'),

  /// `reflow/label-min`: Mindestbreite der Bezeichnung neben Wertspalten.
  labelMin('reflow/label-min'),

  /// `reflow/stat-min`: Mindestbreite einer Kennzahl.
  statMin('reflow/stat-min'),

  /// `reflow/field-min`: Mindestbreite eines Felds oder Buttons in einer Reihe.
  fieldMin('reflow/field-min'),

  /// `reflow/select-min`: Mindestbreite eines Auswahlfelds.
  selectMin('reflow/select-min'),

  /// `reflow/rule-inline`: Trennlinie zwischen nebeneinanderliegenden Zellen.
  ruleInline('reflow/rule-inline'),

  /// `reflow/rule-stacked`: Trennlinie zwischen untereinanderliegenden Zellen.
  ruleStacked('reflow/rule-stacked'),

  /// `reflow/inset-inline`: Innenabstand neben einer Trennlinie.
  insetInline('reflow/inset-inline');

  const AppReflowMetric(this.figmaName);

  /// Name in Figma und im Generat.
  final String figmaName;

  /// Wert bei Textgröße 100 %.
  double get at100 => AppReflow.byFigmaName[figmaName]!;

  /// Wert bei Textgröße 200 %.
  double get at200 => AppReflow.byFigmaNameAt200[figmaName]!;

  /// Wert bei der Textgröße [scale] (1 = 100 %).
  double at(double scale) {
    final t = (scale - 1).clamp(0.0, 1.0);
    return at100 + (at200 - at100) * t;
  }

  /// Wert für die Textgröße von [context].
  double of(BuildContext context) => at(textScaleOf(context));

  /// Wert für nebeneinander (Modus 100) oder untereinander ([stacked], Modus
  /// 200) stehende Zellen.
  double arranged({required bool stacked}) => stacked ? at200 : at100;

  /// Textgröße von [context] als Faktor (1 = 100 %), gemessen an `type/body`.
  static double textScaleOf(BuildContext context) {
    final size = AppTypography.body.fontSize!;
    return MediaQuery.textScalerOf(context).scale(size) / size;
  }
}
