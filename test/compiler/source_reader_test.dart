@Tags(['compiler'])
library;

import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/reader/character.dart';
import 'package:primal/compiler/reader/source_reader.dart';
import 'package:test/test.dart';

void main() {
  group('SourceReader', () {
    test('Empty input returns empty list', () {
      final List<Character> result = const SourceReader('').analyze();
      expect(result.length, equals(0));
    });

    test('Single character has correct value and location', () {
      final List<Character> result = const SourceReader('a').analyze();
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
    });

    test('Multiple characters on one line have incrementing columns', () {
      final List<Character> result = const SourceReader('abc').analyze();
      expect(result[0].value, equals('a'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('b'));
      expect(result[1].location.column, equals(2));
      expect(result[2].value, equals('c'));
      expect(result[2].location.column, equals(3));
      // All on row 1
      for (int i = 0; i < 3; i++) {
        expect(result[i].location.row, equals(1));
      }
    });

    test('Multiline input increments rows on newlines', () {
      final List<Character> result = const SourceReader('a\nb').analyze();
      // 'a' at row 1, col 1
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
      // trailing \n for row 1
      expect(result[1].value, equals('\n'));
      expect(result[1].location.row, equals(1));
      // 'b' at row 2, col 1
      expect(result[2].value, equals('b'));
      expect(result[2].location.row, equals(2));
      expect(result[2].location.column, equals(1));
    });

    test('Shebang line is skipped', () {
      final List<Character> result = const SourceReader(
        '#!/usr/bin/env primal\nmain = 42',
      ).analyze();
      // First character should be from the second line
      expect(result[0].value, equals('m'));
      expect(result[0].location.row, equals(2));
      expect(result[0].location.column, equals(1));
    });

    test('Shebang only skips first line', () {
      final List<Character> result = const SourceReader(
        'main = 1\n#!/usr/bin/env primal',
      ).analyze();
      // First line is processed normally
      expect(result[0].value, equals('m'));
      expect(result[0].location.row, equals(1));
      // Second line starting with #! is NOT skipped
      final List<Character> row2Chars = result
          .where((c) => c.location.row == 2 && c.value != '\n')
          .toList();
      expect(row2Chars[0].value, equals('#'));
      expect(row2Chars[1].value, equals('!'));
    });

    test('Tabs and spaces are preserved as characters', () {
      final List<Character> result = const SourceReader('\t ').analyze();
      expect(result[0].value, equals('\t'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals(' '));
      expect(result[1].location.row, equals(1));
      expect(result[1].location.column, equals(2));
    });

    test('Whitespace characters are handled', () {
      // \r is normalized to \n, splitting into two rows
      final List<Character> result = const SourceReader('\r\t ').analyze();
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(1));
      expect(result[1].value, equals('\t'));
      expect(result[1].location.row, equals(2));
      expect(result[2].value, equals(' '));
      expect(result[2].location.row, equals(2));
    });

    test('Unicode characters are handled', () {
      final List<Character> result = const SourceReader(
        '\u00e9\u00f1',
      ).analyze();
      expect(result[0].value, equals('\u00e9'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('\u00f1'));
      expect(result[1].location.column, equals(2));
    });

    test('Mixed content tracks locations correctly', () {
      final List<Character> result = const SourceReader('a1+').analyze();
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('1'));
      expect(result[1].location.row, equals(1));
      expect(result[1].location.column, equals(2));
      expect(result[2].value, equals('+'));
      expect(result[2].location.row, equals(1));
      expect(result[2].location.column, equals(3));
    });

    test('Grapheme clusters are single characters', () {
      final List<Character> result = const SourceReader('a👨‍👩‍👧b').analyze();
      expect(result[0].value, equals('a'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('👨‍👩‍👧'));
      expect(result[1].location.column, equals(2));
      expect(result[2].value, equals('b'));
      expect(result[2].location.column, equals(3));
    });

    test('Each row gets a trailing newline character', () {
      final List<Character> result = const SourceReader('ab\ncd').analyze();
      // Row 1: 'a', 'b', '\n' (trailing)
      // Row 2: 'c', 'd', '\n' (trailing)
      expect(result.length, equals(6));
      expect(result[2].value, equals('\n'));
      expect(result[2].location.row, equals(1));
      expect(result[2].location.column, equals(3));
      expect(result[5].value, equals('\n'));
      expect(result[5].location.row, equals(2));
      expect(result[5].location.column, equals(3));
    });

    test('Windows line endings are normalized to newlines', () {
      final List<Character> result = const SourceReader('a\r\nb').analyze();
      // 'a' at row 1, col 1
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
      // trailing \n for row 1
      expect(result[1].value, equals('\n'));
      expect(result[1].location.row, equals(1));
      // 'b' at row 2, col 1
      expect(result[2].value, equals('b'));
      expect(result[2].location.row, equals(2));
      expect(result[2].location.column, equals(1));
    });

    test('Trailing newline in source is handled correctly', () {
      final List<Character> result = const SourceReader('a\n').analyze();
      // Should have 'a' and trailing '\n' for row 1
      expect(result.length, equals(2));
      expect(result[0].value, equals('a'));
      expect(result[1].value, equals('\n'));
      expect(result[1].location.row, equals(1));
    });

    test('Multiple consecutive newlines create multiple rows', () {
      final List<Character> result = const SourceReader('a\n\nb').analyze();
      // Row 1: 'a', '\n'
      // Row 2: '\n' (empty row still gets trailing newline)
      // Row 3: 'b', '\n'
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[1].value, equals('\n'));
      expect(result[1].location.row, equals(1));
      expect(result[2].value, equals('\n'));
      expect(result[2].location.row, equals(2));
      expect(result[2].location.column, equals(1));
      expect(result[3].value, equals('b'));
      expect(result[3].location.row, equals(3));
    });

    test('Only newline character as input returns trailing newline', () {
      final List<Character> result = const SourceReader('\n').analyze();
      // Split produces ['', ''], last empty removed, leaving ['']
      // Empty row still gets a trailing newline
      expect(result.length, equals(1));
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
    });

    test('Only whitespace input preserves spaces', () {
      final List<Character> result = const SourceReader('   ').analyze();
      expect(result.length, equals(4)); // 3 spaces + trailing newline
      expect(result[0].value, equals(' '));
      expect(result[1].value, equals(' '));
      expect(result[2].value, equals(' '));
      expect(result[3].value, equals('\n'));
    });

    test('Shebang only input returns empty list', () {
      final List<Character> result = const SourceReader(
        '#!/usr/bin/env primal',
      ).analyze();
      expect(result.length, equals(0));
    });

    test('Shebang with trailing newline returns empty list', () {
      final List<Character> result = const SourceReader(
        '#!/usr/bin/env primal\n',
      ).analyze();
      expect(result.length, equals(0));
    });

    test('Empty lines between content are preserved', () {
      final List<Character> result = const SourceReader('a\n\n\nb').analyze();
      // Row 1: 'a', '\n'
      // Row 2: '\n' (empty)
      // Row 3: '\n' (empty)
      // Row 4: 'b', '\n'
      expect(result.length, equals(6));
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[2].value, equals('\n'));
      expect(result[2].location.row, equals(2));
      expect(result[3].value, equals('\n'));
      expect(result[3].location.row, equals(3));
      expect(result[4].value, equals('b'));
      expect(result[4].location.row, equals(4));
    });

    test('Mixed Windows and Unix line endings are normalized', () {
      final List<Character> result = const SourceReader(
        'a\r\nb\nc\rd',
      ).analyze();
      // All line endings should become \n
      final List<Character> newlines = result
          .where((Character c) => c.value == '\n')
          .toList();
      expect(newlines.length, equals(4)); // 4 rows = 4 trailing newlines
    });
  });

  group('Character', () {
    test('Equality compares value and location', () {
      const Character character1 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character3 = Character(
        value: 'b',
        location: Location(row: 1, column: 1),
      );
      const Character character4 = Character(
        value: 'a',
        location: Location(row: 2, column: 1),
      );
      expect(character1, equals(character2));
      expect(character1, isNot(equals(character3)));
      expect(character1, isNot(equals(character4)));
    });

    test('Identical instances are equal', () {
      const Character character = Character(
        value: 'x',
        location: Location(row: 1, column: 1),
      );
      expect(character == character, isTrue);
    });

    test('Not equal to non-Character objects', () {
      const Character character = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      // Use dynamic to test the equality operator with different types
      expect(character == ('a' as dynamic), isFalse);
      expect(character == (1 as dynamic), isFalse);
      expect(character == (null as dynamic), isFalse);
    });

    test('hashCode is consistent with equality', () {
      const Character character1 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      expect(character1.hashCode, equals(character2.hashCode));
    });

    test('toString returns value and location', () {
      const Character character = Character(
        value: 'a',
        location: Location(row: 1, column: 2),
      );
      expect(character.toString(), equals('"a" at [1, 2]'));
    });

    test('toString handles special characters', () {
      const Character newlineCharacter = Character(
        value: '\n',
        location: Location(row: 1, column: 1),
      );
      expect(newlineCharacter.toString(), contains('\n'));

      const Character tabCharacter = Character(
        value: '\t',
        location: Location(row: 1, column: 1),
      );
      expect(tabCharacter.toString(), contains('\t'));
    });
  });
}
