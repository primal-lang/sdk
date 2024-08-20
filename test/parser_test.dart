import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/parser.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  ParseExpression getExpression(String input) {
    final List<Token> tokens = getTokens(input);
    final Parser parser = Parser(tokens);

    return parser.expression();
  }

  group('Parser', () {
    test('Expression 1', () {
      final ParseExpression expression = getExpression('2 - 1 * 3');
      expect(expression.toString(), '(2 - (1 * 3))');
    });

    test('Expression 2', () {
      final ParseExpression expression = getExpression('2 * 1 - 3');
      expect(expression.toString(), '((2 * 1) - 3)');
    });

    test('Expression 3', () {
      final ParseExpression expression = getExpression('(2 - 1) * 3');
      expect(expression.toString(), '((2 - 1) * 3)');
    });

    test('Expression 4', () {
      final ParseExpression expression = getExpression('(2 - 1) != 3 * 4');
      expect(expression.toString(), '((2 - 1) != (3 * 4))');
    });

    test('Expression 5', () {
      final ParseExpression expression =
          getExpression('2 * 4 % 3 == 1 + 3 / 4');
      expect(expression.toString(), '(((2 * 4) % 3) == (1 + (3 / 4)))');
    });

    test('Expression 6', () {
      final ParseExpression expression = getExpression('2 + !5 > !7 * 3');
      expect(expression.toString(), '((2 + (!5)) > ((!7) * 3))');
    });

    test('Expression 7', () {
      final ParseExpression expression = getExpression('!2 + 5 >= 7 * !3');
      expect(expression.toString(), '(((!2) + 5) >= (7 * (!3)))');
    });

    test('Expression 8', () {
      final ParseExpression expression = getExpression('2 + -5 < -7 * 3');
      expect(expression.toString(), '((2 + (-5)) < ((-7) * 3))');
    });

    test('Expression 9', () {
      final ParseExpression expression = getExpression('-2 + 5 <= 7 * -3');
      expect(expression.toString(), '(((-2) + 5) <= (7 * (-3)))');
    });

    test('Expression 10', () {
      final ParseExpression expression =
          getExpression('true | 4 < false & "test"');
      expect(expression.toString(), '((true | 4) < (false & "test"))');
    });

    test('Expression 11', () {
      final ParseExpression expression = getExpression('foo(4 + 1)');
      expect(expression.toString(), 'foo((4 + 1))');
    });

    test('Expression 12', () {
      final ParseExpression expression = getExpression('foo(bar + 1)');
      expect(expression.toString(), 'foo((bar + 1))');
    });

    test('Expression 13', () {
      final ParseExpression expression = getExpression('foo(bar() + 1)');
      expect(expression.toString(), 'foo((bar() + 1))');
    });

    test('Expression 14', () {
      final ParseExpression expression = getExpression('foo(bar()() + 1)()');
      expect(expression.toString(), 'foo((bar()() + 1))()');
    });
  });
}
