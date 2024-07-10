import 'package:dry/compiler/lexical_analyzer.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/models/token.dart';
import 'package:test/test.dart';

void main() {
  List<Token> _tokens(String source) {
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(source: source);

    return lexicalAnalyzer.analyze();
  }

  void _check(List<Token> actual, List<String> expected) {
    expect(actual.length, equals(expected.length));

    for (int i = 0; i < actual.length; i++) {
      expect(actual[i].value, equals(expected[i]));
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
      expect(true, equals('.'.isDot));
      expect(true, equals(','.isComma));
      expect(true, equals('='.isEquals));
      expect(true, equals('('.isOpenParenthesis));
      expect(true, equals(')'.isCloseParenthesis));
    });

    test('Number', () {
      final List<Token> tokens = _tokens('42 1.23');
      _check(tokens, ['42', '1.23']);
    });

    /*test('String', () {
      final List<Token> tokens = _tokens('"This is a string"');
      _check(tokens, ['This is a string']);
    });*/

    test('Symbol', () {
      final List<Token> tokens = _tokens('isEven');
      _check(tokens, ['isEven']);
    });

    test('Comma', () {
      final List<Token> tokens = _tokens(',');
      _check(tokens, [',']);
    });

    test('Open parenthesis', () {
      final List<Token> tokens = _tokens('(');
      _check(tokens, ['(']);
    });

    test('Close parenthesis', () {
      final List<Token> tokens = _tokens(')');
      _check(tokens, [')']);
    });

    test('Equals', () {
      final List<Token> tokens = _tokens('=');
      _check(tokens, ['=']);
    });

    /*test('Constant declaration', () {
      final List<Token> tokens = _tokens('pi = 3.14');
      _check(tokens, ['pi', '=', '3.14']);
    });

    test('Function definition', () {
      final List<Token> tokens = _tokens('main = isEven(4)');
      _check(tokens, ['main', '=', 'isEvent', '(', '4', ')']);
    });

    test('Function definition', () {
      final List<Token> tokens = _tokens('isEven(x) = eq(mod(x, 2), 0)');
      _check(tokens, ['isEven', '(', 'x', ')', '=', 'eq', '(', 'mod', '(', 'x', ',', '2', ')', ',', '0', ')']);
    });*/
  });
}
