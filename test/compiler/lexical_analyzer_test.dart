@Tags(['compiler'])
library;

import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  group('Lexical Analyzer', () {
    test('Double quoted string', () {
      final List<Token> tokens = getTokens('"This is a double quoted string"');
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: 'This is a double quoted string',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Single quoted string', () {
      final List<Token> tokens = getTokens("'This is a single single string'");
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: 'This is a single single string',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Valid number', () {
      final List<Token> tokens = getTokens('42 1.23');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '42',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1.23',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
      ]);
    });

    test('Invalid integer', () {
      expect(() => getTokens('42a'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid decimal', () {
      expect(() => getTokens('1..2'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Scientific notation - integer with positive exponent', () {
      final List<Token> tokens = getTokens('1e10');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1e10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - uppercase E', () {
      final List<Token> tokens = getTokens('1E10');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1E10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - explicit positive exponent', () {
      final List<Token> tokens = getTokens('1e+10');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1e+10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - negative exponent', () {
      final List<Token> tokens = getTokens('1e-10');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1e-10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - decimal with exponent', () {
      final List<Token> tokens = getTokens('1.5e10');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1.5e10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - decimal with negative exponent', () {
      final List<Token> tokens = getTokens('1.5e-3');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1.5e-3',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - with underscores in mantissa', () {
      final List<Token> tokens = getTokens('1_000e10');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1000e10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - with underscores in exponent', () {
      final List<Token> tokens = getTokens('1e1_0');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1e10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Scientific notation - incomplete exponent', () {
      expect(() => getTokens('1e'), throwsA(isA<LexicalError>()));
    });

    test('Scientific notation - incomplete exponent with sign', () {
      expect(() => getTokens('1e+'), throwsA(isA<LexicalError>()));
    });

    test('Scientific notation - invalid character after e', () {
      expect(() => getTokens('1ea'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Scientific notation - underscore after e', () {
      expect(() => getTokens('1e_5'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Scientific notation - underscore after sign', () {
      expect(() => getTokens('1e+_5'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Scientific notation - trailing underscore in exponent', () {
      expect(() => getTokens('1e5_ '), throwsA(isA<InvalidCharacterError>()));
    });

    test('Scientific notation - trailing underscore in exponent at EOI', () {
      expect(() => getTokens('1e5_'), throwsA(isA<LexicalError>()));
    });

    test('Scientific notation - consecutive underscores in exponent', () {
      expect(() => getTokens('1e1__0'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Valid boolean true', () {
      final List<Token> tokens = getTokens('true');
      checkTokens(tokens, [
        BooleanToken(
          const Lexeme(
            value: 'true',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Valid boolean false', () {
      final List<Token> tokens = getTokens('false');
      checkTokens(tokens, [
        BooleanToken(
          const Lexeme(
            value: 'false',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Valid empty list', () {
      final List<Token> tokens = getTokens('[]');
      checkTokens(tokens, [
        OpenBracketToken(
          const Lexeme(
            value: '[',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        CloseBracketToken(
          const Lexeme(
            value: ']',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
      ]);
    });

    test('Valid non empty list', () {
      final List<Token> tokens = getTokens('[1, true, "test"]');
      checkTokens(tokens, [
        OpenBracketToken(
          const Lexeme(
            value: '[',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        CommaToken(
          const Lexeme(
            value: ',',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        BooleanToken(
          const Lexeme(
            value: 'true',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
        CommaToken(
          const Lexeme(
            value: ',',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
        StringToken(
          const Lexeme(
            value: 'test',
            location: Location(
              row: 1,
              column: 11,
            ),
          ),
        ),
        CloseBracketToken(
          const Lexeme(
            value: ']',
            location: Location(
              row: 1,
              column: 17,
            ),
          ),
        ),
      ]);
    });

    test('Indexing list', () {
      final List<Token> tokens = getTokens('[1, 2, 3][1]');
      checkTokens(tokens, [
        OpenBracketToken(
          const Lexeme(
            value: '[',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        CommaToken(
          const Lexeme(
            value: ',',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '2',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
        CommaToken(
          const Lexeme(
            value: ',',
            location: Location(
              row: 1,
              column: 6,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '3',
            location: Location(
              row: 1,
              column: 8,
            ),
          ),
        ),
        CloseBracketToken(
          const Lexeme(
            value: ']',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
        OpenBracketToken(
          const Lexeme(
            value: '[',
            location: Location(
              row: 1,
              column: 10,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 11,
            ),
          ),
        ),
        CloseBracketToken(
          const Lexeme(
            value: ']',
            location: Location(
              row: 1,
              column: 12,
            ),
          ),
        ),
      ]);
    });

    test('Valid empty map', () {
      final List<Token> tokens = getTokens('{}');
      checkTokens(tokens, [
        OpenBracesToken(
          const Lexeme(
            value: '{',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        CloseBracesToken(
          const Lexeme(
            value: '}',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
      ]);
    });

    test('Valid non empty map', () {
      final List<Token> tokens = getTokens('{"name": "John", "age": 42}');
      checkTokens(tokens, [
        OpenBracesToken(
          const Lexeme(
            value: '{',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        StringToken(
          const Lexeme(
            value: 'name',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        ColonToken(
          const Lexeme(
            value: ':',
            location: Location(
              row: 1,
              column: 8,
            ),
          ),
        ),
        StringToken(
          const Lexeme(
            value: 'John',
            location: Location(
              row: 1,
              column: 10,
            ),
          ),
        ),
        CommaToken(
          const Lexeme(
            value: ',',
            location: Location(
              row: 1,
              column: 16,
            ),
          ),
        ),
        StringToken(
          const Lexeme(
            value: 'age',
            location: Location(
              row: 1,
              column: 18,
            ),
          ),
        ),
        ColonToken(
          const Lexeme(
            value: ':',
            location: Location(
              row: 1,
              column: 23,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '42',
            location: Location(
              row: 1,
              column: 25,
            ),
          ),
        ),
        CloseBracesToken(
          const Lexeme(
            value: '}',
            location: Location(
              row: 1,
              column: 27,
            ),
          ),
        ),
      ]);
    });

    test('Indexing map', () {
      final List<Token> tokens = getTokens('{}["name"]');
      checkTokens(tokens, [
        OpenBracesToken(
          const Lexeme(
            value: '{',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        CloseBracesToken(
          const Lexeme(
            value: '}',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        OpenBracketToken(
          const Lexeme(
            value: '[',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        StringToken(
          const Lexeme(
            value: 'name',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
        CloseBracketToken(
          const Lexeme(
            value: ']',
            location: Location(
              row: 1,
              column: 10,
            ),
          ),
        ),
      ]);
    });

    test('Identifier with letters', () {
      final List<Token> tokens = getTokens('isEven');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'isEven',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier with numbers', () {
      final List<Token> tokens = getTokens('isBiggerThan10');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'isBiggerThan10',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier with underscore', () {
      final List<Token> tokens = getTokens('is_even');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'is_even',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier with dot', () {
      final List<Token> tokens = getTokens('is.even');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'is.even',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier complex', () {
      final List<Token> tokens = getTokens('isToday_butNot.31st');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'isToday_butNot.31st',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Condition', () {
      final List<Token> tokens = getTokens('if test foo else bar');
      checkTokens(tokens, [
        IfToken(
          const Lexeme(
            value: 'if',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'test',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'foo',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
        ElseToken(
          const Lexeme(
            value: 'else',
            location: Location(
              row: 1,
              column: 13,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'bar',
            location: Location(
              row: 1,
              column: 18,
            ),
          ),
        ),
      ]);
    });

    test('Arithmetic operators', () {
      final List<Token> tokens = getTokens('- + / * %');
      checkTokens(tokens, [
        MinusToken(
          const Lexeme(
            value: '-',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        PlusToken(
          const Lexeme(
            value: '+',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        ForwardSlashToken(
          const Lexeme(
            value: '/',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
        AsteriskToken(
          const Lexeme(
            value: '*',
            location: Location(
              row: 1,
              column: 7,
            ),
          ),
        ),
        PercentToken(
          const Lexeme(
            value: '%',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
      ]);
    });

    test('At token', () {
      final List<Token> tokens = getTokens('@');
      checkTokens(tokens, [
        AtToken(
          const Lexeme(
            value: '@',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('At token in expression', () {
      final List<Token> tokens = getTokens('a @ 1');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'a',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AtToken(
          const Lexeme(
            value: '@',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
      ]);
    });

    test('Logical operators', () {
      final List<Token> tokens = getTokens('| & !');
      checkTokens(tokens, [
        PipeToken(
          const Lexeme(
            value: '|',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AmpersandToken(
          const Lexeme(
            value: '&',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        BangToken(
          const Lexeme(
            value: '!',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
      ]);
    });

    test('Logical operator aliases', () {
      final List<Token> tokens = getTokens('|| && and or');
      checkTokens(tokens, [
        DoublePipeToken(
          const Lexeme(
            value: '||',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        DoubleAmpersandToken(
          const Lexeme(
            value: '&&',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
        DoubleAmpersandToken(
          const Lexeme(
            value: '&&',
            location: Location(
              row: 1,
              column: 7,
            ),
          ),
        ),
        DoublePipeToken(
          const Lexeme(
            value: '||',
            location: Location(
              row: 1,
              column: 11,
            ),
          ),
        ),
      ]);
    });

    test('Comparison operators', () {
      final List<Token> tokens = getTokens('== != > >= < <=');
      checkTokens(tokens, [
        EqualToken(
          const Lexeme(
            value: '==',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        NotEqualToken(
          const Lexeme(
            value: '!=',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
        GreaterThanToken(
          const Lexeme(
            value: '>',
            location: Location(
              row: 1,
              column: 7,
            ),
          ),
        ),
        GreaterOrEqualToken(
          const Lexeme(
            value: '>=',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
        LessThanToken(
          const Lexeme(
            value: '<',
            location: Location(
              row: 1,
              column: 12,
            ),
          ),
        ),
        LessOrEqualToken(
          const Lexeme(
            value: '<=',
            location: Location(
              row: 1,
              column: 14,
            ),
          ),
        ),
      ]);
    });

    test('Assignment', () {
      final List<Token> tokens = getTokens('=');
      checkTokens(tokens, [
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Comma', () {
      final List<Token> tokens = getTokens(',');
      checkTokens(tokens, [
        CommaToken(
          const Lexeme(
            value: ',',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Open parenthesis', () {
      final List<Token> tokens = getTokens('(');
      checkTokens(tokens, [
        OpenParenthesisToken(
          const Lexeme(
            value: '(',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Close parenthesis', () {
      final List<Token> tokens = getTokens(')');
      checkTokens(tokens, [
        CloseParenthesisToken(
          const Lexeme(
            value: ')',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Single line comments', () {
      final List<Token> tokens = getTokens(
        '// Comment 1\npi = 3.14 // Comment 2\n// Comment 3',
      );
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'pi',
            location: Location(
              row: 2,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 2,
              column: 4,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '3.14',
            location: Location(
              row: 2,
              column: 6,
            ),
          ),
        ),
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
        IdentifierToken(
          const Lexeme(
            value: 'pi',
            location: Location(
              row: 7,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 7,
              column: 4,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '3.14',
            location: Location(
              row: 7,
              column: 6,
            ),
          ),
        ),
      ]);
    });

    test('Constant declaration', () {
      final List<Token> tokens = getTokens('pi = 3.14');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'pi',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '3.14',
            location: Location(
              row: 1,
              column: 6,
            ),
          ),
        ),
      ]);
    });

    test('Invalid function definition 1', () {
      expect(
        () => getFunctions('_isEven = true'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('Invalid function definition 2', () {
      expect(
        () => getFunctions('_isEven(n) = n'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('Invalid function definition 3', () {
      expect(
        () => getFunctions('isEvent(,) = true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Invalid function definition 4', () {
      expect(
        () => getFunctions('isEvent(x,) = true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Main function definition', () {
      final List<Token> tokens = getTokens('main = isEven(4)');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'main',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 6,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'isEven',
            location: Location(
              row: 1,
              column: 8,
            ),
          ),
        ),
        OpenParenthesisToken(
          const Lexeme(
            value: '(',
            location: Location(
              row: 1,
              column: 14,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '4',
            location: Location(
              row: 1,
              column: 15,
            ),
          ),
        ),
        CloseParenthesisToken(
          const Lexeme(
            value: ')',
            location: Location(
              row: 1,
              column: 16,
            ),
          ),
        ),
      ]);
    });

    test('Function definition', () {
      final List<Token> tokens = getTokens('isZero(x) = x == 0');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'isZero',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        OpenParenthesisToken(
          const Lexeme(
            value: '(',
            location: Location(
              row: 1,
              column: 7,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 8,
            ),
          ),
        ),
        CloseParenthesisToken(
          const Lexeme(
            value: ')',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 11,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 13,
            ),
          ),
        ),
        EqualToken(
          const Lexeme(
            value: '==',
            location: Location(
              row: 1,
              column: 15,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '0',
            location: Location(
              row: 1,
              column: 18,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: strings ---

    test('Empty double quoted string', () {
      final List<Token> tokens = getTokens('""');
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: '',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Empty single quoted string', () {
      final List<Token> tokens = getTokens("''");
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: '',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Double quoted string containing single quotes', () {
      final List<Token> tokens = getTokens('"it\'s"');
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: "it's",
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Single quoted string containing double quotes', () {
      final List<Token> tokens = getTokens('\'say "hi"\'');
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: 'say "hi"',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('String containing operators and digits', () {
      final List<Token> tokens = getTokens('"1 + 2 = 3"');
      checkTokens(tokens, [
        StringToken(
          const Lexeme(
            value: '1 + 2 = 3',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Unterminated double quoted string', () {
      expect(
        () => getTokens('"hello'),
        throwsA(isA<UnterminatedStringError>()),
      );
    });

    test('Unterminated single quoted string', () {
      expect(
        () => getTokens("'hello"),
        throwsA(isA<UnterminatedStringError>()),
      );
    });

    // --- Edge cases: numbers ---

    test('Zero', () {
      final List<Token> tokens = getTokens('0');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '0',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Leading zeros', () {
      final List<Token> tokens = getTokens('007');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '007',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Long decimal', () {
      final List<Token> tokens = getTokens('3.14159265');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '3.14159265',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Decimal starting with dot', () {
      expect(() => getTokens('.5'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Number followed by dot and letter', () {
      expect(() => getTokens('42.x'), throwsA(isA<InvalidCharacterError>()));
    });

    // --- Underscore separators in numbers ---

    test('Integer with underscore separator', () {
      final List<Token> tokens = getTokens('1_000');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1000',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Integer with multiple underscore separators', () {
      final List<Token> tokens = getTokens('1_000_000');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1000000',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Decimal with underscore separator in integer part', () {
      final List<Token> tokens = getTokens('1_000.5');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1000.5',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Decimal with underscore separator in fractional part', () {
      final List<Token> tokens = getTokens('3.14_159');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '3.14159',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Decimal with underscore separators in both parts', () {
      final List<Token> tokens = getTokens('1_000.123_456');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1000.123456',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Single digit groups with underscores', () {
      final List<Token> tokens = getTokens('1_2_3');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '123',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Integer with trailing underscore', () {
      expect(() => getTokens('123_ '), throwsA(isA<InvalidCharacterError>()));
    });

    test('Integer with trailing underscore at end of input', () {
      expect(() => getTokensDirect('123_'), throwsA(isA<LexicalError>()));
    });

    test('Decimal with trailing underscore', () {
      expect(() => getTokens('3.14_ '), throwsA(isA<InvalidCharacterError>()));
    });

    test('Decimal with trailing underscore at end of input', () {
      expect(() => getTokensDirect('3.14_'), throwsA(isA<LexicalError>()));
    });

    test('Integer with consecutive underscores', () {
      expect(() => getTokens('1__2'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Decimal with consecutive underscores', () {
      expect(
        () => getTokens('3.14__15'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('Underscore immediately after decimal point', () {
      expect(() => getTokens('3._14'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Underscore before decimal point', () {
      expect(() => getTokens('3_.14'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Integer with underscore in expression', () {
      final List<Token> tokens = getTokens('1_000+2_000');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1000',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        PlusToken(
          const Lexeme(
            value: '+',
            location: Location(
              row: 1,
              column: 6,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '2000',
            location: Location(
              row: 1,
              column: 7,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: identifiers and keywords ---
    // These tests expose a bug: isBoolean/isIf/isElse in string_extensions.dart
    // use hasMatch (substring match) instead of exact match, so identifiers
    // like "trueValue" are incorrectly classified as keywords.

    test('Identifier starting with true', () {
      final List<Token> tokens = getTokens('trueValue');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'trueValue',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier starting with false', () {
      final List<Token> tokens = getTokens('falseHood');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'falseHood',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier starting with if', () {
      final List<Token> tokens = getTokens('iffy');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'iffy',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    test('Identifier starting with else', () {
      final List<Token> tokens = getTokens('elsewhere');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'elsewhere',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: operators without whitespace ---

    test('Expression without whitespace', () {
      final List<Token> tokens = getTokens('1+2');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        PlusToken(
          const Lexeme(
            value: '+',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '2',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
      ]);
    });

    test('Boolean comparison without whitespace', () {
      final List<Token> tokens = getTokens('true==false');
      checkTokens(tokens, [
        BooleanToken(
          const Lexeme(
            value: 'true',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        EqualToken(
          const Lexeme(
            value: '==',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
        BooleanToken(
          const Lexeme(
            value: 'false',
            location: Location(
              row: 1,
              column: 7,
            ),
          ),
        ),
      ]);
    });

    test('Unary minus before number', () {
      final List<Token> tokens = getTokens('-42');
      checkTokens(tokens, [
        MinusToken(
          const Lexeme(
            value: '-',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '42',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
      ]);
    });

    test('Unary bang before boolean', () {
      final List<Token> tokens = getTokens('!true');
      checkTokens(tokens, [
        BangToken(
          const Lexeme(
            value: '!',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        BooleanToken(
          const Lexeme(
            value: 'true',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
      ]);
    });

    test('Binary operator followed by unary minus', () {
      final List<Token> tokens = getTokens('1+-2');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        PlusToken(
          const Lexeme(
            value: '+',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        MinusToken(
          const Lexeme(
            value: '-',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '2',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
      ]);
    });

    test('Binary operator followed by unary bang', () {
      final List<Token> tokens = getTokens('1+!x');
      checkTokens(tokens, [
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        PlusToken(
          const Lexeme(
            value: '+',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        BangToken(
          const Lexeme(
            value: '!',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
      ]);
    });

    test('Double unary bang', () {
      final List<Token> tokens = getTokens('!!x');
      checkTokens(tokens, [
        BangToken(
          const Lexeme(
            value: '!',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        BangToken(
          const Lexeme(
            value: '!',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: whitespace and empty input ---

    test('Empty input', () {
      final List<Token> tokens = getTokens('');
      checkTokens(tokens, []);
    });

    test('Whitespace only input', () {
      final List<Token> tokens = getTokens('   \t  ');
      checkTokens(tokens, []);
    });

    test('Tab whitespace as separator', () {
      final List<Token> tokens = getTokens('x\t=\ty');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'y',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
      ]);
    });

    test('Multiple consecutive whitespace', () {
      final List<Token> tokens = getTokens('x   =   y');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'y',
            location: Location(
              row: 1,
              column: 9,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: location tracking ---

    test('Multiline location tracking', () {
      final List<Token> tokens = getTokens('x = 1\ny = 2');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 5,
            ),
          ),
        ),
        IdentifierToken(
          const Lexeme(
            value: 'y',
            location: Location(
              row: 2,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 2,
              column: 3,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '2',
            location: Location(
              row: 2,
              column: 5,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: comments ---

    test('Inline multi-line comment between tokens', () {
      final List<Token> tokens = getTokens('x /* comment */ = 1');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 17,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 19,
            ),
          ),
        ),
      ]);
    });

    test('Unterminated multi-line comment', () {
      expect(
        () => getTokens('/* comment'),
        throwsA(isA<UnterminatedCommentError>()),
      );
    });

    test('Multi-line comment with consecutive asterisks', () {
      final List<Token> tokens = getTokens('x /* **/ = 1');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 1,
              column: 10,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 1,
              column: 12,
            ),
          ),
        ),
      ]);
    });

    test('Multi-line comment closing with ***/', () {
      final List<Token> tokens = getTokens('/***/x');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 1,
              column: 6,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: delimiters ---

    test('Colon', () {
      final List<Token> tokens = getTokens(':');
      checkTokens(tokens, [
        ColonToken(
          const Lexeme(
            value: ':',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: invalid characters ---

    test('Invalid character #', () {
      expect(() => getTokens('#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character \$', () {
      expect(() => getTokens('\$'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character ~', () {
      expect(() => getTokens('~'), throwsA(isA<InvalidCharacterError>()));
    });

    // --- Edge cases: shebang ---

    test('Shebang line is skipped', () {
      final List<Token> tokens = getTokens('#!/usr/bin/primal\nx = 1');
      checkTokens(tokens, [
        IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(
              row: 2,
              column: 1,
            ),
          ),
        ),
        AssignToken(
          const Lexeme(
            value: '=',
            location: Location(
              row: 2,
              column: 3,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '1',
            location: Location(
              row: 2,
              column: 5,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: invalid character in specific lexer states ---

    test('Invalid character in DecimalState', () {
      expect(() => getTokens('42.1#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character in IdentifierState', () {
      expect(() => getTokens('foo#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after minus', () {
      expect(() => getTokens('-#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after plus', () {
      expect(() => getTokens('+#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after equals', () {
      expect(() => getTokens('=#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after greater', () {
      expect(() => getTokens('>#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after less', () {
      expect(() => getTokens('<#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after pipe', () {
      expect(() => getTokens('|#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after ampersand', () {
      expect(() => getTokens('&#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after bang', () {
      expect(() => getTokens('!#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after forward slash', () {
      expect(() => getTokens('/#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after asterisk', () {
      expect(() => getTokens('*#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after percent', () {
      expect(() => getTokens('%#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after colon', () {
      expect(() => getTokens(':#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after close parenthesis', () {
      expect(() => getTokens(')#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after open bracket', () {
      expect(() => getTokens('[#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after close bracket', () {
      expect(() => getTokens(']#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after open braces', () {
      expect(() => getTokens('{#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Invalid character after close braces', () {
      expect(() => getTokens('}#'), throwsA(isA<InvalidCharacterError>()));
    });

    test('Close bracket followed by colon', () {
      final List<Token> tokens = getTokens('[0]:');
      checkTokens(tokens, [
        OpenBracketToken(
          const Lexeme(
            value: '[',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        NumberToken(
          const Lexeme(
            value: '0',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        CloseBracketToken(
          const Lexeme(
            value: ']',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
        ColonToken(
          const Lexeme(
            value: ':',
            location: Location(
              row: 1,
              column: 4,
            ),
          ),
        ),
      ]);
    });

    test('Close braces followed by colon', () {
      final List<Token> tokens = getTokens('{}:');
      checkTokens(tokens, [
        OpenBracesToken(
          const Lexeme(
            value: '{',
            location: Location(
              row: 1,
              column: 1,
            ),
          ),
        ),
        CloseBracesToken(
          const Lexeme(
            value: '}',
            location: Location(
              row: 1,
              column: 2,
            ),
          ),
        ),
        ColonToken(
          const Lexeme(
            value: ':',
            location: Location(
              row: 1,
              column: 3,
            ),
          ),
        ),
      ]);
    });

    // --- Edge cases: Lexeme toString ---

    test('Lexeme toString returns formatted string', () {
      const lexeme = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      expect(lexeme.toString(), equals('"test" at [1, 1]'));
    });

    // --- End-of-input flush ---

    group('End-of-input flush', () {
      test('Integer at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('123');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '123',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Decimal at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('3.14');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('foo');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'foo',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Boolean true at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('true');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'true',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Boolean false at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('false');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'false',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('If keyword at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('if');
        checkTokens(tokens, [
          IfToken(
            const Lexeme(
              value: 'if',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Else keyword at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('else');
        checkTokens(tokens, [
          ElseToken(
            const Lexeme(
              value: 'else',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Token before integer at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('(42');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Empty input direct (no false flush)', () {
        final List<Token> tokens = getTokensDirect('');
        checkTokens(tokens, []);
      });
    });

    // --- Edge cases: single-character delimiter tokens ---

    group('Single-character delimiter tokens', () {
      test('Adjacent parentheses', () {
        final List<Token> tokens = getTokens('()');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Adjacent brackets', () {
        final List<Token> tokens = getTokens('[]');
        checkTokens(tokens, [
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Adjacent braces', () {
        final List<Token> tokens = getTokens('{}');
        checkTokens(tokens, [
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Nested parentheses', () {
        final List<Token> tokens = getTokens('(())');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Mixed delimiters without whitespace', () {
        final List<Token> tokens = getTokens('([{)]}');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 2),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Multiple commas', () {
        final List<Token> tokens = getTokens(',,,');
        checkTokens(tokens, [
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 1),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 2),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Multiple colons', () {
        final List<Token> tokens = getTokens(':::');
        checkTokens(tokens, [
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 1),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 2),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Open parenthesis followed by operator', () {
        final List<Token> tokens = getTokens('(+');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Close parenthesis followed by operator', () {
        final List<Token> tokens = getTokens(')+');
        checkTokens(tokens, [
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 1),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Comma followed by close parenthesis', () {
        final List<Token> tokens = getTokens(',)');
        checkTokens(tokens, [
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Colon followed by close braces', () {
        final List<Token> tokens = getTokens(':}');
        checkTokens(tokens, [
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Open bracket followed by close bracket (empty list)', () {
        final List<Token> tokens = getTokens('[]');
        checkTokens(tokens, [
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Single-char delimiters with numbers', () {
        final List<Token> tokens = getTokens('(1,2,3)');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 2),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 4),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '3',
              location: Location(row: 1, column: 6),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('Map literal structure', () {
        final List<Token> tokens = getTokens('{a:1}');
        checkTokens(tokens, [
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 2),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('List with nested list', () {
        final List<Token> tokens = getTokens('[[]]');
        checkTokens(tokens, [
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Single-char delimiters at end of input', () {
        final List<Token> tokens = getTokensDirect('x(');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Comma at end of input', () {
        final List<Token> tokens = getTokensDirect('x,');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Colon at end of input', () {
        final List<Token> tokens = getTokensDirect('x:');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('All single-char delimiters in sequence', () {
        final List<Token> tokens = getTokens('()[]{},:');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 2),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 4),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 6),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 7),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 8),
            ),
          ),
        ]);
      });

      test('Delimiter followed by string', () {
        final List<Token> tokens = getTokens('("hello")');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          StringToken(
            const Lexeme(
              value: 'hello',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 9),
            ),
          ),
        ]);
      });

      test('Delimiter followed by unary minus', () {
        final List<Token> tokens = getTokens('(-1)');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          MinusToken(
            const Lexeme(
              value: '-',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Delimiter followed by bang', () {
        final List<Token> tokens = getTokens('(!true)');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          BangToken(
            const Lexeme(
              value: '!',
              location: Location(row: 1, column: 2),
            ),
          ),
          BooleanToken(
            const Lexeme(
              value: 'true',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });
    });

    // --- String escape sequences ---

    group('String escape sequences', () {
      test('Double quoted string with newline escape', () {
        final List<Token> tokens = getTokens('"hello\\nworld"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'hello\nworld',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Single quoted string with tab escape', () {
        final List<Token> tokens = getTokens("'hello\\tworld'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'hello\tworld',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Double quoted string with backslash escape', () {
        final List<Token> tokens = getTokens('"path\\\\to"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'path\\to',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Escaped double quote inside double quoted string', () {
        final List<Token> tokens = getTokens('"say \\"hi\\""');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'say "hi"',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Escaped single quote inside single quoted string', () {
        final List<Token> tokens = getTokens("'it\\'s'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: "it's",
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Multiple escapes in one string', () {
        final List<Token> tokens = getTokens('"a\\nb\\tc"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'a\nb\tc',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Escape at start of string', () {
        final List<Token> tokens = getTokens('"\\nhello"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\nhello',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Escape at end of string', () {
        final List<Token> tokens = getTokens('"hello\\n"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'hello\n',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Invalid escape sequence in double quoted string', () {
        expect(
          () => getTokens('"hello\\z"'),
          throwsA(isA<InvalidEscapeSequenceError>()),
        );
      });

      test('Invalid escape sequence in single quoted string', () {
        expect(
          () => getTokens("'hello\\z'"),
          throwsA(isA<InvalidEscapeSequenceError>()),
        );
      });

      test('Escaped single quote in double quoted string', () {
        final List<Token> tokens = getTokens(r'''"it\'s"''');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: "it's",
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Escaped double quote in single quoted string', () {
        final List<Token> tokens = getTokens("'say \\\"hi\\\"'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'say "hi"',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Unterminated string ending with backslash (double quote)', () {
        expect(
          () => getTokensDirect('"hello\\'),
          throwsA(isA<UnterminatedStringError>()),
        );
      });

      test('Unterminated string ending with backslash (single quote)', () {
        expect(
          () => getTokensDirect("'hello\\"),
          throwsA(isA<UnterminatedStringError>()),
        );
      });
    });

    // --- Unicode escape sequences ---

    group('Unicode escape sequences', () {
      // Valid \xXX escapes
      test('\\xXX escape for A', () {
        final List<Token> tokens = getTokens('"\\x41"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\xXX escape for null character', () {
        final List<Token> tokens = getTokens('"\\x00"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\x00',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\xXX escape lowercase hex', () {
        final List<Token> tokens = getTokens('"\\x6a"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'j',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      // Valid \uXXXX escapes
      test('\\uXXXX escape for A', () {
        final List<Token> tokens = getTokens('"\\u0041"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\uXXXX escape for Greek alpha', () {
        final List<Token> tokens = getTokens('"\\u03B1"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'α',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\uXXXX escape for null character', () {
        final List<Token> tokens = getTokens('"\\u0000"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\u0000',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      // Valid \u{...} escapes
      test('\\u{...} escape short form', () {
        final List<Token> tokens = getTokens('"\\u{41}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape with leading zeros', () {
        final List<Token> tokens = getTokens('"\\u{0041}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape for Greek alpha', () {
        final List<Token> tokens = getTokens('"\\u{3B1}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'α',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape for emoji', () {
        final List<Token> tokens = getTokens('"\\u{1F600}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '😀',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape for max code point', () {
        final List<Token> tokens = getTokens('"\\u{10FFFF}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\u{10FFFF}',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      // Mixed escapes
      test('Multiple \\uXXXX escapes', () {
        final List<Token> tokens = getTokens('"\\u0041\\u0042"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'AB',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape mixed with text', () {
        final List<Token> tokens = getTokens('"\\u{48}ello"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'Hello',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\xXX escape for quotes', () {
        final List<Token> tokens = getTokens('"Say \\x22hi\\x22"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'Say "hi"',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      // Single quoted strings with unicode escapes
      test('\\xXX escape in single quoted string', () {
        final List<Token> tokens = getTokens("'\\x41'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\uXXXX escape in single quoted string', () {
        final List<Token> tokens = getTokens("'\\u0041'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape in single quoted string', () {
        final List<Token> tokens = getTokens("'\\u{1F600}'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '😀',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      // Invalid escapes
      test('\\u with only 2 digits', () {
        expect(
          () => getTokens('"\\u41"'),
          throwsA(isA<InvalidHexEscapeError>()),
        );
      });

      test('\\uXXXX with non-hex character', () {
        expect(
          () => getTokens('"\\uGGGG"'),
          throwsA(isA<InvalidHexEscapeError>()),
        );
      });

      test('\\x with only 1 digit', () {
        expect(
          () => getTokens('"\\x4"'),
          throwsA(isA<InvalidHexEscapeError>()),
        );
      });

      test('\\xXX with non-hex character', () {
        expect(
          () => getTokens('"\\xGG"'),
          throwsA(isA<InvalidHexEscapeError>()),
        );
      });

      test('\\u{} empty braces', () {
        expect(
          () => getTokens('"\\u{}"'),
          throwsA(isA<InvalidBracedEscapeError>()),
        );
      });

      test('\\u{...} with non-hex character', () {
        expect(
          () => getTokens('"\\u{GGGG}"'),
          throwsA(isA<InvalidBracedEscapeError>()),
        );
      });

      test('\\u{...} with too many digits', () {
        expect(
          () => getTokens('"\\u{1234567}"'),
          throwsA(isA<InvalidBracedEscapeError>()),
        );
      });

      test('\\u{...} exceeds max code point', () {
        expect(
          () => getTokens('"\\u{110000}"'),
          throwsA(isA<InvalidCodePointError>()),
        );
      });

      test('\\u{...} missing closing brace', () {
        expect(
          () => getTokens('"\\u{41"'),
          throwsA(isA<InvalidBracedEscapeError>()),
        );
      });

      test('Unterminated string in \\uXXXX escape', () {
        expect(
          () => getTokensDirect('"\\u004'),
          throwsA(isA<UnterminatedStringError>()),
        );
      });

      test('Unterminated string in \\xXX escape', () {
        expect(
          () => getTokensDirect('"\\x4'),
          throwsA(isA<UnterminatedStringError>()),
        );
      });

      test('Unterminated string in \\u{...} escape', () {
        expect(
          () => getTokensDirect('"\\u{41'),
          throwsA(isA<UnterminatedStringError>()),
        );
      });

      test('Unterminated string after \\u', () {
        expect(
          () => getTokensDirect('"\\u'),
          throwsA(isA<UnterminatedStringError>()),
        );
      });
    });

    // --- Additional edge cases: end-of-input states ---

    group('End-of-input state handling', () {
      test('Exponent number at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('1e10');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e10',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Decimal exponent at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('3.14e2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14e2',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('and keyword at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('and');
        checkTokens(tokens, [
          DoubleAmpersandToken(
            const Lexeme(
              value: '&&',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('or keyword at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('or');
        checkTokens(tokens, [
          DoublePipeToken(
            const Lexeme(
              value: '||',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('not keyword at end of input (no trailing delimiter)', () {
        final List<Token> tokens = getTokensDirect('not');
        checkTokens(tokens, [
          BangToken(
            const Lexeme(
              value: '!',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Incomplete exponent with minus sign at end of input', () {
        expect(() => getTokensDirect('1e-'), throwsA(isA<LexicalError>()));
      });

      test('Integer with underscore at end of input', () {
        final List<Token> tokens = getTokensDirect('1_000');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1000',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Decimal with underscore at end of input', () {
        final List<Token> tokens = getTokensDirect('3.14_15');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.1415',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Exponent with underscore at end of input', () {
        final List<Token> tokens = getTokensDirect('1e1_0');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e10',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Exponent trailing underscore at end of input', () {
        expect(() => getTokensDirect('1e10_'), throwsA(isA<LexicalError>()));
      });
    });

    // --- Whitespace edge cases ---

    group('Whitespace edge cases', () {
      test('Carriage return normalized to newline by source reader', () {
        // Note: SourceReader normalizes \r and \r\n to \n before lexing
        // So 'x\r=\ry' becomes 'x\n=\ny' and splits into 3 rows
        final List<Token> tokens = getTokens('x\r=\ry');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          AssignToken(
            const Lexeme(
              value: '=',
              location: Location(row: 2, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'y',
              location: Location(row: 3, column: 1),
            ),
          ),
        ]);
      });

      test('Newline only input', () {
        final List<Token> tokens = getTokens('\n');
        checkTokens(tokens, []);
      });

      test('Mixed whitespace characters', () {
        // Note: \r\n is normalized to single \n by source reader
        final List<Token> tokens = getTokens('x \t\r\n y');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'y',
              location: Location(row: 2, column: 2),
            ),
          ),
        ]);
      });
    });

    // --- Comment edge cases ---

    group('Comment edge cases', () {
      test('Single line comment at end of input without newline', () {
        final List<Token> tokens = getTokens('x = 1 // comment');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          AssignToken(
            const Lexeme(
              value: '=',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Empty single line comment', () {
        final List<Token> tokens = getTokens('//\nx');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 2, column: 1),
            ),
          ),
        ]);
      });

      test('Empty multi-line comment', () {
        final List<Token> tokens = getTokens('/**/x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Multi-line comment with asterisk in content', () {
        final List<Token> tokens = getTokens('/* a * b */x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 12),
            ),
          ),
        ]);
      });

      test('Unterminated multi-line comment ending with asterisk', () {
        expect(
          () => getTokens('/* comment *'),
          throwsA(isA<UnterminatedCommentError>()),
        );
      });

      test('Division followed by division (not comment)', () {
        final List<Token> tokens = getTokens('a / b / c');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          ForwardSlashToken(
            const Lexeme(
              value: '/',
              location: Location(row: 1, column: 3),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 5),
            ),
          ),
          ForwardSlashToken(
            const Lexeme(
              value: '/',
              location: Location(row: 1, column: 7),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'c',
              location: Location(row: 1, column: 9),
            ),
          ),
        ]);
      });

      test('Multiplication not starting comment', () {
        final List<Token> tokens = getTokens('a * b');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          AsteriskToken(
            const Lexeme(
              value: '*',
              location: Location(row: 1, column: 3),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });
    });

    // --- Operator boundary cases ---

    group('Operator boundary cases', () {
      test('Double equals followed by identifier', () {
        final List<Token> tokens = getTokens('==x');
        checkTokens(tokens, [
          EqualToken(
            const Lexeme(
              value: '==',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Not equals followed by identifier', () {
        final List<Token> tokens = getTokens('!=x');
        checkTokens(tokens, [
          NotEqualToken(
            const Lexeme(
              value: '!=',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Greater or equal followed by number', () {
        final List<Token> tokens = getTokens('>=5');
        checkTokens(tokens, [
          GreaterOrEqualToken(
            const Lexeme(
              value: '>=',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Less or equal followed by number', () {
        final List<Token> tokens = getTokens('<=5');
        checkTokens(tokens, [
          LessOrEqualToken(
            const Lexeme(
              value: '<=',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Pipe followed by open parenthesis', () {
        final List<Token> tokens = getTokens('|(x)');
        checkTokens(tokens, [
          PipeToken(
            const Lexeme(
              value: '|',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Ampersand followed by open parenthesis', () {
        final List<Token> tokens = getTokens('&(x)');
        checkTokens(tokens, [
          AmpersandToken(
            const Lexeme(
              value: '&',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Minus followed by open parenthesis', () {
        final List<Token> tokens = getTokens('-(x)');
        checkTokens(tokens, [
          MinusToken(
            const Lexeme(
              value: '-',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Plus followed by open parenthesis', () {
        final List<Token> tokens = getTokens('+(x)');
        checkTokens(tokens, [
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Percent followed by number', () {
        final List<Token> tokens = getTokens('%5');
        checkTokens(tokens, [
          PercentToken(
            const Lexeme(
              value: '%',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Asterisk followed by number', () {
        final List<Token> tokens = getTokens('*5');
        checkTokens(tokens, [
          AsteriskToken(
            const Lexeme(
              value: '*',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('Forward slash followed by number', () {
        final List<Token> tokens = getTokens('/5');
        checkTokens(tokens, [
          ForwardSlashToken(
            const Lexeme(
              value: '/',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });
    });

    // --- Token equality and string representation ---

    group('Token equality and representation', () {
      test('Token equality with same values', () {
        final Token token1 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token token2 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(token1, equals(token2));
      });

      test('Token inequality with different values', () {
        final Token token1 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token token2 = NumberToken(
          const Lexeme(
            value: '43',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(token1, isNot(equals(token2)));
      });

      test('Token inequality with different locations', () {
        final Token token1 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token token2 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 2),
          ),
        );
        expect(token1, isNot(equals(token2)));
      });

      test('Token inequality with different types', () {
        final Token token1 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token token2 = IdentifierToken(
          const Lexeme(
            value: 'x',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(token1, isNot(equals(token2)));
      });

      test('Token toString returns formatted string', () {
        final Token token = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(token.toString(), equals('"42" at [1, 1]'));
      });

      test('Token hashCode consistency', () {
        final Token token1 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token token2 = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(token1.hashCode, equals(token2.hashCode));
      });
    });

    // --- Number edge cases ---

    group('Number edge cases', () {
      test('Single digit zero', () {
        final List<Token> tokens = getTokens('0');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Decimal with single digit after dot', () {
        final List<Token> tokens = getTokens('3.1');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.1',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Exponent with zero', () {
        final List<Token> tokens = getTokens('1e0');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e0',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Decimal with zero fractional part', () {
        final List<Token> tokens = getTokens('1.0');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1.0',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Zero with exponent', () {
        final List<Token> tokens = getTokens('0e5');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '0e5',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Zero decimal with exponent', () {
        final List<Token> tokens = getTokens('0.0e1');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '0.0e1',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Very large exponent', () {
        final List<Token> tokens = getTokens('1e999');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e999',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Very small exponent', () {
        final List<Token> tokens = getTokens('1e-999');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e-999',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Number followed by open bracket', () {
        final List<Token> tokens = getTokens('42[0]');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Number followed by close parenthesis', () {
        final List<Token> tokens = getTokens('(42)');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Number followed by comma', () {
        final List<Token> tokens = getTokens('1,2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 1),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Number followed by colon', () {
        final List<Token> tokens = getTokens('1:2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 1),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });
    });

    // --- Identifier edge cases ---

    group('Identifier edge cases', () {
      test('Single letter identifier', () {
        final List<Token> tokens = getTokens('x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier with leading uppercase', () {
        final List<Token> tokens = getTokens('MyVar');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'MyVar',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier with multiple dots', () {
        final List<Token> tokens = getTokens('a.b.c');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a.b.c',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier with multiple underscores', () {
        final List<Token> tokens = getTokens('a__b');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a__b',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier with trailing underscore', () {
        final List<Token> tokens = getTokens('x_');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x_',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier with trailing dot', () {
        final List<Token> tokens = getTokens('x.');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x.',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier followed by open parenthesis', () {
        final List<Token> tokens = getTokens('foo(x)');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'foo',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 4),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Identifier followed by open bracket', () {
        final List<Token> tokens = getTokens('arr[0]');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'arr',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 4),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Identifier containing and', () {
        final List<Token> tokens = getTokens('expand');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'expand',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier containing or', () {
        final List<Token> tokens = getTokens('origin');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'origin',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });
    });

    // --- String edge cases ---

    group('String edge cases', () {
      test('String with only escape sequences', () {
        final List<Token> tokens = getTokens('"\\n\\t"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\n\t',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('String with consecutive escapes', () {
        final List<Token> tokens = getTokens('"\\n\\n\\n"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\n\n\n',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('String with spaces', () {
        final List<Token> tokens = getTokens('"  "');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '  ',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('String with mixed unicode and regular escapes', () {
        final List<Token> tokens = getTokens('"\\x41\\n\\u0042"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'A\nB',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('String containing actual newline character', () {
        // Note: this uses a literal newline within the string in source code
        // which should be preserved by the lexer
        final List<Token> tokens = getTokens('"line1\nline2"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'line1\nline2',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });
    });

    // --- Lexeme equality ---

    group('Lexeme class', () {
      test('Lexeme equality with same values', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        expect(lexeme1, equals(lexeme2));
      });

      test('Lexeme inequality with different values', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'other',
          location: Location(row: 1, column: 1),
        );
        expect(lexeme1, isNot(equals(lexeme2)));
      });

      test('Lexeme inequality with different locations', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 2, column: 1),
        );
        expect(lexeme1, isNot(equals(lexeme2)));
      });

      test('Lexeme hashCode consistency', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        expect(lexeme1.hashCode, equals(lexeme2.hashCode));
      });

      test('Lexeme add method creates new lexeme', () {
        const Lexeme lexeme = Lexeme(
          value: 'ab',
          location: Location(row: 1, column: 1),
        );
        final Lexeme newLexeme = lexeme.add('c');
        expect(newLexeme.value, equals('abc'));
        expect(newLexeme.location, equals(lexeme.location));
        expect(lexeme.value, equals('ab')); // Original unchanged
      });
    });

    // --- Scientific notation edge cases ---

    group('Scientific notation edge cases', () {
      test('Exponent with negative sign immediately followed by digit', () {
        final List<Token> tokens = getTokens('5e-2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '5e-2',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Exponent with positive sign immediately followed by digit', () {
        final List<Token> tokens = getTokens('5e+2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '5e+2',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Invalid character in exponent after digit', () {
        expect(() => getTokens('1e5x'), throwsA(isA<InvalidCharacterError>()));
      });

      test('Double e in number', () {
        expect(() => getTokens('1ee5'), throwsA(isA<InvalidCharacterError>()));
      });

      test('E after decimal without following exponent', () {
        expect(() => getTokens('1.2e'), throwsA(isA<LexicalError>()));
      });

      test('Lowercase e exponent followed by delimiter', () {
        final List<Token> tokens = getTokens('1e5)');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Uppercase E exponent followed by delimiter', () {
        final List<Token> tokens = getTokens('1E5]');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1E5',
              location: Location(row: 1, column: 1),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });
    });

    // --- Complex expressions ---

    group('Complex expressions', () {
      test('Nested function call', () {
        final List<Token> tokens = getTokens('f(g(x))');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'f',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'g',
              location: Location(row: 1, column: 3),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 4),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 6),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('Chained comparison', () {
        final List<Token> tokens = getTokens('a==b!=c');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          EqualToken(
            const Lexeme(
              value: '==',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 4),
            ),
          ),
          NotEqualToken(
            const Lexeme(
              value: '!=',
              location: Location(row: 1, column: 5),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'c',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('Lambda-like expression', () {
        final List<Token> tokens = getTokens('(x) = x + 1');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 3),
            ),
          ),
          AssignToken(
            const Lexeme(
              value: '=',
              location: Location(row: 1, column: 5),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 7),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 9),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 11),
            ),
          ),
        ]);
      });

      test('Multiple binary operators', () {
        final List<Token> tokens = getTokens('1+2-3*4/5%6');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 1),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 3),
            ),
          ),
          MinusToken(
            const Lexeme(
              value: '-',
              location: Location(row: 1, column: 4),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '3',
              location: Location(row: 1, column: 5),
            ),
          ),
          AsteriskToken(
            const Lexeme(
              value: '*',
              location: Location(row: 1, column: 6),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '4',
              location: Location(row: 1, column: 7),
            ),
          ),
          ForwardSlashToken(
            const Lexeme(
              value: '/',
              location: Location(row: 1, column: 8),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 9),
            ),
          ),
          PercentToken(
            const Lexeme(
              value: '%',
              location: Location(row: 1, column: 10),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '6',
              location: Location(row: 1, column: 11),
            ),
          ),
        ]);
      });

      test('Multiple logical operators', () {
        final List<Token> tokens = getTokens('a|b&c');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          PipeToken(
            const Lexeme(
              value: '|',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 3),
            ),
          ),
          AmpersandToken(
            const Lexeme(
              value: '&',
              location: Location(row: 1, column: 4),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'c',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });
    });

    // --- Additional coverage tests ---

    group('Token equality edge cases', () {
      test('Token equality with identical object', () {
        final Token token = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        // ignore: unnecessary_statements
        expect(token == token, isTrue);
      });

      test('Token inequality with non-Token object', () {
        final Token token = NumberToken(
          const Lexeme(
            value: '42',
            location: Location(row: 1, column: 1),
          ),
        );
        // ignore: unrelated_type_equality_checks
        expect(token == 'not a token', isFalse);
        // ignore: unrelated_type_equality_checks
        expect(token == 42, isFalse);
      });
    });

    group('Unicode escape edge cases', () {
      test('\\uXXXX escape with mixed case hex digits', () {
        final List<Token> tokens = getTokens('"\\uAb12"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\uAB12',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\xXX escape with mixed case hex digits', () {
        final List<Token> tokens = getTokens('"\\x4f"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'O',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape with single digit', () {
        final List<Token> tokens = getTokens('"\\u{0}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\u0000',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape with lowercase hex digits', () {
        final List<Token> tokens = getTokens('"\\u{1f600}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '😀',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('\\u{...} escape with max 6 digits', () {
        final List<Token> tokens = getTokens('"\\u{10ffff}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: '\u{10FFFF}',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });
    });

    group('Identifier keyword prefix edge cases', () {
      test('Identifier starting with and', () {
        final List<Token> tokens = getTokens('andromeda');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'andromeda',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Identifier starting with or', () {
        final List<Token> tokens = getTokens('ordinal');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'ordinal',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });
    });

    group('At token edge cases', () {
      test('Adjacent at tokens', () {
        final List<Token> tokens = getTokens('@@');
        checkTokens(tokens, [
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 1),
            ),
          ),
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('At token followed by identifier', () {
        final List<Token> tokens = getTokens('@foo');
        checkTokens(tokens, [
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'foo',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('At token followed by string', () {
        final List<Token> tokens = getTokens('@"test"');
        checkTokens(tokens, [
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 1),
            ),
          ),
          StringToken(
            const Lexeme(
              value: 'test',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });

      test('At token followed by open parenthesis', () {
        final List<Token> tokens = getTokens('@(x)');
        checkTokens(tokens, [
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 2),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });
    });

    group('Comment edge cases (additional)', () {
      test('Empty single-line comment at end of file', () {
        final List<Token> tokens = getTokens('x//');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Single-line comment with only whitespace', () {
        final List<Token> tokens = getTokens('//   \nx');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 2, column: 1),
            ),
          ),
        ]);
      });

      test('Consecutive single-line comments', () {
        final List<Token> tokens = getTokens('//a\n//b\nx');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 3, column: 1),
            ),
          ),
        ]);
      });

      test('Multi-line comment immediately followed by token', () {
        final List<Token> tokens = getTokens('/**/1');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });
    });

    group('Underscore in numbers (additional)', () {
      test('Underscore before exponent in decimal throws error', () {
        expect(
          () => getTokens('3.14_e10'),
          throwsA(isA<InvalidCharacterError>()),
        );
      });

      test('Underscore before exponent in integer throws error', () {
        expect(() => getTokens('1_e10'), throwsA(isA<InvalidCharacterError>()));
      });
    });

    group('Lexeme edge cases', () {
      test('Lexeme inequality with non-Lexeme object', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        // ignore: unrelated_type_equality_checks
        expect(lexeme == 'not a lexeme', isFalse);
        // ignore: unrelated_type_equality_checks
        expect(lexeme == 42, isFalse);
      });

      test('Lexeme add with empty string', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        final Lexeme newLexeme = lexeme.add('');
        expect(newLexeme.value, equals('test'));
        expect(newLexeme.location, equals(lexeme.location));
      });
    });

    group('String termination edge cases', () {
      test('Single quoted string followed by single quoted string', () {
        final List<Token> tokens = getTokens("'a''b'");
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          StringToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Double quoted string followed by double quoted string', () {
        final List<Token> tokens = getTokens('"a""b"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          StringToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });
    });

    group('Delimiter and operator transitions', () {
      test('Close bracket followed by open bracket', () {
        final List<Token> tokens = getTokens('][][');
        checkTokens(tokens, [
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 3),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Operator followed by open braces', () {
        final List<Token> tokens = getTokens('+{}');
        checkTokens(tokens, [
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Comma followed by open bracket', () {
        final List<Token> tokens = getTokens(',[');
        checkTokens(tokens, [
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 2),
            ),
          ),
        ]);
      });
    });

    group('Boolean and keyword boundary tests', () {
      test('Boolean true immediately followed by operator', () {
        final List<Token> tokens = getTokens('true+1');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'true',
              location: Location(row: 1, column: 1),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Boolean false immediately followed by operator', () {
        final List<Token> tokens = getTokens('false|x');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'false',
              location: Location(row: 1, column: 1),
            ),
          ),
          PipeToken(
            const Lexeme(
              value: '|',
              location: Location(row: 1, column: 6),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('If keyword immediately followed by open parenthesis', () {
        final List<Token> tokens = getTokens('if(x)');
        checkTokens(tokens, [
          IfToken(
            const Lexeme(
              value: 'if',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 3),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Else keyword immediately followed by open braces', () {
        final List<Token> tokens = getTokens('else{}');
        checkTokens(tokens, [
          ElseToken(
            const Lexeme(
              value: 'else',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });
    });

    group('Invalid escape sequence variations', () {
      test('Invalid escape sequence \\a', () {
        expect(
          () => getTokens('"\\a"'),
          throwsA(isA<InvalidEscapeSequenceError>()),
        );
      });

      test('Invalid escape sequence \\0 (not hex)', () {
        expect(
          () => getTokens('"\\0"'),
          throwsA(isA<InvalidEscapeSequenceError>()),
        );
      });
    });

    group('Number followed by various delimiters', () {
      test('Number followed by open braces', () {
        final List<Token> tokens = getTokens('1{}');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Number followed by close braces', () {
        final List<Token> tokens = getTokens('{1}');
        checkTokens(tokens, [
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Number followed by close bracket', () {
        final List<Token> tokens = getTokens('[1]');
        checkTokens(tokens, [
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });
    });

    group('Exponent edge cases', () {
      test('Exponent followed by open parenthesis', () {
        final List<Token> tokens = getTokens('1e5(x)');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 4),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Exponent followed by comma', () {
        final List<Token> tokens = getTokens('1e5,2e3');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 1),
            ),
          ),
          CommaToken(
            const Lexeme(
              value: ',',
              location: Location(row: 1, column: 4),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2e3',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Exponent followed by colon', () {
        final List<Token> tokens = getTokens('1e5:2e3');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 1),
            ),
          ),
          ColonToken(
            const Lexeme(
              value: ':',
              location: Location(row: 1, column: 4),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2e3',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });
    });

    group('Decimal edge cases', () {
      test('Decimal followed by open bracket', () {
        final List<Token> tokens = getTokens('3.14[0]');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 6),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('Decimal followed by close parenthesis', () {
        final List<Token> tokens = getTokens('(3.14)');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });
    });

    group('Multi-line comment state transitions', () {
      test('Multi-line comment with slash in content', () {
        final List<Token> tokens = getTokens('/* a / b */x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 12),
            ),
          ),
        ]);
      });

      test('Multi-line comment ending with multiple asterisks', () {
        final List<Token> tokens = getTokens('/*****/x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 8),
            ),
          ),
        ]);
      });

      test('Multi-line comment with asterisk-slash sequence not at end', () {
        final List<Token> tokens = getTokens('/* text * / more */x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 20),
            ),
          ),
        ]);
      });
    });

    group('Identifier followed by various operators', () {
      test('Identifier followed by minus', () {
        final List<Token> tokens = getTokens('x-1');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          MinusToken(
            const Lexeme(
              value: '-',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Identifier followed by asterisk', () {
        final List<Token> tokens = getTokens('x*2');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          AsteriskToken(
            const Lexeme(
              value: '*',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Identifier followed by forward slash', () {
        final List<Token> tokens = getTokens('x/2');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          ForwardSlashToken(
            const Lexeme(
              value: '/',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Identifier followed by percent', () {
        final List<Token> tokens = getTokens('x%2');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          PercentToken(
            const Lexeme(
              value: '%',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Identifier followed by at', () {
        final List<Token> tokens = getTokens('x@0');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Identifier followed by greater than', () {
        final List<Token> tokens = getTokens('x>0');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          GreaterThanToken(
            const Lexeme(
              value: '>',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });

      test('Identifier followed by less than', () {
        final List<Token> tokens = getTokens('x<0');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          LessThanToken(
            const Lexeme(
              value: '<',
              location: Location(row: 1, column: 2),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 3),
            ),
          ),
        ]);
      });
    });

    // --- Location class tests ---

    group('Location class', () {
      test('Location toString returns formatted string', () {
        const Location location = Location(row: 5, column: 10);
        expect(location.toString(), equals('[5, 10]'));
      });

      test('Location equality with identical object', () {
        const Location location = Location(row: 1, column: 1);
        // ignore: unnecessary_statements
        expect(location == location, isTrue);
      });

      test('Location equality with same values', () {
        const Location location1 = Location(row: 1, column: 1);
        const Location location2 = Location(row: 1, column: 1);
        expect(location1, equals(location2));
      });

      test('Location inequality with different row', () {
        const Location location1 = Location(row: 1, column: 1);
        const Location location2 = Location(row: 2, column: 1);
        expect(location1, isNot(equals(location2)));
      });

      test('Location inequality with different column', () {
        const Location location1 = Location(row: 1, column: 1);
        const Location location2 = Location(row: 1, column: 2);
        expect(location1, isNot(equals(location2)));
      });

      test('Location inequality with non-Location object', () {
        const Location location = Location(row: 1, column: 1);
        // ignore: unrelated_type_equality_checks
        expect(location == 'not a location', isFalse);
        // ignore: unrelated_type_equality_checks
        expect(location == 42, isFalse);
      });

      test('Location hashCode consistency', () {
        const Location location1 = Location(row: 5, column: 10);
        const Location location2 = Location(row: 5, column: 10);
        expect(location1.hashCode, equals(location2.hashCode));
      });
    });

    // --- Token value type tests ---

    group('Token value types', () {
      test('NumberToken value is num type', () {
        final List<Token> tokens = getTokens('42');
        expect(tokens.first, isA<NumberToken>());
        expect((tokens.first as NumberToken).value, isA<num>());
        expect((tokens.first as NumberToken).value, equals(42));
      });

      test('NumberToken value parses decimal correctly', () {
        final List<Token> tokens = getTokens('3.14');
        expect(tokens.first, isA<NumberToken>());
        expect((tokens.first as NumberToken).value, equals(3.14));
      });

      test('NumberToken value parses scientific notation correctly', () {
        final List<Token> tokens = getTokens('1e3');
        expect(tokens.first, isA<NumberToken>());
        expect((tokens.first as NumberToken).value, equals(1000));
      });

      test('BooleanToken value is bool type', () {
        final List<Token> tokens = getTokens('true');
        expect(tokens.first, isA<BooleanToken>());
        expect((tokens.first as BooleanToken).value, isA<bool>());
        expect((tokens.first as BooleanToken).value, isTrue);
      });

      test('BooleanToken false value', () {
        final List<Token> tokens = getTokens('false');
        expect(tokens.first, isA<BooleanToken>());
        expect((tokens.first as BooleanToken).value, isFalse);
      });

      test('StringToken value is String type', () {
        final List<Token> tokens = getTokens('"hello"');
        expect(tokens.first, isA<StringToken>());
        expect((tokens.first as StringToken).value, isA<String>());
        expect((tokens.first as StringToken).value, equals('hello'));
      });

      test('IdentifierToken value is String type', () {
        final List<Token> tokens = getTokens('myIdentifier');
        expect(tokens.first, isA<IdentifierToken>());
        expect((tokens.first as IdentifierToken).value, isA<String>());
        expect((tokens.first as IdentifierToken).value, equals('myIdentifier'));
      });
    });

    // --- Operator state end-of-input tests ---
    // Note: The lexer does not flush operator states at EOF (no trailing newline),
    // so single operators at EOF are dropped. These tests verify this behavior.
    // Two-character operators like == produce a result because the second char
    // acts as an operand delimiter for the first.

    group('Operator state end-of-input handling', () {
      test('Minus at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('-');
        checkTokens(tokens, []);
      });

      test('Plus at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('+');
        checkTokens(tokens, []);
      });

      test('Equals at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('=');
        checkTokens(tokens, []);
      });

      test('Double equals at end of input produces equal token', () {
        final List<Token> tokens = getTokensDirect('==');
        checkTokens(tokens, [
          EqualToken(
            const Lexeme(
              value: '==',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Greater at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('>');
        checkTokens(tokens, []);
      });

      test('Greater or equal at end of input produces token', () {
        final List<Token> tokens = getTokensDirect('>=');
        checkTokens(tokens, [
          GreaterOrEqualToken(
            const Lexeme(
              value: '>=',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Less at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('<');
        checkTokens(tokens, []);
      });

      test('Less or equal at end of input produces token', () {
        final List<Token> tokens = getTokensDirect('<=');
        checkTokens(tokens, [
          LessOrEqualToken(
            const Lexeme(
              value: '<=',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Pipe at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('|');
        checkTokens(tokens, []);
      });

      test('Double pipe at end of input produces double pipe token', () {
        final List<Token> tokens = getTokensDirect('||');
        checkTokens(tokens, [
          DoublePipeToken(
            const Lexeme(
              value: '||',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Ampersand at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('&');
        checkTokens(tokens, []);
      });

      test(
        'Double ampersand at end of input produces double ampersand token',
        () {
          final List<Token> tokens = getTokensDirect('&&');
          checkTokens(tokens, [
            DoubleAmpersandToken(
              const Lexeme(
                value: '&&',
                location: Location(row: 1, column: 1),
              ),
            ),
          ]);
        },
      );

      test('Bang at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('!');
        checkTokens(tokens, []);
      });

      test('Not equal at end of input produces token', () {
        final List<Token> tokens = getTokensDirect('!=');
        checkTokens(tokens, [
          NotEqualToken(
            const Lexeme(
              value: '!=',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Forward slash at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('/');
        checkTokens(tokens, []);
      });

      test('Asterisk at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('*');
        checkTokens(tokens, []);
      });

      test('Percent at end of input is dropped (no flush)', () {
        final List<Token> tokens = getTokensDirect('%');
        checkTokens(tokens, []);
      });

      test('At token is emitted immediately (no state)', () {
        // At token produces a ResultState immediately, no pending state
        final List<Token> tokens = getTokensDirect('@');
        checkTokens(tokens, [
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('Operators followed by newline are emitted', () {
        // Using getTokens which adds a trailing newline
        final List<Token> tokens = getTokens('-');
        checkTokens(tokens, [
          MinusToken(
            const Lexeme(
              value: '-',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });
    });

    // --- Shebang edge cases ---

    group('Shebang edge cases', () {
      test('Shebang only input', () {
        final List<Token> tokens = getTokens('#!/bin/primal');
        checkTokens(tokens, []);
      });

      test('Shebang with empty second line', () {
        final List<Token> tokens = getTokens('#!/bin/primal\n\n42');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 3, column: 1),
            ),
          ),
        ]);
      });

      test('Shebang not on first line is invalid', () {
        expect(
          () => getTokens('\n#!/bin/primal'),
          throwsA(isA<InvalidCharacterError>()),
        );
      });
    });

    // --- Escape sequence carriage return ---
    // Note: \\r is not a supported escape sequence (only \\n, \\t, \\\\, \\', \\", \\xXX, \\uXXXX, \\u{...})

    group('Escape sequence carriage return', () {
      test('Escape sequence \\r in double quoted string throws error', () {
        expect(
          () => getTokens('"hello\\rworld"'),
          throwsA(isA<InvalidEscapeSequenceError>()),
        );
      });

      test('Escape sequence \\r in single quoted string throws error', () {
        expect(
          () => getTokens("'hello\\rworld'"),
          throwsA(isA<InvalidEscapeSequenceError>()),
        );
      });
    });

    // --- Token runtimeType in equality ---

    group('Token type discrimination', () {
      test('Different token types with same value are not equal', () {
        final Token identifierToken = IdentifierToken(
          const Lexeme(
            value: 'true',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token ifToken = IfToken(
          const Lexeme(
            value: 'if',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(identifierToken, isNot(equals(ifToken)));
      });

      test('Same token type with same value and location are equal', () {
        final Token token1 = IdentifierToken(
          const Lexeme(
            value: 'foo',
            location: Location(row: 1, column: 1),
          ),
        );
        final Token token2 = IdentifierToken(
          const Lexeme(
            value: 'foo',
            location: Location(row: 1, column: 1),
          ),
        );
        expect(token1, equals(token2));
      });
    });

    // --- Decimal state transitions ---

    group('Decimal state transitions', () {
      test('Decimal followed by operator', () {
        final List<Token> tokens = getTokens('3.14+1');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 1),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Decimal followed by minus', () {
        final List<Token> tokens = getTokens('3.14-1');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 1),
            ),
          ),
          MinusToken(
            const Lexeme(
              value: '-',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Decimal followed by asterisk', () {
        final List<Token> tokens = getTokens('3.14*2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 1),
            ),
          ),
          AsteriskToken(
            const Lexeme(
              value: '*',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Decimal followed by forward slash', () {
        final List<Token> tokens = getTokens('3.14/2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '3.14',
              location: Location(row: 1, column: 1),
            ),
          ),
          ForwardSlashToken(
            const Lexeme(
              value: '/',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });
    });

    // --- Integer state transitions ---

    group('Integer state transitions', () {
      test('Integer followed by plus', () {
        final List<Token> tokens = getTokens('42+1');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 1),
            ),
          ),
          PlusToken(
            const Lexeme(
              value: '+',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Integer followed by asterisk', () {
        final List<Token> tokens = getTokens('42*2');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 1),
            ),
          ),
          AsteriskToken(
            const Lexeme(
              value: '*',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Integer followed by percent', () {
        final List<Token> tokens = getTokens('42%5');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 1),
            ),
          ),
          PercentToken(
            const Lexeme(
              value: '%',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '5',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Integer followed by at', () {
        final List<Token> tokens = getTokens('42@0');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 1),
            ),
          ),
          AtToken(
            const Lexeme(
              value: '@',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });
    });

    // --- String followed by various tokens ---

    group('String followed by various tokens', () {
      test('String followed by string', () {
        final List<Token> tokens = getTokens('"a" "b"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          StringToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('String followed by number', () {
        final List<Token> tokens = getTokens('"x" 42');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '42',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('String followed by identifier', () {
        final List<Token> tokens = getTokens('"x" foo');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'foo',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('String followed by open parenthesis', () {
        final List<Token> tokens = getTokens('"x"(1)');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 4),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });
    });

    // --- Boolean followed by various tokens ---

    group('Boolean followed by various tokens', () {
      test('Boolean followed by boolean', () {
        final List<Token> tokens = getTokens('true false');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'true',
              location: Location(row: 1, column: 1),
            ),
          ),
          BooleanToken(
            const Lexeme(
              value: 'false',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Boolean followed by open bracket', () {
        final List<Token> tokens = getTokens('true[0]');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'true',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 5),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '0',
              location: Location(row: 1, column: 6),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('Boolean followed by open braces', () {
        final List<Token> tokens = getTokens('true{}');
        checkTokens(tokens, [
          BooleanToken(
            const Lexeme(
              value: 'true',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });
    });

    // --- Comment followed immediately by token ---

    group('Comment boundaries', () {
      test('Single line comment immediately followed by identifier', () {
        final List<Token> tokens = getTokens('//comment\nx');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 2, column: 1),
            ),
          ),
        ]);
      });

      test('Multi line comment on same line as tokens', () {
        final List<Token> tokens = getTokens('a/*comment*/b');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'a',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'b',
              location: Location(row: 1, column: 13),
            ),
          ),
        ]);
      });

      test('Multi line comment with only asterisks', () {
        final List<Token> tokens = getTokens('/****/x');
        checkTokens(tokens, [
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });
    });

    // --- Exponent state boundary tests ---

    group('Exponent state boundary tests', () {
      test('Exponent followed by open braces', () {
        final List<Token> tokens = getTokens('1e5{}');
        checkTokens(tokens, [
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Exponent followed by close bracket', () {
        final List<Token> tokens = getTokens('[1e5]');
        checkTokens(tokens, [
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });

      test('Exponent followed by close braces', () {
        final List<Token> tokens = getTokens('{1e5}');
        checkTokens(tokens, [
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1e5',
              location: Location(row: 1, column: 2),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 5),
            ),
          ),
        ]);
      });
    });

    // --- Unicode in identifiers and strings ---

    group('Unicode content', () {
      test('String with unicode characters', () {
        final List<Token> tokens = getTokens('"hello \u4e16\u754c"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'hello \u4e16\u754c',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });

      test('String with emoji', () {
        final List<Token> tokens = getTokens('"hello \u{1F600}"');
        checkTokens(tokens, [
          StringToken(
            const Lexeme(
              value: 'hello \u{1F600}',
              location: Location(row: 1, column: 1),
            ),
          ),
        ]);
      });
    });

    // --- Multiple operators in sequence ---
    // Note: Operators need proper delimiters between them. Most operators cannot
    // be directly followed by another operator (except when forming two-char ops).
    // These tests verify both valid and invalid operator sequences.

    group('Multiple operators in sequence', () {
      test('Consecutive operators without delimiter throws error', () {
        // > followed by < is invalid because < is not an operator delimiter
        expect(
          () => getTokens('><'),
          throwsA(isA<InvalidCharacterError>()),
        );
      });

      test('Operators separated by operand work', () {
        final List<Token> tokens = getTokens('>1<2');
        checkTokens(tokens, [
          GreaterThanToken(
            const Lexeme(
              value: '>',
              location: Location(row: 1, column: 1),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 2),
            ),
          ),
          LessThanToken(
            const Lexeme(
              value: '<',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '2',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('Logical operators with bang (bang is unary so valid after &&)', () {
        final List<Token> tokens = getTokens('||&&!x');
        checkTokens(tokens, [
          DoublePipeToken(
            const Lexeme(
              value: '||',
              location: Location(row: 1, column: 1),
            ),
          ),
          DoubleAmpersandToken(
            const Lexeme(
              value: '&&',
              location: Location(row: 1, column: 3),
            ),
          ),
          BangToken(
            const Lexeme(
              value: '!',
              location: Location(row: 1, column: 5),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });

      test('Triple equals parses as == followed by =', () {
        // === parses as == (first two) then = needs a delimiter
        // But = is not an operator delimiter for ==, so we need to check
        final List<Token> tokens = getTokens('===x');
        checkTokens(tokens, [
          EqualToken(
            const Lexeme(
              value: '==',
              location: Location(row: 1, column: 1),
            ),
          ),
          AssignToken(
            const Lexeme(
              value: '=',
              location: Location(row: 1, column: 3),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 4),
            ),
          ),
        ]);
      });

      test('== followed by != with identifier in between', () {
        final List<Token> tokens = getTokens('==x!=y');
        checkTokens(tokens, [
          EqualToken(
            const Lexeme(
              value: '==',
              location: Location(row: 1, column: 1),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'x',
              location: Location(row: 1, column: 3),
            ),
          ),
          NotEqualToken(
            const Lexeme(
              value: '!=',
              location: Location(row: 1, column: 4),
            ),
          ),
          IdentifierToken(
            const Lexeme(
              value: 'y',
              location: Location(row: 1, column: 6),
            ),
          ),
        ]);
      });
    });

    // --- Complex nested structures ---

    group('Complex nested structures', () {
      test('Deeply nested brackets', () {
        final List<Token> tokens = getTokens('[[[1]]]');
        checkTokens(tokens, [
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 2),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 3),
            ),
          ),
          NumberToken(
            const Lexeme(
              value: '1',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 6),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 7),
            ),
          ),
        ]);
      });

      test('Mixed nested delimiters', () {
        final List<Token> tokens = getTokens('([{()}])');
        checkTokens(tokens, [
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 1),
            ),
          ),
          OpenBracketToken(
            const Lexeme(
              value: '[',
              location: Location(row: 1, column: 2),
            ),
          ),
          OpenBracesToken(
            const Lexeme(
              value: '{',
              location: Location(row: 1, column: 3),
            ),
          ),
          OpenParenthesisToken(
            const Lexeme(
              value: '(',
              location: Location(row: 1, column: 4),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 5),
            ),
          ),
          CloseBracesToken(
            const Lexeme(
              value: '}',
              location: Location(row: 1, column: 6),
            ),
          ),
          CloseBracketToken(
            const Lexeme(
              value: ']',
              location: Location(row: 1, column: 7),
            ),
          ),
          CloseParenthesisToken(
            const Lexeme(
              value: ')',
              location: Location(row: 1, column: 8),
            ),
          ),
        ]);
      });
    });
  });
}
