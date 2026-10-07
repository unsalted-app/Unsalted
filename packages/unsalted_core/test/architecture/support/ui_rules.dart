// test/architecture/support/ui_rules.dart
//
// Detektoren für AT-13 (keine festen Farben) und AT-14 (nur
// Design-Komponenten) (Teil 1.2, C13).
// Geprüft wird Quelltext ohne Kommentare, Zeile für Zeile; mehrzeilige
// Aufrufe (`TextStyle(…)`, `SizedBox(…)`) werden über den ganzen Text gesucht.

/// Entfernt Kommentare, behält aber Zeilenumbrüche (für Zeilennummern).
String stripComments(String source) {
  final withoutBlocks = source.replaceAllMapped(
    RegExp(r'/\*[\s\S]*?\*/'),
    (m) => '\n' * '\n'.allMatches(m[0]!).length,
  );
  return withoutBlocks.split('\n').map((line) => line.split('//').first).join('\n');
}

int _lineOf(String code, int offset) => '\n'.allMatches(code.substring(0, offset)).length + 1;

List<(int, String)> _hits(String code, Iterable<int> offsets) {
  final lines = code.split('\n');
  final seen = <int>{};
  return [
    for (final offset in offsets)
      if (seen.add(_lineOf(code, offset))) (_lineOf(code, offset), lines[_lineOf(code, offset) - 1].trim()),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
}

final _colorsRegex = RegExp(r'\b(Cupertino)?Colors\.');
final _colorCtorRegex = RegExp(r'\bColor(\.from\w+)?\(');
final _styleColorArg = RegExp(r'\b(color|backgroundColor|decorationColor)\s*:');

/// AT-13: Fundstellen fester Farben in [source] als (Zeile, Text) —
/// `Colors.*`, `CupertinoColors.*`, `Color(…)`, `Color.from…(…)` und ein
/// `TextStyle(…)` mit eigenem `color`, `backgroundColor` oder
/// `decorationColor`. Aus `design/1.1` übernommen.
List<(int, String)> findFixedColors(String source) {
  final code = stripComments(source);
  final offsets = <int>[
    for (final m in _colorsRegex.allMatches(code)) m.start,
    for (final m in _colorCtorRegex.allMatches(code)) m.start,
  ];
  for (final match in RegExp(r'\bTextStyle\(').allMatches(code)) {
    var depth = 0;
    var end = match.end - 1;
    for (; end < code.length; end++) {
      if (code[end] == '(') depth++;
      if (code[end] == ')' && --depth == 0) break;
    }
    // Nur Argumente der obersten Ebene zählen, nicht verschachtelte Aufrufe.
    final topLevel = code.substring(match.end, end).replaceAll(RegExp(r'\([^()]*\)'), '()');
    if (_styleColorArg.hasMatch(topLevel)) offsets.add(match.start);
  }
  return _hits(code, offsets);
}

/// AT-14: Material-Bausteine, für die es eine Design-Komponente gibt
/// (Ersatz in docs/design/components.md).
const designReplacedWidgets = [
  'Scaffold', 'AppBar', 'SliverAppBar', 'FloatingActionButton', //
  'ElevatedButton', 'FilledButton', 'OutlinedButton', 'TextButton', 'IconButton',
  'PopupMenuButton', 'PopupMenuItem', 'ListTile', 'Card',
  'Chip', 'ChoiceChip', 'ActionChip', 'FilterChip', 'InputChip',
  'TextField', 'TextFormField', 'InputDecoration', 'DropdownButton', 'DropdownButtonFormField', 'DropdownMenuItem',
  'AlertDialog', 'SimpleDialog', 'SimpleDialogOption', 'SnackBar', 'SnackBarAction',
  'CircularProgressIndicator', 'LinearProgressIndicator', 'Divider', 'VerticalDivider',
  'Dismissible', 'ReorderableListView', 'ListView', 'Table', 'TableRow', 'DataTable',
  'NavigationBar', 'NavigationDestination', 'NavigationRail', 'SelectableText',
  'Icon', 'Container', 'DecoratedBox', 'ColoredBox', 'Padding',
];

/// AT-14: Aufrufe und Stil-Angaben, die in Bildschirmen nichts zu suchen
/// haben (Antwort F1: streng).
final designForbiddenPatterns = <String, RegExp>{
  'showDialog': RegExp(r'\bshowDialog\s*[<(]'),
  'showAboutDialog': RegExp(r'\bshowAboutDialog\s*\('),
  'ScaffoldMessenger': RegExp(r'\bScaffoldMessenger\s*\.'),
  'showSnackBar': RegExp(r'\.showSnackBar\s*\('),
  'Icons.': RegExp(r'\bIcons\.'),
  'Theme.of': RegExp(r'\bTheme\.of\s*\('),
  'TextStyle': RegExp(r'\bTextStyle\s*\('),
  'FontWeight.': RegExp(r'\bFontWeight\.'),
  'EdgeInsets.': RegExp(r'\bEdgeInsets\w*\.'),
  'BorderRadius.': RegExp(r'\bBorderRadius\.'),
  'SizedBox mit Zahl': RegExp(r'\bSizedBox(\.\w+)?\s*\([^)]*\b(width|height|dimension)\s*:\s*([\d.]|double\.)'),
};

final _widgetRegex = RegExp('\\b(${designReplacedWidgets.join('|')})\\s*(<[^>()]*>)?\\s*[.(]');

/// AT-14: Fundstellen in [source] als (Zeile, Text).
List<(int, String)> findDesignViolations(String source) {
  final code = stripComments(source);
  return _hits(code, [
    for (final m in _widgetRegex.allMatches(code)) m.start,
    for (final pattern in designForbiddenPatterns.values)
      for (final m in pattern.allMatches(code)) m.start,
  ]);
}
