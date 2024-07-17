import 'package:dry/compiler/syntactic/expression.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Expression Parser', () {
    test('String expression', () {
      final Expression expression = getExpression('"Hello, world!"');
      checkExpressions(expression, LiteralExpression.string('Hello, world!'));
    });

    test('Number expression', () {
      final Expression expression = getExpression('123');
      checkExpressions(expression, LiteralExpression.number(123));
    });

    test('Boolean expression', () {
      final Expression expression = getExpression('true');
      checkExpressions(expression, LiteralExpression.boolean(true));
    });

    test('Symbol expression', () {
      final Expression expression = getExpression('isEven');
      checkExpressions(expression, LiteralExpression.symbol('isEven'));
    });

    test('Function call expression with one parameter', () {
      final Expression expression = getExpression('isEven(x)');
      checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'isEven',
          arguments: [LiteralExpression.symbol('x')],
        ),
      );
    });

    test('Function call expression with several parameters', () {
      final Expression expression = getExpression('if(true, 1.23, "hello")');
      checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'if',
          arguments: [
            LiteralExpression.boolean(true),
            LiteralExpression.number(1.23),
            LiteralExpression.string('hello'),
          ],
        ),
      );
    });

    test('Chained function calls expression 1', () {
      final Expression expression = getExpression('eq(mod(x, 2), 0)');
      checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'eq',
          arguments: [
            FunctionCallExpression(
              name: 'mod',
              arguments: [
                LiteralExpression.symbol('x'),
                LiteralExpression.number(2),
              ],
            ),
            LiteralExpression.number(0),
          ],
        ),
      );
    });

    test('Chained function calls expression 2', () {
      final Expression expression = getExpression('not(isEven(positive(x)))');
      checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'not',
          arguments: [
            FunctionCallExpression(
              name: 'isEven',
              arguments: [
                FunctionCallExpression(
                  name: 'positive',
                  arguments: [
                    LiteralExpression.symbol('x'),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });

    test('Chained function calls expression 3', () {
      final Expression expression =
          getExpression('if(eq(n, 0), 1, mul(n, factorial(sub(n, 1))))');
      checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'if',
          arguments: [
            FunctionCallExpression(
              name: 'eq',
              arguments: [
                LiteralExpression.symbol('n'),
                LiteralExpression.number(0),
              ],
            ),
            LiteralExpression.number(1),
            FunctionCallExpression(
              name: 'mul',
              arguments: [
                LiteralExpression.symbol('n'),
                FunctionCallExpression(
                  name: 'factorial',
                  arguments: [
                    FunctionCallExpression(
                      name: 'sub',
                      arguments: [
                        LiteralExpression.symbol('n'),
                        LiteralExpression.number(1),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  });
}
