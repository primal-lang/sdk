@Tags(['compiler'])
library;

import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:test/test.dart';

void main() {
  group('Lexeme', () {
    test('add() appends character value correctly', () {
      const lexeme = Lexeme(
        value: 'abc',
        location: Location(row: 1, column: 1),
      );

      final result = lexeme.add('d');

      expect(result.value, equals('abcd'));
    });

    test('add() preserves original location', () {
      const originalLocation = Location(row: 5, column: 10);
      const lexeme = Lexeme(
        value: 'hello',
        location: originalLocation,
      );

      final result = lexeme.add('!');

      expect(result.location, equals(originalLocation));
    });

    test('chaining multiple add() calls', () {
      const lexeme = Lexeme(
        value: '',
        location: Location(row: 1, column: 1),
      );

      final result = lexeme.add('a').add('b').add('c');

      expect(result.value, equals('abc'));
    });

    test('add() returns new immutable Lexeme', () {
      const original = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );

      final modified = original.add('!');

      expect(original.value, equals('test'));
      expect(modified.value, equals('test!'));
      expect(identical(original, modified), isFalse);
    });

    test('add() with empty string', () {
      const lexeme = Lexeme(
        value: 'hello',
        location: Location(row: 1, column: 1),
      );

      final result = lexeme.add('');

      expect(result.value, equals('hello'));
    });

    test('add() with multi-character string', () {
      const lexeme = Lexeme(
        value: 'pre',
        location: Location(row: 1, column: 1),
      );

      final result = lexeme.add('fix');

      expect(result.value, equals('prefix'));
    });

    test('equality', () {
      const lexeme1 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      const lexeme2 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      const lexeme3 = Lexeme(
        value: 'test',
        location: Location(row: 2, column: 1),
      );

      expect(lexeme1, equals(lexeme2));
      expect(lexeme1, isNot(equals(lexeme3)));
    });

    test('hashCode is consistent with equality', () {
      const lexeme1 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      const lexeme2 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );

      expect(lexeme1.hashCode, equals(lexeme2.hashCode));
    });

    test('toString() format', () {
      const lexeme = Lexeme(
        value: 'hello',
        location: Location(row: 3, column: 7),
      );

      expect(lexeme.toString(), equals('"hello" at [3, 7]'));
    });
  });
}
