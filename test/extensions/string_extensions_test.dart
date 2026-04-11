@Tags(['unit'])
library;

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
        '9',
      ];

      for (final String digit in digits) {
        expect(true, equals(digit.isDigit));
      }
    });

    test('isHexDigit', () {
      const List<String> hexDigits = [
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
      ];

      for (final String hexDigit in hexDigits) {
        expect(true, equals(hexDigit.isHexDigit));
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
      expect(true, equals('\\'.isBackslash));
      expect(true, equals('*'.isAsterisk));
      expect(true, equals('%'.isPercent));
      expect(true, equals('@'.isAt));
    });

    test('isOther', () {
      expect(true, equals('"'.isDoubleQuote));
      expect(true, equals("'".isSingleQuote));
      expect(true, equals('_'.isUnderscore));
      expect(true, equals('.'.isDot));
      expect(true, equals(','.isComma));
      expect(true, equals(':'.isColon));
      expect(true, equals('('.isOpenParenthesis));
      expect(true, equals(')'.isCloseParenthesis));
      expect(true, equals('['.isOpenBracket));
      expect(true, equals(']'.isCloseBracket));
      expect(true, equals('{'.isOpenBraces));
      expect(true, equals('}'.isCloseBraces));
      expect(true, equals('\n'.isNewLine));
      expect(true, equals('e'.isExponent));
      expect(true, equals('E'.isExponent));
    });

    test('isBoolean', () {
      expect(true, equals('true'.isBoolean));
      expect(true, equals('false'.isBoolean));
    });

    test('isCondition', () {
      expect(true, equals('if'.isIf));
      expect(true, equals('else'.isElse));
    });

    test('isLogicalKeyword', () {
      expect(true, equals('and'.isAnd));
      expect(true, equals('or'.isOr));
      expect(true, equals('not'.isNot));
    });

    group('Negative cases', () {
      test('isDigit returns false for non-digits', () {
        expect(false, equals('a'.isDigit));
        expect(false, equals('z'.isDigit));
        expect(false, equals(' '.isDigit));
        expect(false, equals('+'.isDigit));
        expect(false, equals('.'.isDigit));
      });

      test('isHexDigit returns false for non-hex characters', () {
        expect(false, equals('g'.isHexDigit));
        expect(false, equals('G'.isHexDigit));
        expect(false, equals('z'.isHexDigit));
        expect(false, equals('Z'.isHexDigit));
        expect(false, equals(' '.isHexDigit));
        expect(false, equals('+'.isHexDigit));
        expect(false, equals('.'.isHexDigit));
        expect(false, equals('@'.isHexDigit));
      });

      test('isLetter returns false for non-letters', () {
        expect(false, equals('0'.isLetter));
        expect(false, equals('9'.isLetter));
        expect(false, equals(' '.isLetter));
        expect(false, equals('+'.isLetter));
        expect(false, equals('_'.isLetter));
      });

      test('isWhitespace returns false for non-whitespace', () {
        expect(false, equals('a'.isWhitespace));
        expect(false, equals('0'.isWhitespace));
        expect(false, equals('+'.isWhitespace));
        expect(false, equals('.'.isWhitespace));
      });

      test('isNewLine returns false for non-newline whitespace', () {
        expect(false, equals(' '.isNewLine));
        expect(false, equals('\t'.isNewLine));
        expect(false, equals('\r'.isNewLine));
        expect(false, equals('a'.isNewLine));
      });

      test('isExponent returns false for non-exponent characters', () {
        expect(false, equals('d'.isExponent));
        expect(false, equals('D'.isExponent));
        expect(false, equals('f'.isExponent));
        expect(false, equals('0'.isExponent));
        expect(false, equals('+'.isExponent));
      });

      test('isBoolean returns false for non-boolean strings', () {
        expect(false, equals('yes'.isBoolean));
        expect(false, equals('no'.isBoolean));
        expect(false, equals('0'.isBoolean));
        expect(false, equals('1'.isBoolean));
      });

      test('isIf returns false for non-if strings', () {
        expect(false, equals('else'.isIf));
        expect(false, equals('then'.isIf));
      });

      test('isElse returns false for non-else strings', () {
        expect(false, equals('if'.isElse));
        expect(false, equals('then'.isElse));
      });

      test('operator checks return false for non-operators', () {
        expect(false, equals('a'.isMinus));
        expect(false, equals('a'.isPlus));
        expect(false, equals('a'.isEquals));
        expect(false, equals('a'.isGreater));
        expect(false, equals('a'.isLess));
        expect(false, equals('a'.isPipe));
        expect(false, equals('a'.isAmpersand));
        expect(false, equals('a'.isBang));
        expect(false, equals('a'.isForwardSlash));
        expect(false, equals('a'.isBackslash));
        expect(false, equals('a'.isAsterisk));
        expect(false, equals('a'.isPercent));
        expect(false, equals('a'.isAt));
      });

      test('punctuation checks return false for wrong characters', () {
        expect(false, equals('a'.isDoubleQuote));
        expect(false, equals('a'.isSingleQuote));
        expect(false, equals('a'.isUnderscore));
        expect(false, equals('a'.isDot));
        expect(false, equals('a'.isComma));
        expect(false, equals('a'.isColon));
        expect(false, equals('a'.isOpenParenthesis));
        expect(false, equals('a'.isCloseParenthesis));
        expect(false, equals('a'.isOpenBracket));
        expect(false, equals('a'.isCloseBracket));
        expect(false, equals('a'.isOpenBraces));
        expect(false, equals('a'.isCloseBraces));
        expect(false, equals('a'.isExponent));
      });

      test('isAnd returns false for non-and strings', () {
        expect(false, equals('or'.isAnd));
        expect(false, equals('AND'.isAnd));
        expect(false, equals('&&'.isAnd));
      });

      test('isOr returns false for non-or strings', () {
        expect(false, equals('and'.isOr));
        expect(false, equals('OR'.isOr));
        expect(false, equals('||'.isOr));
      });

      test('isNot returns false for non-not strings', () {
        expect(false, equals('and'.isNot));
        expect(false, equals('NOT'.isNot));
        expect(false, equals('!'.isNot));
      });
    });

    group('Multi-character strings', () {
      test('isDigit matches within multi-char strings', () {
        expect(true, equals('abc123'.isDigit));
      });

      test('isHexDigit matches within multi-char strings', () {
        expect(true, equals('ghij0'.isHexDigit));
        expect(true, equals('xyz9'.isHexDigit));
        expect(true, equals('!@#a'.isHexDigit));
        expect(true, equals('!@#F'.isHexDigit));
        expect(false, equals('ghij'.isHexDigit));
      });

      test('isLetter matches within multi-char strings', () {
        expect(true, equals('123abc'.isLetter));
      });

      test('isBoolean requires exact match', () {
        expect(false, equals('falsehood'.isBoolean));
        expect(false, equals('untrue'.isBoolean));
        expect(true, equals('true'.isBoolean));
        expect(true, equals('false'.isBoolean));
      });

      test('isIf requires exact match', () {
        expect(false, equals('iffy'.isIf));
        expect(false, equals('elif'.isIf));
        expect(true, equals('if'.isIf));
      });

      test('isElse requires exact match', () {
        expect(false, equals('elsewhere'.isElse));
        expect(true, equals('else'.isElse));
      });

      test('isAnd requires exact match', () {
        expect(false, equals('android'.isAnd));
        expect(false, equals('sandy'.isAnd));
        expect(true, equals('and'.isAnd));
      });

      test('isOr requires exact match', () {
        expect(false, equals('orange'.isOr));
        expect(false, equals('for'.isOr));
        expect(true, equals('or'.isOr));
      });

      test('isNot requires exact match', () {
        expect(false, equals('nothing'.isNot));
        expect(false, equals('knot'.isNot));
        expect(true, equals('not'.isNot));
      });
    });

    group('Composite properties', () {
      test('isIdentifier', () {
        expect(true, equals('a'.isIdentifier));
        expect(true, equals('Z'.isIdentifier));
        expect(true, equals('0'.isIdentifier));
        expect(true, equals('.'.isIdentifier));
        expect(true, equals('_'.isIdentifier));
        expect(false, equals(' '.isIdentifier));
        expect(false, equals('+'.isIdentifier));
        expect(false, equals(','.isIdentifier));
        expect(false, equals('('.isIdentifier));
      });

      test('isBinaryOperator', () {
        const List<String> binaryOps = [
          '-',
          '+',
          '=',
          '>',
          '<',
          '|',
          '&',
          '!',
          '/',
          '*',
          '%',
          '@',
        ];
        for (final String operator in binaryOps) {
          expect(true, equals(operator.isBinaryOperator));
        }
        expect(false, equals('a'.isBinaryOperator));
        expect(false, equals('0'.isBinaryOperator));
        expect(false, equals(' '.isBinaryOperator));
        expect(false, equals('.'.isBinaryOperator));
        expect(false, equals('\\'.isBinaryOperator));
      });

      test('isUnaryOperator', () {
        expect(true, equals('-'.isUnaryOperator));
        expect(true, equals('!'.isUnaryOperator));
        expect(false, equals('+'.isUnaryOperator));
        expect(false, equals('*'.isUnaryOperator));
        expect(false, equals('a'.isUnaryOperator));
      });

      test('isOperandDelimiter', () {
        expect(true, equals(' '.isOperandDelimiter));
        expect(true, equals('\t'.isOperandDelimiter));
        expect(true, equals('\n'.isOperandDelimiter));
        expect(true, equals('+'.isOperandDelimiter));
        expect(true, equals('-'.isOperandDelimiter));
        expect(true, equals('*'.isOperandDelimiter));
        expect(true, equals('/'.isOperandDelimiter));
        expect(true, equals('%'.isOperandDelimiter));
        expect(true, equals('@'.isOperandDelimiter));
        expect(true, equals(','.isOperandDelimiter));
        expect(true, equals(':'.isOperandDelimiter));
        expect(true, equals('('.isOperandDelimiter));
        expect(true, equals(')'.isOperandDelimiter));
        expect(true, equals('['.isOperandDelimiter));
        expect(true, equals(']'.isOperandDelimiter));
        expect(true, equals('{'.isOperandDelimiter));
        expect(true, equals('}'.isOperandDelimiter));
        expect(false, equals('a'.isOperandDelimiter));
        expect(false, equals('0'.isOperandDelimiter));
        expect(false, equals('"'.isOperandDelimiter));
        expect(false, equals('.'.isOperandDelimiter));
        expect(false, equals('_'.isOperandDelimiter));
      });

      test('isOperatorDelimiter', () {
        expect(true, equals(' '.isOperatorDelimiter));
        expect(true, equals('0'.isOperatorDelimiter));
        expect(true, equals('a'.isOperatorDelimiter));
        expect(true, equals('"'.isOperatorDelimiter));
        expect(true, equals("'".isOperatorDelimiter));
        expect(true, equals('('.isOperatorDelimiter));
        expect(true, equals('['.isOperatorDelimiter));
        expect(true, equals('{'.isOperatorDelimiter));
        expect(true, equals('-'.isOperatorDelimiter));
        expect(true, equals('!'.isOperatorDelimiter));
        expect(false, equals('+'.isOperatorDelimiter));
        expect(false, equals(')'.isOperatorDelimiter));
        expect(false, equals(','.isOperatorDelimiter));
      });
    });

    group('Edge cases', () {
      test('empty string returns false for all checks', () {
        expect(false, equals(''.isDigit));
        expect(false, equals(''.isHexDigit));
        expect(false, equals(''.isLetter));
        expect(false, equals(''.isWhitespace));
        expect(false, equals(''.isNewLine));
        expect(false, equals(''.isMinus));
        expect(false, equals(''.isPlus));
        expect(false, equals(''.isEquals));
        expect(false, equals(''.isGreater));
        expect(false, equals(''.isLess));
        expect(false, equals(''.isPipe));
        expect(false, equals(''.isAmpersand));
        expect(false, equals(''.isBang));
        expect(false, equals(''.isForwardSlash));
        expect(false, equals(''.isBackslash));
        expect(false, equals(''.isAsterisk));
        expect(false, equals(''.isPercent));
        expect(false, equals(''.isAt));
        expect(false, equals(''.isDoubleQuote));
        expect(false, equals(''.isSingleQuote));
        expect(false, equals(''.isUnderscore));
        expect(false, equals(''.isDot));
        expect(false, equals(''.isExponent));
        expect(false, equals(''.isComma));
        expect(false, equals(''.isColon));
        expect(false, equals(''.isOpenParenthesis));
        expect(false, equals(''.isCloseParenthesis));
        expect(false, equals(''.isOpenBracket));
        expect(false, equals(''.isCloseBracket));
        expect(false, equals(''.isOpenBraces));
        expect(false, equals(''.isCloseBraces));
        expect(false, equals(''.isBoolean));
        expect(false, equals(''.isIf));
        expect(false, equals(''.isElse));
        expect(false, equals(''.isAnd));
        expect(false, equals(''.isOr));
        expect(false, equals(''.isIdentifier));
        expect(false, equals(''.isBinaryOperator));
        expect(false, equals(''.isUnaryOperator));
        expect(false, equals(''.isOperandDelimiter));
        expect(false, equals(''.isOperatorDelimiter));
      });

      test('unicode characters are not digits or letters', () {
        expect(false, equals('é'.isDigit));
        expect(false, equals('ñ'.isLetter));
        expect(false, equals('你'.isDigit));
        expect(false, equals('你'.isLetter));
        expect(false, equals('→'.isOperandDelimiter));
      });

      test('ASCII boundary characters are handled correctly', () {
        // Characters just outside letter ranges
        expect(false, equals('@'.isLetter)); // before 'A'
        expect(false, equals('['.isLetter)); // after 'Z'
        expect(false, equals('`'.isLetter)); // before 'a'
        expect(false, equals('{'.isLetter)); // after 'z'

        // Characters just outside digit range
        expect(false, equals('/'.isDigit)); // before '0'
        expect(false, equals(':'.isDigit)); // after '9'

        // Characters just outside hex digit ranges
        expect(false, equals('/'.isHexDigit)); // before '0'
        expect(false, equals(':'.isHexDigit)); // after '9'
        expect(false, equals('@'.isHexDigit)); // before 'A'
        expect(false, equals('G'.isHexDigit)); // after 'F'
        expect(false, equals('`'.isHexDigit)); // before 'a'
        expect(false, equals('g'.isHexDigit)); // after 'f'
      });

      test('unicode whitespace is not recognized as whitespace', () {
        expect(false, equals('\u00A0'.isWhitespace)); // non-breaking space
        expect(false, equals('\u2003'.isWhitespace)); // em space
        expect(false, equals('\u200B'.isWhitespace)); // zero-width space
      });

      test('isWhitespace requires exact single-char match', () {
        // Unlike isDigit/isLetter (which use regex), isWhitespace uses equality
        expect(false, equals('hello world'.isWhitespace));
        expect(false, equals('a\tb'.isWhitespace));
        expect(false, equals('line1\nline2'.isWhitespace));
        expect(false, equals('  '.isWhitespace)); // two spaces
        expect(false, equals('nospaces'.isWhitespace));
      });
    });
  });
}
