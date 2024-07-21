import 'package:dry/compiler/errors/lexical_error.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/location.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Lexical Analyzer', () {
    test('Double quoted string', () {
      final List<Token> tokens = getTokens('"This is a double quoted string"');
      checkTokens(tokens, [
        StringToken(const Lexeme(
          value: 'This is a double quoted string',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Single single string', () {
      final List<Token> tokens = getTokens("'This is a single single string'");
      checkTokens(tokens, [
        StringToken(const Lexeme(
          value: 'This is a single single string',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Valid number', () {
      final List<Token> tokens = getTokens('42 -9 1.23 -0.5');
      checkTokens(tokens, [
        NumberToken(const Lexeme(
          value: '42',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        NumberToken(const Lexeme(
          value: '-9',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
        NumberToken(const Lexeme(
          value: '1.23',
          location: Location(
            row: 1,
            column: 7,
          ),
        )),
        NumberToken(const Lexeme(
          value: '-0.5',
          location: Location(
            row: 1,
            column: 12,
          ),
        )),
      ]);
    });

    test('Invalid integer', () {
      try {
        getTokens('42a');
      } catch (e) {
        expect(e, isA<LexicalError>());
      }
    });

    test('Invalid decimal', () {
      try {
        getTokens('1..2');
      } catch (e) {
        expect(e, isA<LexicalError>());
      }
    });

    test('Symbol', () {
      final List<Token> tokens = getTokens('isEven');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'isEven',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Symbol with numbers', () {
      final List<Token> tokens = getTokens('isBiggerThan10');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'isBiggerThan10',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Symbol with underscore', () {
      final List<Token> tokens = getTokens('is_even');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'is_even',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Symbol complex', () {
      final List<Token> tokens = getTokens('isToday_butNot31st');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'isToday_butNot31st',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Invalid symbol', () {
      try {
        getTokens('func#');
      } catch (e) {
        expect(e, isA<LexicalError>());
      }
    });

    test('Comma', () {
      final List<Token> tokens = getTokens(',');
      checkTokens(tokens, [
        CommaToken(const Lexeme(
          value: ',',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Equals', () {
      final List<Token> tokens = getTokens('=');
      checkTokens(tokens, [
        EqualsToken(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Open parenthesis', () {
      final List<Token> tokens = getTokens('(');
      checkTokens(tokens, [
        OpenParenthesisToken(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Close parenthesis', () {
      final List<Token> tokens = getTokens(')');
      checkTokens(tokens, [
        CloseParenthesisToken(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Constant declaration', () {
      final List<Token> tokens = getTokens('pi = 3.14');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'pi',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        EqualsToken(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
        NumberToken(const Lexeme(
          value: '3.14',
          location: Location(
            row: 1,
            column: 6,
          ),
        )),
      ]);
    });

    test('Main function definition', () {
      final List<Token> tokens = getTokens('main = isEven(4)');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'main',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        EqualsToken(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 6,
          ),
        )),
        SymbolToken(const Lexeme(
          value: 'isEven',
          location: Location(
            row: 1,
            column: 8,
          ),
        )),
        OpenParenthesisToken(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 14,
          ),
        )),
        NumberToken(const Lexeme(
          value: '4',
          location: Location(
            row: 1,
            column: 15,
          ),
        )),
        CloseParenthesisToken(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 16,
          ),
        )),
      ]);
    });

    test('Function definition', () {
      final List<Token> tokens = getTokens('isZero(x) = eq(x, 0)');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'isZero',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        OpenParenthesisToken(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 7,
          ),
        )),
        SymbolToken(const Lexeme(
          value: 'x',
          location: Location(
            row: 1,
            column: 8,
          ),
        )),
        CloseParenthesisToken(const Lexeme(
          value: ')',
          location: Location(
            row: 1,
            column: 9,
          ),
        )),
        EqualsToken(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 11,
          ),
        )),
        SymbolToken(const Lexeme(
          value: 'eq',
          location: Location(
            row: 1,
            column: 13,
          ),
        )),
        OpenParenthesisToken(const Lexeme(
          value: '(',
          location: Location(
            row: 1,
            column: 15,
          ),
        )),
        SymbolToken(const Lexeme(
          value: 'x',
          location: Location(
            row: 1,
            column: 16,
          ),
        )),
        CommaToken(const Lexeme(
          value: ',',
          location: Location(
            row: 1,
            column: 17,
          ),
        )),
        NumberToken(const Lexeme(
          value: '0',
          location: Location(
            row: 1,
            column: 19,
          ),
        )),
        CloseParenthesisToken(const Lexeme(
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
