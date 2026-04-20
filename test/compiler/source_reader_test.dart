@Tags(['compiler'])
library;

import 'package:primal/compiler/models/located.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/reader/character.dart';
import 'package:primal/compiler/reader/source_reader.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    test('Equality compares row and column', () {
      const Location location1 = Location(row: 1, column: 2);
      const Location location2 = Location(row: 1, column: 2);
      const Location location3 = Location(row: 1, column: 3);
      const Location location4 = Location(row: 2, column: 2);
      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
      expect(location1, isNot(equals(location4)));
    });

    test('Identical instances are equal', () {
      const Location location = Location(row: 5, column: 10);
      expect(location == location, isTrue);
    });

    test('Not equal to non-Location objects', () {
      const Location location = Location(row: 1, column: 1);
      expect(location == ('1,1' as dynamic), isFalse);
      expect(location == (1 as dynamic), isFalse);
      expect(location == (null as dynamic), isFalse);
    });

    test('hashCode is consistent with equality', () {
      const Location location1 = Location(row: 3, column: 4);
      const Location location2 = Location(row: 3, column: 4);
      expect(location1.hashCode, equals(location2.hashCode));
    });

    test('hashCode differs for different locations', () {
      const Location location1 = Location(row: 1, column: 1);
      const Location location2 = Location(row: 1, column: 2);
      const Location location3 = Location(row: 2, column: 1);
      // Different locations should have different hashCodes (not guaranteed but likely)
      expect(
        location1.hashCode != location2.hashCode ||
            location1.hashCode != location3.hashCode,
        isTrue,
      );
    });

    test('toString returns row and column in brackets', () {
      const Location location = Location(row: 5, column: 10);
      expect(location.toString(), equals('[5, 10]'));
    });

    test('toString handles single digit positions', () {
      const Location location = Location(row: 1, column: 1);
      expect(location.toString(), equals('[1, 1]'));
    });

    test('toString handles large positions', () {
      const Location location = Location(row: 999, column: 1000);
      expect(location.toString(), equals('[999, 1000]'));
    });
  });

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
        '#!/usr/bin/env primal\nmain() = 42',
      ).analyze();
      // First character should be from the second line
      expect(result[0].value, equals('m'));
      expect(result[0].location.row, equals(2));
      expect(result[0].location.column, equals(1));
    });

    test('Shebang only skips first line', () {
      final List<Character> result = const SourceReader(
        'main() = 1\n#!/usr/bin/env primal',
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

    test('Shebang followed by empty lines returns empty characters', () {
      final List<Character> result = const SourceReader(
        '#!/usr/bin/env primal\n\n',
      ).analyze();
      // Shebang line is skipped, remaining is one empty line
      expect(result.length, equals(1));
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(2));
    });

    test('Very long line tracks columns correctly', () {
      final String longLine = 'a' * 100;
      final List<Character> result = SourceReader(longLine).analyze();
      // 100 characters + trailing newline
      expect(result.length, equals(101));
      expect(result[0].location.column, equals(1));
      expect(result[49].location.column, equals(50));
      expect(result[99].location.column, equals(100));
      expect(result[100].value, equals('\n'));
      expect(result[100].location.column, equals(101));
    });

    test('Multiple shebang-like lines only skip first', () {
      final List<Character> result = const SourceReader(
        '#!first\n#!second',
      ).analyze();
      // First line skipped, second line starting with #! is kept
      expect(result[0].value, equals('#'));
      expect(result[0].location.row, equals(2));
      expect(result[1].value, equals('!'));
    });

    test('Carriage return only input is normalized', () {
      final List<Character> result = const SourceReader('\r').analyze();
      expect(result.length, equals(1));
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(1));
    });

    test('Multiple carriage returns are each normalized', () {
      final List<Character> result = const SourceReader('\r\r').analyze();
      expect(result.length, equals(2));
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(1));
      expect(result[1].value, equals('\n'));
      expect(result[1].location.row, equals(2));
    });

    test('Input preserves all special ASCII characters', () {
      final List<Character> result = const SourceReader('!@#\$%^&*').analyze();
      expect(result[0].value, equals('!'));
      expect(result[1].value, equals('@'));
      expect(result[2].value, equals('#'));
      expect(result[3].value, equals('\$'));
      expect(result[4].value, equals('%'));
      expect(result[5].value, equals('^'));
      expect(result[6].value, equals('&'));
      expect(result[7].value, equals('*'));
    });

    test('Combining characters are grouped with base character', () {
      // e followed by combining acute accent (U+0301) forms é
      final List<Character> result = const SourceReader('e\u0301x').analyze();
      // Should be 2 grapheme clusters (é and x) + trailing newline
      expect(result.length, equals(3));
      expect(result[0].value, equals('e\u0301'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('x'));
      expect(result[1].location.column, equals(2));
    });

    test('Zero-width joiner joins with preceding character', () {
      // ZWJ (U+200D) joins with the preceding character in grapheme clustering
      final List<Character> result = const SourceReader('a\u200Db').analyze();
      // 'a' + ZWJ forms one grapheme cluster, 'b' is another, plus trailing newline
      expect(result.length, equals(3));
      expect(result[0].value, equals('a\u200D'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('b'));
      expect(result[1].location.column, equals(2));
    });

    test('Empty string after shebang with multiple empty lines', () {
      final List<Character> result = const SourceReader(
        '#!/bin/sh\n\n\n',
      ).analyze();
      // Shebang skipped, two empty lines remain
      expect(result.length, equals(2));
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(2));
      expect(result[1].value, equals('\n'));
      expect(result[1].location.row, equals(3));
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

    test('hashCode differs for different characters', () {
      const Character character1 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'b',
        location: Location(row: 1, column: 1),
      );
      const Character character3 = Character(
        value: 'a',
        location: Location(row: 2, column: 1),
      );
      // Different characters should have different hashCodes (not guaranteed but likely)
      expect(
        character1.hashCode != character2.hashCode ||
            character1.hashCode != character3.hashCode,
        isTrue,
      );
    });

    test('toString handles empty string value', () {
      const Character character = Character(
        value: '',
        location: Location(row: 1, column: 1),
      );
      expect(character.toString(), equals('"" at [1, 1]'));
    });

    test('toString handles unicode value', () {
      const Character character = Character(
        value: '👨‍👩‍👧',
        location: Location(row: 1, column: 1),
      );
      expect(character.toString(), equals('"👨‍👩‍👧" at [1, 1]'));
    });

    test('Equality with different value and same location returns false', () {
      const Character character1 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'b',
        location: Location(row: 1, column: 1),
      );
      expect(character1, isNot(equals(character2)));
    });

    test('Equality with same value and different row returns false', () {
      const Character character1 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'a',
        location: Location(row: 2, column: 1),
      );
      expect(character1, isNot(equals(character2)));
    });

    test('Equality with same value and different column returns false', () {
      const Character character1 = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'a',
        location: Location(row: 1, column: 2),
      );
      expect(character1, isNot(equals(character2)));
    });
  });

  group('Located', () {
    test('Equality compares location', () {
      const Located located1 = Located(location: Location(row: 1, column: 2));
      const Located located2 = Located(location: Location(row: 1, column: 2));
      const Located located3 = Located(location: Location(row: 1, column: 3));
      const Located located4 = Located(location: Location(row: 2, column: 2));
      expect(located1, equals(located2));
      expect(located1, isNot(equals(located3)));
      expect(located1, isNot(equals(located4)));
    });

    test('Identical instances are equal', () {
      const Located located = Located(location: Location(row: 5, column: 10));
      expect(located == located, isTrue);
    });

    test('Not equal to non-Located objects', () {
      const Located located = Located(location: Location(row: 1, column: 1));
      expect(located == ('1,1' as dynamic), isFalse);
      expect(located == (1 as dynamic), isFalse);
      expect(located == (null as dynamic), isFalse);
    });

    test('hashCode is consistent with equality', () {
      const Located located1 = Located(location: Location(row: 3, column: 4));
      const Located located2 = Located(location: Location(row: 3, column: 4));
      expect(located1.hashCode, equals(located2.hashCode));
    });

    test('hashCode differs for different locations', () {
      const Located located1 = Located(location: Location(row: 1, column: 1));
      const Located located2 = Located(location: Location(row: 1, column: 2));
      const Located located3 = Located(location: Location(row: 2, column: 1));
      // Different locations should have different hashCodes (not guaranteed but likely)
      expect(
        located1.hashCode != located2.hashCode ||
            located1.hashCode != located3.hashCode,
        isTrue,
      );
    });

    test('hashCode equals location hashCode', () {
      const Location location = Location(row: 7, column: 8);
      const Located located = Located(location: location);
      expect(located.hashCode, equals(location.hashCode));
    });

    test('Character subclass equality uses Character equality not Located', () {
      // Character extends Located but has its own equality based on value and location
      const Character character = Character(
        value: 'a',
        location: Location(row: 1, column: 1),
      );
      const Located located = Located(location: Location(row: 1, column: 1));
      // Character and Located with same location should not be equal
      // because Character.== checks for Character type
      expect(character == located, isFalse);
    });
  });

  group('SourceReader input property', () {
    test('Input property returns the original source string', () {
      const String source = 'hello world';
      const SourceReader reader = SourceReader(source);
      expect(reader.input, equals(source));
    });

    test('Input property preserves original line endings before analysis', () {
      const String source = 'a\r\nb';
      const SourceReader reader = SourceReader(source);
      // Input should preserve original, normalization happens in analyze()
      expect(reader.input, equals(source));
    });

    test('Input property preserves shebang before analysis', () {
      const String source = '#!/bin/sh\nmain() = 1';
      const SourceReader reader = SourceReader(source);
      expect(reader.input, equals(source));
    });
  });

  group('SourceReader additional edge cases', () {
    test('Shebang line with only hash and bang', () {
      final List<Character> result = const SourceReader('#!\ncode').analyze();
      expect(result[0].value, equals('c'));
      expect(result[0].location.row, equals(2));
    });

    test('Hash without bang on first line is not treated as shebang', () {
      final List<Character> result = const SourceReader('#comment').analyze();
      expect(result[0].value, equals('#'));
      expect(result[0].location.row, equals(1));
    });

    test('Bang without hash on first line is not treated as shebang', () {
      final List<Character> result = const SourceReader('!command').analyze();
      expect(result[0].value, equals('!'));
      expect(result[0].location.row, equals(1));
    });

    test('Multiple rows with varying lengths track columns correctly', () {
      final List<Character> result = const SourceReader(
        'ab\nc\ndefg',
      ).analyze();
      // Row 1: 'a'(col 1), 'b'(col 2), '\n'(col 3)
      // Row 2: 'c'(col 1), '\n'(col 2)
      // Row 3: 'd'(col 1), 'e'(col 2), 'f'(col 3), 'g'(col 4), '\n'(col 5)
      expect(result[0].location, equals(const Location(row: 1, column: 1)));
      expect(result[1].location, equals(const Location(row: 1, column: 2)));
      expect(result[2].location, equals(const Location(row: 1, column: 3)));
      expect(result[3].location, equals(const Location(row: 2, column: 1)));
      expect(result[4].location, equals(const Location(row: 2, column: 2)));
      expect(result[5].location, equals(const Location(row: 3, column: 1)));
      expect(result[8].location, equals(const Location(row: 3, column: 4)));
      expect(result[9].location, equals(const Location(row: 3, column: 5)));
    });

    test('Multiple emoji in sequence are separate characters', () {
      final List<Character> result = const SourceReader('🔥🎉🚀').analyze();
      expect(result.length, equals(4)); // 3 emoji + trailing newline
      expect(result[0].value, equals('🔥'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('🎉'));
      expect(result[1].location.column, equals(2));
      expect(result[2].value, equals('🚀'));
      expect(result[2].location.column, equals(3));
    });

    test('Flag emoji is single character', () {
      final List<Character> result = const SourceReader('🇺🇸x').analyze();
      expect(result.length, equals(3)); // flag + x + newline
      expect(result[0].value, equals('🇺🇸'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('x'));
      expect(result[1].location.column, equals(2));
    });

    test('Skin tone emoji modifier is part of base emoji', () {
      final List<Character> result = const SourceReader('👋🏽a').analyze();
      expect(
        result.length,
        equals(3),
      ); // waving hand with skin tone + a + newline
      expect(result[0].value, equals('👋🏽'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('a'));
      expect(result[1].location.column, equals(2));
    });

    test('Consecutive Windows line endings create multiple rows', () {
      final List<Character> result = const SourceReader(
        'a\r\n\r\nb',
      ).analyze();
      // Row 1: 'a', '\n'
      // Row 2: '\n' (empty row)
      // Row 3: 'b', '\n'
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[2].value, equals('\n'));
      expect(result[2].location.row, equals(2));
      expect(result[3].value, equals('b'));
      expect(result[3].location.row, equals(3));
    });

    test('Line ending at end of shebang does not add characters', () {
      final List<Character> result = const SourceReader(
        '#!shebang\n',
      ).analyze();
      expect(result.length, equals(0));
    });

    test('Shebang with Windows line ending is skipped correctly', () {
      final List<Character> result = const SourceReader(
        '#!shebang\r\ncode',
      ).analyze();
      expect(result[0].value, equals('c'));
      expect(result[0].location.row, equals(2));
    });

    test('Null character is preserved', () {
      final List<Character> result = const SourceReader('a\x00b').analyze();
      expect(result[0].value, equals('a'));
      expect(result[1].value, equals('\x00'));
      expect(result[2].value, equals('b'));
    });

    test('Backspace character is preserved', () {
      final List<Character> result = const SourceReader('a\bb').analyze();
      expect(result[0].value, equals('a'));
      expect(result[1].value, equals('\b'));
      expect(result[2].value, equals('b'));
    });

    test('Form feed character is preserved', () {
      final List<Character> result = const SourceReader('a\fb').analyze();
      expect(result[0].value, equals('a'));
      expect(result[1].value, equals('\f'));
      expect(result[2].value, equals('b'));
    });

    test('Vertical tab is preserved', () {
      final List<Character> result = const SourceReader('a\vb').analyze();
      expect(result[0].value, equals('a'));
      expect(result[1].value, equals('\v'));
      expect(result[2].value, equals('b'));
    });

    test('Multiple grapheme clusters with combining marks', () {
      // Multiple characters with combining diacritical marks
      final List<Character> result = const SourceReader(
        'a\u0301e\u0300',
      ).analyze();
      // a + combining acute, e + combining grave
      expect(result.length, equals(3)); // 2 grapheme clusters + newline
      expect(result[0].value, equals('a\u0301'));
      expect(result[1].value, equals('e\u0300'));
    });

    test('Regional indicator symbols form flag', () {
      // U+1F1FA U+1F1F8 = US flag
      final List<Character> result = const SourceReader(
        '\u{1F1FA}\u{1F1F8}',
      ).analyze();
      expect(result.length, equals(2)); // flag + newline
      expect(result[0].value, equals('🇺🇸'));
    });

    test('Surrogate pairs in source are handled as grapheme clusters', () {
      // Emoji that requires surrogate pair in UTF-16: 😀 (U+1F600)
      final List<Character> result = const SourceReader('😀').analyze();
      expect(result.length, equals(2)); // emoji + newline
      expect(result[0].value, equals('😀'));
      expect(result[0].location.column, equals(1));
    });

    test('Single trailing carriage return with newline', () {
      final List<Character> result = const SourceReader('a\r\n').analyze();
      // 'a' at row 1, '\n' trailing for row 1
      expect(result.length, equals(2));
      expect(result[0].value, equals('a'));
      expect(result[1].value, equals('\n'));
    });

    test('SourceReader can be used as const', () {
      const SourceReader reader = SourceReader('test');
      final List<Character> result = reader.analyze();
      expect(result.length, equals(5)); // t, e, s, t, \n
    });

    test('Multiple calls to analyze return independent lists', () {
      const SourceReader reader = SourceReader('ab');
      final List<Character> result1 = reader.analyze();
      final List<Character> result2 = reader.analyze();
      expect(result1, equals(result2));
      expect(identical(result1, result2), isFalse);
    });
  });

  group('Location boundary values', () {
    test('Location with zero row and column can be created', () {
      const Location location = Location(row: 0, column: 0);
      expect(location.row, equals(0));
      expect(location.column, equals(0));
    });

    test('Location with negative values can be created', () {
      const Location location = Location(row: -1, column: -1);
      expect(location.row, equals(-1));
      expect(location.column, equals(-1));
    });

    test('Location with very large values', () {
      const Location location = Location(row: 2147483647, column: 2147483647);
      expect(location.row, equals(2147483647));
      expect(location.column, equals(2147483647));
    });
  });

  group('Character edge cases', () {
    test('Character with multi-codepoint value', () {
      const Character character = Character(
        value: '👨‍👩‍👧‍👦',
        location: Location(row: 1, column: 1),
      );
      expect(character.value, equals('👨‍👩‍👧‍👦'));
      expect(character.toString(), equals('"👨‍👩‍👧‍👦" at [1, 1]'));
    });

    test('Character with combining mark value', () {
      const Character character = Character(
        value: 'e\u0301',
        location: Location(row: 1, column: 1),
      );
      expect(character.value, equals('e\u0301'));
    });

    test('Character equality with same grapheme different encoding', () {
      // é as single codepoint vs e + combining acute
      const Character character1 = Character(
        value: '\u00e9', // é as single codepoint
        location: Location(row: 1, column: 1),
      );
      const Character character2 = Character(
        value: 'e\u0301', // e + combining acute
        location: Location(row: 1, column: 1),
      );
      // These are different strings, so should not be equal
      expect(character1, isNot(equals(character2)));
    });

    test('Character with whitespace value displays correctly', () {
      const Character character = Character(
        value: ' ',
        location: Location(row: 1, column: 1),
      );
      expect(character.toString(), equals('" " at [1, 1]'));
    });
  });
}
