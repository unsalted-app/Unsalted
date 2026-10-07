// lib/src/ui/settings/export_screen.dart
//
// Bildschirm 11 (Kapitel 22, Schritt 8.7): JSON-Export. Auswahl
// beschränkt auf Versionen mit state = snapshot (Kapitel 13.7:
// exportVersionAsJsonString wirft IllegalStateException auf Drafts --
// diese Datei filtert die Auswahl deshalb bereits vorher, statt den
// Fehlerfall provozieren zu lassen). "In Zwischenablage kopieren" nutzt
// das eingebaute Clipboard-API; ein nativer Teilen-Dialog bräuchte ein
// zusätzliches Paket (z. B. share_plus), das pubspec.yaml ändern würde --
// außerhalb des Dateiscopes dieses Schritts (nur lib/src/ui/settings/*).
// Seit Teil 1.2 (C18) aus Design-Komponenten: FormPageTemplate mit festen
// Abschnitten unter sections/.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../providers/core_providers.dart';
import 'sections/export_result_section.dart';
import 'sections/export_selection_section.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _selectedRecipeId;
  String? _selectedVersionId;
  String? _exportedJson;
  String? _error;

  Future<void> _export() async {
    setState(() {
      _error = null;
      _exportedJson = null;
    });
    try {
      final json =
          await ref.read(snapshotServiceProvider).exportVersionAsJsonString(_selectedVersionId!);
      setState(() => _exportedJson = json);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _exportedJson!));
    if (!mounted) return;
    showAppMessage(context, 'In Zwischenablage kopiert.');
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepositoryProvider);

    return FormPageTemplate(
      title: 'Export',
      body: FormSections.fixed(
        children: [
          ExportSelectionSection(
            recipes: repo.watchRecipes(),
            versions: _selectedRecipeId == null ? null : repo.watchVersions(_selectedRecipeId!),
            selectedRecipeId: _selectedRecipeId,
            selectedVersionId: _selectedVersionId,
            onRecipeSelected: (id) => setState(() {
              _selectedRecipeId = id;
              _selectedVersionId = null;
              _exportedJson = null;
            }),
            onVersionSelected: (id) => setState(() {
              _selectedVersionId = id;
              _exportedJson = null;
            }),
          ),
          const AppGap(AppSpace.l),
          AppButton.primary(label: 'Exportieren', onPressed: _selectedVersionId == null ? null : _export),
          if (_error != null) AppPadding.only(top: AppSpace.s, child: AppText(_error!, tone: AppTone.error)),
          if (_exportedJson != null)
            Expanded(child: ExportResultSection(json: _exportedJson!, onCopy: _copyToClipboard)),
        ],
      ),
    );
  }
}
