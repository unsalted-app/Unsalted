// test/typography/support/cmap.dart
//
// Liest die Zeichentabelle (`cmap`) einer TrueType-Datei (Teil 1.3, D02,
// DS-49): welche Unicode-Zeichen die Schrift enthält. Unterstützt die
// Unicode-Untertabellen Format 4 (BMP) und 12 (voller Bereich); andere
// Formate kommen in den gebündelten Schriften nicht vor.

import 'dart:typed_data';

/// Alle Zeichen (Code Points) mit Glyphe in der Schrift [bytes].
Set<int> cmapCodePoints(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final numTables = data.getUint16(4);
  int? cmapOffset;
  for (var i = 0; i < numTables; i++) {
    final record = 12 + i * 16;
    final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
    if (tag == 'cmap') cmapOffset = data.getUint32(record + 8);
  }
  if (cmapOffset == null) throw StateError('Schrift ohne cmap-Tabelle');

  final result = <int>{};
  final subtables = data.getUint16(cmapOffset + 2);
  for (var i = 0; i < subtables; i++) {
    final platform = data.getUint16(cmapOffset + 4 + i * 8);
    final offset = cmapOffset + data.getUint32(cmapOffset + 4 + i * 8 + 4);
    if (platform != 0 && platform != 3) continue;
    switch (data.getUint16(offset)) {
      case 4:
        result.addAll(_format4(data, offset));
      case 12:
        result.addAll(_format12(data, offset));
    }
  }
  return result;
}

Iterable<int> _format4(ByteData data, int offset) sync* {
  final segments = data.getUint16(offset + 6) ~/ 2;
  final ends = offset + 14;
  final starts = ends + segments * 2 + 2;
  final deltas = starts + segments * 2;
  final rangeOffsets = deltas + segments * 2;
  for (var s = 0; s < segments; s++) {
    final start = data.getUint16(starts + s * 2);
    final end = data.getUint16(ends + s * 2);
    final delta = data.getInt16(deltas + s * 2);
    final rangeOffset = data.getUint16(rangeOffsets + s * 2);
    for (var c = start; c <= end && c != 0xFFFF; c++) {
      int glyph;
      if (rangeOffset == 0) {
        glyph = (c + delta) & 0xFFFF;
      } else {
        final at = rangeOffsets + s * 2 + rangeOffset + (c - start) * 2;
        glyph = data.getUint16(at);
        if (glyph != 0) glyph = (glyph + delta) & 0xFFFF;
      }
      if (glyph != 0) yield c;
    }
  }
}

Iterable<int> _format12(ByteData data, int offset) sync* {
  final groups = data.getUint32(offset + 12);
  for (var g = 0; g < groups; g++) {
    final group = offset + 16 + g * 12;
    final start = data.getUint32(group);
    final end = data.getUint32(group + 4);
    for (var c = start; c <= end; c++) {
      yield c;
    }
  }
}
