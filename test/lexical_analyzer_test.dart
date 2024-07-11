import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  List<Token> _tokens(String source) {
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(source: source);

    return lexicalAnalyzer.analyze();
  }

  void _checkTokenValue(List<Token> actual, List<Token> expected) {
    expect(actual.length, equals(expected.length));

    for (int i = 0; i < actual.length; i++) {
      expect(actual[i].type, equals(expected[i].type));
      expect(actual[i].value, equals(expected[i].value));
    }
  }

  group('Lexical Analyzer', () {
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

    test('Number', () {
      final List<Token> tokens = _tokens('42 1.23');
      _checkTokenValue(tokens, [
        Token.number('42'),
        Token.number('1.23'),
      ]);
    });

    test('String', () {
      final List<Token> tokens = _tokens('"This is a string"');
      _checkTokenValue(tokens, [
        Token.string('This is a string'),
      ]);
    });

    test('Symbol', () {
      final List<Token> tokens = _tokens('isEven');
      _checkTokenValue(tokens, [
        Token.symbol('isEven'),
      ]);
    });

    test('Comma', () {
      final List<Token> tokens = _tokens(',');
      _checkTokenValue(tokens, [
        Token.comma(','),
      ]);
    });

    test('Equals', () {
      final List<Token> tokens = _tokens('=');
      _checkTokenValue(tokens, [
        Token.equals('='),
      ]);
    });

    test('Open parenthesis', () {
      final List<Token> tokens = _tokens('(');
      _checkTokenValue(tokens, [
        Token.openParenthesis('('),
      ]);
    });

    test('Close parenthesis', () {
      final List<Token> tokens = _tokens(')');
      _checkTokenValue(tokens, [
        Token.closeParenthesis(')'),
      ]);
    });

    test('Constant declaration', () {
      final List<Token> tokens = _tokens('pi = 3.14');
      _checkTokenValue(tokens, [
        Token.symbol('pi'),
        Token.equals('='),
        Token.number('3.14'),
      ]);
    });

    test('Function definition', () {
      final List<Token> tokens = _tokens('main = isEven(4)');
      _checkTokenValue(tokens, [
        Token.symbol('main'),
        Token.equals('='),
        Token.symbol('isEven'),
        Token.openParenthesis('('),
        Token.number('4'),
        Token.closeParenthesis(')'),
      ]);
    });

    test('Function definition', () {
      final List<Token> tokens = _tokens('isZero(x) = eq(x, 0)');
      _checkTokenValue(tokens, [
        Token.symbol('isZero'),
        Token.openParenthesis('('),
        Token.symbol('x'),
        Token.closeParenthesis(')'),
        Token.equals('='),
        Token.symbol('eq'),
        Token.openParenthesis('('),
        Token.symbol('x'),
        Token.comma(','),
        Token.number('0'),
        Token.closeParenthesis(')'),
      ]);
    });

    test('Function definition', () {
      final List<Token> tokens = _tokens('isTrue(x) = eq(x, true)');
      _checkTokenValue(tokens, [
        Token.symbol('isTrue'),
        Token.openParenthesis('('),
        Token.symbol('x'),
        Token.closeParenthesis(')'),
        Token.equals('='),
        Token.symbol('eq'),
        Token.openParenthesis('('),
        Token.symbol('x'),
        Token.comma(','),
        Token.boolean('true'),
        Token.closeParenthesis(')'),
      ]);
    });

    test('isBoolean', () {
      expect(true, equals('true'.isBoolean));
      expect(true, equals('false'.isBoolean));
    });
  });
}
