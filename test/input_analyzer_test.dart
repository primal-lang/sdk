import 'package:primal/extensions/string_extensions.dart';
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
      const List<String> delimiters = [' ', '\t', '\n', '\r'];

      for (final String delimiter in delimiters) {
        expect(true, equals(delimiter.isWhitespace));
      }
    });

    test('isOperator', () {
      expect(true, equals('-'.isMinus));
      expect(true, equals('+'.isPlus));
      expect(true, equals('='.isEquals));
      expect(true, equals('>'.isGreater));
      expect(true, equals('<'.isLess));
      expect(true, equals('|'.isPipe));
      expect(true, equals('&'.isAmpersand));
      expect(true, equals('!'.isBang));
      expect(true, equals('/'.isForwardSlash));
      expect(true, equals('*'.isAsterisk));
      expect(true, equals('%'.isPercent));
    });

    test('isOther', () {
      expect(true, equals('"'.isDoubleQuote));
      expect(true, equals("'".isSingleQuote));
      expect(true, equals('_'.isUnderscore));
      expect(true, equals('.'.isDot));
      expect(true, equals(','.isComma));
      expect(true, equals('('.isOpenParenthesis));
      expect(true, equals(')'.isCloseParenthesis));
      expect(true, equals('['.isOpenBracket));
      expect(true, equals(']'.isCloseBracket));
      expect(true, equals('\n'.isNewLine));
    });

    test('isBoolean', () {
      expect(true, equals('true'.isBoolean));
      expect(true, equals('false'.isBoolean));
    });

    test('isCondition', () {
      expect(true, equals('if'.isIf));
      expect(true, equals('else'.isElse));
    });
  });
}
