// lib/src/components/icons/app_icons.dart
//
// Komponente (Teil 1.2): fachneutrale Symbolnamen (Figma `Icon/<name>`).
// Bildschirme verwenden nur diese Namen, nie `Icons.*` (AT-14); ein späteres
// eigenes Symbolset ändert nur diese Datei.
//
// Seit Teil 1.3 (D05b): die Outlined-Varianten der mitgelieferten Material
// Icons, bis das eigene Linienset steht (docs/design/system/README.md,
// „Symbole und Bilder“; UEBERGABE Punkt 4), und alle 32 Namen der
// Figma-Bibliothek (docs/design/figma/figma-ids.json). `star` bleibt gefüllt:
// Es ist das Gegenstück zu `star-outline` (markiert/markieren).

import 'package:flutter/material.dart';

/// Symbole der App.
abstract final class AppIcons {
  /// `Icon/add` — hinzufügen, neu anlegen.
  static const IconData add = Icons.add_outlined;

  /// `Icon/check` — bestätigen, speichern.
  static const IconData check = Icons.check_outlined;

  /// `Icon/search` — suchen.
  static const IconData search = Icons.search_outlined;

  /// `Icon/edit` — bearbeiten.
  static const IconData edit = Icons.edit_outlined;

  /// `Icon/history` — Verlauf.
  static const IconData history = Icons.history_outlined;

  /// `Icon/delete` — löschen.
  static const IconData delete = Icons.delete_outlined;

  /// `Icon/delete-outline` — entfernen.
  static const IconData deleteOutline = Icons.delete_outline;

  /// `Icon/copy` — kopieren.
  static const IconData copy = Icons.copy_outlined;

  /// `Icon/compare` — vergleichen.
  static const IconData compare = Icons.compare_arrows_outlined;

  /// `Icon/star` — markiert (gefüllt, Gegenstück zu [starOutline]).
  static const IconData star = Icons.star;

  /// `Icon/star-outline` — markieren.
  static const IconData starOutline = Icons.star_outline;

  /// `Icon/drag-handle` — Ziehgriff.
  static const IconData dragHandle = Icons.drag_handle_outlined;

  /// `Icon/info` — Hinweis.
  static const IconData info = Icons.info_outline;

  /// `Icon/warning` — Warnung.
  static const IconData warning = Icons.warning_amber_outlined;

  /// `Icon/error` — Fehler.
  static const IconData error = Icons.error_outline;

  /// `Icon/upload` — ausgeben, exportieren.
  static const IconData upload = Icons.upload_outlined;

  /// `Icon/download` — einlesen, importieren.
  static const IconData download = Icons.download_outlined;

  /// `Icon/book` — Sammlung, Liste von Einträgen.
  static const IconData book = Icons.menu_book_outlined;

  /// `Icon/restaurant` — Besteck, z. B. für einen Navigationsbereich.
  static const IconData restaurant = Icons.restaurant_outlined;

  /// `Icon/empty-plate` — leere Auswahl.
  static const IconData emptyPlate = Icons.no_food_outlined;

  /// `Icon/settings` — Einstellungen.
  static const IconData settings = Icons.settings_outlined;

  /// `Icon/timer` — Zeitangabe.
  static const IconData timer = Icons.timer_outlined;

  /// `Icon/arrow` — alt → neu (die Schrift hat keinen Pfeil).
  static const IconData arrow = Icons.arrow_forward_outlined;

  /// `Icon/back` — zurück.
  static const IconData back = Icons.arrow_back_outlined;

  /// `Icon/lock` — Siegel, fest.
  static const IconData lock = Icons.lock_outlined;

  /// `Icon/more` — weitere Aktionen.
  static const IconData more = Icons.more_vert_outlined;

  /// `Icon/close` — schließen.
  static const IconData close = Icons.close_outlined;

  /// `Icon/undo` — rückgängig.
  static const IconData undo = Icons.undo_outlined;

  /// `Icon/chevron` — aufklappen (Auswahlfeld).
  static const IconData chevron = Icons.expand_more_outlined;

  /// `Icon/link` — verknüpfen.
  static const IconData link = Icons.link_outlined;

  /// `Icon/photo` — Bild.
  static const IconData photo = Icons.photo_outlined;

  /// `Icon/swap` — tauschen.
  static const IconData swap = Icons.swap_horiz_outlined;

  /// Alle Symbole mit ihrem Figma-Namen (Reihenfolge wie in
  /// docs/design/figma/figma-ids.json).
  static const byFigmaName = {
    'Icon/add': add,
    'Icon/check': check,
    'Icon/info': info,
    'Icon/lock': lock,
    'Icon/error': error,
    'Icon/warning': warning,
    'Icon/arrow': arrow,
    'Icon/back': back,
    'Icon/search': search,
    'Icon/more': more,
    'Icon/book': book,
    'Icon/empty-plate': emptyPlate,
    'Icon/settings': settings,
    'Icon/timer': timer,
    'Icon/chevron': chevron,
    'Icon/delete': delete,
    'Icon/photo': photo,
    'Icon/drag-handle': dragHandle,
    'Icon/close': close,
    'Icon/link': link,
    'Icon/edit': edit,
    'Icon/history': history,
    'Icon/swap': swap,
    'Icon/restaurant': restaurant,
    'Icon/delete-outline': deleteOutline,
    'Icon/copy': copy,
    'Icon/compare': compare,
    'Icon/star': star,
    'Icon/star-outline': starOutline,
    'Icon/upload': upload,
    'Icon/download': download,
    'Icon/undo': undo,
  };
}
