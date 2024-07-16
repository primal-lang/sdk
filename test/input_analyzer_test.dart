import 'package:dry/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Input Analyzer', () {
    test('isDigit', () {
      const List<String> digits = [
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9'
      ];

      for (final String digit in digits) {
        expect(true, equals(digit.isDigit));
      }
    });

    test('isLetter', () {
      const List<String> letters = [
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
      ];

      for (final String letter in letters) {
        expect(true, equals(letter.isLetter));
        expect(true, equals(letter.toUpperCase().isLetter));
      }
    });

    test('isWhitespace', () {
      const List<String> delimiters = [' ', '\r', '\n', '\t'];

      for (final String delimiter in delimiters) {
        expect(true, equals(delimiter.isWhitespace));
      }
    });

    test('isOther', () {
      expect(true, equals('"'.isQuote));
      expect(true, equals('.'.isDot));
      expect(true, equals(','.isComma));
      expect(true, equals('='.isEquals));
      expect(true, equals('('.isOpenParenthesis));
      expect(true, equals(')'.isCloseParenthesis));
    });

    test('isSeparator', () {
      expect(true, equals(','.isSeparator));
      expect(true, equals('='.isSeparator));
      expect(true, equals('('.isSeparator));
      expect(true, equals(')'.isSeparator));
    });

    test('isBoolean', () {
      expect(true, equals('true'.isBoolean));
      expect(true, equals('false'.isBoolean));
    });
  });
}
