// lib/src/ui/settings/import_screen.dart
//
// Bildschirm 12 (Kapitel 22, Schritt 8.7): JSON-Import mit Vorschau vor
// dem Schreiben. Die Vorschau nutzt SnapshotCodec.decode -- denselben
// Codec, den SnapshotService.importJsonString intern verwendet (Kapitel
// 13) --, keine eigene JSON-Strukturinterpretation darüber hinaus. Der
// eigentliche Import läuft über importJsonString mit dem unveränderten
// Original-Text, damit unbekannte Felder wie vom Snapshot-Contract
// vorgesehen erhalten bleiben (Kapitel 13.6, GD-12). Datei-Auswahl bräuchte
// ein zusätzliches Paket (z. B. file_picker) -- außerhalb des
// Dateiscopes dieses Schritts, deshalb nur Text einfügen. Seit Teil 1.2
// (C19) aus Design-Komponenten: FormPageTemplate mit festen Abschnitten unter
// sections/.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unsalted_design/unsalted_design.dart';

import '../../contracts/core_exceptions.dart';
import '../../providers/core_providers.dart';
import '../../recipe/recipe_snapshot_v1.dart';
import '../../recipe/snapshot_codec.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import 'sections/import_input_section.dart';
import 'sections/import_preview_section.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _textController = TextEditingController();
  RecipeSnapshotV1? _preview;
  String? _previewError;
  bool _importing = false;
  String? _importError;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updatePreview(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _preview = null;
        _previewError = null;
      });
      return;
    }
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      final decoded = SnapshotCodec.decode(map);
      setState(() {
        _preview = decoded;
        _previewError = null;
      });
    } on ImportFormatException catch (e) {
      setState(() {
        _preview = null;
        _previewError = e.message;
      });
    } on ImportVersionException catch (e) {
      setState(() {
        _preview = null;
        _previewError = e.message;
      });
    } on FormatException {
      setState(() {
        _preview = null;
        _previewError = 'Ungültiges JSON.';
      });
    }
  }

  Future<void> _import() async {
    setState(() {
      _importing = true;
      _importError = null;
    });
    try {
      final recipeId =
          await ref.read(snapshotServiceProvider).importJsonString(_textController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => RecipeDetailScreen(recipeId: recipeId),
      ));
    } on ImportFormatException catch (e) {
      setState(() => _importError = e.message);
    } on ImportVersionException catch (e) {
      setState(() => _importError = e.message);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;

    return FormPageTemplate(
      title: 'Import',
      body: FormSections.fixed(
        children: [
          Expanded(child: ImportInputSection(controller: _textController, onChanged: _updatePreview)),
          if (_previewError != null)
            AppPadding.only(top: AppSpace.s, child: AppText(_previewError!, tone: AppTone.error)),
          if (preview != null) AppPadding.only(top: AppSpace.s, child: ImportPreviewSection(preview: preview)),
          if (_importError != null)
            AppPadding.only(top: AppSpace.s, child: AppText(_importError!, tone: AppTone.error)),
          AppPadding.only(
            top: AppSpace.l,
            child: AppButton.primary(
              label: 'Importieren',
              onPressed: (preview == null || _importing) ? null : _import,
            ),
          ),
        ],
      ),
    );
  }
}
