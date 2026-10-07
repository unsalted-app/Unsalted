// test/architecture/at14_design_components_only_test.dart
//
// AT-14 (Teil 1.2, Kapitel 28.9): Bildschirme legen nur fest, was angezeigt
// wird. `lib/src/ui/` verwendet keine Material-Bausteine, für die es eine
// Komponente in `unsalted_design` gibt, und keine Stil-Angaben (`Icons.`,
// `Theme.of(`, `TextStyle(`, `FontWeight.`, `EdgeInsets…`, `BorderRadius.`,
// `SizedBox` mit Zahl) — Antwort F1 „streng“. Liste und Muster in
// `support/ui_rules.dart`. Dateien der Übergangsliste sind bis C27
// ausgenommen; steht eine Datei ohne Verstoß darauf, ist sie zu streichen.

import 'dart:io';

import 'package:test/test.dart';

import 'support/architecture_test_utils.dart';
import 'support/design_transition.dart';
import 'support/ui_rules.dart';

void main() {
  final root = findProjectRoot();
  final libDir = findPackageLibDir();
  final uiFiles = allDartFiles(Directory('${libDir.path}/src/ui')).toList();
  String projectPath(File f) => f.path.substring(root.path.length + 1).replaceAll(Platform.pathSeparator, '/');

  test('AT-14: lib/src/ui/ verwendet nur Design-Komponenten', () {
    expect(uiFiles, isNotEmpty);
    final violations = <String>[];
    for (final file in uiFiles) {
      final path = projectPath(file);
      if (designTransitionList.contains(path)) continue;
      for (final (line, text) in findDesignViolations(file.readAsStringSync())) {
        violations.add('$path:$line → $text');
      }
    }
    expect(violations, isEmpty, reason: 'Material-Bausteine oder Stil-Angaben:\n${violations.join('\n')}');
  });

  test('AT-14: die Übergangsliste enthält nur nicht umgestellte Dateien', () {
    final byPath = {for (final f in uiFiles) projectPath(f): f};
    final unknown = designTransitionList.where((p) => !byPath.containsKey(p)).toList();
    expect(unknown, isEmpty, reason: 'Dateien auf der Übergangsliste gibt es nicht: $unknown');
    final clean = [
      for (final path in designTransitionList)
        if (byPath[path] case final file?)
          if (findDesignViolations(file.readAsStringSync()).isEmpty && findFixedColors(file.readAsStringSync()).isEmpty)
            path,
    ];
    expect(clean, isEmpty, reason: 'Umgestellt, bitte von der Übergangsliste streichen: $clean');
  });

  test('AT-14: der Detektor erkennt Verstöße', () {
    for (final source in [
      'return Scaffold(body: x);',
      'ElevatedButton(onPressed: f, child: c)',
      'TextButton.icon(onPressed: f, icon: i, label: l)',
      'PopupMenuButton<VoidCallback>(itemBuilder: b)',
      'DropdownButton<String>(value: v)',
      'const Divider(height: 32)',
      'ListView.builder(itemCount: 1)',
      'const Icon(Icons.add)',
      'Padding(padding: p, child: c)',
      'Container(color: c)',
      'showDialog<bool>(context: context)',
      'ScaffoldMessenger.of(context)',
      'Theme.of(context).colorScheme',
      'const TextStyle(fontWeight: x)',
      'style: s.copyWith(fontWeight: FontWeight.bold)',
      'const EdgeInsets.all(16)',
      'BorderRadius.circular(8)',
      'const SizedBox(height: 8)',
      'SizedBox(width: double.infinity, child: c)',
      'SizedBox.square(dimension: 20)',
    ]) {
      expect(findDesignViolations(source), hasLength(1), reason: source);
    }
    for (final source in [
      'return AppPage(body: x);',
      'AppButton.primary(label: l, onPressed: f)',
      'const AppDivider(space: AppSpace.xxl)',
      'RecipeCard(recipe: r)',
      'AppKeyValueTable(headers: h, rows: r)',
      'const AppIcon(AppIcons.add)',
      'AppPadding.all(AppSpace.l, child: c)',
      'const SizedBox.shrink()',
      'final IconData icon = action.icon;',
      'Navigator.of(context).push(MaterialPageRoute<void>(builder: b))',
      'RecipeActionPlacement.appBar',
      '// Scaffold( nur im Kommentar',
    ]) {
      expect(findDesignViolations(source), isEmpty, reason: source);
    }
  });
}
