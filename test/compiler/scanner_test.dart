@Tags(['compiler'])
library;

import 'package:primal/compiler/scanner/character.dart';
import 'package:primal/compiler/scanner/scanner_analyzer.dart';
import 'package:test/test.dart';

void main() {
  group('Scanner', () {
    test('Empty input returns empty list', () {
      final List<Character> result = const Scanner('').analyze();
      expect(result.length, equals(0));
    });

    test('Single character has correct value and location', () {
      final List<Character> result = const Scanner('a').analyze();
      expect(result[0].value, equals('a'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
    });

    test('Multiple characters on one line have incrementing columns', () {
      final List<Character> result = const Scanner('abc').analyze();
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
      final List<Character> result = const Scanner('a\nb').analyze();
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
      final List<Character> result = const Scanner(
        '#!/usr/bin/env primal\nmain = 42',
      ).analyze();
      // First character should be from the second line
      expect(result[0].value, equals('m'));
      expect(result[0].location.row, equals(2));
      expect(result[0].location.column, equals(1));
    });

    test('Shebang only skips first line', () {
      final List<Character> result = const Scanner(
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
      final List<Character> result = const Scanner('\t ').analyze();
      expect(result[0].value, equals('\t'));
      expect(result[0].location.row, equals(1));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals(' '));
      expect(result[1].location.row, equals(1));
      expect(result[1].location.column, equals(2));
    });

    test('Whitespace characters are handled', () {
      // \r is normalized to \n, splitting into two rows
      final List<Character> result = const Scanner('\r\t ').analyze();
      expect(result[0].value, equals('\n'));
      expect(result[0].location.row, equals(1));
      expect(result[1].value, equals('\t'));
      expect(result[1].location.row, equals(2));
      expect(result[2].value, equals(' '));
      expect(result[2].location.row, equals(2));
    });

    test('Unicode characters are handled', () {
      final List<Character> result = const Scanner('\u00e9\u00f1').analyze();
      expect(result[0].value, equals('\u00e9'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('\u00f1'));
      expect(result[1].location.column, equals(2));
    });

    test('Mixed content tracks locations correctly', () {
      final List<Character> result = const Scanner('a1+').analyze();
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
      final List<Character> result = const Scanner('a👨‍👩‍👧b').analyze();
      expect(result[0].value, equals('a'));
      expect(result[0].location.column, equals(1));
      expect(result[1].value, equals('👨‍👩‍👧'));
      expect(result[1].location.column, equals(2));
      expect(result[2].value, equals('b'));
      expect(result[2].location.column, equals(3));
    });

    test('Each row gets a trailing newline character', () {
      final List<Character> result = const Scanner('ab\ncd').analyze();
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
  });
}
