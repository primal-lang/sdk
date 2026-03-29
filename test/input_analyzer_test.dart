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
      expect(true, equals(':'.isColon));
      expect(true, equals('('.isOpenParenthesis));
      expect(true, equals(')'.isCloseParenthesis));
      expect(true, equals('['.isOpenBracket));
      expect(true, equals(']'.isCloseBracket));
      expect(true, equals('{'.isOpenBraces));
      expect(true, equals('}'.isCloseBraces));
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

    group('Negative cases', () {
      test('isDigit returns false for non-digits', () {
        expect(false, equals('a'.isDigit));
        expect(false, equals('z'.isDigit));
        expect(false, equals(' '.isDigit));
        expect(false, equals('+'.isDigit));
        expect(false, equals('.'.isDigit));
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
        expect(false, equals('a'.isAsterisk));
        expect(false, equals('a'.isPercent));
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
      });
    });

    group('Multi-character strings', () {
      test('isDigit matches within multi-char strings', () {
        expect(true, equals('abc123'.isDigit));
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
          '-', '+', '=', '>', '<', '|', '&', '!', '/', '*', '%',
        ];
        for (final String op in binaryOps) {
          expect(true, equals(op.isBinaryOperator));
        }
        expect(false, equals('a'.isBinaryOperator));
        expect(false, equals('0'.isBinaryOperator));
        expect(false, equals(' '.isBinaryOperator));
        expect(false, equals('.'.isBinaryOperator));
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
        expect(true, equals('+'.isOperandDelimiter));
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
        expect(false, equals('+'.isOperatorDelimiter));
        expect(false, equals(')'.isOperatorDelimiter));
        expect(false, equals(','.isOperatorDelimiter));
      });

      test('isCommaDelimiter', () {
        expect(true, equals(' '.isCommaDelimiter));
        expect(true, equals('0'.isCommaDelimiter));
        expect(true, equals('a'.isCommaDelimiter));
        expect(true, equals('"'.isCommaDelimiter));
        expect(true, equals("'".isCommaDelimiter));
        expect(true, equals('('.isCommaDelimiter));
        expect(true, equals('['.isCommaDelimiter));
        expect(true, equals('{'.isCommaDelimiter));
        expect(true, equals('-'.isCommaDelimiter));
        expect(true, equals('!'.isCommaDelimiter));
        expect(false, equals(')'.isCommaDelimiter));
        expect(false, equals(','.isCommaDelimiter));
      });

      test('isColonDelimiter', () {
        expect(true, equals(' '.isColonDelimiter));
        expect(true, equals('0'.isColonDelimiter));
        expect(true, equals('a'.isColonDelimiter));
        expect(true, equals('"'.isColonDelimiter));
        expect(true, equals("'".isColonDelimiter));
        expect(true, equals('('.isColonDelimiter));
        expect(true, equals('['.isColonDelimiter));
        expect(true, equals('{'.isColonDelimiter));
        expect(true, equals('-'.isColonDelimiter));
        expect(true, equals('!'.isColonDelimiter));
        expect(false, equals(')'.isColonDelimiter));
        expect(false, equals(':'.isColonDelimiter));
      });

      test('isOpenParenthesisDelimiter', () {
        expect(true, equals(' '.isOpenParenthesisDelimiter));
        expect(true, equals('0'.isOpenParenthesisDelimiter));
        expect(true, equals('a'.isOpenParenthesisDelimiter));
        expect(true, equals('"'.isOpenParenthesisDelimiter));
        expect(true, equals("'".isOpenParenthesisDelimiter));
        expect(true, equals('('.isOpenParenthesisDelimiter));
        expect(true, equals(')'.isOpenParenthesisDelimiter));
        expect(true, equals('['.isOpenParenthesisDelimiter));
        expect(true, equals('{'.isOpenParenthesisDelimiter));
        expect(true, equals('-'.isOpenParenthesisDelimiter));
        expect(true, equals('!'.isOpenParenthesisDelimiter));
        expect(false, equals(','.isOpenParenthesisDelimiter));
        expect(false, equals('+'.isOpenParenthesisDelimiter));
      });

      test('isCloseParenthesisDelimiter', () {
        expect(true, equals(' '.isCloseParenthesisDelimiter));
        expect(true, equals(','.isCloseParenthesisDelimiter));
        expect(true, equals(':'.isCloseParenthesisDelimiter));
        expect(true, equals('a'.isCloseParenthesisDelimiter));
        expect(true, equals('('.isCloseParenthesisDelimiter));
        expect(true, equals(')'.isCloseParenthesisDelimiter));
        expect(true, equals('['.isCloseParenthesisDelimiter));
        expect(true, equals(']'.isCloseParenthesisDelimiter));
        expect(true, equals('+'.isCloseParenthesisDelimiter));
        expect(false, equals('"'.isCloseParenthesisDelimiter));
        expect(false, equals('0'.isCloseParenthesisDelimiter));
      });

      test('isOpenBracketDelimiter', () {
        expect(true, equals(' '.isOpenBracketDelimiter));
        expect(true, equals('0'.isOpenBracketDelimiter));
        expect(true, equals('a'.isOpenBracketDelimiter));
        expect(true, equals('"'.isOpenBracketDelimiter));
        expect(true, equals("'".isOpenBracketDelimiter));
        expect(true, equals('('.isOpenBracketDelimiter));
        expect(true, equals('['.isOpenBracketDelimiter));
        expect(true, equals(']'.isOpenBracketDelimiter));
        expect(true, equals('{'.isOpenBracketDelimiter));
        expect(true, equals('-'.isOpenBracketDelimiter));
        expect(true, equals('!'.isOpenBracketDelimiter));
        expect(false, equals(','.isOpenBracketDelimiter));
        expect(false, equals(')'.isOpenBracketDelimiter));
      });

      test('isCloseBracketDelimiter', () {
        expect(true, equals(' '.isCloseBracketDelimiter));
        expect(true, equals(','.isCloseBracketDelimiter));
        expect(true, equals('a'.isCloseBracketDelimiter));
        expect(true, equals('('.isCloseBracketDelimiter));
        expect(true, equals(')'.isCloseBracketDelimiter));
        expect(true, equals('['.isCloseBracketDelimiter));
        expect(true, equals(']'.isCloseBracketDelimiter));
        expect(true, equals('}'.isCloseBracketDelimiter));
        expect(true, equals('+'.isCloseBracketDelimiter));
        expect(false, equals('"'.isCloseBracketDelimiter));
        expect(false, equals('{'.isCloseBracketDelimiter));
      });

      test('isOpenBracesDelimiter', () {
        expect(true, equals(' '.isOpenBracesDelimiter));
        expect(true, equals('0'.isOpenBracesDelimiter));
        expect(true, equals('a'.isOpenBracesDelimiter));
        expect(true, equals('"'.isOpenBracesDelimiter));
        expect(true, equals("'".isOpenBracesDelimiter));
        expect(true, equals('('.isOpenBracesDelimiter));
        expect(true, equals('['.isOpenBracesDelimiter));
        expect(true, equals('{'.isOpenBracesDelimiter));
        expect(true, equals('}'.isOpenBracesDelimiter));
        expect(true, equals('-'.isOpenBracesDelimiter));
        expect(true, equals('!'.isOpenBracesDelimiter));
        expect(false, equals(','.isOpenBracesDelimiter));
        expect(false, equals(')'.isOpenBracesDelimiter));
      });

      test('isCloseBracesDelimiter', () {
        expect(true, equals(' '.isCloseBracesDelimiter));
        expect(true, equals(','.isCloseBracesDelimiter));
        expect(true, equals('a'.isCloseBracesDelimiter));
        expect(true, equals(')'.isCloseBracesDelimiter));
        expect(true, equals('['.isCloseBracesDelimiter));
        expect(true, equals(']'.isCloseBracesDelimiter));
        expect(true, equals('}'.isCloseBracesDelimiter));
        expect(true, equals('+'.isCloseBracesDelimiter));
        expect(false, equals('"'.isCloseBracesDelimiter));
        expect(false, equals('('.isCloseBracesDelimiter));
      });
    });

    group('Edge cases', () {
      test('empty string returns false for all checks', () {
        expect(false, equals(''.isDigit));
        expect(false, equals(''.isLetter));
        expect(false, equals(''.isWhitespace));
        expect(false, equals(''.isNewLine));
        expect(false, equals(''.isMinus));
        expect(false, equals(''.isPlus));
        expect(false, equals(''.isEquals));
        expect(false, equals(''.isDoubleQuote));
        expect(false, equals(''.isSingleQuote));
        expect(false, equals(''.isUnderscore));
        expect(false, equals(''.isDot));
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
        expect(false, equals(''.isIdentifier));
        expect(false, equals(''.isBinaryOperator));
        expect(false, equals(''.isUnaryOperator));
      });

      test('unicode characters are not digits or letters', () {
        expect(false, equals('é'.isDigit));
        expect(false, equals('ñ'.isLetter));
        expect(false, equals('你'.isDigit));
        expect(false, equals('你'.isLetter));
        expect(false, equals('→'.isOperandDelimiter));
      });
    });
  });
}
