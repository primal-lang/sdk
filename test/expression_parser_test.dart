import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Expression Parser', () {
    test('String expression', () {
      final Expression expression = getExpression('"Hello, world!"');
      checkExpressions(
          expression, LiteralExpression.string(stringToken('Hello, world!')));
    });

    test('Number expression', () {
      final Expression expression = getExpression('123');
      checkExpressions(expression, LiteralExpression.number(numberToken(123)));
    });

    test('Boolean expression', () {
      final Expression expression = getExpression('true');
      checkExpressions(
          expression, LiteralExpression.boolean(booleanToken(true)));
    });

    test('Symbol expression', () {
      final Expression expression = getExpression('isEven');
      checkExpressions(
          expression, LiteralExpression.symbol(symbolToken('isEven')));
    });

    test('Function call expression with one parameter', () {
      final Expression expression = getExpression('isEven(x)');
      checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'isEven',
          arguments: [LiteralExpression.symbol(symbolToken('x'))],
          location: const Location(row: 1, column: 1),
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
            LiteralExpression.boolean(booleanToken(true)),
            LiteralExpression.number(numberToken(1.23)),
            LiteralExpression.string(stringToken('hello')),
          ],
          location: const Location(row: 1, column: 1),
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
                LiteralExpression.symbol(symbolToken('x')),
                LiteralExpression.number(numberToken(2)),
              ],
              location: const Location(row: 1, column: 4),
            ),
            LiteralExpression.number(numberToken(0)),
          ],
          location: const Location(row: 1, column: 1),
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
                    LiteralExpression.symbol(symbolToken('x')),
                  ],
                  location: const Location(row: 1, column: 12),
                ),
              ],
              location: const Location(row: 1, column: 5),
            ),
          ],
          location: const Location(row: 1, column: 1),
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
                LiteralExpression.symbol(symbolToken('n')),
                LiteralExpression.number(numberToken(0)),
              ],
              location: const Location(row: 1, column: 4),
            ),
            LiteralExpression.number(numberToken(1)),
            FunctionCallExpression(
              name: 'mul',
              arguments: [
                LiteralExpression.symbol(symbolToken('n')),
                FunctionCallExpression(
                  name: 'factorial',
                  arguments: [
                    FunctionCallExpression(
                      name: 'sub',
                      arguments: [
                        LiteralExpression.symbol(symbolToken('n')),
                        LiteralExpression.number(numberToken(1)),
                      ],
                      location: const Location(row: 1, column: 34),
                    ),
                  ],
                  location: const Location(row: 1, column: 24),
                ),
              ],
              location: const Location(row: 1, column: 17),
            ),
          ],
          location: const Location(row: 1, column: 1),
        ),
      );
    });
  });
}
