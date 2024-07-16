import 'package:dry/compiler/errors/lexical_error.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/input_analyzer.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:test/test.dart';

void main() {
  List<Token> _tokens(String source) {
    final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
    final List<Character> characters = inputAnalyzer.analyze();
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);

    return lexicalAnalyzer.analyze();
  }

  void _checkTokens(List<Token> actual, List<Token> expected) {
    expect(actual.length, equals(expected.length));

    for (int i = 0; i < actual.length; i++) {
      expect(actual[i].type, equals(expected[i].type));
      expect(actual[i].value, equals(expected[i].value));
      expect(actual[i].location.row, equals(expected[i].location.row));
      expect(actual[i].location.column, equals(expected[i].location.column));
    }
  }

  group('Lexical Analyzer', () {
    test('Valid umber', () {
      final List<Token> tokens = _tokens('42 1.23');
      _checkTokens(tokens, [
        Token.number(const Lexeme(
          value: '42',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        Token.number(const Lexeme(
          value: '1.23',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
      ]);
    });

    test('Invalid integer', () {
      try {
        _tokens('42a');
      } catch (e) {
        expect(e, isA<LexicalError>());
      }
    });

    test('Invalid decimal', () {
      try {
        _tokens('1..2');
      } catch (e) {
        expect(e, isA<LexicalError>());
      }
    });

    test('String', () {
      final List<Token> tokens = _tokens('"This is a string"');
      _checkTokens(tokens, [
        Token.string(const Lexeme(
          value: 'This is a string',
          location: Location(
            row: 1,
            column: 2,
          ),
        )),
      ]);
    });

    test('Symbol', () {
      final List<Token> tokens = _tokens('isEven');
      _checkTokens(tokens, [
        Token.symbol(const Lexeme(
          value: 'isEven',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Invalid symbol', () {
      try {
        _tokens('func#');
      } catch (e) {
        expect(e, isA<LexicalError>());
      }
    });

    test('Comma', () {
      final List<Token> tokens = _tokens(',');
      _checkTokens(tokens, [
        Token.comma(const Lexeme(
          value: ',',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Equals', () {
      final List<Token> tokens = _tokens('=');
      _checkTokens(tokens, [
        Token.equals(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Open parenthesis', () {
      final List<Token> tokens = _tokens('(');
      _checkTokens(tokens, [
        Token.openParenthesis(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Close parenthesis', () {
      final List<Token> tokens = _tokens(')');
      _checkTokens(tokens, [
        Token.closeParenthesis(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Constant declaration', () {
      final List<Token> tokens = _tokens('pi = 3.14');
      _checkTokens(tokens, [
        Token.symbol(const Lexeme(
          value: 'pi',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        Token.equals(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
        Token.number(const Lexeme(
          value: '3.14',
          location: Location(
            row: 1,
            column: 6,
          ),
        )),
      ]);
    });

    test('Main function definition', () {
      final List<Token> tokens = _tokens('main = isEven(4)');
      _checkTokens(tokens, [
        Token.symbol(const Lexeme(
          value: 'main',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        Token.equals(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 6,
          ),
        )),
        Token.symbol(const Lexeme(
          value: 'isEven',
          location: Location(
            row: 1,
            column: 8,
          ),
        )),
        Token.openParenthesis(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 14,
          ),
        )),
        Token.number(const Lexeme(
          value: '4',
          location: Location(
            row: 1,
            column: 15,
          ),
        )),
        Token.closeParenthesis(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 16,
          ),
        )),
      ]);
    });

    test('Function definition', () {
      final List<Token> tokens = _tokens('isZero(x) = eq(x, 0)');
      _checkTokens(tokens, [
        Token.symbol(const Lexeme(
          value: 'isZero',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        Token.openParenthesis(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 7,
          ),
        )),
        Token.symbol(const Lexeme(
          value: 'x',
          location: Location(
            row: 1,
            column: 8,
          ),
        )),
        Token.closeParenthesis(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 9,
          ),
        )),
        Token.equals(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 11,
          ),
        )),
        Token.symbol(const Lexeme(
          value: 'eq',
          location: Location(
            row: 1,
            column: 13,
          ),
        )),
        Token.openParenthesis(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 15,
          ),
        )),
        Token.symbol(const Lexeme(
          value: 'x',
          location: Location(
            row: 1,
            column: 16,
          ),
        )),
        Token.comma(const Lexeme(
          value: ',',
          location: Location(
            row: 1,
            column: 17,
          ),
        )),
        Token.number(const Lexeme(
          value: '0',
          location: Location(
            row: 1,
            column: 19,
          ),
        )),
        Token.closeParenthesis(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 20,
          ),
        )),
      ]);
    });
  });
}
