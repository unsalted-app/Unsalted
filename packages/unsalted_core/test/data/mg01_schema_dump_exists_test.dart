import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// MG-01 (Kapitel 23.4): Schema-Dump v1 existiert in drift_schemas/.
void main() {
  test('MG-01: Schema-Dump v1 existiert und ist gültiges JSON', () {
    final file = File('drift_schemas/drift_schema_v1.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'drift_schemas/drift_schema_v1.json fehlt. Erzeugen mit:\n'
          'dart run drift_dev schema dump '
          'lib/src/data/core_database.dart drift_schemas/',
    );

    final decoded =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['_meta'], isNotNull);
    expect(decoded['entities'], isA<List>());

    final entities = decoded['entities'] as List;
    final tableNames = entities
        .whereType<Map<String, dynamic>>()
        .where((e) => e['type'] == 'table')
        .map((e) => (e['data'] as Map<String, dynamic>)['name'] as String)
        .toSet();

    expect(
      tableNames,
      containsAll(<String>{
        'recipes',
        'recipe_versions',
        'recipe_ingredients',
        'recipe_steps',
        'food_variants',
      }),
      reason: 'Nicht alle fünf Tabellen aus Kapitel 11 im Schema-Dump gefunden.',
    );
  });
}