// lib/src/tokens/size_tokens.g.dart
//
// GENERIERT aus tokens/unsalted.tokens.json durch tool/generate_tokens.dart — nicht von Hand
// ändern (Teil 1.3, DS-04). Gruppe `size`: feste Maße und Grundwerte der
// mitwachsenden Maße (`reflow-*`).

/// Feste Maße der Komponenten: Tippziele, Höhen, Breiten, Spalten.
///
/// Ziele, die man in der Küche trifft – und die festen Maße der Komponenten. Jede Höhe und Breite
/// einer Komponente steht hier, nie als Zahl im Bildschirm. Die Einträge `reflow-*` sind Maße, die
/// mit der Schrift wachsen: je ein Wert für Textgröße `100` und `200` wie die Modi der
/// Figma-Sammlung `type`; dazwischen linear, über 200 % der Wert bei 200.
abstract final class AppSize {
  /// `size/target`
  static const double target = 48;

  /// `size/control`
  static const double control = 48;

  /// `size/fab`
  static const double fab = 56;

  /// `size/icon`
  static const double icon = 24;

  /// `size/icon-small`
  static const double iconSmall = 20;

  /// `size/mark`
  static const double mark = 24;

  /// `size/content-max`
  static const double contentMax = 720;

  /// `size/dot`
  static const double dot = 2;

  /// `size/icon-xs`
  static const double iconXs = 16;

  /// `size/control-small`
  static const double controlSmall = 32;

  /// `size/list-item`
  static const double listItem = 56;

  /// `size/top-bar`
  static const double topBar = 56;

  /// `size/nav-bar`
  static const double navBar = 64;

  /// `size/dialog`
  static const double dialog = 328;

  /// `size/value-column`
  static const double valueColumn = 96;

  /// `size/index-column`
  static const double indexColumn = 32;

  /// `size/nav-rail`
  static const double navRail = 96;

  /// `size/list-pane`
  static const double listPane = 360;

  /// Alle Werte mit ihrem Figma-Namen.
  static const byFigmaName = <String, double>{
    'size/target': target,
    'size/control': control,
    'size/fab': fab,
    'size/icon': icon,
    'size/icon-small': iconSmall,
    'size/mark': mark,
    'size/content-max': contentMax,
    'size/dot': dot,
    'size/icon-xs': iconXs,
    'size/control-small': controlSmall,
    'size/list-item': listItem,
    'size/top-bar': topBar,
    'size/nav-bar': navBar,
    'size/dialog': dialog,
    'size/value-column': valueColumn,
    'size/index-column': indexColumn,
    'size/nav-rail': navRail,
    'size/list-pane': listPane,
  };
}

/// Maße neben Text, die mit der Textgröße wachsen: Felder und [byFigmaName]
/// bei 100 %, [byFigmaNameAt200] bei 200 %. In Figma liegen sie in der
/// Sammlung `type` (Modi `100`/`200`); Zwischenstufen über `AppReflowMetric`.
abstract final class AppReflow {
  /// `reflow/value-column`
  static const double valueColumn = 96;

  /// `reflow/label-min`
  static const double labelMin = 120;

  /// `reflow/stat-min`
  static const double statMin = 96;

  /// `reflow/field-min`
  static const double fieldMin = 120;

  /// `reflow/select-min`
  static const double selectMin = 104;

  /// `reflow/rule-inline`
  static const double ruleInline = 1;

  /// `reflow/rule-stacked`
  static const double ruleStacked = 0;

  /// `reflow/inset-inline`
  static const double insetInline = 12;

  /// Alle Werte mit ihrem Figma-Namen.
  static const byFigmaName = <String, double>{
    'reflow/value-column': valueColumn,
    'reflow/label-min': labelMin,
    'reflow/stat-min': statMin,
    'reflow/field-min': fieldMin,
    'reflow/select-min': selectMin,
    'reflow/rule-inline': ruleInline,
    'reflow/rule-stacked': ruleStacked,
    'reflow/inset-inline': insetInline,
  };

  /// Alle Werte bei Textgröße 200 % (Figma-Modus `200`) mit ihrem Figma-Namen.
  static const byFigmaNameAt200 = <String, double>{
    'reflow/value-column': 160,
    'reflow/label-min': 200,
    'reflow/stat-min': 240,
    'reflow/field-min': 240,
    'reflow/select-min': 208,
    'reflow/rule-inline': 0,
    'reflow/rule-stacked': 1,
    'reflow/inset-inline': 0,
  };
}
