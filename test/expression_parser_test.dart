import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/expression_parser.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  Expression getExpression(String input) {
    final List<Token> tokens = getTokens(input);
    final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

    return parser.expression();
  }

  group('Expression parser', () {
    test('Expression 1', () {
      final Expression expression = getExpression('2 - 1 * 3');
      expect(expression.toString(), '-(2, *(1, 3))');
    });

    test('Expression 2', () {
      final Expression expression = getExpression('2 * 1 - 3');
      expect(expression.toString(), '-(*(2, 1), 3)');
    });

    test('Expression 3', () {
      final Expression expression = getExpression('(2 - 1) * 3');
      expect(expression.toString(), '*(-(2, 1), 3)');
    });

    test('Expression 4', () {
      final Expression expression = getExpression('(2 - 1) != 3 * 4');
      expect(expression.toString(), '!=(-(2, 1), *(3, 4))');
    });

    test('Expression 5', () {
      final Expression expression = getExpression('2 * 4 % 3 == 1 + 3 / 4');
      expect(expression.toString(), '==(%(*(2, 4), 3), +(1, /(3, 4)))');
    });

    test('Expression 6', () {
      final Expression expression = getExpression('2 + !5 > !7 * 3');
      expect(expression.toString(), '>(+(2, !(5)), *(!(7), 3))');
    });

    test('Expression 7', () {
      final Expression expression = getExpression('!2 + 5 >= 7 * !3');
      expect(expression.toString(), '>=(+(!(2), 5), *(7, !(3)))');
    });

    test('Expression 8', () {
      final Expression expression = getExpression('2 + -5 < -7 * 3');
      expect(expression.toString(), '<(+(2, -(0, 5)), *(-(0, 7), 3))');
    });

    test('Expression 9', () {
      final Expression expression = getExpression('-2 + 5 <= 7 * -3');
      expect(expression.toString(), '<=(+(-(0, 2), 5), *(7, -(0, 3)))');
    });

    test('Expression 10', () {
      final Expression expression = getExpression('true | 4 < false & "test"');
      expect(expression.toString(), '<(|(true, 4), &(false, "test"))');
    });

    test('Expression 11', () {
      final Expression expression = getExpression('foo(4 + 1)');
      expect(expression.toString(), 'foo(+(4, 1))');
    });

    test('Expression 12', () {
      final Expression expression = getExpression('foo(bar + 1)');
      expect(expression.toString(), 'foo(+(bar, 1))');
    });

    test('Expression 13', () {
      final Expression expression = getExpression('foo(bar() + 1)');
      expect(expression.toString(), 'foo(+(bar(), 1))');
    });

    test('Expression 14', () {
      final Expression expression = getExpression('foo(bar()() + 1)()');
      expect(expression.toString(), 'foo(+(bar()(), 1))()');
    });

    test('Expression 15', () {
      final Expression expression = getExpression('if true 1 else 2');
      expect(expression.toString(), 'if(true, 1, 2)');
    });

    test('Expression 16', () {
      final Expression expression = getExpression('if (a > b) 1 else 2');
      expect(expression.toString(), 'if(>(a, b), 1, 2)');
    });
  });
}
