import 'package:dry/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Syntactic Analyzer', () {
    test('isBoolean', () {
      expect(true, equals('true'.isBoolean));
      expect(true, equals('false'.isBoolean));
    });
  });
}
