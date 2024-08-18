import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
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
        MinusToken(const Lexeme(
          value: '-',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
        NumberToken(const Lexeme(
          value: '9',
          location: Location(
            row: 1,
            column: 5,
          ),
        )),
        NumberToken(const Lexeme(
          value: '1.23',
          location: Location(
            row: 1,
            column: 7,
          ),
        )),
        MinusToken(const Lexeme(
          value: '-',
          location: Location(
            row: 1,
            column: 12,
          ),
        )),
        NumberToken(const Lexeme(
          value: '0.5',
          location: Location(
            row: 1,
            column: 13,
          ),
        )),
      ]);
    });

    test('Invalid integer', () {
      try {
        getTokens('42a');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid decimal', () {
      try {
        getTokens('1..2');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Valid boolean true', () {
      final List<Token> tokens = getTokens('true');
      checkTokens(tokens, [
        BooleanToken(const Lexeme(
          value: 'true',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Valid boolean false', () {
      final List<Token> tokens = getTokens('false');
      checkTokens(tokens, [
        BooleanToken(const Lexeme(
          value: 'false',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
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

    test('Symbol with dot', () {
      final List<Token> tokens = getTokens('is.even');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'is.even',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Symbol complex', () {
      final List<Token> tokens = getTokens('isToday_butNot.31st');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'isToday_butNot.31st',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
    });

    test('Arithmetic operators', () {
      final List<Token> tokens = getTokens('- + / \\ * % ^');
      checkTokens(tokens, [
        MinusToken(const Lexeme(
          value: '-',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        PlusToken(const Lexeme(
          value: '+',
          location: Location(
            row: 1,
            column: 3,
          ),
        )),
        ForwardSlashToken(const Lexeme(
          value: '/',
          location: Location(
            row: 1,
            column: 5,
          ),
        )),
        BackwardSlashToken(const Lexeme(
          value: '\\',
          location: Location(
            row: 1,
            column: 7,
          ),
        )),
        AsteriskToken(const Lexeme(
          value: '*',
          location: Location(
            row: 1,
            column: 10,
          ),
        )),
        PercentToken(const Lexeme(
          value: '%',
          location: Location(
            row: 1,
            column: 12,
          ),
        )),
        CaretToken(const Lexeme(
          value: '^',
          location: Location(
            row: 1,
            column: 14,
          ),
        )),
      ]);
    });

    test('Logical operators', () {
      final List<Token> tokens = getTokens('| & !');
      checkTokens(tokens, [
        PipeToken(const Lexeme(
          value: '|',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        AmpersandToken(const Lexeme(
          value: '&',
          location: Location(
            row: 1,
            column: 3,
          ),
        )),
        BangToken(const Lexeme(
          value: '!',
          location: Location(
            row: 1,
            column: 5,
          ),
        )),
      ]);
    });

    test('Comparison operators', () {
      final List<Token> tokens = getTokens('== != > >= < <=');
      checkTokens(tokens, [
        EqualToken(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        NotEqualToken(const Lexeme(
          value: '!=',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
        GreaterThanToken(const Lexeme(
          value: '>',
          location: Location(
            row: 1,
            column: 7,
          ),
        )),
        GreaterEqualThanToken(const Lexeme(
          value: '>=',
          location: Location(
            row: 1,
            column: 10,
          ),
        )),
        LessThanToken(const Lexeme(
          value: '<',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
        LessEqualThanToken(const Lexeme(
          value: '<=',
          location: Location(
            row: 1,
            column: 4,
          ),
        )),
      ]);
    });

    test('Equals', () {
      final List<Token> tokens = getTokens('=');
      checkTokens(tokens, [
        AssignToken(const Lexeme(
          value: '=',
          location: Location(
            row: 1,
            column: 1,
          ),
        )),
      ]);
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

    test('Single line comments', () {
      final List<Token> tokens =
          getTokens('// Comment 1\npi = 3.14 // Comment 2\n// Comment 3');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'pi',
          location: Location(
            row: 2,
            column: 1,
          ),
        )),
        AssignToken(const Lexeme(
          value: '=',
          location: Location(
            row: 2,
            column: 4,
          ),
        )),
        NumberToken(const Lexeme(
          value: '3.14',
          location: Location(
            row: 2,
            column: 6,
          ),
        )),
      ]);
    });

    test('Multi line comments', () {
      final List<Token> tokens = getTokens('''/*
  This is a
  multiline comment
  * almost closing!
  but not yet
*/
pi = 3.14
''');
      checkTokens(tokens, [
        SymbolToken(const Lexeme(
          value: 'pi',
          location: Location(
            row: 7,
            column: 1,
          ),
        )),
        AssignToken(const Lexeme(
          value: '=',
          location: Location(
            row: 7,
            column: 4,
          ),
        )),
        NumberToken(const Lexeme(
          value: '3.14',
          location: Location(
            row: 7,
            column: 6,
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
        AssignToken(const Lexeme(
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
        AssignToken(const Lexeme(
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
        AssignToken(const Lexeme(
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
