import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:unsalted_core/src/contracts/core_exceptions.dart';
import 'package:unsalted_core/src/recipe/snapshot_codec.dart';

/// Golden-Tests für das Snapshot-Format v1 (Kapitel 13, Schritt 4.2).
///
/// Hinweis zu GD-05: Die Spezifikation verlangt ein "byteweise identisches"
/// Ergebnis beim erneuten Kodieren. Hier wird das über den Vergleich der
/// jsonEncode()-Ausgabe von Original und Rundreise geprüft (beide durchlaufen
/// denselben Encoder mit fester Schlüsselreihenfolge) statt über einen
/// Byte-Vergleich mit der handgeschriebenen Golden-Datei — deren exakte
/// Einrückung sich sonst bei jeder Formatierungsänderung der Golden-Datei
/// verschieben würde, ohne dass sich am Codec etwas ändert. Das prüft
/// denselben Sachverhalt (keine Datenverluste, deterministisches Encoding)
/// robuster gegen harmlose Whitespace-Unterschiede in der Testdatei.

Map<String, dynamic> _loadGolden(String name) {
  final file = File('test/contract/golden/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('SnapshotCodec — Golden-Dateien', () {
    test('GD-01 minimal: Rundreise verlustfrei', () {
      final json = _loadGolden('gd01_minimal.json');
      final decoded = SnapshotCodec.decode(json);
      final reEncoded = SnapshotCodec.encode(decoded);
      expect(jsonEncode(reEncoded), jsonEncode(json));
    });

    test('GD-02 voll: alle Felder gesetzt, Rundreise verlustfrei', () {
      final json = _loadGolden('gd02_full.json');
      final decoded = SnapshotCodec.decode(json);

      expect(decoded.recipe.description, 'Klassischer Teig, kalt geführt.');
      expect(decoded.version.parentVersionId, isNotNull);
      expect(decoded.ingredients, hasLength(2));
      expect(decoded.ingredients[1].densityGPerMl.toString(), '0.91');
      expect(decoded.steps, hasLength(2));
      expect(decoded.steps[1].timerSeconds, isNull);

      final reEncoded = SnapshotCodec.encode(decoded);
      expect(jsonEncode(reEncoded), jsonEncode(json));
    });

    test('GD-03 null-Nährwerte: Zutat ohne Variante bleibt null', () {
      final json = _loadGolden('gd03_null_nutrients.json');
      final decoded = SnapshotCodec.decode(json);

      expect(decoded.ingredients.single.per100g, isNull);
      expect(decoded.nutrition.total.energyKcal, isNull);
      expect(decoded.nutrition.incomplete, hasLength(8));

      final reEncoded = SnapshotCodec.encode(decoded);
      expect(jsonEncode(reEncoded), jsonEncode(json));
    });

    test('GD-04 extra: zusätzliche Nährwerte bleiben erhalten', () {
      final json = _loadGolden('gd04_extra.json');
      final decoded = SnapshotCodec.decode(json);

      final extra = decoded.ingredients.single.per100g!.extra;
      expect(extra['sodium_mg'].toString(), '20');
      expect(extra['vitamin_c_mg'].toString(), '12.5');

      final reEncoded = SnapshotCodec.encode(decoded);
      expect(jsonEncode(reEncoded), jsonEncode(json));
    });

    test('GD-05 deterministisch: zweimaliges Encoden liefert identisches JSON',
        () {
      final json = _loadGolden('gd02_full.json');
      final decoded = SnapshotCodec.decode(json);
      final first = jsonEncode(SnapshotCodec.encode(decoded));
      final second = jsonEncode(SnapshotCodec.encode(decoded));
      expect(first, second);
    });

    test('GD-06 unbekanntes Feld wird ignoriert', () {
      final json = _loadGolden('gd01_minimal.json');
      final withUnknown = Map<String, dynamic>.from(json)
        ..['unknown_top_level_field'] = 'sollte ignoriert werden';
      (withUnknown['recipe'] as Map<String, dynamic>)['unknown_recipe_field'] =
          42;

      final decoded = SnapshotCodec.decode(withUnknown);

      expect(decoded.recipe.id, 'r1');
      expect(decoded.ingredients, hasLength(1));
    });

    test('GD-07 höhere format_version wird abgelehnt', () {
      final json = _loadGolden('gd01_minimal.json');
      final future = Map<String, dynamic>.from(json)..['format_version'] = 2;

      expect(
        () => SnapshotCodec.decode(future),
        throwsA(isA<ImportVersionException>()),
      );
    });

    test('GD-08 falsches format wird abgelehnt', () {
      final json = _loadGolden('gd01_minimal.json');
      final wrong = Map<String, dynamic>.from(json)
        ..['format'] = 'irgendein_anderes_format';

      expect(
        () => SnapshotCodec.decode(wrong),
        throwsA(isA<ImportFormatException>()),
      );
    });

    test('GD-09 fehlendes Pflichtfeld wird abgelehnt', () {
      final json = _loadGolden('gd01_minimal.json');
      final broken = Map<String, dynamic>.from(json);
      final recipeCopy =
          Map<String, dynamic>.from(broken['recipe'] as Map<String, dynamic>)
            ..remove('title');
      broken['recipe'] = recipeCopy;

      expect(
        () => SnapshotCodec.decode(broken),
        throwsA(isA<ImportFormatException>()),
      );
    });

    test('GD-10 keine Dezimalwerte als JSON-Number', () {
      const decimalKeys = [
        'quantity',
        'grams',
        'baking_loss_percent',
        'final_weight_override_g',
        'density_g_per_ml',
        'grams_per_piece',
        'raw_weight_g',
        'final_weight_g',
        'energy_kcal',
        'fat_g',
        'saturated_fat_g',
        'carbs_g',
        'sugars_g',
        'fiber_g',
        'protein_g',
        'salt_g',
      ];

      for (final name in [
        'gd01_minimal.json',
        'gd02_full.json',
        'gd03_null_nutrients.json',
        'gd04_extra.json',
      ]) {
        final raw = File('test/contract/golden/$name').readAsStringSync();
        for (final key in decimalKeys) {
          final pattern = RegExp('"$key":\\s*-?[0-9]');
          expect(
            pattern.hasMatch(raw),
            isFalse,
            reason:
                '$name enthält "$key" als unquotierte JSON-Number statt als String.',
          );
        }
      }
    });
  });
}