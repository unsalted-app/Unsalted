// lib/src/components/icons/app_icons.dart
//
// Komponente (Teil 1.2): fachneutrale Symbolnamen (Figma `Icon/<name>`).
// Bildschirme verwenden nur diese Namen, nie `Icons.*` (AT-14); ein späteres
// eigenes Symbolset ändert nur diese Datei.

import 'package:flutter/material.dart';

/// Symbole der App.
abstract final class AppIcons {
  /// `Icon/add` — hinzufügen, neu anlegen.
  static const IconData add = Icons.add;

  /// `Icon/check` — bestätigen, speichern.
  static const IconData check = Icons.check;

  /// `Icon/search` — suchen.
  static const IconData search = Icons.search;

  /// `Icon/edit` — bearbeiten.
  static const IconData edit = Icons.edit;

  /// `Icon/history` — Verlauf.
  static const IconData history = Icons.history;

  /// `Icon/delete` — löschen (gefüllt).
  static const IconData delete = Icons.delete;

  /// `Icon/delete-outline` — entfernen.
  static const IconData deleteOutline = Icons.delete_outline;

  /// `Icon/copy` — kopieren.
  static const IconData copy = Icons.copy;

  /// `Icon/compare` — vergleichen.
  static const IconData compare = Icons.compare_arrows;

  /// `Icon/star` — markiert.
  static const IconData star = Icons.star;

  /// `Icon/star-outline` — markieren.
  static const IconData starOutline = Icons.star_outline;

  /// `Icon/drag-handle` — Ziehgriff.
  static const IconData dragHandle = Icons.drag_handle;

  /// `Icon/info` — Hinweis.
  static const IconData info = Icons.info_outline;

  /// `Icon/warning` — Warnung.
  static const IconData warning = Icons.warning_amber_rounded;

  /// `Icon/error` — Fehler.
  static const IconData error = Icons.error_outline;

  /// `Icon/upload` — ausgeben, exportieren.
  static const IconData upload = Icons.upload;

  /// `Icon/download` — einlesen, importieren.
  static const IconData download = Icons.download;

  /// `Icon/book` — Sammlung, Liste von Einträgen.
  static const IconData book = Icons.menu_book;

  /// `Icon/restaurant` — Besteck, z. B. für einen Navigationsbereich.
  static const IconData restaurant = Icons.restaurant;

  /// `Icon/empty-plate` — leere Auswahl.
  static const IconData emptyPlate = Icons.no_food;

  /// `Icon/settings` — Einstellungen.
  static const IconData settings = Icons.settings;

  /// Alle Symbole mit ihrem Figma-Namen.
  static const byFigmaName = {
    'Icon/add': add,
    'Icon/check': check,
    'Icon/search': search,
    'Icon/edit': edit,
    'Icon/history': history,
    'Icon/delete': delete,
    'Icon/delete-outline': deleteOutline,
    'Icon/copy': copy,
    'Icon/compare': compare,
    'Icon/star': star,
    'Icon/star-outline': starOutline,
    'Icon/drag-handle': dragHandle,
    'Icon/info': info,
    'Icon/warning': warning,
    'Icon/error': error,
    'Icon/upload': upload,
    'Icon/download': download,
    'Icon/book': book,
    'Icon/restaurant': restaurant,
    'Icon/empty-plate': emptyPlate,
    'Icon/settings': settings,
  };
}
