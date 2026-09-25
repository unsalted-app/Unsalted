import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:unsalted_core/src/data/converters/decimal_converter.dart';

void main() {
  group('DecimalConverter (MG-04)', () {
    const converter = DecimalConverter();

    test('einfacher Wert bleibt exakt erhalten', () {
      final value = Decimal.parse('12.5');
      final sql = converter.toSql(value);
      expect(sql, isA<String>());
      expect(converter.fromSql(sql), value);
    });

    test('toSql liefert niemals eine Zahl, sondern immer einen String', () {
      final sql = converter.toSql(Decimal.parse('600'));
      expect(sql, '600');
      expect(sql, isA<String>());
    });

    test('sehr kleiner Wert bleibt exakt erhalten', () {
      final value = Decimal.parse('0.000000001');
      expect(converter.fromSql(converter.toSql(value)), value);
    });

    test('sehr großer Wert bleibt exakt erhalten', () {
      final value = Decimal.parse('999999999999.99');
      expect(converter.fromSql(converter.toSql(value)), value);
    });

    test('negativer Wert bleibt exakt erhalten', () {
      final value = Decimal.parse('-3.14');
      expect(converter.fromSql(converter.toSql(value)), value);
    });

    test('Null-Wert bleibt exakt erhalten', () {
      final value = Decimal.zero;
      expect(converter.fromSql(converter.toSql(value)), value);
    });

    test('viele Nachkommastellen bleiben exakt erhalten', () {
      final value = Decimal.parse('0.123456789012345');
      expect(converter.fromSql(converter.toSql(value)), value);
    });
  });
}