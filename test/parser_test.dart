import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/parser.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Parser', () {
    test('Expression 1', () {
      final List<Token> tokens = getTokens('2 - 1 * 3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '(2 - (1 * 3))');
    });

    test('Expression 2', () {
      final List<Token> tokens = getTokens('2 * 1 - 3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '((2 * 1) - 3)');
    });

    test('Expression 3', () {
      final List<Token> tokens = getTokens('(2 - 1) * 3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '((2 - 1) * 3)');
    });

    test('Expression 4', () {
      final List<Token> tokens = getTokens('(2 - 1) != 3 * 4');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '((2 - 1) != (3 * 4))');
    });

    test('Expression 5', () {
      final List<Token> tokens = getTokens('2 * 4 % 3 == 1 + 3 / 4');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '(((2 * 4) % 3) == (1 + (3 / 4)))');
    });

    test('Expression 6', () {
      final List<Token> tokens = getTokens('2 + !5 > !7 * 3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '((2 + (!5)) > ((!7) * 3))');
    });

    test('Expression 7', () {
      final List<Token> tokens = getTokens('!2 + 5 >= 7 * !3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '(((!2) + 5) >= (7 * (!3)))');
    });

    test('Expression 8', () {
      final List<Token> tokens = getTokens('2 + -5 < -7 * 3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '((2 + (-5)) < ((-7) * 3))');
    });

    test('Expression 9', () {
      final List<Token> tokens = getTokens('-2 + 5 <= 7 * -3');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '(((-2) + 5) <= (7 * (-3)))');
    });

    test('Expression 10', () {
      final List<Token> tokens = getTokens('true | 4 < false & "test"');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, '((true | 4) < (false & "test"))');
    });

    test('Expression 11', () {
      final List<Token> tokens = getTokens('foo(4 + 1)');
      final Parser parser = Parser(tokens);
      final ParseExpression expression = parser.expression();
      expect(expression.text, 'foo((4 + 1))');
    });
  });
}
