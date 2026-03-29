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
        GreaterEqualThanToken(
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
        LessEqualThanToken(
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
      try {
        getFunctions('_isEven = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid function definition 2', () {
      try {
        getFunctions('_isEven(n) = n');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid function definition 3', () {
      try {
        getFunctions('isEvent(,) = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid function definition 4', () {
      try {
        getFunctions('isEvent(x,) = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
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
      final List<Token> tokens = getTokens('"hello');
      checkTokens(tokens, []);
    });

    test('Unterminated single quoted string', () {
      final List<Token> tokens = getTokens("'hello");
      checkTokens(tokens, []);
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
      try {
        getTokens('.5');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Number followed by dot and letter', () {
      try {
        getTokens('42.x');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
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
      final List<Token> tokens = getTokens('/* comment');
      checkTokens(tokens, []);
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

    test('Invalid character @', () {
      try {
        getTokens('@');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid character #', () {
      try {
        getTokens('#');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid character \$', () {
      try {
        getTokens('\$');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid character ~', () {
      try {
        getTokens('~');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
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
  });
}
